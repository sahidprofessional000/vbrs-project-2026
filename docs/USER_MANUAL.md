# VEHICLE BREAKDOWN REPORTING & RESPONSE SYSTEM (VBRS)
# Comprehensive User Operations Manual

**Target Audience:** Motorists (Customers / Drivers) & Certified Field Technicians (Mechanics)  
**System Version:** 1.0.0 (Production-Quality Academic Capstone Release)  

---

## PART 1: MOTORIST & DRIVER OPERATIONS GUIDE

### 1.1 Account Registration & Authentication
1. **Public Portal Gateway:** Navigate to the platform homepage (`http://localhost:3000`).
2. **Accessing Driver Sign In:** In the top navigation bar, click **Driver Portal** or select **Access Motorist Desk** under the dedicated portal gateway card.
3. **Registration:** If you are a new motorist, select **Register New Account**. Enter your legal full name, email address, contact phone number, and a secure password (minimum 8 characters, containing uppercase, lowercase, numbers, and special characters).
4. **Quick-Fill Demo Credentials (Academic Testing):** For academic demonstration, click the **Driver** quick-fill button on the sign-in page to populate credentials for `customer.john@vbrs.local` with password `Password@123`.

---

### 1.2 Managing Your Vehicle Garage (`/customer/vehicles`)
Every emergency breakdown report must be linked to a registered vehicle in your garage.
1. **View Active Fleet:** Navigate to **Garage** in the header navigation or visit `/customer/vehicles`.
2. **Register a Vehicle:**
   - Click the **Add Automobile** or **Register First Car** button.
   - Enter the Make (e.g., `BMW`, `Toyota`, `Tesla`), Model (e.g., `M4 Competition`, `Camry XSE`), Manufacture Year, and Official Monospace License Plate (e.g., `NYC-7842` or `TS28 U0056`).
   - Click **Commit Automobile Registration**.
3. **Primary Vehicle Designation:** Your most recently registered vehicle or designated daily driver is flagged with a **PRIMARY** status tag and automatically pre-selected during roadside emergencies.
4. **Fleet Removal:** Click **Remove** on any vehicle card to safely retire it from your garage.

---

### 1.3 Customer Profile & Saved Dispatch Bookmarks (`/customer/profile`)
1. **Personal Information:** Edit your display name, contact phone number, and profile avatar URL, then click **Save Profile Updates**.
2. **Saved Dispatch Locations:** Bookmark frequent locations (Home Garage, Office Headquarters, Airport Hub) for rapid 1-click incident reporting:
   - Enter a human-readable label (e.g., `Downtown Office`).
   - Enter the street address or click **Autofill Current GPS** to populate your live device coordinates.
   - Click **Save Bookmark**.

---

### 1.4 Reporting a Roadside Breakdown (`/report-breakdown`)
When experiencing a breakdown, speed and location accuracy are critical.

```
[1. Hardware GPS Detection]  -->  [2. Fault Categorization]  -->  [3. Photographic Evidence]  -->  [4. Emergency Dispatch]
```

1. **Initiate Rescue Request:** Click **Request Emergency Rescue** from the home screen or navigation bar.
2. **Geospatial Location Capture:**
   - **Hardware GPS Autofill:** If location permissions are granted, your device's high-precision latitude and longitude coordinates are automatically captured.
   - **Manual Map Pin Fallback:** If GPS is disabled or inaccurate, click and drag the interactive radar pin on the OpenStreetMap Leaflet display to pinpoint your vehicle's physical position.
3. **Vehicle & Fault Selection:**
   - Select your disabled vehicle from the dropdown.
   - Select the Fault Category:
     - `ENGINE_FAILURE` (Overheating, sudden stall, oil pressure warning)
     - `BATTERY_DEAD` (Electrical failure, no crank, dim headlights)
     - `FLAT_TYRE` (Puncture, blowout, tyre pressure loss)
     - `BRAKE_ISSUE` (Spongy pedal, grinding, hydraulic loss)
     - `TRANSMISSION_ISSUE` (Gear slipping, clutch failure, no drive)
     - `ELECTRICAL_FAULT` (Alternator failure, harness short, ECU error)
     - `OUT_OF_FUEL` (Fuel exhaustion, EV battery depletion)
     - `LOCKOUT` (Keys locked inside vehicle)
     - `TOWING_REQUIRED` (Collision damage, unmovable mechanical failure)
4. **Severity Level:** Select `LOW`, `MEDIUM`, `HIGH`, or `CRITICAL`.
5. **Photographic Evidence Upload:**
   - Drag and drop up to 5 clear photographs (PNG, JPEG, WebP) of the mechanical fault, dashboard warnings, or roadside hazard.
   - Files exceeding **5 MB** or containing invalid MIME types are automatically rejected client-side for security.
6. **Transmit Signal:** Click **Transmit Emergency Signal**. The system immediately evaluates the incident against the SAE J1979 Triage Protocol and activates the emergency dispatch state machine.

---

### 1.5 Real-Time Live Service Tracking (`/customer/track/[id]`)
Once submitted, you are automatically redirected to the Live Tracking Terminal:
1. **Milestone Progress Stepper:** Track the status progression in real-time over WebSocket:
   - `SUBMITTED`: Incident recorded in database; awaiting nearest technician claim.
   - `ACCEPTED`: Certified technician has claimed your dispatch and reviewed preliminary triage.
   - `EN_ROUTE`: Technician is actively driving to your GPS coordinates.
   - `ARRIVED`: Technician has reached your scene and commenced visual inspection.
   - `IN_PROGRESS`: On-site diagnostic and mechanical repair work underway.
   - `COMPLETED`: Work order finalized, parts itemized, and vehicle cleared for road use.
