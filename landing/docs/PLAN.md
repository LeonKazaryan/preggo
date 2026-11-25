# Preggo Landing Page — Implementation Plan

## Общая идея

Apple-style cinematic scroll-storytelling лендинг для iOS-приложения Preggo.
Один iPhone. Одна история. uncertainty → interpretation → clarity → control.

Продаём не трекер — продаём спокойствие, контроль и медицинскую уверенность
в самый важный период жизни женщины.

---

## 1. Технический стек

### Core
- **Next.js 15** (App Router) — SSG/SSR, performance, SEO
- **TypeScript** — строгая типизация по всему проекту
- **Tailwind CSS v4** — layout, утилиты, spacing
- **CSS Custom Properties** — design tokens (цвета, размеры, кривые)

### Animation
- **GSAP + ScrollTrigger** — главный движок scroll storytelling, pinning сцен
- **Framer Motion** — micro-interactions, section reveals, stagger-анимации
- **Lenis** — smooth premium scroll (заменяет нативный scroll)
- **React Three Fiber + Drei** — 3D light scene для hero (опционально, один элемент)

### UI
- **Radix UI Primitives** — accessibility-ready компоненты (dialog, tooltip)
- **clsx + tailwind-merge** — условные классы
- **Inter** (Google Fonts) — основная типографика

### Дополнительно
- **next/image** — оптимизация ассетов
- **next/font** — zero-layout-shift шрифты
- **@studio-freight/lenis** — smooth scroll
- **react-intersection-observer** — вспомогательный trigger для Framer Motion

---

## 2. Структура файлов

```
src/
├── app/
│   ├── layout.tsx              # Root layout: шрифты, Lenis provider, meta
│   ├── page.tsx                # Главная страница — собирает все секции
│   └── globals.css             # CSS tokens, reset, base styles
│
├── components/
│   ├── layout/
│   │   ├── Navbar.tsx          # Sticky glass navbar
│   │   └── Footer.tsx          # Минимальный footer
│   │
│   ├── sections/
│   │   ├── Hero.tsx            # Секция 1: Opening Scene
│   │   ├── Uncertainty.tsx     # Секция 2: Pain Scene
│   │   ├── Clarity.tsx         # Секция 3: Transition to Clarity
│   │   ├── ProductReveal.tsx   # Секция 4: Safety System
│   │   ├── Features.tsx        # Секция 5: Feature Sequence (оболочка)
│   │   ├── EmotionalPeak.tsx   # Секция 6: Emotional Peak
│   │   ├── Pricing.tsx         # Секция 7: Pricing
│   │   └── FinalCTA.tsx        # Секция 8: Closing Scene
│   │
│   ├── features/               # Под-секции Feature Sequence
│   │   ├── FeatureMonitoring.tsx
│   │   ├── FeatureRiskDetection.tsx
│   │   ├── FeatureLabScanner.tsx
│   │   └── FeatureDoctorReport.tsx
│   │
│   ├── ui/
│   │   ├── PhoneMockup.tsx     # iPhone рамка + экраны внутри
│   │   ├── GlassCard.tsx       # Floating metric / alert карточка
│   │   ├── CTAButton.tsx       # Primary / secondary кнопки
│   │   ├── ScanLine.tsx        # Анимированная полоса сканирования
│   │   ├── Heartbeat.tsx       # SVG waveform + пульсация
│   │   ├── LightTrails.tsx     # Canvas / SVG flowing light trails
│   │   ├── ParticleField.tsx   # Subtle particle system (hero bg)
│   │   └── ScrollProgress.tsx  # Тонкая прогресс-линия сверху
│   │
│   └── providers/
│       ├── LenisProvider.tsx   # Инициализация Lenis smooth scroll
│       └── GSAPProvider.tsx    # GSAP context + ScrollTrigger setup
│
├── hooks/
│   ├── useScrollProgress.ts    # Прогресс скролла 0–1
│   ├── useParallax.ts          # Parallax offset по ref
│   ├── usePinnedScene.ts       # GSAP pin helper
│   └── useInView.ts            # Обёртка над IntersectionObserver
│
├── lib/
│   ├── gsap.ts                 # Инициализация GSAP + плагинов
│   ├── animations.ts           # Переиспользуемые animation presets
│   └── constants.ts            # Цвета, брейкпоинты, timing
│
├── types/
│   └── index.ts                # Общие TypeScript типы
│
└── assets/
    ├── screens/                # UI скриншоты Preggo app
    │   ├── dashboard.png
    │   ├── risk-alert.png
    │   ├── lab-scan.png
    │   ├── insights.png
    │   └── doctor-report.png
    ├── iphone-frame.png        # PNG/SVG рамка iPhone
    └── logo.svg                # Логотип Preggo
```

