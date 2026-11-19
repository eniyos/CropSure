import { cn } from "@/lib/utils";

const PRESET = {
  surface: "card", sheet: "sheet", bar: "bar", control: "button", knob: "knob", inline: null, overlay: null,
}
// Roles whose elements usually float over page content default to CSS-only.
const WEBGL_DEFAULT = {
  surface: true, sheet: false, bar: true, control: true, knob: true, inline: false, overlay: false,
}
const PARAMS = {
  regular: { frost: 1, tint: 0.2 },
  clear: { frost: 0.1, tint: 0 },
  tinted: { frost: 0.6, tint: 0.35 },
}
export function liquidGlass(
  {
    role,
    material = "regular",
    tint,
    glass,
    webgl = WEBGL_DEFAULT[role]
  }
) {
  const p = PARAMS[material]
  const color = glass?.tint ?? tint
  const frost = glass?.frost ?? p.frost
  const style = {}
  if (color) {
    style["--lg-tint"] = color
    if (material !== "tinted") style["--lg-tint-amt"] = "18%"
  }
  const preset = webgl ? PRESET[role] : null
  const attrs = preset
    ? { "data-glass": preset, "data-frost": String(frost), "data-tint": String(p.tint) }
    : {}
  return { className: `lg lg-${material} lg-${role}`, style: style, attrs };
}

/** Spread onto an element: material classes/attrs merged with the element's own className and style. */
export function liquidProps(opts, own = {}) {
  const r = liquidGlass(opts)
  return { ...r.attrs, className: cn(r.className, own.className), style: { ...r.style, ...own.style } }
}

/** A component's `variant` (default `liquid`) together with its material (default `regular`). */
export function resolveVariant(variant, material) {
  return { variant: (variant ?? "liquid"), material: material ?? "regular" };
}
