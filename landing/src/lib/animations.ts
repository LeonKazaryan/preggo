import type { Variants, Transition } from 'framer-motion'
import { EASING, DURATION } from './constants'

const smoothTransition: Transition = {
  duration: DURATION.slow,
  ease: EASING.outExpo,
}

export const fadeInUp: Variants = {
  hidden: { opacity: 0, y: 40 },
  visible: {
    opacity: 1,
    y: 0,
    transition: smoothTransition,
  },
}

export const fadeIn: Variants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: { duration: DURATION.slow, ease: EASING.outCubic },
  },
}

export const scaleIn: Variants = {
  hidden: { opacity: 0, scale: 0.9 },
  visible: {
    opacity: 1,
    scale: 1,
    transition: { duration: DURATION.cinematic, ease: EASING.outExpo },
  },
}

export const slideInLeft: Variants = {
  hidden: { opacity: 0, x: -40 },
  visible: {
    opacity: 1,
    x: 0,
    transition: smoothTransition,
  },
}

export const slideInRight: Variants = {
  hidden: { opacity: 0, x: 40 },
  visible: {
    opacity: 1,
    x: 0,
    transition: smoothTransition,
  },
}

export const staggerContainer: Variants = {
  hidden: {},
  visible: {
    transition: {
      staggerChildren: 0.08,
      delayChildren: 0.1,
    },
  },
}

export const staggerFast: Variants = {
  hidden: {},
  visible: {
    transition: {
      staggerChildren: 0.05,
      delayChildren: 0.05,
    },
  },
}

export const wordReveal: Variants = {
  hidden: { opacity: 0, y: '110%' },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.7,
      ease: EASING.outExpo,
    },
  },
}

export const phoneReveal: Variants = {
  hidden: { opacity: 0, scale: 0.88, y: 60 },
  visible: {
    opacity: 1,
    scale: 1,
    y: 0,
    transition: {
      duration: DURATION.cinematic,
      ease: EASING.outExpo,
      delay: 0.3,
    },
  },
}

export const calloutReveal: Variants = {
  hidden: { opacity: 0, scale: 0.85 },
  visible: {
    opacity: 1,
    scale: 1,
    transition: {
      duration: DURATION.slow,
      ease: EASING.outExpo,
    },
  },
}
