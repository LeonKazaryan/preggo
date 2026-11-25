export const COLORS = {
  coral: '#F29B8F',
  coralDeep: '#E5867B',
  blush: '#FDF0EC',
  rose: '#F8D8D0',
  white: '#FFFFFF',
  warmWhite: '#FAF8F6',
  navy: '#1A1F2E',
  navySoft: '#25313D',
  lavender: '#E8E4F0',
  blueSoft: '#C8D9E8',
  muted: '#6B7280',
} as const

export const EASING = {
  apple: [0.25, 0.46, 0.45, 0.94] as const,
  outExpo: [0.16, 1, 0.3, 1] as const,
  inOutQuart: [0.77, 0, 0.175, 1] as const,
  outCubic: [0.33, 1, 0.68, 1] as const,
} as const

export const DURATION = {
  fast: 0.3,
  normal: 0.6,
  slow: 0.9,
  cinematic: 1.4,
} as const

export const BREAKPOINTS = {
  sm: 640,
  md: 768,
  lg: 1024,
  xl: 1280,
  '2xl': 1536,
} as const

export const NAV_LINKS = [
  { href: '#features', label: 'Features' },
  { href: '#how-it-works', label: 'How it works' },
  { href: '#pricing', label: 'Pricing' },
] as const
