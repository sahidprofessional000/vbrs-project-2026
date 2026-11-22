# VEHICLE BREAKDOWN REPORTING & RESPONSE SYSTEM (VBRS)
# Platform Administrator Governance & Operations Manual

**Target Audience:** Platform System Administrators, Municipal Supervisors & Compliance Officers  
**System Version:** 1.0.0 (Production-Quality Academic Capstone Release)  

---

## 1. Executive Governance Overview

The VBRS **Admin Command Center** (`/admin/dashboard`) provides supervisory oversight, fraud detection, credential vetting, dispute resolution, and operational fleet analytics for metropolitan roadside assistance networks. 

All metrics, graphs, and audit records on the administrator desk are calculated strictly from live PostgreSQL SQL aggregations with **zero synthetic data or hardcoded fallbacks**.

---

## 2. Administrator Access & Authentication

1. **Sign-In Endpoint:** Navigate to `http://localhost:3000/login?role=ADMIN&redirect=/admin/dashboard`.
2. **Platform Credentials:** 
   - **Email:** `admin@vbrs.local`
   - **Password:** `Password@123`
   - *Quick-Fill:* Click the **Admin** button on the login screen.
3. **Role Guards & Session Security:** 
   - The platform strictly enforces Role-Based Access Control (`Role.ADMIN`).
   - If an unauthenticated user or user with `CUSTOMER` or `MECHANIC` roles attempts to access `/admin/*`, the layout guard intercepts the request and cleanly redirects to the authorized portal.
   - Administrative sessions are governed by cryptographically signed JWT access tokens (15-minute lifespan) and HttpOnly refresh token cookies with automatic rotation.

---

## 3. Desk 1: Operational Fleet Analytics & Live SQL Telemetry

The Operational Command Center aggregates real-time metrics across all metropolitan dispatches:

### Core Fleet Metrics Matrix
- **Total Incidents:** Cumulative count of all breakdown reports recorded in the PostgreSQL database.
- **Active Dispatches:** Real-time count of dispatches currently in `ACCEPTED`, `EN_ROUTE`, `ARRIVED`, or `IN_PROGRESS` states.
- **Completed Operations:** Successfully finalized work orders with verified customer receipt.
- **Cancelled Operations:** Abandoned or revoked requests with recorded cancellation reasons.
- **Towing Required Ratio (%):** Percentage of breakdowns requiring heavy flatbed recovery vs roadside repair.
- **Registered Vehicles & Verified Drivers:** Total garage inventory and unique customer profiles.
- **Active Field Technicians:** Total onboarded technicians, broken down by `APPROVED` vs `PENDING`.

### Real SQL Response Timing Calculations
Unlike legacy dispatch systems with hardcoded estimates, VBRS computes exact operational timings from actual database timestamp deltas:
- **Average Dispatch Latency:** Mean minutes between customer incident submission (`BreakdownReport.createdAt`) and technician acceptance (`ServiceRequest.acceptedAt`):
  $$\text{Latency} = \frac{1}{N}\sum_{i=1}^{N} \frac{\text{acceptedAt}_i - \text{createdAt}_i}{60 \text{ seconds}}$$
- **Average Service Duration:** Mean minutes between technician arrival on scene and job completion (`ServiceRequest.completedAt`):
  $$\text{Duration} = \frac{1}{M}\sum_{j=1}^{M} \frac{\text{completedAt}_j - \text{acceptedAt}_j}{60 \text{ seconds}}$$
*Note: If zero completed records exist, both fields evaluate strictly to `0.0` with no fabricated constants.*

### Breakdown Category Distribution
Displays live SQL aggregation of breakdown causes (`ENGINE_FAILURE`, `BATTERY_DEAD`, `FLAT_TYRE`, `TRANSMISSION_ISSUE`, etc.) to inform municipal spare parts inventory and roadside recovery positioning.

### Top Field Technicians Leaderboard
Ranks technicians by real Bayesian-weighted customer reputation scores, completed work orders, and approved operating perimeters.

---

## 4. Desk 2: Field Technician Credential Vetting Gate

To guarantee public safety and professional competence, independent mechanics cannot receive dispatch dispatches until verified by an administrator.

