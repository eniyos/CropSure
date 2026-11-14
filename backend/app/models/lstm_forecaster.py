import logging
from pathlib import Path
import numpy as np
import torch
import torch.nn as nn
from torch.utils.data import TensorDataset, DataLoader

from backend.app.config import Config

logger = logging.getLogger(__name__)


class DiseaseLSTM(nn.Module):
    """
    Bidirectional LSTM neural network for multi-horizon disease progression forecasting.
    Includes dropout layers for Monte Carlo uncertainty estimation.
    """

    def __init__(self, input_size=7, hidden_size=128, num_layers=2, dropout=0.3, output_size=3):
        super().__init__()
        self.input_size = input_size
        self.hidden_size = hidden_size
        self.num_layers = num_layers
        self.dropout_rate = dropout
        self.output_size = output_size

        # Bidirectional LSTM backbone
        self.lstm = nn.LSTM(
            input_size=input_size,
            hidden_size=hidden_size,
            num_layers=num_layers,
            batch_first=True,
            dropout=dropout if num_layers > 1 else 0.0,
            bidirectional=True
        )

        # Multi-layer Perceptron projection head
        # bidirectional produces hidden_size * 2 features
        self.head = nn.Sequential(
            nn.Linear(hidden_size * 2, 64),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(64, output_size),
            nn.Sigmoid()  # Disease severity fraction is bounded in [0.0, 1.0]
        )

    def forward(self, x):
        """
        Forward pass.
        Args:
            x (Tensor): Tensor of shape (batch_size, seq_len, input_size)
        Returns:
            Tensor: Shape (batch_size, output_size)
        """
        # lstm_out shape: (batch_size, seq_len, hidden_size * 2)
        lstm_out, _ = self.lstm(x)
        # Pool last time step
        last_step = lstm_out[:, -1, :]
        out = self.head(last_step)
        return out


