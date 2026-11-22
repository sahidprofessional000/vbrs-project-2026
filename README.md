# Vehicle Breakdown Reporting & Response System (VBRS)

An enterprise-grade, real-world emergency vehicle breakdown assistance platform designed to connect stranded drivers with nearby certified mechanics and towing specialists in real time.

Built under a strict **Zero-Budget (\$0.00)** mandate using 100% Free and Open-Source Software (FOSS) with **zero paid APIs, subscriptions, or billing accounts**.

---

## Key Capabilities

- **Customer Emergency Intake:** 60-second incident reporting with automatic GPS geolocation, interactive Leaflet/OpenStreetMap fallback pin-drop, vehicle selection, problem classification, and multi-photo upload (with 5MB file size shield).
- **Dedicated Customer Portal (`/customer/home`, `/customer/profile`):** Personalized driver dashboard, garage fleet overview, saved dispatch location bookmarks with GPS autofill, active incident tracking, and complete profile management.
- **Dedicated Mechanic Workspace (`/mechanic/home`, `/mechanic/profile`):** Professional automotive workshop workspace with live availability toggle (`AVAILABLE` / `OFFLINE`), operating radius perimeter slider (10–100 km), GPS beaconing, real financial ledger from PostgreSQL (revenue, labor, parts, AOV), inbound dispatch radar, 1-click atomic claiming, work order quotation intake, and professional dossier management.
- **Interactive 3D Automotive Hologram CAD Digital Twin:** Hardware-accelerated Three.js WebGL inspection terminal embedded in Mechanic Overview and Workshop featuring **8 individually selectable subsystem assemblies**:
  - Engine Block
  - Battery Module
  - Transmission
  - Braking System
  - Wheels and Tyres
  - Suspension
  - Cooling System
  - Electrical System
  *Includes unrestricted $360^\circ$ horizontal and vertical ($0$ to $\pi$) orbit, mouse wheel zoom, pan, mobile touch controls, 4 CAD inspection modes (Standard, X-Ray Hologram, Exploded View, Isolated Subsystem), and SAE DTC fault code tables.*
- **Role-Separated Presentation Architecture:** Strict component isolation keeping public/customer/admin pages on the classic PBR clearcoat vehicle model (`OriginalVehicleViewer`) while isolating the CAD 3D hologram (`MechanicHologramViewer`) exclusively to certified mechanic portals.
- **Rule-Based Diagnostic Triage:** Deterministic rule engine analyzing symptoms and dashboard warning lights to evaluate tow-truck necessity vs on-site roadside repair.
- **Geospatial Proximity Dispatch:** Haversine Great-Circle spherical distance calculation matching active mechanics within operational radius.
- **Real-Time Lifecycle Tracking:** End-to-end WebSocket updates (`SUBMITTED` $\to$ `ACCEPTED` $\to$ `EN_ROUTE` $\to$ `ARRIVED` $\to$ `IN_PROGRESS` $\to$ `COMPLETED`) with en-route mechanic telemetry streaming.
- **Admin Command Center (`/admin/dashboard`):** System-wide incident overview, technician credential vetting gate, municipal dispute adjudication desk, real-time SQL operational analytics, and immutable security audit log explorer.
- **100% Authentic PostgreSQL Operations:** Audited database with zero synthetic records, zero seeded test accounts, zero fake metrics, and zero hardcoded dashboard fallbacks.

---

## Technology Stack

- **Frontend:** Next.js 14 (App Router), React 18, TypeScript, Tailwind CSS, Lucide Icons.
- **3D Graphics & CAD:** Three.js, React Three Fiber, @react-three/drei, Draco WASM geometry compression.
- **Backend:** NestJS 10, Node.js v24 LTS, REST APIs, Socket.IO, Swagger / OpenAPI 3.0.
- **Database:** PostgreSQL 16 / 18, Prisma ORM 5/6, ACID transactions, B-Tree and foreign key indexes.
- **Mapping & Geocoding:** Leaflet.js, OpenStreetMap raster tiles (with offline grid fallback).
- **Security:** bcrypt password hashing (12 rounds), JWT access & HttpOnly refresh tokens with rotation, strict RBAC, OWASP security headers, and input validation pipes.

