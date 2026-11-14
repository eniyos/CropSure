import React, { useState } from 'react';
import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';
import TopBar from './TopBar';

export default function Layout() {
  const [sidebarOpen, setSidebarOpen] = useState(false);

  return (
    <div className="min-h-screen bg-[#FAFAF5] flex flex-col antialiased">
      {/* Sidebar navigation */}
      <Sidebar
        isOpen={sidebarOpen}
        onClose={() => setSidebarOpen(false)}
      />

      {/* Main Container offset for desktop sidebar (w-64 = 16rem / 256px) */}
      <div className="lg:pl-64 flex flex-col flex-1 min-w-0 transition-all duration-300">
        <TopBar onOpenSidebar={() => setSidebarOpen(true)} />

        <main className="flex-1 p-4 sm:p-6 lg:p-8 max-w-7xl w-full mx-auto">
          <Outlet />
        </main>

        {/* Global Footer */}
        <footer className="py-4 px-6 border-t border-gray-200/60 text-center text-xs text-gray-500 bg-white/60">
          <div className="max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-2">
            <span className="font-medium text-gray-600">
              CropSure Agricultural AI Intelligence System &copy; {new Date().getFullYear()}
            </span>
            <span className="text-gray-400 text-[11px]">
              Trained on Solanaceae Phenotypic Foliar Libraries &bull; Van der Plank Logistic Engine
            </span>
          </div>
        </footer>
      </div>
    </div>
  );
}
