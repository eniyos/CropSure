import React from 'react';
import { motion } from 'framer-motion';

export default function SeverityGauge({
  value = 0, // 0 to 100
  size = 180,
  strokeWidth = 14,
  label = 'Infection Severity',
  sublabel = null,
  showCategory = true,
  className = ''
}) {
  // Clamp value between 0 and 100
  const clampedValue = Math.min(100, Math.max(0, Number(value) || 0));

  // Determine severity tier and color aligned with Chronicle palette
  let color = '#0d5c46'; // viridian (<20%)
  let category = 'Mild';
  let badgeBg = 'bg-[#0d5c46]/10 text-[#0d5c46] border-[#0d5c46]/20';

  if (clampedValue > 50) {
    color = '#dc2626'; // red
    category = 'Critical';
    badgeBg = 'bg-red-50 text-red-700 border-red-200';
  } else if (clampedValue >= 25) {
    color = '#475569'; // slate
    category = 'Moderate';
    badgeBg = 'bg-slate-100 text-slate-700 border-slate-200';
  }

  // SVG parameters
  const radius = (size - strokeWidth) / 2;
  const circumference = 2 * Math.PI * radius;
  // Use a 260-degree arc gauge
  const arcLength = circumference * 0.75;
  const strokeDashoffset = arcLength - (arcLength * clampedValue) / 100;

  return (
    <div className={`flex flex-col items-center justify-center ${className}`}>
      <div className="relative" style={{ width: size, height: size * 0.85 }}>
        <svg
          width={size}
          height={size}
          className="transform -rotate-225 origin-center overflow-visible"
        >
          {/* Background Track Arc */}
          <circle
            cx={size / 2}
            cy={size / 2}
            r={radius}
            fill="transparent"
            stroke="#e2e8f0"
            strokeWidth={strokeWidth}
            strokeDasharray={`${arcLength} ${circumference}`}
            strokeLinecap="round"
          />

          {/* Foreground Animated Value Arc */}
          <motion.circle
            cx={size / 2}
            cy={size / 2}
            r={radius}
            fill="transparent"
            stroke={color}
            strokeWidth={strokeWidth}
            strokeDasharray={`${arcLength} ${circumference}`}
            initial={{ strokeDashoffset: arcLength }}
            animate={{ strokeDashoffset }}
            transition={{ duration: 1.2, ease: 'easeOut' }}
            strokeLinecap="round"
          />
        </svg>

        {/* Center Content */}
        <div className="absolute inset-0 flex flex-col items-center justify-center pt-2">
          <motion.span
            initial={{ scale: 0.5, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="text-3xl font-extrabold font-mono tracking-tight text-slate-900"
          >
            {clampedValue.toFixed(1)}%
          </motion.span>
          <span className="text-[11px] font-semibold text-slate-400 uppercase tracking-wider mt-0.5">
            Leaf Affected
          </span>

          {showCategory && (
            <span className={`mt-1.5 px-2 py-0.5 text-[11px] font-mono font-bold uppercase tracking-wider rounded-md border ${badgeBg}`}>
              {category}
            </span>
          )}
        </div>
      </div>

      <div className="text-center mt-1">
        <h5 className="text-xs font-semibold text-slate-700 uppercase tracking-wide">{label}</h5>
        {sublabel && <p className="text-[11px] text-slate-500 font-mono">{sublabel}</p>}
      </div>
    </div>
  );
}
