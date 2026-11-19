import React from 'react';
import { motion } from 'framer-motion';
import { TrendingUp, TrendingDown, Minus } from 'lucide-react';

export default function StatCard({
  icon: Icon,
  label,
  value,
  subvalue,
  trend, // { direction: 'up' | 'down' | 'neutral', value: string, positive: boolean }
  badge,
  className = '',
  delay = 0,
}) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 12 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4, delay }}
      whileHover={{ y: -2 }}
      className={`bg-white/95 backdrop-blur-[6px] rounded-2xl p-5 border border-slate-200/85 [box-shadow:inset_1px_-1px_1px_rgba(255,255,255,0.95),inset_-1px_1px_1px_rgba(255,255,255,0.95),0_4px_16px_rgba(15,23,42,0.04)] hover:[box-shadow:inset_1px_-1px_1px_rgba(255,255,255,0.95),inset_-1px_1px_1px_rgba(255,255,255,0.95),0_6px_20px_rgba(15,23,42,0.07)] transition-all duration-200 relative overflow-hidden ${className}`}
    >
      <div className="flex items-start justify-between">
        <div className="flex flex-col">
          <span className="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-1">
            {label}
          </span>
          <div className="flex items-baseline gap-2">
            <span className="text-2xl font-bold font-display text-slate-900 tracking-tight">
              {value}
            </span>
            {subvalue && (
              <span className="text-xs text-slate-500 font-medium font-mono">
                {subvalue}
              </span>
            )}
          </div>
        </div>

        {Icon && (
          <div className="w-10 h-10 rounded-xl bg-[#0d5c46]/10 border border-[#0d5c46]/15 flex items-center justify-center text-[#0d5c46] shrink-0">
            <Icon className="w-5 h-5" />
          </div>
        )}
      </div>

      {(trend || badge) && (
        <div className="mt-4 pt-3 border-t border-slate-100 flex items-center justify-between text-xs">
          {trend && (
            <div
              className={`flex items-center gap-1 font-medium font-mono ${
                trend.positive
                  ? 'text-[#0d5c46]'
                  : trend.direction === 'neutral'
                  ? 'text-slate-500'
                  : 'text-red-600'
              }`}
            >
              {trend.direction === 'up' && <TrendingUp className="w-3.5 h-3.5" />}
              {trend.direction === 'down' && <TrendingDown className="w-3.5 h-3.5" />}
              {trend.direction === 'neutral' && <Minus className="w-3.5 h-3.5" />}
              <span>{trend.value}</span>
            </div>
          )}

          {badge && (
            <span className="px-2 py-0.5 rounded-full bg-slate-100 text-slate-700 text-[11px] font-mono font-medium border border-slate-200">
              {badge}
            </span>
          )}
        </div>
      )}
    </motion.div>
  );
}
