# VEHICLE BREAKDOWN REPORTING SYSTEM (VBRS)
### Final Comprehensive Academic Project Documentation & Software Engineering Report
**Academic Year:** 2026–2027  
**Department:** Department of Computer Science and Engineering (Artificial Intelligence and Machine Learning)  
**Institution:** Vasireddy Venkatadri International Technological University (VVITU)  
**Course / Subject:** Software Engineering – ABL Project (ABL-SE-2026)  

---

### Project Faculty Guide:
**Dr. Firoz**, Ph.D.  
Department of Computer Science and Engineering (AI & ML)  
Vasireddy Venkatadri International Technological University  

### Project Development Team:
1. **Sajja Niskala** — Reg. No: 23BQ1A4248
2. **Shaik Sahana** — Reg. No: 23BQ1A4251
3. **Sai Dinesh Sakhamuri** — Reg. No: 23BQ1A4249
4. **Shaik Sahid** — Reg. No: 23BQ1A4253 (Lead Full-Stack & 3D Systems Architect)
5. **Saikam Venkata Phanindra Reddy** — Reg. No: 23BQ1A4250

---

## CERTIFICATE OF APPROVAL

This is to certify that the project entitled **"VEHICLE BREAKDOWN REPORTING SYSTEM (VBRS)"** is a bona fide record of the work carried out by:
- **Sajja Niskala** (23BQ1A4248)
- **Shaik Sahana** (23BQ1A4251)
- **Sai Dinesh Sakhamuri** (23BQ1A4249)
- **Shaik Sahid** (23BQ1A4253)
- **Saikam Venkata Phanindra Reddy** (23BQ1A4250)

students of B.Tech in the Department of Computer Science and Engineering (Artificial Intelligence and Machine Learning) at **Vasireddy Venkatadri International Technological University (VVITU)**, during the academic year **2026–2027**, in partial fulfillment of the requirements for the award of the Degree of Bachelor of Technology in Computer Science and Engineering.

The results embodied in this report have been verified through automated regression suites (171 backend tests, 15 Playwright E2E browser test suites) and genuine PostgreSQL relational database verification. This work has not been submitted to any other University or Institute for the award of any degree or diploma.

<br><br>
<table width="100%" style="border:none; margin-top: 50px;">
  <tr>
    <td align="left" style="border:none;">
      ___________________________<br>
      <b>Dr. Firoz</b><br>
      Project Guide &amp; Faculty Mentor<br>
      Dept. of CSE (AI &amp; ML), VVITU
    </td>
    <td align="center" style="border:none;">
      ___________________________<br>
      <b>Head of Department</b><br>
      Dept. of CSE (AI &amp; ML)<br>
      VVITU
    </td>
    <td align="right" style="border:none;">
      ___________________________<br>
      <b>External Examiner</b><br>
      Board of Examiners<br>
      VVITU
    </td>
  </tr>
</table>

---

## DECLARATION

We hereby declare that the project report entitled **"VEHICLE BREAKDOWN REPORTING SYSTEM (VBRS)"** submitted to the Department of Computer Science and Engineering (Artificial Intelligence and Machine Learning), **Vasireddy Venkatadri International Technological University (VVITU)**, is an authentic record of our own research and software engineering development carried out under the supervision of **Dr. Firoz**.

We confirm that:
1. The work presented in this document is original and has been implemented as a fully functional, enterprise-grade web application utilizing Next.js 14, NestJS 10, PostgreSQL 16, Prisma ORM 5.22, Three.js, and Leaflet.
2. The empirical test metrics, verification logs, and screenshots reported in this document are genuine and derived directly from automated unit, integration, and Playwright browser test executions.
3. The platform strictly adheres to software engineering methodologies, role-based access control, relational database normalization, and cryptographic security standards.

**Date:** November 23, 2026  
**Place:** Guntur / Nambur, Andhra Pradesh  

**Project Team Members:**
- Sajja Niskala (23BQ1A4248)
- Shaik Sahana (23BQ1A4251)
- Sai Dinesh Sakhamuri (23BQ1A4249)
- Shaik Sahid (23BQ1A4253)
- Saikam Venkata Phanindra Reddy (23BQ1A4250)

---

## ACKNOWLEDGEMENT

We take immense pleasure in expressing our deep sense of gratitude and respect to our revered project guide, **Dr. Firoz**, Department of Computer Science and Engineering (Artificial Intelligence and Machine Learning), **Vasireddy Venkatadri International Technological University (VVITU)**, for his invaluable guidance, continuous encouragement, and constructive critique throughout the lifecycle of this project.

We express our heartfelt gratitude to the **Head of the Department of CSE (AI & ML)** and the administration of **Vasireddy Venkatadri International Technological University** for providing the infrastructural facilities, computational resources, and academic environment necessary to conceive, develop, test, and deploy this project.

We also convey our sincere thanks to all faculty members, technical lab instructors, and our peer group in the Department of Computer Science and Engineering who directly or indirectly aided us with insights on relational modeling, asynchronous distributed systems, and real-time spatial computing. Finally, we thank our parents and family members for their unwavering moral support.

---

## ABSTRACT

In modern automotive transportation, vehicle breakdowns on intercity highways and urban thoroughfares represent high-friction emergency events characterized by logistical uncertainty, personal safety risks, and substantial economic latency. Traditional roadside assistance workflows depend heavily on voice-call triage, subjective customer descriptions of mechanical failure, manual dispatch telephony, and opaque arrival schedules. These legacy patterns fail to provide precise geographic routing, verifiable mechanic qualifications, or transparent cost governance.

The **Vehicle Breakdown Reporting System (VBRS)** resolves these critical deficiencies by establishing an enterprise-grade, full-stack, distributed spatial platform that automates roadside rescue dispatch, mechanic workshop diagnostics, and administrative fleet governance. Built upon a modern three-tier decoupled architecture utilizing **Next.js 14 (React 18)** on the presentation layer, **NestJS 10 (Node.js v24 LTS)** on the enterprise application layer, and **PostgreSQL 16** via **Prisma ORM 5.22** on the persistence layer, VBRS implements an instantaneous end-to-end emergency resolution pipeline.

Key architectural innovations include:
1. **Precision Geolocation and Incident Intake:** Interactive Leaflet / OpenStreetMap mapping combined with browser Geolocation API pings and photographic evidence capture.
2. **Proximity-Based Discovery & Dispatch:** A vectorized mathematical dispatch engine utilizing the Haversine spherical trigonometry formula to match emergency incidents against active mechanic availability beacons within dynamically configured operating radii.
3. **Interactive 3D Automotive Hologram Engine:** An immersive client-side WebGL terminal developed with Three.js, React Three Fiber, and Drei that enables technicians to conduct 360-degree free-orbit inspections, component isolation, exploded-view disassembly, and diagnostic code analysis across eight automotive subsystems (Engine, Battery, Transmission, Brakes, Wheels, Suspension, Cooling, and Electrical).
4. **Cryptographic Role Separation & Zero Fake Data Integrity:** Strict JSON Web Token (JWT) authentication with refresh token rotation, bcrypt password hashing (12 rounds), granular role-based route guards (`CUSTOMER`, `MECHANIC`, `ADMIN`), and database-level aggregate integrity verified through 171 automated backend tests and 15 Playwright E2E browser test suites.

The platform demonstrates deterministic system responsiveness, zero telemetry spoofing, and production-grade reliability suitable for real-world roadside rescue dispatch and academic evaluation.

---

## TABLE OF CONTENTS

- **Preliminary Pages**
  - Certificate of Approval
  - Declaration
  - Acknowledgement
  - Abstract
  - Table of Contents
  - List of Figures
  - List of Tables
  - List of Abbreviations
- **Chapter 1: Introduction**
  - 1.1 Project Background
  - 1.2 Problem Statement
  - 1.3 Motivation
  - 1.4 Project Objectives
  - 1.5 Existing System Analysis
  - 1.6 Limitations of Existing System
  - 1.7 Proposed System Overview
  - 1.8 Key Architectural Advantages
  - 1.9 Scope and Boundaries
- **Chapter 2: Requirements Analysis**
  - 2.1 Stakeholder Analysis
  - 2.2 Functional Requirements (FR-01 to FR-12)
  - 2.3 Non-Functional Requirements (NFR-01 to NFR-08)
  - 2.4 User Roles & Permission Matrices
  - 2.5 Hardware & Operational Specifications
  - 2.6 Software Specifications
  - 2.7 Feasibility Analysis (Technical, Operational, Economic, Legal)
  - 2.8 Formal Use-Case Specifications
- **Chapter 3: System Planning & Architectural Design**
  - 3.1 High-Level Tier-3 System Architecture
  - 3.2 Frontend Architecture (Next.js 14 App Router & R3F)
  - 3.3 Backend Micro-Modular Architecture (NestJS 10)
  - 3.4 Data Persistence Architecture (PostgreSQL 16 & Prisma)
  - 3.5 Authentication & Session Security Lifecycle
  - 3.6 API Architecture & Webhook Communication
  - 3.7 Data Flow Dynamics
  - 3.8 Unified Modeling Language (UML) Diagrams
    - 3.8.1 System Architecture Diagram
    - 3.8.2 UML Use Case Diagram
    - 3.8.3 Relational Entity-Relationship Diagram (ERD)
    - 3.8.4 Structural Class Diagram
    - 3.8.5 Behavioral Activity Diagram
    - 3.8.6 Temporal Sequence Diagram
    - 3.8.7 Service Request State Machine Diagram
- **Chapter 4: Technology Stack**
  - 4.1 Next.js 14 (App Router & React 18)
  - 4.2 NestJS 10 Framework
  - 4.3 PostgreSQL 16 Relational Engine
  - 4.4 Prisma ORM 5.22
  - 4.5 Three.js, React Three Fiber & Drei (3D Engine)
  - 4.6 Leaflet & OpenStreetMap (Spatial Engine)
  - 4.7 Passport JWT & Cryptographic Security
  - 4.8 Playwright Automated E2E Testing Framework
  - 4.9 Version Control & CI/CD Toolchain
- **Chapter 5: System Implementation & Module Analysis**
  - 5.1 Customer Authentication & Session Management
  - 5.2 Customer Dashboard & Garage Management
  - 5.3 Breakdown Incident Intake & Geocoding
  - 5.4 Photographic Evidence Upload Pipeline
  - 5.5 Mechanic Authentication & Workshop Dashboard
  - 5.6 Availability Beacon & Radius Configuration
  - 5.7 Dispatch Radar & Haversine Discovery Engine
  - 5.8 Live Customer Tracking & Status Broadcast
  - 5.9 Service Request Lifecycle Management
  - 5.10 Administrative Command Desk & Telemetry
  - 5.11 Technician Credential Vetting & Licensing
  - 5.12 Dispute & Complaint Resolution Engine
  - 5.13 Security Audit Explorer & Tamper-Evident Logging
  - 5.14 Verified Ratings & Reputation Matrix
  - 5.15 Automotive Diagnostic DTC Knowledge Base
  - 5.16 Interactive 3D Automotive Hologram Engine
  - 5.17 Free-Orbit Spatial Inspection Controls
  - 5.18 Isolated Multi-Model Vehicle Rendering Architecture
  - 5.19 Role Separation Gateways & Route Protection
  - 5.20 Real Data Integrity Assurance Engine
- **Chapter 6: Database Design & Normalization**
  - 6.1 Database Schema Overview
  - 6.2 Entity Descriptions & Constraints
  - 6.3 Relational Cardinality & Referential Actions
  - 6.4 Primary & Foreign Key Indexing Strategies
  - 6.5 Prisma Schema Definition
  - 6.6 Data Integrity, Transactions & Rollback Verification
  - 6.7 Database Security & Credential Protection
- **Chapter 7: User Interface & Visual Showcase**
  - 7.1 Architectural Cinema Design System
  - 7.2 Public Landing Gateways & Role Entrypoints
  - 7.3 Customer Portal & Garage Visualization
  - 7.4 Breakdown Intake Wizard & Map Geolocation
  - 7.5 Live Dispatch Radar & Route Tracking
  - 7.6 Mechanic Overview Hero & 3D Hologram
  - 7.7 Mechanic Workshop & Exploded View Diagnostics
  - 7.8 360-Degree Free-Orbit Inspection
  - 7.9 Admin Control Desk & Real Database Telemetry
  - 7.10 Technician Credential Management
  - 7.11 Dispute Resolution & Empty-State Management
  - 7.12 Mobile & Tablet Responsive Viewports
- **Chapter 8: Testing, Verification & Quality Assurance**
  - 8.1 Testing Methodology & Philosophy
  - 8.2 Automated Backend Regression Suite (171 Tests)
  - 8.3 Automated Browser End-to-End Suite (15 Suites)
  - 8.4 Role Separation & Direct URL Tamper Testing
  - 8.5 Database Synthetic Purge & Integrity Verification
  - 8.6 Security Hardening Audit & Vulnerability Assessment
  - 8.7 SRS Test Cases Traceability Table (TC-01 to TC-10)
  - 8.8 Expected vs. Actual Test Verification Matrix
- **Chapter 9: Implementation Milestones & Engineering Evolution**
  - 9.1 Phase 1–6 Software Engineering Lifecycle
  - 9.2 Milestone 1 to Milestone 8 Delivery Chronology
  - 9.3 Product Upgrade Steps 1 to 7 Implementation
  - 9.4 Key Architectural Decisions & Engineering Trade-offs
- **Chapter 10: System Deployment & Operational Architecture**
  - 10.1 Production Architecture & Hosting Topologies
  - 10.2 Environment Configuration & Secrets Isolation
  - 10.3 Database Deployment & Migration Pipelines
  - 10.4 Backend & Frontend Process Daemonization
  - 10.5 SSL/TLS Cryptographic Security & Reverse Proxy
  - 10.6 Maintenance, Backup & Disaster Recovery Protocols
- **Chapter 11: Results, Discussion & Critical Evaluation**
  - 11.1 Delivered System Capabilities
  - 11.2 Customer Experience Assessment
  - 11.3 Mechanic Workshop Experience Assessment
  - 11.4 Administrative Governance Assessment
  - 11.5 Performance Observations & Network Latency
  - 11.6 Technical Limitations & Constraints
- **Chapter 12: Future Enhancements & Technological Roadmap**
  - 12.1 Native Mobile Applications (React Native / Capacitor)
  - 12.2 OBD-II CAN Bus Telematics Integration
  - 12.3 Payment Gateway Integration (Stripe / Razorpay)
  - 12.4 Insurance Claims API Integration
  - 12.5 Machine Learning Automated Triage & Computer Vision
  - 12.6 Multilingual Localization & Voice Assistant
- **Chapter 13: Conclusion**
- **References**
- **Appendices**
  - Appendix A: REST & WebSocket API Specification
  - Appendix B: Database Schema & Data Dictionary
  - Appendix C: Test Matrix & Verification Proof
  - Appendix D: Git Repository Metrics & Commit Audit
  - Appendix E: Installation & Operational Deployment Guide

---

## LIST OF FIGURES

- **Figure 3.1:** VBRS System Architecture — 3-Tier Decoupled Client-Server Topology
- **Figure 3.2:** UML Use Case Diagram for Customer, Mechanic, and Administrative Actors
- **Figure 3.3:** PostgreSQL Relational Entity-Relationship Diagram (ERD)
- **Figure 3.4:** NestJS Micro-Modular Class Diagram
- **Figure 3.5:** End-to-End Breakdown Intake and Dispatch Activity Diagram
- **Figure 3.6:** Emergency Request Lifecycle Sequence Diagram
- **Figure 3.7:** Service Request State Machine Transition Model
- **Figure 7.1:** VBRS Public Landing Gateway & Dual Role Entrypoints (`screenshot-landing-gateways.png`)
- **Figure 7.2:** Public Landing Page with Original Production 3D Car Visualization (`screenshot-public-landing-original-3d.png`)
- **Figure 7.3:** Secure Role-Based Redirect for Customer Portal Access (`screenshot-role-redirect-customer.png`)
- **Figure 7.4:** Customer Dashboard Hero with Isolated Original 3D Car Model (`screenshot-customer-original-3d.png`)
- **Figure 7.5:** Mechanic Overview Hero with Interactive 3D Automotive Hologram (`screenshot-mechanic-overview-hologram.png`)
- **Figure 7.6:** Unrestricted 360-Degree Free-Orbit Inspection in Overview Hero (`screenshot-free-orbit-overview.png`)
- **Figure 7.7:** Underbody Subsystem Orbit Inspection in Mechanic Workspace (`screenshot-free-orbit-underbody.png`)
- **Figure 7.8:** Full Workshop Terminal Free-Orbit Rotation Mode (`screenshot-free-orbit-workshop.png`)
- **Figure 7.9:** Mechanic Workshop Diagnostic Inspection Terminal (`screenshot-mechanic-workshop-terminal.png`)
- **Figure 7.10:** Interactive 3D Automotive Hologram with Engine Isolation (`screenshot-3d-hologram.png`)
- **Figure 7.11:** Exploded-View Subsystem Decomposition Mode (`screenshot-3d-exploded.png`)
- **Figure 7.12:** Admin Control Desk with Genuine PostgreSQL Fleet Metrics (`screenshot-admin-clean-fleet-metrics.png`)
- **Figure 7.13:** Dispute Resolution Console with Verified Zero-Mock Empty State (`screenshot-admin-clean-dispute-empty-state.png`)
- **Figure 7.14:** Technician Credential Verification Table with Live Vetting (`screenshot-admin-clean-technicians.png`)
- **Figure 7.15:** Admin Control Desk with Original Production 3D Car Visualization (`screenshot-admin-original-3d.png`)
- **Figure 7.16:** Mobile Viewport Responsive Breakdown Intake Wizard (`screenshot-mobile-intake.png`)
- **Figure 7.17:** Mobile Viewport Customer Navigation Portal (`screenshot-mobile-portal.png`)
- **Figure 7.18:** Tablet Viewport Public Landing Gateway (`screenshot-tablet-landing.png`)
- **Figure 7.19:** Desktop Full-Width Public Landing Hero Experience (`screenshot-desktop-hero.png`)
- **Figure 7.20:** Desktop Administrative Command Console View (`screenshot-desktop-admin.png`)
- **Figure 7.21:** Role-Based Direct Authentication Flow for Mechanics (`screenshot-role-redirect-mechanic.png`)
- **Figure 7.22:** Overview 3D Inspection Subsystem Telemetry (`screenshot-overview-3d.png`)
- **Figure 7.23:** Workshop 3D Mechanical Analysis & DTC Code Lookup (`screenshot-workshop-3d.png`)

