import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import {
  ResponsiveContainer,
  BarChart,
  Bar,
  AreaChart,
  Area,
  LineChart,
  Line,
  XAxis,
  YAxis,
  Tooltip,
  CartesianGrid
} from 'recharts';
import {
  ScanSearch,
  Activity,
  ShieldCheck,
  Cpu,
  Leaf,
  Layers,
  RefreshCw,
  ArrowUp,
  ArrowDown,
  Calendar,
  AlertTriangle,
  ChevronRight,
  ExternalLink,
  Lock,
  Clock,
  Search,
  Filter
} from 'lucide-react';

// Shadcn UI Components
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { SheenPillButton } from '@/components/buttons/sheen-pill-button';
import { Avatar, AvatarImage, AvatarFallback } from '@/components/ui/avatar';
import { Progress } from '@/components/ui/progress';

// Interior FilterGrid & Animated Spring Cards
import { FilterGrid, AnimatedCard } from '@/components/interior/filter-grid';

// Chronicle-style Sparkline Dataset: Hourly Inoculum / Diagnoses
const HOURLY_DATA = [
  { time: '12a', current: 12, previous: 8 },
  { time: '2a', current: 8, previous: 8 },
  { time: '4a', current: 4, previous: 6 },
  { time: '6a', current: 6, previous: 4 },
  { time: '8a', current: 18, previous: 14 },
  { time: '10a', current: 42, previous: 28 },
  { time: '12p', current: 68, previous: 52 },
  { time: '2p', current: 84, previous: 64 },
  { time: '4p', current: 96, previous: 72 },
  { time: '6p', current: 78, previous: 58 },
  { time: '8p', current: 54, previous: 42 },
  { time: '10p', current: 28, previous: 22 }
];

// Weekly Active Nodes Trend (Step Area)
const STEP_NODES_DATA = [
  { month: 'Dec', accounts: 260 },
  { month: 'Jan', accounts: 272 },
  { month: 'Feb', accounts: 280 },
  { month: 'Mar', accounts: 295 },
  { month: 'Apr', accounts: 304 },
  { month: 'May', accounts: 312 },
  { month: 'Jun', accounts: 318 },
  { month: 'Jul', accounts: 320 },
  { month: 'Aug', accounts: 322 },
  { month: 'Sep', accounts: 324 },
  { month: 'Oct', accounts: 325 }
];

// Weekly New Diagnoses (Pill Bars)
const WEEKLY_DIAGNOSES = [
  { day: 'Wed', value: 8 },
  { day: 'Thu', value: 3 },
  { day: 'Fri', value: 5 },
  { day: 'Sat', value: 7 },
  { day: 'Sun', value: 6 },
  { day: 'Mon', value: 9 },
  { day: 'Tue', value: 7 }
];

// Accuracy 14-Day Trajectory
const ACCURACY_DATA = [
  { day: '1', acc: 95.8 },
  { day: '2', acc: 96.0 },
  { day: '3', acc: 96.1 },
  { day: '4', acc: 96.2 },
  { day: '5', acc: 96.4 },
  { day: '6', acc: 96.5 },
  { day: '7', acc: 96.8 }
];

