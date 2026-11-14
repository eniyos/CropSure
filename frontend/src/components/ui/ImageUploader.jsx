import React, { useCallback, useState } from 'react';
import { useDropzone } from 'react-dropzone';
import { UploadCloud, Image as ImageIcon, X, AlertCircle, Sparkles, CheckCircle2 } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

// Real PlantVillage demonstration images that users can click to load instantly
const SAMPLE_LEAVES = [
  {
    name: 'Early Blight',
    filename: 'early_blight_sample.jpg',
    url: '/samples/early_blight_sample.jpg',
    disease: 'Early Blight (Alternaria solani)'
  },
  {
    name: 'Late Blight',
    filename: 'late_blight_sample.jpg',
    url: '/samples/late_blight_sample.jpg',
    disease: 'Late Blight (Phytophthora infestans)'
  },
  {
    name: 'Bacterial Spot',
    filename: 'bacterial_spot_sample.jpg',
    url: '/samples/bacterial_spot_sample.jpg',
    disease: 'Bacterial Spot (Xanthomonas)'
  },
  {
    name: 'Leaf Mold',
    filename: 'leaf_mold_sample.jpg',
    url: '/samples/leaf_mold_sample.jpg',
    disease: 'Leaf Mold (Passalora fulva)'
  },
  {
    name: 'Septoria Spot',
    filename: 'septoria_sample.jpg',
    url: '/samples/septoria_sample.jpg',
    disease: 'Septoria Leaf Spot (Septoria lycopersici)'
  },
  {
    name: 'Spider Mites',
    filename: 'spider_mites_sample.jpg',
    url: '/samples/spider_mites_sample.jpg',
    disease: 'Spider Mites (Tetranychus urticae)'
  },
  {
    name: 'Target Spot',
    filename: 'target_spot_sample.jpg',
    url: '/samples/target_spot_sample.jpg',
    disease: 'Target Spot (Corynespora cassiicola)'
  },
  {
    name: 'Healthy Foliage',
    filename: 'healthy_leaf_sample.jpg',
    url: '/samples/healthy_leaf_sample.jpg',
    disease: 'Healthy Tomato Foliage'
  }
];