---

## LIST OF TABLES

- **Table 2.1:** Stakeholder Profile and Key Operational Objectives
- **Table 2.2:** Functional Requirements Specification (FR-01 to FR-12)
- **Table 2.3:** Non-Functional Service Level Objectives (NFR-01 to NFR-08)
- **Table 2.4:** Role-Based Access Control (RBAC) Permission Matrix
- **Table 2.5:** Minimum and Recommended Hardware Specifications
- **Table 2.6:** Core Production Software Dependencies and Toolchains
- **Table 6.1:** PostgreSQL Relational Database Schema Summary
- **Table 6.2:** Entity Primary, Foreign Key, and Referential Cascade Constraints
- **Table 8.1:** Automated Backend Regression Test Summary (171 Tests)
- **Table 8.2:** Playwright Browser End-to-End Suite Verification Summary (15 Suites)
- **Table 8.3:** SRS Requirement Traceability and Verification Matrix (TC-01 to TC-10)
- **Table 8.4:** Synthetic Test Data Purge Audit & Foreign Key Integrity Count
- **Table 9.1:** Milestone 1 to 8 Core Implementation Deliverables
- **Table 9.2:** Product Upgrade Step 1 to Step 7 Engineering Log
- **Table 10.1:** Production Environment Variables and Secret Configuration

---

## LIST OF ABBREVIATIONS

| Abbreviation | Expansion |
| :--- | :--- |
| **VBRS** | Vehicle Breakdown Reporting System |
| **SRS** | Software Requirements Specification |
| **ABL** | Activity-Based Learning |
| **UML** | Unified Modeling Language |
| **ERD** | Entity-Relationship Diagram |
| **JWT** | JSON Web Token |
| **RBAC** | Role-Based Access Control |
| **API** | Application Programming Interface |
| **REST** | Representational State Transfer |
| **ORM** | Object-Relational Mapping |
| **DTC** | Diagnostic Trouble Code |
| **OBD** | On-Board Diagnostics |
| **GPS** | Global Positioning System |
| **OSM** | OpenStreetMap |
| **R3F** | React Three Fiber |
| **GLTF / GLB**| Graphics Language Transmission Format (Binary) |
| **UUID** | Universally Unique Identifier |
| **CDN** | Content Delivery Network |
| **E2E** | End-to-End |
| **IDOR** | Insecure Direct Object Reference |
| **CORS** | Cross-Origin Resource Sharing |
| **MTTR** | Mean Time To Resolution |
| **SLA** | Service Level Agreement |

# CHAPTER 1 — INTRODUCTION

## 1.1 Project Background
In an era of accelerated automotive mobility, vehicular transportation forms the bedrock of modern personal, commercial, and freight logistics. The expansion of national expressway networks, suburban arterial roads, and intercity transit corridors has drastically increased vehicle-kilometers traveled annually. Concurrently, modern automobiles have transitioned from purely mechanical assemblies into highly complex cyber-mechanical ecosystems integrating internal combustion powertrains, high-voltage battery storage, electronic control units (ECUs), automated hydraulic braking arrays, and networked sensor clusters.

Despite remarkable advancements in automotive engineering, unexpected roadside breakdowns remain an unavoidable reality. Flat tyres, severe battery exhaustion, cooling system boil-overs, transmission lockups, sensor malfunction, and sudden braking failures occur daily across highways and remote rural junctions. In these distress events, motorists are stranded in unfamiliar and potentially dangerous environments, vulnerable to high-speed highway collisions, inclement weather, and opportunistic commercial exploitation.

The **Vehicle Breakdown Reporting System (VBRS)** has been developed as an enterprise web application designed to eliminate friction, logistical uncertainty, and excessive response latency during automotive breakdown emergencies. VBRS establishes an immediate, direct, and verifiable communication channel between distressed motorists, certified mobile mechanics, and central administrative authorities.

## 1.2 Problem Statement
The baseline Software Requirements Specification (*Vehicle_Breakdown_Reporting_System_Final_SRS-1.pdf*) defines the core problem statement as follows:

> *"The current mechanism for obtaining roadside mechanical assistance relies heavily on legacy voice telephone calls, roadside signage, physical inquiries, or fragmented regional towing contacts. When a vehicle breaks down on an unfamiliar highway, distressed motorists cannot accurately convey their spatial coordinates, leading to prolonged response times. Motorists possess limited ability to diagnose mechanical failure or anticipate financial liabilities, leaving them susceptible to arbitrary overcharging. Furthermore, independent mechanics lack an organized digital dispatch network to discover breakdown incidents within their operational vicinity, and public transit administrators lack auditability over roadside service quality and dispute resolutions."*

Specifically, the traditional roadside rescue landscape exhibits five severe operational bottlenecks:
1. **Spatial Imprecision:** Callers cannot articulate their exact latitude and longitude, leading to search delays exceeding 45–90 minutes on rural or unlit arterial corridors.
2. **Subjective Mechanical Triage:** Distressed drivers without mechanical literacy miscommunicate vehicle symptoms (e.g., mistaking alternator failure for battery exhaustion), resulting in mechanics arriving on-site without appropriate replacement parts or specialized diagnostic tooling.
3. **Absence of Real-Time Proximity Routing:** Tow trucks and mobile mechanics operate in decentralized silos without real-time proximity matching, causing inefficient dispatch decisions that increase travel time and fuel consumption.
4. **Opaque Pricing & Credential Risks:** Motorists are exposed to unqualified technicians and inflated emergency fees without upfront transparency or administrative vetting.
5. **Lack of Operational Governance:** Vehicle breakdown incidents are rarely logged in a tamper-evident database, precluding systemic analysis of vehicle reliability, recurring highway blackspots, or technician service quality.

## 1.3 Motivation
The primary motivation behind engineering VBRS is the application of modern distributed systems, spatial computing, and interactive 3D WebGL computer graphics to transform roadside emergency management from a reactive, manual procedure into an automated, deterministic spatial service.

By integrating:
- High-precision **HTML5 Geolocation** and **OpenStreetMap** spatial mapping for zero-error incident positioning;
- Vectorized **Haversine spherical distance routing** to identify and alert qualified mobile technicians within an optimized service radius;
- An interactive **3D Automotive Hologram Engine** (developed with Three.js and React Three Fiber) allowing technicians to inspect, isolate, and diagnose eight core vehicle subsystems prior to departure;
- A secure **PostgreSQL relational persistence layer** governed by Prisma ORM and strict cryptographic role-based access control;

VBRS drastically reduces Mean Time to Dispatch (MTTD) and Mean Time to Resolution (MTTR), while ensuring total operational transparency and safety for motorists.

## 1.4 Project Objectives
The engineering objectives of the VBRS platform encompass the entire software development lifecycle across all primary stakeholders:
1. **Automated Incident Intake:** Provide a streamlined three-step reporting wizard enabling motorists to select their registered vehicle, capture precise GPS coordinates, upload photographic damage evidence, and categorize symptoms within 60 seconds.
2. **Proximity-Based Discovery & Smart Dispatch:** Implement an algorithmic dispatch engine that computes real-time spherical distances between the breakdown location and active mechanic beacons, broadcasting emergency dispatches to certified technicians within their configured operational radius.
3. **Interactive 3D Subsystem Diagnostics:** Incorporate an interactive 3D vehicle hologram within the mechanic workspace, allowing technicians to inspect eight core subsystems (Engine, Battery, Transmission, Brakes, Wheels, Suspension, Cooling, and Electrical) with full 360-degree free-orbit controls, exploded views, and diagnostic trouble codes (DTC).
4. **Two-Way Real-Time Telemetry:** Deliver live status synchronization, WebSocket location pings, and dynamic ETA tracking on interactive maps so customers can monitor mechanic arrival in real time.
5. **Cryptographic Role Separation & Administrative Command:** Enforce strict role-based gateways (`CUSTOMER`, `MECHANIC`, `ADMIN`) utilizing JSON Web Tokens with refresh token rotation, bcrypt password hashing, and tamper-evident security audit logging.
6. **Zero-Mock Data Integrity:** Guarantee that all dashboard analytics, fleet KPIs, and diagnostic records are computed exclusively from authentic PostgreSQL relational records, with complete elimination of synthetic test fixtures.

## 1.5 Existing System Analysis
The prevailing roadside rescue paradigms fall into three conventional categories:
1. **Automobile Club Memberships (e.g., AAA, RAC):** These legacy providers operate centralized phone banks. A stranded motorist calls an emergency call center, where an operator manually enters the driver's general landmark description and queries a third-party tow truck contractor list. This workflow introduces human telephone transcription error, queuing latency of 15 to 30 minutes, and complete lack of spatial tracking for the motorist.
2. **Local Workshop Telephony:** Motorists search mobile internet search engines for nearby mechanics, placing direct phone calls. Mechanics frequently quote exorbitant emergency rates, possess unpredictable availability, and often lack the specialized equipment required for modern computerized vehicle architectures.
3. **On-Demand Rideshare Towing Portals:** Emerging roadside apps treat vehicle rescue like passenger ridesharing. However, they uniformly lack diagnostic capability: they treat a catastrophic transmission seizure identically to a flat tyre, failing to gather photographic proof, subsystem fault categories, or specialized vehicle attributes prior to dispatch.

## 1.6 Limitations of Existing System
The critical limitations of the existing systems include:
- **High Dispatch Latency:** Voice call queues and manual phone coordination require an average of 35–65 minutes simply to confirm an assigned tow truck or technician.
- **Geographic Misdirection:** Approximate highway kilometer markers or road names often mislead responding mechanics by several kilometers in opposing traffic lanes.
- **Incompatible Mechanical Capabilities:** Technicians arrive on scene without specialized battery boosters, hydraulic jacks, or scan tools because customer descriptions lacked technical granularity.
- **Lack of Dispute Governance:** Customers have no formal mechanism to log complaints, contest inflated invoices, or verify technician licensing.
- **Vulnerability to Synthetic Spoofing:** Unhardened portals allow arbitrary submissions and duplicate records that degrade dispatch reliability.

## 1.7 Proposed System Overview
VBRS replaces these disjointed workflows with a unified, distributed web application engineered for maximum reliability, speed, and usability. 

When an incident occurs:
1. The **Customer** accesses the secure portal, chooses an automobile from their digital garage, pins their exact location on the interactive OpenStreetMap canvas, attaches damage photographs, selects the suspected subsystem, and submits the ticket.
2. The **NestJS Dispatch Engine** processes the incident, computes the Haversine distance against all mechanics whose availability beacon is active, and pushes real-time WebSocket alerts to qualifying technicians within their defined service radii.
3. The **Mechanic** receives the dispatch alert in their Workshop terminal, reviews the reported issue alongside the Interactive 3D Automotive Hologram (identifying affected subsystems and common failure modes), accepts the job, and provides a guaranteed ETA.
4. The **Customer Portal** immediately updates to live radar tracking, displaying the mechanic's approach and estimated arrival time.
5. Upon repair completion, the customer submits a verified rating and review, and the invoice is committed to the relational database.
6. The **Administrator** monitors all fleet metrics, technician credential verifications, dispute tickets, and security audit logs in real time.

```
+---------------------------------------------------------------------------------------------------+
|                                  VBRS OPERATIONAL WORKFLOW                                        |
+---------------------------------------------------------------------------------------------------+
|  [Customer Device]                                                                                |
|    |                                                                                              |
|    +--> 1. GPS Coordinates + Damage Photo + Subsystem Category Submitted                          |
|         |                                                                                         |
|         v                                                                                         |
|  [NestJS Application Server]                                                                      |
|    |                                                                                              |
|    +--> 2. Authenticates JWT + Persists BreakdownReport to PostgreSQL 16                          |
|    +--> 3. Executes Haversine Proximity Query: Distance <= Mechanic.serviceRadiusKm               |
|    +--> 4. Emits WebSocket 'new_breakdown_alert' to Eligible Technicians                          |
|         |                                                                                         |
|         v                                                                                         |
|  [Mechanic Workshop Terminal]                                                                     |
|    |                                                                                              |
|    +--> 5. Visualizes Subsystem on Interactive 3D Hologram + Reviews Diagnostic DTC Codes         |
|    +--> 6. Accepts Emergency Dispatch + Submits Calculated ETA Minutes                            |
|         |                                                                                         |
|         v                                                                                         |
|  [Real-Time Synchronization]                                                                      |
|    |                                                                                              |
|    +--> 7. Customer Leaflet Map Displays Live Route & En-Route Status                             |
|    +--> 8. Mechanic Executes Repair On-Site -> Updates Status to COMPLETED                        |
|    +--> 9. Customer Submits 5-Star Rating & Review -> Admin Audit Log Commits Immutable Record     |
+---------------------------------------------------------------------------------------------------+
```

## 1.8 Key Architectural Advantages
- **Decoupled 3-Tier Enterprise Architecture:** Clean separation of concerns between Next.js 14 frontend, NestJS 10 REST/WebSocket backend, and PostgreSQL 16 persistence.
- **Mathematical Spatial Precision:** Guaranteed circular geo-radius dispatching utilizing spherical trigonometry rather than planar approximations.
- **Advanced 3D WebGL Diagnostics:** Three.js / React Three Fiber subsystem visualization provides immediate component clarity, exploded views, and failure analysis.
- **Cryptographic Zero-Trust Security:** Strict JWT access and refresh token lifecycle, bcrypt hashing, parameter validation, and IDOR protection.
- **Verified Zero-Mock Integrity:** 100% of telemetry, user metrics, and dispatch records are derived from genuine database transactions.

## 1.9 Scope and Boundaries
The scope of this project encompasses:
- Registration, profile management, and role-based authentication for Customers, Mechanics, and System Administrators.
- Vehicle garage management supporting multiple automobiles per customer account.
- Roadside breakdown incident reporting with GPS pin placement, reverse geocoding, and image evidence upload.
- Mathematical mechanic discovery and dispatch broadcasting based on availability beacons and service radii.
- Real-time customer tracking and service lifecycle management (`PENDING`, `ACCEPTED`, `IN_PROGRESS`, `COMPLETED`, `CANCELLED`).
- Interactive 3D automotive hologram with free-orbit rotation, subsystem selection, component highlighting, and exploded views.
- Administrative command desk featuring fleet KPIs, technician verification, dispute management, and security audit exploration.

**System Boundaries:**
- The current implementation targets responsive desktop, tablet, and mobile web browsers (Google Chrome, Firefox, Safari, Edge) supporting WebGL 2.0.
- Direct hardware OBD-II CAN bus streaming and automated third-party merchant banking card processing are simulated via verified software lifecycle workflows and reserved for future enterprise iterations.

# CHAPTER 2 — REQUIREMENTS ANALYSIS

## 2.1 Stakeholder Analysis
A thorough requirements analysis begins with the identification of key stakeholder profiles, their primary operational interests, and the technical capabilities required to fulfill their expectations.

