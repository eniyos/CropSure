import { useState, useCallback, useRef } from 'react';

/**
 * Custom hook for API calls with loading, error, caching, and retry logic.
 * @param {Function} apiFunc - Async function to call
 * @param {Object} options - Configuration options { immediate, initialData, cacheKey, retries }
 */
export function useApi(apiFunc, options = {}) {
  const {
    immediate = false,
    initialData = null,
    cacheKey = null,
    retries = 2,
    retryDelay = 1000
  } = options;

  const [data, setData] = useState(initialData);
  const [loading, setLoading] = useState(immediate);
  const [error, setError] = useState(null);

  // In-memory cache map stored across renders
  const cacheRef = useRef(new Map());

  const execute = useCallback(async (...args) => {
    const key = cacheKey ? `${cacheKey}_${JSON.stringify(args)}` : null;

    if (key && cacheRef.current.has(key)) {
      setData(cacheRef.current.get(key));
      setLoading(false);
      return cacheRef.current.get(key);
    }

    setLoading(true);
    setError(null);

    let attempt = 0;
    while (attempt <= retries) {
      try {
        const result = await apiFunc(...args);
        setData(result);
        if (key) {
          cacheRef.current.set(key, result);
        }
        setLoading(false);
        return result;
      } catch (err) {
        attempt++;
        if (attempt > retries) {
          const errMsg = err?.response?.data?.message || err?.message || 'An unexpected error occurred';
          setError(errMsg);
          setLoading(false);
          throw err;
        }
        await new Promise(r => setTimeout(r, retryDelay * attempt));
      }
    }
  }, [apiFunc, cacheKey, retries, retryDelay]);

  const reset = useCallback(() => {
    setData(initialData);
    setLoading(false);
    setError(null);
  }, [initialData]);

  const clearCache = useCallback(() => {
    cacheRef.current.clear();
  }, []);

  return {
    data,
    loading,
    error,
    execute,
    setData,
    reset,
    clearCache
  };
}

export default useApi;