2. **Interactive Telemetry Map:** Displays dual coordinates (your vehicle's location and the responding mechanic's live GPS beacon).
3. **Quotation & Parts Approval:** When the technician logs an on-site diagnosis, the authorized work order appears in your tracking terminal itemizing Diagnostic Fee, Labor, and Replacement Parts.
4. **Rating & Reputation Review:** Upon completion, an interactive 5-star rating form unlocks:
   - Provide overall star rating (1 to 5 stars).
   - Rate sub-scores for Response Timeliness, Cost Fairness, and Professionalism.
   - Submit written review comments. The mechanic's Bayesian reputation score is immediately recomputed.

---

## PART 2: FIELD MECHANIC & WORKSHOP OPERATIONS GUIDE

### 2.1 Mechanic Registration & Credential Verification
1. **Technician Portal Gateway:** Click **Technician Desk** from the public homepage or visit `/login?role=MECHANIC&redirect=/mechanic/home`.
2. **Registration:** Register with your workshop name, business address, contact telephone, and state-issued **Trade License Number**.
3. **Administrative Vetting:** New accounts enter `PENDING` verification status. Platform administrators must review and approve credentials before live dispatching is enabled.
4. **Quick-Fill Demo Credentials (Academic Testing):** Click **Technician** quick-fill to log in as Alex Vance (`mechanic.alex@vbrs.local`) or Marcus Sterling (`mechanic.marcus@vbrs.local`) with password `Password@123`.

---

### 2.2 Workshop Terminal (`/mechanic/home`)
The Workshop Terminal is a high-density, professional automotive workspace.

1. **Availability Switch:** Toggle between `AVAILABLE` (Online and beaconing on radar) and `OFFLINE` (Standby mode). When offline, inbound dispatch tickets are isolated and will not ring on your terminal.
2. **Operating Radius Perimeter Slider:** Adjust your service coverage boundary from **10 km** to **100 km**. The Haversine radial engine only routes incidents within your chosen radius.
3. **Hardware GPS Beacon:** Click **Update GPS Coordinates** to transmit your current workshop or mobile service vehicle position to the platform database.
4. **Real Financial Ledger:** Real-time metrics computed directly from PostgreSQL:
   - **Total Revenue:** Accumulated career earnings from completed work orders.
   - **Itemized Labor & Parts:** Breakdown of diagnostic charges versus hardware components.
   - **Average Order Value (AOV):** Mean ticket size per completed dispatch.
   - **Reputation Rating:** Real-time Bayesian-weighted customer score.

---

### 2.3 Dispatch Radar & Claiming Dispatches
1. **Inbound Dispatch Radar:** When a motorist within your operating perimeter submits an incident, it appears in your **Inbound Opportunities** queue with distance in kilometers, vehicle details, severity badge, and reported fault description.
2. **Atomic Dispatch Claiming:** Click **Claim Dispatch**. 
   - If another technician claims the ticket first, the platform catches the HTTP 409 Conflict atomically, displays a collision banner, and rolls back your queue state without data corruption.
3. **Advancing Service Milestones:** Once claimed, the terminal transitions to **Active On-Job Assignment**:
   - Step 1: Click **Start En-Route Dispatch** when departing workshop.
   - Step 2: Click **Mark Arrived on Scene** upon arriving at vehicle.
   - Step 3: Click **Begin Repair Work** after preliminary safety perimeter is established.
4. **Submitting Work Order Quotations:**
   - Enter itemized Diagnostic Fee, Labor Cost, and Replacement Parts Cost.
   - Click **Save Quotation**. The total is instantly broadcast to the customer's live tracking terminal.
5. **Finalizing Job Completion:** Click **Complete Service & Release Vehicle**. The work order is finalized, financial earnings are credited, and your terminal automatically resets to `AVAILABLE`.

---

### 2.4 Interactive 3D Automotive Hologram & CAD Inspection Terminal
Embedded in both the Mechanic Overview (`/mechanic/overview`) and Workshop Workspace (`/mechanic/home`):

1. **360° Free Orbit & Zoom:** Click and drag with mouse (or one-finger drag on touchscreens) to rotate the vehicle continuously in any horizontal or vertical polar angle ($0$ to $\pi$). Use mouse wheel or pinch gesture to zoom in and out. Right-click drag pans the camera across the workspace.
2. **Eight Individually Selectable Subsystems:** Click directly on 3D components or use the technical selector strip:
   - **1. Engine Assembly:** V8 engine block, cylinder heads, red valve covers, intake runners.
   - **2. Battery Module:** 12V AGM/HV enclosure, dual brass terminal posts, orange conduits.
   - **3. Transmission:** 7-speed dual-clutch transmission casing, bell housing, differential hub.
   - **4. Braking System:** 4-wheel cross-drilled carbon-ceramic rotors and red monobloc calipers.
   - **5. Wheels and Tyres:** 4-wheel forged alloy rims with low-profile performance rubber.
   - **6. Suspension:** Coil-over adaptive dampers, chrome piston rods, helical springs.
   - **7. Cooling System:** Dual-pass aluminum crossflow radiator core, electric suction fans.
   - **8. Electrical System:** Bosch Motronic ECU heatsink, wiring loom, power distribution fuse box.
3. **CAD Inspection Modes (Workshop Terminal):**
   - **Standard CAD:** Full textured PBR automotive assembly.
   - **X-Ray Hologram:** Translucent wireframe matrix with internal component emission.
   - **Exploded View:** Mechanically separated subsystem layout revealing sub-assemblies.
   - **Isolated Subsystem:** Hides exterior chassis, focusing exclusively on the active component.
4. **Contextual Diagnostic Telemetry:** Displays active SAE Diagnostic Trouble Codes (DTCs), OEM operating tolerances, common failure symptoms, and recommended shop repair procedures.