---

## 3. Design Tokens (CSS переменные)

```css
/* Палитра — calm intelligence */
--color-coral:       #F29B8F;   /* brand primary */
--color-coral-deep:  #E5867B;   /* hover / accent */
--color-blush:       #FDF0EC;   /* very light bg */
--color-rose:        #F8D8D0;   /* dividers, cards */

--color-white:       #FFFFFF;
--color-warm-white:  #FAF8F6;
--color-navy:        #1A1F2E;   /* dark cinematic bg */
--color-navy-soft:   #25313D;   /* dark text */

--color-lavender:    #E8E4F0;   /* subtle accent */
--color-blue-soft:   #C8D9E8;   /* medical accent */
--color-muted:       #6B7280;

/* Типографика */
--font-display:      'Inter', system-ui;
--tracking-tight:    -0.03em;
--leading-tight:     1.05;

/* Transitions */
--ease-apple:        cubic-bezier(0.25, 0.46, 0.45, 0.94);
--ease-out-expo:     cubic-bezier(0.16, 1, 0.3, 1);
--ease-in-out-quart: cubic-bezier(0.77, 0, 0.175, 1);

/* Spacing scale */
--section-padding-y: clamp(80px, 12vw, 160px);
```

---

## 4. Архитектура анимаций

### 4.1 GSAP ScrollTrigger — глобальная схема

```
[Hero]        → pin 100vh, phone fade-in, light trails appear
[Uncertainty] → pin 100vh, chaos elements float in, parallax
[Clarity]     → pin 100vh, particles converge to center
[Reveal]      → pin 100vh, feature callouts stagger in
[Features]    → 4 × pin 100vh (по одной на фичу)
[EmotPeak]    → no pin, slow fade
[Pricing]     → no pin, number count-up
[FinalCTA]    → light trails orbit, CTA pulse
```

### 4.2 Lenis setup

```ts
const lenis = new Lenis({
  duration: 1.4,
  easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
  smoothWheel: true,
})

// связать с GSAP ticker
gsap.ticker.add((time) => lenis.raf(time * 1000))
```

### 4.3 Framer Motion — section reveal preset

```ts
const sectionVariants = {
  hidden: { opacity: 0, y: 40 },
  visible: {
    opacity: 1, y: 0,
    transition: { duration: 0.9, ease: [0.16, 1, 0.3, 1] }
  }
}
```

---

## 5. Секции — детальный план

---

### СЕКЦИЯ 1 — Hero / Opening Scene

**Компонент:** `Hero.tsx`

**Вёрстка:**
- `position: fixed` → переходит в sticky через GSAP
- Fullscreen 100dvh
- Фон: soft radial gradient (white → blush → lavender)
- По центру: `PhoneMockup` с анимированным дашбордом
- Слева/справа: floating light trails (Canvas)
- Верх: `Navbar`

**Контент:**
```
Headline (72–96px): Know earlier. Worry less.
Subline (18–20px):  Preggo uses continuous AI monitoring, risk detection,
                    and doctor-ready insights to help you understand
                    what's happening with your body.
CTA Primary:        [Get early access]
Microcopy:          Takes 30 seconds to start
```

**Анимация:**
1. Page load: телефон появляется `scale(0.85) → scale(1)` + `opacity 0→1` (1.2s ease-out-expo)
2. Headline: слова появляются stagger по 80ms
3. Light trails: `requestAnimationFrame` canvas loop, 6–8 thin bezier curves плавно движутся
4. UI внутри телефона: heartbeat SVG line пульсирует (loop), risk score появляется с delay
5. На скролл (0–20%): телефон масштабируется `scale(1 → 1.08)`, background lightens

