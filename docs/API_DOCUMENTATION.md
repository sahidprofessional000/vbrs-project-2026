# VEHICLE BREAKDOWN REPORTING & RESPONSE SYSTEM (VBRS)
# Complete REST API & WebSocket Protocol Documentation

**Specification Standard:** OpenAPI 3.0 / RESTful JSON / W3C WebSocket  
**Interactive Swagger UI:** `http://localhost:4000/api/docs`  
**Base Endpoint URL:** `http://localhost:4000/api`  
**System Version:** 1.0.0 (Production-Quality Academic Capstone Release)  

---

## 1. Authentication & Security Headers

All protected endpoints require an HTTP Bearer JWT token in the `Authorization` header:
```http
Authorization: Bearer <access_token>
```

### Security Headers Enforced on Every Response
```http
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Referrer-Policy: strict-origin-when-cross-origin
```

---

## 2. API Endpoint Directory by Module

### 2.1 Authentication & Profile Management (`/api/auth`)

| Method | Endpoint | Access | Description |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/auth/register` | Public | Register new Customer or Mechanic account. |
| `POST` | `/api/auth/login` | Public | Authenticate credentials; sets HttpOnly refresh cookie and returns access token. |
| `POST` | `/api/auth/refresh` | Public | Rotates refresh token and issues fresh JWT token pair. |
| `POST` | `/api/auth/logout` | Authenticated | Revokes refresh token in database and clears cookie. |
| `GET` | `/api/auth/profile` | Authenticated | Retrieves current authenticated user record. |
| `PUT` | `/api/auth/profile` | Authenticated | Updates legal name, phone, or profile avatar URL. |

#### Request Example: Login (`POST /api/auth/login`)
```json
{
  "email": "customer.john@vbrs.local",
  "password": "Password@123"
}
```
#### Response Example (`200 OK`):
```json
{
  "user": {
    "id": "e22478b0-00a4-44f8-b146-3649213c7a20",
    "email": "customer.john@vbrs.local",
    "fullName": "Johnathan Doe",
    "phone": "+1-555-0199",
    "role": "CUSTOMER",
    "avatarUrl": null
  },
  "tokens": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "7d-cryptographic-token-string..."
  }
}
```

---

### 2.2 Customer Experience & Saved Locations (`/api/customer`)

| Method | Endpoint | Access | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/customer/overview` | Customer | Aggregated summary: registered vehicles, active dispatches, recent service history. |
| `GET` | `/api/customer/saved-addresses` | Customer | Lists bookmarked dispatch locations for the authenticated driver. |
| `POST` | `/api/customer/saved-addresses` | Customer | Creates a new saved address bookmark with GPS coordinates. |
| `DELETE` | `/api/customer/saved-addresses/:id` | Customer | Removes a saved address bookmark (tenant-isolated). |

#### Request Example: Create Saved Address (`POST /api/customer/saved-addresses`)
```json
{
  "label": "Downtown Headquarters",
  "address": "450 Lexington Ave, New York, NY 10017",
  "latitude": 40.7523,
  "longitude": -73.9754,
  "isDefault": true
}
```

---

### 2.3 Customer Vehicle Garage (`/api/vehicles`)

| Method | Endpoint | Access | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/vehicles` | Customer | Retrieves garage automobiles for the authenticated motorist. |
| `POST` | `/api/vehicles` | Customer | Registers a new vehicle (make, model, year, license plate, VIN). |
| `GET` | `/api/vehicles/:id` | Customer | Retrieves single vehicle record by UUID. |
| `PUT` | `/api/vehicles/:id` | Customer | Updates vehicle details or primary daily-driver flag. |
| `DELETE` | `/api/vehicles/:id` | Customer | Deletes a vehicle from the customer's garage. |

#### Request Example: Add Vehicle (`POST /api/vehicles`)
```json
{
  "make": "BMW",
  "model": "M4 Competition",
  "year": 2026,
  "licensePlate": "TS28 U0056",
  "color": "Obsidian Carbon",
  "isPrimary": true
}
```

---

### 2.4 Breakdown Incident Intake (`/api/breakdowns`)

| Method | Endpoint | Access | Description |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/breakdowns` | Customer | Submits roadside breakdown report with coordinates, fault category, and photos. |
| `GET` | `/api/breakdowns/:id` | Authenticated | Retrieves breakdown record with vehicle and preliminary triage assessment. |
| `GET` | `/api/breakdowns/nearby` | Mechanic | Discovers unassigned incidents within technician's operating perimeter. |
| `GET` | `/api/breakdowns/images/:filename` | Public | Serves uploaded damage photography (with directory traversal protection). |

#### Request Example: Submit Breakdown (`POST /api/breakdowns`)
*Multipart Form Data:*
- `vehicleId`: `ace1cb6e-1e74-4c0d-84df-622d529c8a5e`
- `category`: `ENGINE_FAILURE`
- `severity`: `CRITICAL`
- `description`: `Engine cut out completely on West Side Hwy shoulder. White smoke under hood.`
- `latitude`: `40.7589`
- `longitude`: `-73.9851`
- `address`: `West Side Highway near 42nd St`
- `photos`: *[Binary image files, max 5MB each]*

