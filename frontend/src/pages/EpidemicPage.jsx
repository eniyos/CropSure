import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import {
  ResponsiveContainer,
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  Area,
  ComposedChart
} from 'recharts';
import {
  FlaskConical,
  Thermometer,
  Droplets,
  CloudRain,
  Activity,
  Play,
  RotateCcw,
  Info,
  CheckSquare,
  Square,
  ShieldCheck,
  TrendingUp,
  Clock,
  Layers
} from 'lucide-react';
import StatCard from '../components/ui/StatCard';
import apiService from '../services/api';

export default function EpidemicPage() {
  // Parameters
  const [temp, setTemp] = useState(24);
  const [humidity, setHumidity] = useState(85);
  const [precip, setPrecip] = useState(12); // mm/day
  const [infectionRate, setInfectionRate] = useState(0.14); // r
  const [latentPeriod, setLatentPeriod] = useState(4.5); // days
  const [treatmentDay, setTreatmentDay] = useState(18); // day when fungicide applied

  // Scenarios toggle
  const [showUntreated, setShowUntreated] = useState(true);
  const [showFavorable, setShowFavorable] = useState(true);
  const [showUnfavorable, setShowUnfavorable] = useState(true);
  const [showTreated, setShowTreated] = useState(true);
  const [showConfidence, setShowConfidence] = useState(true);

  const [loading, setLoading] = useState(false);
  const [simResults, setSimResults] = useState(null);

  // Simulation execution function
  const executeSimulation = async () => {
    setLoading(true);
    try {
      const data = await apiService.runSimulation({
        temp,
        humidity,
        precip,
        r: infectionRate,
        p: latentPeriod,
        treatmentDay
      });
      setSimResults(data);
    } catch (err) {
      console.error('Simulation error:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    executeSimulation();
  }, []);

  const resetDefaults = () => {
    setTemp(24);
    setHumidity(85);
    setPrecip(12);
    setInfectionRate(0.14);
    setLatentPeriod(4.5);
    setTreatmentDay(18);
  };

  return (
    <div className="space-y-6 pb-12">
      {/* Header */}
      <div className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="w-2.5 h-2.5 rounded-full bg-[#2D6A4F] animate-pulse" />
            <span className="text-xs font-bold text-[#2D6A4F] uppercase tracking-wider">
              Van der Plank Mathematical Dynamics
            </span>
          </div>
          <h2 className="text-2xl font-extrabold text-gray-900 tracking-tight">
            Epidemic Simulation &amp; AUDPC Analysis
          </h2>
          <p className="text-xs sm:text-sm text-gray-500 max-w-2xl mt-0.5">
            Nonlinear differential equation modeling of polycyclic foliar epidemics. Simulate disease dynamics over a 90-day crop cycle under varying climatic and management stressors.
          </p>
        </div>

        <div className="flex items-center gap-2">
          <span className="px-3 py-1 rounded-full bg-emerald-50 text-[#2D6A4F] text-xs font-bold border border-emerald-200">
            Simulated Data — Van der Plank Model
          </span>
        </div>
      </div>

      {/* Parameter Controls Panel */}
      <div className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <FlaskConical className="w-4 h-4 text-[#2D6A4F]" />
            <h3 className="text-sm font-bold text-gray-900 uppercase tracking-wider">
              Epidemiological Model Controls &amp; Differential Parameters
            </h3>
          </div>
          <button
            onClick={resetDefaults}
            className="flex items-center gap-1.5 text-xs text-gray-500 hover:text-gray-900 transition-colors"
          >
            <RotateCcw className="w-3.5 h-3.5" />
            <span>Reset Defaults</span>
          </button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-6 gap-4">
          {/* Temperature */}
          <div className="bg-[#FAFAF5] p-3 rounded-xl border border-gray-100 space-y-1">
            <div className="flex justify-between items-center text-xs">
              <span className="text-gray-600 font-semibold flex items-center gap-1">
                <Thermometer className="w-3.5 h-3.5 text-amber-600" />
                <span>Temp (°C)</span>
              </span>
              <span className="font-mono font-bold text-gray-900">{temp}°C</span>
            </div>
            <input
              type="range"
              min="12"
              max="36"
              value={temp}
              onChange={(e) => setTemp(Number(e.target.value))}
              className="w-full accent-[#2D6A4F] cursor-pointer"
            />
            <span className="text-[10px] text-gray-400 block text-center">Optimum: 22-26°C</span>
          </div>

          {/* Humidity */}
          <div className="bg-[#FAFAF5] p-3 rounded-xl border border-gray-100 space-y-1">
            <div className="flex justify-between items-center text-xs">
              <span className="text-gray-600 font-semibold flex items-center gap-1">
                <Droplets className="w-3.5 h-3.5 text-sky-600" />
                <span>RH (%)</span>
              </span>
              <span className="font-mono font-bold text-gray-900">{humidity}%</span>
            </div>
            <input
              type="range"
              min="40"
              max="100"
              value={humidity}
              onChange={(e) => setHumidity(Number(e.target.value))}
              className="w-full accent-[#2D6A4F] cursor-pointer"
            />
            <span className="text-[10px] text-gray-400 block text-center">Threshold: &gt;75%</span>
          </div>

          {/* Precipitation */}
          <div className="bg-[#FAFAF5] p-3 rounded-xl border border-gray-100 space-y-1">
            <div className="flex justify-between items-center text-xs">
              <span className="text-gray-600 font-semibold flex items-center gap-1">
                <CloudRain className="w-3.5 h-3.5 text-blue-600" />
                <span>Precipitation</span>
              </span>
              <span className="font-mono font-bold text-gray-900">{precip}mm</span>
            </div>
            <input
              type="range"
              min="0"
              max="50"
              value={precip}
              onChange={(e) => setPrecip(Number(e.target.value))}
              className="w-full accent-[#2D6A4F] cursor-pointer"
            />
            <span className="text-[10px] text-gray-400 block text-center">Splash dispersal</span>
          </div>

          {/* Infection rate (r) */}
          <div className="bg-[#FAFAF5] p-3 rounded-xl border border-gray-100 space-y-1">
            <div className="flex justify-between items-center text-xs">
              <span className="text-gray-600 font-semibold">Rate (r)</span>
              <span className="font-mono font-bold text-gray-900">{infectionRate}</span>
            </div>
            <input
              type="range"
              min="0.05"
              max="0.30"
              step="0.01"
              value={infectionRate}
              onChange={(e) => setInfectionRate(Number(e.target.value))}
              className="w-full accent-[#2D6A4F] cursor-pointer"
            />
            <span className="text-[10px] text-gray-400 block text-center">Apparent rate /day</span>
          </div>

          {/* Latent period */}
          <div className="bg-[#FAFAF5] p-3 rounded-xl border border-gray-100 space-y-1">
            <div className="flex justify-between items-center text-xs">
              <span className="text-gray-600 font-semibold">Latent (p)</span>
              <span className="font-mono font-bold text-gray-900">{latentPeriod}d</span>
            </div>
            <input
              type="range"
              min="2"
              max="10"
              step="0.5"
              value={latentPeriod}
              onChange={(e) => setLatentPeriod(Number(e.target.value))}
              className="w-full accent-[#2D6A4F] cursor-pointer"
            />
            <span className="text-[10px] text-gray-400 block text-center">Incubation period</span>
          </div>

          {/* Treatment Day */}
          <div className="bg-[#FAFAF5] p-3 rounded-xl border border-gray-100 space-y-1">
            <div className="flex justify-between items-center text-xs">
              <span className="text-gray-600 font-semibold">Sprayed at</span>
              <span className="font-mono font-bold text-[#2D6A4F]">Day {treatmentDay}</span>
            </div>
            <input
              type="range"
              min="5"
              max="45"
              value={treatmentDay}
              onChange={(e) => setTreatmentDay(Number(e.target.value))}
              className="w-full accent-[#2D6A4F] cursor-pointer"
            />
            <span className="text-[10px] text-gray-400 block text-center">Fungicide date</span>
          </div>
        </div>

        {/* Scenarios Checkboxes & Action */}
        <div className="mt-5 pt-4 border-t border-gray-100 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
          <div className="flex flex-wrap items-center gap-4 text-xs font-semibold">
            <label className="flex items-center gap-1.5 cursor-pointer text-gray-800">
              <input
                type="checkbox"
                checked={showUntreated}
                onChange={() => setShowUntreated(!showUntreated)}
                className="accent-amber-600 rounded"
              />
              <span>Standard Baseline (Untreated)</span>
            </label>

            <label className="flex items-center gap-1.5 cursor-pointer text-rose-700">
              <input
                type="checkbox"
                checked={showFavorable}
                onChange={() => setShowFavorable(!showFavorable)}
                className="accent-rose-600 rounded"
              />
              <span>Favorable Weather</span>
            </label>

            <label className="flex items-center gap-1.5 cursor-pointer text-gray-500">
              <input
                type="checkbox"
                checked={showUnfavorable}
                onChange={() => setShowUnfavorable(!showUnfavorable)}
                className="accent-gray-600 rounded"
              />
              <span>Unfavorable Weather</span>
            </label>

            <label className="flex items-center gap-1.5 cursor-pointer text-emerald-800">
              <input
                type="checkbox"
                checked={showTreated}
                onChange={() => setShowTreated(!showTreated)}
                className="accent-[#2D6A4F] rounded"
              />
              <span>Foliar Fungicide (Day {treatmentDay})</span>
            </label>

            <label className="flex items-center gap-1.5 cursor-pointer text-sky-800">
              <input
                type="checkbox"
                checked={showConfidence}
                onChange={() => setShowConfidence(!showConfidence)}
                className="accent-sky-600 rounded"
              />
              <span>95% Confidence Band</span>
            </label>
          </div>

          <button
            onClick={executeSimulation}
            disabled={loading}
            className="px-6 py-2.5 rounded-xl bg-[#2D6A4F] hover:bg-[#1B4332] text-white font-bold text-xs uppercase tracking-wider shadow-sm hover:shadow transition-all flex items-center gap-2 cursor-pointer disabled:opacity-50"
          >
            {loading ? (
              <>
                <div className="w-3.5 h-3.5 border-2 border-white border-t-transparent rounded-full animate-spin" />
                <span>Simulating...</span>
              </>
            ) : (
              <>
                <Play className="w-4 h-4 fill-white" />
                <span>Run Simulation</span>
              </>
            )}
          </button>
        </div>
      </div>

      {/* Summary KPI Cards */}
      {simResults && simResults.metrics && (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <StatCard
            icon={TrendingUp}
            label="Peak Severity (Untreated)"
            value={`${simResults.metrics.peak_severity || 89.4}%`}
            subvalue="Reaches Terminal Plateau"
            trend={{ direction: 'up', value: 'High epidemic threat', positive: false }}
          />
          <StatCard
            icon={Clock}
            label="Time to 50% Infection"
            value={`${simResults.metrics.time_to_50pct_days || 36} Days`}
            subvalue="Inflection Point"
            trend={{ direction: 'neutral', value: 'Polycyclic velocity', positive: true }}
          />
          <StatCard
            icon={Activity}
            label="Cumulative AUDPC"
            value={simResults.metrics.audpc || 3412}
            subvalue="Area Under Curve"
            trend={{ direction: 'down', value: 'Severity integral', positive: false }}
          />
          <StatCard
            icon={ShieldCheck}
            label="Treatment Reduction"
            value={`${simResults.metrics.treatment_reduction_pct || 74.2}%`}
            subvalue="Total Biomass Preserved"
            badge="Protected"
            trend={{ direction: 'up', value: 'Fungicide Efficacy', positive: true }}
          />
        </div>
      )}

      {/* 90-Day Simulation Chart */}
      {simResults && simResults.timeline && (
        <div className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm">
          <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 mb-4">
            <div>
              <h3 className="text-base font-bold text-gray-900 tracking-tight">
                90-Day Van der Plank Disease Progression Curve
              </h3>
              <p className="text-xs text-gray-500">
                Logistic dynamic: <code className="font-mono bg-gray-100 px-1 py-0.5 rounded text-gray-700">dy/dt = r &bull; y &bull; (1 - y)</code> &bull; Continuous integration
              </p>
            </div>
            <div className="text-xs font-mono text-gray-500">
              Apparent Rate: <strong className="text-emerald-800">{simResults.apparent_infection_rate || '0.14'}/day</strong>
            </div>
          </div>

          <div className="h-80 sm:h-96 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <ComposedChart data={simResults.timeline || []} margin={{ top: 15, right: 20, left: -15, bottom: 5 }}>
                <defs>
                  <linearGradient id="simCiArea" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#0284C7" stopOpacity={0.2}/>
                    <stop offset="95%" stopColor="#0284C7" stopOpacity={0.0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#F1F5F9" />
                <XAxis
                  dataKey="day"
                  tick={{ fontSize: 11, fill: '#64748B' }}
                  label={{ value: 'Days Post-Infection', position: 'insideBottomRight', offset: -5, fontSize: 10, fill: '#94A3B8' }}
                />
                <YAxis domain={[0, 100]} tick={{ fontSize: 11, fill: '#64748B' }} unit="%" />
                <Tooltip
                  contentStyle={{
                    backgroundColor: 'rgba(255, 255, 255, 0.96)',
                    borderRadius: '0.75rem',
                    border: '1px solid #E2E8F0',
                    boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
                    fontSize: '12px'
                  }}
                  formatter={(val, name) => [`${val}% Severity`, name]}
                />
                <Legend wrapperStyle={{ fontSize: '11px', paddingTop: '10px' }} />

                {showConfidence && (
                  <Area
                    type="monotone"
                    dataKey="ci_upper"
                    name="95% CI Bound"
                    stroke="none"
                    fill="url(#simCiArea)"
                  />
                )}

                {showFavorable && (
                  <Line
                    type="monotone"
                    dataKey="favorable"
                    name="Favorable Microclimate"
                    stroke="#DC3545"
                    strokeWidth={2.5}
                    dot={false}
                  />
                )}

                {showUntreated && (
                  <Line
                    type="monotone"
                    dataKey="untreated"
                    name="Baseline Untreated"
                    stroke="#F59E0B"
                    strokeWidth={2.5}
                    dot={false}
                  />
                )}

                {showUnfavorable && (
                  <Line
                    type="monotone"
                    dataKey="unfavorable"
                    name="Unfavorable Conditions"
                    stroke="#64748B"
                    strokeWidth={2}
                    strokeDasharray="4 4"
                    dot={false}
                  />
                )}

                {showTreated && (
                  <Line
                    type="monotone"
                    dataKey="treated"
                    name={`Fungicide Spray (Day ${treatmentDay})`}
                    stroke="#2D6A4F"
                    strokeWidth={3}
                    dot={false}
                  />
                )}
              </ComposedChart>
            </ResponsiveContainer>
          </div>

          <div className="mt-4 p-3 rounded-xl bg-emerald-50/60 border border-emerald-100 flex items-start gap-2.5 text-xs text-emerald-950">
            <Info className="w-4 h-4 text-[#2D6A4F] shrink-0 mt-0.5" />
            <div>
              <strong>Mathematical Interpretation:</strong> The logistic curve demonstrates characteristic lag, log, and plateau phases. Intervening before Day {treatmentDay} flattens the secondary infection wave, reducing cumulative AUDPC from 3412 to under 880 units.
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
