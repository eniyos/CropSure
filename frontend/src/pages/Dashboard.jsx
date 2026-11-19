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
  Leaf,
  CheckCircle2,
  ExternalLink,
  Layers,
  Thermometer,
  Droplets,
  CloudSun
} from 'lucide-react';

// Shadcn UI Components
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Separator } from '@/components/ui/separator';

const DISEASE_DISTRIBUTION = [
  { name: 'Early Blight', value: 28, color: '#D97706' },
  { name: 'Late Blight', value: 22, color: '#DC2626' },
  { name: 'Bacterial Spot', value: 16, color: '#EA580C' },
  { name: 'Septoria Spot', value: 12, color: '#1B4332' },
  { name: 'Leaf Mold', value: 8, color: '#2D6A4F' },
  { name: 'Yellow Leaf Curl', value: 6, color: '#B45309' },
  { name: 'Mosaic Virus', value: 4, color: '#7C3AED' },
  { name: 'Healthy Tissue', value: 4, color: '#16A34A' }
];

const RECENT_ANALYSES = [
  {
    id: 'CS-8921',
    sample: 'Greenhouse Block B &bull; Tomato Hybrid F1',
    disease: 'Tomato Early Blight',
    severity: '42.5%',
    confidence: '94.2%',
    status: 'destructive',
    time: '12 min ago'
  },
  {
    id: 'CS-8920',
    sample: 'Hydroponics Bay 1 &bull; Solanum lycopersicum',
    disease: 'Tomato Late Blight',
    severity: '68.0%',
    confidence: '91.5%',
    status: 'destructive',
    time: '45 min ago'
  },
  {
    id: 'CS-8919',
    sample: 'Field 2A &bull; Open Canopy',
    disease: 'Healthy Foliage',
    severity: '0.0%',
    confidence: '98.5%',
    status: 'secondary',
    time: '2 hrs ago'
  },
  {
    id: 'CS-8918',
    sample: 'South Perimeter &bull; Roma Tomato',
    disease: 'Bacterial Spot',
    severity: '31.0%',
    confidence: '88.7%',
    status: 'outline',
    time: '3 hrs ago'
  }
];

const MODEL_HEALTH = [
  { name: 'YOLOv8 Foliar Pathology Detector', status: 'online', latency: '42ms', accuracy: '96.8% (mAP 93.8%)' },
  { name: 'Grad-CAM Attention Saliency Engine', status: 'online', latency: '68ms', accuracy: '94.8% IoU' },
  { name: 'Van der Plank Epidemiological ODE', status: 'online', latency: '15ms', accuracy: 'Continuous Stability' },
  { name: 'BiLSTM Multi-Horizon Forecaster', status: 'online', latency: '34ms', accuracy: 'Val MSE 0.0004' },
  { name: 'Random Forest Harvest Yield Regressor', status: 'online', latency: '12ms', accuracy: 'R² 0.990' },
  { name: 'Bayesian Conjugate Trust Evaluator', status: 'online', latency: '22ms', accuracy: '12 Multimodal Signals' },
  { name: 'Solana Devnet Proof Anchor (SPL Memo)', status: 'online', latency: '1.4s', accuracy: 'On-Chain Verified' }
];

