import * as React from "react"
import { Slot } from "@radix-ui/react-slot"
import { cva } from "class-variance-authority"
import { cn } from "@/lib/utils"
import { liquidProps, resolveVariant } from "@/lib/liquid-glass/material"
import { hoverEffects } from "@/lib/hover-effects"

const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-full text-sm font-medium transition-all disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg:not([class*='size-'])]:size-4 shrink-0 [&_svg]:shrink-0 outline-none focus-visible:ring-ring/50 focus-visible:ring-[3px] aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 cursor-pointer",
  {
    variants: {
      variant: {
        liquid: "text-foreground",
        glass:
          "bg-white/40 dark:bg-white/10 backdrop-blur-md border border-white/60 dark:border-white/10 text-slate-800 dark:text-slate-100 shadow-xs hover:bg-white/60 dark:hover:bg-white/15",
        default:
          "bg-[#0d5c46] text-white shadow-xs hover:bg-[#0a4837] active:scale-[0.98] active:shadow-[inset_0_2px_4px_rgba(0,0,0,0.2)]",
        destructive:
          "bg-red-600 text-white shadow-xs hover:bg-red-700 focus-visible:ring-red-500/20 active:scale-[0.98]",
        outline:
          "border border-slate-200/90 bg-white/70 backdrop-blur-xs text-slate-800 shadow-xs hover:bg-slate-100/80 hover:border-slate-300 dark:border-slate-700 dark:bg-slate-800/50 dark:hover:bg-slate-700/50 active:scale-[0.98]",
        secondary:
          "bg-slate-100/90 backdrop-blur-xs text-slate-800 shadow-xs hover:bg-slate-200/90 active:scale-[0.98]",
        ghost:
          "hover:bg-slate-100/80 hover:text-slate-900 active:bg-slate-200/80",
        link: "text-[#0d5c46] underline-offset-4 hover:underline active:opacity-80",
      },
      size: {
        default: "h-9 px-4 has-[>svg]:px-3.5",
        xs: "h-6 gap-1 px-2 text-xs has-[>svg]:px-1.5 [&_svg:not([class*='size-'])]:size-3",
        sm: "h-8 gap-1.5 px-3 text-xs has-[>svg]:px-2.5",
        lg: "h-11 px-6 text-base has-[>svg]:px-4",
        icon: "size-9",
        "icon-sm": "size-7",
        "icon-lg": "size-10",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
)

const Button = React.forwardRef(function Button(
  {
    className,
    variant,
    size,
    asChild = false,
    material,
    tint,
    glass,
    webgl,
    effect = "none",
    style,
    ...props
  },
  ref
) {
  const Comp = asChild ? Slot : "button"
  const isLiquid = variant === "liquid" || material !== undefined || tint !== undefined || glass !== undefined
  const v = resolveVariant(variant ?? (isLiquid ? "liquid" : undefined), material)
  const lg = v.variant === "liquid" ? liquidProps({ role: "control", material: v.material, tint, glass, webgl }) : null

  return (
    <Comp
      ref={ref}
      data-slot="button"
      {...lg}
      className={cn(
        buttonVariants({ variant: v.variant, size }),
        lg?.className,
        hoverEffects({ hover: effect }),
        className
      )}
      style={{ ...lg?.style, ...style }}
      {...props}
    />
  )
})

export { Button, buttonVariants }
