import React from 'react';
import { Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import {
  PieChart,
  Pie,
  Cell,
  ResponsiveContainer,
  Tooltip,
  Legend
} from 'recharts';
import {
  Cpu,
  ScanSearch,
  Activity,
  ShieldCheck,
  TrendingUp,
  FlaskConical,
  LineChart,
  ArrowRight,
  Clock,
  Sparkles,
  AlertTriangle,
  Leaf,
  CheckCircle2
} from 'lucide-react';
import StatCard from '../components/ui/StatCard';
import StatusBadge from '../components/ui/StatusBadge';

// 8 Tomato Disease Classes + Healthy
const DISEASE_DISTRIBUTION = [
  { name: 'Early Blight', value: 28, color: '#D4A843' },
  { name: 'Late Blight', value: 22, color: '#DC3545' },
  { name: 'Bacterial Spot', value: 16, color: '#F59E0B' },
  { name: 'Septoria Spot', value: 12, color: '#2D6A4F' },
  { name: 'Leaf Mold', value: 8, color: '#40916C' },
  { name: 'Yellow Leaf Curl', value: 6, color: '#EA580C' },
  { name: 'Mosaic Virus', value: 4, color: '#8B5CF6' },
  { name: 'Healthy', value: 4, color: '#52B788' }
];

const RECENT_ANALYSES = [
  {
    id: 'CS-8921',
    sample: 'Field 4B - Greenhouse 2',
    disease: 'Tomato Early Blight',
    severity: '42.5%',
    confidence: '94.2%',
    status: 'warning',
    time: '12 minutes ago'
  },
  {
    id: 'CS-8920',
    sample: 'Zone 1 - Hydroponics Rack',
    disease: 'Tomato Late Blight',
    severity: '68.0%',
    confidence: '91.5%',
    status: 'error',
    time: '45 minutes ago'
  },
  {
    id: 'CS-8919',
    sample: 'Field 2A - Open Canopy',
    disease: 'Healthy Foliage',
    severity: '0.0%',
    confidence: '98.5%',
    status: 'success',
    time: '2 hours ago'
  },
  {
    id: 'CS-8918',
    sample: 'Field 3C - Perimeter Row',
    disease: 'Bacterial Spot',
    severity: '31.0%',
    confidence: '88.7%',
    status: 'warning',
    time: '3 hours ago'
  }
];

const MODEL_HEALTH = [
  { name: 'EfficientNet-B4 Classifier', status: 'online', latency: '42ms', accuracy: '98.4%' },
  { name: 'Grad-CAM Saliency Engine', status: 'online', latency: '68ms', accuracy: '94.8% IoU' },
  { name: 'Van der Plank ODE Simulator', status: 'online', latency: '15ms', accuracy: 'R² 0.93' },
  { name: 'LSTM Microclimate Forecaster', status: 'online', latency: '34ms', accuracy: 'MAE 2.1%' },
  { name: 'Yield Loss Estimator', status: 'online', latency: '12ms', accuracy: 'RMSE 1.8%' },
  { name: 'Multi-Evidence Trust Evaluator', status: 'online', latency: '22ms', accuracy: 'ECE 0.024' }
];

export default function Dashboard() {
  return (
    <div className="space-y-6">
      {/* Welcome Hero Banner */}
      <motion.div
        initial={{ opacity: 0, y: 15 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        className="rounded-2xl bg-gradient-to-r from-[#1B4332] via-[#2D6A4F] to-[#1B4332] text-white p-6 sm:p-8 shadow-md relative overflow-hidden"
      >
        {/* Decorative background glow & shapes */}
        <div className="absolute top-0 right-0 w-80 h-80 bg-[#52B788]/10 rounded-full blur-3xl pointer-events-none" />
        <div className="absolute -bottom-10 right-20 w-48 h-48 bg-[#D4A843]/15 rounded-full blur-2xl pointer-events-none" />

        <div className="relative z-10 max-w-3xl">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-white/10 backdrop-blur-md text-[#D4A843] text-xs font-semibold mb-3 border border-white/10">
            <Sparkles className="w-3.5 h-3.5" />
            <span>AI Multi-Spectral Diagnostic Framework Active</span>
          </div>

          <h2 className="text-2xl sm:text-3xl font-extrabold tracking-tight text-white mb-2">
            Welcome to CropSure Intelligence
          </h2>
          <p className="text-sm sm:text-base text-gray-200 leading-relaxed max-w-2xl">
            Autonomous foliar disease classification, pixel-level Grad-CAM explainability, and Van der Plank epidemiological disease forecasting across tomato cropping cycles.
          </p>

          <div className="mt-5 flex flex-wrap gap-3">
            <Link
              to="/analyze"
              className="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-[#D4A843] hover:bg-[#C9952B] text-gray-950 font-bold text-xs uppercase tracking-wider transition-all duration-150 shadow-md hover:shadow-lg hover:scale-102"
            >
              <ScanSearch className="w-4 h-4" />
              <span>Launch Disease Analysis</span>
            </Link>

            <Link
              to="/epidemic"
              className="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-white/10 hover:bg-white/20 text-white font-semibold text-xs tracking-wide backdrop-blur-md transition-all border border-white/20"
            >
              <FlaskConical className="w-4 h-4 text-[#74C69D]" />
              <span>Run Epidemic Simulation</span>
            </Link>
          </div>
        </div>
      </motion.div>

      {/* Stats Cards Row */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          icon={Cpu}
          label="Models Loaded"
          value="6 / 6"
          subvalue="Fully Operational"
          trend={{ direction: 'neutral', value: 'Zero downtime', positive: true }}
          delay={0.1}
        />
        <StatCard
          icon={Activity}
          label="Analyses Run"
          value="14,820"
          subvalue="This Season"
          trend={{ direction: 'up', value: '+18.4% vs last cycle', positive: true }}
          delay={0.2}
        />
        <StatCard
          icon={ShieldCheck}
          label="Model Accuracy"
          value="96.8%"
          subvalue="mAP@50 93.8% (Avg Conf 94.6%)"
          trend={{ direction: 'up', value: 'High Benchmark Accuracy', positive: true }}
          delay={0.3}
        />
        <StatCard
          icon={Leaf}
          label="System Status"
          value="Online"
          subvalue="Telemetry Synced"
          badge="Healthy"
          trend={{ direction: 'neutral', value: 'All 4 workers idle-ready', positive: true }}
          delay={0.4}
        />
      </div>

      {/* Main Grid: Disease Distribution + Recent Activity */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Disease Distribution Chart */}
        <div className="lg:col-span-2 bg-white rounded-2xl p-6 border border-gray-100 shadow-sm flex flex-col justify-between">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h3 className="text-base font-bold text-gray-900 tracking-tight">
                Disease Distribution Frequency
              </h3>
              <p className="text-xs text-gray-500">
                Aggregated detections across monitored tomato cultivars (Demo Data)
              </p>
            </div>
            <span className="px-2.5 py-1 text-[11px] font-semibold rounded-full bg-emerald-50 text-[#2D6A4F] border border-emerald-100">
              8 Classes
            </span>
          </div>

          <div className="h-64 sm:h-72 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={DISEASE_DISTRIBUTION}
                  cx="50%"
                  cy="50%"
                  innerRadius={60}
                  outerRadius={95}
                  paddingAngle={3}
                  dataKey="value"
                >
                  {DISEASE_DISTRIBUTION.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip
                  formatter={(value, name) => [`${value}% of total diagnoses`, name]}
                  contentStyle={{
                    backgroundColor: 'rgba(255, 255, 255, 0.95)',
                    borderRadius: '0.75rem',
                    border: '1px solid #E2E8F0',
                    boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
                    fontSize: '12px'
                  }}
                />
                <Legend
                  verticalAlign="bottom"
                  height={48}
                  iconType="circle"
                  wrapperStyle={{ fontSize: '11px', paddingTop: '10px' }}
                />
              </PieChart>
            </ResponsiveContainer>
          </div>

          <div className="mt-4 pt-3 border-t border-gray-100 flex items-center justify-between text-xs text-gray-500">
            <span>Primary Threat: <strong className="text-gray-800">Early & Late Blight (50% combined)</strong></span>
            <Link to="/forecast" className="text-[#2D6A4F] hover:underline font-semibold flex items-center gap-1">
              <span>View Forecast</span>
              <ArrowRight className="w-3.5 h-3.5" />
            </Link>
          </div>
        </div>

        {/* Quick Actions Grid */}
        <div className="space-y-3 flex flex-col justify-between">
          <div className="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
            <h3 className="text-sm font-bold text-gray-900 uppercase tracking-wider mb-3">
              Quick Diagnostic Actions
            </h3>
            <div className="grid grid-cols-2 gap-2.5">
              <Link
                to="/analyze"
                className="p-3.5 rounded-xl border border-gray-100 bg-[#FAFAF5] hover:bg-emerald-50/50 hover:border-[#2D6A4F]/40 transition-all text-left group"
              >
                <div className="w-8 h-8 rounded-lg bg-[#2D6A4F]/10 flex items-center justify-center text-[#2D6A4F] mb-2 group-hover:bg-[#2D6A4F] group-hover:text-white transition-colors">
                  <ScanSearch className="w-4 h-4" />
                </div>
                <div className="font-bold text-xs text-gray-900 group-hover:text-[#2D6A4F]">
                  Analyze Leaf
                </div>
                <div className="text-[10px] text-gray-500 mt-0.5">
                  Deep CNN + Grad-CAM
                </div>
              </Link>

              <Link
                to="/forecast"
                className="p-3.5 rounded-xl border border-gray-100 bg-[#FAFAF5] hover:bg-emerald-50/50 hover:border-[#2D6A4F]/40 transition-all text-left group"
              >
                <div className="w-8 h-8 rounded-lg bg-[#D4A843]/15 flex items-center justify-center text-[#C9952B] mb-2 group-hover:bg-[#D4A843] group-hover:text-gray-950 transition-colors">
                  <LineChart className="w-4 h-4" />
                </div>
                <div className="font-bold text-xs text-gray-900 group-hover:text-[#2D6A4F]">
                  View Forecast
                </div>
                <div className="text-[10px] text-gray-500 mt-0.5">
                  7, 14, 30-day projection
                </div>
              </Link>

              <Link
                to="/epidemic"
                className="p-3.5 rounded-xl border border-gray-100 bg-[#FAFAF5] hover:bg-emerald-50/50 hover:border-[#2D6A4F]/40 transition-all text-left group"
              >
                <div className="w-8 h-8 rounded-lg bg-emerald-100 flex items-center justify-center text-emerald-800 mb-2 group-hover:bg-emerald-700 group-hover:text-white transition-colors">
                  <FlaskConical className="w-4 h-4" />
                </div>
                <div className="font-bold text-xs text-gray-900 group-hover:text-[#2D6A4F]">
                  Run Simulation
                </div>
                <div className="text-[10px] text-gray-500 mt-0.5">
                  Van der Plank model
                </div>
              </Link>

              <Link
                to="/models"
                className="p-3.5 rounded-xl border border-gray-100 bg-[#FAFAF5] hover:bg-emerald-50/50 hover:border-[#2D6A4F]/40 transition-all text-left group"
              >
                <div className="w-8 h-8 rounded-lg bg-sky-100 flex items-center justify-center text-sky-800 mb-2 group-hover:bg-sky-700 group-hover:text-white transition-colors">
                  <Cpu className="w-4 h-4" />
                </div>
                <div className="font-bold text-xs text-gray-900 group-hover:text-[#2D6A4F]">
                  Model Status
                </div>
                <div className="text-[10px] text-gray-500 mt-0.5">
                  Registry & telemetry
                </div>
              </Link>
            </div>
          </div>

          {/* Microclimate telemetry quick look */}
          <div className="bg-white rounded-2xl p-4 border border-gray-100 shadow-sm">
            <div className="flex items-center justify-between text-xs mb-2">
              <span className="font-bold text-gray-800">Station Microclimate</span>
              <span className="text-[10px] text-gray-500">Live Telemetry</span>
            </div>
            <div className="grid grid-cols-3 gap-2 text-center text-xs">
              <div className="bg-[#FAFAF5] p-2 rounded-xl border border-gray-100">
                <span className="text-[10px] text-gray-500 block">Temp</span>
                <span className="font-extrabold text-gray-900">23.8 °C</span>
              </div>
              <div className="bg-[#FAFAF5] p-2 rounded-xl border border-gray-100">
                <span className="text-[10px] text-gray-500 block">RH</span>
                <span className="font-extrabold text-[#2D6A4F]">84%</span>
              </div>
              <div className="bg-[#FAFAF5] p-2 rounded-xl border border-gray-100">
                <span className="text-[10px] text-gray-500 block">Leaf Wet</span>
                <span className="font-extrabold text-amber-600">6.2 hrs</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Bottom Row: Recent Activity & System Health */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent Activity Timeline */}
        <div className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h3 className="text-base font-bold text-gray-900 tracking-tight">
                Recent Diagnostic Activity
              </h3>
              <p className="text-xs text-gray-500">Latest automated and manual leaf scans</p>
            </div>
            <Clock className="w-4 h-4 text-gray-400" />
          </div>

          <div className="divide-y divide-gray-100">
            {RECENT_ANALYSES.map((item) => (
              <div key={item.id} className="py-3.5 flex items-center justify-between text-xs hover:bg-[#FAFAF5] px-2 rounded-xl transition-colors">
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded-lg bg-emerald-50 border border-emerald-100 flex items-center justify-center text-[#2D6A4F] font-mono text-[10px] font-bold">
                    {item.id.replace('CS-', '')}
                  </div>
                  <div>
                    <h5 className="font-semibold text-gray-900">{item.disease}</h5>
                    <p className="text-gray-400 text-[11px]">{item.sample}</p>
                  </div>
                </div>

                <div className="flex items-center gap-3 text-right">
                  <div className="hidden sm:block">
                    <span className="font-mono text-gray-700 block font-semibold">{item.severity} Sev</span>
                    <span className="text-gray-400 text-[10px]">{item.time}</span>
                  </div>
                  <StatusBadge
                    status={item.status}
                    label={item.confidence}
                    size="sm"
                  />
                </div>
              </div>
            ))}
          </div>

          <div className="mt-4 pt-3 border-t border-gray-100 text-center">
            <Link to="/analyze" className="text-xs text-[#2D6A4F] hover:underline font-semibold">
              Analyze a New Leaf Sample &rarr;
            </Link>
          </div>
        </div>

        {/* System Health Panel */}
        <div className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h3 className="text-base font-bold text-gray-900 tracking-tight">
                Model Pipeline Health
              </h3>
              <p className="text-xs text-gray-500">Inference engines and runtime metrics</p>
            </div>
            <StatusBadge status="success" label="All 6 Ready" pulse size="sm" />
          </div>

          <div className="space-y-2.5">
            {MODEL_HEALTH.map((model, idx) => (
              <div
                key={idx}
                className="p-2.5 rounded-xl bg-[#FAFAF5] border border-gray-100 flex items-center justify-between text-xs"
              >
                <div className="flex items-center gap-2.5">
                  <div className="w-2 h-2 rounded-full bg-emerald-500" />
                  <span className="font-semibold text-gray-800">{model.name}</span>
                </div>
                <div className="flex items-center gap-3 font-mono text-[11px]">
                  <span className="text-gray-500">{model.latency}</span>
                  <span className="text-emerald-700 font-bold bg-emerald-100/60 px-2 py-0.5 rounded">
                    {model.accuracy}
                  </span>
                </div>
              </div>
            ))}
          </div>

          <div className="mt-4 pt-3 border-t border-gray-100 flex items-center justify-between text-xs text-gray-500">
            <span>Cluster: <strong className="text-gray-800">PyTorch GPU Active</strong></span>
            <Link to="/models" className="text-[#2D6A4F] hover:underline font-semibold">
              View Detailed Specs &rarr;
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
