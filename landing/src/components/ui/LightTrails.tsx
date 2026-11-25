'use client'

import { useEffect, useRef } from 'react'

interface Point {
  x: number
  y: number
}

interface Trail {
  start: Point
  cp1: Point
  cp2: Point
  end: Point
  color: string
  alpha: number
  width: number
  phase: number
  speed: number
}

function createTrails(w: number, h: number): Trail[] {
  const cx = w / 2
  const cy = h / 2

  const palette = [
    'rgba(242,155,143',
    'rgba(248,216,208',
    'rgba(232,228,240',
    'rgba(200,217,232',
    'rgba(229,134,123',
    'rgba(242,155,143',
  ]

  return Array.from({ length: 7 }, (_, i) => {
    const angle = (i / 7) * Math.PI * 2
    const r = 160 + Math.random() * 100
    return {
      start: {
        x: cx + Math.cos(angle) * r * 0.4,
        y: cy + Math.sin(angle) * r * 0.4,
      },
      cp1: {
        x: cx + Math.cos(angle + 0.8) * r * 0.9,
        y: cy + Math.sin(angle + 0.8) * r * 0.9,
      },
      cp2: {
        x: cx + Math.cos(angle + 1.6) * r * 0.7,
        y: cy + Math.sin(angle + 1.6) * r * 0.7,
      },
      end: {
        x: cx + Math.cos(angle + 2.4) * r * 0.5,
        y: cy + Math.sin(angle + 2.4) * r * 0.5,
      },
      color: palette[i % palette.length],
      alpha: 0.12 + Math.random() * 0.1,
      width: 0.8 + Math.random() * 1.2,
      phase: Math.random() * Math.PI * 2,
      speed: 0.0003 + Math.random() * 0.0002,
    }
  })
}

interface LightTrailsProps {
  className?: string
}

export function LightTrails({ className }: LightTrailsProps) {
  const canvasRef = useRef<HTMLCanvasElement>(null)

  useEffect(() => {
    const canvas = canvasRef.current
    if (!canvas) return

    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return

    const ctx = canvas.getContext('2d')
    if (!ctx) return

    let raf: number
    let trails: Trail[] = []
    let isVisible = true

    const observer = new IntersectionObserver(
      ([entry]) => { isVisible = entry.isIntersecting },
      { threshold: 0 },
    )
    observer.observe(canvas)

    const resize = () => {
      const rect = canvas.parentElement?.getBoundingClientRect()
      canvas.width = rect?.width ?? window.innerWidth
      canvas.height = rect?.height ?? window.innerHeight
      trails = createTrails(canvas.width, canvas.height)
    }

    resize()
    window.addEventListener('resize', resize)

    const draw = (time: number) => {
      raf = requestAnimationFrame(draw)

      if (!isVisible) return

      ctx.clearRect(0, 0, canvas.width, canvas.height)

      for (const trail of trails) {
        const t = time * trail.speed + trail.phase
        const pulse = Math.sin(t) * 0.04

        const cp1 = {
          x: trail.cp1.x + Math.sin(t * 1.3) * 30,
          y: trail.cp1.y + Math.cos(t * 0.9) * 20,
        }
        const cp2 = {
          x: trail.cp2.x + Math.cos(t * 0.7) * 25,
          y: trail.cp2.y + Math.sin(t * 1.1) * 20,
        }

        ctx.beginPath()
        ctx.moveTo(trail.start.x, trail.start.y)
        ctx.bezierCurveTo(cp1.x, cp1.y, cp2.x, cp2.y, trail.end.x, trail.end.y)
        ctx.strokeStyle = `${trail.color},${trail.alpha + pulse})`
        ctx.lineWidth = trail.width
        ctx.lineCap = 'round'
        ctx.stroke()
      }
    }

    raf = requestAnimationFrame(draw)

    return () => {
      cancelAnimationFrame(raf)
      observer.disconnect()
      window.removeEventListener('resize', resize)
    }
  }, [])

  return (
    <canvas
      ref={canvasRef}
      className={className}
      style={{ pointerEvents: 'none' }}
    />
  )
}