**Phone UI Screen (dashboard):**
- Верхняя строка: "Week 22 · Risk: Low"
- Heartbeat waveform (анимированный SVG)
- 3 metric карточки: HRV / Sleep / Activity
- Один soft alert: "Blood pressure pattern noticed"

---

### СЕКЦИЯ 2 — Uncertainty / Pain Scene

**Компонент:** `Uncertainty.tsx`

**Вёрстка:**
- Pinned 100vh
- Светлый фон → начинает слегка темнеть
- Центр: телефон остаётся, вокруг него появляются floating элементы

**Контент:**
```
Headline: Pregnancy shouldn't feel like guessing.
Support:  Between doctor visits, most women are left with questions,
          scattered data, and no clear interpretation.
```

**Floating chaos элементы** (12–16 штук):
- `GlassCard` с текстом: "Is this normal?", "Should I worry?",
  "Am I missing something?", "What does this result mean?"
- Blurred lab result fragment
- Scattered symptom notes
- Question mark fragments

**Анимация (GSAP ScrollTrigger):**
1. Scrub 0%–100% пина:
   - Хаотичные карточки появляются с разных сторон + разными задержками
   - Легкий parallax (разные `y`-скорости)
   - Карточки rotate немного (±5deg)
   - Blur effect на некоторых: `filter: blur(2px)`
2. При выходе из пина (95%–100%):
   - Все элементы начинают стягиваться к центру
   - opacity падает с краёв

---

### СЕКЦИЯ 3 — Transition to Clarity

**Компонент:** `Clarity.tsx`

**Вёрстка:**
- Pinned 100vh
- Фон переходит от slightly dark → обратно к light, чистому

**Контент:**
```
Headline: From scattered signals to one clear picture.
```

**Анимация (самая красивая сцена):**
1. Chaos элементы из секции 2 продолжают converge
2. GSAP morph / path animation: линии сходятся в центральный круг / экран телефона
3. Particles летят по кривым Безье к центру (Canvas)
4. Blur → sharp focus: `filter: blur(8px) → blur(0px)` на центральном элементе
5. Финал: все сходится в чистый dashboard на экране телефона
6. Фон вспыхивает мягким белым светом
7. Headline появляется после конвергенции

**Технически:**
- GSAP `motionPath` для частиц
- Canvas для particle lines
- `gsap.to(el, { filter: 'blur(0px)', duration: 1 })`

---

### СЕКЦИЯ 4 — Product Reveal / Safety System

**Компонент:** `ProductReveal.tsx`

**Вёрстка:**
- Pinned 100vh
- Чистый светлый фон
- Телефон по центру, увеличен немного
- Вокруг появляются floating callout labels с линиями к UI элементам

**Контент:**
```
Headline (split line):
  "This is not a pregnancy app.
   This is a safety system."

Support:
  Preggo combines continuous monitoring, AI interpretation,
  document scanning, alerts, and doctor-ready reports
  into one intelligent workflow.
```

**Feature callouts (5 штук):**
- Continuous Monitoring
- AI Risk Detection
- Lab Scanner
- Smart Alerts
- Doctor Reports

**Анимация:**
1. Телефон появляется в центре (уже виден из предыдущей сцены)
2. Headline: первая строка → пауза → вторая строка (theater-style reveal)
3. Callout labels: появляются один за другим stagger (0.3s между каждым)
4. Каждый callout: fade + slide-in от стороны + тонкая линия рисуется к элементу UI
5. При упоминании каждого callout — соответствующий UI элемент на экране телефона мягко glows

---

### СЕКЦИЯ 5 — Feature Sequence (4 сцены)

**Компонент-оболочка:** `Features.tsx`
**Под-компоненты:** по одному на фичу

Каждая фича = отдельная pinned 100vh сцена.

---

#### 5.1 Continuous Monitoring
**Компонент:** `FeatureMonitoring.tsx`

**Контент:**
```
Overline: 01
Headline: Always watching. Quietly.
Body:     Wearable data, patterns, and signals —
          continuously organized without manual overload.
```

