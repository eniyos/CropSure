import React from 'react';
import { motion } from 'framer-motion';
import {
  Sprout,
  ShieldCheck,
  Cpu,
  Layers,
  ArrowRight,
  Database,
  ExternalLink,
  BookOpen,
  Award,
  FlaskConical,
  LineChart,
  Binary,
  Code2
} from 'lucide-react';
import { Button } from '@/components/ui/button';

const TECH_STACK = [
  { category: 'Diagnostic Vision & Localization', techs: ['PyTorch 2.5', 'EfficientNet-B4', 'Grad-CAM', 'Torchvision', 'Scikit-learn'] },
  { category: 'Epidemiology & Forecasters', techs: ['Van der Plank ODEs', 'SciPy Integrate', 'BiLSTM Networks', 'XGBoost'] },
  { category: 'Frontend Engineering', techs: ['React 19', 'Vite 6', 'Tailwind CSS v4', 'Recharts', 'Framer Motion', 'Lucide React'] },
  { category: 'Backend & Inference Telemetry', techs: ['FastAPI / Flask', 'NumPy', 'OpenCV CLAHE', 'Pandas', 'Bayesian ECE Calibration'] },
];

const ARCH_LAYERS = [
  {
    step: '01',
    title: 'Foliar Specimen Ingestion',
    desc: 'High-resolution RGB leaf imagery ingested via dropzone; normalized and augmented with OpenCV CLAHE color correction.',
    icon: Sprout,
    tag: 'Input Stage'
  },
  {
    step: '02',
    title: 'Deep Feature Extraction',
    desc: 'EfficientNet-B4 extracts compound multi-scale feature maps from convolutional blocks 5 through 7.',
    icon: Cpu,
    tag: 'CNN Backbone'
  },
  {
    step: '03',
    title: 'Grad-CAM Attention Mapping',
    desc: 'Backward propagation of gradients with respect to target class produces pixel-level spatial activation heatmaps.',
    icon: Layers,
    tag: 'Explainability'
  },
  {
    step: '04',
    title: 'Epidemic Dynamics ODE',
    desc: 'Van der Plank non-linear logistic differential equations calculate apparent infection rate (r) conditioned on microclimate.',
    icon: FlaskConical,
    tag: 'Mathematical ODE'
  },
  {
    step: '05',
    title: 'Bayesian Trust Calibrator',
    desc: 'Aggregates 12 biometric and morphological signals with Expected Calibration Error (ECE < 0.03) to detect out-of-distribution leaf inputs.',
    icon: ShieldCheck,
    tag: 'Verification Guard'
  }
];

