# SYSTEM ARCHITECTURE DOCUMENT

**Project:** Vehicle Breakdown Reporting System (VBRS)  
**Architecture Style:** Modular Monolith / Clean N-Tier Distributed Architecture  
**Document Version:** 1.0.0

---

## 1. System Topology & Physical Architecture

```mermaid
graph TB
    subgraph ClientLayer ["Client Layer (Browser / Windows 11)"]
        CustomerUI["Customer Portal (Next.js 14 / React)"]
        MechanicUI["Mechanic Terminal (Next.js 14 / React)"]
        AdminUI["Admin Command Center (Next.js 14 / React)"]
        LeafletOSM["Leaflet.js + OSM Raster Tiles"]
        SocketClient["Socket.IO Client (Real-time events)"]
    end

    subgraph APILayer ["Backend Service Layer (NestJS / Node.js)"]
        Gateway["HTTP / REST API Gateway (Port 4000)"]
        WSServer["WebSocket Gateway (Socket.IO Engine)"]
        AuthGuard["JWT / RBAC Authorization Guards"]
        ValidationPipe["Class-Validator Input Sanitizer"]
        
        subgraph CoreModules ["Core NestJS Domain Modules"]
            AuthModule["Auth & Profile Module"]
            VehicleModule["Vehicle Garage Module"]
            BreakdownModule["Breakdown Intake Module"]
            DiscoveryModule["Haversine Proximity Engine"]
            RequestModule["Service Lifecycle Engine"]
            ReviewModule["Reviews & Complaints Module"]
            AdminModule["Admin & Analytics Module"]
            DiagnosisModule["Rule-Based Diagnosis Engine"]
        end
    end

    subgraph StorageLayer ["Persistence & File Storage (Zero-Cost Local)"]
        PrismaORM["Prisma ORM Client"]
        PostgresDB[(PostgreSQL 16 Local Database)]
        LocalStorage[("Local Static Uploads (/uploads)")]
    end

    CustomerUI -->|HTTP / REST| Gateway
    MechanicUI -->|HTTP / REST| Gateway
    AdminUI -->|HTTP / REST| Gateway

    CustomerUI <-->|Bidirectional WebSockets| WSServer
    MechanicUI <-->|Bidirectional WebSockets| WSServer
    AdminUI <-->|Bidirectional WebSockets| WSServer

    CustomerUI --> LeafletOSM
    MechanicUI --> LeafletOSM
    AdminUI --> LeafletOSM

    Gateway --> AuthGuard
    AuthGuard --> ValidationPipe
    ValidationPipe --> CoreModules

    CoreModules --> PrismaORM
    PrismaORM --> PostgresDB
    BreakdownModule --> LocalStorage
    AuthModule --> LocalStorage
```

---

## 2. Service Request Lifecycle State Machine

A vehicle breakdown request moves through an explicit, strictly enforced state machine. Invalid state transitions are rejected by the backend with HTTP `400 Bad Request` or `409 Conflict`.

```mermaid
stateDiagram-v2
    [*] --> SUBMITTED: Customer files breakdown report
    SUBMITTED --> SEARCHING: System searches nearby mechanics
    SEARCHING --> ASSIGNED: Mechanic selected / broadcast dispatched
    ASSIGNED --> ACCEPTED: Mechanic accepts assignment
    ASSIGNED --> SEARCHING: Mechanic rejects / timeout expires
    ACCEPTED --> EN_ROUTE: Mechanic starts travel to customer
    EN_ROUTE --> ARRIVED: Mechanic reaches breakdown location
    ARRIVED --> IN_PROGRESS: Mechanic starts diagnosis / repairs
    IN_PROGRESS --> COMPLETED: Service finished & signed off
    
    SUBMITTED --> CANCELLED: Customer cancels request
    SEARCHING --> CANCELLED: Customer cancels request
    ASSIGNED --> CANCELLED: Customer cancels request
    ACCEPTED --> CANCELLED: Customer / Mechanic cancels with reason
    EN_ROUTE --> CANCELLED: Customer / Mechanic cancels with emergency reason

    COMPLETED --> [*]
    CANCELLED --> [*]
```

