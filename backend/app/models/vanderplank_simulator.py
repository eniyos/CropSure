import logging
from pathlib import Path
import numpy as np
import pandas as pd
from scipy.integrate import solve_ivp

logger = logging.getLogger(__name__)

# NumPy 2.0+ uses trapezoid; NumPy 1.x uses trapz
_trapezoid = getattr(np, "trapezoid", getattr(np, "trapz", None))


class VanDerPlankSimulator:
    """
    Van der Plank Delay-Differential Epidemic Simulator.
    Models plant disease dynamics taking into account latent period, sporulation,
    microclimatic environmental drivers (temperature, humidity, precipitation),
    and Area Under Disease Progress Curve (AUDPC).
    """

    def __init__(
        self,
        initial_inoculum=0.01,
        infection_rate=0.25,
        latent_period=5,
        sporulation_period=14,
        temp=24.0,
        humidity=85.0,
        precipitation=5.0
    ):
        """
        Initialize simulator parameters.

        Args:
            initial_inoculum (float): Initial proportion of infected tissue (0.0001 - 0.1).
            infection_rate (float): Base intrinsic apparent infection rate r (per day).
            latent_period (int or float): Latent period p (days) before lesions become infectious.
            sporulation_period (int or float): Duration i (days) lesions remain infectious.
            temp (float): Mean ambient temperature (°C).
            humidity (float): Relative humidity (%).
            precipitation (float): Daily rainfall or leaf wetness precipitation (mm/day).
        """
        self.initial_inoculum = float(np.clip(initial_inoculum, 1e-6, 0.5))
        self.infection_rate = float(np.clip(infection_rate, 0.01, 1.5))
        self.latent_period = max(1, int(round(latent_period)))
        self.sporulation_period = max(1, int(round(sporulation_period)))
        self.temp = float(temp)
        self.humidity = float(np.clip(humidity, 10.0, 100.0))
        self.precipitation = float(max(0.0, precipitation))

    def calculate_environmental_modifier(self, temp=None, humidity=None, precipitation=None):
        """
        Calculate environmental multiplier E in [0, 1] modifying apparent infection rate r.
        Considers cardinal temperatures (Tmin=10°C, Topt=24°C, Tmax=35°C), relative humidity,
        and rainfall-induced leaf wetness duration.
        """
        t = self.temp if temp is None else float(temp)
        h = self.humidity if humidity is None else float(humidity)
        p = self.precipitation if precipitation is None else float(precipitation)

        # 1. Temperature Modifier (Yan & Hunt cardinal temperature response)
        t_min, t_opt, t_max = 10.0, 24.0, 35.0
        if t <= t_min or t >= t_max:
            t_mod = 0.05
        else:
            # Generalized bell curve centered at T_opt
            t_mod = np.exp(-0.5 * ((t - t_opt) / 4.5) ** 2)

        # 2. Humidity Modifier (Sigmoidal curve favoring RH > 75%)
        # Standard foliar fungal pathogens germinate rapidly at RH > 80%
        h_mod = 1.0 / (1.0 + np.exp(-0.12 * (h - 75.0)))

        # 3. Precipitation / Free Moisture Modifier
        # Rainfall enhances spore splash and prolongs leaf wetness
        p_mod = 1.0 - 0.6 * np.exp(-0.4 * p)

        env_mult = float(np.clip(t_mod * h_mod * p_mod, 0.01, 1.0))
        return env_mult

    def simulate(self, days=90, custom_params=None):
        """
        Simulate epidemic disease progression across time horizon.

        Args:
            days (int): Number of simulation days (default 90).
            custom_params (dict): Optional parameter overrides.

        Returns:
            dict: Trajectory time-series, daily rates, AUDPC, peak day, inflection point.
        """
        params = {
            "initial_inoculum": self.initial_inoculum,
            "infection_rate": self.infection_rate,
            "latent_period": self.latent_period,
            "sporulation_period": self.sporulation_period,
            "temp": self.temp,
            "humidity": self.humidity,
            "precipitation": self.precipitation
        }
        if custom_params:
            params.update(custom_params)

        y0 = float(np.clip(params["initial_inoculum"], 1e-6, 0.5))
        base_r = float(params["infection_rate"])
        p = max(1, int(round(params["latent_period"])))
        i = max(1, int(round(params["sporulation_period"])))

        env_mod = self.calculate_environmental_modifier(
            temp=params["temp"],
            humidity=params["humidity"],
            precipitation=params["precipitation"]
        )
        effective_r = base_r * env_mod

        # Discrete-delay integration step
        dt = 0.25  # Quarter-day resolution for numerical stability
        total_steps = int(days / dt) + 1
        time_points = np.linspace(0, days, total_steps)

        # Buffer to store historical disease severity y(t)
        y_history = np.zeros(total_steps, dtype=np.float64)
        y_history[0] = y0

        steps_per_day = int(1.0 / dt)
        p_steps = p * steps_per_day
        i_steps = i * steps_per_day

        daily_rate_record = np.zeros(total_steps, dtype=np.float64)

        for step in range(total_steps - 1):
            curr_y = y_history[step]

            # Inoculum tissue that has completed latency (t - p)
            if step >= p_steps:
                y_latent_matured = y_history[step - p_steps]
            else:
                y_latent_matured = y0

            # Tissue that has aged out of sporulation (t - p - i)
            if step >= (p_steps + i_steps):
                y_exhausted = y_history[step - (p_steps + i_steps)]
            else:
                y_exhausted = 0.0

            # Active infectious tissue
            infectious_tissue = np.clip(y_latent_matured - y_exhausted, 0.0, curr_y)

            # Available healthy host tissue: (1 - y)
            healthy_tissue = max(0.0, 1.0 - curr_y)

            # Van der Plank delay rate
            dy_dt = effective_r * (infectious_tissue + y0 * 0.1) * healthy_tissue

            # Euler-Maruyama / RK step with clamping
            next_y = curr_y + dy_dt * dt
            next_y = np.clip(next_y, 0.0, 1.0)
            y_history[step + 1] = next_y
            daily_rate_record[step + 1] = dy_dt

        # Downsample to daily values for standard agricultural reporting
        daily_indices = [int(round(d * steps_per_day)) for d in range(days + 1)]
        daily_indices = [idx if idx < total_steps else total_steps - 1 for idx in daily_indices]

        daily_days = list(range(days + 1))
        daily_severity = [round(float(y_history[idx]), 5) for idx in daily_indices]
        daily_rates = [round(float(daily_rate_record[idx]), 5) for idx in daily_indices]

        # Calculate Area Under Disease Progress Curve (AUDPC)
        # AUDPC = sum_i ((y_i + y_{i+1}) / 2 * (t_{i+1} - t_i))
        audpc = float(_trapezoid(daily_severity, daily_days))

        # Peak infection rate day
        peak_rate_idx = int(np.argmax(daily_rates))
        peak_day = daily_days[peak_rate_idx]

        # Inflection day (when severity reaches 50% or maximum rate)
        inflection_day = None
        for d, s in zip(daily_days, daily_severity):
            if s >= 0.5:
                inflection_day = d
                break
        if inflection_day is None:
            inflection_day = peak_day

        return {
            "days": daily_days,
            "severity_trajectory": daily_severity,
            "daily_infection_rate": daily_rates,
            "audpc": round(audpc, 2),
            "peak_day": peak_day,
            "inflection_day": inflection_day,
            "final_severity": daily_severity[-1],
            "effective_infection_rate": round(effective_r, 4),
            "environmental_modifier": round(env_mod, 4),
            "parameters": {
                "initial_inoculum": y0,
                "infection_rate": base_r,
                "latent_period": p,
                "sporulation_period": i,
                "temp": params["temp"],
                "humidity": params["humidity"],
                "precipitation": params["precipitation"]
            }
        }

    def compare_scenarios(self, days=90):
        """
        Compare 4 standard epidemiological management scenarios:
        1. Favorable (high pathogen spread: warm, humid, wet)
        2. Unfavorable (hot/dry, poor spore germination)
        3. Treated (early therapeutic intervention reducing rate by 75% at day 20)
        4. Untreated Baseline (ambient baseline parameters)
        """
        # Baseline
        base_res = self.simulate(days=days)

        # Favorable
        favorable_res = self.simulate(days=days, custom_params={
            "temp": 24.0,
            "humidity": 92.0,
            "precipitation": 12.0,
            "infection_rate": 0.35
        })

        # Unfavorable
        unfavorable_res = self.simulate(days=days, custom_params={
            "temp": 34.0,
            "humidity": 45.0,
            "precipitation": 0.0,
            "infection_rate": 0.12
        })

        # Treated intervention scenario
        # Simulate initial 20 days normally, then intervene
        sim_treated = self._simulate_with_intervention(
            days=days,
            intervention_day=20,
            efficacy=0.80
        )

        return {
            "baseline": base_res,
            "favorable": favorable_res,
            "unfavorable": unfavorable_res,
            "treated": sim_treated,
            "audpc_comparison": {
                "baseline": base_res["audpc"],
                "favorable": favorable_res["audpc"],
                "unfavorable": unfavorable_res["audpc"],
                "treated": sim_treated["audpc"]
            },
            "loss_reduction_pct": round(
                max(0.0, (base_res["audpc"] - sim_treated["audpc"]) / (base_res["audpc"] + 1e-6) * 100.0),
                2
            )
        }

    def _simulate_with_intervention(self, days=90, intervention_day=20, efficacy=0.80):
        """Simulate disease trajectory with chemical or biological remediation applied at intervention_day."""
        dt = 0.25
        total_steps = int(days / dt) + 1
        steps_per_day = int(1.0 / dt)
        intervention_step = intervention_day * steps_per_day

        env_mod = self.calculate_environmental_modifier()
        base_eff_r = self.infection_rate * env_mod

        p_steps = self.latent_period * steps_per_day
        i_steps = self.sporulation_period * steps_per_day

        y_history = np.zeros(total_steps, dtype=np.float64)
        y_history[0] = self.initial_inoculum
        daily_rate_record = np.zeros(total_steps, dtype=np.float64)

        for step in range(total_steps - 1):
            curr_y = y_history[step]

            # Post-intervention effective rate drops by efficacy
            current_r = base_eff_r * (1.0 - efficacy) if step >= intervention_step else base_eff_r

            y_lat = y_history[step - p_steps] if step >= p_steps else self.initial_inoculum
            y_exh = y_history[step - (p_steps + i_steps)] if step >= (p_steps + i_steps) else 0.0

            infectious = np.clip(y_lat - y_exh, 0.0, curr_y)
            healthy = max(0.0, 1.0 - curr_y)

            dy_dt = current_r * (infectious + self.initial_inoculum * 0.05) * healthy
            next_y = np.clip(curr_y + dy_dt * dt, 0.0, 1.0)
            y_history[step + 1] = next_y
            daily_rate_record[step + 1] = dy_dt

        daily_indices = [min(int(round(d * steps_per_day)), total_steps - 1) for d in range(days + 1)]
        daily_days = list(range(days + 1))
        daily_severity = [round(float(y_history[idx]), 5) for idx in daily_indices]
        daily_rates = [round(float(daily_rate_record[idx]), 5) for idx in daily_indices]
        audpc = float(_trapezoid(daily_severity, daily_days))

        return {
            "days": daily_days,
            "severity_trajectory": daily_severity,
            "daily_infection_rate": daily_rates,
            "audpc": round(audpc, 2),
            "peak_day": daily_days[int(np.argmax(daily_rates))],
            "final_severity": daily_severity[-1],
            "intervention_day": intervention_day,
            "efficacy_pct": efficacy * 100.0
        }

    def generate_trajectories(self, n=5000, days=90, random_state=42):
        """
        Generate n synthetic epidemic disease trajectories with randomized biological and climatic parameters.

        Args:
            n (int): Number of trajectory simulations (default 5000).
            days (int): Number of simulated days per run.
            random_state (int): Seed for reproducibility.

        Returns:
            pandas.DataFrame: Tabular trajectories with metadata.
        """
        rng = np.random.RandomState(random_state)
        records = []

        # Parameter distributions
        inoculums = rng.uniform(0.001, 0.05, n)
        rates = rng.uniform(0.10, 0.45, n)
        latents = rng.randint(3, 9, n)
        sporulations = rng.randint(8, 20, n)
        temperatures = rng.uniform(16.0, 32.0, n)
        humidities = rng.uniform(50.0, 98.0, n)
        precipitations = rng.exponential(scale=6.0, size=n)

        for i in range(n):
            sim_inst = VanDerPlankSimulator(
                initial_inoculum=inoculums[i],
                infection_rate=rates[i],
                latent_period=latents[i],
                sporulation_period=sporulations[i],
                temp=temperatures[i],
                humidity=humidities[i],
                precipitation=precipitations[i]
            )
            res = sim_inst.simulate(days=days)

            traj_data = {
                "trajectory_id": i,
                "initial_inoculum": round(inoculums[i], 4),
                "infection_rate": round(rates[i], 4),
                "latent_period": int(latents[i]),
                "sporulation_period": int(sporulations[i]),
                "temp": round(temperatures[i], 1),
                "humidity": round(humidities[i], 1),
                "precipitation": round(precipitations[i], 1),
                "audpc": res["audpc"],
                "final_severity": res["final_severity"],
                "peak_day": res["peak_day"]
            }

            # Sample key day snapshots (Day 7, 14, 21, 30, 45, 60, 90)
            sample_days = [7, 14, 21, 30, 45, 60, 90]
            for d in sample_days:
                if d < len(res["severity_trajectory"]):
                    traj_data[f"day_{d}_severity"] = res["severity_trajectory"][d]

            records.append(traj_data)

        return pd.DataFrame(records)

    def save_trajectories(self, path, n=1000):
        """
        Generate and persist synthetic epidemic trajectories to CSV file.

        Args:
            path: Target file path.
            n (int): Number of trajectory simulations to save.

        Returns:
            str: Absolute path of written CSV.
        """
        target_path = Path(path)
        target_path.parent.mkdir(parents=True, exist_ok=True)

        logger.info(f"Generating {n} epidemiological trajectories for {target_path}...")
        df = self.generate_trajectories(n=n)
        df.to_csv(target_path, index=False)
        logger.info(f"Successfully saved {len(df)} trajectories to {target_path}")
        return str(target_path)
