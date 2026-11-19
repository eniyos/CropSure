import React from 'react';
import { motion } from 'framer-motion';

export default function ConfidenceBar({
  value = 0, // 0 to 1 or 0 to 100
  label = 'Model Confidence',
  showPercentage = true,
  height = 'h-2.5',
  className = ''
}) {
  // Normalize value to percentage 0-100
  const pct = value <= 1 ? +(value * 100).toFixed(1) : Math.min(100, Math.max(0, +value.toFixed(1)));

  // Color selection
  let barColor = 'bg-[#0d5c46]'; // high confidence
  let textColor = 'text-[#0d5c46]';
  if (pct < 60) {
    barColor = 'bg-red-600';
    textColor = 'text-red-600';
  } else if (pct < 80) {
    barColor = 'bg-slate-500';
    textColor = 'text-slate-700';
  }

  return (
    <div className={`w-full ${className}`}>
      <div className="flex items-center justify-between text-xs font-semibold mb-1.5">
        <span className="text-slate-700">{label}</span>
        {showPercentage && (
          <span className={`font-mono text-xs font-bold ${textColor}`}>
            {pct}%
          </span>
        )}
      </div>

      <div className={`w-full bg-slate-100 rounded-full overflow-hidden ${height} p-0.5 border border-slate-200/60`}>
        <motion.div
          initial={{ width: 0 }}
          animate={{ width: `${pct}%` }}
          transition={{ duration: 0.8, ease: 'easeOut' }}
          className={`h-full rounded-full ${barColor} shadow-xs relative`}
        >
          {/* Subtle sheen highlight */}
          <div className="absolute inset-0 bg-white/20 rounded-full" />
        </motion.div>
      </div>
    </div>
  );
}
