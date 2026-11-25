"use client";

import { useEffect, useRef } from "react";
import { motion } from "framer-motion";
import { CTAButton } from "@/components/ui/CTAButton";
import { AppLogo } from "@/components/ui/AppLogo";

function OrbitingTrails() {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;

    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    let raf: number;
    let isVisible = false;

    const observer = new IntersectionObserver(
      ([entry]) => {
        isVisible = entry.isIntersecting;
      },
      { threshold: 0 },
    );
    observer.observe(canvas);

    const orbits = [
      { rx: 220, ry: 80,  speed: 1,    color: "rgba(242,155,143", alpha: 0.15, width: 1.0 },
      { rx: 290, ry: 115, speed: -0.7, color: "rgba(232,228,240", alpha: 0.12, width: 0.7 },
      { rx: 175, ry: 58,  speed: 1.4,  color: "rgba(248,216,208", alpha: 0.1,  width: 0.9 },
      { rx: 350, ry: 145, speed: -0.5, color: "rgba(200,217,232", alpha: 0.08, width: 0.6 },
    ];

    const resize = () => {
      canvas.width = canvas.offsetWidth;
      canvas.height = canvas.offsetHeight;
    };
    resize();
    window.addEventListener("resize", resize);

    const draw = (time: number) => {
      raf = requestAnimationFrame(draw);
      if (!isVisible) return;

      const cx = canvas.width / 2;
      const cy = canvas.height / 2;
      const t = time * 0.0003;

      ctx.clearRect(0, 0, canvas.width, canvas.height);

      for (const o of orbits) {
        ctx.beginPath();
        ctx.ellipse(cx, cy, o.rx, o.ry, 0, 0, Math.PI * 2);
        ctx.strokeStyle = `${o.color},${o.alpha})`;
        ctx.lineWidth = o.width;
        ctx.stroke();

        const headAngle = t * o.speed;
        const hx = cx + Math.cos(headAngle) * o.rx;
        const hy = cy + Math.sin(headAngle) * o.ry;
        ctx.beginPath();
        ctx.arc(hx, hy, 2.5, 0, Math.PI * 2);
        ctx.fillStyle = `${o.color},${o.alpha * 2.8})`;
        ctx.fill();
      }
    };

    raf = requestAnimationFrame(draw);
    return () => {
      cancelAnimationFrame(raf);
      observer.disconnect();
      window.removeEventListener("resize", resize);
    };
  }, []);

  return (
    <canvas
      ref={canvasRef}
      className="absolute inset-0 w-full h-full"
      style={{ pointerEvents: "none" }}
    />
  );
}

export function FinalCTA() {
  return (
    <section
      className="relative min-h-[100vh] overflow-hidden flex items-center justify-center py-40"
      style={{
        background: `
          radial-gradient(ellipse 80% 70% at 50% 50%, rgba(26,31,46,0.97) 0%, #0A0D18 100%)
        `,
      }}
    >
      <OrbitingTrails />

      <div
        className="absolute inset-0 pointer-events-none"
        style={{
          background:
            "radial-gradient(ellipse 55% 55% at 50% 50%, rgba(242,155,143,0.09) 0%, transparent 65%)",
        }}
      />

      <div className="relative z-10 mx-auto box-border w-full max-w-2xl px-6 text-center sm:px-8">
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-15% 0px" }}
          transition={{ duration: 1.2, ease: [0.16, 1, 0.3, 1] }}
          className="flex flex-col items-center"
        >
          <div className="mb-12 flex items-center justify-center gap-2">
            <AppLogo
              size="lg"
              className="shadow-[0_4px_24px_rgba(242,155,143,0.5)]"
            />
            <span className="text-[17px] font-bold text-white tracking-tight">
              Preggo
            </span>
          </div>

          <h2
            className="mb-7 w-full font-bold leading-[1.06] text-white text-balance"
            style={{
              fontSize: "clamp(38px, 5.5vw, 76px)",
              letterSpacing: "-0.03em",
            }}
          >
            You can&apos;t control everything.
            <br />
            <span className="text-[#F29B8F]">But you can understand.</span>
          </h2>

          <p
            className="mb-14 w-full text-pretty leading-relaxed text-[rgba(255,255,255,0.5)]"
            style={{ fontSize: "clamp(15px, 1.3vw, 18px)" }}
          >
            Preggo helps turn uncertainty into clarity — through monitoring,
            interpretation, and calm, actionable insight.
          </p>

          <motion.div
            whileInView={{ scale: [0.97, 1] }}
            viewport={{ once: true }}
            transition={{ duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
          >
            <CTAButton
              size="lg"
              href="#pricing"
              className="text-[16px] px-12 py-[18px] min-h-[56px] shadow-[0_8px_40px_rgba(242,155,143,0.45)]"
            >
              Start your pregnancy with clarity
            </CTAButton>
          </motion.div>

          <p className="text-[12px] text-[rgba(255,255,255,0.28)] mt-10 tracking-wide leading-relaxed">
            Available on iOS · Early access open now
          </p>
        </motion.div>
      </div>
    </section>
  );
}
