import React from 'react';
import { motion } from 'framer-motion';
import { Sprout } from 'lucide-react';

export default function LoadingSpinner({
  size = 'md', // sm, md, lg, xl
  label = 'Processing...',
  subtext = null,
  fullPage = false,
  className = ''
}) {
  const sizeMap = {
    sm: { container: 'w-6 h-6', icon: 'w-3.5 h-3.5', ring: 'border-2' },
    md: { container: 'w-12 h-12', icon: 'w-6 h-6', ring: 'border-2' },
    lg: { container: 'w-16 h-16', icon: 'w-8 h-8', ring: 'border-3' },
    xl: { container: 'w-24 h-24', icon: 'w-12 h-12', ring: 'border-3' },
  };

  const selectedSize = sizeMap[size] || sizeMap.md;

  const content = (
    <div className={`flex flex-col items-center justify-center gap-3 ${className}`}>
      <div className={`relative ${selectedSize.container} flex items-center justify-center`}>
        {/* Subtle background track */}
        <div className={`absolute inset-0 rounded-full border-slate-200 ${selectedSize.ring}`} />

        {/* Precision viridian spinner */}
        <motion.div
          animate={{ rotate: 360 }}
          transition={{ duration: 1.2, repeat: Infinity, ease: 'linear' }}
          className={`absolute inset-0 rounded-full border-t-[#0d5c46] border-r-transparent border-b-transparent border-l-transparent ${selectedSize.ring}`}
        />

        {/* Center calm leaf icon */}
        <div className="text-[#0d5c46]">
          <Sprout className={selectedSize.icon} />
        </div>
      </div>

      {label && (
        <div className="text-center">
          <p className="text-sm font-semibold text-slate-800 tracking-tight">{label}</p>
          {subtext && <p className="text-xs font-mono text-slate-500 mt-0.5">{subtext}</p>}
        </div>
      )}
    </div>
  );

  if (fullPage) {
    return (
      <div className="fixed inset-0 z-50 flex items-center justify-center bg-white/80 backdrop-blur-sm">
        {content}
      </div>
    );
  }

  return content;
}
