import React from 'react';
import { motion } from 'framer-motion';

export default function ConfidenceBar({
  value = 0, // 0 to 1 or 0 to 100
  label = 'Model Confidence',
  showPercentage = true,
  height = 'h-3',
  className = ''
}) {
  // Normalize value to percentage 0-100
  const pct = value <= 1 ? +(value * 100).toFixed(1) : Math.min(100, Math.max(0, +value.toFixed(1)));

  // Color selection
  let barColor = 'bg-[#2D6A4F]'; // high confidence
  let textColor = 'text-[#2D6A4F]';
  if (pct < 60) {
    barColor = 'bg-rose-500';
    textColor = 'text-rose-600';
  } else if (pct < 80) {
    barColor = 'bg-amber-500';
    textColor = 'text-amber-600';
  }

  return (
    <div className={`w-full ${className}`}>
      <div className="flex items-center justify-between text-xs font-semibold mb-1.5">
        <span className="text-gray-700">{label}</span>
        {showPercentage && (
          <span className={`font-mono text-xs font-bold ${textColor}`}>
            {pct}%
          </span>
        )}
      </div>

      <div className={`w-full bg-gray-100 rounded-full overflow-hidden ${height} p-0.5 border border-gray-200/60`}>
        <motion.div
          initial={{ width: 0 }}
          animate={{ width: `${pct}%` }}
          transition={{ duration: 1, ease: 'easeOut' }}
          className={`h-full rounded-full ${barColor} shadow-xs relative`}
        >
          {/* Subtle sheen highlight */}
          <div className="absolute inset-0 bg-white/20 rounded-full" />
        </motion.div>
      </div>
    </div>
  );
}
