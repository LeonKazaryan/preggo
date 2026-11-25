import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import { LenisProvider } from '@/providers/LenisProvider'
import './globals.css'

const inter = Inter({
  subsets: ['latin'],
  weight: ['300', '400', '500', '600', '700', '800'],
  variable: '--font-inter',
  display: 'swap',
})

export const metadata: Metadata = {
  title: 'Preggo — Know earlier. Worry less.',
  description:
    'Preggo is an AI-powered pregnancy safety system with continuous monitoring, risk detection, and doctor-ready reports. Built for clarity.',
  openGraph: {
    title: 'Preggo — Your confidence in pregnancy.',
    description: 'Not just tracking. Understanding.',
    siteName: 'Preggo',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Preggo — Know earlier. Worry less.',
    description: 'Not just tracking. Understanding.',
  },
  metadataBase: new URL('https://preggo.app'),
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className={inter.variable}>
      <body>
        <LenisProvider>{children}</LenisProvider>
      </body>
    </html>
  )
}
