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
      className={`bg-white rounded-xl p-5 border border-gray-100 shadow-sm hover:shadow-md transition-all duration-200 relative overflow-hidden ${className}`}
    >
      <div className="flex items-start justify-between">
        <div className="flex flex-col">
          <span className="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-1">
            {label}
          </span>
          <div className="flex items-baseline gap-2">
            <span className="text-2xl font-bold text-gray-900 tracking-tight">
              {value}
            </span>
            {subvalue && (
              <span className="text-xs text-gray-500 font-medium">
                {subvalue}
              </span>
            )}
          </div>
        </div>

        {Icon && (
          <div className="w-11 h-11 rounded-xl bg-[#2D6A4F]/10 flex items-center justify-center text-[#2D6A4F] shrink-0">
            <Icon className="w-5 h-5" />
          </div>
        )}
      </div>

      {(trend || badge) && (
        <div className="mt-4 pt-3 border-t border-gray-50 flex items-center justify-between text-xs">
          {trend && (
            <div
              className={`flex items-center gap-1 font-medium ${
                trend.positive
                  ? 'text-emerald-700'
                  : trend.direction === 'neutral'
                  ? 'text-gray-500'
                  : 'text-rose-600'
              }`}
            >
              {trend.direction === 'up' && <TrendingUp className="w-3.5 h-3.5" />}
              {trend.direction === 'down' && <TrendingDown className="w-3.5 h-3.5" />}
              {trend.direction === 'neutral' && <Minus className="w-3.5 h-3.5" />}
              <span>{trend.value}</span>
            </div>
          )}

          {badge && (
            <span className="px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-800 text-[11px] font-medium border border-emerald-100">
              {badge}
            </span>
          )}
        </div>
      )}
    </motion.div>
  );
}
