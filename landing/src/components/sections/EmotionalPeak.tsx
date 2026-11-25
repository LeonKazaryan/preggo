"use client";

import { motion, useScroll, useTransform } from "framer-motion";
import { useRef } from "react";
import { RiskGauge } from "@/components/ui/RiskGauge";

export function EmotionalPeak() {
  const sectionRef = useRef<HTMLDivElement>(null);

  const { scrollYProgress } = useScroll({
    target: sectionRef,
    offset: ["start end", "end start"],
  });

  return (
    <section
      ref={sectionRef}
      id="how-it-works"
      className="relative min-h-[100vh] overflow-hidden flex items-center justify-center py-32"
      style={{
        background: `
          radial-gradient(ellipse 80% 80% at 50% 50%, rgba(253,240,236,0.7) 0%, transparent 65%),
          radial-gradient(ellipse 50% 50% at 30% 70%, rgba(232,228,240,0.35) 0%, transparent 55%),
          #FAF8F6
        `,
      }}
    >
      <div
        className="absolute inset-0 pointer-events-none"
        style={{
          backgroundImage: `
            radial-gradient(circle at 50% 50%, rgba(242,155,143,0.06) 0%, transparent 60%)
          `,
        }}
      />

      <div className="relative z-10 w-full max-w-5xl xl:max-w-6xl mx-auto px-6 sm:px-8 md:px-12 grid grid-cols-1 lg:grid-cols-2 gap-14 lg:gap-16 items-center">
        <motion.div
          className="flex flex-col items-center lg:items-start text-center lg:text-left min-w-0 w-full max-w-lg mx-auto lg:mx-0"
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-15% 0px" }}
          transition={{ duration: 1.2, ease: [0.16, 1, 0.3, 1] }}
        >
          <span className="inline-block text-[12px] font-semibold uppercase tracking-[0.18em] text-[#F29B8F] mb-8">
            The feeling
          </span>

          <h2
            className="font-bold text-[#25313D] leading-[1.06] mb-8 max-w-[520px] text-balance"
            style={{
              fontSize: "clamp(36px, 5vw, 70px)",
              letterSpacing: "-0.03em",
            }}
          >
            For the first time,
            <br />
            <span className="text-[#F29B8F]">you feel in control.</span>
          </h2>

          <p
            className="text-[#6B7280] leading-relaxed max-w-sm lg:mx-0 text-balance"
            style={{ fontSize: "clamp(15px, 1.3vw, 18px)" }}
          >
            Less noise. Less panic.
            <br />
            More clarity around what matters.
          </p>

          <motion.div
            className="mt-12 flex flex-col gap-5 max-w-sm w-full mx-auto lg:mx-0"
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
            transition={{ delay: 0.4, duration: 0.8 }}
          >
            {[
              "Know earlier, not later",
              "One clear picture, not chaos",
              "Calm, actionable intelligence",
            ].map((point) => (
              <div
                key={point}
                className="flex items-center gap-3 justify-start text-left"
              >
                <div className="w-5 h-5 rounded-full bg-[#F29B8F]/15 border border-[#F29B8F]/30 flex items-center justify-center flex-shrink-0">
                  <div className="w-1.5 h-1.5 rounded-full bg-[#F29B8F]" />
                </div>
                <span className="text-[15px] text-[#25313D] font-medium">
                  {point}
                </span>
              </div>
            ))}
          </motion.div>
        </motion.div>

        <motion.div
          className="flex w-full min-w-0 justify-center items-center"
          initial={{ opacity: 0, scale: 0.9 }}
          whileInView={{ opacity: 1, scale: 1 }}
          viewport={{ once: true, margin: "-10% 0px" }}
          transition={{ duration: 1.4, ease: [0.16, 1, 0.3, 1], delay: 0.2 }}
        >
          <div className="relative w-full max-w-[480px]">
            <RiskGauge />
          </div>
        </motion.div>
      </div>
    </section>
  );
}
