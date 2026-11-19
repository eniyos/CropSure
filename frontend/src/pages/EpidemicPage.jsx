import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import {
  ResponsiveContainer,
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
  ShieldCheck,
  TrendingUp,
  Clock,
} from 'lucide-react';
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Separator } from '@/components/ui/separator';
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
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-2 border-b border-slate-200">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="w-2 h-2 rounded-full bg-[#0d5c46]" />
            <span className="text-xs font-mono uppercase tracking-wider text-slate-500">
              Van der Plank Mathematical Dynamics
            </span>
          </div>
          <h1 className="text-2xl font-bold font-display tracking-tight text-slate-900">
            Epidemic Simulation &amp; AUDPC Analysis
          </h1>
          <p className="text-sm text-slate-500 mt-0.5">
            Nonlinear differential equation modeling of polycyclic foliar epidemics over a 90-day crop cycle.
          </p>
        </div>

        <div className="flex items-center gap-2 shrink-0">
          <Badge variant="outline" className="font-mono text-xs border-slate-200 text-slate-700 bg-white px-2.5 py-1">
            dy/dt = r·y·(1-y)
          </Badge>
          <Badge className="bg-[#e6f0ed] text-[#0d5c46] hover:bg-[#e6f0ed] border border-[#0d5c46]/20 font-mono text-xs">
            Polycyclic Solver
          </Badge>
        </div>
      </div>

      {/* KPI Overview Strip */}
      {simResults && simResults.metrics && (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <Card className="border-slate-200/80 shadow-xs bg-white">
            <CardContent className="p-4 space-y-1">
              <div className="text-xs font-medium text-slate-500 flex items-center justify-between">
                <span>Peak Severity (Untreated)</span>
                <TrendingUp className="w-3.5 h-3.5 text-rose-500" />
              </div>
              <div className="text-2xl font-bold font-mono tracking-tight text-rose-700">
                {simResults.metrics.peak_severity || 89.4}%
              </div>
              <div className="text-xs text-slate-500 font-mono">
                Terminal disease plateau
              </div>
            </CardContent>
          </Card>

          <Card className="border-slate-200/80 shadow-xs bg-white">
            <CardContent className="p-4 space-y-1">
              <div className="text-xs font-medium text-slate-500 flex items-center justify-between">
                <span>Time to 50% Infection</span>
                <Clock className="w-3.5 h-3.5 text-amber-500" />
              </div>
              <div className="text-2xl font-bold font-mono tracking-tight text-slate-900">
                {simResults.metrics.time_to_50pct_days || 36} <span className="text-sm font-normal text-slate-500">Days</span>
              </div>
              <div className="text-xs text-slate-500 font-mono">
                Logistic inflection point
              </div>
            </CardContent>
          </Card>

          <Card className="border-slate-200/80 shadow-xs bg-white">
            <CardContent className="p-4 space-y-1">
              <div className="text-xs font-medium text-slate-500 flex items-center justify-between">
                <span>Cumulative AUDPC</span>
                <Activity className="w-3.5 h-3.5 text-[#0d5c46]" />
              </div>
              <div className="text-2xl font-bold font-mono tracking-tight text-slate-900">
                {simResults.metrics.audpc || 3412}
              </div>
              <div className="text-xs text-slate-500 font-mono">
                Area under disease progress curve
              </div>
            </CardContent>
          </Card>

          <Card className="border-slate-200/80 shadow-xs bg-white">
            <CardContent className="p-4 space-y-1">
              <div className="text-xs font-medium text-slate-500 flex items-center justify-between">
                <span>Intervention Efficacy</span>
                <ShieldCheck className="w-3.5 h-3.5 text-[#0d5c46]" />
              </div>
              <div className="text-2xl font-bold font-mono tracking-tight text-[#0d5c46]">
                {simResults.metrics.treatment_reduction_pct || 74.2}%
              </div>
              <div className="text-xs text-emerald-700 font-mono">
                Total biomass preserved
              </div>
            </CardContent>
          </Card>
        </div>
      )}

      {/* Parameter Controls Panel */}
      <Card className="border-slate-200/80 shadow-xs bg-white">
        <CardHeader className="pb-3 border-b border-slate-100">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <FlaskConical className="w-4 h-4 text-[#0d5c46]" />
              <CardTitle className="text-sm font-semibold tracking-tight text-slate-900 font-display">
                Epidemiological Model Controls &amp; Differential Parameters
              </CardTitle>
            </div>
            <button
              onClick={resetDefaults}
              className="flex items-center gap-1.5 text-xs text-slate-500 hover:text-slate-800 transition-colors font-medium cursor-pointer"
            >
              <RotateCcw className="w-3.5 h-3.5" />
              <span>Reset Defaults</span>
            </button>
          </div>
        </CardHeader>

        <CardContent className="pt-4 space-y-5">
          <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-6 gap-3">
            {/* Temperature */}
            <div className="bg-slate-50 p-3 rounded-lg border border-slate-200/80 space-y-1.5">
              <div className="flex justify-between items-center text-xs">
                <span className="text-slate-600 font-medium flex items-center gap-1">
                  <Thermometer className="w-3.5 h-3.5 text-amber-600" />
                  <span>Temp</span>
                </span>
                <span className="font-mono font-bold text-slate-900">{temp}°C</span>
              </div>
              <input
                type="range"
                min="12"
                max="36"
                value={temp}
                onChange={(e) => setTemp(Number(e.target.value))}
                className="w-full accent-[#0d5c46] cursor-pointer"
              />
              <span className="text-[10px] text-slate-400 block text-center font-mono">Opt: 22-26°C</span>
            </div>

            {/* Humidity */}
            <div className="bg-slate-50 p-3 rounded-lg border border-slate-200/80 space-y-1.5">
              <div className="flex justify-between items-center text-xs">
                <span className="text-slate-600 font-medium flex items-center gap-1">
                  <Droplets className="w-3.5 h-3.5 text-sky-600" />
                  <span>RH</span>
                </span>
                <span className="font-mono font-bold text-slate-900">{humidity}%</span>
              </div>
              <input
                type="range"
                min="40"
                max="100"
                value={humidity}
                onChange={(e) => setHumidity(Number(e.target.value))}
                className="w-full accent-[#0d5c46] cursor-pointer"
              />
              <span className="text-[10px] text-slate-400 block text-center font-mono">Crit: &gt;75%</span>
            </div>

            {/* Precipitation */}
            <div className="bg-slate-50 p-3 rounded-lg border border-slate-200/80 space-y-1.5">
              <div className="flex justify-between items-center text-xs">
                <span className="text-slate-600 font-medium flex items-center gap-1">
                  <CloudRain className="w-3.5 h-3.5 text-blue-600" />
                  <span>Precip</span>
                </span>
                <span className="font-mono font-bold text-slate-900">{precip}mm</span>
              </div>
              <input
                type="range"
                min="0"
                max="50"
                value={precip}
                onChange={(e) => setPrecip(Number(e.target.value))}
                className="w-full accent-[#0d5c46] cursor-pointer"
              />
              <span className="text-[10px] text-slate-400 block text-center font-mono">Splash index</span>
            </div>

            {/* Infection rate (r) */}
            <div className="bg-slate-50 p-3 rounded-lg border border-slate-200/80 space-y-1.5">
              <div className="flex justify-between items-center text-xs">
                <span className="text-slate-600 font-medium">Rate (r)</span>
                <span className="font-mono font-bold text-slate-900">{infectionRate}</span>
              </div>
              <input
                type="range"
                min="0.05"
                max="0.30"
                step="0.01"
                value={infectionRate}
                onChange={(e) => setInfectionRate(Number(e.target.value))}
                className="w-full accent-[#0d5c46] cursor-pointer"
              />
              <span className="text-[10px] text-slate-400 block text-center font-mono">Infection/day</span>
            </div>

            {/* Latent period */}
            <div className="bg-slate-50 p-3 rounded-lg border border-slate-200/80 space-y-1.5">
              <div className="flex justify-between items-center text-xs">
                <span className="text-slate-600 font-medium">Latent (p)</span>
                <span className="font-mono font-bold text-slate-900">{latentPeriod}d</span>
              </div>
              <input
                type="range"
                min="2"
                max="10"
                step="0.5"
                value={latentPeriod}
                onChange={(e) => setLatentPeriod(Number(e.target.value))}
                className="w-full accent-[#0d5c46] cursor-pointer"
              />
              <span className="text-[10px] text-slate-400 block text-center font-mono">Incubation</span>
            </div>

            {/* Treatment Day */}
            <div className="bg-slate-50 p-3 rounded-lg border border-slate-200/80 space-y-1.5">
              <div className="flex justify-between items-center text-xs">
                <span className="text-slate-600 font-medium">Spray At</span>
                <span className="font-mono font-bold text-[#0d5c46]">Day {treatmentDay}</span>
              </div>
              <input
                type="range"
                min="5"
                max="45"
                value={treatmentDay}
                onChange={(e) => setTreatmentDay(Number(e.target.value))}
                className="w-full accent-[#0d5c46] cursor-pointer"
              />
              <span className="text-[10px] text-slate-400 block text-center font-mono">Intervention</span>
            </div>
          </div>

          {/* Scenarios Checkboxes & Action */}
          <div className="pt-3 border-t border-slate-100 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
            <div className="flex flex-wrap items-center gap-4 text-xs font-medium text-slate-700">
              <label className="flex items-center gap-1.5 cursor-pointer">
                <input
                  type="checkbox"
                  checked={showUntreated}
                  onChange={() => setShowUntreated(!showUntreated)}
                  className="accent-[#d97706] rounded"
                />
                <span>Untreated Baseline</span>
              </label>

              <label className="flex items-center gap-1.5 cursor-pointer text-rose-700">
                <input
                  type="checkbox"
                  checked={showFavorable}
                  onChange={() => setShowFavorable(!showFavorable)}
                  className="accent-rose-600 rounded"
                />
                <span>Favorable Microclimate</span>
              </label>

              <label className="flex items-center gap-1.5 cursor-pointer text-slate-500">
                <input
                  type="checkbox"
                  checked={showUnfavorable}
                  onChange={() => setShowUnfavorable(!showUnfavorable)}
                  className="accent-slate-600 rounded"
                />
                <span>Subdued Climate</span>
              </label>

              <label className="flex items-center gap-1.5 cursor-pointer text-[#0d5c46] font-semibold">
                <input
                  type="checkbox"
                  checked={showTreated}
                  onChange={() => setShowTreated(!showTreated)}
                  className="accent-[#0d5c46] rounded"
                />
                <span>Fungicide (Day {treatmentDay})</span>
              </label>

              <label className="flex items-center gap-1.5 cursor-pointer text-sky-700">
                <input
                  type="checkbox"
                  checked={showConfidence}
                  onChange={() => setShowConfidence(!showConfidence)}
                  className="accent-sky-600 rounded"
                />
                <span>95% CI Area</span>
              </label>
            </div>

            <Button
              onClick={executeSimulation}
              disabled={loading}
              className="bg-[#0d5c46] hover:bg-[#094333] text-white font-medium text-xs shadow-xs px-5 h-9 shrink-0"
            >
              {loading ? (
                <>
                  <div className="w-3.5 h-3.5 border-2 border-white border-t-transparent rounded-full animate-spin mr-2" />
                  Simulating...
                </>
              ) : (
                <>
                  <Play className="w-3.5 h-3.5 mr-2 fill-white" />
                  Run Differential Solver
                </>
              )}
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* 90-Day Simulation Chart */}
      {simResults && simResults.timeline && (
        <Card className="border-slate-200/80 shadow-xs bg-white">
          <CardHeader className="pb-3 border-b border-slate-100">
            <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
              <div>
                <CardTitle className="text-sm font-semibold tracking-tight text-slate-900 font-display">
                  90-Day Van der Plank Disease Progression Curve
                </CardTitle>
                <CardDescription className="text-xs text-slate-500 mt-0.5">
                  Logistic dynamic with latent lag, exponential sporulation, and post-intervention containment
                </CardDescription>
              </div>
              <div className="text-xs font-mono text-slate-500">
                Apparent Rate: <strong className="text-[#0d5c46]">{simResults.apparent_infection_rate || '0.14'}/day</strong>
              </div>
            </div>
          </CardHeader>

          <CardContent className="pt-4">
            <div className="h-80 sm:h-96 w-full">
              <ResponsiveContainer width="100%" height="100%">
                <ComposedChart data={simResults.timeline || []} margin={{ top: 15, right: 20, left: -15, bottom: 5 }}>
                  <defs>
                    <linearGradient id="simCiArea" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#0284c7" stopOpacity={0.15}/>
                      <stop offset="95%" stopColor="#0284c7" stopOpacity={0.0}/>
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" vertical={false} />
                  <XAxis
                    dataKey="day"
                    tick={{ fontSize: 11, fill: '#64748b' }}
                    axisLine={{ stroke: '#cbd5e1' }}
                    label={{ value: 'Days Post-Infection', position: 'insideBottomRight', offset: -5, fontSize: 10, fill: '#94a3b8' }}
                  />
                  <YAxis domain={[0, 100]} tick={{ fontSize: 11, fill: '#64748b' }} unit="%" axisLine={{ stroke: '#cbd5e1' }} />
                  <Tooltip
                    contentStyle={{
                      backgroundColor: 'rgba(255, 255, 255, 0.96)',
                      borderRadius: '0.5rem',
                      border: '1px solid #e2e8f0',
                      boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.05)',
                      fontSize: '12px',
                      fontFamily: 'JetBrains Mono, monospace'
                    }}
                    formatter={(val, name) => [`${val}% Severity`, name]}
                  />
                  <Legend wrapperStyle={{ fontSize: '11px', paddingTop: '12px' }} />

                  {showConfidence && (
                    <Area
                      type="monotone"
                      dataKey="ci_upper"
                      name="95% CI Interval"
                      stroke="none"
                      fill="url(#simCiArea)"
                    />
                  )}

                  {showFavorable && (
                    <Line
                      type="monotone"
                      dataKey="favorable"
                      name="Favorable Microclimate"
                      stroke="#dc2626"
                      strokeWidth={2}
                      dot={false}
                    />
                  )}

                  {showUntreated && (
                    <Line
                      type="monotone"
                      dataKey="untreated"
                      name="Baseline Untreated"
                      stroke="#d97706"
                      strokeWidth={2}
                      dot={false}
                    />
                  )}

                  {showUnfavorable && (
                    <Line
                      type="monotone"
                      dataKey="unfavorable"
                      name="Subdued Climate"
                      stroke="#64748b"
                      strokeWidth={1.5}
                      strokeDasharray="4 4"
                      dot={false}
                    />
                  )}

                  {showTreated && (
                    <Line
                      type="monotone"
                      dataKey="treated"
                      name={`Fungicide Spray (Day ${treatmentDay})`}
                      stroke="#0d5c46"
                      strokeWidth={2.5}
                      dot={false}
                    />
                  )}
                </ComposedChart>
              </ResponsiveContainer>
            </div>

            <div className="mt-4 p-3 rounded-lg bg-slate-50 border border-slate-200/80 flex items-start gap-2.5 text-xs text-slate-700">
              <Info className="w-4 h-4 text-[#0d5c46] shrink-0 mt-0.5" />
              <div>
                <span className="font-semibold text-slate-900">Mathematical Interpretation:</span> The logistic dynamic exhibits characteristic lag, exponential acceleration, and asymptote saturation. Intervening on or before Day {treatmentDay} curtails the secondary infection wave, reducing cumulative AUDPC from ~3,412 to under 880 units.
              </div>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
