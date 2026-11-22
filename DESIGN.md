# DESIGN SYSTEM: VEHICLE BREAKDOWN REPORTING SYSTEM (VBRS)

**Design Identity:** Architectural Cinema + Automotive Editorial + Quiet Luxury  
**Aesthetic References:** Porsche, Leica, Aesop, Linear, Bang & Olufsen  
**Philosophy:** Precision engineering, restrained editorial layouts, generous whitespace, tactile contrast, and quiet confidence. Zero neon, zero generic SaaS gradients, zero decorative 3D noise.

---

## 1. Color Palette System

The color architecture is built strictly on deep warm carbons, tactile graphite surfaces, and warm porcelain typography, punctuated solely by functional automotive safety indicators.

```css
:root {
  /* Core Architectural Neutral Canvas */
  --bg-carbon: #111214;          /* Warm Carbon (Primary Page Canvas) */
  --bg-graphite: #181A1D;        /* Graphite Surface (Level 1 Sub-surface / Sidebar) */
  --bg-elevated: #202327;        /* Elevated Surface (Level 2 Modals, Menus, Selects) */
  --bg-surface-hover: #262A30;   /* Subtle interactive hover */

  /* Structural Dividers */
  --border-subtle: #25282C;       /* Low-contrast divider */
  --border-divider: #303236;      /* Standard hairline border (1px solid) */
  --border-active: #484C52;       /* Focus & selected border */

  /* Editorial Typography Tones */
  --text-porcelain: #F0EEE8;      /* Warm Porcelain (Primary Headlines, Key Data) */
  --text-secondary: #A5A39D;      /* Muted Warm Stone (Body, Subheads, Descriptions) */
  --text-tertiary: #6C6B66;       /* Dim Metadata, Footers, Technical Labels */

  /* Restrained Functional Accents (Non-Neon, Matte Engineering Tones) */
  --accent-emergency: #D93829;    /* Safety Crimson (Breakdown, Immediate Hazard, Error) */
  --accent-emergency-subtle: rgba(217, 56, 41, 0.10);
  
  --accent-warning: #C28B38;      /* Warm Ochre / Hazard Amber (Searching, In Transit) */
  --accent-warning-subtle: rgba(194, 139, 56, 0.10);
  
  --accent-success: #2D8A58;      /* Alpine Forest Green (Verified, Completed, Online) */
  --accent-success-subtle: rgba(45, 138, 88, 0.10);

  --accent-active: #E4E2DC;       /* High-contrast Porcelain Accent for Active Controls */

  /* Shadows: Architectural & Recessed (No Neon Glows) */
  --shadow-subtle: 0 1px 2px rgba(0, 0, 0, 0.3);
  --shadow-elevated: 0 8px 32px -4px rgba(0, 0, 0, 0.5);
  --shadow-overlay: 0 24px 64px -12px rgba(0, 0, 0, 0.7);
}
```

---

## 2. Typography Specification

- **Display & Headlines:** `Inter`, `Manrope`, `-apple-system`, `BlinkMacSystemFont`, sans-serif.
  - Tracking: Tight tracking on large titles (`-0.03em`), normal on body.
  - Weights: `400 (Regular)` and `500 (Medium)` dominate. `600 (Semibold)` reserved strictly for primary labels and headers. Oversized bold/extrabold headlines are strictly prohibited.
- **Monospace Technical Telemetry (VINs, Coordinates, Plates, Timestamps):**
  - `ui-monospace`, `SFMono-Regular`, `Menlo`, `Monaco`, `Consolas`, monospace.
  - Uppercase with slight letter spacing (`+0.05em`).

---

## 3. Layout & Composition Guidelines

1. **Asymmetric Editorial Balance:**
   - Avoid centered SaaS landing pages with floating pill badges.
   - Use dynamic editorial grids: wide cinematic full-bleed or generous bordered photography paired with disciplined typographic blocks.
2. **Surface Rhythm & Line Work:**
   - Replace rounded "card soup" with architectural hairline dividers (`border-[#303236]`).
   - Group information logically through typography and clean section borders rather than nesting card-in-card containers.
3. **Photography Art Direction:**
   - Real, authentic automotive photography: dusk roadside highways, rain-slicked asphalt, precision chassis engineering, workshop lifts, authentic automotive craft.
   - High contrast, deep shadows, cinematic crops.
   - Never use 3D floating spheres, gradient bubbles, or clip-art icons.

---

## 4. Component Rules

- **Buttons:**
  - Primary Emergency: `#D93829` (Solid Matte Safety Crimson) with warm white text, no glow.
  - Primary Standard: `#F0EEE8` (Solid Warm Porcelain) with `#111214` (Warm Carbon) text.
  - Secondary: `#181A1D` with 1px border `#303236` and `#F0EEE8` text.
  - Radius: Disciplined, subtle corners (`rounded-md` or `rounded-lg`, never overly bubbly `rounded-full` for big action cards).
- **Status Pills:**
  - Hairline border, muted background, 11px uppercase monospace text.
  - `SUBMITTED`: Border `#303236`, Text `#A5A39D`
  - `SEARCHING`: Border `#C28B38`/40, Text `#C28B38`
  - `EN_ROUTE`: Border `#A5A39D`/40, Text `#F0EEE8`
  - `COMPLETED`: Border `#2D8A58`/40, Text `#3FA26C`
  - `CANCELLED`: Border `#D93829`/40, Text `#E55342`
- **Modals:**
  - Clean slate overlay (`bg-black/80 backdrop-blur-md`), bordered by `#303236`, interior in `#181A1D`.
- **Map:**
  - Dark, restrained CartoDB Dark Matter / OSM custom monochrome styling.
