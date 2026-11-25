'use client'

import { useRef, useEffect } from 'react'
import { motion, useScroll, useTransform } from 'framer-motion'

interface Particle {
  x: number
  y: number
  tx: number
  ty: number
  vx: number
  vy: number
  radius: number
  color: string
  alpha: number
  progress: number
}

function createParticles(w: number, h: number, count: number): Particle[] {
  const cx = w / 2
  const cy = h / 2
  const colors = ['#F29B8F', '#F8D8D0', '#E8E4F0', '#C8D9E8', '#E5867B']

  return Array.from({ length: count }, () => {
    const angle = Math.random() * Math.PI * 2
    const dist = 200 + Math.random() * 280

    return {
      x: cx + Math.cos(angle) * dist,
      y: cy + Math.sin(angle) * dist,
      tx: cx + (Math.random() - 0.5) * 60,
      ty: cy + (Math.random() - 0.5) * 60,
      vx: 0,
      vy: 0,
      radius: 1.5 + Math.random() * 2,
      color: colors[Math.floor(Math.random() * colors.length)],
      alpha: 0.4 + Math.random() * 0.5,
      progress: 0,
    }
  })
}

export function Clarity() {
  const sectionRef = useRef<HTMLDivElement>(null)
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const particlesRef = useRef<Particle[]>([])
  const convergeRef = useRef(0)

  const { scrollYProgress } = useScroll({
    target: sectionRef,
    offset: ['start end', 'end start'],
  })

  const headlineOpacity = useTransform(scrollYProgress, [0.3, 0.55], [0, 1])
  const headlineY = useTransform(scrollYProgress, [0.3, 0.55], [40, 0])
  const convergeProgress = useTransform(scrollYProgress, [0.1, 0.65], [0, 1])

  useEffect(() => {
    const canvas = canvasRef.current
    if (!canvas) return

    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return

    const ctx = canvas.getContext('2d')
    if (!ctx) return

    let raf: number
    let isVisible = false

    const observer = new IntersectionObserver(
      ([entry]) => { isVisible = entry.isIntersecting },
      { threshold: 0 },
    )
    observer.observe(canvas)

    const resize = () => {
      canvas.width = canvas.offsetWidth
      canvas.height = canvas.offsetHeight
      particlesRef.current = createParticles(canvas.width, canvas.height, 60)
    }

    resize()
    window.addEventListener('resize', resize)

    const unsub = convergeProgress.on('change', (v) => {
      convergeRef.current = v
    })

    const draw = () => {
      raf = requestAnimationFrame(draw)
      if (!isVisible || !ctx || !canvas) return
      ctx.clearRect(0, 0, canvas.width, canvas.height)

      const progress = convergeRef.current
      const cx = canvas.width / 2
      const cy = canvas.height / 2

      for (const p of particlesRef.current) {
        const eased = progress < 0.5
          ? 2 * progress * progress
          : 1 - Math.pow(-2 * progress + 2, 2) / 2

        const currentX = p.x + (p.tx - p.x) * eased
        const currentY = p.y + (p.ty - p.y) * eased

        const alpha = p.alpha * (0.3 + progress * 0.7)

        if (progress > 0.2) {
          ctx.beginPath()
          ctx.moveTo(currentX, currentY)
          ctx.lineTo(
            currentX + (cx - currentX) * Math.min((progress - 0.2) / 0.8, 1) * 0.3,
            currentY + (cy - currentY) * Math.min((progress - 0.2) / 0.8, 1) * 0.3,
          )
          ctx.strokeStyle = p.color + Math.round(alpha * 80).toString(16).padStart(2, '0')
          ctx.lineWidth = 0.8
          ctx.stroke()
        }

        ctx.beginPath()
        ctx.arc(currentX, currentY, p.radius * (1 - eased * 0.4), 0, Math.PI * 2)
        ctx.fillStyle = p.color + Math.round(alpha * 255).toString(16).padStart(2, '0')
        ctx.fill()
      }

      if (progress > 0.6) {
        const glowAlpha = (progress - 0.6) / 0.4
        const gradient = ctx.createRadialGradient(
          canvas.width / 2, canvas.height / 2, 0,
          canvas.width / 2, canvas.height / 2, 80,
        )
        gradient.addColorStop(0, `rgba(242,155,143,${glowAlpha * 0.25})`)
        gradient.addColorStop(1, 'rgba(242,155,143,0)')
        ctx.beginPath()
        ctx.arc(canvas.width / 2, canvas.height / 2, 80, 0, Math.PI * 2)
        ctx.fillStyle = gradient
        ctx.fill()
      }

    }

    raf = requestAnimationFrame(draw)

    return () => {
      cancelAnimationFrame(raf)
      observer.disconnect()
      window.removeEventListener('resize', resize)
      unsub()
    }
  }, [convergeProgress])

  return (
    <section
      ref={sectionRef}
      id="clarity"
      className="relative min-h-[100vh] overflow-hidden flex items-center justify-center"
      style={{
        background: `
          radial-gradient(ellipse 80% 60% at 50% 50%, rgba(253,240,236,0.6) 0%, transparent 65%),
          #FAFAFA
        `,
      }}
    >
      <canvas
        ref={canvasRef}
        className="absolute inset-0 w-full h-full"
        style={{ pointerEvents: 'none' }}
      />

      <div className="relative z-10 flex w-full items-center justify-center px-6 py-44">
        <motion.div
          style={{ opacity: headlineOpacity, y: headlineY }}
          className="flex w-full max-w-2xl flex-col items-center text-center"
        >
          <span className="mb-7 block text-[12px] font-semibold uppercase tracking-[0.18em] text-[#F29B8F]">
            The shift
          </span>

          <h2
            className="mb-7 w-full font-bold leading-[1.06] text-[#25313D] text-balance"
            style={{
              fontSize: 'clamp(36px, 4.8vw, 66px)',
              letterSpacing: '-0.03em',
            }}
          >
            From scattered signals
            <br />
            to one clear picture.
          </h2>

          <p
            className="w-full text-pretty text-[#6B7280] leading-relaxed"
            style={{ fontSize: 'clamp(15px, 1.25vw, 18px)' }}
          >
            All your data, symptoms, and signals — interpreted, organized,
            and presented as one coherent view of your pregnancy.
          </p>
        </motion.div>
      </div>
    </section>
  )
}
