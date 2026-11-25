'use client'

import { cn } from '@/lib/utils'

interface GlassCardMetricProps {
  variant: 'metric'
  label: string
  value: string
  unit?: string
  status?: 'normal' | 'warning'
  icon?: React.ReactNode
  className?: string
  style?: React.CSSProperties
}

interface GlassCardAlertProps {
  variant: 'alert'
  title: string
  description: string
  level?: 'low' | 'medium'
  className?: string
  style?: React.CSSProperties
}

interface GlassCardQuestionProps {
  variant: 'question'
  text: string
  className?: string
  style?: React.CSSProperties
}

interface GlassCardScanProps {
  variant: 'scan'
  label: string
  value: string
  flagged?: boolean
  className?: string
  style?: React.CSSProperties
}

type GlassCardProps =
  | GlassCardMetricProps
  | GlassCardAlertProps
  | GlassCardQuestionProps
  | GlassCardScanProps

const glassBase =
  'rounded-2xl border border-white/60 backdrop-blur-xl shadow-[0_4px_24px_rgba(0,0,0,0.06)]'

export function GlassCard(props: GlassCardProps) {
  if (props.variant === 'metric') {
    return (
      <div
        className={cn(
          glassBase,
          'bg-white/72 px-4 py-3.5 min-w-[110px]',
          props.className,
        )}
        style={props.style}
      >
        {props.icon && (
          <div className="text-[#F29B8F] mb-1.5 text-sm">{props.icon}</div>
        )}
        <div className="text-[11px] font-medium text-[#6B7280] uppercase tracking-wider mb-1">
          {props.label}
        </div>
        <div className="flex items-baseline gap-1">
          <span className="text-xl font-bold text-[#25313D]">{props.value}</span>
          {props.unit && (
            <span className="text-xs text-[#6B7280]">{props.unit}</span>
          )}
        </div>
        {props.status && (
          <div
            className={cn(
              'mt-1.5 text-[10px] font-medium',
              props.status === 'normal' ? 'text-[#4E8B62]' : 'text-[#D98A3A]',
            )}
          >
            {props.status === 'normal' ? '● Normal' : '● Watch'}
          </div>
        )}
      </div>
    )
  }

  if (props.variant === 'alert') {
    const isLow = props.level === 'low'
    return (
      <div
        className={cn(
          glassBase,
          'bg-white/80 px-4 py-3.5 max-w-[220px]',
          props.className,
        )}
        style={props.style}
      >
        <div className="flex items-center gap-2 mb-1.5">
          <div
            className={cn(
              'w-1.5 h-1.5 rounded-full',
              isLow ? 'bg-[#4E8B62]' : 'bg-[#D98A3A]',
            )}
          />
          <span className="text-[11px] font-semibold text-[#25313D]">
            {props.title}
          </span>
        </div>
        <p className="text-[11px] text-[#6B7280] leading-relaxed">
          {props.description}
        </p>
      </div>
    )
  }

  if (props.variant === 'question') {
    return (
      <div
        className={cn(
          glassBase,
          'bg-white/60 px-4 py-3 text-[13px] font-medium text-[#6B7280] italic',
          props.className,
        )}
        style={props.style}
      >
        {props.text}
      </div>
    )
  }

  if (props.variant === 'scan') {
    return (
      <div
        className={cn(
          glassBase,
          'bg-white/80 px-3.5 py-2.5 flex items-center justify-between gap-6',
          props.className,
        )}
        style={props.style}
      >
        <span className="text-[12px] text-[#6B7280]">{props.label}</span>
        <span
          className={cn(
            'text-[13px] font-semibold',
            props.flagged ? 'text-[#D98A3A]' : 'text-[#4E8B62]',
          )}
        >
          {props.value}
          {props.flagged ? ' ⚠' : ' ✓'}
        </span>
      </div>
    )
  }

  return null
}
