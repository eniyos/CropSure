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

  // Determine severity tier and color
  let color = '#28A745'; // green (<20%)
  let category = 'Mild';
  let badgeBg = 'bg-emerald-50 text-emerald-800 border-emerald-200';

  if (clampedValue > 75) {
    color = '#DC3545'; // red
    category = 'Critical';
    badgeBg = 'bg-rose-50 text-rose-800 border-rose-200';
  } else if (clampedValue > 50) {
    color = '#EA580C'; // orange
    category = 'Severe';
    badgeBg = 'bg-orange-50 text-orange-800 border-orange-200';
  } else if (clampedValue >= 20) {
    color = '#F59E0B'; // amber/yellow
    category = 'Moderate';
    badgeBg = 'bg-amber-50 text-amber-800 border-amber-200';
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
            stroke="#E5E7EB"
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
            className="text-3xl font-extrabold tracking-tight text-gray-900"
          >
            {clampedValue.toFixed(1)}%
          </motion.span>
          <span className="text-[11px] font-semibold text-gray-400 uppercase tracking-wider mt-0.5">
            Leaf Affected
          </span>

          {showCategory && (
            <span className={`mt-1.5 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wider rounded-md border ${badgeBg}`}>
              {category}
            </span>
          )}
        </div>
      </div>

      <div className="text-center mt-1">
        <h5 className="text-xs font-semibold text-gray-700 uppercase tracking-wide">{label}</h5>
        {sublabel && <p className="text-[11px] text-gray-500">{sublabel}</p>}
      </div>
    </div>
  );
}
