"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { motion } from "framer-motion";
import { CTAButton } from "@/components/ui/CTAButton";

function useCountUp(target: number, duration = 1500) {
  const [value, setValue] = useState(0);
  const startedRef = useRef(false);

  const start = useCallback(() => {
    if (startedRef.current) return;
    startedRef.current = true;
    const startTime = performance.now();

    const tick = (now: number) => {
      const elapsed = now - startTime;
      const progress = Math.min(elapsed / duration, 1);
      const eased = 1 - Math.pow(1 - progress, 3);
      setValue(Math.round(eased * target));
      if (progress < 1) requestAnimationFrame(tick);
    };

    requestAnimationFrame(tick);
  }, [target, duration]);

  return { value, start };
}

export function Pricing() {
  const sectionRef = useRef<HTMLDivElement>(null);
  const { value: price, start } = useCountUp(159, 1200);

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) start();
      },
      { threshold: 0.4 },
    );
    if (sectionRef.current) observer.observe(sectionRef.current);
    return () => observer.disconnect();
  }, [start]);

  return (
    <section
      ref={sectionRef}
      id="pricing"
      className="relative flex min-h-[100vh] items-center justify-center overflow-hidden py-20 lg:py-24"
      style={{
        background: `
          radial-gradient(ellipse 70% 60% at 50% 50%, rgba(253,240,236,0.65) 0%, transparent 65%),
          #F8F6F4
        `,
      }}
    >
      <div className="mx-auto w-full max-w-2xl px-6 text-center">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.9, ease: [0.16, 1, 0.3, 1] }}
          className="flex flex-col items-center"
        >
          <span className="mb-14 inline-block text-[clamp(13px,1.4vw,16px)] font-bold uppercase tracking-[0.25em] text-[#F29B8F]">
            Simple, honest pricing
          </span>

          <div className="mb-12">
            <div
              className="font-bold leading-none text-[#25313D]"
              style={{
                fontSize: "clamp(100px, 14vw, 160px)",
                letterSpacing: "-0.05em",
              }}
            >
              ${price}
            </div>
            <div className="mt-6 text-[20px] font-medium tracking-wide text-[#9CA3AF]">
              per year
            </div>
          </div>

          <p
            className="mb-16 mt-12 w-full max-w-lg text-center text-pretty leading-relaxed text-[#6B7280]"
            style={{ fontSize: "clamp(17px, 1.5vw, 20px)" }}
          >
            Less than one doctor visit.
            <br />
            More clarity throughout your entire pregnancy.
          </p>

          <div className="mb-16">
            <CTAButton size="lg" href="#">
              Join beta →
            </CTAButton>
          </div>

          <p className="mb-16 text-[15px] text-[#9CA3AF]">
            Or <span className="font-medium text-[#6B7280]">$15 / month</span> —
            try before committing
          </p>

          <div className="flex flex-wrap items-center justify-center gap-x-10 gap-y-5">
            {[
              "Early access pricing",
              "Cancel anytime",
              "iOS · Coming soon",
            ].map((item) => (
              <span
                key={item}
                className="flex items-center gap-1.5 text-[11.5px] text-[#9CA3AF]"
              >
                <div className="w-1 h-1 rounded-full bg-[#F29B8F]/60" />
                {item}
              </span>
            ))}
          </div>
        </motion.div>
      </div>
    </section>
  );
}
