'use client'

import { useEffect, useRef } from 'react'
import { motion } from 'framer-motion'
import { CTAButton } from '@/components/ui/CTAButton'
import { LightTrails } from '@/components/ui/LightTrails'
import { PhoneMockup } from '@/components/ui/PhoneMockup'
import { cn, splitWords } from '@/lib/utils'
import { wordReveal, staggerContainer, fadeIn, phoneReveal } from '@/lib/animations'

const HEADLINE = 'Know earlier. Worry less.'
const SUBLINE =
  'Preggo uses continuous AI monitoring, risk detection, and doctor-ready insights to help you understand what\'s happening with your body.'

const STATS = [
  { value: 'AI', label: 'Risk detection' },
  { value: '24/7', label: 'Monitoring' },
  { value: '5 min', label: 'Doctor reports' },
]

export function Hero() {
  const sectionRef = useRef<HTMLElement>(null)
  const phoneRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!sectionRef.current || !phoneRef.current) return

    let ticking = false
    const handleScroll = () => {
      if (ticking) return
      ticking = true
      requestAnimationFrame(() => {
        const scrollY = window.scrollY
        const sectionHeight = sectionRef.current?.offsetHeight ?? 0
        const progress = Math.min(scrollY / sectionHeight, 1)
        if (phoneRef.current) {
          const scale = 1 + progress * 0.04
          const translateY = -progress * 16
          phoneRef.current.style.transform = `scale(${scale}) translateY(${translateY}px)`
        }
        ticking = false
      })
    }

    window.addEventListener('scroll', handleScroll, { passive: true })
    return () => window.removeEventListener('scroll', handleScroll)
  }, [])

  return (
    <section
      ref={sectionRef}
      className="relative min-h-[100dvh] overflow-x-clip flex flex-col"
    >
      <div
        className="absolute inset-0 z-0"
        style={{
          background: `
            radial-gradient(ellipse 140% 80% at 50% -10%, rgba(253,240,236,0.9) 0%, transparent 55%),
            radial-gradient(ellipse 60% 60% at 85% 40%, rgba(232,228,240,0.35) 0%, transparent 50%),
            radial-gradient(ellipse 50% 50% at 15% 60%, rgba(200,217,232,0.2) 0%, transparent 50%),
            #FAFAFA
          `,
        }}
      />

      <LightTrails className="absolute inset-0 z-0 w-full h-full hidden md:block" />

      <div className="relative z-10 flex-1 grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-8 xl:gap-12 items-center max-w-6xl xl:max-w-7xl mx-auto w-full min-w-0 px-6 sm:px-10 md:px-12 lg:px-14 xl:px-16 pt-28 sm:pt-32 pb-16 sm:pb-20">
        <div className="flex flex-col items-center lg:items-start text-center lg:text-left min-w-0 w-full max-w-lg mx-auto lg:mx-0 lg:max-w-xl lg:justify-self-end lg:pr-4 xl:pr-8">
          <motion.div
            className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-[#F8D8D0] bg-white/70 backdrop-blur-sm mb-8"
            initial={{ opacity: 0, y: 16 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.7, ease: [0.16, 1, 0.3, 1], delay: 0.2 }}
          >
            <div className="w-1.5 h-1.5 rounded-full bg-[#4E8B62] animate-pulse" />
            <span className="text-[12px] font-medium text-[#6B7280]">
              Now in early access
            </span>
          </motion.div>

          <div className="mb-5 w-full">
            <motion.h1
              className="font-bold text-[#25313D] leading-[1.08] flex flex-wrap justify-center lg:justify-start gap-x-[0.22em] gap-y-1.5"
              style={{
                fontSize: 'clamp(38px, 5vw, 76px)',
                letterSpacing: '-0.025em',
              }}
              variants={staggerContainer}
              initial="hidden"
              animate="visible"
            >
              {splitWords(HEADLINE).map((word, i) => (
                <span key={i} className="inline-block overflow-hidden">
                  <motion.span
                    className="inline-block"
                    variants={wordReveal}
                    custom={i}
                  >
                    {word}
                  </motion.span>
                </span>
              ))}
            </motion.h1>
          </div>

          <motion.p
            className="text-[#6B7280] leading-relaxed mb-10 w-full max-w-[28rem] lg:max-w-md"
            style={{ fontSize: 'clamp(15px, 1.25vw, 18px)' }}
            variants={fadeIn}
            initial="hidden"
            animate="visible"
            transition={{ delay: 0.6, duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
          >
            {SUBLINE}
          </motion.p>

          <motion.div
            className="flex flex-col sm:flex-row sm:flex-wrap items-stretch sm:items-center justify-center lg:justify-start gap-6 sm:gap-8 w-full"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.85, duration: 0.7, ease: [0.16, 1, 0.3, 1] }}
          >
            <CTAButton size="lg" href="#pricing" className="w-full sm:w-auto shrink-0">
              Get early access
            </CTAButton>
            <span className="text-[14px] text-[#9CA3AF] sm:self-center text-center sm:text-left leading-normal font-medium pl-2">
              Takes 30 seconds to start
            </span>
          </motion.div>

          <motion.div
            className="w-full max-w-md lg:max-w-none mt-20 pt-10 border-t border-[#E8E4F0]/90"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 1.1, duration: 0.8 }}
          >
            <div className="flex flex-col gap-10 sm:flex-row sm:flex-nowrap sm:items-start sm:justify-center lg:justify-start sm:gap-0">
              {STATS.map((stat, i) => (
                <div
                  key={stat.label}
                  className={cn(
                    'flex flex-col items-center lg:items-start min-w-0 sm:px-6 xl:px-8 first:sm:pl-0',
                    i > 0 && 'sm:border-l sm:border-[#E8E4F0]',
                  )}
                >
                  <span
                    className="font-bold text-[#25313D] leading-tight block"
                    style={{ fontSize: 'clamp(20px, 1.8vw, 26px)' }}
                  >
                    {stat.value}
                  </span>
                  <span className="text-[11px] text-[#9CA3AF] mt-3 uppercase tracking-[0.15em] leading-tight max-w-[8rem] text-center lg:text-left font-semibold">
                    {stat.label}
                  </span>
                </div>
              ))}
            </div>
          </motion.div>
        </div>

        <div className="flex w-full min-w-0 justify-center items-center lg:justify-center">
          <div ref={phoneRef} className="relative w-full max-w-[280px] sm:max-w-[300px]" style={{ willChange: 'transform' }}>
            <motion.div
              variants={phoneReveal}
              initial="hidden"
              animate="visible"
              className="relative"
            >
              <div
                className="absolute -inset-12 sm:-inset-16 rounded-full opacity-35 blur-3xl pointer-events-none"
                style={{
                  background:
                    'radial-gradient(circle, rgba(242,155,143,0.35) 0%, transparent 70%)',
                }}
              />

              <div className="relative mx-auto w-full">
                <PhoneMockup scale={1} priority />
              </div>
            </motion.div>

            <motion.div
              className="absolute -right-2 sm:-right-4 top-[18%] hidden md:block max-w-[200px] z-10"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 1.4, duration: 0.7, ease: [0.16, 1, 0.3, 1] as [number, number, number, number] }}
            >
              <div className="rounded-2xl border border-white/60 bg-white/95 px-5 py-4 shadow-[0_8px_28px_rgba(0,0,0,0.08)] backdrop-blur-xl">
                <div className="mb-2 flex items-center gap-2">
                  <div className="h-1.5 w-1.5 shrink-0 rounded-full bg-[#D98A3A]" />
                  <span className="text-[11px] font-semibold text-[#D98A3A]">Pattern</span>
                </div>
                <p className="text-[12px] leading-relaxed text-[#6B7280]">
                  Blood pressure trend noticed
                </p>
              </div>
            </motion.div>

            <motion.div
              className="absolute -left-2 sm:-left-4 bottom-[28%] hidden md:block z-10"
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 1.6, duration: 0.7, ease: [0.16, 1, 0.3, 1] as [number, number, number, number] }}
            >
              <div className="rounded-2xl border border-white/60 bg-white/95 px-5 py-4 shadow-[0_8px_28px_rgba(0,0,0,0.08)] backdrop-blur-xl">
                <div className="mb-2 text-[10px] font-medium uppercase tracking-wider text-[#6B7280]">
                  Risk Score
                </div>
                <div className="flex items-baseline gap-1.5">
                  <span className="text-[22px] font-bold leading-none text-[#4E8B62]">24</span>
                  <span className="text-[12px] text-[#6B7280]">/ 100</span>
                </div>
                <div className="mt-2 text-[10px] font-medium text-[#4E8B62]">Low</div>
              </div>
            </motion.div>
          </div>
        </div>
      </div>

      <div className="relative z-10 pb-10 flex justify-center">
        <motion.div
          className="flex flex-col items-center gap-2"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1.5, duration: 0.8 }}
        >
          <span className="text-[11px] text-[#9CA3AF] uppercase tracking-widest">
            Scroll
          </span>
          <motion.div
            className="w-0.5 h-10 bg-gradient-to-b from-[#F29B8F] to-transparent rounded-full"
            animate={{ scaleY: [1, 0.6, 1], opacity: [0.6, 1, 0.6] }}
            transition={{ duration: 2, repeat: Infinity, ease: 'easeInOut' }}
          />
        </motion.div>
      </div>
    </section>
  )
}