export default function ImageUploader({
  selectedImage,
  onImageSelect,
  onClear,
  maxSizeMB = 10,
  className = ''
}) {
  const [error, setError] = useState(null);
  const [loadingSample, setLoadingSample] = useState(false);

  const onDrop = useCallback((acceptedFiles, rejectedFiles) => {
    setError(null);
    if (rejectedFiles && rejectedFiles.length > 0) {
      const rej = rejectedFiles[0];
      if (rej.errors[0]?.code === 'file-too-large') {
        setError(`File is too large. Maximum allowed size is ${maxSizeMB}MB.`);
      } else {
        setError(rej.errors[0]?.message || 'Invalid file format. Please upload JPG, PNG or WebP.');
      }
      return;
    }

    if (acceptedFiles && acceptedFiles.length > 0) {
      const file = acceptedFiles[0];
      const previewUrl = URL.createObjectURL(file);
      onImageSelect({
        file,
        previewUrl,
        name: file.name,
        size: (file.size / (1024 * 1024)).toFixed(2) + ' MB',
      });
    }
  }, [maxSizeMB, onImageSelect]);

  const { getRootProps, getInputProps, isDragActive, isDragReject } = useDropzone({
    onDrop,
    accept: {
      'image/jpeg': ['.jpeg', '.jpg'],
      'image/png': ['.png'],
      'image/webp': ['.webp']
    },
    maxSize: maxSizeMB * 1024 * 1024,
    multiple: false
  });

  const handleSelectSample = async (sample) => {
    setError(null);
    setLoadingSample(true);
    try {
      // Fetch sample as blob
      const response = await fetch(sample.url);
      const blob = await response.blob();
      const file = new File([blob], sample.filename, { type: 'image/jpeg' });
      const sizeStr = blob.size > 1024 * 1024 
        ? `${(blob.size / (1024 * 1024)).toFixed(2)} MB` 
        : `${(blob.size / 1024).toFixed(1)} KB`;
      onImageSelect({
        file,
        previewUrl: sample.url,
        name: sample.filename,
        size: sizeStr,
        sampleTag: sample.disease
      });
    } catch (e) {
      // In case cross-origin fails, use direct URL
      onImageSelect({
        file: null,
        previewUrl: sample.url,
        name: sample.filename,
        size: '18.2 KB',
        sampleTag: sample.disease
      });
    } finally {
      setLoadingSample(false);
    }
  };

  return (
    <div className={`w-full ${className}`}>
      <AnimatePresence mode="wait">
        {!selectedImage ? (
          <motion.div
            key="dropzone"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
          >
            <div
              {...getRootProps()}
              className={`relative cursor-pointer rounded-2xl border-2 border-dashed p-8 transition-all duration-200 text-center flex flex-col items-center justify-center bg-white ${
                isDragActive
                  ? 'border-[#2D6A4F] bg-[#2D6A4F]/5 shadow-inner'
                  : isDragReject
                  ? 'border-rose-400 bg-rose-50/50'
                  : 'border-emerald-900/20 hover:border-[#2D6A4F] hover:bg-emerald-50/20'
              }`}
            >
              <input {...getInputProps()} />

              <div className="w-16 h-16 rounded-2xl bg-emerald-100/60 flex items-center justify-center text-[#2D6A4F] mb-4 shadow-xs">
                <UploadCloud className="w-8 h-8" />
              </div>

              <h4 className="text-base font-semibold text-gray-900 mb-1">
                {isDragActive ? 'Drop your leaf image here' : 'Drag & drop leaf photo here, or click to browse'}
              </h4>
              <p className="text-xs text-gray-500 max-w-sm mb-4">
                Supports High-Resolution JPG, PNG, and WebP (up to {maxSizeMB}MB). Captured in daylight for best diagnostic accuracy.
              </p>

              <div className="flex items-center gap-2 text-xs font-medium text-[#2D6A4F] bg-[#2D6A4F]/10 px-3 py-1.5 rounded-full">
                <Sparkles className="w-3.5 h-3.5" />
                <span>AI auto-enhancement and leaf segmentation active</span>
              </div>
            </div>

            {error && (
              <motion.div
                initial={{ opacity: 0, y: -6 }}
                animate={{ opacity: 1, y: 0 }}
                className="mt-3 flex items-center gap-2 text-xs text-rose-600 bg-rose-50 border border-rose-200 p-2.5 rounded-lg"
              >
                <AlertCircle className="w-4 h-4 shrink-0" />
                <span>{error}</span>
              </motion.div>
            )}

            {/* Quick Demo Samples */}
            <div className="mt-5">
              <div className="flex items-center justify-between mb-2.5">
                <span className="text-xs font-semibold text-gray-500 uppercase tracking-wider">
                  Or Test With Demo Leaf Samples:
                </span>
                {loadingSample && (
                  <span className="text-xs text-[#2D6A4F] animate-pulse">Loading sample...</span>
                )}
              </div>
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-2.5">
                {SAMPLE_LEAVES.map((sample, idx) => (
                  <button
                    key={idx}
                    type="button"
                    onClick={() => handleSelectSample(sample)}
                    className="flex flex-col items-center gap-1.5 p-2 rounded-xl bg-white border border-gray-200 hover:border-[#2D6A4F] hover:shadow-sm transition-all text-left group"
                  >
                    <div className="w-full h-16 rounded-lg overflow-hidden relative bg-gray-100">
                      <img
                        src={sample.url}
                        alt={sample.name}
                        className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                      />
                    </div>
                    <span className="text-[11px] font-medium text-gray-800 line-clamp-1 w-full text-center group-hover:text-[#2D6A4F]">
                      {sample.name}
                    </span>
                  </button>
                ))}
              </div>
            </div>
          </motion.div>
        ) : (
          <motion.div
            key="preview"
            initial={{ opacity: 0, scale: 0.98 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0 }}
            className="bg-white rounded-2xl border border-gray-200 p-4 shadow-sm"
          >
            <div className="flex items-center justify-between pb-3 border-b border-gray-100">
              <div className="flex items-center gap-2">
                <CheckCircle2 className="w-4 h-4 text-[#2D6A4F]" />
                <span className="text-xs font-semibold text-gray-700">Image Ready for Neural Inference</span>
              </div>
              <button
                type="button"
                onClick={onClear}
                className="flex items-center gap-1 text-xs text-gray-400 hover:text-rose-600 transition-colors px-2 py-1 rounded-md hover:bg-rose-50"
              >
                <X className="w-3.5 h-3.5" />
                <span>Remove</span>
              </button>
            </div>

            <div className="mt-3 flex flex-col sm:flex-row gap-4 items-center">
              <div className="relative w-full sm:w-48 h-44 rounded-xl overflow-hidden bg-gray-950 border border-gray-200 shrink-0">
                <img
                  src={selectedImage.previewUrl}
                  alt="Leaf preview"
                  className="w-full h-full object-cover"
                />
                <div className="absolute bottom-2 left-2 px-2 py-0.5 rounded bg-black/60 backdrop-blur-md text-white text-[10px] font-mono">
                  {selectedImage.size}
                </div>
              </div>

              <div className="flex-1 space-y-2 text-left w-full">
                <div>
                  <h4 className="text-sm font-bold text-gray-900 truncate">
                    {selectedImage.name}
                  </h4>
                  {selectedImage.sampleTag && (
                    <span className="inline-block mt-1 text-[11px] bg-emerald-50 text-[#2D6A4F] font-medium px-2 py-0.5 rounded-full border border-emerald-200">
                      Sample: {selectedImage.sampleTag}
                    </span>
                  )}
                </div>

                <div className="grid grid-cols-2 gap-2 text-xs pt-2">
                  <div className="bg-[#FAFAF5] p-2.5 rounded-lg border border-gray-100">
                    <span className="text-gray-400 block text-[10px] uppercase font-semibold">Format</span>
                    <span className="text-gray-800 font-medium">RGB (3 channels)</span>
                  </div>
                  <div className="bg-[#FAFAF5] p-2.5 rounded-lg border border-gray-100">
                    <span className="text-gray-400 block text-[10px] uppercase font-semibold">Target Spec</span>
                    <span className="text-gray-800 font-medium">Solanaceae Foliage</span>
                  </div>
                </div>

                <p className="text-[11px] text-gray-500 pt-1">
                  Ready to stream to EfficientNet-B4 + Grad-CAM explanation + Van der Plank epidemic projection models.
                </p>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
