# PRODUCT DEFINITION: VEHICLE BREAKDOWN REPORTING SYSTEM (VBRS)

## 1. Product Truth & Mission
When a vehicle breaks down on a dark highway or busy arterial road, drivers experience acute vulnerability, confusion, and anxiety. The Vehicle Breakdown Reporting System (VBRS) exists to convert roadside chaos into calm, transparent, and swift resolution. 

The application is an emergency assistance web platform connecting stranded drivers with certified, nearby mechanics and towing specialists in real-time, operating entirely on free and open-source infrastructure without reliance on costly external APIs.

---

## 2. Surfaces & Modes

Per the design architecture, each surface is engineered for its distinct human context:

| Surface | Target Persona | UX Mode | Primary User Goal | Design Mandate |
| :--- | :--- | :--- | :--- | :--- |
| **Landing & Public Info** | Prospective Customers & Mechanics | **Persuade** | Understand value, feel trust, install/bookmark, register | Automotive technology aesthetic; high visual craft, clear trust badges, zero fluff. |
| **Emergency Breakdown Intake** | Distressed Drivers | **Operate (Emergency)** | Report issue in under 60 seconds with minimal friction | High-contrast controls, large tap targets, automatic GPS with 1-tap pin fallback, low cognitive load. |
| **Customer Tracking Portal** | Active Request Owners | **Operate** | Monitor mechanic arrival, view telemetry, communicate | Real-time interactive map, progressive status timeline, clear ETA and contact triggers. |
| **Mechanic Dispatch Terminal**| Field Mechanics & Tow Drivers | **Operate** | Triage incoming alerts, accept jobs, navigate, update status | High-legibility roadside contrast, audio-visual job pings, one-touch status buttons (`ARRIVED`, etc.). |
| **Admin Command Center** | Fleet Dispatchers & Regulators | **Operate** | Monitor city-wide incidents, verify mechanics, resolve disputes | Information-dense, multi-column layout, real-time metrics, audit inspection, zero decorative distraction. |

---

## 3. Human Experience Principles

1. **Clarity Over Cleverness:** During a roadside breakdown, nobody wants ambiguous icons or nested menus. Emergency actions are large, prominent, and labeled with plain English.
2. **Deterministic Feedback:** Every tap, drag, upload, and status transition provides immediate visual feedback. Loading skeletons replace layout shifts; toasts confirm transmissions.
3. **Graceful Degradation:** When device GPS fails, the map immediately offers a manual drag-and-drop pin. When map tiles are unreachable, a clean vector coordinate grid takes over.
4. **Honest Metrics:** All statistics, ETAs, and distance numbers represent real calculations (Haversine formula on active coordinates), never simulated cosmetic placeholders.
