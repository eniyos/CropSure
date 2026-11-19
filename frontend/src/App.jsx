import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { TooltipProvider } from '@/components/ui/tooltip';
import Layout from './components/Layout/Layout';
import Dashboard from './pages/Dashboard';
import AnalyzePage from './pages/AnalyzePage';
import ForecastPage from './pages/ForecastPage';
import EpidemicPage from './pages/EpidemicPage';
import ModelsPage from './pages/ModelsPage';
import AboutPage from './pages/AboutPage';

export default function App() {
  return (
    <TooltipProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Layout />}>
            <Route index element={<Dashboard />} />
            <Route path="analyze" element={<AnalyzePage />} />
            <Route path="forecast" element={<ForecastPage />} />
            <Route path="epidemic" element={<EpidemicPage />} />
            <Route path="models" element={<ModelsPage />} />
            <Route path="about" element={<AboutPage />} />
            {/* Fallback to Dashboard */}
            <Route path="*" element={<Navigate to="/" replace />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </TooltipProvider>
  );
}
