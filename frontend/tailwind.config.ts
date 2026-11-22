import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  darkMode: "class",
  theme: {
    extend: {
      maxWidth: {
        layout: "1600px",
      },
      colors: {
        carbon: {
          DEFAULT: "#111214",
          subtle: "#15171A",
        },
        graphite: {
          DEFAULT: "#181A1D",
          hover: "#22252A",
        },
        elevated: {
          DEFAULT: "#202327",
          hover: "#2A2E34",
        },
        porcelain: {
          DEFAULT: "#F0EEE8",
          dim: "#D8D5CD",
        },
        stone: {
          muted: "#A5A39D",
          dim: "#6C6B66",
        },
        divider: {
          DEFAULT: "#303236",
          subtle: "#25282C",
          strong: "#484C52",
        },
        crimson: {
          DEFAULT: "#D93829",
          hover: "#C23123",
          subtle: "rgba(217, 56, 41, 0.12)",
        },
        ochre: {
          DEFAULT: "#C28B38",
          subtle: "rgba(194, 139, 56, 0.12)",
        },
        sage: {
          DEFAULT: "#2D8A58",
          light: "#3FA26C",
          subtle: "rgba(45, 138, 88, 0.12)",
        },
      },
      fontFamily: {
        sans: ["Inter", "Manrope", "-apple-system", "BlinkMacSystemFont", "Segoe UI", "sans-serif"],
        mono: ["ui-monospace", "SFMono-Regular", "Menlo", "Monaco", "Consolas", "monospace"],
      },
      boxShadow: {
        architectural: "0 1px 3px rgba(0, 0, 0, 0.4)",
        elevated: "0 8px 30px -4px rgba(0, 0, 0, 0.5)",
        modal: "0 24px 60px -12px rgba(0, 0, 0, 0.75)",
      },
      letterSpacing: {
        tightest: "-0.035em",
        tighter: "-0.025em",
      },
    },
  },
  plugins: [],
};
export default config;