### Verification Workflow
1. Navigate to the **Technician Credential Desk** tab on the Admin Command Center.
2. Filter profiles by status:
   - `PENDING`: Newly registered mechanics or existing mechanics who updated their trade licenses.
   - `APPROVED`: Fully vetted technicians with active dispatch authorization.
   - `REJECTED`: Applications denied due to invalid licensing or failed background checks.
3. Click **Review Credentials** on any technician card to open the Supervisory Vetting Modal.
4. **Audit Inspection:**
   - Verify Legal Workshop Name and physical facility address.
   - Verify State Trade License Number against state regulatory registries.
   - Inspect listed Technical Specializations (e.g., Heavy Towing, Hybrid/EV High Voltage, Transmission Rebuild).
   - Inspect ASE & Manufacturer Certifications.
5. **Committing Supervisory Decisions:**
   - Enter required **Administrative Supervisory Notes** (e.g., `"Verified against New York State DMV Repair Shop Registry; ASE Master Tech credentials valid."`).
   - Click **Approve Credentials** or **Reject Application**.
   - An immutable security audit log (`MECHANIC_VERIFICATION_APPROVED` or `MECHANIC_VERIFICATION_REJECTED`) is recorded with the administrator's user ID and timestamp.
   - The technician's terminal is immediately unlocked or suspended in real-time.

---

## 5. Desk 3: Municipal Dispute & Grievance Desk

Governed by principles derived from **ISO 20488:2018 (Online Consumer Reviews)**, this desk enables fair adjudication of motorist grievances and technician dispute appeals.

### Managing Disputes
1. Navigate to the **Dispute & Grievance Desk** tab.
2. Filter grievances by investigation status (`ALL`, `PENDING`, `INVESTIGATING`, `RESOLVED`, `DISMISSED`).
3. Click **Manage Dispute** on any contested incident ticket to open the Mediation Terminal.
4. **Investigation Actions:**
   - Review motorist's complaint statement and attached photographic evidence.
   - Cross-reference technician's work order quotation, parts itemization, and GPS telemetry timestamps.
   - Select updated investigation status (`INVESTIGATING`, `RESOLVED`, `DISMISSED`).
   - Enter **Binding Administrative Resolution Notes** detailing findings and any agreed financial adjustments.
   - Click **Commit Resolution**.
5. **Clean Authentic Empty State:** When no disputes are filed, the desk renders a clean empty state card: `"No disputes filed matching status 'ALL'. All service operations running smoothly."`

---

## 6. Desk 4: Immutable Security Audit Log Explorer

The Audit Log Explorer provides a tamper-evident administrative ledger recording every critical state transition across the platform.

### Logged Administrative & System Actions
- `USER_REGISTERED`: New customer or technician account creation.
- `USER_LOGGED_IN` / `USER_LOGGED_OUT`: Authentication events with session tracking.
- `BREAKDOWN_REPORT_CREATED`: New roadside emergency intake signal.
- `DISPATCH_ACCEPTED`: Technician claims roadside incident ticket.
- `SERVICE_STATUS_*`: Lifecycle milestones (`EN_ROUTE`, `ARRIVED`, `IN_PROGRESS`, `COMPLETED`).
- `MECHANIC_VERIFICATION_APPROVED` / `REJECTED`: Supervisory credential decisions.
- `COMPLAINT_STATUS_RESOLVED`: Municipal dispute adjudications.
- `PROFILE_UPDATED`: Customer or mechanic profile modifications.

### Searching & Inspecting Audit Records
1. Navigate to the **Security Audit Log Explorer** tab.
2. **Filtering:** Search by action keyword (e.g., `MECHANIC_VERIFICATION`, `USER_LOGGED_IN`, `SERVICE_STATUS`).
3. **Payload Inspection:** Click **Inspect** on any log row to open the JSON Payload Inspector modal:
   - View Actor User ID and Full Name.
   - View Target Entity Type (`User`, `MechanicProfile`, `ServiceRequest`, `Complaint`).
   - View Target Entity ID.
   - View Raw Metadata JSON containing before/after state diffs, license numbers, or dispute notes.
   - *Sensitive Data Masking:* Passwords, hashed tokens, and private payment details are strictly excluded from audit payloads.