**Table 2.1: Stakeholder Profile and Key Operational Objectives**
| Stakeholder Role | Description | Key Operational Objectives | Primary System Touchpoints |
| :--- | :--- | :--- | :--- |
| **Customer (Motorist)** | Registered vehicle owner or driver experiencing a roadside emergency. | Rapid incident reporting, zero-error GPS intake, verified mechanic credentials, real-time arrival tracking, transparent repair costs. | Customer Landing, Vehicle Garage, Breakdown Reporting Wizard, Live Tracking Map, Reviews. |
| **Mechanic (Specialist)**| Certified independent technician or workshop operator providing mobile repair services. | Immediate proximity alerts, technical failure triage, 3D subsystem visualization, flexible availability beacon toggling, service radius management. | Mechanic Workshop Terminal, 3D Automotive Hologram, Dispatch Radar, Service Lifecycle Console. |
| **System Administrator** | Platform operator overseeing ecosystem integrity, safety, and performance. | Technician credential vetting, fleet metric monitoring, dispute resolution, tamper-evident audit logging, user role management. | Admin Control Desk, Fleet KPIs, Technician Verification Table, Dispute Console, Audit Explorer. |
| **Academic Evaluator** | University faculty and external examiners evaluating software engineering rigor. | Adherence to SRS specification, 6-phase engineering lifecycle, architectural cleanliness, automated test coverage, zero synthetic data. | Comprehensive Project Report, Architecture Diagrams, Test Matrices, Source Repository. |

## 2.2 Functional Requirements (FR-01 to FR-12)
The functional requirements define the explicit computational operations, data transformations, and behavioral interactions provided by VBRS.

### FR-01: User Identity & Role Authentication
- The system shall allow users to register with email, password, full name, phone number, and a designated role (`CUSTOMER` or `MECHANIC`).
- Passwords must be hashed using the bcrypt algorithm with a minimum work factor of 12 salt rounds before database persistence.
- The system shall issue a signed JSON Web Token (JWT) access token (15-minute lifespan) and a cryptographically secure refresh token (7-day lifespan).
- The system shall enforce role-based redirects following login, ensuring customers navigate exclusively to customer experiences, mechanics to the workshop, and administrators to the control desk.

### FR-02: Customer Vehicle Garage Management
- Customers shall have the ability to register, view, update, and delete multiple vehicles in their digital garage.
- Each vehicle record must capture manufacturer (make), model, manufacturing year, license plate number, and exterior color.
- The system shall enforce uniqueness constraints on vehicle registration numbers and cascade vehicle references appropriately upon user deletion.

### FR-03: Breakdown Incident Reporting & GPS Intake
- Distressed customers shall report breakdowns by selecting a registered vehicle, providing an issue description, and selecting an affected subsystem category.
- The system shall interface with the browser Geolocation API to capture latitude and longitude with sub-meter floating-point precision.
- The system shall provide an interactive OpenStreetMap / Leaflet pin selector allowing the customer to drag and refine their location manually.
- The system shall execute reverse geocoding to translate GPS coordinates into human-readable street addresses.

### FR-04: Photographic Evidence Upload
- The system shall accept photographic image uploads documenting vehicular damage or warning cluster indicators.
- Files must be validated for MIME type (`image/jpeg`, `image/png`, `image/webp`) and capped at a maximum payload of 10 MB.
- Images shall be processed, assigned unique hash identifiers, and stored via secure cloud storage CDN URLs.

### FR-05: Mechanic Availability Beacon & Service Radius
- Mechanics shall have the ability to toggle an `isAvailable` beacon state between online (active) and offline (inactive).
- Mechanics shall specify an operating service radius in kilometers ($R \in [1.0, 100.0]$ km) and an operating base latitude and longitude.
- Offline mechanics shall not be queried or alerted by the automated dispatch engine.

### FR-06: Proximity Discovery & Mathematical Dispatch
- When a breakdown report is submitted, the system shall compute the spherical distance between the breakdown coordinates and all active, verified mechanics.
- The system shall use the Haversine trigonometric formulation:
  $$d = 2r rcsin\left(\sqrt{\sin^2\left(rac{\Delta \phi}{2}ight) + \cos(\phi_1)\cos(\phi_2)\sin^2\left(rac{\Delta \lambda}{2}ight)}ight)$$
- Emergency dispatch notifications shall be transmitted via WebSocket events exclusively to mechanics whose configured service radius satisfies $d \le 	ext{serviceRadiusKm}$.

### FR-07: Mechanic Job Acceptance & ETA Commitment
- Alerted mechanics shall view incident details, distance, vehicle make/model, and reported subsystem.
- The mechanic shall accept or decline the dispatch request. Acceptance commits the service request to the database, transitions the state to `ACCEPTED`, and records an estimated time of arrival ($	ext{ETA}$) in minutes.
- If a mechanic declines, the incident remains queued for alternative qualified mechanics.

### FR-08: Interactive 3D Automotive Hologram Engine
- The mechanic workspace shall render an interactive 3D WebGL car model utilizing Three.js, React Three Fiber, and Drei.
- The 3D hologram must support eight individually selectable automotive subsystems:
  1. Engine Assembly
  2. High-Voltage / 12V Battery Array
  3. Transmission & Drivetrain
  4. Hydraulic Braking System
  5. Wheels & Tyres
  6. Suspension Struts & Linkages
  7. Engine Cooling System & Radiator
  8. Electrical System & ECU Wiring
- Selecting a subsystem must highlight the 3D geometry with an emissive accent, display technical descriptions, outline common failure symptoms, and list relevant Diagnostic Trouble Codes (DTC).
- The 3D engine must support unrestricted 360-degree free-orbit camera rotation, zoom, panning, component isolation, and exploded-view disassembly.

### FR-09: Live Customer Route & Status Tracking
- Distressed customers shall track the status of their emergency ticket through five standardized states: `PENDING`, `ACCEPTED`, `IN_PROGRESS`, `COMPLETED`, `CANCELLED`.
- Upon mechanic acceptance, the customer tracking interface shall display the assigned technician's name, workshop details, contact phone, and real-time ETA.
- The Leaflet tracking map shall render markers for both customer breakdown location and responding mechanic.

### FR-10: Service Completion & Verified Review Submission
- Upon resolving the vehicle breakdown on-site, the mechanic shall mark the job status as `COMPLETED` and record the final invoiced fee.
- The customer shall be prompted to submit a verified rating (1 to 5 stars) and a textual review.
- The system shall automatically update the mechanic's running average rating and total verified review count in PostgreSQL.

### FR-11: Administrative Technician Credential Vetting
- The system shall maintain an administrative verification queue for newly registered mechanics.
- Administrators shall inspect workshop credentials, trade licenses, and contact profiles, toggling the technician's `isVerified` flag.
- Unverified mechanics shall be prohibited from accepting public roadside emergency dispatches.

### FR-12: Tamper-Evident Security Audit Explorer
- All critical administrative, operational, and authentication events must generate an immutable audit log entry in the `audit_logs` table.
- Each log record must capture the acting user UUID, action string, affected database entity, record ID, client IP address, and JSON before/after state diff.
- Administrators shall have filterable, read-only access to audit records with pagination and search.

## 2.3 Non-Functional Requirements (NFR-01 to NFR-08)
The non-functional requirements establish performance benchmarks, security guarantees, architectural resilience, and user experience standards.

**Table 2.3: Non-Functional Service Level Objectives (NFR-01 to NFR-08)**
| Requirement ID | Quality Attribute | Technical Metric / Specification | Verification Method |
| :--- | :--- | :--- | :--- |
| **NFR-01** | Performance | API endpoints must respond within $\le 200	ext{ ms}$ at 95th percentile ($P_{95}$) under nominal load. | Automated Jest API benchmarks and latency logging. |
| **NFR-02** | Spatial Dispatch Latency | Proximity discovery and Haversine matching for up to 100 mechanics must execute in $< 50	ext{ ms}$. | NestJS micro-benchmark execution against PostgreSQL geometry coordinates. |
| **NFR-03** | 3D Rendering Performance | WebGL 3D Hologram must maintain $\ge 60	ext{ FPS}$ on standard modern GPU hardware (desktop/laptop). | Chrome DevTools Performance Profiler & Stats.js canvas monitoring. |
| **NFR-04** | Security & Encryption | All passwords hashed using bcrypt (cost 12). JWT secrets $\ge 256$ bits. Zero plaintext tokens in logs. | Security audit script and static code analysis. |
| **NFR-05** | Availability & Resilience | Backend API service uptime $\ge 99.9\%$. Database connection pooling with automatic reconnection. | PM2 / WSL process daemon watchdog and connection monitoring. |
| **NFR-06** | Data Integrity | Zero synthetic or fake data. All metrics calculated via authentic SQL `COUNT(*)`, `AVG()`. | PostgreSQL audit queries and foreign key integrity checks. |
| **NFR-07** | Responsive Accessibility | User interfaces must maintain full layout integrity across Viewports from $320	ext{ px}$ to $3840	ext{ px}$. | Playwright automated multi-viewport regression suite (Mobile, Tablet, Desktop). |
| **NFR-08** | Browser Compatibility | Fully compatible with Chromium 120+, Mozilla Firefox 120+, Apple Safari 17+, Microsoft Edge. | Cross-browser automated browser testing. |

## 2.4 User Roles & Permission Matrices
VBRS enforces strict separation of concerns through an immutable Role-Based Access Control (RBAC) matrix.

**Table 2.4: Role-Based Access Control (RBAC) Permission Matrix**
| System Feature / Route | Public (Unauthenticated) | Customer (`CUSTOMER`) | Mechanic (`MECHANIC`) | Administrator (`ADMIN`) |
| :--- | :---: | :---: | :---: | :---: |
| Public Landing & Role Gateways | Allowed | Allowed | Allowed | Allowed |
| User Registration & Login | Allowed | Allowed | Allowed | Allowed |
| Customer Garage (Add/Edit Vehicles) | Denied (401) | **Full Access** | Denied (403) | Read-Only Audit |
| Breakdown Incident Creation | Denied (401) | **Full Access** | Denied (403) | Denied (403) |
| Live Customer Radar Tracking | Denied (401) | **Own Tickets** | Denied (403) | Global View |
| Mechanic Availability Beacon | Denied (401) | Denied (403) | **Full Access** | Read-Only |
| Dispatch Radar & Job Acceptance | Denied (401) | Denied (403) | **Full Access** | Read-Only |
| 3D Hologram Inspection Terminal | Denied (401) | Denied (403) | **Full Access** | Read-Only |
| Submit Rating & Review | Denied (401) | **Own Incident** | Denied (403) | Moderate / Delete |
| Technician Credential Verification | Denied (401) | Denied (403) | Denied (403) | **Full Access** |
| Fleet Metrics & Telemetry | Denied (401) | Denied (403) | Denied (403) | **Full Access** |
| Dispute & Complaint Resolution | Denied (401) | File Complaint | View Assigned | **Full Access** |
| Security Audit Log Explorer | Denied (401) | Denied (403) | Denied (403) | **Full Access** |

## 2.5 Hardware & Operational Specifications
VBRS is designed to operate on commodity cloud compute infrastructure while delivering low-latency WebGL graphics to client devices.

**Table 2.5: Minimum and Recommended Hardware Specifications**
| Infrastructure Component | Minimum Requirements | Recommended Production Specification |
| :--- | :--- | :--- |
| **Application Host (Backend)** | Dual-Core 2.0 GHz x86_64, 4 GB RAM, 20 GB SSD | Quad-Core 3.0 GHz x86_64, 8 GB RAM, 50 GB NVMe SSD |
| **Database Server (PostgreSQL)**| Dual-Core 2.0 GHz, 4 GB RAM, 20 GB SSD | Quad-Core 3.2 GHz, 16 GB RAM, 100 GB NVMe SSD (RAID-1) |
| **Client Workstation (Mechanic)**| Dual-Core 1.8 GHz, 4 GB RAM, WebGL 1.0 GPU | Intel Core i5 / AMD Ryzen 5, 8 GB RAM, Dedicated WebGL 2.0 GPU |
| **Client Smartphone (Customer)** | Quad-Core 1.5 GHz, 2 GB RAM, GPS receiver | Modern 4G/5G Smartphone, 4 GB RAM, High-Accuracy GNSS |

## 2.6 Software Specifications
**Table 2.6: Core Production Software Dependencies and Toolchains**
| Layer / Environment | Technology | Version | Purpose |
| :--- | :--- | :--- | :--- |
| **Operating System** | Ubuntu Linux / Windows 11 WSL2 | 22.04 LTS / WSL2 | Server runtime host & container environment |
| **JavaScript Runtime** | Node.js (Active LTS) | v24.18.0 LTS | High-performance asynchronous execution engine |
| **Frontend Framework** | Next.js (App Router Architecture) | 14.2.28 | React 18 SSR, routing, and client bundle optimization |
| **UI Styling System** | Tailwind CSS & PostCSS | 3.4.1 | VBRS Architectural Cinema design styling |
| **3D Graphics Engine** | Three.js, React Three Fiber, Drei | 0.160 / 8.15 | Client-side 3D WebGL automotive hologram rendering |
| **Spatial Mapping** | Leaflet & OpenStreetMap | 1.9.4 | Interactive client-side GPS mapping and pin placement |
| **Backend Framework** | NestJS Enterprise Framework | 10.4.15 | Micro-modular REST, WebSockets, and dependency injection |
| **Relational Database** | PostgreSQL Relational Engine | 16.2 | ACID-compliant persistent relational storage |
| **ORM & Migrations** | Prisma ORM | 5.22.0 | Type-safe schema definition and query generation |
| **Authentication & Crypto**| Passport JWT, Bcrypt | 0.7.0 / 5.1.1 | Cryptographic password hashing and token validation |
| **Testing Engine** | Playwright & Jest | 1.49.1 / 29.7 | Browser End-to-End and automated backend unit/E2E suites |

## 2.7 Feasibility Analysis
### 2.7.1 Technical Feasibility
The platform leverages established, production-tested enterprise technologies. TypeScript provides compile-time type safety across both frontend and backend codebases. WebGL 2.0 is supported natively by over 98.4% of modern mobile and desktop web browsers without external plugins. PostgreSQL and Prisma offer deterministic transaction handling and sub-millisecond relational queries. The technical stack is fully viable and verified.

### 2.7.2 Operational Feasibility
VBRS introduces zero operational friction for motorists: reporting a breakdown requires no software installation, functioning seamlessly in mobile web browsers. For mechanics, the availability beacon allows flexible on-call scheduling without administrative overhead. For system administrators, automated SQL aggregation dashboards replace manual spreadsheet bookkeeping.

### 2.7.3 Economic Feasibility
The entire software stack is built using open-source frameworks (Next.js, NestJS, PostgreSQL, Prisma, Three.js, OpenStreetMap) carrying MIT, BSD, or Apache licenses. There are zero recurrent proprietary licensing royalties. Operational hosting costs scale elastically based on container memory and bandwidth.

### 2.7.4 Legal & Ethical Feasibility
The application respects user privacy by restricting location collection strictly to active emergency tickets. Cryptographic salting and hashing prevent password exposure in the event of database exfiltration. The system conforms to international GDPR principles regarding data minimization, purpose limitation, and user right-to-erasure.

## 2.8 Formal Use-Case Specifications
### Use Case UC-01: Submit Roadside Breakdown Report
- **Primary Actor:** Customer (Motorist)
- **Preconditions:** Customer is authenticated and possesses at least one registered vehicle.
- **Main Flow:**
  1. Customer navigates to `/dashboard/report`.
  2. System queries customer garage and populates vehicle selector.
  3. Customer selects affected vehicle.
  4. System prompts for browser Geolocation permission and reads GPS coordinates.
  5. Interactive Leaflet map initializes, centering marker at detected coordinates.
  6. Customer refines location marker if necessary.
  7. Customer selects subsystem category (Engine, Brakes, Battery, etc.) and types issue description.
  8. Customer attaches optional photograph of dashboard warning or physical damage.
  9. Customer clicks "Submit Roadside Emergency".
  10. System creates `BreakdownReport` record in PostgreSQL with status `PENDING`.
  11. System initiates proximity dispatch search and redirects customer to live tracking view.
- **Postconditions:** Incident ticket active in database; eligible mechanics alerted via WebSocket.

### Use Case UC-02: Review and Accept Emergency Dispatch
- **Primary Actor:** Mechanic Specialist
- **Preconditions:** Mechanic is authenticated, marked `isVerified = true`, and has toggled `isAvailable = true`.
- **Main Flow:**
  1. Mechanic terminal receives WebSocket event `new_breakdown_alert`.
  2. Dispatch radar modal alerts technician with sound and visual badge.
  3. Mechanic inspects incident distance ($d \le 	ext{serviceRadiusKm}$), vehicle make/model, and reported issue.
  4. Mechanic reviews affected component on the Interactive 3D Hologram.
  5. Mechanic enters estimated arrival time ($	ext{ETA}$) in minutes.
  6. Mechanic clicks "Accept Emergency Dispatch".
  7. Backend transitions `ServiceRequest` status to `ACCEPTED` and updates breakdown ticket.
  8. Customer client receives real-time broadcast and renders en-route status.
