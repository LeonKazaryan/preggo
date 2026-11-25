'use client'

import { useRef } from 'react'
import { motion, useScroll, useTransform } from 'framer-motion'
import { PhoneMockup } from '@/components/ui/PhoneMockup'

const CALLOUTS = [
  { label: 'Continuous Monitoring',  side: 'left',  top: '18%', delay: 0.1 },
  { label: 'AI Risk Detection',       side: 'left',  top: '40%', delay: 0.2 },
  { label: 'Lab & Document Scanner', side: 'left',  top: '62%', delay: 0.3 },
  { label: 'Smart Alerts',           side: 'right', top: '28%', delay: 0.15 },
  { label: 'Doctor-Ready Reports',   side: 'right', top: '54%', delay: 0.25 },
]

export function ProductReveal() {
  const sectionRef = useRef<HTMLDivElement>(null)

  const { scrollYProgress } = useScroll({
    target: sectionRef,
    offset: ['start end', 'end start'],
  })

  const phoneY = useTransform(scrollYProgress, [0, 0.4], [60, 0])
  const phoneOpacity = useTransform(scrollYProgress, [0, 0.3], [0, 1])
  const headlineOpacity = useTransform(scrollYProgress, [0.1, 0.4], [0, 1])
  const headlineY = useTransform(scrollYProgress, [0.1, 0.4], [40, 0])

  return (
    <section
      ref={sectionRef}
      id="product"
      className="relative flex min-h-[100vh] flex-col items-center justify-center overflow-x-clip py-32"
      style={{
        background: `
          radial-gradient(ellipse 100% 70% at 50% 0%, rgba(232,228,240,0.35) 0%, transparent 60%),
          radial-gradient(ellipse 60% 50% at 80% 80%, rgba(253,240,236,0.4) 0%, transparent 55%),
          #F8F6F4
        `,
      }}
    >
      <div className="mx-auto box-border flex w-full max-w-7xl flex-col items-center px-5 sm:px-8 md:px-10 lg:px-12">
        <motion.div
          style={{ opacity: headlineOpacity, y: headlineY }}
          className="mx-auto mb-20 box-border w-full max-w-6xl shrink-0 text-center"
        >
          <span className="mb-6 block text-[12px] font-semibold uppercase tracking-[0.18em] text-[#F29B8F]">
            Product
          </span>
          <h2
            className="mx-auto max-w-6xl font-bold leading-[1.06] text-[#25313D] text-balance"
            style={{
              fontSize: 'clamp(32px, 4.5vw, 64px)',
              letterSpacing: '-0.03em',
            }}
          >
            This is not a pregnancy app.
            <br />
            <span className="text-[#F29B8F]">This is a safety system.</span>
          </h2>

          <p
            className="mx-auto mt-7 max-w-6xl text-pretty text-[#6B7280] leading-relaxed"
            style={{ fontSize: 'clamp(15px, 1.25vw, 18px)' }}
          >
            Preggo combines continuous monitoring, AI interpretation, document scanning,
            alerts, and doctor-ready reports into one intelligent workflow.
          </p>
        </motion.div>

        <div className="relative mx-auto box-border flex w-full max-w-6xl shrink-0 justify-center">
          <div className="absolute inset-0 hidden lg:block">
            {CALLOUTS.filter((c) => c.side === 'left').map((c) => (
              <motion.div
                key={c.label}
                className="absolute right-1/2 flex translate-x-0 items-center justify-end gap-3 pr-[min(270px,30vw)]"
                style={{ top: c.top }}
                initial={{ opacity: 0, x: -20 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true, margin: '-15% 0px' }}
                transition={{
                  delay: c.delay,
                  duration: 0.7,
                  ease: [0.16, 1, 0.3, 1],
                }}
              >
                <div className="rounded-full border border-white/70 bg-white/85 px-4 py-2 shadow-[0_2px_16px_rgba(0,0,0,0.06)] backdrop-blur-xl whitespace-nowrap">
                  <span className="text-[12.5px] font-medium text-[#25313D]">{c.label}</span>
                </div>
                <div className="flex items-center gap-0">
                  <div className="h-px w-12 bg-gradient-to-r from-transparent to-[#F29B8F]/35" />
                  <div className="h-1.5 w-1.5 rounded-full bg-[#F29B8F]/55" />
                </div>
              </motion.div>
            ))}

            {CALLOUTS.filter((c) => c.side === 'right').map((c) => (
              <motion.div
                key={c.label}
                className="absolute left-1/2 flex translate-x-0 items-center gap-3 pl-[min(270px,30vw)]"
                style={{ top: c.top }}
                initial={{ opacity: 0, x: 20 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true, margin: '-15% 0px' }}
                transition={{
                  delay: c.delay,
                  duration: 0.7,
                  ease: [0.16, 1, 0.3, 1],
                }}
              >
                <div className="flex items-center gap-0">
                  <div className="h-1.5 w-1.5 rounded-full bg-[#F29B8F]/55" />
                  <div className="h-px w-12 bg-gradient-to-r from-[#F29B8F]/35 to-transparent" />
                </div>
                <div className="rounded-full border border-white/70 bg-white/85 px-4 py-2 shadow-[0_2px_16px_rgba(0,0,0,0.06)] backdrop-blur-xl whitespace-nowrap">
                  <span className="text-[12.5px] font-medium text-[#25313D]">{c.label}</span>
                </div>
              </motion.div>
            ))}
          </div>

          <motion.div
            style={{ y: phoneY, opacity: phoneOpacity }}
            className="relative z-10 flex min-h-[520px] w-full flex-col items-center justify-center"
          >
            <div
              className="pointer-events-none absolute left-1/2 top-1/2 h-[min(420px,55vw)] w-[min(420px,55vw)] -translate-x-1/2 -translate-y-1/2 rounded-full opacity-30 blur-3xl"
              style={{
                background:
                  'radial-gradient(circle, rgba(242,155,143,0.45) 0%, rgba(232,228,240,0.25) 50%, transparent 70%)',
              }}
            />
            <div className="relative flex w-full max-w-[300px] justify-center">
              <PhoneMockup scale={1} />
            </div>
          </motion.div>
        </div>

        <div className="mx-auto mt-12 flex w-full max-w-6xl flex-wrap justify-center gap-2.5 lg:hidden">
          {CALLOUTS.map((c) => (
            <motion.div
              key={c.label}
              className="rounded-full border border-white/70 bg-white/80 px-4 py-2 shadow-[0_2px_12px_rgba(0,0,0,0.05)] backdrop-blur-xl"
              initial={{ opacity: 0, scale: 0.9 }}
              whileInView={{ opacity: 1, scale: 1 }}
              viewport={{ once: true }}
              transition={{ delay: c.delay, duration: 0.5, ease: [0.16, 1, 0.3, 1] }}
            >
              <span className="text-[13px] font-medium text-[#25313D]">{c.label}</span>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  )
}
