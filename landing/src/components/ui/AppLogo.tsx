import Image from "next/image";
import { cn } from "@/lib/utils";
import logo from "@/assets/logo.png";

const DIMENSIONS = {
  sm: 24,
  md: 28,
  lg: 32,
} as const;

type AppLogoProps = {
  size?: keyof typeof DIMENSIONS;
  className?: string;
  priority?: boolean;
};

export function AppLogo({ size = "md", className, priority }: AppLogoProps) {
  const px = DIMENSIONS[size];
  return (
    <Image
      src={logo}
      alt="Preggo"
      width={px}
      height={px}
      priority={priority}
      className={cn(
        "rounded-[22%] object-cover shadow-[0_2px_10px_rgba(242,155,143,0.35)]",
        className,
      )}
    />
  );
}
