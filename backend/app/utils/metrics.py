import numpy as np
from sklearn.metrics import (
    mean_absolute_error,
    mean_squared_error,
    r2_score,
    confusion_matrix,
    classification_report
)


def calculate_mae(y_true, y_pred):
    """
    Calculate Mean Absolute Error (MAE).
    """
    y_t = np.asarray(y_true, dtype=np.float64)
    y_p = np.asarray(y_pred, dtype=np.float64)
    return float(mean_absolute_error(y_t, y_p))


def calculate_rmse(y_true, y_pred):
    """
    Calculate Root Mean Squared Error (RMSE).
    """
    y_t = np.asarray(y_true, dtype=np.float64)
    y_p = np.asarray(y_pred, dtype=np.float64)
    return float(np.sqrt(mean_squared_error(y_t, y_p)))


def calculate_r2(y_true, y_pred):
    """
    Calculate Coefficient of Determination (R^2 Score).
    Handles edge cases with constant target.
    """
    y_t = np.asarray(y_true, dtype=np.float64)
    y_p = np.asarray(y_pred, dtype=np.float64)
    if len(y_t) < 2 or np.all(y_t == y_t[0]):
        return 1.0 if np.allclose(y_t, y_p) else 0.0
    return float(r2_score(y_t, y_p))


def calculate_mape(y_true, y_pred, epsilon=1e-6):
    """
    Calculate Mean Absolute Percentage Error (MAPE).
    Uses epsilon to avoid division by zero.
    """
    y_t = np.asarray(y_true, dtype=np.float64)
    y_p = np.asarray(y_pred, dtype=np.float64)
    denominator = np.where(np.abs(y_t) < epsilon, epsilon, np.abs(y_t))
    return float(np.mean(np.abs((y_t - y_p) / denominator)) * 100.0)


def confusion_matrix_report(y_true, y_pred, labels=None):
    """
    Generate confusion matrix along with labels.

    Returns:
        dict: {"matrix": list_of_lists, "labels": list}
    """
    matrix = confusion_matrix(y_true, y_pred, labels=labels)
    resolved_labels = list(labels) if labels is not None else sorted(list(set(y_true) | set(y_pred)))
    return {
        "matrix": matrix.tolist(),
        "labels": resolved_labels
    }


def classification_report_dict(y_true, y_pred, labels=None):
    """
    Generate classification metrics (precision, recall, f1, support) as a dictionary.

    Returns:
        dict: Classification report formatted as structured JSON dictionary.
    """
    report = classification_report(
        y_true,
        y_pred,
        labels=labels,
        output_dict=True,
        zero_division=0
    )
    return report