**Визуал:**
- Экран телефона: live dashboard с waveform
- Animated SVG heartbeat line (loop, плавная)
- 3 floating metric карточки: HRV 58ms / Deep Sleep 1h 42m / Steps 6,240
- Subtle moving particles через "data paths"

**Анимация:**
- Heartbeat line рисуется слева направо (SVG `stroke-dashoffset`)
- Metric карточки появляются stagger снизу вверх
- Particles двигаются по кривым вдоль waveform

---

#### 5.2 AI Risk Detection
**Компонент:** `FeatureRiskDetection.tsx`

**Контент:**
```
Overline: 02
Headline: Know earlier. Not later.
Body:     Preggo helps surface patterns and signals that deserve
          attention before uncertainty turns into panic.
```

**Визуал:**
- Экран: Risk Score panel "Low · 24/100"
- Alert card: "Blood pressure pattern noticed. Worth mentioning to your doctor."
- Emphasis glow вокруг главной метрики

**Анимация:**
- Risk score count-up: 0 → 24 (медленно, с паузами)
- Alert card появляется снизу + soft glow (не красный ужас, а calm amber)
- Score bar заполняется плавно
- NOT panic, NOT red — это calm controlled awareness

---

#### 5.3 Lab & Document Scanner
**Компонент:** `FeatureLabScanner.tsx`

**Контент:**
```
Overline: 03
Headline: No more guessing test results.
Body:     Scan reports, extract the important parts,
          and turn medical documents into understandable insight.
```

**Визуал:**
- Стилизованный документ (не уродливый PDF, а premium medical paper)
- Scan beam — горизонтальная линия проходит по документу
- После сканирования: key values подсвечиваются один за другим

**Анимация (`ScanLine.tsx`):**
1. Документ slide-in снизу
2. Scan beam движется сверху вниз (2s)
3. После прохода: 4–5 значений highlight один за другим
   ("Hemoglobin: 11.2 g/dL ✓", "Glucose: 98 mg/dL ✓", "TSH: 2.1 mU/L ⚠")
4. Extracted panel появляется справа с чистыми значениями

---

#### 5.4 Doctor-ready Reports
**Компонент:** `FeatureDoctorReport.tsx`

**Контент:**
```
Overline: 04
Headline: Walk into appointments prepared.
Body:     Bring one clear, organized story of your pregnancy
          to every doctor visit.
```

**Визуал:**
- Report собирается сам: сначала пустой, потом секции snap in
- Sections: Timeline / Key Metrics / Lab Results / Risk Notes
- Финальный "export" lock — subtle звук-подобный эффект (visual click)

**Анимация:**
1. Report template появляется пустым
2. Секции добавляются одна за другой (stagger 0.4s)
3. Графики "рисуются" (SVG path animation)
4. Финальный "Report Ready" badge появляется + gentle lock animation

---

### СЕКЦИЯ 6 — Emotional Peak

**Компонент:** `EmotionalPeak.tsx`

**Вёрстка:**
- Не pinned, обычный scroll
- Самый чистый и светлый экран
- Абсолютный минимализм

**Контент:**
```
Headline (split, slow):
  "For the first time,
   you feel in control."

Support:
  Less noise. Less panic.
  More clarity around what matters.
```

**Визуал:**
- Один красивый phone shot с мягким halo
- Почти пустой фон с очень subtle radial gradient
- Никаких карточек, никаких фич

**Анимация:**
- Всё замедляется (буквально: Lenis duration увеличивается)
- Фон "дышит" — очень медленный scale 1 → 1.02 → 1 loop
- Headline появляется строка за строкой с 0.8s паузой
- Motion в 2× медленнее чем в feature секциях
- Phone glow пульсирует softly

---

### СЕКЦИЯ 7 — Pricing

**Компонент:** `Pricing.tsx`

**Вёрстка:**
- Центрированный блок, много воздуха
- Никаких тарифных карточек / таблиц
- Ultra-minimal

**Контент:**
```
Pre-label: Simple, honest pricing.

Main price: $159 / year
Sub:        Less than one doctor visit.
            More clarity throughout your pregnancy.

Monthly alt: Or $15 / month

CTA: [Join beta →]

Microcopy: Early access · No commitment · Cancel anytime
```