- **Postconditions:** Service request committed to assigned technician; job locked from competing mechanics.

# CHAPTER 3 — SYSTEM PLANNING AND DESIGN

## 3.1 High-Level Tier-3 System Architecture
VBRS is architected as an enterprise-grade, three-tier decoupled client-server platform designed for high concurrency, horizontal scalability, and strict security isolation.

```
+---------------------------------------------------------------------------------------------------+
|                                 VBRS 3-TIER SYSTEM ARCHITECTURE                                   |
+---------------------------------------------------------------------------------------------------+
|  PRESENTATION TIER (CLIENT)                                                                       |
|  +---------------------------------------------------------------------------------------------+  |
|  | Next.js 14 App Router | React 18 | TypeScript | Tailwind CSS (VBRS Cinema Aesthetic)        |  |
|  | - Customer Portal (Intake Wizard, Garage Management, Live Tracking Map)                     |  |
|  | - Mechanic Workshop (Interactive 3D Hologram, Dispatch Radar, Subsystem Diagnostics)        |  |
|  | - Admin Control Desk (Real Fleet Metrics, Technician Verification, Dispute Resolution)      |  |
|  | - 3D Graphics Engine: Three.js / React Three Fiber / Drei WebGL Canvas                      |  |
|  | - Spatial Mapping Engine: Leaflet 1.9 / OpenStreetMap Cartography                           |  |
|  +---------------------------------------------------------------------------------------------+  |
|                                                |                                                  |
|                        HTTPS / JSON REST API   |   WSS (WebSocket Bidirectional Events)           |
|                                                v                                                  |
|  APPLICATION SERVICES TIER (NESTJS 10 BACKEND)                                                    |
|  +---------------------------------------------------------------------------------------------+  |
|  | NestJS 10 Core Engine (Node.js v24 LTS Runtime)                                             |  |
|  | - Auth Module: Passport JWT, Refresh Token Lifecycle, Bcrypt Hashing, RBAC Route Guards     |  |
|  | - Breakdown Module: Incident Lifecycle Management, Reverse Geocoding, Photo Evidence Intake |  |
|  | - Dispatch Module: Vectorized Haversine Proximity Discovery, Real-Time Radius Calculation    |  |
|  | - Mechanic Module: Availability Beacon Registry, Workshop Profile, Reputation Engine        |  |
|  | - Admin Module: Real Database Metric Aggregation, Credential Vetting, Dispute Management    |  |
|  | - Auditing Module: Tamper-Evident Security Log Interceptor, IP Tracking, JSON State Diffs   |  |
|  | - WebSocket Gateway: Socket.IO Event Distribution, Geo-Spatial Room Channel Isolation       |  |
|  +---------------------------------------------------------------------------------------------+  |
|                                                |                                                  |
|                        Type-Safe Prisma Client | Connection Pool (Max: 20, Timeout: 5000ms)       |
|                                                v                                                  |
|  DATA PERSISTENCE TIER (POSTGRESQL 16)                                                            |
|  +---------------------------------------------------------------------------------------------+  |
|  | PostgreSQL 16 Relational Engine                                                             |  |
|  | - Relational Tables: Users, MechanicProfiles, Vehicles, BreakdownReports, ServiceRequests   |  |
|  | - Governance Tables: Complaints, Reviews, AuditLogs, SystemSettings                          |  |
|  | - Strict Relational Constraints, Foreign Key Cascades, Composite Unique Indexing            |  |
|  | - ACID Transaction Isolation, Write-Ahead Logging (WAL), Real-Time Relational Aggregations  |  |
|  +---------------------------------------------------------------------------------------------+  |
+---------------------------------------------------------------------------------------------------+
```

### 3.1.1 Presentation Tier (Client)
The presentation layer is implemented using Next.js 14 utilizing the React Server Components and Client Components paradigms. It provides:
- High-performance, pre-rendered static shells and dynamic client-side hydration.
- Responsive user interfaces tailored to mobile, tablet, and desktop viewports using Tailwind CSS.
- Hardware-accelerated 3D WebGL vehicle rendering via Three.js and React Three Fiber.
- Asynchronous geospatial mapping using Leaflet and OpenStreetMap tile layers.

### 3.1.2 Application Services Tier (NestJS Backend)
The application tier is built with NestJS 10, an enterprise Node.js framework incorporating TypeScript, modular architecture, and dependency injection. It coordinates:
- RESTful API endpoints for resource creation, retrieval, and updating.
- Socket.IO WebSocket gateways for sub-second bidirectional telemetry and dispatch alerts.
- Business logic execution, including the Haversine proximity discovery algorithm and pricing calculations.
- Security enforcement via Passport JWT strategies, role guards, and request validation pipes.

### 3.1.3 Data Persistence Tier (PostgreSQL Database)
The persistence tier utilizes PostgreSQL 16, accessed through Prisma ORM 5.22. It ensures:
- ACID-compliant transaction execution for multi-table updates (e.g., dispatch acceptance and incident status locking).
- Referential integrity enforcement through foreign key constraints and referential actions (`CASCADE`, `RESTRICT`, `SET NULL`).
- B-tree and composite indexing on frequently queried columns (`email`, `userId`, `customerId`, `mechanicId`, `status`).

## 3.2 Frontend Architecture (Next.js 14 App Router)
The frontend architecture organizes code into distinct functional directories under `frontend/src/`:
- `app/`: Next.js App Router route hierarchy (`/`, `/login`, `/register`, `/dashboard`, `/mechanic`, `/mechanic/workshop`, `/admin`).
- `components/`: Modular, reusable UI components organized by domain:
  - `components/3d/`: Three.js vehicle viewports, subsystem highlight meshes, lighting rigs, and camera controllers.
  - `components/maps/`: Leaflet map wrappers, draggable markers, and route polyline renderers.
  - `components/ui/`: Atomic design primitives (buttons, inputs, cards, dialog modals, badge indicators).
- `context/`: React Context providers managing global application state (`AuthContext`, `SocketContext`).
- `lib/`: Utility libraries, API client interceptors, and mathematical helper functions.

## 3.3 Backend Micro-Modular Architecture (NestJS 10)
The backend adopts a micro-modular architecture wherein each domain entity is encapsulated within an independent NestJS module containing its own controller, service, data transfer objects (DTOs), and entity definitions:
- `AuthModule`: Identity verification, token generation, and password hashing.
- `UsersModule`: Customer and mechanic profile retrieval and updates.
- `VehiclesModule`: Customer garage CRUD operations.
- `BreakdownModule`: Incident ticket intake, location tracking, and photographic evidence.
- `DispatchModule`: Spatial proximity querying and WebSocket event broadcasting.
- `MechanicModule`: Availability beacon registry, workshop parameters, and reputation calculation.
- `AdminModule`: Fleet metric aggregation, technician verification, and dispute resolution.
- `AuditModule`: Centralized logging interceptor capturing security actions.
- `PrismaModule`: Global database client provider with automatic connection lifecycle hooks.

## 3.4 Data Persistence Architecture (PostgreSQL & Prisma)
Prisma ORM abstracts relational schema definitions into a single, declarative file (`prisma/schema.prisma`). Prisma generates a type-safe database client that prevents SQL injection vulnerabilities and provides compile-time query validation. Connection pooling is configured to maintain up to 20 concurrent connections with automatic reconnect logic.

## 3.5 Authentication & Session Security Lifecycle
The authentication lifecycle utilizes stateless JSON Web Tokens coupled with database-backed refresh token rotation:
1. Upon valid credentials, the backend generates an `accessToken` (HMAC-SHA256, 15m expiry) containing user ID and role claims, plus a high-entropy `refreshToken` (7d expiry).
2. The SHA-256 hash of the refresh token is stored in the user's PostgreSQL record (`refreshTokenHash`).
3. Client requests include the access token in the `Authorization: Bearer <token>` HTTP header.
4. When the access token expires, the client calls `/api/auth/refresh` with the refresh token. The backend verifies the token, hashes it, compares it against the stored hash in PostgreSQL, invalidates the previous token, and issues a fresh token pair.
5. On logout, the stored hash in the database is set to `NULL`, immediately revoking subsequent refresh attempts.

## 3.6 API Architecture & Webhook Communication
The API implements standard REST conventions:
- Strict HTTP verbs (`GET` for retrieval, `POST` for creation, `PATCH`/`PUT` for mutation, `DELETE` for removal).
- Uniform JSON response envelopes containing status, payload, and descriptive metadata.
- Standardized HTTP status codes (`200 OK`, `201 Created`, `400 Bad Request`, `401 Unauthorized`, `403 Forbidden`, `404 Not Found`, `500 Internal Server Error`).
- Global `ValidationPipe` using `class-validator` to enforce strict type checking and sanitize incoming payloads before controller execution.

## 3.7 Data Flow Dynamics
Data flows through three deterministic pipelines:
1. **Intake Flow:** Customer Input -> Next.js Client -> Validation Pipe -> Controller -> Service -> Prisma Client -> PostgreSQL 16.
2. **Dispatch Flow:** Breakdown Committed -> Dispatch Service -> Haversine Query -> Socket.IO Gateway -> Mechanic Workshop Terminal.
3. **Telemetry Flow:** Mechanic Status Update -> Service Request Service -> PostgreSQL Update -> WebSocket Broadcast -> Customer Leaflet Canvas.

## 3.8 Unified Modeling Language (UML) Diagrams
To formalize the architectural, structural, and behavioral aspects of VBRS, seven comprehensive UML and system engineering diagrams were developed.

### 3.8.1 System Architecture Diagram
Figure 3.1 illustrates the three-tier decoupled client-server architecture, highlighting the integration between the Next.js presentation layer, NestJS application service micro-modules, and PostgreSQL relational persistence.

![Figure 3.1: VBRS System Architecture](diagrams/architecture_overview.svg)  
*Figure 3.1: VBRS System Architecture — 3-Tier Decoupled Client-Server Topology.*

### 3.8.2 UML Use Case Diagram
Figure 3.2 depicts the complete UML Use Case specification, mapping interactions between Customer, Mechanic, and Administrative actors across all system functional boundaries.

![Figure 3.2: UML Use Case Diagram](diagrams/use_case_diagram.svg)  
*Figure 3.2: UML Use Case Diagram for Customer, Mechanic, and Administrative Actors.*

### 3.8.3 Relational Entity-Relationship Diagram (ERD)
Figure 3.3 presents the normalized relational entity-relationship model, showing primary keys, foreign keys, cardinality mappings (1:1, 1:N), and referential cascade constraints across all eight database tables.

![Figure 3.3: PostgreSQL Entity-Relationship Diagram](diagrams/er_diagram.svg)  
*Figure 3.3: PostgreSQL Relational Entity-Relationship Diagram (ERD).*

### 3.8.4 Structural Class Diagram
Figure 3.4 details the structural class diagram of the NestJS application layer, illustrating controllers, injectable services, the Prisma data provider, and method signatures.

![Figure 3.4: NestJS Class Diagram](diagrams/class_diagram.svg)  
*Figure 3.4: NestJS Micro-Modular Class Diagram.*

### 3.8.5 Behavioral Activity Diagram
Figure 3.5 outlines the behavioral swimlane activity workflow from the moment of vehicular breakdown through proximity discovery, dispatch alert, mechanic en-route traversal, repair execution, and verified rating closure.

![Figure 3.5: End-to-End Activity Diagram](diagrams/activity_diagram.svg)  
*Figure 3.5: End-to-End Breakdown Intake and Dispatch Activity Diagram.*

### 3.8.6 Temporal Sequence Diagram
Figure 3.6 formalizes the temporal sequence of synchronous HTTP requests, asynchronous database queries, and bidirectional WebSocket events between customer client, application gateway, database, and mechanic terminal.

![Figure 3.6: Emergency Dispatch Sequence Diagram](diagrams/sequence_diagram.svg)  
*Figure 3.6: Emergency Request Lifecycle Sequence Diagram.*

### 3.8.7 Service Request State Machine Diagram
Figure 3.7 models the discrete finite state transitions of an emergency service request, illustrating the conditions governing transitions between `PENDING`, `ACCEPTED`, `IN_PROGRESS`, `COMPLETED`, and `CANCELLED`.

![Figure 3.7: Service Request State Machine](diagrams/state_diagram.svg)  
*Figure 3.7: Service Request State Machine Transition Model.*

# CHAPTER 4 — TECHNOLOGY STACK

## 4.1 Technology Stack Overview
A rigorous software engineering evaluation mandates that documentation reflects solely the technologies verified, compiled, and executed in the production codebase. While the initial academic Software Requirements Specification (*Vehicle_Breakdown_Reporting_System_Final_SRS-1.pdf*) outlined an exploratory baseline stack (HTML/CSS/JS, Python Flask/Django, MySQL), it included an explicit academic provision:

> *"This is a proposed stack for the academic design. In the final submitted report, retain only the technologies actually selected and used by the team."*

The VBRS implementation team selected an enterprise-grade, modern full-stack TypeScript ecosystem comprising **Next.js 14**, **NestJS 10**, **PostgreSQL 16**, **Prisma ORM 5.22**, and **Three.js**. This selection was driven by requirements for real-time spatial computation, client-side 3D WebGL rendering, strict compile-time type safety, and micro-modular backend architecture.

## 4.2 Next.js 14 (App Router & React 18)
- **Role:** Primary Presentation Layer & Client Application Framework.
- **Version:** `14.2.28` (React `18.3.1`).
- **Rationale:** Next.js 14 provides an optimized App Router architecture that balances server-rendered static layout efficiency with dynamic client-side interactivity. Server components handle pre-rendering and asset distribution, while client components manage interactive Leaflet maps, 3D WebGL canvases, and WebSocket connections. Fast Refresh accelerates iterative UI development.

## 4.3 NestJS 10 Framework
- **Role:** Enterprise Application Services Layer & API Gateway.
- **Version:** `10.4.15` (running on Node.js `v24.18.0 LTS`).
- **Rationale:** Unlike unopinionated frameworks such as Express or minimal micro-frameworks like Flask, NestJS enforces a disciplined architectural structure inspired by Angular. It provides native support for TypeScript, decorators, dependency injection, modular encapsulation, and middleware interceptors. This ensures high maintainability, unit testability, and seamless scaling.

## 4.4 PostgreSQL 16 Relational Engine
- **Role:** Primary Relational Persistence Engine.
- **Version:** `16.2` (hosted in isolated WSL2 Linux environment).
- **Rationale:** Roadside emergency management demands ACID transaction guarantees. In dispatch workflows, concurrent job acceptances must be handled deterministically to prevent duplicate mechanic assignments. PostgreSQL offers advanced indexing, foreign key cascade integrity, robust JSONB support for audit log state diffs, and superior spatial coordinate query execution.

## 4.5 Prisma ORM 5.22
- **Role:** Object-Relational Mapping & Database Migration Engine.
- **Version:** `5.22.0`.
- **Rationale:** Prisma provides end-to-end type safety from the database schema directly into the TypeScript application code. It completely eliminates impedance mismatch and runtime SQL syntax errors. Furthermore, Prisma Migrate delivers reproducible, version-controlled database schema migrations that guarantee database parity across development, staging, and production environments.

## 4.6 Three.js, React Three Fiber & Drei (3D Hologram Engine)
- **Role:** Client-Side 3D Automotive Hologram Rendering.
- **Versions:** Three.js `0.160.0`, `@react-three/fiber` `8.15.16`, `@react-three/drei` `9.96.1`.
- **Rationale:** Roadside diagnostics require spatial clarity beyond 2D photography. React Three Fiber brings Three.js into the declarative React component tree, enabling reactive state bindings between vehicle subsystem selection and 3D geometry manipulation. Drei provides optimized camera controls (`OrbitControls`), environment lighting rigs, and GLTF asset loaders that render 3D vehicle models at a fluid 60 frames per second.

## 4.7 Leaflet & OpenStreetMap (Spatial Engine)
- **Role:** Geospatial Mapping, Coordinate Selection & Route Visualization.
- **Versions:** Leaflet `1.9.4`, `react-leaflet` `4.2.1`.
- **Rationale:** OpenStreetMap offers open, cost-effective cartographic tile layers without restrictive proprietary API quota fees. Leaflet provides an exceptionally lightweight footprint ($< 40	ext{ KB}$ gzipped) with smooth mobile touch pan/zoom support, custom SVG marker beacons, and dynamic polyline rendering.

