"use client";
import { useCallback, useId, useMemo, useRef, useState } from "react";
import { AnimatePresence, motion, useReducedMotion } from "motion/react";

const CELL = {
  type: "spring",
  stiffness: 480,
  damping: 32,
  mass: 0.45
};
const MOVE = {
  type: "spring",
  stiffness: 280,
  damping: 28,
  mass: 0.7
};
const EASE = [0.23, 1, 0.32, 1];
const LEAVE = {
  duration: 0.16,
  ease: [0.4, 0, 1, 1]
};
const INSTANT = {
  duration: 0
};

export function useFilterGrid(
  {
    items,
    filters,
    value,
    defaultValue,
    onValueChange
  }
) {
  const fallback = filters[0]?.id ?? "";
  const [internal, setInternal] = useState(() => defaultValue ?? fallback);

  const requested = value ?? internal;
  const current = filters.find((f) => f.id === requested) ?? filters[0];
  const active = current?.id ?? fallback;

  const emit = useRef(onValueChange);
  emit.current = onValueChange;

  const counts = useMemo(() => {
    const next = {};
    for (const filter of filters) {
      let n = 0;
      for (const item of items) if (filter.match(item)) n += 1;
      next[filter.id] = n;
    }
    return next;
  }, [filters, items]);

  const visible = useMemo(() => {
    const filter = filters.find((f) => f.id === active);
    if (!filter) return [...items];
    return items.filter((item) => filter.match(item));
  }, [filters, items, active]);

  const select = useCallback(
    (id) => {
      if (value === undefined) setInternal(id);
      if (id !== active) emit.current?.(id);
    },
    [value, active],
  );

  return {
    active,
    activeLabel: current?.label ?? "",
    select,
    visible,
    counts,
    total: items.length,
  };
}

