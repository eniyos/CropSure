import React from 'react';
import { useLocation } from 'react-router-dom';
import { Menu, Bell } from 'lucide-react';
import { Button } from '@/components/ui/button';

const PAGE_TITLES = {
  '/': { title: 'Canopy Pathology Overview', subtitle: 'Real-time telemetry and plant health operations' },
  '/analyze': { title: 'Disease Diagnosis & Saliency', subtitle: 'Foliar pathology detection with Grad-CAM localization and Bayesian calibration' },
  '/forecast': { title: 'Disease Progression Forecast', subtitle: 'Microclimate projection and 30-day severity curves' },
  '/epidemic': { title: 'Epidemic Dynamics Simulation', subtitle: 'Van der Plank epidemiological growth and intervention modeling' },
  '/models': { title: 'Production Model Registry', subtitle: 'Runtime telemetry for inference engines' },
  '/about': { title: 'Architecture & Specifications', subtitle: 'Diagnostic pipeline specifications and mathematical formulations' },
};

export default function TopBar({ onOpenSidebar }) {
  const location = useLocation();
  const currentMeta = PAGE_TITLES[location.pathname] || {
    title: 'CropSure Platform',
    subtitle: 'Agricultural Pathology & Diagnostics'
  };

  return (
    <header className="h-16 bg-white border-b border-slate-200/80 shadow-xs sticky top-0 z-30 flex items-center justify-between px-4 sm:px-6 font-sans">
      {/* Left: Hamburger & Dynamic Title */}
      <div className="flex items-center gap-3">
        <Button
          variant="ghost"
          size="icon-sm"
          onClick={onOpenSidebar}
          className="lg:hidden text-slate-600 hover:bg-slate-100"
          aria-label="Open sidebar"
        >
          <Menu className="w-5 h-5" />
        </Button>

        <div className="flex flex-col">
          <h1 className="font-display text-base sm:text-lg font-bold text-slate-900 tracking-tight leading-tight">
            {currentMeta.title}
          </h1>
          <p className="text-xs text-slate-500 hidden sm:block">
            {currentMeta.subtitle}
          </p>
        </div>
      </div>

      {/* Right Actions */}
      <div className="flex items-center gap-3">
        {/* Live Engine Status Badge */}
        <div className="hidden sm:flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-slate-50 border border-slate-200 text-slate-700 text-xs font-mono font-medium">
          <span className="w-2 h-2 rounded-full bg-[#0d5c46]" />
          <span>Inference Suite Active</span>
        </div>

        {/* Notification Bell */}
        <Button
          type="button"
          variant="ghost"
          size="icon-sm"
          effect="ripple"
          className="relative text-slate-500 hover:text-slate-900 hover:bg-slate-100 rounded-full"
          title="Telemetry Notifications"
        >
          <Bell className="w-4 h-4" />
          <span className="absolute top-1.5 right-1.5 w-1.5 h-1.5 bg-[#0d5c46] rounded-full" />
        </Button>

        {/* User Profile Avatar */}
        <div className="flex items-center gap-2 pl-2 border-l border-slate-200">
          <div className="w-8 h-8 rounded-lg bg-[#0d5c46] text-white flex items-center justify-center font-bold text-xs shadow-xs font-mono">
            AG
          </div>
          <div className="hidden xl:flex flex-col text-left">
            <span className="text-xs font-semibold text-slate-900 leading-none">Agronomist</span>
            <span className="text-[10px] text-slate-500">Research Station A</span>
          </div>
        </div>
      </div>
    </header>
  );
}
