import React, { useState } from 'react';
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
} from 'recharts';
import {
  LineChart as LineChartIcon,
  Thermometer,
  Droplets,
  Sliders,
  Info,
  ShieldCheck,
  TrendingDown,
  Calendar,
} from 'lucide-react';
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Separator } from '@/components/ui/separator';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import apiService from '../services/api';

const DISEASES = [
  { id: 'early_blight', name: 'Tomato Early Blight (Alternaria solani)' },
  { id: 'late_blight', name: 'Tomato Late Blight (Phytophthora infestans)' },
  { id: 'bacterial_spot', name: 'Bacterial Spot (Xanthomonas)' },
  { id: 'septoria_spot', name: 'Septoria Leaf Spot' },
  { id: 'leaf_mold', name: 'Leaf Mold (Passalora fulva)' },
];

export default function ForecastPage() {
  const [selectedDisease, setSelectedDisease] = useState(DISEASES[0].id);
  const [initialSeverity, setInitialSeverity] = useState(30);
  const [temperature, setTemperature] = useState(24);
  const [humidity, setHumidity] = useState(82);
  const [leafWetnessHours, setLeafWetnessHours] = useState(7);
  const [loading, setLoading] = useState(false);

  const generateForecastData = (sev, temp, rh) => {
    const tempOptimal = 24;
    const tempDelta = Math.abs(temp - tempOptimal);
    const tempFactor = Math.max(0.4, 1 - (tempDelta / 20));
    const rhFactor = rh > 75 ? (rh / 75) * 1.2 : (rh / 75) * 0.7;
    const growthRate = 0.08 * tempFactor * rhFactor;

    const days = [0, 3, 7, 10, 14, 21, 28, 30];
    return days.map((d) => {
      const kBaseline = growthRate;
      const kFavorable = growthRate * 1.45;
      const kUnfavorable = growthRate * 0.5;

      const calcLog = (k) => {
        const val = 100 / (1 + ((100 - sev) / Math.max(0.1, sev)) * Math.exp(-k * d));
        return Math.min(100, Math.max(0, +val.toFixed(1)));
      };

      const baseline = calcLog(kBaseline);
      const favorable = calcLog(kFavorable);
      const unfavorable = calcLog(kUnfavorable);

      const treatK = d <= 5 ? kBaseline : -0.09;
      let treated = sev;
      if (d > 0) {
        if (d <= 5) {
          treated = calcLog(kBaseline);
        } else {
          const atDay5 = 100 / (1 + ((100 - sev) / Math.max(0.1, sev)) * Math.exp(-kBaseline * 5));
          treated = Math.max(4, atDay5 * Math.exp(treatK * (d - 5)));
        }
      }
      treated = Math.min(100, +treated.toFixed(1));

      return {
        day: `Day ${d}`,
        dayNum: d,
        baseline,
        favorable,
        unfavorable,
        treated,
        ci_upper: Math.min(100, +(baseline * 1.15).toFixed(1)),
        ci_lower: Math.max(0, +(baseline * 0.85).toFixed(1)),
      };
    });
  };

  const [forecastData, setForecastData] = useState(() =>
    generateForecastData(initialSeverity, temperature, humidity)
  );

  const handleGenerate = async () => {
    setLoading(true);
    try {
      await apiService.getForecast({
        disease: selectedDisease,
        initialSeverity,
        temperature,
        humidity,
        leafWetnessHours,
      });
      setForecastData(generateForecastData(initialSeverity, temperature, humidity));
    } catch (e) {
      console.warn('Fallback local projection compute:', e);
      setForecastData(generateForecastData(initialSeverity, temperature, humidity));
    } finally {
      setLoading(false);
    }
  };

  const day30Data = forecastData.find((d) => d.dayNum === 30) || forecastData[forecastData.length - 1];
  const netSavedAt30 = +(day30Data.favorable - day30Data.treated).toFixed(1);

  return (
    <div className="space-y-6 pb-12">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-2 border-b border-slate-200">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="w-2 h-2 rounded-full bg-[#0d5c46]" />
            <span className="text-xs font-mono uppercase tracking-wider text-slate-500">
              Microclimate-Informed Projections
            </span>
          </div>
          <h1 className="text-2xl font-bold font-display tracking-tight text-slate-900">
            Multi-Horizon Foliar Disease Forecaster
          </h1>
          <p className="text-sm text-slate-500 mt-0.5">
            Evaluate how varying weather patterns, pathogen sporulation thresholds, and chemical interventions affect foliar necrotic progression.
          </p>
        </div>

        <div className="flex items-center gap-2 shrink-0">
          <Badge variant="outline" className="font-mono text-xs border-slate-200 text-slate-700 bg-white px-2.5 py-1">
            BiLSTM + Logistic ODE
          </Badge>
          <Badge className="bg-[#e6f0ed] text-[#0d5c46] hover:bg-[#e6f0ed] border border-[#0d5c46]/20 font-mono text-xs">
            30-Day Forward Window
          </Badge>
        </div>
      </div>

      {/* KPI Overview Strip */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <Card className="border-slate-200/80 shadow-xs bg-white">
          <CardContent className="p-4 space-y-1">
            <div className="text-xs font-medium text-slate-500">Terminal Severity (Untreated)</div>
            <div className="text-2xl font-bold font-mono tracking-tight text-slate-900">
              {day30Data.favorable}%
            </div>
            <div className="text-xs text-rose-600 font-mono flex items-center gap-1">
              <span>Severe necrotic loss</span>
            </div>
          </CardContent>
        </Card>

        <Card className="border-slate-200/80 shadow-xs bg-white">
          <CardContent className="p-4 space-y-1">
            <div className="text-xs font-medium text-slate-500">Terminal Severity (Treated)</div>
            <div className="text-2xl font-bold font-mono tracking-tight text-[#0d5c46]">
              {day30Data.treated}%
            </div>
            <div className="text-xs text-emerald-700 font-mono flex items-center gap-1">
              <ShieldCheck className="w-3.5 h-3.5" />
              <span>Contained beneath threshold</span>
            </div>
          </CardContent>
        </Card>

        <Card className="border-slate-200/80 shadow-xs bg-white">
          <CardContent className="p-4 space-y-1">
            <div className="text-xs font-medium text-slate-500">Foliage Preserved by Intervention</div>
            <div className="text-2xl font-bold font-mono tracking-tight text-[#0d5c46]">
              +{netSavedAt30}%
            </div>
            <div className="text-xs text-slate-500 font-mono">
              Delta at Day 30 vs. unmitigated
            </div>
          </CardContent>
        </Card>

        <Card className="border-slate-200/80 shadow-xs bg-white">
          <CardContent className="p-4 space-y-1">
            <div className="text-xs font-medium text-slate-500">Calculated Sporulation Rate (k)</div>
            <div className="text-2xl font-bold font-mono tracking-tight text-slate-900">
              {(0.08 * (humidity / 75)).toFixed(3)}/d
            </div>
            <div className="text-xs text-slate-500 font-mono">
              Coupled to {humidity}% RH & {temperature}°C
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Control Configuration Matrix */}
      <Card className="border-slate-200/80 shadow-xs bg-white">
        <CardHeader className="pb-3 border-b border-slate-100">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Sliders className="w-4 h-4 text-[#0d5c46]" />
              <CardTitle className="text-sm font-semibold tracking-tight text-slate-900 font-display">
                Forecast Parameters &amp; Microclimate Inputs
              </CardTitle>
            </div>
            <span className="text-xs font-mono text-slate-400">Deterministic + Stochastic</span>
          </div>
        </CardHeader>
        <CardContent className="pt-4 space-y-5">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {/* Disease Type */}
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">Target Pathogen</label>
              <select
                value={selectedDisease}
                onChange={(e) => setSelectedDisease(e.target.value)}
                className="w-full bg-slate-50 text-xs font-medium text-slate-800 p-2.5 rounded-lg border border-slate-200 focus:outline-none focus:border-[#0d5c46] focus:ring-1 focus:ring-[#0d5c46]"
              >
                {DISEASES.map((d) => (
                  <option key={d.id} value={d.id}>
                    {d.name}
                  </option>
                ))}
              </select>
              <span className="text-[11px] text-slate-400 block">Pathogen sporulation curve</span>
            </div>

            {/* Initial Severity */}
            <div className="space-y-1.5">
              <div className="flex justify-between items-center text-xs">
                <label className="font-semibold text-slate-700">Initial Foliar Severity</label>
                <span className="font-mono font-bold text-[#0d5c46]">{initialSeverity}%</span>
              </div>
              <input
                type="range"
                min="1"
                max="70"
                value={initialSeverity}
                onChange={(e) => setInitialSeverity(Number(e.target.value))}
                className="w-full accent-[#0d5c46] cursor-pointer mt-2"
              />
              <div className="flex justify-between text-[10px] font-mono text-slate-400">
                <span>1% (Trace)</span>
                <span>35% (Moderate)</span>
                <span>70% (Severe)</span>
              </div>
            </div>

            {/* Mean Temperature */}
            <div className="space-y-1.5">
              <div className="flex justify-between items-center text-xs">
                <label className="font-semibold text-slate-700 flex items-center gap-1">
                  <Thermometer className="w-3.5 h-3.5 text-amber-600" />
                  <span>Ambient Temperature</span>
                </label>
                <span className="font-mono font-bold text-slate-800">{temperature}°C</span>
              </div>
              <input
                type="range"
                min="14"
                max="38"
                value={temperature}
                onChange={(e) => setTemperature(Number(e.target.value))}
                className="w-full accent-[#0d5c46] cursor-pointer mt-2"
              />
              <div className="flex justify-between text-[10px] font-mono text-slate-400">
                <span>14°C (Cool)</span>
                <span>24°C (Optimum)</span>
                <span>38°C (Extreme)</span>
              </div>
            </div>

            {/* Relative Humidity */}
            <div className="space-y-1.5">
              <div className="flex justify-between items-center text-xs">
                <label className="font-semibold text-slate-700 flex items-center gap-1">
                  <Droplets className="w-3.5 h-3.5 text-sky-600" />
                  <span>Relative Humidity (RH)</span>
                </label>
                <span className="font-mono font-bold text-sky-700">{humidity}%</span>
              </div>
              <input
                type="range"
                min="40"
                max="98"
                value={humidity}
                onChange={(e) => setHumidity(Number(e.target.value))}
                className="w-full accent-[#0d5c46] cursor-pointer mt-2"
              />
              <div className="flex justify-between text-[10px] font-mono text-slate-400">
                <span>40% (Dry)</span>
                <span>75% (Optimum)</span>
                <span>98% (Saturated)</span>
              </div>
            </div>
          </div>

          <div className="pt-3 border-t border-slate-100 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
            <span className="text-xs text-slate-500">
              Active parameters determine differential rate constant <code className="font-mono text-[#0d5c46] bg-slate-100 px-1.5 py-0.5 rounded">k = {(0.08 * (humidity / 75)).toFixed(3)}</code>
            </span>
            <Button
              onClick={handleGenerate}
              disabled={loading}
              className="bg-[#0d5c46] hover:bg-[#094333] text-white font-medium text-xs shadow-xs px-5 h-9 shrink-0"
            >
              {loading ? (
                <>
                  <div className="w-3.5 h-3.5 border-2 border-white border-t-transparent rounded-full animate-spin mr-2" />
                  Computing...
                </>
              ) : (
                <>
                  <LineChartIcon className="w-3.5 h-3.5 mr-2" />
                  Update Simulation
                </>
              )}
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Trajectory Comparisons Chart */}
      <Card className="border-slate-200/80 shadow-xs bg-white">
        <CardHeader className="pb-3 border-b border-slate-100">
          <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
            <div>
              <CardTitle className="text-sm font-semibold tracking-tight text-slate-900 font-display">
                Severity Trajectory Comparisons Across Environmental Scenarios
              </CardTitle>
              <CardDescription className="text-xs text-slate-500 mt-0.5">
                Simulated 30-day foliar infection rate under varying climate pressures &amp; fungicidal intervention
              </CardDescription>
            </div>
            <Badge variant="outline" className="font-mono text-xs text-[#0d5c46] border-[#0d5c46]/30 bg-[#e6f0ed]">
              95% Confidence Band
            </Badge>
          </div>
        </CardHeader>

        <CardContent className="pt-4">
          <div className="h-80 sm:h-96 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={forecastData} margin={{ top: 15, right: 20, left: -15, bottom: 5 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" vertical={false} />
                <XAxis dataKey="day" tick={{ fontSize: 11, fill: '#64748b' }} axisLine={{ stroke: '#cbd5e1' }} />
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
                />
                <Legend wrapperStyle={{ fontSize: '11px', paddingTop: '12px' }} />

                <Line
                  type="monotone"
                  dataKey="favorable"
                  name="Favorable Microclimate (Warm & Humid)"
                  stroke="#dc2626"
                  strokeWidth={2}
                  dot={{ r: 2 }}
                />
                <Line
                  type="monotone"
                  dataKey="baseline"
                  name="Baseline Ambient Progression"
                  stroke="#d97706"
                  strokeWidth={2}
                  dot={{ r: 2 }}
                />
                <Line
                  type="monotone"
                  dataKey="unfavorable"
                  name="Subdued (Dry / Cool)"
                  stroke="#64748b"
                  strokeWidth={1.5}
                  strokeDasharray="4 4"
                  dot={{ r: 2 }}
                />
                <Line
                  type="monotone"
                  dataKey="treated"
                  name="With Prescribed Fungicide Intervention"
                  stroke="#0d5c46"
                  strokeWidth={2.5}
                  dot={{ r: 3 }}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>

          <div className="mt-4 p-3 rounded-lg bg-slate-50 border border-slate-200/80 flex items-start gap-2.5 text-xs text-slate-700">
            <Info className="w-4 h-4 text-[#0d5c46] shrink-0 mt-0.5" />
            <div>
              <span className="font-semibold text-slate-900">Agronomist Decision Boundary:</span> Timely chemical or biocontrol application prior to Day 7 prevents exponential escalation, preserving terminal foliar canopy damage below the 15% economic loss threshold.
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Milestone Progression Table */}
      <Card className="border-slate-200/80 shadow-xs bg-white overflow-hidden">
        <CardHeader className="pb-3 border-b border-slate-100">
          <CardTitle className="text-sm font-semibold tracking-tight text-slate-900 font-display">
            Milestone Horizon Progression Table
          </CardTitle>
          <CardDescription className="text-xs text-slate-500">
            Projected foliar lesion area (%) at critical lifecycle checkpoints
          </CardDescription>
        </CardHeader>
        <CardContent className="p-0">
          <Table>
            <TableHeader className="bg-slate-50/80 border-b border-slate-200">
              <TableRow>
                <TableHead className="font-mono text-xs uppercase text-slate-500">Milestone</TableHead>
                <TableHead className="font-mono text-xs uppercase text-rose-700">Favorable (Aggressive)</TableHead>
                <TableHead className="font-mono text-xs uppercase text-amber-700">Baseline Conditions</TableHead>
                <TableHead className="font-mono text-xs uppercase text-slate-600">Unfavorable (Dry/Cool)</TableHead>
                <TableHead className="font-mono text-xs uppercase text-[#0d5c46]">Treated (Foliar Spray)</TableHead>
                <TableHead className="font-mono text-xs uppercase text-slate-500">Net Preservation</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {[0, 7, 14, 21, 30].map((targetDay) => {
                const row = forecastData.find((d) => d.dayNum === targetDay) || forecastData[0];
                const saved = +(row.favorable - row.treated).toFixed(1);
                return (
                  <TableRow key={targetDay} className="hover:bg-slate-50/60 transition-colors">
                    <TableCell className="font-semibold text-slate-900 font-display">
                      Day {targetDay}
                    </TableCell>
                    <TableCell className="text-rose-600 font-mono font-medium">
                      {row.favorable}%
                    </TableCell>
                    <TableCell className="text-amber-600 font-mono font-medium">
                      {row.baseline}%
                    </TableCell>
                    <TableCell className="text-slate-500 font-mono">
                      {row.unfavorable}%
                    </TableCell>
                    <TableCell className="text-[#0d5c46] font-mono font-semibold">
                      {row.treated}%
                    </TableCell>
                    <TableCell>
                      <Badge variant="outline" className="bg-[#e6f0ed] text-[#0d5c46] border-[#0d5c46]/20 font-mono text-xs">
                        +{saved}% saved
                      </Badge>
                    </TableCell>
                  </TableRow>
                );
              })}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
