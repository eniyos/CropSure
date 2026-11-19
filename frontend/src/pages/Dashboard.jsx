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
  Sparkles,
  Search,
  Filter
} from 'lucide-react';

// Shadcn UI Components
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Avatar, AvatarImage, AvatarFallback } from '@/components/ui/avatar';
import { Progress } from '@/components/ui/progress';

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

// Needs Attention Items (Chronicle "Needs Attention" List)
const ATTENTION_ITEMS = [
  {
    id: 'CS-PL-0158',
    plot: 'Upland Greenhouse 4B',
    disease: 'Tomato Late Blight',
    pathogen: 'Phytophthora infestans',
    scout: 'Seren Novak',
    cultivar: 'Roma Hybrid',
    status: 'Over severity threshold',
    severity: '60%',
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
    severity: '68%',
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
    severity: '56%',
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
    severity: '55%',
    threshold: '/ 40%',
    image: '/samples/septoria_sample.jpg',
    action: 'Dehumidify row'
  },
  {
    id: 'CS-PL-0186',
    plot: 'Juniper High-Tunnel 2',
    disease: 'Tomato Spider Mites',
    pathogen: 'Tetranychus urticae',
    scout: 'Chidi Chandra',
    cultivar: 'Heirloom Brandywine',
    status: 'Sub-canopy outbreak',
    severity: '43%',
    threshold: '/ 30%',
    image: '/samples/spider_mites_sample.jpg',
    action: 'Miticidal release'
  }
];

// Diurnal Heatmap Matrix Data (Days x 2-Hour Blocks)
const DAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const TIME_BLOCKS = ['12a', '2a', '4a', '6a', '8a', '10a', '12p', '2p', '4p', '6p', '8p', '10p'];
// Simulated infection moisture intensity: 0 to 4
const HEATMAP_GRID = [
  [1, 1, 1, 2, 4, 5, 4, 4, 3, 2, 1, 1], // Mon
  [1, 1, 1, 2, 4, 5, 4, 5, 4, 2, 1, 1], // Tue (Peak)
  [1, 1, 1, 2, 4, 5, 4, 4, 3, 2, 1, 1], // Wed
  [1, 1, 1, 2, 3, 4, 4, 4, 3, 2, 1, 1], // Thu
  [1, 1, 1, 2, 3, 4, 3, 3, 2, 1, 1, 1], // Fri
  [1, 1, 0, 1, 1, 2, 2, 2, 1, 1, 1, 1], // Sat
  [1, 0, 0, 1, 1, 2, 2, 2, 1, 1, 1, 1]  // Sun
];

