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
    md: { container: 'w-12 h-12', icon: 'w-6 h-6', ring: 'border-3' },
    lg: { container: 'w-16 h-16', icon: 'w-8 h-8', ring: 'border-4' },
    xl: { container: 'w-24 h-24', icon: 'w-12 h-12', ring: 'border-4' },
  };

  const selectedSize = sizeMap[size] || sizeMap.md;

  const content = (
    <div className={`flex flex-col items-center justify-center gap-3 ${className}`}>
      <div className={`relative ${selectedSize.container} flex items-center justify-center`}>
        {/* Outer glowing orbital ring */}
        <motion.div
          animate={{ rotate: 360 }}
          transition={{ duration: 1.6, repeat: Infinity, ease: 'linear' }}
          className={`absolute inset-0 rounded-full border-t-[#2D6A4F] border-r-[#52B788] border-b-transparent border-l-transparent ${selectedSize.ring}`}
        />
        
        {/* Second counter-rotating accent ring */}
        <motion.div
          animate={{ rotate: -360 }}
          transition={{ duration: 2.4, repeat: Infinity, ease: 'linear' }}
          className={`absolute inset-1 rounded-full border-t-[#D4A843] border-b-[#74C69D] border-r-transparent border-l-transparent opacity-80 ${selectedSize.ring}`}
        />

        {/* Center pulsing leaf/sprout icon */}
        <motion.div
          animate={{ scale: [0.85, 1.1, 0.85] }}
          transition={{ duration: 1.8, repeat: Infinity, ease: 'easeInOut' }}
          className="text-[#2D6A4F]"
        >
          <Sprout className={selectedSize.icon} />
        </motion.div>
      </div>

      {label && (
        <div className="text-center">
          <p className="text-sm font-semibold text-gray-800 tracking-wide">{label}</p>
          {subtext && <p className="text-xs text-gray-500 mt-0.5">{subtext}</p>}
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
