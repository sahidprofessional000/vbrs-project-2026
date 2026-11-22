# PROJECT REQUIREMENTS SPECIFICATION (SRS)

**Project:** Vehicle Breakdown Reporting System (VBRS)  
**Standard:** IEEE 830-1998 Software Requirements Specification Adaptation  
**Classification:** Enterprise Automotive Emergency Services Platform  
**Target Environment:** Local Windows 11 / Modern Web Browsers

---

## 1. Introduction

### 1.1 Purpose
This document provides a formal, comprehensive specification of all functional, non-functional, behavioral, and architectural requirements for the Vehicle Breakdown Reporting System (VBRS). It serves as the single source of truth for engineering implementation, quality assurance, verification, and academic evaluation.

### 1.2 Scope of System
VBRS is a responsive, full-stack web application connecting vehicle drivers encountering roadside failures with nearby certified automotive technicians and towing operators. The platform provides automated incident logging, location pinpointing, proximity discovery, real-time dispatch tracking, status management, post-service dispute handling, and administrative auditing.

---

## 2. Functional Requirements (FR)

### Module 1: User Identity, Authentication & Profiles (FR-AUTH)
- **FR-AUTH-001 [Registration]:** The system shall allow users to register under specific roles: `CUSTOMER` or `MECHANIC`. Platform `ADMIN` accounts are seeded or provisioned via secure admin CLI.
- **FR-AUTH-002 [Password Security]:** Passwords must be at least 8 characters long, containing at least one uppercase letter, one lowercase letter, one number, and one special character. Passwords must be hashed using `bcrypt` (work factor 12) before persistence.
- **FR-AUTH-003 [Authentication]:** The system shall authenticate users using email and password, issuing a signed JSON Web Token (JWT) with user ID, email, and role claims.
- **FR-AUTH-004 [Token Rotation]:** The system shall implement refresh tokens stored in secure `httpOnly`, `SameSite=Lax` cookies with server-side invalidation on logout.
- **FR-AUTH-005 [Role-Based Access Control]:** Every backend endpoint must enforce RBAC guards verifying the user's role before processing requests.
- **FR-AUTH-006 [Profile Management]:** Users shall be able to view and edit their profile details (Name, Phone number, Avatar URL).

### Module 2: Customer Vehicle Management (FR-VEH)
- **FR-VEH-001 [Vehicle Registry]:** Customers shall be able to register multiple vehicles to their garage profile.
- **FR-VEH-002 [Vehicle Attributes]:** Each vehicle entry must record Make, Model, Year, License Plate Number, Vehicle Identification Number (VIN - optional), Color, and Powertrain Type (PETROL, DIESEL, ELECTRIC, HYBRID, CNG).
- **FR-VEH-003 [Validation]:** The system shall enforce unique license plate constraints per user and validate vehicle years (1970 to Current Year + 1).
- **FR-VEH-004 [Default Vehicle]:** Customers can designate a primary vehicle for rapid emergency breakdown filing.

### Module 3: Breakdown Incident Reporting & Diagnosis (FR-BDR)
- **FR-BDR-001 [Intake Wizard]:** Customers shall be able to initiate a breakdown report selecting a registered vehicle or specifying a temporary vehicle.
- **FR-BDR-002 [Fault Classification]:** Customers must categorize the problem from:
  - `ENGINE_FAILURE`
  - `TRANSMISSION_ISSUE`
  - `FLAT_TIRE_WHEEL`
  - `BATTERY_DEAD_ELECTRICAL`
  - `BRAKE_SYSTEM_FAILURE`
  - `OVERHEATING_COOLANT`
  - `FUEL_EMPTY_OR_CONTAMINATED`
  - `LOCKOUT_KEY_LOST`
  - `COLLISION_ACCIDENT`
  - `OTHER_UNKNOWN`
- **FR-BDR-003 [Severity Assessment]:** Customers shall indicate severity: `LOW` (drivable), `MEDIUM` (stalled on shoulder), `CRITICAL` (hazardous roadway, immediate obstruction).
- **FR-BDR-004 [Image Upload]:** Customers can upload up to 5 photographs of the damage/dashboard warning lights. Uploads must be validated on the backend (JPEG, PNG, WebP only, <= 5MB each).
- **FR-BDR-005 [Geospatial Location]:**
  - The system shall capture coordinates using the browser Geolocation API with user consent.
  - If geolocation fails or user declines, the system shall provide an interactive Leaflet map to drag and drop a pin or enter manual coordinates/street description.
- **FR-BDR-006 [Rule-Based Triage]:** The system shall evaluate reported symptoms and advise whether roadside repair is probable or flatbed tow truck is mandatory.

### Module 4: Mechanic Onboarding & Availability Management (FR-MEC)
- **FR-MEC-001 [Mechanic Verification Queue]:** Mechanic accounts must undergo administrative verification before becoming eligible for dispatch. Required fields: Business Name, Trade Certification Number, Years of Experience, Government ID / Trade License document.
- **FR-MEC-002 [Service Competencies]:** Mechanics shall declare their supported service categories and vehicle classes (Motorcycles, Passenger Cars, Heavy Trucks).
- **FR-MEC-003 [Live Availability Toggle]:** Verified mechanics can switch status between `OFFLINE`, `AVAILABLE`, and `BUSY`.
- **FR-MEC-004 [Live Location Beacon]:** When `AVAILABLE`, the mechanic's client shall periodically update its latitude and longitude to the backend.