export default function Dashboard() {
  const [filterPeriod, setFilterPeriod] = useState('Last 30 days');

  return (
    <div className="space-y-4 pb-16 font-sans">
      {/* Chronicle Inset Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-1 border-b border-border/60">
        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-xl font-semibold tracking-tight text-foreground">
              Overview
            </h1>
            <Badge variant="outline" className="text-[11px] font-mono border-border bg-muted/40 text-muted-foreground">
              CropSure Production
            </Badge>
          </div>
          <p className="text-xs text-muted-foreground mt-0.5">
            Real-time foliar health metrics, epidemic propagation curves, and Solana on-chain passports
          </p>
        </div>

        <div className="flex items-center gap-2 shrink-0">
          <Button variant="outline" size="sm" className="h-8 text-xs font-medium gap-1.5 border-border">
            <Calendar className="size-3.5 text-muted-foreground" />
            <span>Oct 20 &ndash; Nov 19, 2026</span>
          </Button>

          <Button asChild size="sm" className="h-8 text-xs font-medium bg-[#0D5C46] hover:bg-[#0A4A55] text-white gap-1.5 shadow-xs">
            <Link to="/analyze">
              <ScanSearch className="size-3.5" />
              <span>Analyze Leaf</span>
            </Link>
          </Button>
        </div>
      </div>

      {/* ROW 1: Chronicle Hero Double Card (2:1 Grid) */}
      <div className="grid gap-4 xl:grid-cols-3">
        {/* Card 1: Foliar Scan Throughput & Hourly Inoculum (2 cols) */}
        <Card className="rounded-2xl border border-border/60 shadow-xs bg-card xl:col-span-2 overflow-hidden">
          <div className="flex items-start justify-between gap-2 p-5 pb-0">
            <div className="flex items-center gap-2 text-sm font-medium text-foreground">
              <Layers className="size-4 text-[#0D5C46]" />
              <span>Foliar Intake &amp; Pathogen Velocity</span>
            </div>
            <Badge variant="outline" className="font-mono text-[10px] text-muted-foreground">
              Live Inoculum Stream
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
                    <stop offset="0%" stopColor="#0D5C46" stopOpacity={0.8} />
                    <stop offset="100%" stopColor="#0D5C46" stopOpacity={0.2} />
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
              <span className="h-2.5 w-1.5 rounded-full bg-[#0D5C46]" />
              Current Diurnal Intake (By Hour)
            </span>
            <span className="flex items-center gap-1.5 font-mono text-[11px]">
              <span className="w-3 border-t border-dashed border-slate-400" />
              Historical Pathogen Baseline
            </span>
          </div>
        </Card>

        {/* Card 2: Net Foliar Health Rate (1 col) */}
        <Card className="rounded-2xl border border-border/60 shadow-xs bg-card p-5 flex flex-col justify-between">
          <div className="flex items-start justify-between gap-2">
            <div className="flex items-center gap-2 text-sm font-medium text-foreground">
              <RefreshCw className="size-4 text-[#0D5C46]" />
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
              <span className="text-muted-foreground">Optimal Foliage</span>
              <span className="h-1.5 overflow-hidden rounded-full bg-muted">
                <span className="block h-full rounded-full bg-[#0D5C46]" style={{ width: '91.2%' }} />
              </span>
              <span className="font-mono font-medium tabular-nums text-foreground">13,420 ha</span>
            </li>

            <li className="grid grid-cols-[6rem_1fr_auto] items-center gap-3">
              <span className="text-muted-foreground">Mild Chlorosis</span>
              <span className="h-1.5 overflow-hidden rounded-full bg-muted">
                <span className="block h-full rounded-full bg-[#0891B2]" style={{ width: '8.4%' }} />
              </span>
              <span className="font-mono font-medium tabular-nums text-foreground">1,040 ha</span>
            </li>

            <li className="grid grid-cols-[6rem_1fr_auto] items-center gap-3">
              <span className="text-muted-foreground">Active Lesion</span>
              <span className="h-1.5 overflow-hidden rounded-full bg-muted">
                <span className="block h-full rounded-full bg-destructive" style={{ width: '51.4%' }} />
              </span>
              <span className="font-mono font-medium tabular-nums text-destructive">360 ha</span>
            </li>
          </ul>
        </Card>
      </div>

      {/* ROW 2: Chronicle 4-Column Micro-Sparkline Cards */}
      <div className="grid gap-4 lg:grid-cols-2 2xl:grid-cols-4">
        {/* Metric 1: Paying Accounts -> Monitored Canopy Sectors */}
        <Card className="rounded-2xl border border-border/60 shadow-xs bg-card p-5 flex flex-col justify-between">
          <div className="flex items-start justify-between gap-2">
            <div className="flex items-center gap-2 text-sm font-medium text-foreground">
              <Layers className="size-4 text-[#0D5C46]" />
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
              <span className="font-mono text-xs text-muted-foreground tabular-nums">
                vs 318 last month
              </span>
            </div>
          </div>

          <div className="h-24 pt-3 -mx-2">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={STEP_NODES_DATA}>
                <defs>
                  <linearGradient id="sectorStepGrad" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="#0D5C46" stopOpacity={0.28} />
                    <stop offset="100%" stopColor="#0D5C46" stopOpacity={0.0} />
                  </linearGradient>
                </defs>
                <Area
                  type="stepAfter"
                  dataKey="accounts"
                  stroke="#0D5C46"
                  strokeWidth={2}
                  fill="url(#sectorStepGrad)"
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </Card>

        {/* Metric 2: New Accounts per Week -> Weekly Critical Inoculations */}
        <Card className="rounded-2xl border border-border/60 shadow-xs bg-card p-5 flex flex-col justify-between">
          <div className="flex items-start justify-between gap-2">
            <div className="flex items-center gap-2 text-sm font-medium text-foreground">
              <Activity className="size-4 text-[#0D5C46]" />
              <span>New Alerts per Week</span>
            </div>
          </div>

          <div className="flex flex-col gap-1 pt-2">
            <span className="font-mono font-semibold tracking-tight tabular-nums text-3xl text-foreground">
              7
            </span>
            <div className="flex items-center gap-2">
              <span className="inline-flex items-center gap-0.5 text-xs font-medium tabular-nums text-destructive">
                <ArrowDown className="size-3.5" /> 22.2%
              </span>
              <span className="font-mono text-xs text-muted-foreground tabular-nums">
                16 field alerts open now
              </span>
            </div>
          </div>

          <div className="h-24 pt-3 -mx-2">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={WEEKLY_DIAGNOSES}>
                <Bar
                  dataKey="value"
                  fill="#0D5C46"
                  radius={[999, 999, 0, 0]}
                  barSize={12}
                  opacity={0.35}
                />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </Card>

        {/* Metric 3: Pathology Benchmark Accuracy */}
        <Card className="rounded-2xl border border-border/60 shadow-xs bg-card p-5 flex flex-col justify-between">
          <div className="flex items-start justify-between gap-2">
            <div className="flex items-center gap-2 text-sm font-medium text-foreground">
              <ShieldCheck className="size-4 text-[#0D5C46]" />
              <span>Model Test Accuracy</span>
            </div>
          </div>

          <div className="flex flex-col gap-1 pt-2">
            <span className="font-mono font-semibold tracking-tight tabular-nums text-3xl text-foreground">
              96.8%
            </span>
            <div className="flex items-center gap-2">
              <span className="inline-flex items-center gap-0.5 text-xs font-medium tabular-nums text-emerald-600">
                <ArrowUp className="size-3.5" /> 0.4%
              </span>
              <span className="font-mono text-xs text-muted-foreground tabular-nums">
                mAP@50 93.8% test split
              </span>
            </div>
          </div>

          <div className="h-24 pt-3 -mx-2">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={ACCURACY_DATA}>
                <Line
                  type="monotone"
                  dataKey="acc"
                  stroke="#0D5C46"
                  strokeWidth={2}
                  dot={{ r: 2.5, fill: '#0D5C46' }}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </Card>

        {/* Metric 4: Seats in Use -> Monitored Hectares Capacity */}
        <Card className="rounded-2xl border border-border/60 shadow-xs bg-card p-5 flex flex-col justify-between">
          <div className="flex items-start justify-between gap-2">
            <div className="flex items-center gap-2 text-sm font-medium text-foreground">
              <Leaf className="size-4 text-[#0D5C46]" />
              <span>Monitored Hectares</span>
            </div>
          </div>

          <div className="flex flex-col gap-1 pt-2">
            <span className="font-mono font-semibold tracking-tight tabular-nums text-3xl text-foreground">
              80.9%
            </span>
            <span className="font-mono text-xs text-muted-foreground tabular-nums">
              3,707 of 4,582 registered hectares
            </span>
          </div>

          <ul className="flex flex-col gap-2 pt-3 text-xs" aria-label="Canopy by zone">
            <li className="grid grid-cols-[4.5rem_1fr_auto] items-center gap-3">
              <span className="text-muted-foreground">Open Field</span>
              <span className="h-1.5 overflow-hidden rounded-full bg-muted">
                <span className="block h-full rounded-full bg-[#0D5C46]" style={{ width: '81.9%' }} />
              </span>
              <span className="font-mono text-xs tabular-nums text-foreground">688/840</span>
            </li>
            <li className="grid grid-cols-[4.5rem_1fr_auto] items-center gap-3">
              <span className="text-muted-foreground">Greenhouse</span>
              <span className="h-1.5 overflow-hidden rounded-full bg-muted">
                <span className="block h-full rounded-full bg-[#15803D]" style={{ width: '81.5%' }} />
              </span>
              <span className="font-mono text-xs tabular-nums text-foreground">1,181/1,448</span>
            </li>
            <li className="grid grid-cols-[4.5rem_1fr_auto] items-center gap-3">
              <span className="text-muted-foreground">Hydroponic</span>
              <span className="h-1.5 overflow-hidden rounded-full bg-muted">
                <span className="block h-full rounded-full bg-[#0284C7]" style={{ width: '80.1%' }} />
              </span>
              <span className="font-mono text-xs tabular-nums text-foreground">1,838/2,294</span>
            </li>
          </ul>

          <p className="pt-2 text-xs text-muted-foreground">
            <span className="font-mono text-foreground tabular-nums font-semibold">19</span> sectors require active ventilation.
          </p>
        </Card>
      </div>

      {/* ROW 3: Chronicle "Needs Attention" List (2 cols) + Diurnal Activity Matrix (1 col) */}
      <div className="grid gap-4 xl:grid-cols-3">
        {/* Left: "Needs attention" actionable list (2 cols) */}
        <Card className="rounded-2xl border border-border/60 shadow-xs bg-card overflow-hidden xl:col-span-2">
          <div className="flex items-start justify-between gap-2 p-5 pb-1">
            <div className="flex items-center gap-2 text-base font-medium text-foreground">
              <span>Needs attention</span>
              <Badge variant="outline" className="border-transparent bg-destructive/10 text-destructive gap-1.5 font-medium">
                <span className="size-1.5 rounded-full bg-destructive" />
                5 critical
              </Badge>
            </div>
            <Button variant="ghost" size="sm" asChild className="h-7 text-xs text-muted-foreground hover:text-foreground">
              <Link to="/analyze">Review specimens</Link>
            </Button>
          </div>
          <p className="px-5 pb-3 text-sm text-muted-foreground">
            Sectors exceeding foliar damage thresholds, prioritized by pathogen severity. <span className="font-mono text-foreground font-semibold tabular-nums">$1,983/ha</span> average economic harvest exposure.
          </p>

          <ul className="flex flex-col border-t border-border/60 divide-y divide-border/60">
            {ATTENTION_ITEMS.map((item) => (
              <li key={item.id} className="flex items-center gap-3.5 px-5 py-3 hover:bg-muted/30 transition-colors">
                <Avatar className="size-9 rounded-lg border border-border shrink-0">
                  <AvatarImage src={item.image} alt={item.plot} className="object-cover" />
                  <AvatarFallback className="font-mono text-[10px] bg-muted">
                    {item.disease.slice(0, 2).toUpperCase()}
                  </AvatarFallback>
                </Avatar>

                <div className="flex min-w-0 flex-1 flex-col">
                  <span className="truncate text-sm font-medium text-foreground">
                    {item.plot} &bull; {item.disease}
                  </span>
                  <span className="truncate text-xs text-muted-foreground font-serif italic">
                    <span className="text-foreground/80 font-sans not-italic font-medium">{item.scout}</span> &bull; {item.cultivar} &bull; {item.pathogen}
                  </span>
                </div>

                <div className="hidden lg:block">
                  <Badge variant="outline" className={`gap-1.5 text-xs font-medium border-transparent ${
                    item.status.includes('Critical')
                      ? 'bg-destructive/10 text-destructive'
                      : 'bg-amber-500/10 text-amber-700'
                  }`}>
                    <span className={`size-1.5 rounded-full ${
                      item.status.includes('Critical') ? 'bg-destructive' : 'bg-amber-500'
                    }`} />
                    {item.status}
                  </Badge>
                </div>

                <div className="hidden w-24 text-end font-mono text-sm tabular-nums md:block">
                  <span className="text-destructive font-bold">{item.severity}</span>
                  <span className="text-muted-foreground">{item.threshold}</span>
                </div>

                <Button
                  variant="outline"
                  size="sm"
                  asChild
                  className="w-28 shrink-0 h-7 text-xs font-medium border-border hover:bg-muted"
                >
                  <Link to="/analyze">
                    {item.action}
                  </Link>
                </Button>
              </li>
            ))}
          </ul>
        </Card>

        {/* Right: Diurnal Spore Activity Heatmap (1 col) */}
        <Card className="rounded-2xl border border-border/60 shadow-xs bg-card p-5 flex flex-col justify-between">
          <div className="flex items-start justify-between gap-2">
            <div className="flex items-center gap-2 text-sm font-medium text-foreground">
              <Layers className="size-4 text-[#0D5C46]" />
              <span>Diurnal Pathogen Spore Activity</span>
            </div>
          </div>

          <div className="flex flex-col gap-1 pt-2">
            <span className="font-mono font-semibold tracking-tight tabular-nums text-3xl text-foreground">
              119.3K
            </span>
            <span className="font-mono text-xs text-muted-foreground tabular-nums">
              spore germinability index, week of 12 Nov
            </span>
          </div>

          {/* Heatmap Grid Matrix */}
          <div className="w-full pt-4">
            <div className="text-[10px] font-mono text-muted-foreground mb-1.5 flex justify-between px-7">
              <span>12a</span>
              <span>6a</span>
              <span>12p</span>
              <span>6p</span>
              <span>10p</span>
            </div>

            <div className="space-y-1.5">
              {DAYS.map((day, dIdx) => (
                <div key={day} className="flex items-center gap-2 text-xs">
                  <span className="w-6 font-mono text-[10px] text-muted-foreground shrink-0">{day}</span>
                  <div className="grid grid-cols-12 gap-1 flex-1">
                    {HEATMAP_GRID[dIdx].map((val, tIdx) => {
                      const bgClasses = [
                        'bg-slate-100 dark:bg-slate-800',
                        'bg-emerald-100/60 dark:bg-emerald-950/40',
                        'bg-emerald-200/80 dark:bg-emerald-900/60',
                        'bg-emerald-400 dark:bg-emerald-700',
                        'bg-emerald-600 dark:bg-emerald-600',
                        'bg-[#0D5C46] dark:bg-emerald-500' // Peak
                      ];
                      return (
                        <div
                          key={tIdx}
                          className={`h-4 rounded-[3px] transition-colors ${bgClasses[val]}`}
                          title={`${day} ${TIME_BLOCKS[tIdx]}: Activity level ${val}/5`}
                        />
                      );
                    })}
                  </div>
                </div>
              ))}
            </div>

            <div className="flex items-center justify-between text-[10px] font-mono text-muted-foreground pt-3 border-t border-border/40 mt-3">
              <span>Low Moisture Risk</span>
              <div className="flex items-center gap-1">
                <span className="size-2 rounded-[2px] bg-slate-100 border border-slate-200" />
                <span className="size-2 rounded-[2px] bg-emerald-200" />
                <span className="size-2 rounded-[2px] bg-emerald-400" />
                <span className="size-2 rounded-[2px] bg-emerald-600" />
                <span className="size-2 rounded-[2px] bg-[#0D5C46]" />
              </div>
              <span className="text-[#0D5C46] font-semibold">High Spore Risk</span>
            </div>
          </div>
        </Card>
      </div>

      {/* ROW 4: Solana Devnet Blockchain Passports Ledger (Chronicle Style) */}
      <Card className="rounded-2xl border border-border/60 shadow-xs bg-card overflow-hidden">
        <div className="flex items-center justify-between p-5 pb-3 border-b border-border/60">
          <div className="flex items-center gap-3">
            <div className="size-8 rounded-lg bg-[#0D5C46] text-white flex items-center justify-center font-mono font-bold text-xs">
              SOL
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h3 className="text-sm font-semibold text-foreground">
                  Solana Devnet Specimen Passports
                </h3>
                <Badge variant="outline" className="font-mono text-[10px] border-emerald-500/30 text-emerald-800 bg-emerald-50">
                  SPL Memo v2
                </Badge>
              </div>
              <p className="text-xs text-muted-foreground">
                Cryptographically anchored foliar proof-of-diagnosis ledger for phytosanitary export validation
              </p>
            </div>
          </div>

          <Button variant="ghost" size="sm" asChild className="h-7 text-xs text-muted-foreground hover:text-foreground">
            <Link to="/analyze" className="gap-1">
              <span>View all passports</span>
              <ChevronRight className="size-3.5" />
            </Link>
          </Button>
        </div>

        <div className="p-5 grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="p-4 rounded-xl border border-border bg-muted/20 space-y-1">
            <span className="text-[10px] font-mono text-muted-foreground uppercase">Authority Devnet Wallet</span>
            <div className="font-mono text-xs font-semibold text-foreground truncate select-all">
              CM7QUSZCrD2XNNYThFFwNbXhf8jymFbFq9QRFh56cy5R
            </div>
            <span className="text-[11px] text-emerald-700 font-mono font-medium block">
              Balance: 3.826 SOL &bull; Consensus Ready
            </span>
          </div>

          <div className="p-4 rounded-xl border border-border bg-muted/20 space-y-1">
            <span className="text-[10px] font-mono text-muted-foreground uppercase">Latest Confirmed Signature</span>
            <div className="font-mono text-xs font-semibold text-foreground truncate select-all">
              9L7aJHM592fuHkRdqGTmJ6irbMpCVzrK798fjAc4Fk2z3ds...
            </div>
            <a
              href="https://explorer.solana.com/tx/9L7aJHM592fuHkRdqGTmJ6irbMpCVzrK798fjAc4Fk2z3ds1rdLTtaWiS1s3LdmDYN4F2cgZArTvp6wnfEEVLY6?cluster=devnet"
              target="_blank"
              rel="noopener noreferrer"
              className="text-[11px] text-[#0D5C46] hover:underline font-medium inline-flex items-center gap-1"
            >
              <span>Inspect on Solana Explorer</span>
              <ExternalLink className="size-3" />
            </a>
          </div>

          <div className="p-4 rounded-xl border border-border bg-muted/20 space-y-1">
            <span className="text-[10px] font-mono text-muted-foreground uppercase">Smart Program Binding</span>
            <div className="font-mono text-xs font-semibold text-foreground truncate select-all">
              MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr
            </div>
            <span className="text-[11px] text-muted-foreground font-mono block">
              Tx Cost: ~0.000005 SOL &bull; Finalized &lt;1.5s
            </span>
          </div>
        </div>
      </Card>
    </div>
  );
}
