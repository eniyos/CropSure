"use client";

import React, { forwardRef } from "react";
import { cn } from "@/lib/cn";

const SHEEN_PILL_RADIUS = 9999;

const SHEEN_SHELL =
  "group relative inline-flex shrink-0 cursor-pointer items-center justify-center gap-2 overflow-hidden border border-double border-[rgba(51,51,51,0.08)] bg-[rgba(255,255,255,0.85)] backdrop-blur-[5px] brightness-[1.02]";

const SHEEN_SHELL_SHADOW =
  "[box-shadow:inset_2px_-2px_1px_-1px_rgba(255,255,255,0.9),inset_-2px_2px_1px_-1px_rgba(255,255,255,0.9),inset_6px_-6px_1px_-6px_rgba(255,255,255,0.55),inset_-6px_6px_1px_-6px_rgba(255,255,255,0.55),inset_0_0_2px_rgba(0,0,0,0.4),0_2px_6px_rgba(15,23,42,0.06)]";

const SHEEN_SHELL_HOVER_SHADOW =
  "hover:[box-shadow:inset_2px_-2px_1px_-1px_rgba(255,255,255,0.95),inset_-2px_2px_1px_-1px_rgba(255,255,255,0.95),inset_6px_-6px_1px_-6px_rgba(255,255,255,0.65),inset_-6px_6px_1px_-6px_rgba(255,255,255,0.65),inset_0_0_2px_rgba(0,0,0,0.5),0_4px_10px_rgba(15,23,42,0.1)]";

export const SheenPillButton = forwardRef(
  (
    {
      as: Component = "button",
      children,
      className,
      labelClassName,
      width = 180,
      height = 42,
      highlight = 15,
      type = "button",
      disabled,
      style,
      ...props
    },
    ref
  ) => {
    const Tag = props.href ? "a" : Component;
    const isNumWidth = typeof width === "number";
    const isNumHeight = typeof height === "number";

    const shadeVeilWidth = isNumWidth ? Math.max(0, width - 16) : `calc(100% - 16px)`;
    const shadeVeilHeight = isNumHeight ? Math.max(0, height - 16) : `calc(100% - 16px)`;
    const rimWireWidth = isNumWidth ? Math.max(0, width - 9) : `calc(100% - 9px)`;
    const rimWireHeight = isNumHeight ? Math.max(0, height - 9) : `calc(100% - 9px)`;

    return (
      <Tag
        ref={ref}
        {...(Tag === "button" ? { type, disabled } : {})}
        data-slot="sheen-pill-button"
        className={cn(
          SHEEN_SHELL,
          "transition-[transform,background-color,box-shadow,filter] duration-250 ease-linear motion-reduce:transition-none",
          "hover:scale-[1.02] hover:bg-white hover:brightness-105",
          "active:scale-100 motion-reduce:hover:scale-100",
          "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-900",
          "disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50",
          SHEEN_SHELL_SHADOW,
          SHEEN_SHELL_HOVER_SHADOW,
          className
        )}
        style={{
          width,
          height,
          borderRadius: SHEEN_PILL_RADIUS,
          ...style,
        }}
        {...props}
      >
        <span
          aria-hidden="true"
          data-layer="sheen-shade-veil"
          className="pointer-events-none absolute top-[35%] left-1/2 z-0 -translate-x-1/2 border border-[rgba(0,0,0,0.8)] blur-sm transition-[opacity,transform,filter] duration-250 ease-linear group-hover:opacity-80 group-hover:blur-md motion-reduce:transition-none"
          style={{
            width: shadeVeilWidth,
            height: shadeVeilHeight,
            borderRadius: SHEEN_PILL_RADIUS,
          }}
        />

        <span
          aria-hidden="true"
          data-layer="sheen-light-band"
          className="pointer-events-none absolute inset-0 z-10 opacity-80 blur-[7px] transition-[opacity,transform,filter] duration-250 ease-linear group-hover:scale-105 group-hover:opacity-100 group-hover:blur-[9px] motion-reduce:transition-none motion-reduce:group-hover:scale-100"
          style={{
            borderRadius: SHEEN_PILL_RADIUS,
            background: `linear-gradient(45deg, rgba(255,255,255,0.85) 0%, transparent ${highlight}%, transparent calc(100% - ${highlight}%), rgba(255,255,255,0.85) 100%)`,
          }}
        />

        <span
          aria-hidden="true"
          data-layer="sheen-rim-wire"
          className="pointer-events-none absolute top-1/2 left-1/2 z-20 -translate-x-1/2 -translate-y-1/2 border border-[rgba(255,255,255,0.25)] blur-[1px] transition-[border-color,opacity] duration-250 ease-linear group-hover:border-[rgba(255,255,255,0.5)] group-hover:opacity-100 motion-reduce:transition-none"
          style={{
            width: rimWireWidth,
            height: rimWireHeight,
            borderRadius: SHEEN_PILL_RADIUS,
          }}
        />

        <span
          data-layer="sheen-label-well"
          className="relative z-30 flex h-full w-full items-center justify-center gap-2 px-[0.8rem]"
        >
          <span
            data-layer="sheen-label"
            className={cn(
              "leading-none whitespace-nowrap text-slate-800 filter-[drop-shadow(0_12px_3px_rgba(15,23,42,0.08))] transition-[color,filter,transform] duration-250 ease-linear group-hover:translate-y-[-0.5px] group-hover:text-slate-950 motion-reduce:transition-none motion-reduce:group-hover:translate-y-0 font-semibold flex items-center justify-center gap-2",
              typeof height === "number" && height >= 56 ? "text-base" : "text-xs sm:text-sm",
              labelClassName
            )}
          >
            {children}
          </span>
        </span>
      </Tag>
    );
  }
);

SheenPillButton.displayName = "SheenPillButton";

export default SheenPillButton;