### Module 5: Geospatial Matching & Dispatch Engine (FR-MATCH)
- **FR-MATCH-001 [Proximity Discovery]:** Upon breakdown report submission, the system executes a Haversine spherical distance query over active mechanics within a configurable radius (default 25 km).
- **FR-MATCH-002 [Ranking Algorithm]:** Eligible mechanics shall be ranked based on:
  1. Distance to incident location.
  2. Compatibility with breakdown category.
  3. Average customer review score.
- **FR-MATCH-003 [Direct Dispatch / Broadcasting]:** The customer can either select a specific mechanic or allow the system to broadcast the request to the top 3 nearest candidates.
- **FR-MATCH-004 [Request Timeout]:** Broadcasted requests shall maintain an automated timeout (e.g., 60 seconds). If rejected or unanswered, the system advances to the next candidate.

### Module 6: Service Request Lifecycle & Real-Time Tracking (FR-REQ)
- **FR-REQ-001 [State Machine Enforcement]:** Service requests must transition strictly through permitted states:
  - `SUBMITTED` -> `SEARCHING` -> `ASSIGNED` -> `ACCEPTED` -> `EN_ROUTE` -> `ARRIVED` -> `IN_PROGRESS` -> `COMPLETED`
  - At any point prior to `ARRIVED`, a request may be transitioned to `CANCELLED` with a documented reason.
- **FR-REQ-002 [Audit Trail of Statuses]:** Every state transition must be recorded in the `service_status_history` table with timestamp, previous state, new state, actor ID, and optional comments.
- **FR-REQ-003 [Real-Time WebSockets]:** The backend Socket.IO gateway must emit updates to designated rooms:
  - `request:{id}`: Broadcasts status changes and telemetry to both customer and mechanic.
  - `mechanic:{id}`: Pushes incoming dispatch alerts.
  - `admin:feed`: Broadcasts platform-wide emergency events.
- **FR-REQ-004 [Live Telemetry Rendering]:** When a mechanic is `EN_ROUTE`, their live coordinate updates must move their marker on the customer's Leaflet tracking screen in real time.

### Module 7: Reviews, Ratings & Dispute Handling (FR-REV)
- **FR-REV-001 [Customer Feedback]:** Upon request completion, the customer can submit a 1 to 5-star rating and written review.
- **FR-REV-002 [Reputation Recalculation]:** The mechanic's overall rating average and job counter must automatically update upon review submission.
- **FR-REV-003 [Complaint Lodging]:** Customers or mechanics can file an official complaint against a completed or cancelled service request.
- **FR-REV-004 [Complaint Moderation]:** Admins can review complaints, request additional statements, and set resolution status (`PENDING`, `INVESTIGATING`, `RESOLVED`, `DISMISSED`).

### Module 8: Administrative Governance & Analytics (FR-ADM)
- **FR-ADM-001 [User Directory]:** Administrators shall be able to view, search, filter, and suspend/reactivate any customer or mechanic account.
- **FR-ADM-002 [Verification Approval]:** Admins can review mechanic credential documents and click `APPROVE` or `REJECT` with justification notes.
- **FR-ADM-003 [Live Incident Map]:** Admins can visualize all currently active breakdowns and mechanic locations on a global Leaflet command map.
- **FR-ADM-004 [Real-Time Analytics]:** Dashboard displaying:
  - Breakdown counts by category (pie chart).
  - Daily incident frequency trends (line chart).
  - Average response time and resolution duration.
  - Geographic hotspot distribution.
- **FR-ADM-005 [Audit Log Inspection]:** Administrators can inspect system activity logs with search filters for date, user, and action type.

---

## 3. Non-Functional Requirements (NFR)

### 3.1 Performance & Latency (NFR-PERF)
- **NFR-PERF-001:** REST API endpoint response time shall not exceed 300ms for 95% of standard queries under local development load.
- **NFR-PERF-002:** WebSocket event propagation latency between mechanic coordinate submission and customer map marker update shall be under 500ms over local networks.
- **NFR-PERF-003:** Geospatial Haversine calculation queries across 1,000 mechanic coordinate records shall execute in under 50ms using indexed coordinates.

### 3.2 Security & Data Integrity (NFR-SEC)
- **NFR-SEC-001:** Zero hardcoded API keys, JWT secrets, or credentials in repository files. All secrets loaded strictly via environment variables.
- **NFR-SEC-002:** Rate limiting applied to sensitive endpoints (e.g., maximum 5 failed login attempts per IP per minute).
- **NFR-SEC-003:** Uploaded image filenames must be cryptographically hashed (UUID v4) and stripped of EXIF metadata before disk persistence.
- **NFR-SEC-004:** CORS configuration restricted to authorized origins (e.g., `http://localhost:3000`).

### 3.3 Usability & Accessibility (NFR-USE)
- **NFR-USE-001:** Adherence to WCAG 2.1 Level AA color contrast ratios (minimum 4.5:1 for normal text) across both dark and light modes.
- **NFR-USE-002:** Fully responsive viewport support ranging from mobile viewports (360px width) through 4K desktop screens.
- **NFR-USE-003:** Zero dead controls, dummy links, or unhandled form submissions. Every button must trigger a verified handler, loading state, and user-facing toast feedback.

### 3.4 Reliability, Fault Tolerance & Zero-Cost Compliance (NFR-REL)
- **NFR-REL-001:** Zero paid cloud API dependencies. The system must operate fully within a local Windows 11 development environment.
- **NFR-REL-002:** If OpenStreetMap tile servers are unreachable, the Leaflet map component must display an informative fallback grid without crashing the application.
- **NFR-REL-003:** All asynchronous state updates and network failures must display clear, actionable human-readable error messages with retry buttons.