**Анимация:**
- "$159" — number count-up (0 → 159, 1.5s, ease-out)
- CTA button: нежный pulsing glow (не агрессивный)
- Fade in секции Framer Motion

---

### СЕКЦИЯ 8 — Final CTA / Closing Scene

**Компонент:** `FinalCTA.tsx`

**Вёрстка:**
- Темный cinematic фон (rich twilight gradient: navy → deep purple-navy)
- Центральный логотип / phone
- Orbiting light trails
- Ощущение: рекламный финальный кадр, не просто footer

**Контент:**
```
Headline:
  "You can't control everything.
   But you can understand."

Subtext:
  Preggo helps turn uncertainty into clarity — through monitoring,
  interpretation, and calm, actionable insight.

CTA: [Start your pregnancy with clarity]
Microcopy: Available on iOS · Free to try
```

**Анимация:**
1. Light trails медленно orbiting вокруг центра (Canvas bezier loops)
2. CTA кнопка: subtle glow pulse (не мигание — breathing)
3. Весь экран "резолвится" в уверенный финальный кадр
4. Логотип появляется последним (confident, slow fade)

---

## 6. Навигация

**Компонент:** `Navbar.tsx`

**Поведение:**
- Старт: почти невидимая (`opacity: 0.0` → `opacity: 1` при скролле 5%)
- При скролле: compact translucent bar (`backdrop-filter: blur(24px)`)
- Background: `rgba(255,255,255,0.72)` или `rgba(26,31,46,0.72)` в тёмных секциях
- Нет жёстких бордеров, только тень
- Анимация появления: `height: 72px → 52px` при скролле

**Ссылки:**
- Features
- How it works
- Pricing
- Join beta (CTA button)

**Mobile:**
- Hamburger → fullscreen overlay menu
- Smooth slide-down animation

---

## 7. PhoneMockup компонент

**Компонент:** `PhoneMockup.tsx`

**Структура:**
```tsx
<PhoneMockup screen="dashboard" scale={1} glowColor="coral">
  {/* screen content injected as children */}
</PhoneMockup>
```

**Props:**
- `screen`: `"dashboard" | "risk" | "lab" | "insights" | "report"`
- `scale`: число (управляется GSAP при скролле)
- `glowColor`: тема подсветки
- `animated`: boolean — включает micro-motion внутри экрана

**Рамка:**
- SVG или PNG высокодетализированная рамка iPhone 15 Pro
- Dynamic Island сверху
- Subtle отражение / блик на стекле

**Экраны (5 штук):**
Каждый экран — отдельный React компонент, имитирующий реальный UI Preggo:

`DashboardScreen` — main monitoring view
`RiskScreen` — risk score + alert
`LabScreen` — document scan view
`InsightsScreen` — symptoms + patterns
`ReportScreen` — doctor report preview

---

## 8. GlassCard компонент

**Компонент:** `GlassCard.tsx`

**Варианты:**
- `metric`: иконка + значение + лейбл (HRV, Sleep, Steps)
- `alert`: иконка предупреждения + короткий текст
- `question`: floating текстовый fragment
- `scan`: fragment с lab value

**Стиль:**
```css
background: rgba(255, 255, 255, 0.72);
backdrop-filter: blur(20px);
border: 1px solid rgba(255, 255, 255, 0.5);
border-radius: 16px;
box-shadow: 0 4px 24px rgba(0, 0, 0, 0.06);
```

---

## 9. Мобильная адаптация

### Breakpoints
- `sm`: 640px
- `md`: 768px
- `lg`: 1024px
- `xl`: 1280px

### Принципы мобайла
- Desktop: полный cinematic опыт, все pin-сцены, все анимации
- Tablet (≤1024px): упрощённый parallax, сохранены transitions
- Mobile (≤768px):
  - Убираем pin-сцены (слишком сложно для тач-скролла)
  - Заменяем GSAP scroll animations на Framer Motion InView variants
  - Сохраняем все ключевые визуальные элементы
  - Телефон остаётся центральным героем
  - Chaos секция: упрощённая версия (меньше карточек, без pin)
  - Feature секции: вертикальный stack вместо cinematic pin

