import React, { forwardRef } from "react";
import { cn } from "@/lib/cn";

/**
 * DotGridPattern
 * From OpenSourceUI (MIT License)
 * Subtle minimal dot-grid canvas pattern.
 */
const DotGridPattern = forwardRef(
  ({ children, className, ...props }, ref) => {
    return (
      <div
        ref={ref}
        data-slot="dot-grid-pattern"
        className={cn(
          "relative isolate overflow-hidden bg-neutral-50 [background-image:radial-gradient(circle,#e8e8e8_1px,transparent_1px)] [background-size:12px_12px]",
          className
        )}
        {...props}
      >
        {children}
      </div>
    );
  }
);

DotGridPattern.displayName = "DotGridPattern";

export { DotGridPattern };
export default DotGridPattern;