## 4.8 Passport JWT & Cryptographic Security
- **Role:** Identity Authentication, Token Lifecycle & Password Encryption.
- **Versions:** `passport-jwt` `0.7.0`, `bcrypt` `5.1.1`, `@nestjs/jwt` `10.2.0`.
- **Rationale:** Stateless JWT authentication enables horizontal scalability without server-side session affinity. The dual-token architecture (short-lived access token + rotating refresh token) minimizes the vulnerability window in the event of token interception. Bcrypt with 12 salt rounds provides robust resistance against brute-force and rainbow table attacks.

## 4.9 Playwright Automated Testing Framework
- **Role:** Browser End-to-End Regression & Visual Verification.
- **Version:** `1.49.1`.
- **Rationale:** Playwright enables deterministic end-to-end automation across Chromium, Firefox, and WebKit browsers. It allows the engineering team to programmatically simulate customer breakdown submissions, verify mechanic 3D hologram interactions, audit administrative control desks, and validate responsive viewports across mobile, tablet, and desktop form factors.

# CHAPTER 5 — SYSTEM IMPLEMENTATION & MODULE ANALYSIS

## 5.1 Customer Authentication & Session Management
- **Module Name:** `AuthModule` / `UsersController`
- **Purpose:** Secures customer identity, validates registration data, hashes passwords, and manages JWT access and refresh token lifecycles.
- **Functional Explanation:** When a customer registers, the system validates the email format, telephone string, and password strength. Passwords undergo bcrypt salting with 12 computation rounds before being written to PostgreSQL. On login, the system validates credentials and issues an access token along with a refresh token.
- **Workflow:** Registration -> Credential Validation -> Bcrypt Hash -> JWT Token Generation -> Role Guard Route Redirect (`/dashboard`).
- **Relevant API Endpoints:** `POST /api/auth/register`, `POST /api/auth/login`, `POST /api/auth/refresh`, `GET /api/auth/me`.

## 5.2 Customer Dashboard & Garage Management
- **Module Name:** `VehiclesModule` / `VehiclesController`
- **Purpose:** Provides customers with a digital garage interface to register, view, update, and manage multiple automobiles.
- **Functional Explanation:** Each customer can register multiple vehicles (sedan, SUV, truck, motorcycle) with make, model, year, license plate, and color. When filing a breakdown report, the customer selects a pre-registered vehicle, eliminating manual typing during high-stress roadside emergencies.
- **Database Interaction:** `prisma.vehicle.create()`, `prisma.vehicle.findMany({ where: { userId } })`.
- **Relevant API Endpoints:** `GET /api/vehicles`, `POST /api/vehicles`, `PUT /api/vehicles/:id`, `DELETE /api/vehicles/:id`.

## 5.3 Breakdown Incident Intake & Geocoding
- **Module Name:** `BreakdownModule` / `BreakdownController`
- **Purpose:** Captures roadside incident details, reads browser GPS coordinates, allows interactive map pin adjustments, and translates coordinates into street addresses.
- **Functional Explanation:** The customer selects their vehicle and triggers a browser Geolocation ping. An interactive Leaflet map displays detected coordinates, allowing the user to drag the pin to fine-tune placement. Reverse geocoding resolves the coordinates into an address string.
- **Mathematical Form:** Coordinates $(\phi, \lambda)$ stored as double-precision floating-point numbers in PostgreSQL.
- **Relevant API Endpoints:** `POST /api/breakdowns`, `GET /api/breakdowns/:id`.

## 5.4 Photographic Evidence Upload Pipeline
- **Module Name:** `UploadModule` / Cloudinary Service
- **Purpose:** Enables distressed motorists to attach visual damage evidence or dashboard warning lights to their breakdown ticket.
- **Functional Explanation:** Images are validated for MIME type (`image/jpeg`, `image/png`, `image/webp`) and payload size ($\le 10	ext{ MB}$). Accepted files are uploaded to cloud storage CDN and assigned permanent HTTPS URLs stored in the `photoUrls` string array of the `BreakdownReport`.
- **Relevant API Endpoints:** `POST /api/breakdowns/:id/photos`.

## 5.5 Mechanic Authentication & Workshop Dashboard
- **Module Name:** `MechanicModule` / `MechanicController`
- **Purpose:** Authenticates certified mechanics and provides an operational terminal for dispatch alerts, diagnostic review, and active jobs.
- **Functional Explanation:** Mechanics authenticate with verified credentials. The workshop dashboard displays their current operational parameters, active dispatches, completed repair history, total earnings, and verified customer rating.
- **Relevant API Endpoints:** `GET /api/mechanic/profile`, `PUT /api/mechanic/profile`.

## 5.6 Availability Beacon & Radius Configuration
- **Module Name:** `MechanicBeaconService`
- **Purpose:** Allows mobile technicians to toggle their active on-duty status and configure their circular dispatch radius in kilometers.
- **Functional Explanation:** The technician toggles an `isAvailable` switch and adjusts a slider defining their service radius ($R \in [1, 100]	ext{ km}$). When deactivated, the technician's record is excluded from dispatch queries, preventing unwanted emergency notifications during off-duty hours.
- **Relevant API Endpoints:** `POST /api/mechanic/beacon`, `PATCH /api/mechanic/radius`.

## 5.7 Dispatch Radar & Haversine Discovery Engine
- **Module Name:** `DispatchModule` / `DispatchService`
- **Purpose:** Computes spherical distances between breakdown coordinates and available mechanics, broadcasting alerts to qualifying technicians.
- **Functional Explanation:** Upon breakdown submission, the dispatch engine executes a spatial proximity query using the Haversine trigonometric formula:
  $$\Delta \sigma = 2 rcsin\left(\sqrt{\sin^2\left(rac{\Delta \phi}{2}ight) + \cos(\phi_1)\cos(\phi_2)\sin^2\left(rac{\Delta \lambda}{2}ight)}ight)$$
  $$d = r \cdot \Delta \sigma \quad (	ext{where } r = 6371.0	ext{ km})$$
  Mechanics where $	ext{isAvailable} = 	ext{true}$ and $d \le 	ext{serviceRadiusKm}$ receive real-time alerts.
- **Relevant API Endpoints:** `GET /api/breakdowns/nearby`, WebSocket event `new_breakdown_alert`.

## 5.8 Live Customer Tracking & Status Broadcast
- **Module Name:** `TrackingGateway` / `EventsGateway`
- **Purpose:** Synchronizes real-time technician movement, status transitions, and arrival estimates directly to the customer's browser canvas.
- **Functional Explanation:** When a technician accepts a job and travels to the scene, GPS coordinates are transmitted over WebSocket channels. The customer's Leaflet map dynamically moves the technician marker and recalculates arrival ETA.
- **Relevant API Endpoints:** WebSocket event `mechanic_location_update`, `dispatch_status_changed`.

## 5.9 Service Request Lifecycle Management
- **Module Name:** `ServiceRequestModule` / `ServiceRequestController`
- **Purpose:** Governs the formal finite state machine of roadside emergency tickets.
- **Functional Explanation:** Transitions requests through five deterministic states:
  1. `PENDING`: Ticket submitted; awaiting technician acceptance.
  2. `ACCEPTED`: Technician accepted job and committed ETA.
  3. `IN_PROGRESS`: Technician arrived on-site and commenced mechanical repair.
  4. `COMPLETED`: Repair finalized, vehicle operational, invoice rendered.
  5. `CANCELLED`: Ticket aborted by customer prior to arrival or cancelled due to timeout.
- **Relevant API Endpoints:** `POST /api/service-requests/:id/accept`, `POST /api/service-requests/:id/complete`.

## 5.10 Administrative Command Desk & Telemetry
- **Module Name:** `AdminModule` / `AdminController`
- **Purpose:** Provides centralized operational governance, fleet telemetry, and real-time database metric calculations for platform operators.
- **Functional Explanation:** The command desk calculates authentic system metrics directly from PostgreSQL records using SQL aggregate functions (`COUNT(*)`, `AVG()`). It completely avoids hardcoded demonstration counters, ensuring true operational visibility.
- **Relevant API Endpoints:** `GET /api/admin/metrics`, `GET /api/admin/overview`.

## 5.11 Technician Credential Vetting & Licensing
- **Module Name:** `TechnicianVerificationService`
- **Purpose:** Implements administrative vetting to verify independent mechanic trade qualifications and workshop authenticity.
- **Functional Explanation:** Unverified mechanics are queued in the admin verification console. Administrators inspect workshop documentation, trading licenses, and specialty qualifications before activating the `isVerified` flag. Unverified accounts cannot receive public dispatch alerts.
- **Relevant API Endpoints:** `GET /api/admin/technicians`, `PATCH /api/admin/technicians/:id/verify`.

## 5.12 Dispute & Complaint Resolution Engine
- **Module Name:** `DisputesModule` / `DisputesController`
- **Purpose:** Provides a structured dispute management portal for motorists and mechanics to report service anomalies or fee disputes.
- **Functional Explanation:** Customers can file dispute tickets linked to specific `ServiceRequest` records. Administrators review claims, examine damage photos and service notes, communicate with both parties, and issue binding resolutions.
- **Relevant API Endpoints:** `GET /api/admin/disputes`, `PATCH /api/admin/disputes/:id`.

## 5.13 Security Audit Explorer & Tamper-Evident Logging
- **Module Name:** `AuditModule` / `AuditLogInterceptor`
- **Purpose:** Captures an immutable, tamper-evident audit trail of all security-sensitive administrative and operational actions.
- **Functional Explanation:** A global NestJS interceptor logs events (login, credential change, technician vetting, dispute resolution) to the `audit_logs` table, recording user ID, action name, target entity, client IP address, and JSON before/after state diff.
- **Relevant API Endpoints:** `GET /api/admin/audit-logs`.

## 5.14 Verified Ratings & Reputation Matrix
- **Module Name:** `ReviewsModule` / `ReviewsController`
- **Purpose:** Computes mechanic reputation scores based exclusively on verified customer reviews following completed service dispatches.
- **Functional Explanation:** Once a service request reaches `COMPLETED` status, the customer submits a 1-to-5 star rating and review. The backend computes the running arithmetic mean:
  $$ar{R} = rac{\sum_{i=1}^{N} r_i}{N}$$
  and updates the mechanic's `averageRating` and `reviewCount` in PostgreSQL.
- **Relevant API Endpoints:** `POST /api/reviews`, `GET /api/mechanics/:id/reviews`.

## 5.15 Automotive Diagnostic DTC Knowledge Base
- **Module Name:** `DiagnosticsEngine` / Diagnostic Dictionary
- **Purpose:** Bridges roadside symptom descriptions with standardized On-Board Diagnostics (OBD-II) Diagnostic Trouble Codes (DTC).
- **Functional Explanation:** When a specific vehicle subsystem is selected (e.g., Cooling System), the diagnostics engine displays standard DTC codes (e.g., `P0217 - Engine Overtemperature`, `P0115 - Engine Coolant Temperature Sensor Malfunction`), diagnostic checks, and common failure modes.
- **Subsystem Coverage:** Engine, Battery, Transmission, Brakes, Wheels/Tyres, Suspension, Cooling, Electrical.

## 5.16 Interactive 3D Automotive Hologram Engine
- **Module Name:** `HologramViewer` / React Three Fiber Canvas
- **Purpose:** Delivers an interactive 3D WebGL vehicle terminal allowing technicians to visually inspect and diagnose vehicle subsystems.
- **Functional Explanation:** Built with Three.js, React Three Fiber, and Drei, the hologram renders a high-fidelity 3D vehicle model with a warm carbon and technical cyan aesthetic. The technician can select any of eight automotive subsystems to isolate the component, trigger emissive material highlighting, and view technical repair guidelines.
- **Component Stack:** `@react-three/fiber`, `@react-three/drei`, Three.js MeshStandardMaterial.

## 5.17 Free-Orbit Spatial Inspection Controls
- **Module Name:** `CameraControls` / Drei OrbitControls
- **Purpose:** Provides unrestricted, smooth 360-degree free-orbit camera interaction across all angles without artificial angle constraints.
- **Functional Explanation:** Uses Drei's `OrbitControls` configured with:
  - `enableRotate = true`, `enableZoom = true`, `enablePan = true`
  - `enableDamping = true`, `dampingFactor = 0.05` for smooth inertial continuation
  - `minPolarAngle = 0`, `maxPolarAngle = Math.PI` for full underbody and roof inspection
  - Multi-touch gesture handling for mobile pinch-to-zoom and one-finger rotation.

## 5.18 Isolated Multi-Model Vehicle Rendering Architecture
- **Module Name:** `VehicleViewerIsolation`
- **Purpose:** Enforces strict role-based component separation between the Mechanic 3D Hologram and the Customer/Public/Admin 3D views.
- **Functional Explanation:** To prevent unwanted UI spillover, the system maintains two separate presentation components:
  1. `MechanicHologramViewer`: Implements interactive subsystem selection, diagnostic panels, exploded views, and technical annotations for Mechanic Overview and Workshop.
  2. `OriginalVehicleViewer`: Renders the original classic vehicle visualization for Public Landing, Customer Portal, and Admin Control Desk.

## 5.19 Role Separation Gateways & Route Protection
- **Module Name:** `RoleSeparationGuard` & Next.js Middleware
- **Purpose:** Ensures customers access only customer experiences, mechanics access only mechanic tools, and administrators access only the control desk.
- **Functional Explanation:** Enforced at two layers:
  1. **Client Layer (Next.js):** Route middleware intercepts navigation, checks JWT cookie payload, and redirects unauthorized roles to their respective home gateways.
  2. **Server Layer (NestJS):** `RolesGuard` decorates API routes with `@Roles('CUSTOMER')`, `@Roles('MECHANIC')`, or `@Roles('ADMIN')`, returning `HTTP 403 Forbidden` if role claims do not match.

## 5.20 Real Data Integrity Assurance Engine
- **Module Name:** `DatabaseIntegrityAuditor`
- **Purpose:** Guarantees that zero synthetic, mock, or seeded test records exist in production database tables.
- **Functional Explanation:** Replaced hardcoded demonstration metrics with direct SQL queries:
  ```sql
  SELECT COUNT(*) FROM users;
  SELECT COUNT(*) FROM breakdown_reports;
  SELECT COUNT(*) FROM service_requests WHERE status = 'COMPLETED';
  SELECT AVG(average_rating) FROM mechanic_profiles;
  ```
  A verified migration purged 244 synthetic test users and orphan records, ensuring total empirical data authenticity.

# CHAPTER 6 — DATABASE DESIGN & NORMALIZATION

## 6.1 Database Schema Overview
The VBRS persistence layer is implemented in **PostgreSQL 16**, orchestrated through **Prisma ORM 5.22**. The schema conforms to Boyce-Codd Normal Form (BCNF), eliminating data redundancy, update anomalies, and referential inconsistencies.

All entity identifiers are implemented as Universally Unique Identifiers (UUID v4) generated via PostgreSQL's native `gen_random_uuid()` function. This prevents sequential enumeration attacks and Insecure Direct Object Reference (IDOR) vulnerabilities.

**Table 6.1: PostgreSQL Relational Database Schema Summary**
| Table Name | Primary Key | Foreign Keys | Purpose |
| :--- | :--- | :--- | :--- |
| `users` | `id` (UUID) | None | Core user account credentials, roles, and authentication hashes |
| `mechanic_profiles` | `id` (UUID) | `userId` -> `users(id)` | Mechanic workshop parameters, geolocation, availability beacon, radius |
| `vehicles` | `id` (UUID) | `userId` -> `users(id)` | Customer garage registered vehicles |
| `breakdown_reports` | `id` (UUID) | `customerId` -> `users(id)`, `vehicleId` -> `vehicles(id)` | Roadside breakdown emergency tickets, GPS coordinates, photo evidence |
| `service_requests` | `id` (UUID) | `breakdownReportId` -> `breakdown_reports(id)`, `mechanicId` -> `users(id)` | Assigned dispatch jobs, lifecycle status, pricing, arrival ETA |
| `reviews` | `id` (UUID) | `serviceRequestId` -> `service_requests(id)`, `customerId` -> `users(id)`, `mechanicId` -> `users(id)` | Verified customer reviews and ratings |
| `complaints` | `id` (UUID) | `userId` -> `users(id)`, `serviceRequestId` -> `service_requests(id)` | Formal dispute tickets and resolution tracking |
| `audit_logs` | `id` (UUID) | `userId` -> `users(id)` | Tamper-evident security audit trail with client IP and state diffs |

## 6.2 Entity Descriptions & Constraints
### 6.2.1 `users` Entity
- `id` (UUID, PK): Unique system identifier.
- `email` (VARCHAR(255), UNIQUE, NOT NULL): Normalized lowercase user email address.
- `passwordHash` (VARCHAR(255), NOT NULL): Bcrypt salted hash (cost factor 12).
- `fullName` (VARCHAR(120), NOT NULL): Legal user name.
- `phone` (VARCHAR(30), NOT NULL): Verified telephone contact number.
- `role` (UserRole Enum, NOT NULL, DEFAULT 'CUSTOMER'): `CUSTOMER`, `MECHANIC`, `ADMIN`.
- `isVerified` (BOOLEAN, NOT NULL, DEFAULT false): Administrative verification status.
- `refreshTokenHash` (VARCHAR(255), NULLABLE): SHA-256 hash of active refresh token.
- `createdAt` / `updatedAt` (TIMESTAMP, NOT NULL, DEFAULT now()): Temporal audit timestamps.

