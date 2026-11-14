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

const TECH_STACK = [
  { category: 'Deep Learning & Vision', techs: ['PyTorch 2.5', 'EfficientNet-B4', 'Grad-CAM', 'Torchvision', 'Scikit-learn'] },
  { category: 'Epidemiology & Forecasters', techs: ['Van der Plank ODEs', 'SciPy Integrate', 'LSTM Recurrent Networks', 'XGBoost'] },
  { category: 'Frontend Engineering', techs: ['React 19', 'Vite 6', 'Tailwind CSS v4', 'Recharts', 'Framer Motion', 'Lucide React'] },
  { category: 'Backend & Inference', techs: ['FastAPI / Flask', 'NumPy', 'OpenCV', 'Pandas', 'Bayesian ECE Calibration'] },
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
    tag: 'Explainability (XAI)'
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
      <div className="bg-white rounded-2xl p-6 sm:p-8 border border-gray-100 shadow-sm relative overflow-hidden">
        <div className="max-w-3xl">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-emerald-50 text-[#2D6A4F] text-xs font-bold mb-3 border border-emerald-100">
            <Sprout className="w-3.5 h-3.5" />
            <span>Autonomous Agricultural AI Intelligence</span>
          </div>
          <h2 className="text-3xl font-extrabold text-gray-900 tracking-tight mb-3">
            About CropSure Intelligence Platform
          </h2>
          <p className="text-sm sm:text-base text-gray-600 leading-relaxed">
            CropSure is an end-to-end precision agriculture intelligence framework engineered to bridge modern deep computer vision, explainable artificial intelligence (XAI), and classic Van der Plank epidemiological disease dynamics for tomato and Solanaceae crops.
          </p>
          <p className="text-sm sm:text-base text-gray-600 leading-relaxed mt-2">
            By fusing convolutional saliency localization with microclimate telemetry, CropSure empowers agronomists and commercial growers to detect disease early, verify AI rationale visually, and simulate chemical intervention trajectories before irreversible harvest yield loss occurs.
          </p>
        </div>
      </div>

      {/* Styled Architecture Diagram */}
      <div className="bg-white rounded-2xl p-6 sm:p-8 border border-gray-100 shadow-sm">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h3 className="text-lg font-bold text-gray-900 tracking-tight">
              Multi-Stage Neural Architecture Pipeline
            </h3>
            <p className="text-xs text-gray-500">
              Synchronized dataflow across computer vision, physics-informed dynamics, and trust evaluation
            </p>
          </div>
          <span className="px-2.5 py-1 rounded-full bg-[#D4A843]/15 text-[#C9952B] text-xs font-bold border border-[#D4A843]/30">
            5 Sequential Engines
          </span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-5 gap-4 relative">
          {ARCH_LAYERS.map((layer, idx) => {
            const Icon = layer.icon;
            return (
              <div
                key={layer.step}
                className="bg-[#FAFAF5] rounded-xl p-4 border border-gray-200/80 flex flex-col justify-between relative group hover:border-[#2D6A4F] hover:shadow-sm transition-all"
              >
                <div>
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-xs font-black font-mono text-[#2D6A4F]">
                      {layer.step}
                    </span>
                    <span className="text-[10px] uppercase font-bold text-gray-400 bg-white px-2 py-0.5 rounded border border-gray-200">
                      {layer.tag}
                    </span>
                  </div>

                  <div className="w-10 h-10 rounded-xl bg-white border border-gray-200 flex items-center justify-center text-[#2D6A4F] mb-3 group-hover:scale-105 transition-transform shadow-xs">
                    <Icon className="w-5 h-5" />
                  </div>

                  <h4 className="text-xs font-bold text-gray-900 mb-1 leading-snug">
                    {layer.title}
                  </h4>
                  <p className="text-[11px] text-gray-600 leading-relaxed">
                    {layer.desc}
                  </p>
                </div>

                {idx < ARCH_LAYERS.length - 1 && (
                  <div className="hidden md:flex absolute -right-3 top-1/2 -translate-y-1/2 z-10 w-6 h-6 rounded-full bg-white border border-gray-200 items-center justify-center text-gray-400 shadow-xs">
                    <ArrowRight className="w-3 h-3" />
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </div>

      {/* Technology Stack Grid */}
      <div className="bg-white rounded-2xl p-6 sm:p-8 border border-gray-100 shadow-sm">
        <h3 className="text-lg font-bold text-gray-900 tracking-tight mb-2">
          Enterprise Technology Stack
        </h3>
        <p className="text-xs text-gray-500 mb-6">
          Built with performant modern web technologies and industrial machine learning toolchains
        </p>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {TECH_STACK.map((cat, idx) => (
            <div key={idx} className="p-4 rounded-xl bg-[#FAFAF5] border border-gray-100">
              <span className="text-xs font-bold text-gray-900 uppercase tracking-wider block mb-3 border-b border-gray-200 pb-2">
                {cat.category}
              </span>
              <ul className="space-y-2">
                {cat.techs.map((t, i) => (
                  <li key={i} className="flex items-center gap-2 text-xs text-gray-700">
                    <span className="w-1.5 h-1.5 rounded-full bg-[#2D6A4F]" />
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
        <div className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm">
          <div className="flex items-center gap-2 mb-3">
            <Award className="w-5 h-5 text-[#D4A843]" />
            <h3 className="text-base font-bold text-gray-900 tracking-tight">
              Agronomic Research &amp; Dataset Validation
            </h3>
          </div>
          <p className="text-xs text-gray-600 leading-relaxed mb-4">
            CropSure models are benchmarked against the PlantVillage public foliar database, extended with verified field imagery from greenhouse hydroponic stations and regional horticulture extension centers.
          </p>
          <div className="p-3 rounded-xl bg-emerald-50 border border-emerald-100 text-xs text-[#1B4332] flex items-center justify-between">
            <span>Validation Dataset: <strong>54,305 high-res leaves</strong></span>
            <span className="font-mono font-bold">8 classes</span>
          </div>
        </div>

        <div className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm flex flex-col justify-between">
          <div>
            <div className="flex items-center gap-2 mb-3">
              <BookOpen className="w-5 h-5 text-[#2D6A4F]" />
              <h3 className="text-base font-bold text-gray-900 tracking-tight">
                Developer &amp; Agronomist Documentation
              </h3>
            </div>
            <p className="text-xs text-gray-600 leading-relaxed mb-4">
              Explore the REST API endpoints, model weights registry, and Van der Plank parameter derivation notebooks.
            </p>
          </div>

          <div className="flex flex-wrap gap-2 text-xs">
            <a
              href="http://localhost:5000/api/health"
              target="_blank"
              rel="noreferrer"
              className="inline-flex items-center gap-1.5 px-3 py-2 rounded-xl bg-gray-100 hover:bg-gray-200 text-gray-800 font-semibold transition-colors"
            >
              <span>API Health Endpoint</span>
              <ExternalLink className="w-3.5 h-3.5" />
            </a>
            <a
              href="http://localhost:5000/docs"
              target="_blank"
              rel="noreferrer"
              className="inline-flex items-center gap-1.5 px-3 py-2 rounded-xl bg-emerald-50 hover:bg-emerald-100 text-[#2D6A4F] font-semibold border border-emerald-200 transition-colors"
            >
              <span>FastAPI Swagger Docs</span>
              <ExternalLink className="w-3.5 h-3.5" />
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}
