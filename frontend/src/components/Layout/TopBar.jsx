import React from 'react';
import { useLocation } from 'react-router-dom';
import { Menu, Search, Bell, Sparkles, User, ShieldCheck } from 'lucide-react';

const PAGE_TITLES = {
  '/': { title: 'Intelligence Dashboard', subtitle: 'Real-time telemetry and plant health operations' },
  '/analyze': { title: 'Disease Diagnosis & Explainability', subtitle: 'Deep CNN detection with Grad-CAM and Bayesian trust scoring' },
  '/forecast': { title: 'Disease Progression Forecast', subtitle: 'Microclimate projection and multi-horizon severity curves' },
  '/epidemic': { title: 'Epidemic Dynamics Simulation', subtitle: 'Van der Plank epidemiological growth and intervention modeling' },
  '/models': { title: 'Model Registry & Health', subtitle: 'Runtime telemetry for all 6 specialized deep learning engines' },
  '/about': { title: 'Architecture & System Overview', subtitle: 'Multi-layer neural pipeline and agronomic research validation' },
};

export default function TopBar({ onOpenSidebar }) {
  const location = useLocation();
  const currentMeta = PAGE_TITLES[location.pathname] || {
    title: 'CropSure Platform',
    subtitle: 'Agricultural AI Intelligence'
  };

  return (
    <header className="h-16 bg-white border-b border-gray-100 shadow-xs sticky top-0 z-30 flex items-center justify-between px-4 sm:px-6">
      {/* Left: Hamburger & Dynamic Title */}
      <div className="flex items-center gap-3">
        <button
          onClick={onOpenSidebar}
          className="p-2 rounded-lg text-gray-600 hover:bg-gray-100 lg:hidden"
          aria-label="Open sidebar"
        >
          <Menu className="w-5 h-5" />
        </button>

        <div className="flex flex-col">
          <h1 className="text-base sm:text-lg font-bold text-gray-900 tracking-tight leading-tight">
            {currentMeta.title}
          </h1>
          <p className="text-xs text-gray-500 hidden sm:block">
            {currentMeta.subtitle}
          </p>
        </div>
      </div>

      {/* Right Actions */}
      <div className="flex items-center gap-3">
        {/* Decorative Global Search */}
        <div className="relative hidden md:block w-56">
          <Search className="w-4 h-4 text-gray-400 absolute left-3 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Search diseases, models..."
            className="w-full bg-[#FAFAF5] text-xs text-gray-800 pl-9 pr-3 py-1.5 rounded-lg border border-gray-200 focus:outline-none focus:border-[#2D6A4F] focus:bg-white transition-all"
            readOnly
          />
        </div>

        {/* Live Engine Status Badge */}
        <div className="hidden sm:flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs font-medium">
          <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
          <span>Inference Ready</span>
        </div>

        {/* Notification Bell */}
        <button
          type="button"
          className="relative p-2 rounded-lg text-gray-500 hover:text-gray-900 hover:bg-gray-100 transition-colors"
          title="Telemetry Notifications"
        >
          <Bell className="w-4 h-4" />
          <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-[#D4A843] rounded-full ring-2 ring-white" />
        </button>

        {/* User Profile Avatar */}
        <div className="flex items-center gap-2 pl-2 border-l border-gray-200">
          <div className="w-8 h-8 rounded-full bg-[#2D6A4F] text-white flex items-center justify-center font-bold text-xs shadow-xs">
            AG
          </div>
          <div className="hidden xl:flex flex-col text-left">
            <span className="text-xs font-semibold text-gray-900 leading-none">Agronomist</span>
            <span className="text-[10px] text-gray-500">Research Station A</span>
          </div>
        </div>
      </div>
    </header>
  );
}