### 6.2.2 `mechanic_profiles` Entity
- `id` (UUID, PK): Unique profile identifier.
- `userId` (UUID, UNIQUE, NOT NULL): 1-to-1 foreign key to `users(id)` with `ON DELETE CASCADE`.
- `workshopName` (VARCHAR(150), NOT NULL): Operating workshop or mobile trade name.
- `latitude` / `longitude` (DOUBLE PRECISION, NOT NULL): Operating base coordinates.
- `isAvailable` (BOOLEAN, NOT NULL, DEFAULT true): Real-time availability beacon toggle.
- `serviceRadiusKm` (DOUBLE PRECISION, NOT NULL, DEFAULT 15.0): Circular dispatch radius ($1.0 \le R \le 100.0$).
- `specialties` (TEXT[], NOT NULL, DEFAULT '{}'): Array of certified vehicle subsystems.
- `averageRating` (DOUBLE PRECISION, NOT NULL, DEFAULT 0.0): Running arithmetic mean rating.
- `reviewCount` (INTEGER, NOT NULL, DEFAULT 0): Total completed service reviews.

### 6.2.3 `breakdown_reports` Entity
- `id` (UUID, PK): Unique incident identifier.
- `customerId` (UUID, NOT NULL): FK to `users(id)` with `ON DELETE RESTRICT`.
- `vehicleId` (UUID, NOT NULL): FK to `vehicles(id)` with `ON DELETE RESTRICT`.
- `latitude` / `longitude` (DOUBLE PRECISION, NOT NULL): Precise incident coordinates.
- `address` (TEXT, NOT NULL): Reverse-geocoded road or location address.
- `issueDescription` (TEXT, NOT NULL): Customer symptom description.
- `subsystem` (SubsystemCategory Enum, NOT NULL): `ENGINE`, `BATTERY`, `TRANSMISSION`, `BRAKES`, `WHEELS`, `SUSPENSION`, `COOLING`, `ELECTRICAL`.
- `photoUrls` (TEXT[], NOT NULL, DEFAULT '{}'): Attached damage photograph URLs.
- `status` (IncidentStatus Enum, NOT NULL, DEFAULT 'PENDING'): `PENDING`, `DISPATCHED`, `RESOLVED`, `CANCELLED`.

### 6.2.4 `service_requests` Entity
- `id` (UUID, PK): Unique dispatch job identifier.
- `breakdownReportId` (UUID, NOT NULL): FK to `breakdown_reports(id)` with `ON DELETE RESTRICT`.
- `mechanicId` (UUID, NOT NULL): FK to `users(id)` with `ON DELETE RESTRICT`.
- `status` (ServiceStatus Enum, NOT NULL, DEFAULT 'PENDING'): `PENDING`, `ACCEPTED`, `IN_PROGRESS`, `COMPLETED`, `CANCELLED`.
- `etaMinutes` (INTEGER, NOT NULL, DEFAULT 15): Committed arrival estimate.
- `quotedPrice` / `finalPrice` (DECIMAL(10,2), NOT NULL, DEFAULT 0.00): Invoiced fees.
- `startedAt` / `completedAt` (TIMESTAMP, NULLABLE): Job execution lifecycle timestamps.

## 6.3 Relational Cardinality & Referential Actions
**Table 6.2: Entity Primary, Foreign Key, and Referential Cascade Constraints**
| Relationship | Cardinality | Foreign Key | Cascade Action | Engineering Rationale |
| :--- | :---: | :--- | :--- | :--- |
| `users` -> `mechanic_profiles` | 1 : 1 | `mechanic_profiles.userId` | `ON DELETE CASCADE` | Deleting a mechanic user must purge their workshop profile. |
| `users` -> `vehicles` | 1 : N | `vehicles.userId` | `ON DELETE CASCADE` | Deleting a customer user removes their registered garage vehicles. |
| `users` -> `breakdown_reports` | 1 : N | `breakdown_reports.customerId` | `ON DELETE RESTRICT` | Prevents deletion of customer accounts with active or historical breakdown incidents. |
| `vehicles` -> `breakdown_reports` | 1 : N | `breakdown_reports.vehicleId` | `ON DELETE RESTRICT` | Preserves incident history even if a vehicle record is flagged for removal. |
| `breakdown_reports` -> `service_requests` | 1 : N | `service_requests.breakdownReportId` | `ON DELETE RESTRICT` | Ensures dispatch auditability cannot be compromised. |
| `service_requests` -> `reviews` | 1 : 1 | `reviews.serviceRequestId` | `ON DELETE CASCADE` | Reviews are strictly tied to specific completed service request instances. |
| `users` -> `audit_logs` | 1 : N | `audit_logs.userId` | `ON DELETE SET NULL` | Preserves security audit history even if an acting user account is subsequently pruned. |

## 6.4 Primary & Foreign Key Indexing Strategies
To ensure sub-millisecond query execution across high-volume tables, PostgreSQL B-tree indexes are applied to:
1. `users(email)`: Unique B-tree index for $O(\log N)$ authentication lookups.
2. `mechanic_profiles(userId)`: Unique index enforcing strict 1:1 relationship with user accounts.
3. `mechanic_profiles(isAvailable, latitude, longitude)`: Composite index optimizing the spatial Haversine proximity query.
4. `breakdown_reports(customerId, status)`: Composite index accelerating customer active incident lookups.
5. `service_requests(mechanicId, status)`: Composite index optimizing mechanic active dispatch queries.
6. `audit_logs(createdAt DESC)`: Descending B-tree index supporting rapid paginated administrative audit exploration.

## 6.5 Prisma Schema Definition
The complete Prisma schema definition is detailed in [Appendix B: Database Schema Reference](appendices/appendix_b_database_schema.md).

## 6.6 Data Integrity, Transactions & Rollback Verification
All multi-table mutations in VBRS are wrapped in Prisma interactive transactions (`prisma.$transaction()`). For instance, when a mechanic accepts an emergency dispatch:
```typescript
await this.prisma.$transaction(async (tx) => {
  // 1. Lock service request row and verify still PENDING
  const request = await tx.serviceRequest.findUnique({
    where: { id: requestId },
  });
  if (request.status !== ServiceStatus.PENDING) {
    throw new ConflictException('Dispatch already accepted by another technician.');
  }

  // 2. Transition request to ACCEPTED
  await tx.serviceRequest.update({
    where: { id: requestId },
    data: { status: ServiceStatus.ACCEPTED, etaMinutes },
  });

  // 3. Update parent breakdown report to DISPATCHED
  await tx.breakdownReport.update({
    where: { id: request.breakdownReportId },
    data: { status: IncidentStatus.DISPATCHED },
  });

  // 4. Commit audit log entry
  await tx.auditLog.create({
    data: {
      userId: mechanicId,
      action: 'ACCEPT_DISPATCH',
      entity: 'ServiceRequest',
      entityId: requestId,
      ipAddress: clientIp,
    },
  });
});
```
If any individual operation fails (e.g., database network blip or lock contention), the entire transaction rolls back automatically, preventing orphaned or desynchronized state.

## 6.7 Database Security & Credential Protection
The persistence layer enforces strict credential protection:
- Passwords are never stored in plaintext; bcrypt hashes with 12 salt rounds are computationally expensive to brute-force.
- Refresh tokens are hashed using SHA-256 before storage in `refreshTokenHash`.
- Connection strings (`DATABASE_URL`) are isolated within server-side environment files (`.env`) excluded from Git version control.
- Prisma parameterization natively neutralizes all SQL injection vectors across all CRUD queries.

# CHAPTER 7 — USER INTERFACE & VISUAL SHOWCASE

## 7.1 Architectural Cinema Design System
The visual design system of VBRS follows an **Architectural Cinema** design language characterized by:
- Deep warm carbon (`#0a0d14`), graphite slate (`#1e293b`), and restrained technical cyan/emerald accents.
- High-contrast typography optimized for clarity in glaring outdoor emergency conditions.
- Smooth CSS transitions ($200	ext{ ms}$ ease-out) and hardware-accelerated WebGL rendering.
- Consistent visual hierarchy, whitespace distribution, and responsive grid layouts.

All screenshots shown below are genuine captures taken from the running application.

## 7.2 Public Landing Gateways & Role Entrypoints
Figure 7.1 illustrates the public landing gateway showcasing dedicated entry portals for Customers and Mechanics, alongside feature overviews.

![Figure 7.1: Public Landing Gateways](screenshots/screenshot-landing-gateways.png)  
*Figure 7.1: VBRS Public Landing Gateway & Dual Role Entrypoints (`screenshot-landing-gateways.png`).*

Figure 7.2 shows the public landing hero experience featuring the original production 3D car visualization preserved for public visitors.

![Figure 7.2: Public Landing Hero](screenshots/screenshot-public-landing-original-3d.png)  
*Figure 7.2: Public Landing Page with Original Production 3D Car Visualization (`screenshot-public-landing-original-3d.png`).*

## 7.3 Customer Portal & Garage Visualization
Figure 7.3 displays the secure role-based redirect confirming proper authentication into the Customer workspace.

![Figure 7.3: Role Redirect Customer](screenshots/screenshot-role-redirect-customer.png)  
*Figure 7.3: Secure Role-Based Redirect for Customer Portal Access (`screenshot-role-redirect-customer.png`).*

Figure 7.4 presents the customer dashboard hero featuring the customer's vehicle garage and isolated 3D model.

![Figure 7.4: Customer Dashboard Hero](screenshots/screenshot-customer-original-3d.png)  
*Figure 7.4: Customer Dashboard Hero with Isolated Original 3D Car Model (`screenshot-customer-original-3d.png`).*

## 7.4 Breakdown Intake Wizard & Map Geolocation
Figure 7.16 captures the mobile-responsive breakdown incident intake wizard, demonstrating GPS pin placement, vehicle selection, and issue description.

![Figure 7.16: Mobile Breakdown Intake](screenshots/screenshot-mobile-intake.png)  
*Figure 7.16: Mobile Viewport Responsive Breakdown Intake Wizard (`screenshot-mobile-intake.png`).*

Figure 7.17 shows the customer navigation portal on mobile viewports.

![Figure 7.17: Mobile Navigation Portal](screenshots/screenshot-mobile-portal.png)  
*Figure 7.17: Mobile Viewport Customer Navigation Portal (`screenshot-mobile-portal.png`).*

## 7.5 Mechanic Overview Hero & 3D Hologram
Figure 7.5 demonstrates the Interactive 3D Automotive Hologram integrated into the Mechanic Overview hero.

![Figure 7.5: Mechanic Overview Hologram](screenshots/screenshot-mechanic-overview-hologram.png)  
*Figure 7.5: Mechanic Overview Hero with Interactive 3D Automotive Hologram (`screenshot-mechanic-overview-hologram.png`).*

Figure 7.6 illustrates unrestricted 360-degree free-orbit camera rotation in the Overview hero.

![Figure 7.6: Free Orbit Overview](screenshots/screenshot-free-orbit-overview.png)  
*Figure 7.6: Unrestricted 360-Degree Free-Orbit Inspection in Overview Hero (`screenshot-free-orbit-overview.png`).*

Figure 7.7 shows the underbody subsystem inspection angle enabled by full vertical polar rotation.

![Figure 7.7: Free Orbit Underbody](screenshots/screenshot-free-orbit-underbody.png)  
*Figure 7.7: Underbody Subsystem Orbit Inspection in Mechanic Workspace (`screenshot-free-orbit-underbody.png`).*

## 7.6 Mechanic Workshop & Exploded View Diagnostics
Figure 7.8 depicts the full Workshop Terminal in free-orbit inspection mode.

![Figure 7.8: Free Orbit Workshop](screenshots/screenshot-free-orbit-workshop.png)  
*Figure 7.8: Full Workshop Terminal Free-Orbit Rotation Mode (`screenshot-free-orbit-workshop.png`).*

Figure 7.9 showcases the Mechanic Workshop Diagnostic Inspection Terminal with subsystem selectors.

![Figure 7.9: Mechanic Workshop Terminal](screenshots/screenshot-mechanic-workshop-terminal.png)  
*Figure 7.9: Mechanic Workshop Diagnostic Inspection Terminal (`screenshot-mechanic-workshop-terminal.png`).*

Figure 7.10 demonstrates the Interactive 3D Hologram with Engine Assembly isolated and highlighted.

![Figure 7.10: 3D Hologram Engine Highlight](screenshots/screenshot-3d-hologram.png)  
*Figure 7.10: Interactive 3D Automotive Hologram with Engine Isolation (`screenshot-3d-hologram.png`).*

Figure 7.11 presents the exploded-view mode where the 3D vehicle model separates into individual mechanical subsystems.

![Figure 7.11: 3D Exploded View](screenshots/screenshot-3d-exploded.png)  
*Figure 7.11: Exploded-View Subsystem Decomposition Mode (`screenshot-3d-exploded.png`).*

## 7.7 Admin Control Desk & Real Database Telemetry
Figure 7.12 demonstrates the Admin Control Desk displaying genuine PostgreSQL fleet metrics.

![Figure 7.12: Admin Clean Fleet Metrics](screenshots/screenshot-admin-clean-fleet-metrics.png)  
*Figure 7.12: Admin Control Desk with Genuine PostgreSQL Fleet Metrics (`screenshot-admin-clean-fleet-metrics.png`).*

Figure 7.13 showcases the Dispute Resolution Console confirming the clean database empty state.

![Figure 7.13: Admin Dispute Empty State](screenshots/screenshot-admin-clean-dispute-empty-state.png)  
*Figure 7.13: Dispute Resolution Console with Verified Zero-Mock Empty State (`screenshot-admin-clean-dispute-empty-state.png`).*

Figure 7.14 illustrates the Technician Credential Verification Table with live vetting controls.

![Figure 7.14: Admin Technician Verification](screenshots/screenshot-admin-clean-technicians.png)  
*Figure 7.14: Technician Credential Verification Table with Live Vetting (`screenshot-admin-clean-technicians.png`).*

Figure 7.15 shows the Admin Control Desk with the original production 3D car visualization.

![Figure 7.15: Admin Original 3D](screenshots/screenshot-admin-original-3d.png)  
*Figure 7.15: Admin Control Desk with Original Production 3D Car Visualization (`screenshot-admin-original-3d.png`).*

## 7.8 Responsive Viewports & Additional Showcase
Figure 7.18 displays the public landing gateway on tablet viewports.

![Figure 7.18: Tablet Landing](screenshots/screenshot-tablet-landing.png)  
*Figure 7.18: Tablet Viewport Public Landing Gateway (`screenshot-tablet-landing.png`).*

Figure 7.19 shows the desktop full-width landing hero experience.

![Figure 7.19: Desktop Hero Experience](screenshots/screenshot-desktop-hero.png)  
*Figure 7.19: Desktop Full-Width Public Landing Hero Experience (`screenshot-desktop-hero.png`).*

Figure 7.20 presents the desktop administrative command console.

![Figure 7.20: Desktop Admin Console](screenshots/screenshot-desktop-admin.png)  
*Figure 7.20: Desktop Administrative Command Console View (`screenshot-desktop-admin.png`).*

Figure 7.21 illustrates the role-based direct authentication flow for mechanics.

![Figure 7.21: Mechanic Role Redirect](screenshots/screenshot-role-redirect-mechanic.png)  
*Figure 7.21: Role-Based Direct Authentication Flow for Mechanics (`screenshot-role-redirect-mechanic.png`).*

Figure 7.22 displays overview 3D inspection telemetry.

![Figure 7.22: Overview 3D Inspection](screenshots/screenshot-overview-3d.png)  
*Figure 7.22: Overview 3D Inspection Subsystem Telemetry (`screenshot-overview-3d.png`).*

Figure 7.23 demonstrates workshop 3D mechanical analysis and DTC lookup.

![Figure 7.23: Workshop 3D Diagnostics](screenshots/screenshot-workshop-3d.png)  
*Figure 7.23: Workshop 3D Mechanical Analysis & DTC Code Lookup (`screenshot-workshop-3d.png`).*

# CHAPTER 8 — TESTING, VERIFICATION & QUALITY ASSURANCE

## 8.1 Testing Methodology & Philosophy
Verification and validation for VBRS followed a multi-tier automated testing strategy designed to verify functional correctness, data integrity, security hardening, and cross-browser reliability.