---

## Quick Start (Zero-Cost Local Setup)

### Prerequisites
- Node.js (v20+ or v24 LTS)
- PostgreSQL 16 / 18 (Local or Docker)
- Git & Google Chrome

### 1. Configure Environment
```bash
cp .env.example .env
cp backend/.env.example backend/.env
```

### 2. Launch Local Database
```bash
# Using native service:
sudo service postgresql start

# Or using Docker:
docker compose up -d
```

### 3. Install Dependencies & Migrate
```bash
# Backend setup:
cd backend
npm install
npx prisma generate
npx prisma migrate deploy
npx ts-node prisma/seed.ts

# Frontend setup:
cd ../frontend
npm install
npm run build
```

### 4. Run the Platform
In Terminal 1 (Backend on Port 4000):
```bash
cd backend
node dist/main.js
```
*API Swagger Documentation: `http://localhost:4000/api/docs`*  
*Health Check Endpoint: `http://localhost:4000/api/health`*

In Terminal 2 (Frontend on Port 3000):
```bash
cd frontend
npm run start
```
*Web Application: `http://localhost:3000`*

---

## Automated Verification & Regression Scorecard

- **Backend Tests:** **171 / 171 passed (100% Green)** across 11 E2E suites and 1 unit test suite.
- **Frontend Playwright Suites:** **15 / 15 suites passed (100% Green)** across 4 viewports (Desktop Wide 1744px, Desktop Standard 1440px, Tablet 768px, Mobile 390px).

```bash
# Run all backend tests:
cd backend
$env:DATABASE_URL="postgresql://vbrs_admin:vbrs_secure_password_dev_123@localhost:5432/vbrs_test_db?schema=public"
npx jest --config ./test/jest-e2e.json --runInBand

# Run all frontend Playwright suites:
cd frontend
node test/run-all-e2e.mjs
node test/role-separation.e2e.mjs
node test/vehicle-viewers-isolation.e2e.mjs
node test/hologram-free-movement.e2e.mjs
```

---

## Documentation Index

Comprehensive engineering and academic documentation packages:

- [Academic Capstone Monograph (27 Chapters)](file:///d:/VEHICLE%20BRAKDOWN%20SYSTEM/docs/ACADEMIC_REPORT.md)
- [System Installation & Deployment Guide](file:///d:/VEHICLE%20BRAKDOWN%20SYSTEM/docs/INSTALLATION_GUIDE.md)
- [Customer & Mechanic User Operations Manual](file:///d:/VEHICLE%20BRAKDOWN%20SYSTEM/docs/USER_MANUAL.md)
- [Administrator Governance & Operations Manual](file:///d:/VEHICLE%20BRAKDOWN%20SYSTEM/docs/ADMIN_MANUAL.md)
- [Complete REST API & WebSocket Documentation](file:///d:/VEHICLE%20BRAKDOWN%20SYSTEM/docs/API_DOCUMENTATION.md)
- [Comprehensive Testing & Verification Report](file:///d:/VEHICLE%20BRAKDOWN%20SYSTEM/docs/TEST_REPORT.md)
- [Security Hardening & Penetration Audit Report](file:///d:/VEHICLE%20BRAKDOWN%20SYSTEM/docs/SECURITY_AUDIT.md)
- [Database Architecture & Schema Documentation](file:///d:/VEHICLE%20BRAKDOWN%20SYSTEM/docs/DATABASE_DOCUMENTATION.md)
- [Milestone & Execution Status Tracker](file:///d:/VEHICLE%20BRAKDOWN%20SYSTEM/docs/PROJECT_STATUS.md)
- [Executive Presentation Deck](file:///d:/VEHICLE%20BRAKDOWN%20SYSTEM/docs/PROJECT_PRESENTATION.md)