### 2.1 State Transition Validation Matrix
| From State | Allowed Target States | Permitted Roles | Required Conditions |
| :--- | :--- | :--- | :--- |
| `SUBMITTED` | `SEARCHING`, `CANCELLED` | Customer, Admin | Report has valid coordinates & vehicle |
| `SEARCHING` | `ASSIGNED`, `CANCELLED` | System, Customer, Admin | At least one available mechanic found |
| `ASSIGNED` | `ACCEPTED`, `SEARCHING`, `CANCELLED` | Mechanic, Customer, System | Response timeout (60s default) |
| `ACCEPTED` | `EN_ROUTE`, `CANCELLED` | Mechanic, Customer, Admin | Mechanic commits to travel |
| `EN_ROUTE` | `ARRIVED`, `CANCELLED` | Mechanic, Admin | Mechanic GPS indicates proximity |
| `ARRIVED` | `IN_PROGRESS` | Mechanic | On-site inspection commences |
| `IN_PROGRESS` | `COMPLETED` | Mechanic, Customer, Admin | Work performed, summary notes logged |
| `COMPLETED` | *Terminal State* | - | Enables customer review submission |
| `CANCELLED` | *Terminal State* | - | Cancellation reason saved to history |

---

## 3. Database Entity Relationship (ER) Schema

The database model separates the immutable **Breakdown Report** (the physical incident details) from the transient **Service Request** (the operational dispatch and resolution transaction).

```mermaid
erDiagram
    USERS ||--o{ VEHICLES : "owns"
    USERS ||--o| MECHANIC_PROFILES : "has"
    USERS ||--o{ BREAKDOWN_REPORTS : "reports"
    USERS ||--o{ SERVICE_REQUESTS : "requests (as customer)"
    USERS ||--o{ SERVICE_REQUESTS : "executes (as mechanic)"
    USERS ||--o{ REVIEWS : "writes / receives"
    USERS ||--o{ COMPLAINTS : "files"
    USERS ||--o{ NOTIFICATIONS : "receives"
    USERS ||--o{ AUDIT_LOGS : "triggers"

    MECHANIC_PROFILES ||--o{ MECHANIC_SERVICES : "offers"
    MECHANIC_PROFILES ||--o| MECHANIC_LOCATIONS : "current_coords"

    BREAKDOWN_REPORTS ||--o{ REPORT_IMAGES : "contains"
    BREAKDOWN_REPORTS ||--o| SERVICE_REQUESTS : "initiates"
    VEHICLES ||--o{ BREAKDOWN_REPORTS : "subject_of"

    SERVICE_REQUESTS ||--o{ SERVICE_STATUS_HISTORY : "tracks"
    SERVICE_REQUESTS ||--o| REVIEWS : "evaluated_by"
    SERVICE_REQUESTS ||--o{ COMPLAINTS : "disputed_by"

    USERS {
        uuid id PK
        string email UK
        string password_hash
        string full_name
        string phone
        string role "CUSTOMER | MECHANIC | ADMIN"
        string avatar_url
        boolean is_active
        datetime created_at
        datetime updated_at
    }

    VEHICLES {
        uuid id PK
        uuid user_id FK
        string make
        string model
        int year
        string license_plate
        string vin
        string color
        string powertrain "PETROL | DIESEL | ELECTRIC | HYBRID | CNG"
        boolean is_default
        datetime created_at
    }

    MECHANIC_PROFILES {
        uuid id PK
        uuid user_id FK,UK
        string workshop_name
        string trade_license_number
        int experience_years
        string verification_status "PENDING | APPROVED | REJECTED"
        string verification_notes
        string availability_status "OFFLINE | AVAILABLE | ON_JOB"
        float operating_radius_km
        float rating_average
        int total_jobs_completed
        string document_url
        datetime created_at
    }

    MECHANIC_LOCATIONS {
        uuid id PK
        uuid mechanic_id FK,UK
        float latitude
        float longitude
        float heading
        float speed
        datetime updated_at
    }

    BREAKDOWN_REPORTS {
        uuid id PK
        uuid customer_id FK
        uuid vehicle_id FK
        string category
        string severity "LOW | MEDIUM | CRITICAL"
        string description
        float latitude
        float longitude
        string address_text
        string rule_diagnosis
        boolean requires_towing
        datetime created_at
    }

    REPORT_IMAGES {
        uuid id PK
        uuid report_id FK
        string file_path
        string file_name
        int file_size
        string mime_type
        datetime created_at
    }

    SERVICE_REQUESTS {
        uuid id PK
        uuid breakdown_report_id FK,UK
        uuid customer_id FK
        uuid mechanic_id FK
        string current_status
        float agreed_quote
        string resolution_notes
        datetime assigned_at
        datetime accepted_at
        datetime arrived_at
        datetime completed_at
        datetime cancelled_at
        string cancellation_reason
    }

    SERVICE_STATUS_HISTORY {
        uuid id PK
        uuid service_request_id FK
        string from_status
        string to_status
        uuid changed_by FK
        string notes
        datetime timestamp
    }

    REVIEWS {
        uuid id PK
        uuid service_request_id FK,UK
        uuid customer_id FK
        uuid mechanic_id FK
        int rating
        string comment
        datetime created_at
    }

    COMPLAINTS {
        uuid id PK
        uuid service_request_id FK
        uuid filed_by FK
        uuid target_user_id FK
        string subject
        string description
        string status "PENDING | INVESTIGATING | RESOLVED | DISMISSED"
        string resolution_notes
        datetime created_at
        datetime resolved_at
    }

    NOTIFICATIONS {
        uuid id PK
        uuid user_id FK
        string title
        string message
        string type
        json payload
        boolean is_read
        datetime created_at
    }

    AUDIT_LOGS {
        uuid id PK
        uuid user_id FK
        string action
        string entity_name
        string entity_id
        json details
        string ip_address
        datetime timestamp
    }
```

