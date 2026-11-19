import React, { useState } from 'react';
import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';
import TopBar from './TopBar';
import { ArcBandsBackground } from '@/components/background-gradient/arc-bands-background';

export default function Layout() {
  const [sidebarOpen, setSidebarOpen] = useState(false);

  return (
    <ArcBandsBackground className="min-h-screen flex flex-col antialiased font-sans">
      {/* Sidebar navigation */}
      <Sidebar
        isOpen={sidebarOpen}
        onClose={() => setSidebarOpen(false)}
      />

      {/* Main Container offset for desktop sidebar (w-64 = 16rem / 256px) */}
      <div className="lg:pl-64 flex flex-col flex-1 min-w-0 transition-all duration-200">
        <TopBar onOpenSidebar={() => setSidebarOpen(true)} />

        <main className="flex-1 p-4 sm:p-6 lg:p-8 max-w-7xl w-full mx-auto">
          <Outlet />
        </main>

        {/* Clean Professional Footer */}
        <footer className="py-4 px-6 border-t border-slate-200/80 text-center text-xs text-slate-500 bg-white/70 backdrop-blur-md">
          <div className="max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-2">
            <span className="font-medium text-slate-600">
              CropSure &bull; Agricultural Pathology &amp; Forecasting &copy; {new Date().getFullYear()}
            </span>
            <span className="text-slate-400 font-mono text-[11px]">
              Station Field Unit &bull; Solana Devnet Consensus
            </span>
          </div>
        </footer>
      </div>
    </ArcBandsBackground>
  );
}