// Needs Attention Items for FilterGrid
const ATTENTION_ITEMS = [
  {
    id: 'CS-PL-0158',
    plot: 'Upland Greenhouse 4B',
    disease: 'Tomato Late Blight',
    pathogen: 'Phytophthora infestans',
    scout: 'Seren Novak',
    cultivar: 'Roma Hybrid',
    status: 'Critical necrosis',
    category: 'critical',
    type: 'fungal',
    severity: '68%',
    severityNum: 68,
    threshold: '/ 40%',
    image: '/samples/late_blight_sample.jpg',
    action: 'Prescribe spray'
  },
  {
    id: 'CS-PL-0098',
    plot: 'Copperleaf Hydroponics',
    disease: 'Tomato Early Blight',
    pathogen: 'Alternaria solani',
    scout: 'Beatriz Kamau',
    cultivar: 'Beefsteak F1',
    status: 'Critical necrosis',
    category: 'critical',
    type: 'fungal',
    severity: '64%',
    severityNum: 64,
    threshold: '/ 35%',
    image: '/samples/early_blight_sample.jpg',
    action: 'Prune & isolate'
  },
  {
    id: 'CS-PL-0040',
    plot: 'Sedge Supply Perimeter',
    disease: 'Bacterial Spot',
    pathogen: 'Xanthomonas campestris',
    scout: 'Wen Kowalski',
    cultivar: 'Cherry Gold',
    status: 'Over severity threshold',
    category: 'moderate',
    type: 'bacterial',
    severity: '56%',
    severityNum: 56,
    threshold: '/ 45%',
    image: '/samples/bacterial_spot_sample.jpg',
    action: 'Copper treatment'
  },
  {
    id: 'CS-PL-0016',
    plot: 'Fernway Open Canopy',
    disease: 'Septoria Leaf Spot',
    pathogen: 'Septoria lycopersici',
    scout: 'Soren Dahl',
    cultivar: 'San Marzano',
    status: 'Over severity threshold',
    category: 'moderate',
    type: 'fungal',
    severity: '55%',
    severityNum: 55,
    threshold: '/ 40%',
    image: '/samples/septoria_sample.jpg',
    action: 'Dehumidify row'
  },
  {
    id: 'CS-PL-0204',
    plot: 'Highland Tunnel 2A',
    disease: 'Tomato Leaf Mold',
    pathogen: 'Passalora fulva',
    scout: 'Elena Rostova',
    cultivar: 'Ailsa Craig',
    status: 'Moderate sporulation',
    category: 'moderate',
    type: 'fungal',
    severity: '48%',
    severityNum: 48,
    threshold: '/ 35%',
    image: '/samples/late_blight_sample.jpg',
    action: 'Ventilate tunnel'
  },
  {
    id: 'CS-PL-0231',
    plot: 'East Acre Experimental',
    disease: 'Bacterial Canker',
    pathogen: 'Clavibacter michiganensis',
    scout: 'Marcus Vance',
    cultivar: 'Cherokee Purple',
    status: 'Critical necrosis',
    category: 'critical',
    type: 'bacterial',
    severity: '72%',
    severityNum: 72,
    threshold: '/ 30%',
    image: '/samples/bacterial_spot_sample.jpg',
    action: 'Quarantine plot'
  }
];

const ATTENTION_FILTERS = [
  { id: 'all', label: 'All Sectors', match: () => true },
  { id: 'critical', label: 'Critical (>60%)', match: (item) => item.severityNum >= 60 },
  { id: 'moderate', label: 'Moderate (<60%)', match: (item) => item.severityNum < 60 },
  { id: 'fungal', label: 'Fungal Pathogens', match: (item) => item.type === 'fungal' },
  { id: 'bacterial', label: 'Bacterial Spot', match: (item) => item.type === 'bacterial' },
];

// Diurnal Heatmap Matrix (7 days x 12 intervals)
const DAYS_OF_WEEK = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const DIURNAL_HEATMAP = [
  [1, 1, 2, 2, 3, 4, 4, 3, 3, 2, 1, 1], // Mon
  [1, 2, 2, 3, 4, 5, 5, 4, 3, 2, 1, 1], // Tue
  [2, 2, 3, 4, 5, 5, 4, 4, 3, 2, 1, 1], // Wed
  [1, 1, 2, 3, 3, 4, 3, 2, 2, 1, 1, 0], // Thu
  [1, 2, 3, 4, 5, 4, 3, 2, 1, 1, 1, 0], // Fri
  [0, 1, 1, 2, 2, 3, 3, 2, 1, 1, 0, 0], // Sat
  [1, 1, 2, 3, 4, 4, 3, 2, 1, 1, 0, 0]  // Sun
];

const INTENSITY_COLORS = {
  0: 'bg-slate-100',
  1: 'bg-emerald-100/70',
  2: 'bg-emerald-300',
  3: 'bg-emerald-500',
  4: 'bg-[#0d5c46]',
  5: 'bg-[#083e2f]'
};