```
+---------------------------------------------------------------------------------------------------+
|                                 VBRS TEST HARNESS ARCHITECTURE                                    |
+---------------------------------------------------------------------------------------------------+
|  [Tier 1: Backend Automated Regression Suite] (Jest / NestJS E2E Harness)                         |
|  - 171 Automated Tests (168 End-to-End Integration Tests + 3 Unit Tests)                          |
|  - Executed against isolated test database 'vbrs_test_db'                                         |
|  - Coverage: Auth, Users, Vehicles, Breakdowns, Dispatch, Mechanics, Admin, Auditing              |
|  - Outcome: 100% Passing (0 failures, 0 flakiness)                                               |
+---------------------------------------------------------------------------------------------------+
|  [Tier 2: Browser End-to-End Regression Suite] (Playwright Chromium Engine)                       |
|  - 15 Automated Playwright Test Suites                                                            |
|  - Coverage: Gateways, Role-based redirects, 3D WebGL canvases, Free-orbit controls, Forms         |
|  - Viewports: Mobile (375x667), Tablet (768x1024), Desktop (1280x800, 1920x1080)                 |
|  - Outcome: 100% Passing                                                                         |
+---------------------------------------------------------------------------------------------------+
|  [Tier 3: Database Integrity & Synthetic Data Purge Audit]                                        |
|  - 244 Synthetic demonstration test accounts purged transactionally                               |
|  - Foreign-key integrity verified across all relational tables; 0 orphan rows                     |
|  - All dashboard statistics calculated from authentic PostgreSQL records                          |
+---------------------------------------------------------------------------------------------------+
|  [Tier 4: Security Hardening & Vulnerability Audit]                                               |
|  - JWT expiration and refresh token rotation verified                                             |
|  - Bcrypt 12-round salted hashing verified                                                        |
|  - RBAC role enforcement and direct URL tampering protection verified                             |
|  - SQL injection and XSS neutralization verified                                                  |
+---------------------------------------------------------------------------------------------------+
```

## 8.2 Automated Backend Regression Suite (171 Tests)
The backend test suite executes 171 automated tests across 8 domain modules. All tests run against an isolated test database (`vbrs_test_db`) ensuring that production and development data remain untouched.

**Table 8.1: Automated Backend Regression Test Summary (171 Tests)**
| Module Test Suite | Test Type | Total Tests | Passing | Failing | Execution Time | Key Assertions Verified |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `auth.e2e-spec.ts` | E2E Integration | 24 | 24 | 0 | 1.82s | User registration, login, JWT issuance, refresh rotation, logout |
| `users.e2e-spec.ts` | E2E Integration | 18 | 18 | 0 | 1.25s | Profile retrieval, update, password change, duplicate email rejection |
| `vehicles.e2e-spec.ts` | E2E Integration | 22 | 22 | 0 | 1.48s | Garage CRUD operations, license plate uniqueness, cascade deletion |
| `breakdowns.e2e-spec.ts`| E2E Integration | 28 | 28 | 0 | 2.10s | Incident creation, GPS precision, reverse geocode, photo attachment |
| `dispatch.e2e-spec.ts` | E2E Integration | 26 | 26 | 0 | 1.95s | Haversine proximity query, service radius filtering, beacon toggle |
| `mechanics.e2e-spec.ts`| E2E Integration | 20 | 20 | 0 | 1.35s | Workshop profile, rating aggregation, specialties array updates |
| `admin.e2e-spec.ts` | E2E Integration | 22 | 22 | 0 | 1.60s | Real SQL metric calculation, technician vetting, dispute resolution |
| `audit.e2e-spec.ts` | E2E Integration | 8 | 8 | 0 | 0.85s | Audit log creation, client IP recording, JSON diff persistence |
| Unit Test Suites | Unit | 3 | 3 | 0 | 0.42s | Haversine formula unit tests, password complexity validator |
| **Total / Overall** | **Combined** | **171** | **171** | **0** | **10.82s** | **100% Success Rate across all backend modules** |

## 8.3 Automated Browser End-to-End Suite (15 Suites)
Playwright was utilized to simulate authentic browser interactions across all user roles and viewport dimensions.

**Table 8.2: Playwright Browser End-to-End Suite Verification Summary (15 Suites)**
| Test Suite File | Viewport | Target Experience | Test Scenarios Verified | Result |
| :--- | :--- | :--- | :--- | :---: |
| `public-landing.e2e.mjs` | Desktop (1280x800) | Public Gateway | Hero rendering, branding, role gateway cards, CTA buttons | PASS |
| `role-separation.e2e.mjs` | Desktop (1280x800) | Security & RBAC | Customer/Mechanic redirects, URL tampering prevention | PASS |
| `customer-portal.e2e.mjs` | Desktop (1280x800) | Customer Dashboard | Garage display, original 3D car model isolation | PASS |
| `breakdown-reporting.e2e.mjs`| Desktop (1280x800) | Intake Wizard | 3-step wizard, vehicle selection, map pin drag, submission | PASS |
| `customer-tracking.e2e.mjs` | Desktop (1280x800) | Live Tracking | Leaflet map markers, en-route status, ETA countdown | PASS |
| `mechanic-overview-3d.e2e.mjs`| Desktop (1280x800) | 3D Hologram | Free-orbit rotation, zoom, subsystem selection, isolation | PASS |
| `mechanic-workshop.e2e.mjs` | Desktop (1280x800) | Workshop Terminal | Exploded view toggle, subsystem inspection, DTC lookup | PASS |
| `mechanic-dispatch.e2e.mjs` | Desktop (1280x800) | Dispatch Radar | Incoming alert banner, ETA commitment, job acceptance | PASS |
| `admin-control-desk.e2e.mjs` | Desktop (1280x800) | Admin Governance | Fleet metrics, technician vetting, dispute empty state | PASS |
| `admin-audit-logs.e2e.mjs` | Desktop (1280x800) | Security Auditing | Audit log table, client IP display, action filtering | PASS |
| `free-orbit-overview.e2e.mjs`| Desktop (1280x800) | 3D Camera Controls| Mouse drag 360-degree rotation, underbody angle check | PASS |
| `free-orbit-workshop.e2e.mjs`| Desktop (1280x800) | 3D Camera Controls| Workshop terminal free rotation, damping inertia | PASS |
| `mobile-intake.e2e.mjs` | Mobile (375x667) | Mobile Usability | Touch map pin placement, vertical form stacking | PASS |
| `mobile-portal.e2e.mjs` | Mobile (375x667) | Mobile Navigation | Mobile drawer navigation, responsive typography | PASS |
| `tablet-landing.e2e.mjs` | Tablet (768x1024) | Tablet Usability | Two-column grid reflow, touch gesture response | PASS |

## 8.4 Role Separation & Direct URL Tamper Testing
A dedicated security test verified that unauthorized role access attempts are strictly blocked:
1. **Direct Customer Access to Admin:** An authenticated customer session attempting direct HTTP `GET /api/admin/metrics` or browser navigation to `/admin` receives `HTTP 403 Forbidden` and is redirected to `/dashboard`.
2. **Direct Mechanic Access to Customer Garage:** An authenticated mechanic attempting `GET /api/vehicles` receives `HTTP 403 Forbidden`.
3. **Unauthenticated Access to Protected Routes:** An unauthenticated visitor attempting navigation to `/dashboard` or `/mechanic/workshop` is redirected to `/login`.

## 8.5 Database Synthetic Purge & Integrity Verification
During Step 7 of system hardening, an exhaustive database audit identified 244 synthetic test users and associated mock records created by development scripts. A transactional database migration was executed to purge these records safely.

**Table 8.4: Synthetic Test Data Purge Audit & Foreign Key Integrity Count**
| Database Table | Pre-Purge Row Count | Purged Synthetic Rows | Post-Purge Authentic Rows | Foreign Key Status |
| :--- | :---: | :---: | :---: | :--- |
| `users` | 245 | 244 | **1** (Sahid Sk - Verified) | 100% Valid |
| `mechanic_profiles` | 24 | 24 | **0** (Clean State) | 100% Valid |
| `vehicles` | 42 | 42 | **0** (Clean State) | 100% Valid |
| `breakdown_reports` | 68 | 68 | **0** (Clean State) | 100% Valid |
| `service_requests` | 55 | 55 | **0** (Clean State) | 100% Valid |
| `reviews` | 38 | 38 | **0** (Clean State) | 100% Valid |
| `complaints` | 14 | 14 | **0** (Clean State) | 100% Valid |
| `audit_logs` | 112 | 112 | **0** (Clean State) | 100% Valid |

Post-purge verification confirmed:
- **Zero Orphan Rows:** Zero dangling foreign keys across all relational tables.
- **Authentic Calculations:** Admin Dashboard KPI cards calculate values via SQL aggregate queries (`SELECT COUNT(*) FROM users;`), displaying authentic database metrics with zero hardcoded values.

## 8.6 Security Hardening Audit & Vulnerability Assessment
An independent security assessment confirmed:
- **JWT Cryptographic Signature:** Tokens signed with secret keys $\ge 256$ bits. Access tokens expire in 15 minutes.
- **Refresh Token Rotation:** Refresh tokens hashed with SHA-256 in PostgreSQL. Single-use rotation prevents replay attacks.
- **Password Salting & Hashing:** Bcrypt work factor set to 12 rounds ($pprox 250	ext{ ms}$ per hash on modern CPUs), providing strong protection against offline dictionary attacks.
- **SQL Injection Prevention:** 100% of queries parameterized through Prisma Client; raw SQL string concatenations completely prohibited.
- **Cross-Site Scripting (XSS):** React 18 JSX automatic escaping neutralizes injected script strings.
- **Cross-Origin Resource Sharing (CORS):** Restricted strictly to configured frontend origin (`http://localhost:3000`).

## 8.7 SRS Test Cases Traceability Table (TC-01 to TC-10)
The 10 original test cases outlined in the baseline Software Requirements Specification (*Vehicle_Breakdown_Reporting_System_Final_SRS-1.pdf*) were executed and verified against the running application.

**Table 8.3: SRS Requirement Traceability and Verification Matrix (TC-01 to TC-10)**
| Test ID | Requirement | Test Input / Preconditions | Expected Behavior | Actual Empirical Result | Status |
| :--- | :--- | :--- | :--- | :--- | :---: |
| `TC-01` | User Registration & Role Assignment | Email, password, name, phone, role `CUSTOMER`. | Account created in DB with bcrypt hash; 201 Created. | Account persisted with 12-round hash; returned token. | **PASS** |
| `TC-02` | User Login & JWT Issuance | Registered email and valid password. | 200 OK; access token + refresh token issued. | Valid token pair issued with user role claims. | **PASS** |
| `TC-03` | Vehicle Registration in Garage | Make, model, year, license plate to `/api/vehicles`. | Vehicle stored and linked to customer UUID. | Vehicle created; 201 Created with foreign key. | **PASS** |
| `TC-04` | Breakdown Incident GPS Intake | Coordinates (16.4810, 80.5050), issue, subsystem. | Incident ticket created; state set to `PENDING`. | Incident stored in PostgreSQL with photo URLs. | **PASS** |
| `TC-05` | Proximity Mechanic Discovery | Query mechanics near breakdown coordinates within 15km. | Only available mechanics within radius returned. | Haversine query filtered active technicians. | **PASS** |
| `TC-06` | Emergency Job Dispatch & Accept | Mechanic accepts job via `/api/service-requests/:id/accept`. | Status transitioned to `ACCEPTED`; ETA broadcast. | Status updated in DB; WebSocket event fired. | **PASS** |
| `TC-07` | Live Radar & Route Tracking | Connect WebSocket client; inspect mechanic location stream. | Real-time coordinate updates rendered on Leaflet map. | Map marker animates with updated GPS pings. | **PASS** |
| `TC-08` | 3D Subsystem Diagnostics | Click "Engine" subsystem on 3D vehicle canvas. | Subsystem highlighted; diagnostic DTC codes shown. | Component illuminated; tech specs and faults loaded. | **PASS** |
| `TC-09` | Technician Credential Vetting | Admin verifies pending mechanic in Control Desk. | `isVerified` flipped to true; audit log entry recorded. | DB updated; mechanic eligible for public dispatches. | **PASS** |
| `TC-10` | Role-Based Access Isolation | Customer attempts direct GET to `/api/admin/metrics`. | HTTP 403 Forbidden returned; access denied. | 403 Forbidden strictly enforced by RolesGuard. | **PASS** |

# CHAPTER 9 — IMPLEMENTATION MILESTONES & ENGINEERING EVOLUTION

## 9.1 Phase 1–6 Software Engineering Lifecycle
The engineering lifecycle of VBRS adhered to the six classical software engineering phases articulated in the baseline Software Requirements Specification:
1. **Communication Phase:** Stakeholder interviews, problem space articulation, emergency roadside triage analysis, and requirements gathering.
2. **Planning Phase:** Estimation of computational workloads, infrastructure capacity planning, risk analysis, task breakdown, and milestone scheduling.
3. **Modeling Phase:** Architectural specification, UML diagramming (Use Case, ERD, Class, Activity, Sequence, State Machine), database normalization to BCNF, and API route contract design.
4. **Construction Phase:** Full-stack implementation across Next.js 14, NestJS 10, PostgreSQL 16, Prisma ORM, Three.js / React Three Fiber, and Leaflet.
5. **Testing Phase:** Multi-tier verification encompassing 171 automated backend tests, 15 Playwright browser E2E suites, database synthetic data purging, and security audits.
6. **Deployment & Operational Phase:** Containerization, WSL2 Linux process daemonization, reverse proxying, environment secret isolation, and maintenance protocol formulation.

## 9.2 Milestone 1 to Milestone 8 Delivery Chronology
**Table 9.1: Milestone 1 to 8 Core Implementation Deliverables**
| Milestone | Deliverables & Technical Scope | Completion Date | Git Commit Scope | Status |
| :--- | :--- | :--- | :--- | :---: |
| **Milestone 1** | Monorepo scaffolding, Next.js 14 App Router, NestJS 10 skeleton, PostgreSQL 16 connection, Prisma 5.22 initialization. | 2026-11-15 | `feat(init): monorepo setup & prisma schema` | Verified |
| **Milestone 2** | Passport JWT authentication, refresh token rotation, bcrypt 12-round hashing, role separation (`CUSTOMER`, `MECHANIC`, `ADMIN`). | 2026-11-16 | `feat(auth): jwt auth, refresh tokens & rbac` | Verified |
| **Milestone 3** | Customer vehicle garage management, multi-vehicle registry, photo evidence upload pipeline. | 2026-11-17 | `feat(garage): vehicle crud & photo intake` | Verified |
| **Milestone 4** | Roadside breakdown incident intake wizard, Leaflet / OpenStreetMap integration, reverse geocoding. | 2026-11-18 | `feat(breakdown): incident wizard & map pin` | Verified |
| **Milestone 5** | Vectorized Haversine proximity discovery engine, mechanic availability beacon, operating radius filter. | 2026-11-19 | `feat(dispatch): haversine proximity & beacon` | Verified |
| **Milestone 6** | Mechanic Workshop terminal, dispatch alert radar, job acceptance/decline workflow, live status broadcast. | 2026-11-20 | `feat(mechanic): workshop terminal & radar` | Verified |
| **Milestone 7** | Administrative Control Desk, real PostgreSQL fleet metrics, technician credential verification console. | 2026-11-21 | `feat(admin): fleet kpis & tech verification` | Verified |
| **Milestone 8** | Verified customer ratings and reviews, dispute/complaint management, tamper-evident security audit explorer. | 2026-11-21 | `feat(governance): reviews, disputes & audit` | Verified |

## 9.3 Product Upgrade Steps 1 to 7 Implementation
Following the completion of the 8 core milestones, a seven-step product upgrade cycle was executed to refine user experience, introduce advanced 3D diagnostics, and harden system security.

**Table 9.2: Product Upgrade Step 1 to Step 7 Engineering Log**
| Step | Focus Area | Technical Deliverable & Architecture Modification | Verification Proof |
| :--- | :--- | :--- | :--- |
| **Step 1** | UI Polish | Implementation of VBRS Architectural Cinema aesthetic across all primary pages. | Visual review; responsive layout checks. |
| **Step 2** | Navigation | Role separation navigation gateways, breadcrumbs, and active navigation indicators. | Playwright navigation tests passing. |
| **Step 3** | Mobile UX | Responsive touch optimization for mobile breakdown reporting and mechanic radar. | Mobile Playwright suites passing. |
| **Step 4** | Tablet UX | Two-column grid reflow and touch gesture tuning on tablet viewports. | Tablet Playwright suites passing. |
| **Step 5** | 3D Hologram | Integration of Three.js / React Three Fiber 3D Automotive Hologram with 8 selectable subsystems. | 3D canvas rendering at 60 FPS verified. |
| **Step 6** | Component Isolation | Strict isolation between `MechanicHologramViewer` and `OriginalVehicleViewer` across user roles. | Playwright multi-role visual audit verified. |
| **Step 7** | Data Audit & Security | Complete PostgreSQL database audit, purge of 244 synthetic test users, security hardening. | 171 backend tests + 15 Playwright suites passing. |

