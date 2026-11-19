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
  ChevronRight,
  ShieldCheck
} from 'lucide-react';

const NAV_ITEMS = [
  { path: '/', label: 'Overview', icon: LayoutDashboard },
  { path: '/analyze', label: 'Pathology Diagnosis', icon: ScanSearch },
  { path: '/forecast', label: 'Disease Forecast', icon: LineChart },
  { path: '/epidemic', label: 'Epidemic Simulation', icon: FlaskConical },
  { path: '/models', label: 'Model Infrastructure', icon: Cpu, badge: '6/6' },
  { path: '/about', label: 'System Architecture', icon: Info },
];

export default function Sidebar({ isOpen, onClose }) {
  return (
    <>
      {/* Mobile Backdrop */}
      {isOpen && (
        <div
          onClick={onClose}
          className="fixed inset-0 z-40 bg-slate-900/40 backdrop-blur-xs lg:hidden transition-opacity"
        />
      )}

      {/* Sidebar Container */}
      <aside
        className={`fixed top-0 bottom-0 left-0 z-50 w-64 bg-white text-slate-900 flex flex-col border-r border-slate-200/80 shadow-xs lg:shadow-none transition-transform duration-200 ease-in-out font-sans ${
          isOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'
        }`}
      >
        {/* Brand Header */}
        <div className="h-16 flex items-center justify-between px-5 border-b border-slate-200/80">
          <NavLink to="/" className="flex items-center gap-3 group" onClick={onClose}>
            <div className="w-9 h-9 rounded-xl bg-[#0d5c46] flex items-center justify-center text-white shadow-xs group-hover:scale-105 transition-transform shrink-0">
              <Sprout className="w-5 h-5 stroke-[2.2]" />
            </div>
            <div className="flex flex-col">
              <span className="font-display font-bold text-base tracking-tight text-slate-900 leading-none">
                CropSure
              </span>
              <span className="text-[11px] font-mono text-slate-400 mt-1">
                Foliar Pathology
              </span>
            </div>
          </NavLink>

          <button
            onClick={onClose}
            className="p-1.5 rounded-lg text-slate-400 hover:text-slate-700 hover:bg-slate-100 lg:hidden transition-colors"
            aria-label="Close menu"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Navigation Links */}
        <nav className="flex-1 px-3 py-5 space-y-1 overflow-y-auto">
          <div className="px-3 pb-2">
            <span className="text-[11px] font-mono uppercase tracking-wider text-slate-400 font-semibold">
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
                  `flex items-center justify-between px-3.5 py-2.5 rounded-xl text-xs font-medium transition-colors ${
                    isActive
                      ? 'bg-slate-100 text-[#0d5c46] font-semibold'
                      : 'text-slate-600 hover:text-slate-900 hover:bg-slate-50'
                  }`
                }
              >
                {({ isActive }) => (
                  <>
                    <div className="flex items-center gap-2.5">
                      <Icon
                        className={`w-4 h-4 transition-colors ${
                          isActive ? 'text-[#0d5c46]' : 'text-slate-400'
                        }`}
                      />
                      <span>{item.label}</span>
                    </div>

                    <div className="flex items-center gap-1.5">
                      {item.badge && (
                        <span
                          className={`text-[10px] font-mono px-2 py-0.5 rounded-md font-semibold ${
                            isActive
                              ? 'bg-[#0d5c46] text-white'
                              : 'bg-slate-100 text-slate-600'
                          }`}
                        >
                          {item.badge}
                        </span>
                      )}
                      {isActive && <ChevronRight className="w-3.5 h-3.5 text-[#0d5c46]" />}
                    </div>
                  </>
                )}
              </NavLink>
            );
          })}
        </nav>

        {/* Footer Station Status */}
        <div className="p-4 border-t border-slate-200/80 space-y-2 bg-slate-50/50">
          <div className="flex items-center justify-between text-xs font-mono">
            <span className="text-slate-400">Station</span>
            <span className="text-slate-700 font-semibold">Field Sector A</span>
          </div>
          <div className="flex items-center justify-between text-xs font-mono">
            <span className="text-slate-400">Solana Devnet</span>
            <span className="text-[#0d5c46] font-semibold">Synced</span>
          </div>
        </div>
      </aside>
    </>
  );
}
