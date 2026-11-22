# Vehicle Breakdown Reporting System (VBRS)

An enterprise-grade, real-world emergency vehicle breakdown assistance platform designed to connect stranded drivers with nearby certified mechanics and towing specialists in real time.

Built with **Zero Budget ($0.00)** using 100% Free and Open-Source Software (FOSS).

---

## Key Capabilities

- **Customer Emergency Intake:** 60-second incident reporting with automatic GPS geolocation, interactive Leaflet/OpenStreetMap fallback pin-drop, vehicle selection, problem classification, and multi-photo upload.
- **Rule-Based Diagnostic Triage:** Deterministic rule engine analyzing symptoms and dashboard warning lights to evaluate tow-truck necessity vs. on-site roadside repair.
- **Geospatial Proximity Dispatch:** Haversine Great-Circle spherical distance calculation matching active mechanics within operational radius.
- **Real-Time Lifecycle Tracking:** End-to-end WebSocket updates (SUBMITTED -> SEARCHING -> ASSIGNED -> ACCEPTED -> EN_ROUTE -> ARRIVED -> IN_PROGRESS -> COMPLETED) with en-route mechanic telemetry streaming.
- **Mechanic Dispatch Terminal:** Live availability toggle, audible incoming dispatch radar, turn-by-turn coordinate beaconing, and job completion notes.
- **Admin Command Center:** System-wide incident overview, mechanic document verification desk, grievance arbitration, real-time analytics, and immutable audit logs.

---

## Technology Stack

- **Frontend:** Next.js (App Router), React 18, TypeScript, Tailwind CSS, Framer Motion, Lucide Icons.
- **Backend:** NestJS 10, Node.js v24, REST APIs, Socket.IO, Swagger / OpenAPI 3.0.
- **Database:** PostgreSQL 16 (running locally via Docker), Prisma ORM 5/6.
- **Mapping:** Leaflet.js, OpenStreetMap raster tiles (with offline grid fallback).
- **Security:** bcrypt password hashing, JWT access & httpOnly refresh tokens, strict RBAC, Helmet, rate-limiting, and validation pipes.

---

## Quick Start (Windows 11 Local Environment)

### Prerequisites
- Node.js (v20+ or v24 LTS)
- Docker Desktop (or local PostgreSQL 16 service)
- Git

### 1. Clone & Configure Environment
```powershell
cp .env.example .env
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env
```

### 2. Launch Local Database
```powershell
docker compose up -d postgres
```
Check health:
```powershell
docker compose ps
```

### 3. Install Dependencies
```powershell
# Root dependencies
npm install

# Backend dependencies
cd backend
npm install
npx prisma generate
npx prisma migrate dev --name init
npx prisma db seed

# Frontend dependencies
cd ../frontend
npm install
```

### 4. Run the Application
In terminal 1 (Backend - NestJS on Port 4000):
```powershell
cd backend
npm run start:dev
```
*API & Swagger Documentation: http://localhost:4000/api/docs*

In terminal 2 (Frontend - Next.js on Port 3000):
```powershell
cd frontend
npm run dev
```
*Web Application: http://localhost:3000*

---

## Documentation Index

- [Project Blueprint](file:///d:/VEHICLE%20BRAKDOWN%20SYSTEM/docs/PROJECT_BLUEPRINT.md)
- [System Architecture](file:///d:/VEHICLE%20BRAKDOWN%20SYSTEM/docs/ARCHITECTURE.md)
- [Requirements Specification (SRS)](file:///d:/VEHICLE%20BRAKDOWN%20SYSTEM/docs/REQUIREMENTS.md)
- [Project Status & Milestones](file:///d:/VEHICLE%20BRAKDOWN%20SYSTEM/docs/PROJECT_STATUS.md)
- [Design Tokens & Principles](file:///d:/VEHICLE%20BRAKDOWN%20SYSTEM/DESIGN.md)
- [Product Vision](file:///d:/VEHICLE%20BRAKDOWN%20SYSTEM/PRODUCT.md)