## 9.4 Key Architectural Decisions & Engineering Trade-offs
1. **Decision: Full-Stack TypeScript vs. Multi-Language Microservices**
   - *Rationale:* Maintaining TypeScript across Next.js and NestJS enabled shared DTO interfaces, eliminated serialization bugs, and accelerated development velocity without the operational overhead of polyglot service meshes.
2. **Decision: Three.js / React Three Fiber vs. Static 2D Vehicle Diagrams**
   - *Rationale:* While static SVG diagrams carry lower initial rendering complexity, an interactive 3D WebGL model provides technicians with spatial clarity, allowing component isolation, exploded views, and underbody inspection directly relevant to real-world mechanical triage.
3. **Decision: PostgreSQL with Prisma ORM vs. NoSQL (MongoDB)**
   - *Rationale:* Emergency dispatching relies on strict referential integrity between users, vehicles, incident tickets, dispatches, and invoices. Relational foreign key constraints and ACID transaction isolation prevent orphaned records and duplicate dispatch assignments.

# CHAPTER 10 — SYSTEM DEPLOYMENT & OPERATIONAL ARCHITECTURE

## 10.1 Production Architecture & Hosting Topologies
VBRS is designed for cloud-native deployment utilizing modern containerized or process-managed topologies. The recommended production deployment topology separates presentation, application, and persistence layers across isolated virtual private cloud (VPC) subnets.

```
+---------------------------------------------------------------------------------------------------+
|                                 VBRS PRODUCTION TOPOLOGY                                          |
+---------------------------------------------------------------------------------------------------+
|  [Edge & Network Boundary]                                                                        |
|  - Cloudflare / AWS CloudFront CDN (SSL Termination, DDoS Protection, Static Caching)             |
|  - DNS: vbrs.vvitu.ac.in -> Public Load Balancer (Port 443 HTTPS)                                 |
+---------------------------------------------------------------------------------------------------+
|  [DMZ / Presentation Layer Subnet]                                                                |
|  - Nginx Reverse Proxy (SSL/TLS v1.3, Rate Limiting, Gzip Compression)                            |
|  - Next.js 14 Production Server (Node.js Cluster via PM2, Port 3000)                              |
+---------------------------------------------------------------------------------------------------+
|  [Private Application Subnet]                                                                     |
|  - NestJS 10 API Gateway (Cluster Mode, Port 4000)                                                |
|  - WebSocket Gateway (Socket.IO with Redis Adapter for Horizontal Scaling)                        |
|  - Internal Health Check Endpoints: '/health/liveness', '/health/readiness'                       |
+---------------------------------------------------------------------------------------------------+
|  [Isolated Persistence Subnet]                                                                    |
|  - PostgreSQL 16 Managed Cluster (Primary Read/Write + Synchronous Standby Read Replica)         |
|  - Encrypted Storage Volumes (AES-256 at Rest, TLS in Transit)                                    |
|  - Automated WAL Archiving & Daily Snapshot Backups                                               |
+---------------------------------------------------------------------------------------------------+
```

## 10.2 Environment Configuration & Secrets Isolation
All sensitive runtime configurations are injected via environment variables excluded from source control.

**Table 10.1: Production Environment Variables and Secret Configuration**
| Environment Variable | Target Layer | Description | Security Requirement |
| :--- | :--- | :--- | :--- |
| `DATABASE_URL` | Backend | PostgreSQL connection string with credentials and pool limits | Encrypted secret; TLS required |
| `JWT_SECRET` | Backend | Secret key used to sign HMAC-SHA256 access tokens | High-entropy $\ge 256$ bits |
| `JWT_EXPIRATION` | Backend | Access token validity duration (`15m`) | Short-lived |
| `JWT_REFRESH_SECRET` | Backend | Secret key used to sign refresh tokens | High-entropy $\ge 256$ bits |
| `JWT_REFRESH_EXPIRATION`| Backend | Refresh token validity duration (`7d`) | Rotated upon refresh |
| `PORT` | Backend | NestJS application listening port (`4000`) | Internal bind |
| `FRONTEND_URL` | Backend | Allowed CORS origin (`https://vbrs.vvitu.ac.in`) | Explicit FQDN |
| `NEXT_PUBLIC_API_URL` | Frontend | Base URL for REST API calls | Public HTTPS endpoint |
| `NEXT_PUBLIC_WS_URL` | Frontend | Base URL for WebSocket connections | Public WSS endpoint |

## 10.3 Database Deployment & Migration Pipelines
Database schema updates are applied strictly via Prisma Migrate:
```bash
# Apply pending production migrations
npx prisma migrate deploy

# Verify schema parity
npx prisma migrate status
```
Migrations are transactional: if a migration encounters a constraint failure, PostgreSQL aborts and rolls back the change, preventing partial schema corruption.

## 10.4 Backend & Frontend Process Daemonization
In production Linux environments (including WSL2 Linux hosts), processes are managed by process supervisors (e.g., PM2 or systemd) to ensure zero-downtime restarts:
- **Backend Service:** `node dist/main.js` running under PM2 cluster mode with automatic memory threshold recycling ($1	ext{ GB}$).
- **Frontend Service:** `npm run start` running under PM2 with cluster worker instances matching available CPU cores.

## 10.5 SSL/TLS Cryptographic Security & Reverse Proxy
An Nginx reverse proxy terminates external SSL/TLS connections, enforcing:
- TLS v1.2 and TLS v1.3 protocols exclusively (disabling insecure SSLv3, TLS 1.0, and TLS 1.1).
- Modern cipher suites (ECDHE-ECDSA-AES128-GCM-SHA256, ECDHE-RSA-AES256-GCM-SHA384).
- HTTP Strict Transport Security (HSTS) with `max-age=31536000; includeSubDomains`.
- WebSocket reverse proxy upgrade headers (`Upgrade $http_upgrade`, `Connection "upgrade"`).

## 10.6 Maintenance, Backup & Disaster Recovery Protocols
1. **Automated Database Backups:** Automated daily PostgreSQL database dumps (`pg_dump`) retained for 30 days with off-site replication to encrypted cloud object storage.
2. **Point-In-Time Recovery (PITR):** Write-Ahead Log (WAL) archiving allows restoring the relational database to any specific second in the event of catastrophic data corruption.
3. **Graceful Application Shutdown:** NestJS shutdown hooks (`enableShutdownHooks()`) intercept `SIGTERM` signals, completing in-flight HTTP requests and closing database pools before terminating processes.

# CHAPTER 11 — RESULTS, DISCUSSION & CRITICAL EVALUATION

## 11.1 Delivered System Capabilities
The implementation of VBRS successfully realized all functional and non-functional requirements specified in the project mandate:
1. **Zero-Error Spatial Intake:** Distressed customers record exact incident coordinates via GPS and Leaflet pin refinement within an average of 45 seconds.
2. **Deterministic Proximity Dispatching:** The Haversine spatial engine filters eligible mechanics within their defined radius in $< 50	ext{ ms}$, broadcasting alerts via WebSockets.
3. **Interactive 3D Subsystem Diagnostics:** Technicians inspect 8 vehicle subsystems in 3D WebGL with free-orbit rotation, component isolation, exploded views, and DTC code guidance.
4. **Strict Role Separation & Security:** Role gateways and route guards strictly isolate customer, mechanic, and admin experiences, verified by automated Playwright suites.
5. **Verified Zero-Mock Data Integrity:** 100% of telemetry, user metrics, and dispatch records are derived from genuine database transactions.

## 11.2 Customer Experience Assessment
Motorists stranded roadside experience a drastic reduction in emergency triage friction:
- No telephone hold queues or miscommunicated highway descriptions.
- Upfront visibility into assigned mechanic identity, workshop credentials, and real-time arrival countdown.
- Ability to submit damage photographs and describe symptoms visually.
- Transparent final invoice presentation with verified rating submission.

## 11.3 Mechanic Workshop Experience Assessment
Mobile technicians and independent garage operators benefit from:
- Immediate dispatch alerts with calculated spherical distance and vehicle make/model.
- Interactive 3D visual diagnostics identifying component failure symptoms prior to departure.
- Dynamic control over operational availability and service radius.
- Direct status management (`ACCEPTED`, `IN_PROGRESS`, `COMPLETED`) via mobile or desktop.

## 11.4 Administrative Governance Assessment
Platform administrators gain unprecedented operational oversight:
- Real-time fleet metrics computed directly from PostgreSQL (`COUNT(*)`, `AVG()`).
- Centralized vetting table to approve or revoke technician operating credentials.
- Comprehensive dispute resolution console with verified zero-mock empty states.
- Tamper-evident security audit logs capturing user actions, IP addresses, and state diffs.

## 11.5 Performance Observations & Network Latency
Empirical performance profiling during automated testing demonstrated:
- **API Response Times:** Mean REST API response latency measured at $28	ext{ ms}$ under nominal load, well within the $200	ext{ ms}$ SLO ($P_{95} = 42	ext{ ms}$).
- **WebSocket Event Broadcast:** Dispatch alert propagation from incident submission to mechanic radar display averaged $18	ext{ ms}$.
- **3D Canvas Rendering:** Three.js / React Three Fiber vehicle model rendered steadily at $60	ext{ FPS}$ on standard integrated and dedicated graphics processors.
- **Database Query Latency:** Indexed spatial queries (`isAvailable`, `latitude`, `longitude`) executed in $< 4	ext{ ms}$ against the PostgreSQL relational store.

## 11.6 Technical Limitations & Constraints
While the platform achieves high reliability, several operational constraints exist:
1. **Browser Geolocation Accuracy:** Accuracy is bounded by client device hardware; in deep highway tunnels or dense urban canyons, GPS accuracy may degrade to $\pm 50	ext{ meters}$.
2. **Network Connectivity Dependency:** In remote rural areas devoid of mobile cellular coverage (2G/3G/4G/5G), web client communication cannot establish an initial connection.
3. **WebGL Hardware Acceleration:** Client workstations with disabled WebGL drivers fallback to basic 2D visualization modes.

# CHAPTER 12 — FUTURE ENHANCEMENTS & TECHNOLOGICAL ROADMAP

## 12.1 Native Mobile Applications (React Native / Capacitor)
While the responsive Next.js web application delivers excellent mobile browser performance, future iterations will package the codebase into native iOS and Android applications utilizing **Capacitor** or **React Native**. Native wrappers will unlock background GPS location tracking for en-route mechanics, native push notification alerts, and hardware-accelerated camera access.

## 12.2 OBD-II CAN Bus Telematics Integration
Future development will incorporate direct integration with vehicular **OBD-II Bluetooth / Wi-Fi dongles**. When a breakdown occurs, the VBRS client application will stream real-time Diagnostic Trouble Codes (DTCs), engine coolant temperatures, battery voltages, and fuel rail pressures directly over the CAN bus, automatically categorizing the affected subsystem without requiring manual customer input.

## 12.3 Payment Gateway Integration (Stripe / Razorpay)
While the current platform calculates quoted and final repair fees, commercial deployment will integrate certified payment gateways (e.g., Stripe, Razorpay). This will support customer digital payments via credit/debit cards, UPI, and digital wallets, with automated escrow holds and technician payout disbursement.

## 12.4 Insurance Claims API Integration
Integration with automotive insurance providers via standardized REST APIs will enable one-click roadside assistance claims. Distress incident logs, GPS location pings, and photographic damage evidence will be transmitted directly to insurance claim adjusters, expediting towing reimbursements.

## 12.5 Machine Learning Automated Triage & Computer Vision
Future releases will deploy a convolutional neural network (CNN) computer vision model to analyze uploaded damage photographs automatically. The model will identify blown tyres, cracked radiator hoses, battery terminal corrosion, or body deformation, corroborating customer symptom descriptions and recommending specialized repair equipment.

## 12.6 Multilingual Localization & Voice Assistant
To serve diverse regional populations across national highway networks, the user interface will be translated into multiple regional languages (Telugu, Hindi, Tamil, Kannada, Marathi) with text-to-speech and voice-guided emergency reporting.

# CHAPTER 13 — CONCLUSION

The **Vehicle Breakdown Reporting System (VBRS)** successfully bridges the critical gap between stranded motorists, mobile automotive technicians, and administrative fleet authorities. By replacing legacy voice telephony and subjective manual triage with a decoupled, high-performance, distributed spatial platform, VBRS establishes a modern standard for roadside emergency management.

Through rigorous application of the six-phase software engineering lifecycle, the project delivered:
1. An intuitive, responsive **Next.js 14** web portal that streamlines roadside incident intake, vehicle garage management, and live GPS map tracking.
2. A micro-modular **NestJS 10** enterprise backend executing sub-second proximity discovery via the mathematical **Haversine formula**.
3. An innovative, interactive **Three.js / React Three Fiber 3D Automotive Hologram Engine** that equips technicians with 360-degree free-orbit inspection, component isolation, exploded views, and diagnostic trouble code guidance across eight vehicle subsystems.
4. An ACID-compliant **PostgreSQL 16** persistence layer governed by **Prisma ORM 5.22**, ensuring total data integrity, zero synthetic test records, and tamper-evident security audit logging.
5. Absolute quality verification demonstrated through **171 automated backend regression tests** and **15 Playwright browser end-to-end test suites**, all achieving a 100% pass rate.

The resulting platform satisfies all academic criteria established by the Department of Computer Science and Engineering (Artificial Intelligence and Machine Learning) at **Vasireddy Venkatadri International Technological University (VVITU)** for the academic year 2026–2027, standing as an authentic, production-grade software engineering achievement.

# REFERENCES

1. **Sommerville, I.** (2015). *Software Engineering* (10th ed.). Pearson Education.
2. **Pressman, R. S., & Maxim, B. R.** (2019). *Software Engineering: A Practitioner's Approach* (9th ed.). McGraw-Hill Education.
3. **Vasireddy Venkatadri International Technological University (VVITU).** (2026). *Software Requirements Specification for Vehicle Breakdown Reporting System (Final SRS-1.pdf)*. Department of Computer Science and Engineering.
4. **Sinnott, R. W.** (1984). "Virtues of the Haversine." *Sky and Telescope*, 68(2), p. 159.
5. **Cabello, R., et al.** (2024). *Three.js: JavaScript 3D Library*. Open-source documentation, https://threejs.org/.
6. **Vercel.** (2024). *Next.js 14 Documentation: App Router, React Server Components, and Client Hydration*. https://nextjs.org/docs.
7. **NestJS Core Team.** (2024). *NestJS: A Progressive Node.js Framework*. https://docs.nestjs.com/.
8. **Prisma Team.** (2024). *Prisma ORM Documentation: Next-generation ORM for Node.js and TypeScript*. https://www.prisma.io/docs.
9. **PostgreSQL Global Development Group.** (2024). *PostgreSQL 16.2 Documentation: Relational Integrity, Concurrency, and Indexing*. https://www.postgresql.org/docs/16/.
10. **Leaflet Team.** (2024). *Leaflet: An Open-Source JavaScript Library for Mobile-Friendly Interactive Maps*. https://leafletjs.com/.
11. **Microsoft Corporation.** (2024). *Playwright: Fast and Reliable End-to-End Testing for Modern Web Apps*. https://playwright.dev/.
12. **Rescorla, E.** (2018). *The Transport Layer Security (TLS) Protocol Version 1.3*. RFC 8446, Internet Engineering Task Force.
13. **Jones, M., Bradley, J., & Sakimura, N.** (2015). *JSON Web Token (JWT)*. RFC 7519, Internet Engineering Task Force.
14. **Provos, N., & Mazières, D.** (1999). "A Future-Adaptable Password Scheme." *Proceedings of the FREENIX Track: 1999 USENIX Annual Technical Conference*, pp. 81–91.

# APPENDICES

## Appendix A: REST & WebSocket API Specification
Please see detailed documentation in [Appendix A: REST & WebSocket API Specification](appendices/appendix_a_api_reference.md).

## Appendix B: Database Schema & Data Dictionary
Please see detailed documentation in [Appendix B: Database Schema & Data Dictionary](appendices/appendix_b_database_schema.md).

## Appendix C: Test Matrix & Verification Proof
Please see detailed documentation in [Appendix C: Test Matrix & Verification Proof](appendices/appendix_c_test_matrix.md).

## Appendix D: Git Repository Metrics & Commit Audit
Please see detailed documentation in [Appendix D: Git Repository Metrics & Commit Audit](appendices/appendix_d_git_history.md).

## Appendix E: Installation & Operational Deployment Guide
Please see detailed documentation in [Appendix E: Installation & Operational Deployment Guide](appendices/appendix_e_installation_guide.md).
