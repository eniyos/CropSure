import React from 'react';

export default function StatusBadge({
  status = 'neutral', // 'success' | 'warning' | 'error' | 'info' | 'neutral'
  label,
  showDot = true,
  pulse = false,
  size = 'md',
  className = ''
}) {
  const variantStyles = {
    success: {
      bg: 'bg-[#e6f0ed] border-[#0d5c46]/20 text-[#0d5c46]',
      dot: 'bg-[#0d5c46]',
      pulseDot: 'bg-[#0d5c46]/70'
    },
    warning: {
      bg: 'bg-red-50 border-red-200 text-red-700',
      dot: 'bg-red-500',
      pulseDot: 'bg-red-400'
    },
    error: {
      bg: 'bg-red-50 border-red-200 text-red-700',
      dot: 'bg-red-500',
      pulseDot: 'bg-red-400'
    },
    info: {
      bg: 'bg-slate-100 border-slate-200 text-slate-700',
      dot: 'bg-slate-500',
      pulseDot: 'bg-slate-400'
    },
    neutral: {
      bg: 'bg-slate-100 border-slate-200 text-slate-700',
      dot: 'bg-slate-400',
      pulseDot: 'bg-slate-300'
    }
  };

  const style = variantStyles[status] || variantStyles.neutral;
  const sizeStyles = size === 'sm' ? 'px-2 py-0.5 text-[11px]' : 'px-2.5 py-1 text-xs';

  return (
    <span
      className={`inline-flex items-center gap-1.5 font-medium rounded-full border shadow-xs ${style.bg} ${sizeStyles} ${className}`}
    >
      {showDot && (
        <span className="relative flex h-2 w-2">
          {pulse && (
            <span
              className={`animate-ping absolute inline-flex h-full w-full rounded-full opacity-75 ${style.pulseDot}`}
            />
          )}
          <span className={`relative inline-flex rounded-full h-2 w-2 ${style.dot}`} />
        </span>
      )}
      <span>{label}</span>
    </span>
  );
}
