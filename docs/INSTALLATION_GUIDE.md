# VEHICLE BREAKDOWN REPORTING & RESPONSE SYSTEM (VBRS)
# Complete System Installation & Deployment Guide

**Version:** 1.0.0 (Production-Quality Academic Capstone Release)  
**Budget Constraint:** \$0.00 USD (Zero-Budget, 100% Free & Open-Source)  
**Target Environments:** Windows 10/11 (with WSL2 or Native PostgreSQL), Linux (Ubuntu/Debian), macOS  

---

## 1. Architectural Overview & Prerequisites

VBRS is designed to run entirely locally without requiring any paid cloud APIs, billing accounts, credit cards, or third-party subscriptions. All mapping, routing, 3D CAD rendering, and persistence services are fully self-hosted.

### Prerequisites Matrix

| Component | Minimum Version | Recommended Version | Verification Command | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Node.js** | `v20.x` LTS | `v22.x` or `v24.x` | `node -v` | Backend and Frontend JavaScript Runtime |
| **npm** | `v10.x` | `v10.x+` | `npm -v` | Package Management |
| **PostgreSQL** | `14.x` | `16.x` or `18.x` | `psql --version` | Relational Database & Geospatial Indexing |
| **Git** | `2.40+` | `Latest` | `git --version` | Version Control & Asset Tracking |
| **Web Browser** | Chrome 115+, Edge 115+, Firefox 115+ | Google Chrome Latest | `chrome --version` | WebGL 2.0 3D Rendering & GPS Simulation |

---

## 2. Zero-Budget Database Setup (PostgreSQL)

You can run PostgreSQL either natively on your host machine, inside WSL2, or via Docker Compose.

### Option A: Local / WSL2 PostgreSQL (Recommended)

1. **Start PostgreSQL Service:**
   ```bash
   sudo service postgresql start
   ```

2. **Create Platform Database & User:**
   Connect to the PostgreSQL console as the `postgres` superuser:
   ```bash
   sudo -u postgres psql
   ```
   Execute the following SQL commands:
   ```sql
   -- Create platform administrative user
   CREATE USER vbrs_admin WITH PASSWORD 'vbrs_secure_password_dev_123';

   -- Create operational production database
   CREATE DATABASE vbrs_db OWNER vbrs_admin;

   -- Create isolated test database for automated regression
   CREATE DATABASE vbrs_test_db OWNER vbrs_admin;

   -- Grant permissions
   GRANT ALL PRIVILEGES ON DATABASE vbrs_db TO vbrs_admin;
   GRANT ALL PRIVILEGES ON DATABASE vbrs_test_db TO vbrs_admin;
   \q
   ```

### Option B: Docker Compose (Alternative)

If Docker is preferred:
```bash
docker-compose up -d
```
The included `docker-compose.yml` automatically initializes PostgreSQL 16 on port `5432` with user `vbrs_admin` and database `vbrs_db`.

---

## 3. Environment Variable Configuration

VBRS includes pre-configured environment templates. Create your environment files:

### Root Environment (`.env`)
```env
# Database Configuration (PostgreSQL)
DB_HOST=localhost
DB_PORT=5432
DB_USER=vbrs_admin
DB_PASSWORD=vbrs_secure_password_dev_123
DB_NAME=vbrs_db
DATABASE_URL="postgresql://vbrs_admin:vbrs_secure_password_dev_123@localhost:5432/vbrs_db?schema=public"

# Backend Configuration
BACKEND_PORT=4000
BACKEND_URL=http://localhost:4000
NODE_ENV=development

# JWT Cryptographic Secrets (Bcrypt 12-round hashing)
JWT_ACCESS_SECRET=vbrs_jwt_access_super_secret_key_dev_2026_xyz
JWT_ACCESS_EXPIRATION=15m
JWT_REFRESH_SECRET=vbrs_jwt_refresh_super_secret_key_dev_2026_abc
JWT_REFRESH_EXPIRATION=7d

# File Upload Policies
UPLOAD_DESTINATION=./uploads
MAX_FILE_SIZE_MB=5

# Frontend Web Configuration
FRONTEND_PORT=3000
NEXT_PUBLIC_API_URL=http://localhost:4000/api
NEXT_PUBLIC_SOCKET_URL=http://localhost:4000
NEXT_PUBLIC_APP_NAME="Vehicle Breakdown Assistance"
```

### Backend Environment (`backend/.env`)
Ensure `backend/.env` contains the identical `DATABASE_URL` and JWT secrets:
```env
PORT=4000
NODE_ENV=development
DATABASE_URL="postgresql://vbrs_admin:vbrs_secure_password_dev_123@localhost:5432/vbrs_db?schema=public"
JWT_ACCESS_SECRET="vbrs_jwt_access_super_secret_key_dev_2026_xyz"
JWT_ACCESS_EXPIRATION="15m"
JWT_REFRESH_SECRET="vbrs_jwt_refresh_super_secret_key_dev_2026_abc"
JWT_REFRESH_EXPIRATION="7d"
UPLOAD_DESTINATION="./uploads"
MAX_FILE_SIZE_MB=5
CORS_ORIGIN="http://localhost:3000"
```