---

## 4. Geospatial Proximity Algorithm (Zero-Cost Haversine Engine)

To locate eligible mechanics without paid Google Maps Distance Matrix or proprietary spatial servers, the backend calculates the Great-Circle distance using the Haversine trigonometric formula directly in SQL or TypeScript:

$$\Delta\phi = \phi_2 - \phi_1$$
$$\Delta\lambda = \lambda_2 - \lambda_1$$
$$a = \sin^2\left(\frac{\Delta\phi}{2}\right) + \cos(\phi_1)\cdot\cos(\phi_2)\cdot\sin^2\left(\frac{\Delta\lambda}{2}\right)$$
$$c = 2 \cdot \text{atan2}\left(\sqrt{a}, \sqrt{1-a}\right)$$
$$d = R \cdot c \quad \text{where } R = 6371.0 \text{ km}$$

### SQL Query Implementation Pattern
```sql
SELECT 
    m.id AS mechanic_id,
    u.full_name,
    m.workshop_name,
    m.rating_average,
    loc.latitude,
    loc.longitude,
    (
        6371 * acos(
            cos(radians(:customerLat)) * cos(radians(loc.latitude)) *
            cos(radians(loc.longitude) - radians(:customerLng)) +
            sin(radians(:customerLat)) * sin(radians(loc.latitude))
        )
    ) AS distance_km
FROM "MechanicProfile" m
JOIN "User" u ON m."userId" = u.id
JOIN "MechanicLocation" loc ON m.id = loc."mechanicId"
WHERE m."verificationStatus" = 'APPROVED'
  AND m."availabilityStatus" = 'AVAILABLE'
  AND (
        6371 * acos(
            cos(radians(:customerLat)) * cos(radians(loc.latitude)) *
            cos(radians(loc.longitude) - radians(:customerLng)) +
            sin(radians(:customerLat)) * sin(radians(loc.latitude))
        )
  ) <= m."operatingRadiusKm"
ORDER BY distance_km ASC
LIMIT 10;
```