---

### 2.5 Field Mechanics & Radar Discovery (`/api/mechanics`)

| Method | Endpoint | Access | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/mechanics/nearby` | Authenticated | Haversine proximity query discovering available mechanics within radial perimeter. |
| `GET` | `/api/mechanics/:id` | Authenticated | Retrieves public profile, certifications, and Bayesian reputation score. |
| `PATCH` | `/api/mechanics/location` | Mechanic | Transmits live GPS beacon update (`latitude`, `longitude`, `accuracy`). |
| `PATCH` | `/api/mechanics/availability` | Mechanic | Toggles technician state (`AVAILABLE` vs `OFFLINE`). |
| `PUT` | `/api/mechanic/profile` | Mechanic | Updates workshop dossier (modifying license resets status to `PENDING`). |
| `GET` | `/api/mechanic/earnings` | Mechanic | Computes live financial ledger: career revenue, labor, parts, and payouts. |

---

### 2.6 Service Lifecycle & Work Orders (`/api/service-requests`)

| Method | Endpoint | Access | Description |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/service-requests` | Customer | Initializes a service dispatch linked to an emergency breakdown report. |
| `POST` | `/api/service-requests/:id/accept` | Mechanic | Claims dispatch ticket; handles concurrency with atomic 409 Conflict rollback. |
| `PATCH` | `/api/service-requests/:id/status` | Mechanic | Advances lifecycle: `EN_ROUTE` $\to$ `ARRIVED` $\to$ `IN_PROGRESS` $\to$ `COMPLETED`. |
| `POST` | `/api/service-requests/:id/quotation` | Mechanic | Records itemized diagnostic fee, labor charge, and replacement parts cost. |
| `POST` | `/api/service-requests/:id/cancel` | Customer/Mech | Cancels active dispatch with recorded justification. |
| `GET` | `/api/service-requests/:id/tracking` | Authenticated | Real-time tracking data: state, vehicle coordinates, mechanic beacon, quotation. |
| `GET` | `/api/service-requests/history` | Authenticated | Lists completed work orders filtered by the caller's role. |

---

### 2.7 Rule-Based Diagnostics & Reviews (`/api/diagnostics`, `/api/reviews`)

| Method | Endpoint | Access | Description |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/diagnostics/classify` | Public | SAE J1979 diagnostic expert classifier evaluating symptoms and fault codes. |
| `POST` | `/api/reviews` | Customer | Submits verified 5-star customer review with sub-scores. |
| `GET` | `/api/reviews/mechanic/:id` | Public | Retrieves verified review stream and Bayesian aggregate reputation. |
| `POST` | `/api/complaints` | Authenticated | Files ISO 20488:2018 municipal dispute grievance. |
| `GET` | `/api/complaints` | Admin | Lists platform grievances for administrative adjudication. |

---

### 2.8 Administrator Governance & SQL Analytics (`/api/admin`)

| Method | Endpoint | Access | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/admin/analytics/overview` | Admin | Live SQL fleet KPIs: active dispatches, completed jobs, timing deltas, categories. |
| `GET` | `/api/admin/mechanics` | Admin | Lists technician applications with optional `status` filter (`PENDING`, `APPROVED`). |
| `PATCH` | `/api/admin/mechanics/:id/verify` | Admin | Commits supervisory approval or rejection with mandatory audit notes. |
| `PATCH` | `/api/admin/complaints/:id/status` | Admin | Updates dispute status (`INVESTIGATING`, `RESOLVED`, `DISMISSED`) with findings. |
| `GET` | `/api/admin/audit-logs` | Admin | Paginated security audit explorer with action filtering and JSON inspector. |

---

## 3. Real-Time WebSocket Telemetry Protocol (Socket.IO)

- **Gateway URL:** `ws://localhost:4000/socket.io/?EIO=4&transport=websocket`
- **Room Isolation:** Clients join dedicated room `request:{serviceRequestId}` upon authenticating.

### WebSocket Event Matrix

| Event Name | Direction | Payload | Description |
| :--- | :---: | :--- | :--- |
| `join:request` | Client $\to$ Server | `{ "serviceRequestId": "uuid" }` | Subscribes socket client to isolated service room. |
| `mechanic:location` | Server $\to$ Client | `{ "latitude": float, "longitude": float }` | Streams live GPS position of responding technician. |
| `service:status` | Server $\to$ Client | `{ "status": "EN_ROUTE", "updatedAt": ISO }` | Broadcasts real-time milestone state advancement. |
| `quotation:submitted` | Server $\to$ Client | `{ "diagnostic": float, "labor": float, "parts": float, "total": float }` | Pushes itemized work order quotation to customer tracking screen. |
| `service:completed` | Server $\to$ Client | `{ "completedAt": ISO }` | Triggers final completion UI and rating modal. |
