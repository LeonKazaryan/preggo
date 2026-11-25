"use client";

import { motion } from "framer-motion";
import { cn } from "@/lib/utils";

interface CTAButtonProps {
  children: React.ReactNode;
  variant?: "primary" | "secondary" | "ghost";
  size?: "sm" | "md" | "lg";
  href?: string;
  onClick?: () => void;
  className?: string;
  disabled?: boolean;
}

export function CTAButton({
  children,
  variant = "primary",
  size = "md",
  href,
  onClick,
  className,
  disabled,
}: CTAButtonProps) {
  const base =
    "inline-flex items-center justify-center font-semibold rounded-full transition-all duration-300 cursor-pointer select-none";

  const variants = {
    primary:
      "bg-[#F29B8F] text-white hover:bg-[#E5867B] shadow-[0_4px_24px_rgba(242,155,143,0.35)] hover:shadow-[0_6px_32px_rgba(242,155,143,0.5)]",
    secondary:
      "bg-white/80 backdrop-blur-sm text-[#25313D] border border-[#F8D8D0] hover:bg-white hover:border-[#F29B8F]",
    ghost:
      "bg-transparent text-[#25313D] hover:bg-[#FDF0EC] border border-transparent hover:border-[#F8D8D0]",
  };

  const sizes = {
    sm: "px-5 py-2.5 min-h-[40px] text-[13.5px] leading-none",
    md: "px-8 py-3.5 min-h-[50px] text-[15px] leading-none",
    lg: "px-10 py-4 min-h-[56px] text-[16px] leading-none font-bold",
  };

  const classes = cn(base, variants[variant], sizes[size], className);

  const motionProps = {
    whileHover: { scale: 1.02 },
    whileTap: { scale: 0.97 },
    transition: {
      duration: 0.2,
      ease: [0.16, 1, 0.3, 1] as [number, number, number, number],
    },
  };

  if (href) {
    return (
      <motion.a href={href} className={classes} {...motionProps}>
        {children}
      </motion.a>
    );
  }

  return (
    <motion.button
      onClick={onClick}
      disabled={disabled}
      className={classes}
      {...motionProps}
    >
      {children}
    </motion.button>
  );
}