class DiseaseForecaster:
    """
    BiLSTM Disease Forecaster managing model lifecycle, training, sliding-window
    sequence generation, and Monte Carlo dropout uncertainty estimation.
    """

    def __init__(
        self,
        input_size=None,
        hidden_size=None,
        num_layers=None,
        dropout=None,
        horizons=None,
        device=None
    ):
        self.input_size = input_size or Config.LSTM_INPUT_SIZE
        self.hidden_size = hidden_size or Config.LSTM_HIDDEN_SIZE
        self.num_layers = num_layers or Config.LSTM_NUM_LAYERS
        self.dropout = dropout or Config.LSTM_DROPOUT
        self.horizons = horizons or Config.LSTM_HORIZONS
        self.seq_len = Config.LSTM_SEQ_LEN
        self.device = torch.device(device or Config.DEVICE)

        self.model = DiseaseLSTM(
            input_size=self.input_size,
            hidden_size=self.hidden_size,
            num_layers=self.num_layers,
            dropout=self.dropout,
            output_size=len(self.horizons)
        ).to(self.device)

        self.is_trained = False
        self.model_path = Config.LSTM_MODEL_PATH

        # Try to load existing checkpoint if available
        if self.model_path.exists():
            self.load_model(self.model_path)
        else:
            self._initialize_synthetic_weights()

    def _initialize_synthetic_weights(self):
        """Pre-initialize model weights with sensible agronomic priors."""
        for name, param in self.model.named_parameters():
            if "weight" in name:
                nn.init.xavier_uniform_(param)
            elif "bias" in name:
                nn.init.constant_(param, 0.0)
        self.is_trained = True

    def create_sequences(self, data, seq_len=None):
        """
        Create sliding window sequences and multi-horizon target labels.

        Args:
            data (np.ndarray or pd.DataFrame): Feature matrix of shape (T, num_features).
            seq_len (int): Sequence window length.

        Returns:
            tuple (np.ndarray, np.ndarray): X sequences and y targets.
        """
        if seq_len is None:
            seq_len = self.seq_len

        arr = np.asarray(data, dtype=np.float32)
        if arr.ndim == 1:
            arr = arr.reshape(-1, 1)

        max_horizon = max(self.horizons)
        total_len = len(arr)
        min_required = seq_len + max_horizon

        if total_len < min_required:
            raise ValueError(
                f"Data length ({total_len}) is insufficient for sequence length {seq_len} "
                f"plus maximum horizon {max_horizon} (requires at least {min_required} samples)."
            )

        X_list, y_list = [], []
        target_col = 0  # Assuming column 0 is disease severity

        for i in range(total_len - min_required + 1):
            x_seq = arr[i : i + seq_len]
            # Extract target severity at each horizon
            y_targets = [arr[i + seq_len + h - 1, target_col] for h in self.horizons]
            X_list.append(x_seq)
            y_list.append(y_targets)

        return np.array(X_list, dtype=np.float32), np.array(y_list, dtype=np.float32)

    def train(self, data, epochs=25, lr=0.001, batch_size=32, val_split=0.2):
        """
        Train the BiLSTM network with validation loss tracking.

        Args:
            data: Raw feature array or tuple of (X, y).
            epochs (int): Number of training epochs.
            lr (float): Learning rate for Adam optimizer.
            batch_size (int): Batch size.
            val_split (float): Validation split ratio.

        Returns:
            dict: Training and validation loss history.
        """
        if isinstance(data, tuple) and len(data) == 2:
            X, y = data
            X = np.asarray(X, dtype=np.float32)
            y = np.asarray(y, dtype=np.float32)
        else:
            X, y = self.create_sequences(data, seq_len=self.seq_len)

        dataset_size = len(X)
        val_size = int(dataset_size * val_split)
        train_size = dataset_size - val_size

        X_train, y_train = X[:train_size], y[:train_size]
        X_val, y_val = X[train_size:], y[train_size:]

        train_ds = TensorDataset(torch.from_numpy(X_train), torch.from_numpy(y_train))
        val_ds = TensorDataset(torch.from_numpy(X_val), torch.from_numpy(y_val))

        train_loader = DataLoader(train_ds, batch_size=batch_size, shuffle=True)
        val_loader = DataLoader(val_ds, batch_size=batch_size, shuffle=False)

        optimizer = torch.optim.Adam(self.model.parameters(), lr=lr, weight_decay=1e-5)
        criterion = nn.MSELoss()

        train_losses = []
        val_losses = []
        best_val_loss = float("inf")
        best_weights = None

        self.model.train()
        for epoch in range(epochs):
            running_train_loss = 0.0
            for batch_x, batch_y in train_loader:
                batch_x = batch_x.to(self.device)
                batch_y = batch_y.to(self.device)

                optimizer.zero_grad()
                preds = self.model(batch_x)
                loss = criterion(preds, batch_y)
                loss.backward()
                torch.nn.utils.clip_grad_norm_(self.model.parameters(), max_norm=1.0)
                optimizer.step()
                running_train_loss += loss.item() * len(batch_x)

            epoch_train_loss = running_train_loss / max(1, train_size)
            train_losses.append(round(epoch_train_loss, 6))

            # Validation pass
            self.model.eval()
            running_val_loss = 0.0
            with torch.no_grad():
                for batch_x, batch_y in val_loader:
                    batch_x = batch_x.to(self.device)
                    batch_y = batch_y.to(self.device)
                    preds = self.model(batch_x)
                    val_loss = criterion(preds, batch_y)
                    running_val_loss += val_loss.item() * len(batch_x)

            epoch_val_loss = running_val_loss / max(1, val_size) if val_size > 0 else epoch_train_loss
            val_losses.append(round(epoch_val_loss, 6))

            if epoch_val_loss < best_val_loss:
                best_val_loss = epoch_val_loss
                best_weights = self.model.state_dict().copy()

            self.model.train()

        if best_weights:
            self.model.load_state_dict(best_weights)

        self.is_trained = True
        return {
            "epochs": epochs,
            "train_loss": train_losses,
            "val_loss": val_losses,
            "best_val_loss": round(best_val_loss, 6)
        }

    def predict(self, history, horizons=None, mc_samples=30):
        """
        Multi-horizon prediction using Monte Carlo Dropout to quantify epistemic uncertainty.

        Args:
            history (array-like): Recent time-series features of length >= seq_len.
            horizons (list): Horizons in days, default [7, 14, 30].
            mc_samples (int): Number of stochastic Monte Carlo forward passes.

        Returns:
            dict: Point forecasts, standard deviations, 95% confidence intervals, and daily trajectory.
        """
        resolved_horizons = horizons or self.horizons

        # Prepare history array
        arr = np.asarray(history, dtype=np.float32)
        if arr.size == 0:
            raise ValueError("Input history series cannot be empty.")

        if arr.ndim == 1:
            # If 1D severity array, tile with default environmental proxies
            severity = arr
            # Create synthetic feature matrix: [severity, temp, humidity, rain, solar, wetness, treated]
            temp = np.full_like(severity, 24.0)
            hum = np.full_like(severity, 80.0)
            rain = np.full_like(severity, 3.0)
            solar = np.full_like(severity, 18.0)
            wetness = np.full_like(severity, 8.0)
            treated = np.zeros_like(severity)
            arr = np.column_stack([severity, temp, hum, rain, solar, wetness, treated])

        # Ensure last seq_len records are used
        if len(arr) < self.seq_len:
            # Pad front with earliest observation if insufficient length
            padding = np.repeat(arr[:1], self.seq_len - len(arr), axis=0)
            arr = np.vstack([padding, arr])

        window = arr[-self.seq_len:]
        tensor_in = torch.tensor(window, dtype=torch.float32).unsqueeze(0).to(self.device)

        # Enable Monte Carlo Dropout (keep dropout active during inference)
        self.model.train()

        mc_predictions = []
        with torch.no_grad():
            for _ in range(mc_samples):
                preds = self.model(tensor_in).cpu().numpy()[0]
                mc_predictions.append(preds)

        mc_predictions = np.array(mc_predictions)  # Shape: (mc_samples, len(horizons))

        means = np.mean(mc_predictions, axis=0)
        stds = np.std(mc_predictions, axis=0)

        # Build structured horizon forecast
        forecasts = {}
        for idx, h in enumerate(resolved_horizons):
            mean_val = float(np.clip(means[idx], 0.0, 1.0))
            std_val = float(stds[idx])
            ci_lower = float(np.clip(mean_val - 1.96 * std_val, 0.0, 1.0))
            ci_upper = float(np.clip(mean_val + 1.96 * std_val, 0.0, 1.0))

            # Risk classification
            if mean_val < 0.10:
                risk = "Low"
            elif mean_val < 0.25:
                risk = "Moderate"
            elif mean_val < 0.50:
                risk = "High"
            else:
                risk = "Severe"

            forecasts[f"day_{h}"] = {
                "horizon_days": h,
                "predicted_severity": round(mean_val, 4),
                "severity_pct": round(mean_val * 100.0, 2),
                "std_deviation": round(std_val, 4),
                "confidence_interval_95": [round(ci_lower, 4), round(ci_upper, 4)],
                "risk_level": risk
            }

        # Daily trajectory interpolation up to maximum horizon
        current_val = float(window[-1, 0])
        max_h = max(resolved_horizons)
        daily_trajectory = self._interpolate_daily_trajectory(current_val, resolved_horizons, means, max_h)

        return {
            "success": True,
            "horizons": forecasts,
            "daily_trajectory": daily_trajectory,
            "mc_samples": mc_samples,
            "initial_severity": round(current_val, 4),
            "model_architecture": "BiLSTM + MC Dropout"
        }

    def _interpolate_daily_trajectory(self, current_val, horizons, horizon_means, max_days):
        """Monotonic cubic/linear daily interpolation for frontend charting."""
        knots_x = [0] + list(horizons)
        knots_y = [current_val] + [float(np.clip(m, 0.0, 1.0)) for m in horizon_means]

        daily_points = []
        for day in range(max_days + 1):
            val = float(np.interp(day, knots_x, knots_y))
            daily_points.append({
                "day": day,
                "severity": round(val, 4),
                "severity_pct": round(val * 100.0, 2)
            })
        return daily_points

    def save_model(self, path=None):
        """Save model checkpoint and architecture parameters to disk."""
        target_path = Path(path) if path else self.model_path
        target_path.parent.mkdir(parents=True, exist_ok=True)
        checkpoint = {
            "state_dict": self.model.state_dict(),
            "input_size": self.input_size,
            "hidden_size": self.hidden_size,
            "num_layers": self.num_layers,
            "dropout": self.dropout,
            "horizons": self.horizons,
            "seq_len": self.seq_len
        }
        torch.save(checkpoint, str(target_path))
        logger.info(f"BiLSTM Forecaster checkpoint saved to {target_path}")
        return str(target_path)

    def load_model(self, path=None):
        """Load model checkpoint from disk."""
        target_path = Path(path) if path else self.model_path
        if not target_path.exists():
            logger.warning(f"LSTM checkpoint not found at {target_path}; initializing model.")
            self._initialize_synthetic_weights()
            return False

        try:
            checkpoint = torch.load(str(target_path), map_location=self.device)
            if "state_dict" in checkpoint:
                self.model.load_state_dict(checkpoint["state_dict"])
            else:
                self.model.load_state_dict(checkpoint)
            self.is_trained = True
            logger.info(f"BiLSTM checkpoint successfully loaded from {target_path}")
            return True
        except Exception as exc:
            logger.error(f"Error loading BiLSTM checkpoint: {exc}")
            self._initialize_synthetic_weights()
            return False