---

## 5. Real-Time Communication Protocol (Socket.IO)

### Room Structure
- `customer:{customerId}` - Direct alerts to vehicle owners.
- `mechanic:{mechanicId}` - Dispatch requests and job offers to mechanics.
- `request:{requestId}` - Active shared channel for ongoing service engagements between customer and assigned mechanic.
- `admin:monitor` - Platform-wide operational telemetry for the admin dashboard.

### Event Catalog
| Event Name | Direction | Payload Schema | Purpose |
| :--- | :--- | :--- | :--- |
| `mechanic:location_update` | Client -> Server | `{ latitude, longitude, heading, speed }` | Mechanic sends live position |
| `request:status_changed` | Server -> Client | `{ requestId, fromStatus, toStatus, timestamp }` | Broadcasts state changes |
| `mechanic:location_broadcast` | Server -> Client | `{ requestId, latitude, longitude, heading }` | Streams mechanic position to customer |
| `dispatch:incoming` | Server -> Client | `{ requestId, breakdownCategory, distanceKm, vehicleInfo }` | Notifies mechanic of nearby breakdown |
| `dispatch:response` | Client -> Server | `{ requestId, accepted: boolean, reason?: string }` | Mechanic accepts/declines job |

---

## 6. Directory Structure & Monorepo Topology

```
VEHICLE BREAKDOWN SYSTEM/
├── .env.example                     # Root environment variable documentation
├── docker-compose.yml               # Local PostgreSQL 16 container definition
├── README.md                        # Master repository documentation
├── package.json                     # Root orchestration scripts
├── PRODUCT.md                       # Product vision & UX mode definitions
├── DESIGN.md                        # Design system tokens (graphite/slate palette)
├── docs/                            # Comprehensive engineering documentation
│   ├── PROJECT_BLUEPRINT.md
│   ├── PROJECT_STATUS.md
│   ├── ARCHITECTURE.md
│   └── REQUIREMENTS.md
├── backend/                         # NestJS Enterprise API Server
│   ├── package.json
│   ├── tsconfig.json
│   ├── nest-cli.json
│   ├── .env.example
│   ├── prisma/
│   │   ├── schema.prisma            # 14 entities with relations, enums & indexes
│   │   └── seed.ts                  # Seed script for initial admin, test users
│   └── src/
│       ├── main.ts                  # NestJS bootstrap, Swagger, Pipes, CORS
│       ├── app.module.ts            # Root module wiring
│       ├── common/                  # Shared guards, filters, interceptors, pipes
│       │   ├── decorators/
│       │   ├── filters/
│       │   ├── guards/
│       │   └── interceptors/
│       ├── config/                  # Validated configuration service
│       └── modules/                 # Modular domain features
│           ├── prisma/
│           ├── health/
│           ├── auth/
│           ├── users/
│           ├── vehicles/
│           ├── breakdowns/
│           ├── mechanics/
│           ├── requests/
│           ├── realtime/
│           ├── reviews/
│           ├── complaints/
│           ├── admin/
│           └── diagnosis/
└── frontend/                        # Next.js 14 App Router Web Client
    ├── package.json
    ├── tsconfig.json
    ├── next.config.mjs
    ├── tailwind.config.ts           # Graphite/slate theme token configuration
    ├── postcss.config.mjs
    ├── .env.example
    └── src/
        ├── app/                     # App router pages & layouts
        │   ├── layout.tsx
        │   ├── page.tsx             # Professional landing page
        │   ├── (auth)/              # Login, register, forgot-password
        │   ├── customer/            # Customer portal routes
        │   ├── mechanic/            # Mechanic terminal routes
        │   └── admin/               # Admin command center routes
        ├── components/              # Shared UI design system components
        │   ├── ui/                  # Buttons, cards, modals, skeletons, badges
        │   ├── maps/                # Leaflet map container & marker overlays
        │   └── shared/              # Navbar, sidebar, notifications
        ├── lib/                     # API client, Socket client, utilities
        └── types/                   # Shared TypeScript interfaces
```
