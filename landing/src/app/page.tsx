import { Navbar } from '@/components/layout/Navbar'
import { Footer } from '@/components/layout/Footer'
import { Hero } from '@/components/sections/Hero'
import { Uncertainty } from '@/components/sections/Uncertainty'
import { Clarity } from '@/components/sections/Clarity'
import { ProductReveal } from '@/components/sections/ProductReveal'
import { Features } from '@/components/sections/Features'
import { EmotionalPeak } from '@/components/sections/EmotionalPeak'
import { Pricing } from '@/components/sections/Pricing'
import { FinalCTA } from '@/components/sections/FinalCTA'
import { ScrollProgress } from '@/components/ui/ScrollProgress'

export default function Home() {
  return (
    <main>
      <ScrollProgress />
      <Navbar />
      <Hero />
      <Uncertainty />
      <Clarity />
      <ProductReveal />
      <Features />
      <EmotionalPeak />
      <Pricing />
      <FinalCTA />
      <Footer />
    </main>
  )
}
