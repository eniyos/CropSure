import React from 'react';
import {
  Radar,
  RadarChart,
  PolarGrid,
  PolarAngleAxis,
  PolarRadiusAxis,
  ResponsiveContainer,
  Tooltip
} from 'recharts';

export default function TrustScoreRadar({
  data = null,
  height = 240,
  className = ''
}) {
  // Default metrics if none provided
  const defaultData = [
    { subject: 'Leaf Geometry', score: 88, fullMark: 100 },
    { subject: 'Texture Variance', score: 92, fullMark: 100 },
    { subject: 'Color Homogeneity', score: 81, fullMark: 100 },
    { subject: 'Vein Fidelity', score: 86, fullMark: 100 },
    { subject: 'Boundary Contrast', score: 94, fullMark: 100 },
    { subject: 'Spectral Distribution', score: 79, fullMark: 100 }
  ];

  const chartData = data && Array.isArray(data) && data.length > 0 ? data : defaultData;

  const CustomTooltip = ({ active, payload }) => {
    if (active && payload && payload.length) {
      const p = payload[0];
      return (
        <div className="bg-white/95 backdrop-blur-md p-3 rounded-xl shadow-md border border-slate-200 text-xs">
          <p className="font-semibold text-slate-900">{p.payload.subject}</p>
          <div className="flex items-center gap-2 mt-1">
            <span className="w-2.5 h-2.5 rounded-full bg-[#0d5c46]" />
            <span className="text-slate-600">Trust Strength:</span>
            <span className="font-mono font-bold text-[#0d5c46]">{p.value}/100</span>
          </div>
        </div>
      );
    }
    return null;
  };

  return (
    <div className={`w-full ${className}`} style={{ height }}>
      <ResponsiveContainer width="100%" height="100%">
        <RadarChart cx="50%" cy="50%" outerRadius="75%" data={chartData}>
          <PolarGrid stroke="#E2E8F0" strokeDasharray="3 3" />
          <PolarAngleAxis
            dataKey="subject"
            tick={{ fill: '#475569', fontSize: 10, fontWeight: 500 }}
          />
          <PolarRadiusAxis
            angle={30}
            domain={[0, 100]}
            tick={{ fill: '#94A3B8', fontSize: 9 }}
            stroke="#CBD5E1"
          />
          <Tooltip content={<CustomTooltip />} />
          <Radar
            name="Evidence Reliability"
            dataKey="score"
            stroke="#0d5c46"
            fill="#0d5c46"
            fillOpacity={0.25}
            strokeWidth={1.5}
          />
        </RadarChart>
      </ResponsiveContainer>
    </div>
  );
}
