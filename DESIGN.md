# DESIGN SYSTEM: VEHICLE BREAKDOWN REPORTING SYSTEM (VBRS)

**Design Language:** Precision Automotive Technology  
**Palette Tone:** Slate & Graphite Surfaces with High-Visibility Emergency Accents  
**Typography:** Clean Neogrotesque Sans (Inter / System UI) with Monospace Telemetry

---

## 1. Color Palette Tokens

The color architecture is built around a dark slate foundation that evokes rugged automotive engineering, precision instrumentation, and nighttime roadside legibility, paired with crisp light-mode support.

```css
:root {
  /* Dark Mode Default / Automotive Night Theme */
  --bg-primary: #0b0f17;          /* Deep void slate */
  --bg-surface: #111827;          /* Rich graphite card surface */
  --bg-surface-elevated: #1e293b; /* Elevated container / dropdown */
  --bg-surface-hover: #283548;    /* Interactive hover state */
  
  --border-subtle: #1e293b;       /* Muted outline */
  --border-prominent: #334155;    /* High-contrast element border */
  --border-active: #38bdf8;       /* Focus / selected ring */

  --text-primary: #f8fafc;        /* Crisp high-contrast white */
  --text-secondary: #94a3b8;      /* Muted secondary body text */
  --text-tertiary: #64748b;       /* Dim labels, timestamps */

  /* Functional Automotive Accents */
  --accent-emergency: #ef4444;    /* Crimson Red (Hazard, Engine Fault, Critical) */
  --accent-emergency-bg: rgba(239, 68, 68, 0.12);
  
  --accent-warning: #f59e0b;      /* Amber Caution (Searching, Towing, Maintenance) */
  --accent-warning-bg: rgba(245, 158, 11, 0.12);
  
  --accent-active: #0284c7;       /* Electric Sky Blue (En-Route, Active Job, GPS) */
  --accent-active-bg: rgba(2, 132, 199, 0.12);
  
  --accent-success: #10b981;      /* Emerald Green (Completed, Verified, Online) */
  --accent-success-bg: rgba(16, 185, 129, 0.12);

  /* Elevation Shadows */
  --shadow-card: 0 4px 20px -2px rgba(0, 0, 0, 0.4);
  --shadow-glow-blue: 0 0 15px rgba(56, 189, 248, 0.25);
  --shadow-glow-hazard: 0 0 15px rgba(239, 68, 68, 0.25);
}
```

---

## 2. Typography Hierarchy

- **Font Family (Display & Body):** `Inter`, `-apple-system`, `BlinkMacSystemFont`, `Segoe UI`, `Roboto`, `sans-serif`
- **Font Family (Telemetry & VINs):** `ui-monospace`, `SFMono-Regular`, `Menlo`, `Monaco`, `Consolas`, monospace
- **Scale:**
  - `Hero Title:` 36px - 44px (font-weight: 800, tracking: -0.025em)
  - `Section Header:` 24px - 28px (font-weight: 700, tracking: -0.02em)
  - `Card Header / Milestone:` 18px - 20px (font-weight: 600)
  - `Body Standard:` 14px - 15px (line-height: 1.5, font-weight: 400)
  - `Meta / Coordinates / Badge:` 12px (font-weight: 500, letter-spacing: 0.05em, uppercase for statuses)

---

## 3. UI Component Directives

### 3.1 Status Pill Badges
Every request state has an explicit color identity:
- `SUBMITTED`: Neutral Slate (`bg-slate-800 text-slate-300 border-slate-700`)
- `SEARCHING`: Pulsing Amber (`bg-amber-950/40 text-amber-400 border-amber-800/60 animate-pulse`)
- `ASSIGNED`: Sky Blue (`bg-sky-950/40 text-sky-400 border-sky-800/60`)
- `ACCEPTED`: Cyan (`bg-cyan-950/40 text-cyan-300 border-cyan-800/60`)
- `EN_ROUTE`: Indigo / Radar (`bg-indigo-950/40 text-indigo-300 border-indigo-800/60`)
- `ARRIVED`: Yellow-Green (`bg-lime-950/40 text-lime-400 border-lime-800/60`)
- `IN_PROGRESS`: Blue Glow (`bg-blue-950/40 text-blue-300 border-blue-800/60`)
- `COMPLETED`: Emerald (`bg-emerald-950/40 text-emerald-400 border-emerald-800/60`)
- `CANCELLED`: Rose (`bg-rose-950/40 text-rose-400 border-rose-800/60`)

### 3.2 Leaflet Map Styling
- Dark mode map container styling using CartoDB Dark Matter / Voyager or standard OpenStreetMap with custom SVG high-contrast markers.
- Distinct pulsing SVG icons:
  - Red Pin with pulse wave: Stranded Breakdown Location.
  - Cyan Service Vehicle with directional heading arrow: Mechanic Location.
  - Green Checkpoint: Service base/workshop.

### 3.3 Buttons & Interactive Controls
- Primary Action: `bg-sky-600 hover:bg-sky-500 active:bg-sky-700 text-white font-medium px-4 py-2.5 rounded-lg shadow-sm transition-all focus:ring-2 focus:ring-sky-400 focus:outline-none`
- Hazard / Emergency Action: `bg-rose-600 hover:bg-rose-500 active:bg-rose-700 text-white font-semibold px-5 py-3 rounded-lg shadow-hazard`
- Secondary / Outline: `bg-slate-800/80 hover:bg-slate-750 text-slate-200 border border-slate-700 px-4 py-2.5 rounded-lg`
- Disabled States: `opacity-50 cursor-not-allowed pointer-events-none`

### 3.4 Skeletons & Transitions
- Content loading states must render subtle pulsing slate placeholders (`animate-pulse bg-slate-800 rounded-lg`).
- Modal overlays use `backdrop-blur-sm bg-black/60`.
- Transitions use Framer Motion standard ease: `transition={{ duration: 0.2, ease: "easeOut" }}`.