export default function Dashboard() {
  const [selectedRange, setSelectedRange] = useState('7d');

  return (
    <div className="space-y-6 pb-12 font-sans">
      {/* Chronicle Header Filter Bar */}
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between pb-2 border-b border-border/60">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="w-2.5 h-2.5 rounded-full bg-[#0d5c46] animate-pulse" />
            <span className="text-xs font-mono uppercase tracking-wider text-muted-foreground font-semibold">
              Agronomic Overview &bull; Telemetry Engine
            </span>
          </div>
          <h1 className="font-display text-2xl sm:text-3xl font-bold tracking-tight text-foreground">
            Canopy Pathology Command Center
          </h1>
          <p className="text-xs sm:text-sm text-muted-foreground mt-0.5">
            Microclimatic foliar disease tracking, sporulation projections, and Solana Devnet on-chain passports.
          </p>
        </div>

        <div className="flex items-center gap-2.5 shrink-0">
          <div className="flex items-center rounded-xl border border-border/80 bg-card p-1 text-xs shadow-xs font-medium">
            {['24h', '7d', '30d', '90d'].map((range) => (
              <button
                key={range}
                onClick={() => setSelectedRange(range)}
                className={`px-3 py-1.5 rounded-lg transition-all cursor-pointer font-mono text-xs ${
                  selectedRange === range
                    ? 'bg-[#0d5c46] text-white shadow-xs font-semibold'
                    : 'text-muted-foreground hover:text-foreground'
                }`}
              >
                {range}
              </button>
            ))}
          </div>

          <Link to="/analyze">
            <SheenPillButton
              width={180}
              height={38}
              className="border-slate-300/80 bg-white shadow-xs hover:border-[#0d5c46]/40"
            >
              <ScanSearch className="w-3.5 h-3.5 text-[#0d5c46]" />
              <span>Evaluate Specimen</span>
            </SheenPillButton>
          </Link>
        </div>
      </div>

      {/* ROW 1: Chronicle 2:1 Split (Featured Top Metric Chart + Breakdown Progress Card) */}
      <div className="grid gap-4 lg:grid-cols-3">
        {/* Card 1: Main Metric & Diurnal Hourly Area Chart (2 cols) */}
        <AnimatedCard className="lg:col-span-2" delay={0.05}>
          <Card className="rounded-2xl border border-border/70 shadow-xs bg-card p-0 overflow-hidden h-full flex flex-col justify-between">
            <div className="flex items-start justify-between gap-2 p-5 pb-0">
              <div className="flex items-center gap-2 text-sm font-medium text-foreground">
                <Leaf className="size-4 text-[#0d5c46]" />
                <span>Total Foliar Intake &bull; Active Scans</span>
              </div>
              <Badge variant="outline" className="border-border text-muted-foreground font-mono text-[11px]">
                Hourly Sporulation Index
              </Badge>
            </div>

            <div className="flex flex-col gap-1 px-5 pt-3">
              <div className="flex flex-wrap items-baseline gap-x-3 gap-y-1">
                <span className="font-mono font-semibold tracking-tight tabular-nums text-3xl text-foreground">
                  14,820
                </span>
              </div>
              <div className="flex flex-wrap items-center gap-x-3 gap-y-1">
                <span className="inline-flex items-center gap-0.5 text-xs font-medium tabular-nums text-emerald-600">
                  <ArrowUp className="size-3.5" /> 18.4%
                </span>
                <span className="font-mono text-xs text-muted-foreground tabular-nums">
                  vs 12,510 scans in previous cycle
                </span>
              </div>
            </div>

            {/* Micro Bar Chart */}
            <div className="h-28 px-5 pt-3">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={HOURLY_DATA} margin={{ top: 5, right: 0, left: -20, bottom: 0 }}>
                  <defs>
                    <linearGradient id="chronicleBarGrad" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="0%" stopColor="#0d5c46" stopOpacity={0.85} />
                      <stop offset="100%" stopColor="#0d5c46" stopOpacity={0.2} />
                    </linearGradient>
                  </defs>
                  <Bar
                    dataKey="current"
                    fill="url(#chronicleBarGrad)"
                    radius={[4, 4, 0, 0]}
                    barSize={12}
                  />
                </BarChart>
              </ResponsiveContainer>
            </div>

            <div className="flex items-center justify-between gap-3 px-5 py-3 text-xs text-muted-foreground border-t border-border/40 bg-muted/20">
              <span className="flex items-center gap-1.5 font-mono text-[11px]">
                <span className="h-2.5 w-1.5 rounded-full bg-[#0d5c46]" />
                Current Diurnal Intake (By Hour)
              </span>
              <span className="flex items-center gap-1.5 font-mono text-[11px]">
                <span className="w-3 border-t border-dashed border-slate-400" />
                Historical Pathogen Baseline
              </span>
            </div>
          </Card>
        </AnimatedCard>

        {/* Card 2: Net Foliar Health Rate (1 col) */}
        <AnimatedCard delay={0.1}>
          <Card className="rounded-2xl border border-border/70 shadow-xs bg-card p-5 flex flex-col justify-between h-full">
            <div className="flex items-start justify-between gap-2">
              <div className="flex items-center gap-2 text-sm font-medium text-foreground">
                <RefreshCw className="size-4 text-[#0d5c46]" />
                <span>Net Crop Health Retention</span>
              </div>
            </div>

            <div className="flex flex-col gap-1 pt-3">
              <div className="flex flex-wrap items-baseline gap-x-3 gap-y-1">
                <span className="font-mono font-semibold tracking-tight tabular-nums text-3xl text-foreground">
                  99.7%
                </span>
              </div>
              <div className="flex flex-wrap items-center gap-x-3 gap-y-1">
                <span className="inline-flex items-center gap-0.5 text-xs font-medium tabular-nums text-emerald-600">
                  <ArrowUp className="size-3.5" /> 0.1%
                </span>
                <span className="font-mono text-xs text-muted-foreground tabular-nums">
                  Nov 2026, gross baseline 99.1%
                </span>
              </div>
            </div>

            {/* Movements Progress List */}
            <ul className="flex flex-col gap-3 pt-4 text-xs" aria-label="Canopy movements">
              <li className="grid grid-cols-[6rem_1fr_auto] items-center gap-3">
                <span className="text-muted-foreground font-medium">Optimal Foliage</span>
                <span className="h-1.5 overflow-hidden rounded-full bg-muted">
                  <span className="block h-full rounded-full bg-[#0d5c46]" style={{ width: '91.2%' }} />
                </span>
                <span className="font-mono font-medium tabular-nums text-foreground">13,420 ha</span>
              </li>

              <li className="grid grid-cols-[6rem_1fr_auto] items-center gap-3">
                <span className="text-muted-foreground font-medium">Mild Chlorosis</span>
                <span className="h-1.5 overflow-hidden rounded-full bg-muted">
                  <span className="block h-full rounded-full bg-[#0284c7]" style={{ width: '8.4%' }} />
                </span>
                <span className="font-mono font-medium tabular-nums text-foreground">1,040 ha</span>
              </li>

              <li className="grid grid-cols-[6rem_1fr_auto] items-center gap-3">
                <span className="text-muted-foreground font-medium">Active Lesion</span>
                <span className="h-1.5 overflow-hidden rounded-full bg-muted">
                  <span className="block h-full rounded-full bg-destructive" style={{ width: '51.4%' }} />
                </span>
                <span className="font-mono font-medium tabular-nums text-destructive">360 ha</span>
              </li>
            </ul>
          </Card>
        </AnimatedCard>
      </div>

      {/* ROW 2: Chronicle 4-Column Micro-Sparkline Cards with Animated Spring */}
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {/* Metric 1: Monitored Canopy Sectors */}
        <AnimatedCard delay={0.15}>
          <Card className="rounded-2xl border border-border/70 shadow-xs bg-card p-5 flex flex-col justify-between h-full">
            <div className="flex items-start justify-between gap-2">
              <div className="flex items-center gap-2 text-sm font-medium text-foreground">
                <Layers className="size-4 text-[#0d5c46]" />
                <span>Monitored Sectors</span>
              </div>
            </div>

            <div className="flex flex-col gap-1 pt-2">
              <span className="font-mono font-semibold tracking-tight tabular-nums text-3xl text-foreground">
                325
              </span>
              <div className="flex items-center gap-2">
                <span className="inline-flex items-center gap-0.5 text-xs font-medium tabular-nums text-emerald-600">
                  <ArrowUp className="size-3.5" /> 2.2%
                </span>
                <span className="font-mono text-xs text-muted-foreground tabular-nums">+7 new sectors</span>
              </div>
            </div>

            {/* Sparkline: Step Area Chart */}
            <div className="h-14 pt-2">
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={STEP_NODES_DATA} margin={{ top: 0, right: 0, left: 0, bottom: 0 }}>
                  <defs>
                    <linearGradient id="areaChronicle1" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="0%" stopColor="#0d5c46" stopOpacity={0.28} />
                      <stop offset="100%" stopColor="#0d5c46" stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <Area
                    type="stepAfter"
                    dataKey="accounts"
                    stroke="#0d5c46"
                    strokeWidth={1.5}
                    fill="url(#areaChronicle1)"
                    isAnimationActive={false}
                  />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          </Card>
        </AnimatedCard>

        {/* Metric 2: Weekly New Diagnoses (Pill Bars) */}
        <AnimatedCard delay={0.2}>
          <Card className="rounded-2xl border border-border/70 shadow-xs bg-card p-5 flex flex-col justify-between h-full">
            <div className="flex items-start justify-between gap-2">
              <div className="flex items-center gap-2 text-sm font-medium text-foreground">
                <Activity className="size-4 text-[#0d5c46]" />
                <span>Weekly Diagnoses</span>
              </div>
            </div>

            <div className="flex flex-col gap-1 pt-2">
              <span className="font-mono font-semibold tracking-tight tabular-nums text-3xl text-foreground">
                45
              </span>
              <div className="flex items-center gap-2">
                <span className="inline-flex items-center gap-0.5 text-xs font-medium tabular-nums text-rose-600">
                  <ArrowDown className="size-3.5" /> 6.2%
                </span>
                <span className="font-mono text-xs text-muted-foreground tabular-nums">48 in prior week</span>
              </div>
            </div>

            {/* Sparkline: Rounded Bar Chart */}
            <div className="h-14 pt-2">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={WEEKLY_DIAGNOSES} margin={{ top: 0, right: 0, left: 0, bottom: 0 }}>
                  <Bar
                    dataKey="value"
                    fill="#0d5c46"
                    radius={[4, 4, 0, 0]}
                    isAnimationActive={false}
                  />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </Card>
        </AnimatedCard>

        {/* Metric 3: Ensemble Pathology Confidence */}
        <AnimatedCard delay={0.25}>
          <Card className="rounded-2xl border border-border/70 shadow-xs bg-card p-5 flex flex-col justify-between h-full">
            <div className="flex items-start justify-between gap-2">
              <div className="flex items-center gap-2 text-sm font-medium text-foreground">
                <ShieldCheck className="size-4 text-[#0d5c46]" />
                <span>Detection Precision</span>
              </div>
            </div>

            <div className="flex flex-col gap-1 pt-2">
              <span className="font-mono font-semibold tracking-tight tabular-nums text-3xl text-foreground">
                96.8%
              </span>
              <div className="flex items-center gap-2">
                <span className="inline-flex items-center gap-0.5 text-xs font-medium tabular-nums text-emerald-600">
                  <ArrowUp className="size-3.5" /> 0.3%
                </span>
                <span className="font-mono text-xs text-muted-foreground tabular-nums">mAP@0.5 benchmark</span>
              </div>
            </div>

            {/* Sparkline: Spline Area Chart */}
            <div className="h-14 pt-2">
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={ACCURACY_DATA} margin={{ top: 4, right: 0, left: 0, bottom: 0 }}>
                  <Line
                    type="monotone"
                    dataKey="acc"
                    stroke="#0d5c46"
                    strokeWidth={2}
                    dot={false}
                    isAnimationActive={false}
                  />
                </LineChart>
              </ResponsiveContainer>
            </div>
          </Card>
        </AnimatedCard>

        {/* Metric 4: Multi-Tier Facility Distribution */}
        <AnimatedCard delay={0.3}>
          <Card className="rounded-2xl border border-border/70 shadow-xs bg-card p-5 flex flex-col justify-between h-full">
            <div className="flex items-start justify-between gap-2">
              <div className="flex items-center gap-2 text-sm font-medium text-foreground">
                <Cpu className="size-4 text-[#0d5c46]" />
                <span>Protected Facilities</span>
              </div>
            </div>

            <div className="flex flex-col gap-1 pt-2">
              <span className="font-mono font-semibold tracking-tight tabular-nums text-3xl text-foreground">
                5,190 <span className="text-sm font-normal text-muted-foreground">ha</span>
              </span>
              <div className="flex items-center gap-2">
                <span className="inline-flex items-center gap-0.5 text-xs font-medium tabular-nums text-emerald-600">
                  <ArrowUp className="size-3.5" /> 84.1%
                </span>
                <span className="font-mono text-xs text-muted-foreground tabular-nums">target coverage</span>
              </div>
            </div>

            {/* Segmented Tier Progress Breakdown */}
            <ul className="flex flex-col gap-1.5 pt-2 text-xs" aria-label="Facility coverage">
              <li className="grid grid-cols-[4.5rem_1fr_auto] items-center gap-3">
                <span className="text-muted-foreground text-[11px]">Open Canopy</span>
                <span className="h-1.5 overflow-hidden rounded-full bg-muted">
                  <span className="block h-full rounded-full bg-[#0d5c46]" style={{ width: '89.7%' }} />
                </span>
                <span className="font-mono text-[11px] tabular-nums text-foreground">2,171</span>
              </li>
              <li className="grid grid-cols-[4.5rem_1fr_auto] items-center gap-3">
                <span className="text-muted-foreground text-[11px]">Greenhouse</span>
                <span className="h-1.5 overflow-hidden rounded-full bg-muted">
                  <span className="block h-full rounded-full bg-[#15803d]" style={{ width: '81.5%' }} />
                </span>
                <span className="font-mono text-[11px] tabular-nums text-foreground">1,181</span>
              </li>
              <li className="grid grid-cols-[4.5rem_1fr_auto] items-center gap-3">
                <span className="text-muted-foreground text-[11px]">Hydroponic</span>
                <span className="h-1.5 overflow-hidden rounded-full bg-muted">
                  <span className="block h-full rounded-full bg-[#0284c7]" style={{ width: '80.1%' }} />
                </span>
                <span className="font-mono text-[11px] tabular-nums text-foreground">1,838</span>
              </li>
            </ul>
          </Card>
        </AnimatedCard>
      </div>

      {/* ROW 3: Interactive FilterGrid "Needs Attention" List (2 cols) + Diurnal Activity Matrix (1 col) */}
      <div className="grid gap-4 xl:grid-cols-3">
        {/* Left: Animated FilterGrid actionable list (2 cols) */}
        <AnimatedCard className="xl:col-span-2" delay={0.35}>
          <Card className="rounded-2xl border border-border/70 shadow-xs bg-card p-5 h-full flex flex-col justify-between">
            <div>
              <div className="flex items-start justify-between gap-2 pb-1">
                <div className="flex items-center gap-2 text-base font-semibold text-foreground font-display">
                  <span>Needs Attention</span>
                  <Badge variant="outline" className="border-transparent bg-destructive/10 text-destructive gap-1.5 font-medium font-mono text-xs">
                    <span className="size-1.5 rounded-full bg-destructive animate-pulse" />
                    {ATTENTION_ITEMS.filter(i => i.category === 'critical').length} Critical
                  </Badge>
                </div>
                <Button variant="ghost" size="sm" asChild className="h-7 text-xs text-muted-foreground hover:text-foreground">
                  <Link to="/analyze">Review Specimens &rarr;</Link>
                </Button>
              </div>
              <p className="pb-3 text-xs text-muted-foreground">
                Sectors exceeding foliar damage thresholds. Click tabs below to filter across critical thresholds and pathogen classes.
              </p>

              {/* Interior.dev FilterGrid Integration */}
              <FilterGrid
                label="Sector Pathology Categories"
                filters={ATTENTION_FILTERS}
                items={ATTENTION_ITEMS}
                getKey={(item) => item.id}
                columns={1}
                rowHeight={76}
                maxRows={5}
                gap={8}
                autoHeight={true}
                renderItem={(item) => (
                  <div className="flex items-center gap-3.5 w-full">
                    <Avatar className="size-10 rounded-lg border border-border shrink-0">
                      <AvatarImage src={item.image} alt={item.plot} className="object-cover" />
                      <AvatarFallback className="font-mono text-[11px] bg-muted font-bold text-slate-700">
                        {item.disease.slice(0, 2).toUpperCase()}
                      </AvatarFallback>
                    </Avatar>

                    <div className="flex min-w-0 flex-1 flex-col">
                      <div className="flex items-center gap-2">
                        <span className="truncate text-sm font-semibold text-foreground">
                          {item.plot} &bull; {item.disease}
                        </span>
                      </div>
                      <span className="truncate text-xs text-muted-foreground font-serif italic mt-0.5">
                        <span className="text-foreground/90 font-sans not-italic font-medium">{item.scout}</span> &bull; {item.cultivar} &bull; {item.pathogen}
                      </span>
                    </div>

                    <div className="hidden sm:block">
                      <Badge variant="outline" className={`gap-1.5 text-xs font-mono font-medium border-transparent ${
                        item.category === 'critical'
                          ? 'bg-destructive/10 text-destructive'
                          : 'bg-amber-500/10 text-amber-700'
                      }`}>
                        <span className={`size-1.5 rounded-full ${
                          item.category === 'critical' ? 'bg-destructive' : 'bg-amber-500'
                        }`} />
                        {item.status}
                      </Badge>
                    </div>

                    <div className="hidden w-20 text-end font-mono text-xs tabular-nums md:block">
                      <span className="text-destructive font-bold">{item.severity}</span>
                      <span className="text-muted-foreground">{item.threshold}</span>
                    </div>

                    <Button
                      variant="outline"
                      size="sm"
                      effect="lift"
                      asChild
                      className="w-28 shrink-0 h-8 text-xs font-medium border-border/80 hover:bg-muted bg-white/60 backdrop-blur-xs"
                    >
                      <Link to="/analyze">
                        {item.action}
                      </Link>
                    </Button>
                  </div>
                )}
              />
            </div>

            <div className="pt-3 border-t border-border/40 flex items-center justify-between text-xs text-muted-foreground">
              <span>Avg economic harvest exposure: <strong className="font-mono text-foreground">$1,983/ha</strong></span>
              <span className="font-mono text-[11px] text-[#0d5c46]">Automatic biosecurity dispatch</span>
            </div>
          </Card>
        </AnimatedCard>

        {/* Right: Diurnal Spore Activity Matrix (1 col) */}
        <AnimatedCard delay={0.4}>
          <Card className="rounded-2xl border border-border/70 shadow-xs bg-card p-5 flex flex-col justify-between h-full">
            <div>
              <div className="flex items-start justify-between gap-2 pb-1">
                <div className="flex items-center gap-2 text-sm font-semibold text-foreground font-display">
                  <Clock className="size-4 text-[#0d5c46]" />
                  <span>Diurnal Spore Index Matrix</span>
                </div>
                <Badge variant="outline" className="font-mono text-[10px] text-muted-foreground">
                  7-Day × 12-Interval
                </Badge>
              </div>
              <p className="pb-3 text-xs text-muted-foreground">
                Microclimate spore release probability correlated with canopy RH (&gt;75%) and diurnal temperature.
              </p>

              {/* 7x12 Heatmap Matrix Grid */}
              <div className="space-y-1 pt-1">
                {DAYS_OF_WEEK.map((day, dIdx) => (
                  <div key={day} className="flex items-center gap-2 text-xs">
                    <span className="w-8 font-mono text-[11px] text-muted-foreground shrink-0">{day}</span>
                    <div className="grid grid-cols-12 gap-1 flex-1">
                      {DIURNAL_HEATMAP[dIdx].map((val, hIdx) => (
                        <div
                          key={hIdx}
                          className={`h-4 rounded-xs transition-transform hover:scale-110 cursor-pointer ${INTENSITY_COLORS[val]}`}
                          title={`${day} Interval ${hIdx * 2}:00 - Threat Level ${val}/5`}
                        />
                      ))}
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Legend */}
            <div className="flex items-center justify-between pt-4 mt-2 border-t border-border/40 text-[11px] text-muted-foreground font-mono">
              <span className="flex items-center gap-1.5">
                <span className="size-2 rounded-xs bg-slate-100 border border-slate-300" />
                Dormant (0)
              </span>
              <span className="flex items-center gap-1.5">
                <span className="size-2 rounded-xs bg-emerald-300" />
                Moderate (2)
              </span>
              <span className="flex items-center gap-1.5">
                <span className="size-2 rounded-xs bg-[#083e2f]" />
                Peak Sporulation (5)
              </span>
            </div>
          </Card>
        </AnimatedCard>
      </div>

      {/* ROW 4: Solana Devnet On-Chain Passports Ledger */}
      <AnimatedCard delay={0.45}>
        <Card className="rounded-2xl border border-border/70 shadow-xs bg-card overflow-hidden">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 p-5 pb-3 border-b border-border/60">
            <div>
              <div className="flex items-center gap-2">
                <h3 className="font-display text-sm font-semibold text-foreground">
                  Solana Devnet On-Chain Crop Passports
                </h3>
                <Badge variant="outline" className="font-mono text-[10px] text-[#0d5c46] border-[#0d5c46]/30 bg-[#e6f0ed]">
                  SPL Memo v2
                </Badge>
              </div>
              <p className="text-xs text-muted-foreground mt-0.5">
                Cryptographically anchored foliar pathology proofs finalized on Solana Devnet validators
              </p>
            </div>

            <Button
              variant="outline"
              size="sm"
              effect="lift"
              asChild
              className="font-mono text-xs text-muted-foreground hover:text-foreground shrink-0 h-8 bg-white/60 backdrop-blur-xs"
            >
              <a
                href="https://explorer.solana.com/?cluster=devnet"
                target="_blank"
                rel="noopener noreferrer"
              >
                <span>Solana Explorer</span>
                <ExternalLink className="w-3 h-3 ml-1.5" />
              </a>
            </Button>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-slate-50/80 text-muted-foreground border-b border-border/60 font-mono text-[10px] uppercase tracking-wider">
                <tr>
                  <th className="py-2.5 px-5">Passport ID</th>
                  <th className="py-2.5 px-5">Specimen Image</th>
                  <th className="py-2.5 px-5">Taxon Classification</th>
                  <th className="py-2.5 px-5">Severity</th>
                  <th className="py-2.5 px-5">Solana Transaction Signature</th>
                  <th className="py-2.5 px-5">Block Slot</th>
                  <th className="py-2.5 px-5">Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border/60 font-medium">
                {[
                  {
                    id: 'CS-SOL-9YWEQ7TP',
                    plot: 'Field Sector C-4',
                    disease: 'Tomato Early Blight',
                    pathogen: 'Alternaria solani',
                    severity: '64.2%',
                    tx: '5KmPvQnRxY3ZbWp7A9dE...L4vN',
                    fullTx: '5KmPvQnRxY3ZbWp7A9dEL4vN19QWEQ7TP89fghjk1234',
                    slot: '298,443,112',
                    status: 'Finalized',
                    thumb: '/samples/early_blight_sample.jpg'
                  },
                  {
                    id: 'CS-SOL-8KLA42MN',
                    plot: 'Hydroponic Bay 2',
                    disease: 'Tomato Late Blight',
                    pathogen: 'Phytophthora infestans',
                    severity: '68.0%',
                    tx: '4NkLtZpQxR8WaYc9B2eD...M5wP',
                    fullTx: '4NkLtZpQxR8WaYc9B2eDM5wP90KLAS3210zxvbn5678',
                    slot: '298,440,881',
                    status: 'Finalized',
                    thumb: '/samples/late_blight_sample.jpg'
                  },
                  {
                    id: 'CS-SOL-7XDF19JK',
                    plot: 'High-Tunnel Nursery',
                    disease: 'Bacterial Spot',
                    pathogen: 'Xanthomonas campestris',
                    severity: '56.4%',
                    tx: '3MjKsYoPwQ7VzXb8A1dC...K4vO',
                    fullTx: '3MjKsYoPwQ7VzXb8A1dCK4vO89XDF19JK7654321098',
                    slot: '298,438,450',
                    status: 'Finalized',
                    thumb: '/samples/bacterial_spot_sample.jpg'
                  }
                ].map((p) => (
                  <tr key={p.id} className="hover:bg-slate-50/60 transition-colors">
                    <td className="py-3 px-5 font-mono text-foreground font-semibold">
                      {p.id}
                    </td>
                    <td className="py-3 px-5">
                      <div className="size-8 rounded-md overflow-hidden bg-muted border border-border">
                        <img src={p.thumb} alt={p.disease} className="w-full h-full object-cover" />
                      </div>
                    </td>
                    <td className="py-3 px-5">
                      <div className="font-semibold text-foreground">{p.disease}</div>
                      <div className="text-[11px] text-muted-foreground font-serif italic">{p.pathogen} &bull; {p.plot}</div>
                    </td>
                    <td className="py-3 px-5 font-mono font-bold text-destructive">
                      {p.severity}
                    </td>
                    <td className="py-3 px-5 font-mono text-muted-foreground">
                      <div className="flex items-center gap-1.5">
                        <Lock className="size-3 text-[#0d5c46]" />
                        <span className="hover:text-foreground transition-colors cursor-pointer" title={p.fullTx}>
                          {p.tx}
                        </span>
                      </div>
                    </td>
                    <td className="py-3 px-5 font-mono text-muted-foreground">
                      {p.slot}
                    </td>
                    <td className="py-3 px-5">
                      <Badge variant="outline" className="font-mono text-[11px] bg-[#0d5c46]/10 text-[#0d5c46] border-[#0d5c46]/20">
                        &bull; {p.status}
                      </Badge>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Card>
      </AnimatedCard>
    </div>
  );
}