export default function AboutPage() {
  return (
    <div className="space-y-8 pb-12">
      {/* Hero Description */}
      <div className="bg-white rounded-2xl p-6 sm:p-8 border border-slate-200/80 shadow-xs relative overflow-hidden">
        <div className="max-w-3xl">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-slate-100 text-slate-700 text-xs font-semibold mb-3 border border-slate-200/80">
            <Sprout className="w-3.5 h-3.5 text-[#0d5c46]" />
            <span>Precision Pathology &amp; Epidemiological Modeling</span>
          </div>
          <h2 className="text-2xl sm:text-3xl font-bold font-display text-slate-900 tracking-tight mb-3">
            About CropSure Intelligence Platform
          </h2>
          <p className="text-sm sm:text-base text-slate-600 leading-relaxed">
            CropSure is an end-to-end precision agriculture intelligence framework engineered to bridge modern deep computer vision, explainable artificial intelligence (XAI), and classic Van der Plank epidemiological disease dynamics for tomato and Solanaceae crops.
          </p>
          <p className="text-sm sm:text-base text-slate-600 leading-relaxed mt-2">
            By fusing convolutional saliency localization with microclimate telemetry, CropSure empowers agronomists and commercial growers to detect disease early, verify diagnostic rationale visually, and simulate chemical intervention trajectories before irreversible harvest yield loss occurs.
          </p>
        </div>
      </div>

      {/* Styled Architecture Diagram */}
      <div className="bg-white rounded-2xl p-6 sm:p-8 border border-slate-200/80 shadow-xs">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h3 className="text-lg font-bold font-display text-slate-900 tracking-tight">
              Diagnostic Architecture &amp; Mathematical Models
            </h3>
            <p className="text-xs text-slate-500">
              Synchronized dataflow across computer vision, physics-informed dynamics, and trust evaluation
            </p>
          </div>
          <span className="px-2.5 py-1 rounded-full bg-[#0d5c46]/10 text-[#0d5c46] text-xs font-mono font-medium border border-[#0d5c46]/20">
            5 Sequential Engines
          </span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-5 gap-4 relative">
          {ARCH_LAYERS.map((layer, idx) => {
            const Icon = layer.icon;
            return (
              <div
                key={layer.step}
                className="bg-slate-50/60 rounded-xl p-4 border border-slate-200/80 flex flex-col justify-between relative group hover:border-[#0d5c46] hover:bg-white hover:shadow-xs transition-all"
              >
                <div>
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-xs font-mono font-bold text-[#0d5c46]">
                      {layer.step}
                    </span>
                    <span className="text-[10px] uppercase font-bold text-slate-400 bg-white px-2 py-0.5 rounded border border-slate-200">
                      {layer.tag}
                    </span>
                  </div>

                  <div className="w-10 h-10 rounded-xl bg-white border border-slate-200 flex items-center justify-center text-[#0d5c46] mb-3 group-hover:scale-105 transition-transform shadow-xs">
                    <Icon className="w-5 h-5" />
                  </div>

                  <h4 className="text-xs font-bold text-slate-900 mb-1 leading-snug">
                    {layer.title}
                  </h4>
                  <p className="text-[11px] text-slate-600 leading-relaxed">
                    {layer.desc}
                  </p>
                </div>

                {idx < ARCH_LAYERS.length - 1 && (
                  <div className="hidden md:flex absolute -right-3 top-1/2 -translate-y-1/2 z-10 w-6 h-6 rounded-full bg-white border border-slate-200 items-center justify-center text-slate-400 shadow-xs">
                    <ArrowRight className="w-3 h-3" />
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </div>

      {/* Technology Stack Grid */}
      <div className="bg-white rounded-2xl p-6 sm:p-8 border border-slate-200/80 shadow-xs">
        <h3 className="text-lg font-bold font-display text-slate-900 tracking-tight mb-2">
          Enterprise Technology Stack
        </h3>
        <p className="text-xs text-slate-500 mb-6">
          Built with performant modern web technologies and industrial machine learning toolchains
        </p>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {TECH_STACK.map((cat, idx) => (
            <div key={idx} className="p-4 rounded-xl bg-slate-50/60 border border-slate-200/80">
              <span className="text-xs font-bold text-slate-900 uppercase tracking-wider block mb-3 border-b border-slate-200 pb-2">
                {cat.category}
              </span>
              <ul className="space-y-2">
                {cat.techs.map((t, i) => (
                  <li key={i} className="flex items-center gap-2 text-xs text-slate-700">
                    <span className="w-1.5 h-1.5 rounded-full bg-[#0d5c46]" />
                    <span className="font-medium">{t}</span>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
      </div>

      {/* Team / Research Station Credits & Documentation Links */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-2xl p-6 border border-slate-200/80 shadow-xs">
          <div className="flex items-center gap-2 mb-3">
            <Award className="w-5 h-5 text-[#0d5c46]" />
            <h3 className="text-base font-bold text-slate-900 tracking-tight">
              Agronomic Research &amp; Dataset Validation
            </h3>
          </div>
          <p className="text-xs text-slate-600 leading-relaxed mb-4">
            CropSure models are benchmarked against the PlantVillage public foliar database, extended with verified field imagery from greenhouse hydroponic stations and regional horticulture extension centers.
          </p>
          <div className="p-3 rounded-xl bg-slate-50 border border-slate-200/80 text-xs text-slate-700 flex items-center justify-between">
            <span>Validation Dataset: <strong className="text-slate-900 font-semibold">54,305 high-res leaves</strong></span>
            <span className="font-mono font-bold text-[#0d5c46]">8 classes</span>
          </div>
        </div>

        <div className="bg-white rounded-2xl p-6 border border-slate-200/80 shadow-xs flex flex-col justify-between">
          <div>
            <div className="flex items-center gap-2 mb-3">
              <BookOpen className="w-5 h-5 text-[#0d5c46]" />
              <h3 className="text-base font-bold text-slate-900 tracking-tight">
                Developer &amp; Agronomist Documentation
              </h3>
            </div>
            <p className="text-xs text-slate-600 leading-relaxed mb-4">
              Explore the REST API endpoints, model weights registry, and Van der Plank parameter derivation notebooks.
            </p>
          </div>

          <div className="flex flex-wrap gap-2 text-xs">
            <Button
              asChild
              variant="outline"
              size="sm"
              effect="lift"
              className="bg-slate-100 hover:bg-slate-200 text-slate-800 font-semibold"
            >
              <a
                href="http://localhost:5005/api/health"
                target="_blank"
                rel="noreferrer"
              >
                <span>API Health Endpoint</span>
                <ExternalLink className="w-3.5 h-3.5 ml-1.5" />
              </a>
            </Button>
            <Button
              asChild
              size="sm"
              effect="shimmer"
              className="bg-[#0d5c46] hover:bg-[#0a4837] text-white font-semibold shadow-xs"
            >
              <a
                href="http://localhost:5005/docs"
                target="_blank"
                rel="noreferrer"
              >
                <span>FastAPI Swagger Docs</span>
                <ExternalLink className="w-3.5 h-3.5 ml-1.5" />
              </a>
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}
