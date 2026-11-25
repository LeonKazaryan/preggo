"use client";

import { useEffect, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import Link from "next/link";
import { CTAButton } from "@/components/ui/CTAButton";
import { AppLogo } from "@/components/ui/AppLogo";
import { cn } from "@/lib/utils";
import { NAV_LINKS } from "@/lib/constants";

function PreggoLogo() {
  return (
    <Link
      href="/"
      className="flex items-center gap-2 font-bold text-[16px] text-[#25313D] tracking-tight"
    >
      <AppLogo size="md" priority />
      <span>Preggo</span>
    </Link>
  );
}

export function Navbar() {
  const [scrolled, setScrolled] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);

  useEffect(() => {
    const handleScroll = () => setScrolled(window.scrollY > 60);
    window.addEventListener("scroll", handleScroll, { passive: true });
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  return (
    <>
      <motion.header
        className={cn(
          "fixed top-0 left-0 right-0 z-50 w-full transition-all duration-500",
          scrolled ? "py-3 px-3 sm:px-5" : "py-4 px-4 sm:px-6",
        )}
        initial={{ opacity: 0, y: -16 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.7, ease: [0.16, 1, 0.3, 1], delay: 0.4 }}
      >
        <div
          className={cn(
            "w-full min-w-0 rounded-2xl transition-all duration-500 overflow-visible",
            scrolled
              ? "bg-white/82 backdrop-blur-[28px] border border-white/50 shadow-[0_2px_24px_rgba(0,0,0,0.07),0_1px_4px_rgba(0,0,0,0.04)]"
              : "bg-transparent",
          )}
        >
          <div className="grid grid-cols-[minmax(0,1fr)_auto_minmax(0,1fr)] items-center min-h-[64px] gap-6 px-6 sm:px-8 md:px-10 lg:px-12">
            <div className="min-w-0 flex justify-start">
              <PreggoLogo />
            </div>

            <nav className="hidden md:flex items-center justify-center gap-10 shrink-0">
              {NAV_LINKS.map((link) => (
                <a
                  key={link.href}
                  href={link.href}
                  className="px-6 py-3 text-[14.5px] font-medium text-[#6B7280] hover:text-[#25313D] transition-colors duration-200 rounded-xl hover:bg-black/[0.04]"
                >
                  {link.label}
                </a>
              ))}
            </nav>

            <div className="flex min-w-0 items-center justify-end">
              <div className="hidden md:block shrink-0">
                <CTAButton variant="primary" size="sm" href="#pricing">
                  Join beta
                </CTAButton>
              </div>

              <button
                className="md:hidden flex flex-col gap-1.5 p-2 rounded-lg hover:bg-black/5 transition-colors"
                onClick={() => setMobileOpen(!mobileOpen)}
                aria-label={mobileOpen ? "Close menu" : "Open menu"}
                aria-expanded={mobileOpen}
              >
                <span
                  className={cn(
                    "block w-5 h-0.5 bg-[#25313D] rounded transition-transform duration-300",
                    mobileOpen && "rotate-45 translate-y-2",
                  )}
                />
                <span
                  className={cn(
                    "block w-5 h-0.5 bg-[#25313D] rounded transition-opacity duration-300",
                    mobileOpen && "opacity-0",
                  )}
                />
                <span
                  className={cn(
                    "block w-5 h-0.5 bg-[#25313D] rounded transition-transform duration-300",
                    mobileOpen && "-rotate-45 -translate-y-2",
                  )}
                />
              </button>
            </div>
          </div>
        </div>
      </motion.header>

      <AnimatePresence>
        {mobileOpen && (
          <motion.div
            className="fixed inset-0 z-40 bg-white/97 backdrop-blur-2xl flex flex-col items-center justify-center gap-7"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.25 }}
          >
            {NAV_LINKS.map((link, i) => (
              <motion.a
                key={link.href}
                href={link.href}
                className="text-[28px] font-semibold text-[#25313D] hover:text-[#F29B8F] transition-colors"
                onClick={() => setMobileOpen(false)}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{
                  delay: i * 0.07,
                  duration: 0.4,
                  ease: [0.16, 1, 0.3, 1],
                }}
              >
                {link.label}
              </motion.a>
            ))}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{
                delay: NAV_LINKS.length * 0.07,
                duration: 0.4,
                ease: [0.16, 1, 0.3, 1],
              }}
            >
              <CTAButton
                size="lg"
                href="#pricing"
                onClick={() => setMobileOpen(false)}
              >
                Join beta
              </CTAButton>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
