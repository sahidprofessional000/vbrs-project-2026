# APPENDIX E: INSTALLATION & OPERATIONAL DEPLOYMENT GUIDE

## 1. System Prerequisites
- **Node.js:** v20.0.0 or higher (v24.18.0 LTS recommended)
- **Package Manager:** `npm` v10.0.0 or higher
- **Database Engine:** PostgreSQL 15 or 16 (WSL Docker Desktop or Native)
- **Web Browser:** Google Chrome / Chromium 120+ (WebGL 2.0 enabled for 3D Hologram)

## 2. Environment Configuration
Create `.env` file in `backend/` and `frontend/`:

### `backend/.env`
```env
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/vbrs_db?schema=public"
JWT_SECRET="your-ultra-secure-jwt-secret-key-at-least-256-bits"
JWT_EXPIRATION="15m"
JWT_REFRESH_SECRET="your-ultra-secure-jwt-refresh-secret-key"
JWT_REFRESH_EXPIRATION="7d"
PORT=4000
FRONTEND_URL="http://localhost:3000"
NODE_ENV="development"
```

### `frontend/.env.local`
```env
NEXT_PUBLIC_API_URL="http://localhost:4000/api"
NEXT_PUBLIC_WS_URL="ws://localhost:4000"
```

## 3. Database Initialization
```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Run Prisma database migrations
npx prisma migrate deploy

# Generate type-safe Prisma client
npx prisma generate
```

## 4. Launching Development Servers
```bash
# Terminal 1: Launch NestJS Backend Daemon
cd backend
npm run start:dev

# Terminal 2: Launch Next.js 14 Frontend Application
cd frontend
npm run dev
```

## 5. Running Automated Verification Suites
```bash
# Execute Backend E2E and Unit Regression Tests (171 tests)
cd backend
npm run test:e2e

# Execute Frontend Playwright E2E Suites (15 test suites)
cd frontend
npx playwright test
```
