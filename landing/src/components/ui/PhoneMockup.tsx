"use client";

import Image, { type StaticImageData } from "next/image";
import { cn } from "@/lib/utils";
import appScreen from "@/assets/screen1.png";

interface PhoneMockupProps {
  src?: StaticImageData;
  className?: string;
  style?: React.CSSProperties;
  scale?: number;
  priority?: boolean;
}

export function PhoneMockup({
  src,
  className,
  style,
  scale = 1,
  priority = false,
}: PhoneMockupProps) {
  const screenSrc = src ?? appScreen;
  const maxPx = 300 * scale;
  return (
    <div
      className={cn(
        "relative mx-auto w-full [filter:drop-shadow(0_22px_48px_rgba(0,0,0,0.14))]",
        className,
      )}
      style={{ maxWidth: maxPx, ...style }}
    >
      <Image
        src={screenSrc}
        alt="Preggo app screen"
        sizes="(max-width: 640px) 85vw, (max-width: 1024px) 45vw, 320px"
        className="block h-auto w-full max-w-full bg-transparent [backface-visibility:hidden] [transform:translateZ(0)]"
        priority={priority}
      />
    </div>
  );
}
