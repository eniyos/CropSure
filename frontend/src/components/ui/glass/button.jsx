"use client"

import * as React from "react"
import { Button as BaseButton } from "@/components/ui/button"
import { cn } from "@/lib/utils"
import { hoverEffects } from "@/lib/hover-effects"

/**
 * Glass UI Button - liquid glass capsule by default with ripple, shimmer, glow, lift, or scale hover effects.
 *
 * @example
 * <Button>Continue</Button>
 * <Button material="clear">Clear glass</Button>
 * <Button material="tinted" tint="#0d5c46">Tinted</Button>
 * <Button effect="glow">Glow button</Button>
 * <Button effect="shimmer">Shimmer button</Button>
 * <Button effect="lift">Lift button</Button>
 */
export const Button = React.forwardRef(
  ({ className, effect = "none", variant = "liquid", ...props }, ref) => {
    return (
      <BaseButton
        ref={ref}
        variant={variant}
        effect={effect}
        className={cn("relative overflow-hidden", className)}
        {...props}
      />
    )
  }
)
Button.displayName = "GlassButton"

export default Button
