'use client'

import { useEffect, useRef } from 'react'

interface HeartbeatProps {
  width?: number
  height?: number
  color?: string
  className?: string
  speed?: number
}

export function Heartbeat({
  width = 240,
  height = 48,
  color = '#F29B8F',
  className,
  speed = 2200,
}: HeartbeatProps) {
  const pathRef = useRef<SVGPathElement>(null)
  const svgRef = useRef<SVGSVGElement>(null)

  const ecgPath = `M 0,24
    L 30,24
    L 38,24
    L 42,8
    L 46,40
    L 52,4
    L 58,44
    L 62,24
    L 68,24
    L 100,24
    L 108,24
    L 112,8
    L 116,40
    L 122,4
    L 128,44
    L 132,24
    L 138,24
    L 170,24
    L 178,24
    L 182,8
    L 186,40
    L 192,4
    L 198,44
    L 202,24
    L 208,24
    L 240,24`

  useEffect(() => {
    const path = pathRef.current
    const svg = svgRef.current
    if (!path || !svg) return

    const length = path.getTotalLength()
    path.style.strokeDasharray = `${length}`
    path.style.strokeDashoffset = `${length}`

    let start: number | null = null
    let raf: number
    let isVisible = false

    const observer = new IntersectionObserver(
      ([entry]) => { isVisible = entry.isIntersecting },
      { threshold: 0 },
    )
    observer.observe(svg)

    const animate = (timestamp: number) => {
      raf = requestAnimationFrame(animate)
      if (!isVisible) return
      if (!start) start = timestamp
      const elapsed = timestamp - start
      const progress = (elapsed % speed) / speed
      path.style.strokeDashoffset = `${length * (1 - progress)}`
    }

    raf = requestAnimationFrame(animate)
    return () => {
      cancelAnimationFrame(raf)
      observer.disconnect()
    }
  }, [speed])

  return (
    <svg
      ref={svgRef}
      width={width}
      height={height}
      viewBox={`0 0 ${width} ${height}`}
      fill="none"
      className={className}
    >
      <path
        d={`M 0,24 L ${width},24`}
        stroke={color}
        strokeWidth="1"
        strokeOpacity="0.2"
      />
      <path
        ref={pathRef}
        d={ecgPath}
        stroke={color}
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
    </svg>
  )
}
