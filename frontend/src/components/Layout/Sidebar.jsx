import React from 'react';
import { NavLink } from 'react-router-dom';
import {
  LayoutDashboard,
  ScanSearch,
  LineChart,
  FlaskConical,
  Cpu,
  Info,
  Sprout,
  X,
  ShieldCheck,
  ChevronRight
} from 'lucide-react';
import { motion } from 'framer-motion';

const NAV_ITEMS = [
  { path: '/', label: 'Dashboard', icon: LayoutDashboard },
  { path: '/analyze', label: 'Disease Analysis', icon: ScanSearch, badge: 'AI Core' },
  { path: '/forecast', label: 'Disease Forecast', icon: LineChart },
  { path: '/epidemic', label: 'Epidemic Sim', icon: FlaskConical },
  { path: '/models', label: 'Model Status', icon: Cpu, badge: '6/6' },
  { path: '/about', label: 'About & Arch', icon: Info },
];

export default function Sidebar({ isOpen, onClose }) {
  return (
    <>
      {/* Mobile Backdrop */}
      {isOpen && (
        <div
          onClick={onClose}
          className="fixed inset-0 z-40 bg-black/50 backdrop-blur-xs lg:hidden transition-opacity"
        />
      )}

      {/* Sidebar Container */}
      <aside
        className={`fixed top-0 bottom-0 left-0 z-50 w-64 bg-[#1B4332] text-white flex flex-col border-r border-[#2D6A4F]/40 shadow-xl lg:shadow-none transition-transform duration-300 ease-in-out ${
          isOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'
        }`}
      >
        {/* Brand Header */}
        <div className="h-16 flex items-center justify-between px-6 border-b border-[#2D6A4F]/50">
          <NavLink to="/" className="flex items-center gap-3 group" onClick={onClose}>
            <div className="w-9 h-9 rounded-xl bg-gradient-to-tr from-[#52B788] to-[#D4A843] flex items-center justify-center text-[#1B4332] shadow-md group-hover:scale-105 transition-transform">
              <Sprout className="w-5 h-5 stroke-[2.5]" />
            </div>
            <div className="flex flex-col">
              <span className="font-extrabold text-lg tracking-tight text-white flex items-center gap-1.5">
                CropSure
                <span className="w-1.5 h-1.5 rounded-full bg-[#D4A843]" />
              </span>
              <span className="text-[10px] uppercase tracking-widest text-[#74C69D] font-semibold -mt-1">
                Agri AI Intelligence
              </span>
            </div>
          </NavLink>

          <button
            onClick={onClose}
            className="p-1.5 rounded-lg text-[#74C69D] hover:text-white hover:bg-[#2D6A4F] lg:hidden transition-colors"
            aria-label="Close menu"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Navigation Links */}
        <nav className="flex-1 px-3 py-6 space-y-1.5 overflow-y-auto">
          <div className="px-3 pb-2">
            <span className="text-[10px] font-bold uppercase tracking-wider text-[#74C69D]/80">
              Platform Modules
            </span>
          </div>

          {NAV_ITEMS.map((item) => {
            const Icon = item.icon;
            return (
              <NavLink
                key={item.path}
                to={item.path}
                onClick={onClose}
                className={({ isActive }) =>
                  `flex items-center justify-between px-3.5 py-2.5 rounded-xl font-medium text-sm transition-all duration-150 group ${
                    isActive
                      ? 'bg-[#2D6A4F] text-white shadow-sm font-semibold'
                      : 'text-gray-200 hover:text-white hover:bg-[#2D6A4F]/40'
                  }`
                }
              >
                {({ isActive }) => (
                  <>
                    <div className="flex items-center gap-3">
                      <Icon
                        className={`w-4 h-4 transition-colors ${
                          isActive ? 'text-[#D4A843]' : 'text-[#74C69D] group-hover:text-white'
                        }`}
                      />
                      <span>{item.label}</span>
                    </div>

                    <div className="flex items-center gap-1.5">
                      {item.badge && (
                        <span
                          className={`text-[10px] px-2 py-0.5 rounded-full font-semibold ${
                            isActive
                              ? 'bg-[#1B4332] text-[#D4A843] border border-[#D4A843]/30'
                              : 'bg-[#2D6A4F]/60 text-emerald-200'
                          }`}
                        >
                          {item.badge}
                        </span>
                      )}
                      {isActive && <ChevronRight className="w-3.5 h-3.5 text-[#D4A843]" />}
                    </div>
                  </>
                )}
              </NavLink>
            );
          })}
        </nav>

        {/* Model Pipeline Banner */}
        <div className="p-4 mx-3 mb-4 rounded-xl bg-[#2D6A4F]/40 border border-[#52B788]/20">
          <div className="flex items-center gap-2 mb-1.5">
            <ShieldCheck className="w-4 h-4 text-[#D4A843]" />
            <span className="text-xs font-semibold text-white">CropSure Guard</span>
          </div>
          <p className="text-[11px] text-[#95D5B2] leading-relaxed">
            Neural ensemble calibrated on 54,000+ leaf spectra with Bayesian trust scoring.
          </p>
        </div>

        {/* Footer with version */}
        <div className="p-4 border-t border-[#2D6A4F]/40 flex items-center justify-between text-[11px] text-[#74C69D]">
          <div className="flex items-center gap-1.5">
            <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
            <span>Systems Online</span>
          </div>
          <span className="font-mono text-gray-300">v2.4.0</span>
        </div>
      </aside>
    </>
  );
}
