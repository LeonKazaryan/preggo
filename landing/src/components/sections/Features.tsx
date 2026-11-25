"use client";

import { useRef } from "react";
import type { StaticImageData } from "next/image";
import { motion, useScroll, useTransform } from "framer-motion";
import { PhoneMockup } from "@/components/ui/PhoneMockup";
import { Heartbeat } from "@/components/ui/Heartbeat";
import { GlassCard } from "@/components/ui/GlassCard";
import { cn } from "@/lib/utils";
import feature1 from "@/assets/feature1.png";
import feature2 from "@/assets/feature2.png";
import feature3 from "@/assets/feature3.png";
import feature4 from "@/assets/feature4.png";

interface FeatureSceneProps {
  overline: string;
  headline: string;
  body: string;
  align: "left" | "right";
  image: StaticImageData;
  accent?: React.ReactNode;
}

function FeatureScene({
  overline,
  headline,
  body,
  align,
  image,
  accent,
}: FeatureSceneProps) {
  const ref = useRef<HTMLDivElement>(null);
  const textOnLeft = align === "left";
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start end", "center center"],
  });
  const opacity = useTransform(scrollYProgress, [0, 0.5], [0, 1]);
  const y = useTransform(scrollYProgress, [0, 0.5], [50, 0]);

  return (
    <div
      ref={ref}
      className={cn(
        "flex flex-col items-center gap-12 py-20 lg:flex-row lg:py-28",
        textOnLeft ? "lg:gap-12 xl:gap-14" : "lg:gap-20",
        align === "right" ? "lg:flex-row-reverse" : "",
      )}
    >
      <motion.div
        style={{ opacity, y }}
        className={cn(
          "flex min-w-0 flex-1 flex-col items-center justify-center text-center lg:text-left",
          textOnLeft ? "lg:items-end" : "lg:items-start",
        )}
      >
        <div
          className={cn(
            "mx-auto w-full",
            textOnLeft
              ? "max-w-[560px] lg:ml-auto lg:mr-0 lg:pl-2 xl:pl-4"
              : "max-w-[480px] lg:mx-0",
          )}
        >
          <span className="mb-5 block text-[clamp(13px,1.4vw,16px)] font-bold uppercase tracking-[0.14em] text-[#F29B8F]">
            {overline}
          </span>
          <h3
            className="font-bold text-[#25313D] mb-5 leading-[1.06]"
            style={{
              fontSize: textOnLeft
                ? "clamp(30px, 3.8vw, 58px)"
                : "clamp(28px, 3.5vw, 52px)",
              letterSpacing: "-0.03em",
            }}
          >
            {headline}
          </h3>
          <p
            className="text-[#6B7280] leading-relaxed"
            style={{ fontSize: "clamp(15px, 1.1vw, 17px)" }}
          >
            {body}
          </p>
          {accent && <div className="mt-8">{accent}</div>}
        </div>
      </motion.div>

      <motion.div
        className="flex-1 flex w-full min-w-0 justify-center items-center"
        initial={{ opacity: 0, scale: 0.93 }}
        whileInView={{ opacity: 1, scale: 1 }}
        viewport={{ once: true, margin: "-10% 0px" }}
        transition={{ duration: 1.2, ease: [0.16, 1, 0.3, 1] }}
      >
        <div className="relative w-full max-w-[300px]">
          <div
            className="absolute -inset-16 rounded-full blur-3xl opacity-25 pointer-events-none"
            style={{
              background:
                "radial-gradient(circle, rgba(242,155,143,0.5) 0%, rgba(232,228,240,0.3) 60%, transparent 100%)",
            }}
          />
          <PhoneMockup src={image} scale={1} />
        </div>
      </motion.div>
    </div>
  );
}

export function Features() {
  return (
    <section id="features" className="relative overflow-hidden">
      <div
        className="absolute inset-0 pointer-events-none"
        style={{
          background: `
            radial-gradient(ellipse 80% 40% at 20% 30%, rgba(253,240,236,0.4) 0%, transparent 55%),
            radial-gradient(ellipse 60% 40% at 80% 70%, rgba(232,228,240,0.3) 0%, transparent 55%),
            #FAFAFA
          `,
        }}
      />

      <div className="relative w-full px-6 pt-28 sm:px-8 md:px-12">
        <motion.div
          className="mb-32 flex w-full flex-col items-center justify-center lg:mb-44"
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
        >
          <div className="flex max-w-full flex-col items-center text-center">
            <span className="text-[clamp(15px,2vw,20px)] font-bold uppercase tracking-[0.2em] text-[#F29B8F]">
              Features
            </span>
            <h2
              className="mt-6 text-center text-[clamp(18px,3.8vw,64px)] font-bold leading-[1.08] text-[#25313D] min-[420px]:whitespace-nowrap"
              style={{ letterSpacing: "-0.03em" }}
            >
              One system. One clear picture.
            </h2>
          </div>
        </motion.div>
      </div>

      <div className="relative mx-auto max-w-7xl px-6 sm:px-8 md:px-12">
        <FeatureScene
          overline="01 · Continuous Monitoring"
          headline="Always watching. Quietly."
          body="Wearable data, patterns, and signals — continuously organized without manual overload. Your pregnancy, tracked in the background."
          align="right"
          image={feature1}
          accent={
            <div className="flex flex-col gap-3">
              <Heartbeat width={280} height={44} color="#F29B8F" speed={2200} />
              <div className="flex flex-wrap gap-2.5">
                <GlassCard
                  variant="metric"
                  label="HRV"
                  value="58"
                  unit="ms"
                  status="normal"
                />
                <GlassCard
                  variant="metric"
                  label="Sleep"
                  value="7.2"
                  unit="hrs"
                  status="normal"
                />
                <GlassCard
                  variant="metric"
                  label="Steps"
                  value="6.2k"
                  status="normal"
                />
              </div>
            </div>
          }
        />

        <FeatureScene
          overline="02 · AI Risk Detection"
          headline="Know earlier. Not later."
          body="Preggo surfaces patterns and signals that deserve attention before uncertainty turns into panic. Calm, early awareness."
          align="left"
          image={feature2}
          accent={
            <GlassCard
              variant="alert"
              title="Pattern noticed"
              description="Blood pressure trend worth mentioning to your doctor at the next visit."
              level="medium"
            />
          }
        />

        <FeatureScene
          overline="03 · Lab & Document Scanner"
          headline="No more guessing test results."
          body="Scan reports, extract the important parts, and turn medical documents into understandable insight. Know what matters."
          align="right"
          image={feature3}
          accent={
            <div className="flex flex-col gap-2">
              {[
                { label: "Hemoglobin", value: "11.2 g/dL", flagged: false },
                { label: "Iron", value: "58 µg/dL", flagged: true },
                { label: "Glucose", value: "98 mg/dL", flagged: false },
              ].map((item) => (
                <GlassCard
                  key={item.label}
                  variant="scan"
                  label={item.label}
                  value={item.value}
                  flagged={item.flagged}
                />
              ))}
            </div>
          }
        />

        <FeatureScene
          overline="04 · Doctor-ready Reports"
          headline="Walk into appointments prepared."
          body="Bring one clear, organized story of your pregnancy to every doctor visit. Your data, beautifully presented."
          align="left"
          image={feature4}
        />
      </div>
    </section>
  );
}
