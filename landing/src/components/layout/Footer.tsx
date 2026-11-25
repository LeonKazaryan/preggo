import { AppLogo } from "@/components/ui/AppLogo";

export function Footer() {
  return (
    <footer className="border-t border-[#EDE8E4]/50 py-8 px-6">
      <div className="max-w-7xl mx-auto flex flex-col md:flex-row items-center justify-between gap-5">
        <div className="flex items-center gap-1.5 font-semibold text-[14px] text-[#25313D]">
          <AppLogo size="sm" />
          Preggo
        </div>

        <p className="text-[12px] text-[#B0B8BF] text-center">
          © 2025 Preggo. Built for the moments that matter most.
        </p>

        <div className="flex items-center gap-5">
          {["Privacy", "Terms", "Contact"].map((item) => (
            <a
              key={item}
              href="#"
              className="text-[12px] text-[#B0B8BF] hover:text-[#6B7280] transition-colors duration-200"
            >
              {item}
            </a>
          ))}
        </div>
      </div>
    </footer>
  );
}
