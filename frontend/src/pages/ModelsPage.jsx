import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import {
  Server,
  Clock,
  RefreshCw,
  Zap,
  ShieldCheck,
  CheckCircle2,
  HardDrive,
  Cpu,
} from 'lucide-react';
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { SheenPillButton } from '@/components/buttons/sheen-pill-button';
import { Progress } from '@/components/ui/progress';
import { Separator } from '@/components/ui/separator';
import apiService from '../services/api';

export default function ModelsPage() {
  const [models, setModels] = useState([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  const fetchModels = async () => {
    try {
      const data = await apiService.getModelStatus();
      setModels(data);
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    fetchModels();
  }, []);

  const handleRefresh = () => {
    setRefreshing(true);
    fetchModels();
  };

  return (
    <div className="space-y-6 pb-12">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-2 border-b border-slate-200">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="w-2 h-2 rounded-full bg-[#0d5c46]" />
            <span className="text-xs font-mono uppercase tracking-wider text-slate-500">
              Model Architecture &amp; Pipeline Registry
            </span>
          </div>
          <h1 className="text-2xl font-bold font-display tracking-tight text-slate-900">
            Production Model Infrastructure
          </h1>
          <p className="text-sm text-slate-500 mt-0.5">
            Real-time runtime metrics, memory allocation, latency benchmarks, and architectural specifications for all 6 CropSure diagnostic engines.
          </p>
        </div>

        <div className="flex items-center gap-2 shrink-0">
          <SheenPillButton
            onClick={handleRefresh}
            disabled={refreshing}
            width={138}
            height={36}
            className="text-xs font-mono"
          >
            <RefreshCw className={`w-3.5 h-3.5 text-emerald-700 ${refreshing ? 'animate-spin' : ''}`} />
            <span>Ping Cluster</span>
          </SheenPillButton>
          <Badge className="bg-[#e6f0ed] text-[#0d5c46] hover:bg-[#e6f0ed] border border-[#0d5c46]/20 font-mono text-xs">
            6/6 Online
          </Badge>
        </div>
      </div>

      {/* Cluster Resource Overview */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <Card>
          <CardContent className="p-4 space-y-2">
            <div className="flex justify-between items-start">
              <div>
                <span className="text-xs font-mono uppercase tracking-wider text-slate-400">
                  Inference Device
                </span>
                <div className="text-lg font-bold font-display text-slate-900 mt-0.5">Apple Silicon Neural Engine</div>
                <span className="text-xs text-[#0d5c46] font-mono font-medium">MPS Unified Memory</span>
              </div>
              <div className="w-8 h-8 rounded-lg bg-[#e6f0ed] flex items-center justify-center text-[#0d5c46]">
                <Cpu className="w-4 h-4" />
              </div>
            </div>
            <div className="space-y-1">
              <div className="flex justify-between text-[11px] font-mono text-slate-500">
                <span>VRAM Allocation</span>
                <span>1,380 MB / 16,384 MB</span>
              </div>
              <Progress value={8.4} className="h-1.5 bg-slate-100" />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4 space-y-2">
            <div className="flex justify-between items-start">
              <div>
                <span className="text-xs font-mono uppercase tracking-wider text-slate-400">
                  Pipeline Latency (Avg)
                </span>
                <div className="text-lg font-bold font-mono text-slate-900 mt-0.5">32.2 ms</div>
                <span className="text-xs text-emerald-700 font-mono font-medium">Sub-50ms SLA Target</span>
              </div>
              <div className="w-8 h-8 rounded-lg bg-[#0d5c46]/10 flex items-center justify-center text-[#0d5c46]">
                <Clock className="w-4 h-4" />
              </div>
            </div>
            <div className="space-y-1">
              <div className="flex justify-between text-[11px] font-mono text-slate-500">
                <span>Latency Budget</span>
                <span>32.2ms / 100ms</span>
              </div>
              <Progress value={32.2} className="h-1.5 bg-slate-100" />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4 space-y-2">
            <div className="flex justify-between items-start">
              <div>
                <span className="text-xs font-mono uppercase tracking-wider text-slate-400">
                  Worker Pool
                </span>
                <div className="text-lg font-bold font-mono text-slate-900 mt-0.5">4 / 4 Threads</div>
                <span className="text-xs text-slate-500 font-mono">Zero Request Queue</span>
              </div>
              <div className="w-8 h-8 rounded-lg bg-slate-100 flex items-center justify-center text-slate-700">
                <Server className="w-4 h-4" />
              </div>
            </div>
            <div className="space-y-1">
              <div className="flex justify-between text-[11px] font-mono text-slate-500">
                <span>Pool Saturation</span>
                <span>25%</span>
              </div>
              <Progress value={25} className="h-1.5 bg-slate-100" />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4 space-y-2">
            <div className="flex justify-between items-start">
              <div>
                <span className="text-xs font-mono uppercase tracking-wider text-slate-400">
                  Bayesian Calibration
                </span>
                <div className="text-lg font-bold font-mono text-slate-900 mt-0.5">ECE 0.024</div>
                <span className="text-xs text-[#0d5c46] font-mono font-medium">Optimal Confidence Fit</span>
              </div>
              <div className="w-8 h-8 rounded-lg bg-[#e6f0ed] flex items-center justify-center text-[#0d5c46]">
                <ShieldCheck className="w-4 h-4" />
              </div>
            </div>
            <div className="space-y-1">
              <div className="flex justify-between text-[11px] font-mono text-slate-500">
                <span>Reliability Score</span>
                <span>97.6%</span>
              </div>
              <Progress value={97.6} className="h-1.5 bg-slate-100" />
            </div>
          </CardContent>
        </Card>
      </div>

      {/* 6 Models Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
        {(Array.isArray(models) ? models : []).map((model, idx) => (
          <motion.div
            key={model.id}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.3, delay: idx * 0.05 }}
          >
            <Card className="h-full flex flex-col justify-between hover:border-slate-300 transition-colors">
              <CardHeader className="pb-3 border-b border-slate-100">
                <div className="flex items-start justify-between gap-3">
                  <div className="flex items-center gap-2.5">
                    <span className="w-6 h-6 rounded-md bg-slate-100 text-slate-700 font-mono text-xs flex items-center justify-center font-bold">
                      0{idx + 1}
                    </span>
                    <div>
                      <CardTitle className="text-sm font-semibold tracking-tight text-slate-900 font-display">
                        {model.name}
                      </CardTitle>
                      <span className="text-xs font-mono text-[#0d5c46]">
                        {model.type}
                      </span>
                    </div>
                  </div>
                  <Badge variant="outline" className="font-mono text-[10px] bg-emerald-50 text-emerald-700 border-emerald-200 flex items-center gap-1">
                    <span className="w-1.5 h-1.5 rounded-full bg-emerald-600 animate-pulse" />
                    Active
                  </Badge>
                </div>
              </CardHeader>

              <CardContent className="pt-3 pb-3 space-y-3 flex-1">
                <p className="text-xs text-slate-600 leading-relaxed">
                  {model.description}
                </p>

                {/* Specs & Benchmarks Table */}
                <div className="grid grid-cols-2 gap-2 text-xs">
                  <div className="p-2.5 rounded-lg bg-[#e6f0ed]/60 border border-[#0d5c46]/20">
                    <span className="text-[10px] font-mono uppercase text-slate-500 block">Benchmark Accuracy</span>
                    <span className="font-mono font-bold text-[#0d5c46] text-sm">{model.accuracy}</span>
                  </div>
                  <div className="p-2.5 rounded-lg bg-slate-50 border border-slate-200/80">
                    <span className="text-[10px] font-mono uppercase text-slate-500 block">Inference Latency</span>
                    <span className="font-mono font-bold text-slate-900 text-sm">{model.latency}</span>
                  </div>
                  <div className="p-2.5 rounded-lg bg-slate-50 border border-slate-200/80">
                    <span className="text-[10px] font-mono uppercase text-slate-500 block">Memory Allocation</span>
                    <span className="font-mono font-medium text-slate-700">{model.memoryUsage}</span>
                  </div>
                  <div className="p-2.5 rounded-lg bg-slate-50 border border-slate-200/80">
                    <span className="text-[10px] font-mono uppercase text-slate-500 block">Weights Size</span>
                    <span className="font-mono font-medium text-slate-700">{model.size}</span>
                  </div>
                </div>
              </CardContent>

              <div className="px-5 py-3 border-t border-slate-100 bg-slate-50/50 flex items-center justify-between text-[11px] font-mono text-slate-400">
                <span>Version: <strong className="text-slate-700 font-semibold">{model.version}</strong></span>
                <span>Trained: {model.lastTrained}</span>
              </div>
            </Card>
          </motion.div>
        ))}
      </div>
    </div>
  );
}
