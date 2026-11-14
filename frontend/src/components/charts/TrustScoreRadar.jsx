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

// Default 12 evidence signals if none supplied
const DEFAULT_SIGNALS = [
  { label: 'CNN Feature Concordance', score: 94 },
  { label: 'Grad-CAM Spatial Alignment', score: 89 },
  { label: 'Morphological Pattern Match', score: 92 },
  { label: 'Spectral Consistency', score: 88 },
  { label: 'Phenological Compatibility', score: 95 },
  { label: 'Climatic Feasibility Check', score: 90 },
  { label: 'Symptom Margin Sharpness', score: 87 },
  { label: 'Leaf Texture Regularity', score: 91 },
  { label: 'Vein Architecture Integrity', score: 93 },
  { label: 'Pathogen Signature Index', score: 89 },
  { label: 'Ensemble Agreement Ratio', score: 96 },
  { label: 'Dataset Prior Correlation', score: 88 }
];

export default function TrustScoreRadar({
  data = DEFAULT_SIGNALS,
  height = 320,
  className = ''
}) {
  const chartData = data.map(item => ({
    subject: item.label,
    score: item.score,
    fullMark: 100
  }));

  const CustomTooltip = ({ active, payload }) => {
    if (active && payload && payload.length) {
      const p = payload[0];
      return (
        <div className="bg-white/95 backdrop-blur-md p-3 rounded-xl shadow-lg border border-gray-100 text-xs">
          <p className="font-semibold text-gray-900">{p.payload.subject}</p>
          <div className="flex items-center gap-2 mt-1">
            <span className="w-2.5 h-2.5 rounded-full bg-[#2D6A4F]" />
            <span className="text-gray-600">Trust Strength:</span>
            <span className="font-bold text-[#2D6A4F]">{p.value}/100</span>
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
            stroke="#2D6A4F"
            fill="#52B788"
            fillOpacity={0.45}
            strokeWidth={2}
          />
        </RadarChart>
      </ResponsiveContainer>
    </div>
  );
}
