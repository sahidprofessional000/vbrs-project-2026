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
      colors: {
        slate: {
          750: "#243144",
          850: "#172033",
          950: "#0b0f17",
        },
        emergency: {
          DEFAULT: "#ef4444",
          hover: "#dc2626",
          subtle: "rgba(239, 68, 68, 0.12)",
        },
        automotive: {
          sky: "#0284c7",
          cyan: "#06b6d4",
          amber: "#f59e0b",
          emerald: "#10b981",
        },
      },
      fontFamily: {
        sans: ["Inter", "-apple-system", "BlinkMacSystemFont", "Segoe UI", "Roboto", "sans-serif"],
        mono: ["ui-monospace", "SFMono-Regular", "Menlo", "Monaco", "Consolas", "monospace"],
      },
      boxShadow: {
        card: "0 4px 20px -2px rgba(0, 0, 0, 0.4)",
        glowBlue: "0 0 15px rgba(56, 189, 248, 0.25)",
        glowHazard: "0 0 15px rgba(239, 68, 68, 0.25)",
      },
    },
  },
  plugins: [],
};
export default config;
