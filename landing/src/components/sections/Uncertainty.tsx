'use client'

import { useRef } from 'react'
import { motion, useScroll, useTransform } from 'framer-motion'
import { GlassCard } from '@/components/ui/GlassCard'

const FLOATERS: {
  text: string
  x: string
  y: string
  rotate: number
  delay: number
  scale: number
  mobileHide: boolean
}[] = [
  { text: 'Is this normal?',          x: '3%',  y: '10%', rotate: -3,  delay: 0,    scale: 1,    mobileHide: false },
  { text: 'Should I worry?',          x: '73%', y: '7%',  rotate: 3,   delay: 0.1,  scale: 0.95, mobileHide: true  },
  { text: 'Am I missing something?',  x: '2%',  y: '52%', rotate: -2,  delay: 0.15, scale: 1.02, mobileHide: false },
  { text: 'What does this mean?',     x: '76%', y: '63%', rotate: 2,   delay: 0.2,  scale: 0.9,  mobileHide: true  },
  { text: 'Should I call my doctor?', x: '18%', y: '84%', rotate: -3,  delay: 0.25, scale: 0.93, mobileHide: false },
  { text: 'Is this pain normal?',     x: '69%', y: '29%', rotate: 4,   delay: 0.05, scale: 1.05, mobileHide: true  },
  { text: 'How serious is this?',     x: '2%',  y: '76%', rotate: -5,  delay: 0.3,  scale: 0.88, mobileHide: true  },
  { text: 'What is this number?',     x: '64%', y: '87%', rotate: 1,   delay: 0.18, scale: 0.97, mobileHide: false },
]

export function Uncertainty() {
  const sectionRef = useRef<HTMLDivElement>(null)

  const { scrollYProgress } = useScroll({
    target: sectionRef,
    offset: ['start end', 'end start'],
  })

  const headlineY = useTransform(scrollYProgress, [0.1, 0.5], [30, 0])
  const headlineOpacity = useTransform(scrollYProgress, [0.1, 0.35], [0, 1])
  const contentOpacity = useTransform(scrollYProgress, [0.6, 0.9], [1, 0])

  return (
    <section
      ref={sectionRef}
      id="uncertainty"
      className="relative min-h-[100vh] overflow-hidden flex items-center justify-center"
      style={{
        background: `
          radial-gradient(ellipse 80% 60% at 50% 100%, rgba(232,228,240,0.4) 0%, transparent 60%),
          radial-gradient(ellipse 60% 40% at 20% 40%, rgba(200,217,232,0.15) 0%, transparent 50%),
          #F8F6F4
        `,
      }}
    >
      <div className="absolute inset-0 pointer-events-none">
        {FLOATERS.map((f, i) => (
          <motion.div
            key={i}
            className={f.mobileHide ? 'absolute hidden md:block' : 'absolute'}
            style={{ left: f.x, top: f.y }}
            initial={{ opacity: 0, scale: 0.8, rotate: f.rotate * 0.5 }}
            whileInView={{ opacity: 1, scale: f.scale, rotate: f.rotate }}
            viewport={{ once: false, margin: '-10% 0px -10% 0px' }}
            transition={{
              delay: f.delay,
              duration: 0.9,
              ease: [0.16, 1, 0.3, 1],
            }}
          >
            <motion.div
              animate={{
                y: [0, -6, 0],
                rotate: [f.rotate, f.rotate + 1.5, f.rotate],
              }}
              transition={{
                duration: 4 + i * 0.7,
                repeat: Infinity,
                ease: 'easeInOut',
              }}
            >
              <GlassCard
                variant="question"
                text={f.text}
                style={{
                  filter: i % 3 === 0 ? 'blur(0.4px)' : 'none',
                  opacity: 0.6 + (i % 3) * 0.12,
                }}
              />
            </motion.div>
          </motion.div>
        ))}
      </div>

      <motion.div
        style={{ opacity: contentOpacity }}
        className="relative z-10 box-border w-full max-w-[36rem] mx-auto px-6 sm:px-8 py-40 flex flex-col items-center text-center"
      >
        <motion.div
          style={{ y: headlineY, opacity: headlineOpacity }}
          className="flex w-full flex-col items-center"
        >
          <span className="block text-[12px] font-semibold uppercase tracking-[0.18em] text-[#F29B8F] mb-6 text-center">
            The reality of pregnancy
          </span>

          <h2
            className="font-bold text-[#25313D] mb-6 leading-[1.06] text-balance max-w-full"
            style={{
              fontSize: 'clamp(34px, 4.8vw, 64px)',
              letterSpacing: '-0.03em',
            }}
          >
            Pregnancy shouldn&apos;t feel
            <br />
            like guessing.
          </h2>

          <p
            className="text-[#6B7280] leading-relaxed max-w-md mx-auto text-balance"
            style={{ fontSize: 'clamp(15px, 1.25vw, 18px)' }}
          >
            Between doctor visits, most women are left with questions,
            scattered data, and no clear interpretation.
          </p>
        </motion.div>
      </motion.div>
    </section>
  )
}
