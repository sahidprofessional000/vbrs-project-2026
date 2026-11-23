# APPENDIX B: DATABASE SCHEMA & DATA DICTIONARY

## 1. Relational Schema Summary
The VBRS persistence layer is implemented in **PostgreSQL 16** and orchestrated via **Prisma ORM 5.22**. The schema enforces strict foreign key constraints, composite unique indexes, referential cascades, and enumeration types.

## 2. Core Entities & Attributes

### Table: `users`
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() | Unique identifier for user |
| `email` | VARCHAR(255) | UNIQUE, NOT NULL | User email address (login credential) |
| `passwordHash`| VARCHAR(255) | NOT NULL | Bcrypt hash with salt cost 12 |
| `fullName` | VARCHAR(120) | NOT NULL | Full legal name |
| `phone` | VARCHAR(30) | NOT NULL | Contact telephone number |
| `role` | UserRole | NOT NULL, DEFAULT 'CUSTOMER' | Enum: `CUSTOMER`, `MECHANIC`, `ADMIN` |
| `isVerified` | BOOLEAN | NOT NULL, DEFAULT false | Administrative verification flag |
| `refreshTokenHash` | VARCHAR(255) | NULLABLE | SHA-256 hash of active refresh token |
| `createdAt` | TIMESTAMP | NOT NULL, DEFAULT now() | Record creation timestamp |
| `updatedAt` | TIMESTAMP | NOT NULL, DEFAULT now() | Record update timestamp |

### Table: `mechanic_profiles`
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() | Unique identifier |
| `userId` | UUID | UNIQUE, NOT NULL, FK -> users(id) ON DELETE CASCADE | Associated mechanic user |
| `workshopName` | VARCHAR(150) | NOT NULL | Registered trading or workshop name |
| `latitude` | DOUBLE PRECISION | NOT NULL | Workshop / current base latitude |
| `longitude` | DOUBLE PRECISION | NOT NULL | Workshop / current base longitude |
| `isAvailable` | BOOLEAN | NOT NULL, DEFAULT true | Live beacon toggle |
| `serviceRadiusKm` | DOUBLE PRECISION | NOT NULL, DEFAULT 15.0 | Operating dispatch radius in km |
| `specialties` | TEXT[] | NOT NULL, DEFAULT '{}' | Array of certified subsystems |
| `averageRating`| DOUBLE PRECISION | NOT NULL, DEFAULT 0.0 | Calculated mean review score |
| `reviewCount` | INTEGER | NOT NULL, DEFAULT 0 | Total verified customer reviews |

### Table: `vehicles`
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() | Unique vehicle ID |
| `userId` | UUID | NOT NULL, FK -> users(id) ON DELETE CASCADE | Owner customer reference |
| `make` | VARCHAR(50) | NOT NULL | Manufacturer (e.g., Hyundai, Toyota) |
| `model` | VARCHAR(50) | NOT NULL | Model designation (e.g., Tucson, Civic) |
| `year` | INTEGER | NOT NULL | Year of manufacture |
| `plateNumber` | VARCHAR(20) | NOT NULL | Vehicle registration identifier |
| `color` | VARCHAR(30) | NOT NULL | Vehicle paint color |

### Table: `breakdown_reports`
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() | Unique incident identifier |
| `customerId` | UUID | NOT NULL, FK -> users(id) ON DELETE RESTRICT | Reporting customer |
| `vehicleId` | UUID | NOT NULL, FK -> vehicles(id) ON DELETE RESTRICT | Affected vehicle |
| `latitude` | DOUBLE PRECISION | NOT NULL | Exact incident GPS latitude |
| `longitude` | DOUBLE PRECISION | NOT NULL | Exact incident GPS longitude |
| `address` | TEXT | NOT NULL | Reverse-geocoded road or location |
| `issueDescription` | TEXT | NOT NULL | Detailed breakdown description |
| `subsystem` | SubsystemCategory | NOT NULL | Subsystem (ENGINE, BRAKES, etc.) |
| `photoUrls` | TEXT[] | NOT NULL, DEFAULT '{}' | Cloudinary CDN photographic proof |
| `status` | IncidentStatus | NOT NULL, DEFAULT 'PENDING' | `PENDING`, `DISPATCHED`, `RESOLVED`, `CANCELLED` |

### Table: `service_requests`
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() | Unique dispatch job ID |
| `breakdownReportId` | UUID | NOT NULL, FK -> breakdown_reports(id) ON DELETE RESTRICT | Incident ticket |
| `mechanicId` | UUID | NOT NULL, FK -> users(id) ON DELETE RESTRICT | Assigned technician |
| `status` | ServiceStatus | NOT NULL, DEFAULT 'PENDING' | `PENDING`, `ACCEPTED`, `IN_PROGRESS`, `COMPLETED`, `CANCELLED` |
| `etaMinutes` | INTEGER | NOT NULL, DEFAULT 15 | Estimated arrival time |
| `quotedPrice` | DECIMAL(10,2) | NOT NULL, DEFAULT 0.00 | Initial repair estimate |
| `finalPrice` | DECIMAL(10,2) | NOT NULL, DEFAULT 0.00 | Actual invoiced fee |

### Table: `audit_logs`
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() | Unique log ID |
| `userId` | UUID | NULLABLE, FK -> users(id) ON DELETE SET NULL | Acting user |
| `action` | VARCHAR(100) | NOT NULL | Action (e.g., USER_LOGIN, VERIFY_MECHANIC) |
| `entity` | VARCHAR(100) | NOT NULL | Affected database entity |
| `entityId` | VARCHAR(100) | NULLABLE | ID of modified row |
| `ipAddress` | VARCHAR(50) | NOT NULL | Client IP address |
| `metadata` | JSONB | NULLABLE | Detailed before/after state diff |
| `createdAt` | TIMESTAMP | NOT NULL, DEFAULT now() | Log generation timestamp |