### Media query helper
```ts
const isMobile = useMediaQuery('(max-width: 768px)')
// на мобайле — Framer Motion, на десктопе — GSAP
```

---

## 10. Нужные ассеты

### Обязательные (делаем сами / генерируем)
1. **iPhone 15 Pro frame** — SVG/PNG с прозрачным фоном, фронтальный вид
2. **UI Screens** (5 штук, 390×844px каждый):
   - `dashboard.png` — monitoring view
   - `risk-alert.png` — risk score + alert card
   - `lab-scan.png` — document scanner
   - `insights.png` — symptoms & patterns
   - `doctor-report.png` — report view
3. **Logo** — `logo.svg` (coral + text)
4. **Favicon** — `favicon.svg`

### Генеративные / CSS-based (не нужны PNG)
- Light trails — Canvas animation
- Particles — Canvas animation
- Heartbeat waveform — SVG animation
- Scan line — CSS animation
- Gradient backgrounds — pure CSS

---

## 11. SEO & Meta

```tsx
export const metadata: Metadata = {
  title: 'Preggo — Know earlier. Worry less.',
  description:
    'Preggo is an AI-powered pregnancy safety system with continuous monitoring, risk detection, and doctor-ready reports. Built for clarity.',
  openGraph: {
    title: 'Preggo — Your confidence in pregnancy.',
    description: 'Not just tracking. Understanding.',
    images: [{ url: '/og-image.png', width: 1200, height: 630 }],
  },
  twitter: {
    card: 'summary_large_image',
  },
}
```

---

## 12. Performance

- Все анимации через CSS `transform` и `opacity` (не влияют на layout)
- `will-change: transform` только на активно анимируемых элементах
- `prefers-reduced-motion`: все GSAP/Framer анимации отключаются
- Images: WebP + `next/image` lazy loading
- Fonts: `next/font` с `display: swap`
- GSAP: динамический импорт (не в initial bundle)
- Canvas анимации: `requestAnimationFrame` с visibility check

```ts
// prefers-reduced-motion
const prefersReducedMotion = window.matchMedia(
  '(prefers-reduced-motion: reduce)'
).matches
```

---

## 13. Поэтапный Roadmap

---

### Этап 0 — Setup ✅ DONE
- [x] Мигрировать с Vite на Next.js 15
- [x] Настроить Tailwind v4 + CSS tokens
- [x] Установить Framer Motion + Lenis
- [x] Настроить `LenisProvider`
- [x] Настроить Inter через `next/font`
- [x] Создать структуру папок
- [x] Настроить `lib/constants.ts`, `lib/animations.ts`, `lib/utils.ts`

---

### Этап 1 — Foundation ✅ DONE
- [x] `Navbar.tsx` — glass nav с scroll behavior + mobile menu
- [x] `CTAButton.tsx` — primary/secondary/ghost стили
- [x] `GlassCard.tsx` — metric / alert / question / scan варианты
- [x] `PhoneMockup.tsx` — CSS рамка iPhone + DashboardScreen / RiskScreen / LabScreen / ReportScreen
- [x] `LightTrails.tsx` — Canvas animation (7 bezier trails)
- [x] `Heartbeat.tsx` — SVG ECG waveform с анимацией
- [x] `ScrollProgress.tsx` — тонкая прогресс линия сверху
- [x] `Footer.tsx` — минимальный

---

### Этап 2 — Hero Section ✅ DONE
- [x] `Hero.tsx` — layout, типографика
- [x] Анимация появления телефона (scale + fade)
- [x] Анимация headline (word-by-word stagger)
- [x] LightTrails Canvas вокруг телефона
- [x] Micro-motion UI внутри телефона (heartbeat loop)
- [x] CTA кнопка + microcopy + badge
- [x] Scroll: phone scale on scroll
- [x] Floating callout карточки рядом с телефоном
- [x] Scroll indicator внизу hero

---

### Этап 3 — Uncertainty → Clarity ✅ DONE
- [x] `Uncertainty.tsx` — floating question cards с parallax и auto-float анимацией
- [x] `Clarity.tsx` — Canvas particle convergence (60 частиц сходятся к центру по scroll)
- [x] Scroll-driven opacity/y transitions через Framer Motion useScroll
- [x] Gradient glow в центре Clarity секции при конвергенции

