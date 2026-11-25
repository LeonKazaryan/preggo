"use client";

import { motion, useScroll, useTransform } from "framer-motion";
import { useRef } from "react";

export function RiskGauge() {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start end", "end start"],
  });

  // Анимация стрелки: от High (справа) к Low (слева)
  // Угол дуги примерно от 60 градусов (High) до -60 градусов (Low)
  const rotation = useTransform(scrollYProgress, [0.3, 0.7], [60, -60]);

  return (
    <div
      ref={ref}
      className="relative flex w-full max-w-[480px] flex-col items-center justify-center"
    >
      {/* Основной контейнер спидометра */}
      <div className="relative aspect-[1.4/1] w-full">
        {/* Дуга градиента */}
        <svg
          viewBox="0 0 200 120"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
          className="w-full drop-shadow-[0_10px_40px_rgba(0,0,0,0.04)]"
        >
          {/* Фоновая серая дуга */}
          <path
            d="M30 100 A 70 70 0 0 1 170 100"
            stroke="#F3F4F6"
            strokeWidth="12"
            strokeLinecap="round"
          />
          {/* Цветная дуга */}
          <path
            d="M30 100 A 70 70 0 0 1 170 100"
            stroke="url(#gauge-gradient)"
            strokeWidth="12"
            strokeLinecap="round"
            className="opacity-90"
          />
          <defs>
            <linearGradient
              id="gauge-gradient"
              x1="30"
              y1="100"
              x2="170"
              y2="100"
              gradientUnits="userSpaceOnUse"
            >
              <stop offset="0%" stopColor="#4ADE80" /> {/* Green - Low */}
              <stop offset="50%" stopColor="#FBBF24" />{" "}
              {/* Yellow - Moderate */}
              <stop offset="100%" stopColor="#F87171" /> {/* Red - High */}
            </linearGradient>
          </defs>
        </svg>

        {/* Текстовые метки на дуге */}
        <div className="absolute inset-0 pointer-events-none font-bold tracking-wider text-[10px] uppercase">
          <span className="absolute left-[12%] bottom-[12%] text-[#4ADE80]">
            Low
          </span>
          <span className="absolute left-1/2 top-[12%] -translate-x-1/2 text-[#FBBF24]/80">
            Moderate
          </span>
          <span className="absolute right-[12%] bottom-[12%] text-[#F87171]">
            High
          </span>
        </div>

        {/* Стрелка */}
        <div className="absolute left-1/2 bottom-[15%] h-[70%] w-full -translate-x-1/2">
          <motion.div
            style={{ rotate: rotation, originX: "50%", originY: "100%" }}
            className="absolute left-1/2 bottom-0 h-full w-1.5 -translate-x-1/2"
          >
            {/* Сама игла */}
            <div className="h-full w-full rounded-full bg-[#25313D] shadow-[0_4px_12px_rgba(0,0,0,0.15)]" />

            {/* Центр (ось) */}
            <div className="absolute bottom-0 left-1/2 h-8 w-8 -translate-x-1/2 translate-y-1/2 rounded-full border-[6px] border-white bg-[#25313D] shadow-xl" />
          </motion.div>
        </div>
      </div>

      {/* Текст под спидометром */}
      <div className="mt-12 flex flex-col items-center text-center">
        <span className="text-[12px] font-bold uppercase tracking-[0.2em] text-[#6B7280]/50">
          AI-Interpreted Risk
        </span>
        <div className="mt-3 flex items-center gap-2 text-[22px] font-bold text-[#25313D]">
          <span>Trending towards</span>
          <span className="text-[#4ADE80]">Low</span>
        </div>
      </div>

      {/* Мягкое свечение сзади */}
      <div
        className="pointer-events-none absolute left-1/2 top-1/2 -z-10 h-[100%] w-[100%] -translate-x-1/2 -translate-y-1/2 rounded-full blur-[100px] opacity-30"
        style={{
          background:
            "radial-gradient(circle, rgba(242,155,143,0.4) 0%, transparent 70%)",
        }}
      />
    </div>
  );
}
