import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'VBRS | Vehicle Breakdown Assistance & Dispatch',
  description:
    'Real-time roadside emergency assistance connecting stranded vehicle owners with certified nearby mechanics. 100% Free & Open Source infrastructure.',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="dark">
      <head>
        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" crossOrigin="" />
      </head>
      <body className="bg-slate-950 text-slate-100 antialiased selection:bg-sky-500 selection:text-white">
        {children}
      </body>
    </html>
  );
}