---

### Этап 4 — Product Reveal ✅ DONE
- [x] `ProductReveal.tsx`
- [x] Split headline: "This is not a pregnancy app. / This is a safety system." (coral accent)
- [x] Feature callout labels с линиями-коннекторами по сторонам телефона (desktop)
- [x] Mobile: pill-теги снизу
- [x] Scroll-driven phone appear animation

---

### Этап 5 — Feature Sequence ✅ DONE
- [x] `Features.tsx` — 4 cinematic FeatureScene компонента
- [x] 01 Monitoring: живой heartbeat waveform + metric GlassCards
- [x] 02 Risk Detection: risk score панель + alert card + RiskScreen
- [x] 03 Lab Scanner: scan beam animation + extracted values + LabScreen
- [x] 04 Doctor Reports: report build animation + ReportScreen
- [x] Scroll-driven fade/y-transform на каждой сцене
- [x] Alternating left/right layout

---

### Этап 6 — Emotional Peak + Pricing ✅ DONE
- [x] `EmotionalPeak.tsx` — breathing phone glow, 3 ценностных пункта
- [x] `Pricing.tsx` — count-up $0→$159 при появлении в viewport
- [x] CTA с hover glow + microcopy

---

### Этап 7 — Final CTA + Footer ✅ DONE
- [x] `FinalCTA.tsx` — тёмный cinematic фон (navy)
- [x] Canvas orbiting ellipse trails с moving head-dot
- [x] "You can't control everything. But you can understand." хедлайн
- [x] `Footer.tsx` — минимальный, с лого

---

### Этап 8 — Mobile ✅ DONE
- [x] Hero: floating callouts `hidden md:block`, LightTrails `hidden md:block` на мобайле
- [x] Hero: phone scale-[0.78] sm:scale-[0.88] lg:scale-100 (CSS transform, no layout shift)
- [x] Uncertainty: `mobileHide` флаг — показываем только 4 из 8 карточек на мобайле
- [x] Features: `flex-wrap` для metric cards, scale wrapper для phone
- [x] Lenis: reduced duration + touchMultiplier на мобайле, пропускаем при prefers-reduced-motion
- [x] Navbar: hamburger + fullscreen overlay уже был реализован

---

### Этап 9 — Polish & QA ✅ DONE
- [x] `useReducedMotion` hook + отключение всех Canvas анимаций при prefers-reduced-motion
- [x] IntersectionObserver в LightTrails, Clarity, FinalCTA — пауза когда off-screen
- [x] CSS: `prefers-reduced-motion` global reset в globals.css
- [x] SEO meta tags (layout.tsx: title, description, OG, Twitter card)
- [x] ESLint v9 flat config, 0 errors 0 warnings
- [x] TypeScript build clean — 0 type errors
- [x] Accessibility: focus-visible стили, aria-label на кнопках, aria-expanded
- [x] Performance: `will-change: transform` только на активных элементах
- [x] Mobile: `-webkit-tap-highlight-color: transparent`, `-webkit-text-size-adjust`

---

### Этап 10 — Deploy
- [ ] Vercel deploy (zero-config Next.js)
- [ ] Custom domain (если нужен)
- [ ] Analytics (Vercel Analytics или Plausible)

---

## 14. Важные принципы на каждом этапе

1. **Одна мысль на секцию** — не добавляй карточки, фичи и текст "на всякий случай"
2. **Motion должен быть engineered, не playful** — без bounce, без cheap spring
3. **Phone — главный герой** — всегда виден, всегда центральный
4. **Цвет — calm intelligence** — не кислота, не gradient spam
5. **Типографика лидирует** — большие заголовки, мало текста, много воздуха
6. **Не копируй Apple — перенеси принципы** — свой голос, своя история
7. **Mobile-first только для layout, desktop-first для анимаций** — разные стратегии

---

## 15. Финальное ощущение

После просмотра страницы человек должен подумать:
- "это выглядит как реальный дорогой продукт"
- "это не просто трекер"
- "это помогает чувствовать контроль"
- "это современно, технологично и спокойно"
- "я бы поверил, что это venture-backed startup"
- "это premium confidence platform for pregnancy"