export default function Dashboard() {
  return (
    <div className="space-y-6 pb-12 font-sans">
      {/* Executive Command Header */}
      <Card className="border border-stone-200 shadow-xs bg-white overflow-hidden">
        <div className="h-1.5 w-full bg-[#1B4332]" />
        <CardContent className="p-6 sm:p-8">
          <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-6">
            <div className="max-w-2xl">
              <div className="flex items-center gap-2 mb-2">
                <span className="w-2 h-2 rounded-full bg-emerald-600 animate-pulse" />
                <Badge variant="outline" className="font-mono text-xs uppercase tracking-wider text-emerald-800 bg-emerald-50 border-emerald-200">
                  Precision Crop Protection &bull; Solanaceae Suite
                </Badge>
              </div>
              <h1 className="font-display text-2xl sm:text-3xl font-extrabold tracking-tight text-stone-900">
                CropSure Telemetry &amp; Intelligence Console
              </h1>
              <p className="text-sm text-stone-600 mt-2 leading-relaxed">
                Autonomous foliar disease identification, convolutional Grad-CAM attention mapping, Van der Plank epidemic delay-differential simulations, and immutable Solana Devnet specimen certification.
              </p>

              <div className="mt-5 flex flex-wrap gap-3">
                <Button asChild className="bg-[#1B4332] hover:bg-[#2D6A4F] text-white font-bold text-xs shadow-sm">
                  <Link to="/analyze" className="gap-2">
                    <ScanSearch className="w-4 h-4" />
                    <span>Run Pathology Diagnosis</span>
                  </Link>
                </Button>

                <Button variant="outline" asChild className="text-xs font-semibold text-stone-700">
                  <Link to="/epidemic" className="gap-2">
                    <FlaskConical className="w-4 h-4 text-emerald-700" />
                    <span>Simulate Epidemic Growth</span>
                  </Link>
                </Button>

                <Button variant="ghost" asChild className="text-xs font-semibold text-stone-600">
                  <Link to="/forecast" className="gap-2">
                    <LineChart className="w-4 h-4" />
                    <span>30-Day Projections</span>
                  </Link>
                </Button>
              </div>
            </div>

            {/* Quick Microclimate Telemetry Pill */}
            <div className="p-4 rounded-xl bg-stone-50 border border-stone-200/80 shrink-0 space-y-3">
              <div className="flex items-center justify-between text-xs">
                <span className="font-mono uppercase text-[10px] text-stone-500 font-bold">Field Station Weather</span>
                <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
              </div>
              <div className="grid grid-cols-3 gap-3 text-center text-xs">
                <div className="p-2 rounded bg-white border border-stone-200">
                  <span className="text-[10px] text-stone-400 block font-mono">Temp</span>
                  <span className="font-mono font-bold text-stone-900">23.8°C</span>
                </div>
                <div className="p-2 rounded bg-white border border-stone-200">
                  <span className="text-[10px] text-stone-400 block font-mono">Humidity</span>
                  <span className="font-mono font-bold text-emerald-800">84% RH</span>
                </div>
                <div className="p-2 rounded bg-white border border-stone-200">
                  <span className="text-[10px] text-stone-400 block font-mono">Leaf Wet</span>
                  <span className="font-mono font-bold text-amber-700">6.2 hrs</span>
                </div>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* KPI Stats Strip */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <Card className="border border-stone-200/80 shadow-xs bg-white">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <span className="text-xs font-mono text-stone-500 uppercase tracking-wider">Models Active</span>
              <Cpu className="w-4 h-4 text-emerald-700" />
            </div>
            <div className="font-mono text-2xl font-bold text-stone-900 mt-2">6 / 6</div>
            <p className="text-xs text-stone-500 mt-0.5">Dual CNN + BiLSTM + Van der Plank</p>
          </CardContent>
        </Card>

        <Card className="border border-stone-200/80 shadow-xs bg-white">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <span className="text-xs font-mono text-stone-500 uppercase tracking-wider">Field Specimens</span>
              <Activity className="w-4 h-4 text-emerald-700" />
            </div>
            <div className="font-mono text-2xl font-bold text-stone-900 mt-2">14,820</div>
            <p className="text-xs text-emerald-700 mt-0.5 font-medium">+18.4% seasonal throughput</p>
          </CardContent>
        </Card>

        <Card className="border border-stone-200/80 shadow-xs bg-white">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <span className="text-xs font-mono text-stone-500 uppercase tracking-wider">Validation Accuracy</span>
              <ShieldCheck className="w-4 h-4 text-emerald-700" />
            </div>
            <div className="font-mono text-2xl font-bold text-stone-900 mt-2">96.8%</div>
            <p className="text-xs text-stone-500 mt-0.5">mAP@50 93.8% (Test Split)</p>
          </CardContent>
        </Card>

        <Card className="border border-stone-200/80 shadow-xs bg-white">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <span className="text-xs font-mono text-stone-500 uppercase tracking-wider">Blockchain Ledger</span>
              <Leaf className="w-4 h-4 text-purple-700" />
            </div>
            <div className="font-mono text-2xl font-bold text-purple-950 mt-2">Solana Devnet</div>
            <p className="text-xs text-purple-800 mt-0.5">SPL Memo Anchoring Active</p>
          </CardContent>
        </Card>
      </div>

      {/* Main Grid: Disease Distribution + Quick Actions */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Disease Distribution Chart (7 cols) */}
        <div className="lg:col-span-7 space-y-4">
          <Card className="border border-stone-200 shadow-xs bg-white">
            <CardHeader className="pb-3 border-b border-stone-100">
              <div className="flex items-center justify-between">
                <div>
                  <CardTitle className="font-display text-sm font-bold text-stone-900">
                    Foliar Pathology Frequency Distribution
                  </CardTitle>
                  <CardDescription className="text-xs text-stone-500">
                    Aggregated prevalence across regional tomato monitored cohorts
                  </CardDescription>
                </div>
                <Badge variant="outline" className="font-mono text-xs">
                  8 Target Classes
                </Badge>
              </div>
            </CardHeader>
            <CardContent className="pt-4">
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
                      formatter={(value, name) => [`${value}% prevalence`, name]}
                      contentStyle={{ backgroundColor: '#FFFFFF', borderRadius: '0.5rem', border: '1px solid #E2E8F0', fontSize: '12px' }}
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

              <div className="mt-4 pt-3 border-t border-stone-100 flex items-center justify-between text-xs text-stone-600">
                <span>Primary Threats: <strong className="text-stone-900">Early &amp; Late Blight (50% combined)</strong></span>
                <Link to="/forecast" className="text-emerald-800 hover:underline font-semibold flex items-center gap-1">
                  <span>View 30-Day Trajectory</span>
                  <ArrowRight className="w-3.5 h-3.5" />
                </Link>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Quick Diagnostic Actions (5 cols) */}
        <div className="lg:col-span-5 space-y-4">
          <Card className="border border-stone-200 shadow-xs bg-white">
            <CardHeader className="pb-3 border-b border-stone-100">
              <CardTitle className="font-display text-sm font-bold text-stone-900">
                Agronomic Workstation Shortcuts
              </CardTitle>
              <CardDescription className="text-xs text-stone-500">
                Direct access to analytical tools and simulations
              </CardDescription>
            </CardHeader>
            <CardContent className="pt-4 space-y-2.5">
              <Link
                to="/analyze"
                className="p-3.5 rounded-lg border border-stone-200 hover:border-emerald-700 bg-stone-50 hover:bg-emerald-50/40 transition-colors flex items-center justify-between group"
              >
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded bg-emerald-100 text-emerald-800 flex items-center justify-center">
                    <ScanSearch className="w-4 h-4" />
                  </div>
                  <div>
                    <div className="font-semibold text-xs text-stone-900 group-hover:text-emerald-800">
                      Leaf Disease Diagnosis
                    </div>
                    <div className="text-[11px] text-stone-500">
                      YOLOv8 + Grad-CAM + Solana Passport
                    </div>
                  </div>
                </div>
                <ArrowRight className="w-4 h-4 text-stone-400 group-hover:text-emerald-800 transition-colors" />
              </Link>

              <Link
                to="/forecast"
                className="p-3.5 rounded-lg border border-stone-200 hover:border-emerald-700 bg-stone-50 hover:bg-emerald-50/40 transition-colors flex items-center justify-between group"
              >
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded bg-amber-100 text-amber-800 flex items-center justify-center">
                    <LineChart className="w-4 h-4" />
                  </div>
                  <div>
                    <div className="font-semibold text-xs text-stone-900 group-hover:text-emerald-800">
                      Disease Severity Forecasting
                    </div>
                    <div className="text-[11px] text-stone-500">
                      7, 14, 30-day Bayesian LSTM curves
                    </div>
                  </div>
                </div>
                <ArrowRight className="w-4 h-4 text-stone-400 group-hover:text-emerald-800 transition-colors" />
              </Link>

              <Link
                to="/epidemic"
                className="p-3.5 rounded-lg border border-stone-200 hover:border-emerald-700 bg-stone-50 hover:bg-emerald-50/40 transition-colors flex items-center justify-between group"
              >
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded bg-stone-200 text-stone-800 flex items-center justify-center">
                    <FlaskConical className="w-4 h-4" />
                  </div>
                  <div>
                    <div className="font-semibold text-xs text-stone-900 group-hover:text-emerald-800">
                      Epidemic Growth Simulator
                    </div>
                    <div className="text-[11px] text-stone-500">
                      Van der Plank delay differential ODE
                    </div>
                  </div>
                </div>
                <ArrowRight className="w-4 h-4 text-stone-400 group-hover:text-emerald-800 transition-colors" />
              </Link>

              <Link
                to="/models"
                className="p-3.5 rounded-lg border border-stone-200 hover:border-emerald-700 bg-stone-50 hover:bg-emerald-50/40 transition-colors flex items-center justify-between group"
              >
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded bg-purple-100 text-purple-800 flex items-center justify-center">
                    <Cpu className="w-4 h-4" />
                  </div>
                  <div>
                    <div className="font-semibold text-xs text-stone-900 group-hover:text-emerald-800">
                      Model Registry &amp; Health
                    </div>
                    <div className="text-[11px] text-stone-500">
                      Neural weight checkpoints &amp; latency
                    </div>
                  </div>
                </div>
                <ArrowRight className="w-4 h-4 text-stone-400 group-hover:text-emerald-800 transition-colors" />
              </Link>
            </CardContent>
          </Card>
        </div>
      </div>

      {/* Bottom Row: Recent Detections + Model Health */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent Detections */}
        <Card className="border border-stone-200 shadow-xs bg-white">
          <CardHeader className="pb-3 border-b border-stone-100">
            <div className="flex items-center justify-between">
              <div>
                <CardTitle className="font-display text-sm font-bold text-stone-900">
                  Recent Foliar Analyses
                </CardTitle>
                <CardDescription className="text-xs text-stone-500">
                  Latest automated sensor captures and manual scans
                </CardDescription>
              </div>
              <Clock className="w-4 h-4 text-stone-400" />
            </div>
          </CardHeader>
          <CardContent className="pt-2 divide-y divide-stone-100">
            {RECENT_ANALYSES.map((item) => (
              <div key={item.id} className="py-3 flex items-center justify-between text-xs">
                <div className="flex items-center gap-3">
                  <Badge variant="outline" className="font-mono text-[10px]">
                    {item.id}
                  </Badge>
                  <div>
                    <h5 className="font-semibold text-stone-900">{item.disease}</h5>
                    <p className="text-stone-500 text-[11px]">{item.sample}</p>
                  </div>
                </div>

                <div className="text-right flex items-center gap-2">
                  <span className="font-mono font-semibold text-stone-700">{item.severity}</span>
                  <Badge variant={item.status === 'destructive' ? 'destructive' : 'outline'} className="text-[10px]">
                    {item.confidence}
                  </Badge>
                </div>
              </div>
            ))}
          </CardContent>
        </Card>

        {/* Model Pipeline Health */}
        <Card className="border border-stone-200 shadow-xs bg-white">
          <CardHeader className="pb-3 border-b border-stone-100">
            <div className="flex items-center justify-between">
              <div>
                <CardTitle className="font-display text-sm font-bold text-stone-900">
                  Analytical Engines &bull; Runtime Health
                </CardTitle>
                <CardDescription className="text-xs text-stone-500">
                  Active deep learning inference models &amp; consensus ledger
                </CardDescription>
              </div>
              <Badge variant="outline" className="font-mono text-xs text-emerald-800 bg-emerald-50 border-emerald-200">
                All 7 Operational
              </Badge>
            </div>
          </CardHeader>
          <CardContent className="pt-2 divide-y divide-stone-100 text-xs">
            {MODEL_HEALTH.map((model, idx) => (
              <div key={idx} className="py-2.5 flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <span className="w-1.5 h-1.5 rounded-full bg-emerald-600" />
                  <span className="font-medium text-stone-800">{model.name}</span>
                </div>
                <div className="flex items-center gap-3 font-mono text-[11px]">
                  <span className="text-stone-400">{model.latency}</span>
                  <span className="text-emerald-800 font-bold bg-emerald-50 px-2 py-0.5 rounded border border-emerald-100">
                    {model.accuracy}
                  </span>
                </div>
              </div>
            ))}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
