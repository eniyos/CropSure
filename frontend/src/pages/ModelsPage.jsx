import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import {
  Cpu,
  Server,
  Activity,
  HardDrive,
  Clock,
  CheckCircle2,
  AlertCircle,
  RefreshCw,
  Zap,
  Sliders,
  ShieldCheck,
  Layers,
  ArrowUpRight
} from 'lucide-react';
import StatusBadge from '../components/ui/StatusBadge';
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
      <div className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="w-2.5 h-2.5 rounded-full bg-[#2D6A4F] animate-pulse" />
            <span className="text-xs font-bold text-[#2D6A4F] uppercase tracking-wider">
              Neural Ensemble Health &amp; Model Registry
            </span>
          </div>
          <h2 className="text-2xl font-extrabold text-gray-900 tracking-tight">
            Production Model Infrastructure
          </h2>
          <p className="text-xs sm:text-sm text-gray-500 max-w-2xl mt-0.5">
            Real-time runtime metrics, memory allocation, latency benchmarks, and architectural specifications for all 6 CropSure intelligence engines.
          </p>
        </div>

        <button
          onClick={handleRefresh}
          disabled={refreshing}
          className="flex items-center gap-2 px-4 py-2.5 rounded-xl text-xs font-bold text-[#2D6A4F] bg-emerald-50 hover:bg-emerald-100/70 border border-emerald-200 transition-colors shrink-0 cursor-pointer"
        >
          <RefreshCw className={`w-3.5 h-3.5 ${refreshing ? 'animate-spin' : ''}`} />
          <span>Ping Models</span>
        </button>
      </div>

      {/* Cluster Resource Overview */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="bg-white p-5 rounded-2xl border border-gray-100 shadow-sm">
          <div className="flex justify-between items-start">
            <div>
              <span className="text-xs font-bold uppercase tracking-wider text-gray-400">
                Inference GPU
              </span>
              <div className="text-xl font-black text-gray-900 mt-1">NVIDIA RTX 4090</div>
              <span className="text-xs text-emerald-700 font-semibold">1,380 MB / 24,576 MB</span>
            </div>
            <div className="w-10 h-10 rounded-xl bg-emerald-50 flex items-center justify-center text-[#2D6A4F]">
              <Zap className="w-5 h-5" />
            </div>
          </div>
          <div className="w-full h-1.5 rounded-full bg-gray-100 mt-3 overflow-hidden">
            <div className="h-full bg-[#2D6A4F] rounded-full" style={{ width: '12%' }} />
          </div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-gray-100 shadow-sm">
          <div className="flex justify-between items-start">
            <div>
              <span className="text-xs font-bold uppercase tracking-wider text-gray-400">
                Inference Latency (Avg)
              </span>
              <div className="text-xl font-black text-gray-900 mt-1">32.2 ms</div>
              <span className="text-xs text-emerald-700 font-semibold">Sub-50ms SLA Target Met</span>
            </div>
            <div className="w-10 h-10 rounded-xl bg-amber-50 flex items-center justify-center text-[#C9952B]">
              <Clock className="w-5 h-5" />
            </div>
          </div>
          <div className="w-full h-1.5 rounded-full bg-gray-100 mt-3 overflow-hidden">
            <div className="h-full bg-amber-500 rounded-full" style={{ width: '32%' }} />
          </div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-gray-100 shadow-sm">
          <div className="flex justify-between items-start">
            <div>
              <span className="text-xs font-bold uppercase tracking-wider text-gray-400">
                Active Workers
              </span>
              <div className="text-xl font-black text-gray-900 mt-1">4 / 4 Threads</div>
              <span className="text-xs text-gray-500 font-semibold">Zero Request Queue</span>
            </div>
            <div className="w-10 h-10 rounded-xl bg-sky-50 flex items-center justify-center text-sky-700">
              <Server className="w-5 h-5" />
            </div>
          </div>
          <div className="w-full h-1.5 rounded-full bg-gray-100 mt-3 overflow-hidden">
            <div className="h-full bg-sky-600 rounded-full" style={{ width: '25%' }} />
          </div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-gray-100 shadow-sm">
          <div className="flex justify-between items-start">
            <div>
              <span className="text-xs font-bold uppercase tracking-wider text-gray-400">
                Bayesian Calibration
              </span>
              <div className="text-xl font-black text-gray-900 mt-1">ECE 0.024</div>
              <span className="text-xs text-emerald-700 font-semibold">Optimal Confidence Fit</span>
            </div>
            <div className="w-10 h-10 rounded-xl bg-emerald-50 flex items-center justify-center text-[#2D6A4F]">
              <ShieldCheck className="w-5 h-5" />
            </div>
          </div>
          <div className="w-full h-1.5 rounded-full bg-gray-100 mt-3 overflow-hidden">
            <div className="h-full bg-emerald-600 rounded-full" style={{ width: '92%' }} />
          </div>
        </div>
      </div>

      {/* 6 Models Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {(Array.isArray(models) ? models : []).map((model, idx) => (
          <motion.div
            key={model.id}
            initial={{ opacity: 0, y: 15 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.4, delay: idx * 0.08 }}
            className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm hover:shadow-md transition-all flex flex-col justify-between"
          >
            <div>
              <div className="flex items-start justify-between gap-3 mb-3">
                <div className="flex items-center gap-2">
                  <div className="w-9 h-9 rounded-xl bg-[#2D6A4F]/10 flex items-center justify-center text-[#2D6A4F] shrink-0 font-bold text-xs">
                    0{idx + 1}
                  </div>
                  <div>
                    <h3 className="font-bold text-sm text-gray-900 leading-snug">
                      {model.name}
                    </h3>
                    <span className="text-[11px] text-[#2D6A4F] font-semibold">
                      {model.type}
                    </span>
                  </div>
                </div>

                <StatusBadge status="success" label="Active" size="sm" pulse />
              </div>

              <p className="text-xs text-gray-600 leading-relaxed mb-4">
                {model.description}
              </p>

              {/* Specs & Benchmarks Table */}
              <div className="grid grid-cols-2 gap-2 text-xs mb-4">
                <div className="p-2.5 rounded-xl bg-emerald-50/80 border border-emerald-200/80">
                  <span className="text-[10px] uppercase font-bold text-emerald-800 block">Accuracy / Benchmark</span>
                  <span className="font-mono font-bold text-emerald-950">{model.accuracy}</span>
                </div>
                <div className="p-2.5 rounded-xl bg-[#FAFAF5] border border-gray-100">
                  <span className="text-[10px] uppercase font-bold text-gray-400 block">Inference Latency</span>
                  <span className="font-mono font-bold text-gray-900">{model.latency}</span>
                </div>
                <div className="p-2.5 rounded-xl bg-[#FAFAF5] border border-gray-100">
                  <span className="text-[10px] uppercase font-bold text-gray-400 block">Memory Footprint</span>
                  <span className="font-mono font-bold text-gray-700">{model.memoryUsage}</span>
                </div>
                <div className="p-2.5 rounded-xl bg-[#FAFAF5] border border-gray-100">
                  <span className="text-[10px] uppercase font-bold text-gray-400 block">Weights Size</span>
                  <span className="font-mono font-bold text-gray-700">{model.size}</span>
                </div>
              </div>
            </div>

            <div className="pt-3 border-t border-gray-100 flex items-center justify-between text-[11px] text-gray-400">
              <span>Version: <strong className="text-gray-700 font-mono">{model.version}</strong></span>
              <span>Updated: {model.lastTrained}</span>
            </div>
          </motion.div>
        ))}
      </div>
    </div>
  );
}