---

## 4. Backend Installation & Migration

1. **Install Dependencies:**
   ```bash
   cd backend
   npm install
   ```

2. **Generate Prisma ORM Client:**
   ```bash
   npx prisma generate
   ```

3. **Deploy Database Schema Migrations:**
   ```bash
   npx prisma migrate deploy
   ```
   *Or for development synchronization:*
   ```bash
   npx prisma db push
   ```

4. **Seed Platform Operational Baseline Data:**
   ```bash
   npx ts-node prisma/seed.ts
   ```
   This creates the following verified canonical accounts:
   - **Administrator:** `admin@vbrs.local` (Password: `Password@123`)
   - **Verified Field Mechanic:** `mechanic.marcus@vbrs.local` (Password: `Password@123`)
   - **Registered Field Mechanic:** `mechanic.alex@vbrs.local` (Password: `Password@123`)
   - **Registered Customer:** `customer.john@vbrs.local` (Password: `Password@123`)
   - **Registered Customer:** `customer.sarah@vbrs.local` (Password: `Password@123`)

5. **Build & Start Backend Server:**
   ```bash
   npm run build
   node dist/main.js
   ```
   *Expected output:*
   ```
   🚗 VBRS Backend Server successfully running on Port: 4000
   📘 OpenAPI Swagger Documentation: http://localhost:4000/api/docs
   🩺 System Health Check Endpoint:  http://localhost:4000/api/health
   ```

---

## 5. Frontend Installation & Startup

1. **Install Dependencies:**
   ```bash
   cd ../frontend
   npm install
   ```

2. **Build Next.js Application:**
   ```bash
   npm run build
   ```

3. **Start Next.js Production Server:**
   ```bash
   npm run start
   ```
   The client application will be live at `http://localhost:3000`.

---

## 6. Verification & Health Check Checklist

Verify that all platform components are operational:

1. **Backend Health Check:**
   Open `http://localhost:4000/api/health` in your browser. Expected response:
   ```json
   {
     "status": "ok",
     "info": { "database": { "status": "up" } },
     "error": {},
     "details": { "database": { "status": "up" } }
   }
   ```
2. **OpenAPI Swagger Interactive Console:**
   Open `http://localhost:4000/api/docs`. You can authenticate and test all REST endpoints.
3. **Public Landing Page & 3D WebGL Vehicle:**
   Open `http://localhost:3000/`. Confirm the 3D car model renders with PBR paint swatches and 360° turntable orbit.
4. **Driver Portal Gateway:**
   Click **Driver Portal** or visit `http://localhost:3000/login?role=CUSTOMER&redirect=/customer/home`.
5. **Mechanic Workshop Gateway:**
   Click **Technician Desk** or visit `http://localhost:3000/login?role=MECHANIC&redirect=/mechanic/home`.
6. **Admin Command Center:**
   Visit `http://localhost:3000/login?role=ADMIN&redirect=/admin/dashboard`.

---

## 7. Running Automated Test Suites

### Backend Tests (171 Tests Total)
```bash
cd backend
# Run unit tests (Haversine proximity math)
npm run test

# Run full E2E test suite (168 tests across 11 suites)
$env:DATABASE_URL="postgresql://vbrs_admin:vbrs_secure_password_dev_123@localhost:5432/vbrs_test_db?schema=public"
npx jest --config ./test/jest-e2e.json --runInBand
```

### Frontend Playwright E2E Tests (11 Core Suites + Experience Upgrade Suites)
```bash
cd frontend
# Run all 11 core Playwright E2E regression suites
node test/run-all-e2e.mjs

# Run Role Separation & Public Gateways verification
node test/role-separation.e2e.mjs

# Run Vehicle Viewers Role Isolation verification
node test/vehicle-viewers-isolation.e2e.mjs

# Run 3D Hologram Free Orbit & Subsystems verification
node test/hologram-free-movement.e2e.mjs
```

---

## 8. Troubleshooting & Common Questions

- **PostgreSQL Connection Refused (`ECONNREFUSED 127.0.0.1:5432`):**
  Ensure the PostgreSQL service is active (`sudo service postgresql status` or check Windows Services).
- **Three.js WebGL Context Warning:**
  Ensure hardware acceleration is enabled in your browser settings (`chrome://settings/system` -> "Use graphics acceleration when available").
- **Port Conflict on 3000 or 4000:**
  If port 3000 or 4000 is occupied, you can adjust `PORT=4001` in `backend/.env` and `PORT=3001` for Next.js, and update `NEXT_PUBLIC_API_URL` accordingly.