export function FilterGrid(
  {
    items,
    filters,
    getKey,
    renderItem,
    label,
    value,
    defaultValue,
    onValueChange,
    columns = 1,
    rowHeight = 72,
    maxRows = 6,
    gap = 8,
    autoHeight = false,
    itemClassName = "",
    emptyLabel = "No items match this filter",
    className = ""
  }
) {
  const uid = useId();
  const gridId = `${uid}-grid`;
  const reduced = useReducedMotion();

  const { active, activeLabel, select, visible, counts, total } = useFilterGrid({
    items,
    filters,
    value,
    defaultValue,
    onValueChange,
  });

  const gridRef = useRef(null);
  const chips = useRef([]);
  const heldFocus = useRef(false);

  const cols = Math.max(1, Math.floor(columns));
  const rows = Math.min(Math.max(1, Math.ceil(total / cols)), Math.max(1, maxRows));
  const box = rows * rowHeight + (rows - 1) * gap;

  const index = Math.max(
    0,
    filters.findIndex((f) => f.id === active),
  );

  const choose = useCallback(
    (id) => {
      const grid = gridRef.current;
      heldFocus.current =
        !!grid && grid.contains(document.activeElement) && grid !== document.activeElement;
      select(id);
    },
    [select],
  );

  const settle = useCallback(() => {
    if (!heldFocus.current) return;
    heldFocus.current = false;
    const grid = gridRef.current;
    if (grid && !grid.contains(document.activeElement)) grid.focus();
  }, []);

  const go = useCallback(
    (i) => {
      const next = filters[(i + filters.length) % filters.length];
      if (!next) return;
      chips.current[(i + filters.length) % filters.length]?.focus();
      choose(next.id);
    },
    [filters, choose],
  );

  const onKeyDown = (e, i) => {
    if (e.key === "ArrowRight" || e.key === "ArrowDown") {
      e.preventDefault();
      go(i + 1);
    } else if (e.key === "ArrowLeft" || e.key === "ArrowUp") {
      e.preventDefault();
      go(i - 1);
    } else if (e.key === "Home") {
      e.preventDefault();
      go(0);
    } else if (e.key === "End") {
      e.preventDefault();
      go(filters.length - 1);
    }
  };

  const swap = reduced ? INSTANT : CELL;
  const step = reduced ? INSTANT : { layout: MOVE, duration: 0.22, ease: EASE };
  const leave = reduced ? INSTANT : LEAVE;

  const capped = !autoHeight && Math.ceil(total / cols) > Math.max(1, maxRows);

  return (
    <div className={`w-full ${className}`}>
      {/* Interactive Spring Filter Chips */}
      <div
        role="radiogroup"
        aria-label={label}
        aria-controls={gridId}
        className="flex flex-wrap items-center gap-1.5 pb-2"
      >
        {filters.map((filter, i) => {
          const on = i === index;
          return (
            <button
              key={filter.id}
              ref={(node) => {
                chips.current[i] = node;
              }}
              type="button"
              role="radio"
              aria-checked={on}
              tabIndex={on ? 0 : -1}
              onClick={() => choose(filter.id)}
              onKeyDown={(e) => onKeyDown(e, i)}
              className="group relative inline-grid h-7 select-none place-items-center rounded-lg px-3 outline-none transition-colors"
              style={{ touchAction: "manipulation" }}
            >
              {on ? (
                <motion.span
                  aria-hidden
                  layoutId={reduced ? undefined : `${uid}-thumb`}
                  transition={CELL}
                  className="absolute inset-0 rounded-lg bg-[#0d5c46] shadow-xs"
                />
              ) : null}

              <span
                aria-hidden
                className={`pointer-events-none absolute inset-0 rounded-lg border transition-colors ${
                  on ? "border-transparent" : "border-slate-200/90 bg-white hover:bg-slate-50"
                }`}
              />
              <span className="relative col-start-1 row-start-1 inline-grid">
                <motion.span
                  aria-hidden
                  initial={false}
                  animate={{ opacity: on ? 0 : 1 }}
                  transition={swap}
                  className="col-start-1 row-start-1 inline-flex items-center gap-1.5 whitespace-nowrap text-xs font-medium text-slate-700"
                >
                  {filter.label}
                  <span className="text-[10px] font-mono tabular-nums text-slate-400">
                    {counts[filter.id]}
                  </span>
                </motion.span>
                <motion.span
                  aria-hidden
                  initial={false}
                  animate={{ opacity: on ? 1 : 0 }}
                  transition={swap}
                  className="col-start-1 row-start-1 inline-flex items-center gap-1.5 whitespace-nowrap text-xs font-semibold text-white"
                >
                  {filter.label}
                  <span className="text-[10px] font-mono tabular-nums text-emerald-100">
                    {counts[filter.id]}
                  </span>
                </motion.span>
                <span className="sr-only">
                  {filter.label}, {counts[filter.id]} of {total}
                </span>
              </span>
            </button>
          );
        })}
      </div>

      {/* Animated Spring Items Grid */}
      <div className="relative mt-2">
        <ul
          id={gridId}
          ref={gridRef}
          tabIndex={-1}
          className={`relative overflow-y-auto overscroll-contain outline-none ${
            capped ? "[scrollbar-gutter:stable]" : ""
          }`}
          style={{
            display: "grid",
            gridTemplateColumns: `repeat(${cols}, minmax(0, 1fr))`,
            gridAutoRows: autoHeight ? "auto" : `${rowHeight}px`,
            gap: `${gap}px`,
            height: autoHeight ? "auto" : `${box}px`,
          }}
        >
          <AnimatePresence initial={false} mode="popLayout" onExitComplete={settle}>
            {visible.map((item) => (
              <motion.li
                key={getKey(item)}
                layout={reduced ? false : "position"}
                initial={{ opacity: 0, scale: 0.96, y: 8 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                exit={{ opacity: 0, scale: 0.96, y: -6, transition: leave }}
                transition={step}
                className={`min-w-0 overflow-hidden rounded-xl border border-slate-200/80 bg-white p-3 shadow-xs hover:border-slate-300 transition-colors ${itemClassName}`}
              >
                {renderItem(item)}
              </motion.li>
            ))}
          </AnimatePresence>
        </ul>
        <AnimatePresence initial={false}>
          {visible.length === 0 && (
            <motion.div
              key="empty"
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.95, transition: leave }}
              transition={reduced ? INSTANT : { duration: 0.2, ease: EASE }}
              className="py-12 flex flex-col items-center justify-center text-center"
            >
              <span className="text-xs font-mono text-slate-400">
                {emptyLabel}
              </span>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
      <p aria-live="polite" className="sr-only">
        {activeLabel}: {visible.length} of {total} shown
      </p>
    </div>
  );
}

/**
 * Reusable animated card component applying the interior-style spring animation
 * to standard cards across the dashboard and app.
 */
export function AnimatedCard({
  children,
  className = "",
  delay = 0,
  hoverLift = true,
  ...props
}) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 14, scale: 0.985 }}
      animate={{ opacity: 1, y: 0, scale: 1 }}
      transition={{
        type: "spring",
        stiffness: 280,
        damping: 24,
        mass: 0.5,
        delay,
      }}
      whileHover={
        hoverLift
          ? {
              y: -3,
              transition: { type: "spring", stiffness: 400, damping: 25 },
            }
          : undefined
      }
      className={className}
      {...props}
    >
      {children}
    </motion.div>
  );
}
