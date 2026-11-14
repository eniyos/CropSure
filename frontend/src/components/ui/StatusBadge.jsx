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
      bg: 'bg-emerald-50 border-emerald-200 text-emerald-800',
      dot: 'bg-emerald-500',
      pulseDot: 'bg-emerald-400'
    },
    warning: {
      bg: 'bg-amber-50 border-amber-200 text-amber-800',
      dot: 'bg-amber-500',
      pulseDot: 'bg-amber-400'
    },
    error: {
      bg: 'bg-rose-50 border-rose-200 text-rose-800',
      dot: 'bg-rose-500',
      pulseDot: 'bg-rose-400'
    },
    info: {
      bg: 'bg-sky-50 border-sky-200 text-sky-800',
      dot: 'bg-sky-500',
      pulseDot: 'bg-sky-400'
    },
    neutral: {
      bg: 'bg-gray-100 border-gray-200 text-gray-700',
      dot: 'bg-gray-400',
      pulseDot: 'bg-gray-300'
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
