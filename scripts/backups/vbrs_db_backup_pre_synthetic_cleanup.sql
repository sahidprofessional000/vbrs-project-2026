--
-- PostgreSQL database dump
--

\restrict clSnZMTu7kVHKIIldZYIaCZ0doaeDIDc6x0DyRkBBmsUSFGCTPU2XlPDc0htNHj

-- Dumped from database version 18.7
-- Dumped by pg_dump version 18.7

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: AvailabilityStatus; Type: TYPE; Schema: public; Owner: vbrs_admin
--

CREATE TYPE public."AvailabilityStatus" AS ENUM (
    'OFFLINE',
    'AVAILABLE',
    'ON_JOB'
);


ALTER TYPE public."AvailabilityStatus" OWNER TO vbrs_admin;

--
-- Name: BreakdownCategory; Type: TYPE; Schema: public; Owner: vbrs_admin
--

CREATE TYPE public."BreakdownCategory" AS ENUM (
    'ENGINE_FAILURE',
    'TRANSMISSION_ISSUE',
    'FLAT_TIRE_WHEEL',
    'BATTERY_DEAD_ELECTRICAL',
    'BRAKE_SYSTEM_FAILURE',
    'OVERHEATING_COOLANT',
    'FUEL_EMPTY_OR_CONTAMINATED',
    'LOCKOUT_KEY_LOST',
    'COLLISION_ACCIDENT',
    'OTHER_UNKNOWN'
);


ALTER TYPE public."BreakdownCategory" OWNER TO vbrs_admin;

--
-- Name: ComplaintStatus; Type: TYPE; Schema: public; Owner: vbrs_admin
--

CREATE TYPE public."ComplaintStatus" AS ENUM (
    'PENDING',
    'INVESTIGATING',
    'RESOLVED',
    'DISMISSED'
);


ALTER TYPE public."ComplaintStatus" OWNER TO vbrs_admin;

--
-- Name: NotificationType; Type: TYPE; Schema: public; Owner: vbrs_admin
--

CREATE TYPE public."NotificationType" AS ENUM (
    'REQUEST_UPDATE',
    'DISPATCH_OFFER',
    'ASSIGNMENT',
    'COMPLETION',
    'ADMIN_ALERT',
    'GENERAL'
);


ALTER TYPE public."NotificationType" OWNER TO vbrs_admin;

--
-- Name: PowertrainType; Type: TYPE; Schema: public; Owner: vbrs_admin
--

CREATE TYPE public."PowertrainType" AS ENUM (
    'PETROL',
    'DIESEL',
    'ELECTRIC',
    'HYBRID',
    'CNG'
);


ALTER TYPE public."PowertrainType" OWNER TO vbrs_admin;

--
-- Name: Role; Type: TYPE; Schema: public; Owner: vbrs_admin
--

CREATE TYPE public."Role" AS ENUM (
    'CUSTOMER',
    'MECHANIC',
    'ADMIN'
);


ALTER TYPE public."Role" OWNER TO vbrs_admin;

--
-- Name: ServiceRequestStatus; Type: TYPE; Schema: public; Owner: vbrs_admin
--

CREATE TYPE public."ServiceRequestStatus" AS ENUM (
    'SUBMITTED',
    'SEARCHING',
    'ASSIGNED',
    'ACCEPTED',
    'EN_ROUTE',
    'ARRIVED',
    'IN_PROGRESS',
    'COMPLETED',
    'CANCELLED'
);


ALTER TYPE public."ServiceRequestStatus" OWNER TO vbrs_admin;

--
-- Name: SeverityLevel; Type: TYPE; Schema: public; Owner: vbrs_admin
--

CREATE TYPE public."SeverityLevel" AS ENUM (
    'LOW',
    'MEDIUM',
    'CRITICAL'
);


ALTER TYPE public."SeverityLevel" OWNER TO vbrs_admin;

--
-- Name: VerificationStatus; Type: TYPE; Schema: public; Owner: vbrs_admin
--

CREATE TYPE public."VerificationStatus" AS ENUM (
    'PENDING',
    'APPROVED',
    'REJECTED'
);


ALTER TYPE public."VerificationStatus" OWNER TO vbrs_admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: AuditLog; Type: TABLE; Schema: public; Owner: vbrs_admin
--

CREATE TABLE public."AuditLog" (
    id text NOT NULL,
    "userId" text,
    action text NOT NULL,
    "entityName" text NOT NULL,
    "entityId" text,
    details jsonb,
    "ipAddress" text,
    "userAgent" text,
    "timestamp" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."AuditLog" OWNER TO vbrs_admin;

--
-- Name: BreakdownReport; Type: TABLE; Schema: public; Owner: vbrs_admin
--

CREATE TABLE public."BreakdownReport" (
    id text NOT NULL,
    "customerId" text NOT NULL,
    "vehicleId" text,
    category public."BreakdownCategory" NOT NULL,
    severity public."SeverityLevel" DEFAULT 'MEDIUM'::public."SeverityLevel" NOT NULL,
    description text NOT NULL,
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    "addressText" text,
    "ruleDiagnosis" text,
    "requiresTowing" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."BreakdownReport" OWNER TO vbrs_admin;

--
-- Name: Complaint; Type: TABLE; Schema: public; Owner: vbrs_admin
--

CREATE TABLE public."Complaint" (
    id text NOT NULL,
    "serviceRequestId" text NOT NULL,
    "filedById" text NOT NULL,
    "targetUserId" text,
    subject text NOT NULL,
    description text NOT NULL,
    status public."ComplaintStatus" DEFAULT 'PENDING'::public."ComplaintStatus" NOT NULL,
    "resolutionNotes" text,
    "resolvedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Complaint" OWNER TO vbrs_admin;

--
-- Name: MechanicLocation; Type: TABLE; Schema: public; Owner: vbrs_admin
--

CREATE TABLE public."MechanicLocation" (
    id text NOT NULL,
    "mechanicId" text NOT NULL,
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    heading double precision,
    speed double precision,
    accuracy double precision,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."MechanicLocation" OWNER TO vbrs_admin;

--
-- Name: MechanicProfile; Type: TABLE; Schema: public; Owner: vbrs_admin
--

CREATE TABLE public."MechanicProfile" (
    id text NOT NULL,
    "userId" text NOT NULL,
    "workshopName" text,
    "tradeLicenseNumber" text,
    "experienceYears" integer DEFAULT 0 NOT NULL,
    "verificationStatus" public."VerificationStatus" DEFAULT 'PENDING'::public."VerificationStatus" NOT NULL,
    "verificationNotes" text,
    "availabilityStatus" public."AvailabilityStatus" DEFAULT 'OFFLINE'::public."AvailabilityStatus" NOT NULL,
    "operatingRadiusKm" double precision DEFAULT 25.0 NOT NULL,
    "ratingAverage" double precision DEFAULT 0.0 NOT NULL,
    "totalReviews" integer DEFAULT 0 NOT NULL,
    "totalJobsCompleted" integer DEFAULT 0 NOT NULL,
    "documentUrl" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    bio text,
    certifications text[] DEFAULT ARRAY[]::text[],
    specializations text[] DEFAULT ARRAY[]::text[],
    "workshopAddress" text
);


ALTER TABLE public."MechanicProfile" OWNER TO vbrs_admin;

--
-- Name: MechanicService; Type: TABLE; Schema: public; Owner: vbrs_admin
--

CREATE TABLE public."MechanicService" (
    id text NOT NULL,
    "mechanicId" text NOT NULL,
    category public."BreakdownCategory" NOT NULL,
    "priceEstimateMin" double precision,
    "priceEstimateMax" double precision,
    description text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."MechanicService" OWNER TO vbrs_admin;

--
-- Name: Notification; Type: TABLE; Schema: public; Owner: vbrs_admin
--

CREATE TABLE public."Notification" (
    id text NOT NULL,
    "userId" text NOT NULL,
    title text NOT NULL,
    message text NOT NULL,
    type public."NotificationType" DEFAULT 'GENERAL'::public."NotificationType" NOT NULL,
    payload jsonb,
    "isRead" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."Notification" OWNER TO vbrs_admin;

--
-- Name: RefreshToken; Type: TABLE; Schema: public; Owner: vbrs_admin
--

CREATE TABLE public."RefreshToken" (
    id text NOT NULL,
    "tokenHash" text NOT NULL,
    "userId" text NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "revokedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."RefreshToken" OWNER TO vbrs_admin;

--
-- Name: ReportImage; Type: TABLE; Schema: public; Owner: vbrs_admin
--

CREATE TABLE public."ReportImage" (
    id text NOT NULL,
    "reportId" text NOT NULL,
    "filePath" text NOT NULL,
    "fileName" text NOT NULL,
    "fileSize" integer NOT NULL,
    "mimeType" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."ReportImage" OWNER TO vbrs_admin;

--
-- Name: Review; Type: TABLE; Schema: public; Owner: vbrs_admin
--

CREATE TABLE public."Review" (
    id text NOT NULL,
    "serviceRequestId" text NOT NULL,
    "customerId" text NOT NULL,
    "mechanicId" text NOT NULL,
    rating integer NOT NULL,
    comment text,
    "timelinessRating" integer,
    "costFairnessRating" integer,
    "professionalismRating" integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."Review" OWNER TO vbrs_admin;

--
-- Name: SavedAddress; Type: TABLE; Schema: public; Owner: vbrs_admin
--

CREATE TABLE public."SavedAddress" (
    id text NOT NULL,
    "userId" text NOT NULL,
    label text NOT NULL,
    address text NOT NULL,
    latitude double precision,
    longitude double precision,
    "isDefault" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."SavedAddress" OWNER TO vbrs_admin;

--
-- Name: ServiceRequest; Type: TABLE; Schema: public; Owner: vbrs_admin
--

CREATE TABLE public."ServiceRequest" (
    id text NOT NULL,
    "breakdownReportId" text NOT NULL,
    "customerId" text NOT NULL,
    "mechanicId" text,
    "currentStatus" public."ServiceRequestStatus" DEFAULT 'SUBMITTED'::public."ServiceRequestStatus" NOT NULL,
    "agreedQuote" double precision,
    "resolutionNotes" text,
    "cancellationReason" text,
    "assignedAt" timestamp(3) without time zone,
    "acceptedAt" timestamp(3) without time zone,
    "enRouteAt" timestamp(3) without time zone,
    "arrivedAt" timestamp(3) without time zone,
    "completedAt" timestamp(3) without time zone,
    "cancelledAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "diagnosticQuote" double precision,
    "inProgressAt" timestamp(3) without time zone,
    "laborCost" double precision,
    "locationConsent" boolean DEFAULT true NOT NULL,
    "partsCost" double precision
);


ALTER TABLE public."ServiceRequest" OWNER TO vbrs_admin;

--
-- Name: ServiceStatusHistory; Type: TABLE; Schema: public; Owner: vbrs_admin
--

CREATE TABLE public."ServiceStatusHistory" (
    id text NOT NULL,
    "serviceRequestId" text NOT NULL,
    "fromStatus" public."ServiceRequestStatus",
    "toStatus" public."ServiceRequestStatus" NOT NULL,
    "changedById" text,
    notes text,
    "timestamp" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."ServiceStatusHistory" OWNER TO vbrs_admin;

--
-- Name: User; Type: TABLE; Schema: public; Owner: vbrs_admin
--

CREATE TABLE public."User" (
    id text NOT NULL,
    email text NOT NULL,
    "passwordHash" text NOT NULL,
    "fullName" text NOT NULL,
    phone text,
    role public."Role" DEFAULT 'CUSTOMER'::public."Role" NOT NULL,
    "avatarUrl" text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."User" OWNER TO vbrs_admin;

--
-- Name: Vehicle; Type: TABLE; Schema: public; Owner: vbrs_admin
--

CREATE TABLE public."Vehicle" (
    id text NOT NULL,
    "userId" text NOT NULL,
    make text NOT NULL,
    model text NOT NULL,
    year integer NOT NULL,
    "licensePlate" text NOT NULL,
    vin text,
    color text,
    powertrain public."PowertrainType" DEFAULT 'PETROL'::public."PowertrainType" NOT NULL,
    "isDefault" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Vehicle" OWNER TO vbrs_admin;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: vbrs_admin
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO vbrs_admin;

--
-- Data for Name: AuditLog; Type: TABLE DATA; Schema: public; Owner: vbrs_admin
--

COPY public."AuditLog" (id, "userId", action, "entityName", "entityId", details, "ipAddress", "userAgent", "timestamp") FROM stdin;
a8d726b8-5919-499d-85ee-34eeb1060f87	ac3508cb-830b-424e-86b8-303c71462968	USER_REGISTERED	User	ac3508cb-830b-424e-86b8-303c71462968	{"role": "CUSTOMER", "email": "m2.customer.1795331509851@vbrs.local"}	\N	\N	2026-11-22 07:11:50.446
0b51e5ce-cd1c-4d39-affd-9229b01e3b75	ac3508cb-830b-424e-86b8-303c71462968	USER_LOGGED_IN	User	ac3508cb-830b-424e-86b8-303c71462968	\N	\N	\N	2026-11-22 07:11:50.712
ea01286f-397a-4735-9864-e6e77b7ca403	ac3508cb-830b-424e-86b8-303c71462968	VEHICLE_ADDED	Vehicle	5c920041-6fb2-40bc-996e-5ee623e51e81	{"make": "Ford", "model": "Mustang Mach-E", "plate": "M2-0983"}	\N	\N	2026-11-22 07:11:51
ddce5127-ed1f-4696-ad73-213308ec8dc2	ac3508cb-830b-424e-86b8-303c71462968	VEHICLE_UPDATED	Vehicle	5c920041-6fb2-40bc-996e-5ee623e51e81	\N	\N	\N	2026-11-22 07:11:51.033
d2578693-906b-49d9-ba61-0037084b55f7	ac3508cb-830b-424e-86b8-303c71462968	VEHICLE_DELETED	Vehicle	5c920041-6fb2-40bc-996e-5ee623e51e81	{"plate": "M2-0983"}	\N	\N	2026-11-22 07:11:51.055
6326b008-6537-4d4b-ac75-657170103e6a	ac3508cb-830b-424e-86b8-303c71462968	USER_LOGGED_OUT	User	ac3508cb-830b-424e-86b8-303c71462968	\N	\N	\N	2026-11-22 07:11:51.07
0fc3c09a-d43f-4e20-9675-77c96ce86041	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 07:12:37.226
7350e3ef-e616-4eba-b500-add1f277dbfe	bde388dc-1767-4bbc-a67f-22901fc816a8	USER_REGISTERED	User	bde388dc-1767-4bbc-a67f-22901fc816a8	{"role": "CUSTOMER", "email": "m2.customer.1795331737103@vbrs.local"}	\N	\N	2026-11-22 07:15:37.71
1271ccd1-cfd9-4f64-adc3-161898471902	bde388dc-1767-4bbc-a67f-22901fc816a8	USER_LOGGED_IN	User	bde388dc-1767-4bbc-a67f-22901fc816a8	\N	\N	\N	2026-11-22 07:15:37.971
a0e0149c-aa2d-4218-8086-b9f51b47c03e	bde388dc-1767-4bbc-a67f-22901fc816a8	VEHICLE_ADDED	Vehicle	2564cd29-9d00-4a62-9bab-d5f864a02b3f	{"make": "Ford", "model": "Mustang Mach-E", "plate": "M2-8225"}	\N	\N	2026-11-22 07:15:38.247
cc5f72d7-1d0a-4cf2-a51c-1a4e9bb9ddfc	bde388dc-1767-4bbc-a67f-22901fc816a8	VEHICLE_UPDATED	Vehicle	2564cd29-9d00-4a62-9bab-d5f864a02b3f	\N	\N	\N	2026-11-22 07:15:38.28
cc6fd904-3868-4c13-a44b-7a7b094a5a4e	bde388dc-1767-4bbc-a67f-22901fc816a8	VEHICLE_DELETED	Vehicle	2564cd29-9d00-4a62-9bab-d5f864a02b3f	{"plate": "M2-8225"}	\N	\N	2026-11-22 07:15:38.302
ee71478f-7ac0-4801-a82f-517f4f493477	bde388dc-1767-4bbc-a67f-22901fc816a8	USER_LOGGED_OUT	User	bde388dc-1767-4bbc-a67f-22901fc816a8	\N	\N	\N	2026-11-22 07:15:38.316
f5018b85-0f9a-4ae3-ba24-58e0ab299d4a	a1479806-db8e-432b-a61a-04b1494faf85	USER_REGISTERED	User	a1479806-db8e-432b-a61a-04b1494faf85	{"role": "CUSTOMER", "email": "sahid.0777777@gmail.com"}	\N	\N	2026-11-22 07:19:37.837
d75501c1-e7a2-40e3-b8b1-afa8742ba4d4	a1479806-db8e-432b-a61a-04b1494faf85	USER_LOGGED_IN	User	a1479806-db8e-432b-a61a-04b1494faf85	\N	\N	\N	2026-11-22 07:20:08.211
d7369eaf-939e-4666-aad5-ec1dd3660976	a1479806-db8e-432b-a61a-04b1494faf85	USER_LOGGED_OUT	User	a1479806-db8e-432b-a61a-04b1494faf85	\N	\N	\N	2026-11-22 07:20:43.556
8d8619b2-ebb2-40de-9aa8-f80029bacd55	c1b7fe66-784a-4964-a091-320fa60f5489	USER_REGISTERED	User	c1b7fe66-784a-4964-a091-320fa60f5489	{"role": "CUSTOMER", "email": "m2.customer.1795332738506@vbrs.local"}	\N	\N	2026-11-22 07:32:19.083
4c795a20-fab1-4f0b-b71f-5985f27f66db	c1b7fe66-784a-4964-a091-320fa60f5489	USER_LOGGED_IN	User	c1b7fe66-784a-4964-a091-320fa60f5489	\N	\N	\N	2026-11-22 07:32:19.351
03947245-9b15-4591-aaad-cf280dae4d2b	c1b7fe66-784a-4964-a091-320fa60f5489	VEHICLE_ADDED	Vehicle	db8e0f77-277c-4e22-9dd5-2bcd3168c3a5	{"make": "Ford", "model": "Mustang Mach-E", "plate": "M2-9619"}	\N	\N	2026-11-22 07:32:19.633
7828f165-438d-45b4-b116-09fb36892be1	c1b7fe66-784a-4964-a091-320fa60f5489	VEHICLE_UPDATED	Vehicle	db8e0f77-277c-4e22-9dd5-2bcd3168c3a5	\N	\N	\N	2026-11-22 07:32:19.673
42fcb455-9199-4168-a983-6fd56a22822a	c1b7fe66-784a-4964-a091-320fa60f5489	VEHICLE_DELETED	Vehicle	db8e0f77-277c-4e22-9dd5-2bcd3168c3a5	{"plate": "M2-9619"}	\N	\N	2026-11-22 07:32:19.695
30e6c06e-d872-430b-92da-f349e5c2e46a	c1b7fe66-784a-4964-a091-320fa60f5489	USER_LOGGED_OUT	User	c1b7fe66-784a-4964-a091-320fa60f5489	\N	\N	\N	2026-11-22 07:32:19.71
f49e3287-3acb-46c2-a8a1-291128c5f4ad	a1479806-db8e-432b-a61a-04b1494faf85	USER_LOGGED_IN	User	a1479806-db8e-432b-a61a-04b1494faf85	\N	\N	\N	2026-11-22 07:34:17.638
6d22763a-df94-41b6-89a7-95c6679cb9eb	a1479806-db8e-432b-a61a-04b1494faf85	USER_LOGGED_IN	User	a1479806-db8e-432b-a61a-04b1494faf85	\N	\N	\N	2026-11-22 07:34:52.496
2d4aebb5-46ef-4bb7-ac8b-0f6effe20297	a1479806-db8e-432b-a61a-04b1494faf85	USER_LOGGED_OUT	User	a1479806-db8e-432b-a61a-04b1494faf85	\N	\N	\N	2026-11-22 08:04:02.826
1a5b9468-9103-40dd-9ae3-67f97d25f4b9	a1479806-db8e-432b-a61a-04b1494faf85	USER_LOGGED_IN	User	a1479806-db8e-432b-a61a-04b1494faf85	\N	\N	\N	2026-11-22 08:04:12.635
d9ce3035-c95e-42d2-8da3-8843ea135669	ddac9980-193c-46b4-80e4-8cf4a1d55d97	USER_REGISTERED	User	ddac9980-193c-46b4-80e4-8cf4a1d55d97	{"role": "CUSTOMER", "email": "m2.customer.1795338320195@vbrs.local"}	\N	\N	2026-11-22 09:05:21.201
37932868-cb1b-4d8e-9355-42aa7dcbd343	ddac9980-193c-46b4-80e4-8cf4a1d55d97	USER_LOGGED_IN	User	ddac9980-193c-46b4-80e4-8cf4a1d55d97	\N	\N	\N	2026-11-22 09:05:21.605
6438638b-f48d-4518-ab8d-4329fd643d2a	ddac9980-193c-46b4-80e4-8cf4a1d55d97	VEHICLE_ADDED	Vehicle	d02777ba-ce89-426b-b965-fa2f4a9ee297	{"make": "Ford", "model": "Mustang Mach-E", "plate": "M2-2020"}	\N	\N	2026-11-22 09:05:22.036
ac6a64a5-89bf-4ff4-bf8f-224cc51038e7	ddac9980-193c-46b4-80e4-8cf4a1d55d97	VEHICLE_UPDATED	Vehicle	d02777ba-ce89-426b-b965-fa2f4a9ee297	\N	\N	\N	2026-11-22 09:05:22.087
72027baa-e12e-40b4-9d1e-05184049edf7	ddac9980-193c-46b4-80e4-8cf4a1d55d97	VEHICLE_DELETED	Vehicle	d02777ba-ce89-426b-b965-fa2f4a9ee297	{"plate": "M2-2020"}	\N	\N	2026-11-22 09:05:22.119
f822a954-06a7-4a86-9a8b-b5de795ed5f3	ddac9980-193c-46b4-80e4-8cf4a1d55d97	USER_LOGGED_OUT	User	ddac9980-193c-46b4-80e4-8cf4a1d55d97	\N	\N	\N	2026-11-22 09:05:22.139
b85199df-d49f-45b5-9b6a-a5c935df7375	7a13794a-e022-4261-9b33-6ce596779309	USER_REGISTERED	User	7a13794a-e022-4261-9b33-6ce596779309	{"role": "CUSTOMER", "email": "audit.customer.1795338443181@vbrs.local"}	\N	\N	2026-11-22 09:07:23.75
7bca8a5d-4a7c-4425-b911-885b3c77d520	f497148d-d3c5-45be-b500-72020fd86949	USER_REGISTERED	User	f497148d-d3c5-45be-b500-72020fd86949	{"role": "MECHANIC", "email": "audit.mechanic.1795338443181@vbrs.local"}	\N	\N	2026-11-22 09:07:24.005
a25ff2f8-54c9-4445-b9c5-efcc5a6a1793	7a13794a-e022-4261-9b33-6ce596779309	USER_LOGGED_IN	User	7a13794a-e022-4261-9b33-6ce596779309	\N	\N	\N	2026-11-22 09:07:24.248
7a26932b-ae94-49c0-951a-aaf6ee19e624	f497148d-d3c5-45be-b500-72020fd86949	USER_LOGGED_IN	User	f497148d-d3c5-45be-b500-72020fd86949	\N	\N	\N	2026-11-22 09:07:24.481
044d2ec3-f968-4662-8e27-958cd22cc5c8	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 09:07:24.715
162ab6ea-2299-44d2-a10d-87137a596dd3	13f321bb-a96d-47dc-84d9-c6e12d82ae2e	USER_REGISTERED	User	13f321bb-a96d-47dc-84d9-c6e12d82ae2e	{"role": "CUSTOMER", "email": "audit.userb.1795338443181@vbrs.local"}	\N	\N	2026-11-22 09:07:25.193
cb1cbab7-7ebd-4311-96d2-9f6352fc1cc0	7a13794a-e022-4261-9b33-6ce596779309	VEHICLE_ADDED	Vehicle	fea35bfe-cd34-4fe0-a074-42358c550606	{"make": "Porsche", "model": "Taycan GTS", "plate": "AUD-3182"}	\N	\N	2026-11-22 09:07:25.708
564c2d42-f7bd-4f1b-bc98-20648e90ada0	7a13794a-e022-4261-9b33-6ce596779309	VEHICLE_UPDATED	Vehicle	fea35bfe-cd34-4fe0-a074-42358c550606	\N	\N	\N	2026-11-22 09:07:25.73
f43c4220-ba8c-441c-b2f0-018719286f4a	7a13794a-e022-4261-9b33-6ce596779309	VEHICLE_DELETED	Vehicle	fea35bfe-cd34-4fe0-a074-42358c550606	{"plate": "AUD-3182"}	\N	\N	2026-11-22 09:07:25.757
fb1c57cf-80bc-4ae0-aa16-af21b417254c	c972ff02-c8ee-4306-af30-97d17afddc20	USER_REGISTERED	User	c972ff02-c8ee-4306-af30-97d17afddc20	{"role": "CUSTOMER", "email": "audit.customer.1795338480610@vbrs.local"}	\N	\N	2026-11-22 09:08:01.208
1c45acb0-bfc7-48ff-9c33-6a7885b74d46	b7eed690-1ed3-46ed-882a-8ff0ca54af9d	USER_REGISTERED	User	b7eed690-1ed3-46ed-882a-8ff0ca54af9d	{"role": "MECHANIC", "email": "audit.mechanic.1795338480610@vbrs.local"}	\N	\N	2026-11-22 09:08:01.46
3c76ba2f-d495-40bb-9303-faf1998f6de1	c972ff02-c8ee-4306-af30-97d17afddc20	USER_LOGGED_IN	User	c972ff02-c8ee-4306-af30-97d17afddc20	\N	\N	\N	2026-11-22 09:08:01.703
6df5e277-23b6-4e8c-a538-d893d68cabf3	b7eed690-1ed3-46ed-882a-8ff0ca54af9d	USER_LOGGED_IN	User	b7eed690-1ed3-46ed-882a-8ff0ca54af9d	\N	\N	\N	2026-11-22 09:08:01.939
44ebc72d-d266-47bd-81c3-cea0912ba154	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 09:08:02.172
34e60ec6-d142-4a9b-acd5-d8fc32b1f0df	cf8c2466-215a-460b-a889-2f47bce8dd02	USER_REGISTERED	User	cf8c2466-215a-460b-a889-2f47bce8dd02	{"role": "CUSTOMER", "email": "audit.userb.1795338480610@vbrs.local"}	\N	\N	2026-11-22 09:08:02.703
54d96ad7-6304-451a-8400-c87e842d8c74	c972ff02-c8ee-4306-af30-97d17afddc20	VEHICLE_ADDED	Vehicle	c49769a5-c6a7-4501-95f8-8e41ca4a887f	{"make": "Porsche", "model": "Taycan GTS", "plate": "AUD-0611"}	\N	\N	2026-11-22 09:08:03.214
cdb8cbc8-9687-4185-90d7-575cd7229806	c972ff02-c8ee-4306-af30-97d17afddc20	VEHICLE_UPDATED	Vehicle	c49769a5-c6a7-4501-95f8-8e41ca4a887f	\N	\N	\N	2026-11-22 09:08:03.236
05c56295-65e4-466d-96b5-ed07772bcfd7	c972ff02-c8ee-4306-af30-97d17afddc20	VEHICLE_DELETED	Vehicle	c49769a5-c6a7-4501-95f8-8e41ca4a887f	{"plate": "AUD-0611"}	\N	\N	2026-11-22 09:08:03.262
731e2f44-44cb-4a0e-aaef-6d3dcd273f1e	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 09:10:00.098
cdb1ddf5-0afd-4431-ad59-2b72496f76a5	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 09:10:52.407
8eef946e-1ab3-487e-8b0c-72e63735cd6f	e22478b0-00a4-44f8-b146-3649213c7a20	VEHICLE_ADDED	Vehicle	5d48ecb5-70b7-4754-9871-f8a478e57b46	{"make": "Audi", "model": "RS6 Avant", "plate": "E2E-3961"}	\N	\N	2026-11-22 09:10:54.024
dba21a06-97b2-4887-889c-303785b2b63e	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 09:11:25.291
5b7bf401-6d7b-4a2d-b03a-4453433b60bc	e22478b0-00a4-44f8-b146-3649213c7a20	VEHICLE_ADDED	Vehicle	8531c076-c4eb-46e0-8f89-65d5dcc39895	{"make": "Audi", "model": "RS6 Avant", "plate": "E2E-6854"}	\N	\N	2026-11-22 09:11:26.912
e66ec7db-856a-4226-a431-ef4f492d38c4	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 09:12:09.949
9e52715e-67eb-4b8d-8867-a621b12300f4	e22478b0-00a4-44f8-b146-3649213c7a20	VEHICLE_ADDED	Vehicle	8a02753f-d7f8-44a0-a530-d99461578aaf	{"make": "Audi", "model": "RS6 Avant", "plate": "E2E-1510"}	\N	\N	2026-11-22 09:12:11.563
6fd5ae6b-7270-4872-8487-7470ab17c593	8be98a6e-8e34-4741-8dbc-8105dd3d6b2d	USER_REGISTERED	User	8be98a6e-8e34-4741-8dbc-8105dd3d6b2d	{"role": "CUSTOMER", "email": "m2.customer.1795338760218@vbrs.local"}	\N	\N	2026-11-22 09:12:40.82
cd0fc3c0-37d0-493a-9302-3fa953d7a0fa	df30359f-fb78-4f77-8c18-936d3d870d43	USER_REGISTERED	User	df30359f-fb78-4f77-8c18-936d3d870d43	{"role": "CUSTOMER", "email": "audit.customer.1795338760217@vbrs.local"}	\N	\N	2026-11-22 09:12:40.824
6ea04289-f0f6-43b5-93e3-94546db7084d	0579580b-0d74-488f-9878-c209546a5c2e	USER_REGISTERED	User	0579580b-0d74-488f-9878-c209546a5c2e	{"role": "MECHANIC", "email": "audit.mechanic.1795338760217@vbrs.local"}	\N	\N	2026-11-22 09:12:41.082
f843bb27-1ca0-4c09-86c5-229d654eaef9	8be98a6e-8e34-4741-8dbc-8105dd3d6b2d	USER_LOGGED_IN	User	8be98a6e-8e34-4741-8dbc-8105dd3d6b2d	\N	\N	\N	2026-11-22 09:12:41.087
f70122a3-b1e5-4914-a9b8-40a2748daed0	df30359f-fb78-4f77-8c18-936d3d870d43	USER_LOGGED_IN	User	df30359f-fb78-4f77-8c18-936d3d870d43	\N	\N	\N	2026-11-22 09:12:41.328
dfe70cb8-ca2a-4c23-b2c9-c5f426f6df79	8be98a6e-8e34-4741-8dbc-8105dd3d6b2d	VEHICLE_ADDED	Vehicle	8c337149-8686-4794-a822-45b6a78ebbb8	{"make": "Ford", "model": "Mustang Mach-E", "plate": "M2-1357"}	\N	\N	2026-11-22 09:12:41.369
ee476ab3-7925-43b7-a9ca-ab1e15712048	8be98a6e-8e34-4741-8dbc-8105dd3d6b2d	VEHICLE_UPDATED	Vehicle	8c337149-8686-4794-a822-45b6a78ebbb8	\N	\N	\N	2026-11-22 09:12:41.411
b35f1587-832a-4e3c-bcb0-05c88fedc507	8be98a6e-8e34-4741-8dbc-8105dd3d6b2d	VEHICLE_DELETED	Vehicle	8c337149-8686-4794-a822-45b6a78ebbb8	{"plate": "M2-1357"}	\N	\N	2026-11-22 09:12:41.438
4386d443-c08f-483b-9667-a5d876c8a04a	8be98a6e-8e34-4741-8dbc-8105dd3d6b2d	USER_LOGGED_OUT	User	8be98a6e-8e34-4741-8dbc-8105dd3d6b2d	\N	\N	\N	2026-11-22 09:12:41.461
436cfe0c-6bcb-4ac5-9ca7-3b52ffcd608f	0579580b-0d74-488f-9878-c209546a5c2e	USER_LOGGED_IN	User	0579580b-0d74-488f-9878-c209546a5c2e	\N	\N	\N	2026-11-22 09:12:41.579
80567aa0-770a-4af3-ae53-b5a6cb21bff2	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 09:12:41.819
964433ea-6339-4115-b9d7-b18040591be0	5832bba9-40a1-44a9-b92f-c1fd04bfdcf0	USER_REGISTERED	User	5832bba9-40a1-44a9-b92f-c1fd04bfdcf0	{"role": "CUSTOMER", "email": "audit.userb.1795338760217@vbrs.local"}	\N	\N	2026-11-22 09:12:42.299
ba9e5af2-bb67-4981-8fa8-55eb57326ecc	df30359f-fb78-4f77-8c18-936d3d870d43	VEHICLE_ADDED	Vehicle	0e11971c-29fa-4ba7-aac2-e30d97e89f03	{"make": "Porsche", "model": "Taycan GTS", "plate": "AUD-0218"}	\N	\N	2026-11-22 09:12:42.817
3ee3b308-a53f-4224-9e39-f4800a7675fe	df30359f-fb78-4f77-8c18-936d3d870d43	VEHICLE_UPDATED	Vehicle	0e11971c-29fa-4ba7-aac2-e30d97e89f03	\N	\N	\N	2026-11-22 09:12:42.839
6264e0bf-0b8c-4672-bcd6-b3ef81091887	df30359f-fb78-4f77-8c18-936d3d870d43	VEHICLE_DELETED	Vehicle	0e11971c-29fa-4ba7-aac2-e30d97e89f03	{"plate": "AUD-0218"}	\N	\N	2026-11-22 09:12:42.864
d95598b6-7523-4b43-afd1-837d5de403bd	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 09:13:04.769
9e916432-5ff8-454e-9e89-80fe8ee60d0f	e22478b0-00a4-44f8-b146-3649213c7a20	VEHICLE_ADDED	Vehicle	eb63566c-d19a-4aa5-b1bd-298754098342	{"make": "Audi", "model": "RS6 Avant", "plate": "E2E-6330"}	\N	\N	2026-11-22 09:13:06.383
59b5a6ae-531a-4725-bb3a-4fd076d6d9b2	50d7979c-85db-4cec-8bb2-83ba29ebae7d	USER_REGISTERED	User	50d7979c-85db-4cec-8bb2-83ba29ebae7d	{"role": "CUSTOMER", "email": "m3.customer.1795339272444@vbrs.local"}	\N	\N	2026-11-22 09:21:12.805
50f44723-1d45-4083-b0fc-00f0dcee814a	3bde293e-b15a-438f-82ca-84c742dd02d3	USER_REGISTERED	User	3bde293e-b15a-438f-82ca-84c742dd02d3	{"role": "CUSTOMER", "email": "m3.userb.1795339272444@vbrs.local"}	\N	\N	2026-11-22 09:21:13.062
1f8c7a95-f7eb-42d5-a8c2-b05531ae8f12	d47dec16-a57d-46ee-b2e9-8e7b594fae34	USER_LOGGED_IN	User	d47dec16-a57d-46ee-b2e9-8e7b594fae34	\N	\N	\N	2026-11-22 09:45:41.162
f11a8319-f0d1-4f8b-bda2-b7fde43d30a7	50d7979c-85db-4cec-8bb2-83ba29ebae7d	BREAKDOWN_REPORT_CREATED	BreakdownReport	12b94b32-a715-4095-b318-74fecceaf452	{"category": "ENGINE_FAILURE", "severity": "CRITICAL", "imageCount": 1, "requiresTowing": true}	\N	\N	2026-11-22 09:21:13.126
bd3fd700-9a49-4271-97da-2d149bdb6d55	50d7979c-85db-4cec-8bb2-83ba29ebae7d	BREAKDOWN_REPORT_CREATED	BreakdownReport	0a6ec4bc-6c69-41a4-8c12-16da50b7eed2	{"category": "FLAT_TIRE_WHEEL", "severity": "LOW", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 09:21:13.149
760d5f0f-9d0a-4e78-98eb-70f662ecda16	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 09:26:49.897
27c27559-c0ee-4041-91a6-a0601f046613	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	96554164-ec44-4988-80f1-01ab3b1c79d1	{"category": "TRANSMISSION_ISSUE", "severity": "CRITICAL", "imageCount": 1, "requiresTowing": true}	\N	\N	2026-11-22 09:26:53.364
d4438d87-1432-49ac-8904-673261d147af	15a87756-ecb4-4394-8fb7-5555263f9a09	USER_REGISTERED	User	15a87756-ecb4-4394-8fb7-5555263f9a09	{"role": "CUSTOMER", "email": "m3.customer.1795339630618@vbrs.local"}	\N	\N	2026-11-22 09:27:10.947
a4413c2e-6f23-4f2b-b0a9-a8aa99967c03	788ef40a-1c70-448f-9ebf-8d36ef3884e0	USER_REGISTERED	User	788ef40a-1c70-448f-9ebf-8d36ef3884e0	{"role": "CUSTOMER", "email": "m3.userb.1795339630618@vbrs.local"}	\N	\N	2026-11-22 09:27:11.198
c22ed008-477f-4a5d-ad00-18692cf6a2f4	15a87756-ecb4-4394-8fb7-5555263f9a09	BREAKDOWN_REPORT_CREATED	BreakdownReport	05799f42-cd9e-47cd-98b6-59f318ec06a2	{"category": "ENGINE_FAILURE", "severity": "CRITICAL", "imageCount": 1, "requiresTowing": true}	\N	\N	2026-11-22 09:27:11.261
d9cfd804-af3d-4458-8463-fe0eb2c104ed	15a87756-ecb4-4394-8fb7-5555263f9a09	BREAKDOWN_REPORT_CREATED	BreakdownReport	7a88dee1-d1a2-4e53-94f5-40d9b4416e45	{"category": "FLAT_TIRE_WHEEL", "severity": "LOW", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 09:27:11.288
7043a9bc-6f69-40c9-890a-96853393f83c	77d18c5b-d7f6-4a88-8a79-9d96d9c45dc3	USER_REGISTERED	User	77d18c5b-d7f6-4a88-8a79-9d96d9c45dc3	{"role": "CUSTOMER", "email": "m2.customer.1795339631299@vbrs.local"}	\N	\N	2026-11-22 09:27:11.648
5e9f638b-9f21-4630-93b5-b69121d5db94	99327fc9-e815-4c83-aeb3-6c3616c22e99	USER_REGISTERED	User	99327fc9-e815-4c83-aeb3-6c3616c22e99	{"role": "CUSTOMER", "email": "audit.customer.1795339631397@vbrs.local"}	\N	\N	2026-11-22 09:27:11.735
5afb8e08-5f44-4e01-bab7-43cc57be0229	77d18c5b-d7f6-4a88-8a79-9d96d9c45dc3	USER_LOGGED_IN	User	77d18c5b-d7f6-4a88-8a79-9d96d9c45dc3	\N	\N	\N	2026-11-22 09:27:11.909
b9afb28f-9f33-41b7-a156-dd8faabea7ad	abe634c7-837c-4fc9-8d62-af59c97d8fd7	USER_REGISTERED	User	abe634c7-837c-4fc9-8d62-af59c97d8fd7	{"role": "MECHANIC", "email": "audit.mechanic.1795339631397@vbrs.local"}	\N	\N	2026-11-22 09:27:11.993
e32ca425-6441-4ebc-ab1e-f50bbfb3dca4	77d18c5b-d7f6-4a88-8a79-9d96d9c45dc3	VEHICLE_ADDED	Vehicle	a92a6cc8-3b41-4748-a8e1-e4e9a4c637cb	{"make": "Ford", "model": "Mustang Mach-E", "plate": "M2-2172"}	\N	\N	2026-11-22 09:27:12.187
5696a44a-422c-409d-9256-9c73c8e39cde	77d18c5b-d7f6-4a88-8a79-9d96d9c45dc3	VEHICLE_UPDATED	Vehicle	a92a6cc8-3b41-4748-a8e1-e4e9a4c637cb	\N	\N	\N	2026-11-22 09:27:12.221
f1d7dae5-e1f3-4d66-ac2c-9b6df5ffe208	99327fc9-e815-4c83-aeb3-6c3616c22e99	USER_LOGGED_IN	User	99327fc9-e815-4c83-aeb3-6c3616c22e99	\N	\N	\N	2026-11-22 09:27:12.237
7f700eec-3fd4-483d-bde9-c2ea45450c9d	77d18c5b-d7f6-4a88-8a79-9d96d9c45dc3	VEHICLE_DELETED	Vehicle	a92a6cc8-3b41-4748-a8e1-e4e9a4c637cb	{"plate": "M2-2172"}	\N	\N	2026-11-22 09:27:12.244
b1204ed2-8410-40da-a23f-ef4eee185192	77d18c5b-d7f6-4a88-8a79-9d96d9c45dc3	USER_LOGGED_OUT	User	77d18c5b-d7f6-4a88-8a79-9d96d9c45dc3	\N	\N	\N	2026-11-22 09:27:12.26
ae874249-5842-4595-bf9b-5deb119f23da	abe634c7-837c-4fc9-8d62-af59c97d8fd7	USER_LOGGED_IN	User	abe634c7-837c-4fc9-8d62-af59c97d8fd7	\N	\N	\N	2026-11-22 09:27:12.469
87bbf177-7a5f-46bc-8334-1788ded08591	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 09:27:12.718
f25276be-cc29-49f4-bf14-0d3aa404ab6d	f652e135-854d-4680-9b11-2e96bdc6eda4	USER_REGISTERED	User	f652e135-854d-4680-9b11-2e96bdc6eda4	{"role": "CUSTOMER", "email": "audit.userb.1795339631397@vbrs.local"}	\N	\N	2026-11-22 09:27:13.197
b5833164-26b1-4985-aecc-4ac0750caf2f	99327fc9-e815-4c83-aeb3-6c3616c22e99	VEHICLE_ADDED	Vehicle	5a0f388c-08f7-44c4-8db6-055f2e3e64c7	{"make": "Porsche", "model": "Taycan GTS", "plate": "AUD-1398"}	\N	\N	2026-11-22 09:27:13.711
11b68dbc-7d26-4952-8e1b-9df47e079350	99327fc9-e815-4c83-aeb3-6c3616c22e99	VEHICLE_UPDATED	Vehicle	5a0f388c-08f7-44c4-8db6-055f2e3e64c7	\N	\N	\N	2026-11-22 09:27:13.733
e5027c2e-20fa-46c2-936d-76eba887f562	99327fc9-e815-4c83-aeb3-6c3616c22e99	VEHICLE_DELETED	Vehicle	5a0f388c-08f7-44c4-8db6-055f2e3e64c7	{"plate": "AUD-1398"}	\N	\N	2026-11-22 09:27:13.759
5662e82e-5c33-4d66-a89b-a9c498ce11da	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 09:27:33.913
43a37eec-92f1-4d88-b770-a7123c14a2be	e22478b0-00a4-44f8-b146-3649213c7a20	VEHICLE_ADDED	Vehicle	a82b0cca-e4c8-44b8-9e22-674f048ed5e0	{"make": "Audi", "model": "RS6 Avant", "plate": "E2E-5487"}	\N	\N	2026-11-22 09:27:35.55
0176b1a8-56a3-4031-ba7e-3ec78e156f76	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 09:27:44.159
1356bab4-12dc-4fe3-83aa-807c9a5f3cc8	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	4b1cbadd-3c17-469f-9e59-9fa9f8caeddf	{"category": "TRANSMISSION_ISSUE", "severity": "CRITICAL", "imageCount": 1, "requiresTowing": true}	\N	\N	2026-11-22 09:27:47.83
93aab9d1-1007-41b9-a17b-a9ee938fd1d5	a1479806-db8e-432b-a61a-04b1494faf85	VEHICLE_ADDED	Vehicle	ace1cb6e-1e74-4c0d-84df-622d529c8a5e	{"make": "bmw", "model": "m4", "plate": "TS28 U0056"}	\N	\N	2026-11-22 09:33:51.494
a8829160-4e9e-48a8-a535-b43c64473e99	a1479806-db8e-432b-a61a-04b1494faf85	BREAKDOWN_REPORT_CREATED	BreakdownReport	1a3bbc18-ad93-4373-bb4b-85764d9fdf5f	{"category": "ENGINE_FAILURE", "severity": "CRITICAL", "imageCount": 1, "requiresTowing": true}	\N	\N	2026-11-22 09:34:49.185
5f5b3e27-d355-486c-a077-4413fc81252f	baf36b48-83b6-4d2a-acaf-1145a539c456	USER_REGISTERED	User	baf36b48-83b6-4d2a-acaf-1145a539c456	{"role": "CUSTOMER", "email": "m3.edge.custa.1795340650638@vbrs.local"}	\N	\N	2026-11-22 09:44:11.161
dfc84d49-0381-440c-8718-c3bcbe0f5817	4ddd4a39-70fa-42ed-bfbb-f2c557e01ec5	USER_REGISTERED	User	4ddd4a39-70fa-42ed-bfbb-f2c557e01ec5	{"role": "CUSTOMER", "email": "m3.edge.custb.1795340650638@vbrs.local"}	\N	\N	2026-11-22 09:44:11.572
f8facbf8-ebd4-4792-a590-166ff8813878	c7966587-138d-4fb6-a6d9-b638c3646f4c	USER_REGISTERED	User	c7966587-138d-4fb6-a6d9-b638c3646f4c	{"role": "MECHANIC", "email": "m3.edge.mech.1795340650638@vbrs.local"}	\N	\N	2026-11-22 09:44:11.953
188f0b91-cee2-446d-86a6-c0c5c567de29	baf36b48-83b6-4d2a-acaf-1145a539c456	VEHICLE_ADDED	Vehicle	685d419d-2e68-4907-95d5-1bdec89b7325	{"make": "Porsche", "model": "911 GT3", "plate": "EDGE-A-1961"}	\N	\N	2026-11-22 09:44:11.981
ded547cf-8afd-4f4b-a4a8-83ef61b5d155	4ddd4a39-70fa-42ed-bfbb-f2c557e01ec5	VEHICLE_ADDED	Vehicle	47edc19b-e82a-4bc5-8279-65bac299b3f0	{"make": "Tesla", "model": "Model S Plaid", "plate": "EDGE-B-1985"}	\N	\N	2026-11-22 09:44:11.997
e70de64b-285a-4022-8c48-0f2a17d792bb	baf36b48-83b6-4d2a-acaf-1145a539c456	BREAKDOWN_REPORT_CREATED	BreakdownReport	f76e9070-3aba-4f3a-9e33-ac94e6faf02a	{"category": "COLLISION_ACCIDENT", "severity": "CRITICAL", "imageCount": 5, "requiresTowing": true}	\N	\N	2026-11-22 09:44:12.108
86d0632a-cf9f-43f6-9c90-6255409c9167	baf36b48-83b6-4d2a-acaf-1145a539c456	BREAKDOWN_REPORT_CREATED	BreakdownReport	4a2c7d09-7c83-448d-98a0-23054976798f	{"category": "BRAKE_SYSTEM_FAILURE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 09:44:12.181
18293f30-8733-4ec0-bf48-21bfce8b5e36	baf36b48-83b6-4d2a-acaf-1145a539c456	BREAKDOWN_REPORT_CREATED	BreakdownReport	ad9b7940-13bd-440f-8757-71e7b294e60b	{"category": "BATTERY_DEAD_ELECTRICAL", "severity": "MEDIUM", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 09:44:12.213
fb56e60f-7d7b-459b-afcf-30d456622fec	baf36b48-83b6-4d2a-acaf-1145a539c456	BREAKDOWN_REPORT_CREATED	BreakdownReport	c37150a4-c1a3-4e50-98f6-69c74acc7660	{"category": "TRANSMISSION_ISSUE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 09:44:12.239
3726d151-159d-4016-a39a-7d38130af1cb	baf36b48-83b6-4d2a-acaf-1145a539c456	BREAKDOWN_REPORT_CREATED	BreakdownReport	32b617aa-ebc7-47e0-af57-bd79e34f9620	{"category": "FUEL_EMPTY_OR_CONTAMINATED", "severity": "LOW", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 09:44:12.283
c44984a3-53c3-45c2-b8c4-9c812845e209	baf36b48-83b6-4d2a-acaf-1145a539c456	BREAKDOWN_REPORT_CREATED	BreakdownReport	2089cf9c-dcc4-419d-8c04-6196c3a0c4cd	{"category": "OVERHEATING_COOLANT", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 09:44:12.301
e1b60ed4-00aa-4604-9940-db118162d6ef	baf36b48-83b6-4d2a-acaf-1145a539c456	BREAKDOWN_REPORT_CREATED	BreakdownReport	6233d50b-9428-4f6c-817d-46adf7739b55	{"category": "LOCKOUT_KEY_LOST", "severity": "LOW", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 09:44:12.343
e56de303-6d27-490d-8692-189097c5de27	19b6e30e-7ab8-4db5-87e5-443815e3d455	USER_REGISTERED	User	19b6e30e-7ab8-4db5-87e5-443815e3d455	{"role": "CUSTOMER", "email": "m3.edge.custa.1795340704618@vbrs.local"}	\N	\N	2026-11-22 09:45:05.14
4929263e-bd6d-4bef-acb9-4962ea5db1b4	30d6feea-b385-4632-bdf1-274829eada18	USER_REGISTERED	User	30d6feea-b385-4632-bdf1-274829eada18	{"role": "CUSTOMER", "email": "m3.edge.custb.1795340704618@vbrs.local"}	\N	\N	2026-11-22 09:45:05.512
67a18fff-16bf-4ccd-a157-3ceb3fd03734	29b31365-442a-4af5-9665-541885e6c2ad	USER_REGISTERED	User	29b31365-442a-4af5-9665-541885e6c2ad	{"role": "MECHANIC", "email": "m3.edge.mech.1795340704618@vbrs.local"}	\N	\N	2026-11-22 09:45:05.871
0c93b37f-8011-4f6f-8509-db5f28bb17ff	19b6e30e-7ab8-4db5-87e5-443815e3d455	VEHICLE_ADDED	Vehicle	42b6160d-d5c3-499b-9f7a-54cc3b72dedb	{"make": "Porsche", "model": "911 GT3", "plate": "EDGE-A-5879"}	\N	\N	2026-11-22 09:45:05.899
894c4239-048d-4c19-aa40-25b8bfaf6cf8	30d6feea-b385-4632-bdf1-274829eada18	VEHICLE_ADDED	Vehicle	ff595932-c126-4ad4-b710-54ac968b0da7	{"make": "Tesla", "model": "Model S Plaid", "plate": "EDGE-B-5902"}	\N	\N	2026-11-22 09:45:05.915
eb1ef033-d8db-47f2-9560-a6b7dbbdf82b	19b6e30e-7ab8-4db5-87e5-443815e3d455	BREAKDOWN_REPORT_CREATED	BreakdownReport	fa67a7ad-7e89-43f7-80fd-99f58a73a552	{"category": "COLLISION_ACCIDENT", "severity": "CRITICAL", "imageCount": 5, "requiresTowing": true}	\N	\N	2026-11-22 09:45:06.028
db5ccaa1-1f0d-425f-9ce9-858a98769bdd	19b6e30e-7ab8-4db5-87e5-443815e3d455	BREAKDOWN_REPORT_CREATED	BreakdownReport	3a7e419c-1ce3-4144-b326-0170d6e45376	{"category": "BRAKE_SYSTEM_FAILURE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 09:45:06.105
d882bb33-377d-4593-a1e6-db8f4ffd65e0	19b6e30e-7ab8-4db5-87e5-443815e3d455	BREAKDOWN_REPORT_CREATED	BreakdownReport	c44d9de9-e220-471a-a660-f9e9889172e6	{"category": "BATTERY_DEAD_ELECTRICAL", "severity": "MEDIUM", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 09:45:06.141
9e3d01d8-8a39-4832-8216-88322b013607	19b6e30e-7ab8-4db5-87e5-443815e3d455	BREAKDOWN_REPORT_CREATED	BreakdownReport	674595de-9258-485b-b45d-77d2ecee5127	{"category": "TRANSMISSION_ISSUE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 09:45:06.17
d4cabbf6-a8fa-4d10-80bf-c9ec62cb120b	19b6e30e-7ab8-4db5-87e5-443815e3d455	BREAKDOWN_REPORT_CREATED	BreakdownReport	0291a50b-a345-4dd0-acf0-3bf5a8db0ee9	{"category": "FUEL_EMPTY_OR_CONTAMINATED", "severity": "LOW", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 09:45:06.21
e87cfe8f-e37a-4623-8ff3-6659e0978c78	19b6e30e-7ab8-4db5-87e5-443815e3d455	BREAKDOWN_REPORT_CREATED	BreakdownReport	5fa41250-ea00-41e9-abd0-04429f937a1d	{"category": "OVERHEATING_COOLANT", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 09:45:06.229
6e73a29d-124c-44dc-8503-99f92891d89a	19b6e30e-7ab8-4db5-87e5-443815e3d455	BREAKDOWN_REPORT_CREATED	BreakdownReport	c9c2db7a-0402-4007-938b-022ab3b4fefe	{"category": "LOCKOUT_KEY_LOST", "severity": "LOW", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 09:45:06.276
2de623db-eabf-4f7c-83d4-34f9d926b519	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 09:45:18.863
bd4c145f-e508-46a0-abec-f4c96ee3a976	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	c2c45bd0-744a-4cfc-8f98-da75dbaa6856	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 09:45:23.481
7130acee-5a5f-4754-b121-c77d7c080670	277153e2-5d4b-4efb-8456-e5e9a3e56241	USER_REGISTERED	User	277153e2-5d4b-4efb-8456-e5e9a3e56241	{"role": "CUSTOMER", "email": "m2.customer.1795340739608@vbrs.local"}	\N	\N	2026-11-22 09:45:40.224
a2dcf0b3-92e8-45a1-819e-853e398ca726	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	USER_REGISTERED	User	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	{"role": "CUSTOMER", "email": "m3.edge.custa.1795340739651@vbrs.local"}	\N	\N	2026-11-22 09:45:40.239
2b7505d7-9b84-4bb0-9459-403f3e1c6fb2	436d667c-cc9f-4294-b2c9-cc95e0cb3d7e	USER_REGISTERED	User	436d667c-cc9f-4294-b2c9-cc95e0cb3d7e	{"role": "CUSTOMER", "email": "m3.customer.1795340739721@vbrs.local"}	\N	\N	2026-11-22 09:45:40.278
d9d1528e-7fdb-413e-a69a-a19c5eab3538	d47dec16-a57d-46ee-b2e9-8e7b594fae34	USER_REGISTERED	User	d47dec16-a57d-46ee-b2e9-8e7b594fae34	{"role": "CUSTOMER", "email": "audit.customer.1795340739717@vbrs.local"}	\N	\N	2026-11-22 09:45:40.294
12ad4174-4c1b-4938-b86c-67454d3af689	d76fafdd-5428-40c5-8632-142aab1c5539	USER_REGISTERED	User	d76fafdd-5428-40c5-8632-142aab1c5539	{"role": "CUSTOMER", "email": "m3.userb.1795340739721@vbrs.local"}	\N	\N	2026-11-22 09:45:40.694
1e49ae10-b47f-4809-a505-13d5e19f8695	86ac2e5d-4c47-4b60-900b-7d610ad1cdd0	USER_REGISTERED	User	86ac2e5d-4c47-4b60-900b-7d610ad1cdd0	{"role": "CUSTOMER", "email": "m3.edge.custb.1795340739651@vbrs.local"}	\N	\N	2026-11-22 09:45:40.706
072dcbdc-b1b5-43dd-824c-14a864a72496	277153e2-5d4b-4efb-8456-e5e9a3e56241	USER_LOGGED_IN	User	277153e2-5d4b-4efb-8456-e5e9a3e56241	\N	\N	\N	2026-11-22 09:45:40.715
9d346069-6482-45aa-9789-a3905cfe3eb4	2eca2933-96e6-4fa7-bda8-a1d0479de90c	USER_REGISTERED	User	2eca2933-96e6-4fa7-bda8-a1d0479de90c	{"role": "MECHANIC", "email": "audit.mechanic.1795340739717@vbrs.local"}	\N	\N	2026-11-22 09:45:40.726
507d825e-3941-44e7-9201-82f25de81332	436d667c-cc9f-4294-b2c9-cc95e0cb3d7e	BREAKDOWN_REPORT_CREATED	BreakdownReport	cc327a2e-8c33-412e-929c-92310140ca49	{"category": "ENGINE_FAILURE", "severity": "CRITICAL", "imageCount": 1, "requiresTowing": true}	\N	\N	2026-11-22 09:45:40.768
36ced984-a6ce-431c-afb3-cf420318329e	436d667c-cc9f-4294-b2c9-cc95e0cb3d7e	BREAKDOWN_REPORT_CREATED	BreakdownReport	e036aab4-73c2-4e0e-9747-23dc5a2f4c85	{"category": "FLAT_TIRE_WHEEL", "severity": "LOW", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 09:45:40.804
34eaaa0f-4ac6-4450-b1a8-eb123d1cb605	ebf4e83b-ea5a-4e92-bf15-8c58e0b49d3b	USER_REGISTERED	User	ebf4e83b-ea5a-4e92-bf15-8c58e0b49d3b	{"role": "MECHANIC", "email": "m3.edge.mech.1795340739651@vbrs.local"}	\N	\N	2026-11-22 09:45:41.134
29769490-aa40-403c-b34c-ab7b32383372	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	VEHICLE_ADDED	Vehicle	3f0353ea-4192-4114-b623-1d63f46b7b14	{"make": "Porsche", "model": "911 GT3", "plate": "EDGE-A-1144"}	\N	\N	2026-11-22 09:45:41.166
394aa908-227b-4ffd-838f-e5f23776f760	86ac2e5d-4c47-4b60-900b-7d610ad1cdd0	VEHICLE_ADDED	Vehicle	569bba46-825f-46dc-b372-00fb0320fa05	{"make": "Tesla", "model": "Model S Plaid", "plate": "EDGE-B-1171"}	\N	\N	2026-11-22 09:45:41.184
4d43922b-82b3-41d8-b9d2-2228acad9c53	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	BREAKDOWN_REPORT_CREATED	BreakdownReport	5a8686f4-daa6-49c0-b823-5a8638ebe9be	{"category": "COLLISION_ACCIDENT", "severity": "CRITICAL", "imageCount": 5, "requiresTowing": true}	\N	\N	2026-11-22 09:45:41.316
94234610-4ff0-4e1b-87b2-7c05f230fdae	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	BREAKDOWN_REPORT_CREATED	BreakdownReport	587fdbe5-1a1b-428c-b115-56f9e2f8a082	{"category": "BRAKE_SYSTEM_FAILURE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 09:45:41.387
7175eca4-ed23-45a1-b118-133745d1c470	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	BREAKDOWN_REPORT_CREATED	BreakdownReport	1908a4f7-7d10-4220-b719-a210724204b4	{"category": "BATTERY_DEAD_ELECTRICAL", "severity": "MEDIUM", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 09:45:41.424
25d7e0d5-9bc1-40d0-841e-c76e5264005d	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	BREAKDOWN_REPORT_CREATED	BreakdownReport	4ab03dd0-a9f5-4e79-98b3-4836fec17438	{"category": "TRANSMISSION_ISSUE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 09:45:41.45
e63f5326-9486-448d-988e-d4aa4d5b8eb8	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	BREAKDOWN_REPORT_CREATED	BreakdownReport	7c2217e1-09be-41f7-b5bb-34f267cf8522	{"category": "FUEL_EMPTY_OR_CONTAMINATED", "severity": "LOW", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 09:45:41.503
03b9ee8a-6c81-4005-aa21-1103dd7d838f	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	BREAKDOWN_REPORT_CREATED	BreakdownReport	8decfb7a-033e-455d-8aa0-e0e1ac809af7	{"category": "OVERHEATING_COOLANT", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 09:45:41.523
a9eb65ad-3ff4-4429-b29c-1e4b9c43deba	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	BREAKDOWN_REPORT_CREATED	BreakdownReport	06917a9a-af15-4b5d-b237-16c7ff920e25	{"category": "LOCKOUT_KEY_LOST", "severity": "LOW", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 09:45:41.568
4a1910a7-5015-471c-9809-296bb13f0cdc	277153e2-5d4b-4efb-8456-e5e9a3e56241	VEHICLE_ADDED	Vehicle	0cc544b4-ff21-467f-82de-8368a9af1cab	{"make": "Ford", "model": "Mustang Mach-E", "plate": "M2-1139"}	\N	\N	2026-11-22 09:45:41.156
27e7806e-df6e-4c68-ab2a-ab05cfd3398e	277153e2-5d4b-4efb-8456-e5e9a3e56241	VEHICLE_UPDATED	Vehicle	0cc544b4-ff21-467f-82de-8368a9af1cab	\N	\N	\N	2026-11-22 09:45:41.212
116774f2-3f9c-4629-a7e4-b9cef5ea04eb	277153e2-5d4b-4efb-8456-e5e9a3e56241	VEHICLE_DELETED	Vehicle	0cc544b4-ff21-467f-82de-8368a9af1cab	{"plate": "M2-1139"}	\N	\N	2026-11-22 09:45:41.245
687c4076-6424-495f-866a-5cce05ceab6e	277153e2-5d4b-4efb-8456-e5e9a3e56241	USER_LOGGED_OUT	User	277153e2-5d4b-4efb-8456-e5e9a3e56241	\N	\N	\N	2026-11-22 09:45:41.27
d6fcf664-a72a-45a8-9cac-479f5be88da4	2eca2933-96e6-4fa7-bda8-a1d0479de90c	USER_LOGGED_IN	User	2eca2933-96e6-4fa7-bda8-a1d0479de90c	\N	\N	\N	2026-11-22 09:45:41.546
81b8493d-6817-45c4-a025-0751da3fd44f	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 09:45:41.902
ffa387da-b6bb-4232-a84f-3ca6b8e98313	8aa2fb1e-2ce9-4b57-b38c-e182c0320226	USER_REGISTERED	User	8aa2fb1e-2ce9-4b57-b38c-e182c0320226	{"role": "CUSTOMER", "email": "audit.userb.1795340739717@vbrs.local"}	\N	\N	2026-11-22 09:45:42.643
047ebdc0-7f88-455d-9afd-4bff3d8398e6	d47dec16-a57d-46ee-b2e9-8e7b594fae34	VEHICLE_ADDED	Vehicle	77e398aa-1118-44e7-9763-d0f7cae07cd3	{"make": "Porsche", "model": "Taycan GTS", "plate": "AUD-9719"}	\N	\N	2026-11-22 09:45:43.424
cdc361a6-64e3-4d94-a28a-58c93e5662ca	d47dec16-a57d-46ee-b2e9-8e7b594fae34	VEHICLE_UPDATED	Vehicle	77e398aa-1118-44e7-9763-d0f7cae07cd3	\N	\N	\N	2026-11-22 09:45:43.453
0c81fce8-233f-4bcb-b872-9c94215945b0	d47dec16-a57d-46ee-b2e9-8e7b594fae34	VEHICLE_DELETED	Vehicle	77e398aa-1118-44e7-9763-d0f7cae07cd3	{"plate": "AUD-9719"}	\N	\N	2026-11-22 09:45:43.487
f369bb27-7ddd-4497-93f8-284d3c7d753c	8b3cfcfc-79bc-4fc5-b337-656b2fec774d	USER_REGISTERED	User	8b3cfcfc-79bc-4fc5-b337-656b2fec774d	{"role": "CUSTOMER", "email": "m4.customer.1795341515927@vbrs.local"}	\N	\N	2026-11-22 09:58:36.515
625b0fe8-5b2b-4023-bde7-de50aff9d9a8	23dfa73c-7d5b-46cb-a1f1-cfe57a65b3db	USER_REGISTERED	User	23dfa73c-7d5b-46cb-a1f1-cfe57a65b3db	{"role": "MECHANIC", "email": "m4.mech1.1795341515927@vbrs.local"}	\N	\N	2026-11-22 09:58:36.895
b71fa808-5a04-444c-b248-249545803891	babb78bc-8995-47e3-873b-d77a0c81a425	USER_REGISTERED	User	babb78bc-8995-47e3-873b-d77a0c81a425	{"role": "CUSTOMER", "email": "m4.customer.1795341571967@vbrs.local"}	\N	\N	2026-11-22 09:59:32.578
244224c9-22d4-4e54-a4b6-e057eef04d7d	838cdf88-b812-44c0-a890-3e53d54aafe1	USER_REGISTERED	User	838cdf88-b812-44c0-a890-3e53d54aafe1	{"role": "MECHANIC", "email": "m4.mech1.1795341571967@vbrs.local"}	\N	\N	2026-11-22 09:59:32.956
fe8ddebe-f608-43e8-907b-dbfcd4b7ad21	f69dd74f-2981-40af-9eea-5269a5fa8340	USER_REGISTERED	User	f69dd74f-2981-40af-9eea-5269a5fa8340	{"role": "MECHANIC", "email": "m4.mech2.1795341571967@vbrs.local"}	\N	\N	2026-11-22 09:59:33.33
8679fd5e-9f7a-4178-9a50-27b6684a1dae	babb78bc-8995-47e3-873b-d77a0c81a425	BREAKDOWN_REPORT_CREATED	BreakdownReport	a6fcd4c2-f7f3-430e-8150-212f49720f2c	{"category": "FLAT_TIRE_WHEEL", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 09:59:33.375
d0a975fc-a90c-4b3c-8a92-fcab8eaf18f5	838cdf88-b812-44c0-a890-3e53d54aafe1	DISPATCH_ACCEPTED	ServiceRequest	31fa8134-34e3-4836-859c-fe385f1765cd	{"mechanicId": "e11d2861-51e7-4f1b-9d3c-596ba5c6ba45", "breakdownReportId": "a6fcd4c2-f7f3-430e-8150-212f49720f2c"}	\N	\N	2026-11-22 09:59:33.643
d3c030f5-2ec3-47cc-bece-f90eba7b7af0	2dba2391-5f04-4a66-b103-d008daa1d7cb	USER_REGISTERED	User	2dba2391-5f04-4a66-b103-d008daa1d7cb	{"role": "CUSTOMER", "email": "m4.customer.1795341636004@vbrs.local"}	\N	\N	2026-11-22 10:00:36.39
851f1a68-f9c7-430d-8513-8bbb206b5b76	8aeefd6a-535e-4b26-9fb5-74c9ac6e26c3	USER_REGISTERED	User	8aeefd6a-535e-4b26-9fb5-74c9ac6e26c3	{"role": "MECHANIC", "email": "m4.mech1.1795341636004@vbrs.local"}	\N	\N	2026-11-22 10:00:36.648
0860135b-abd4-44e5-b346-4da63883593c	6d34d30f-9a1e-492c-9781-a28cf649ca03	USER_REGISTERED	User	6d34d30f-9a1e-492c-9781-a28cf649ca03	{"role": "MECHANIC", "email": "m4.mech2.1795341636004@vbrs.local"}	\N	\N	2026-11-22 10:00:36.895
f9bebb13-b0f1-4464-9793-49b1f42c3a26	2dba2391-5f04-4a66-b103-d008daa1d7cb	BREAKDOWN_REPORT_CREATED	BreakdownReport	f420ce28-fa3d-4497-96fc-b0b0659da2db	{"category": "FLAT_TIRE_WHEEL", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:00:36.928
e6f48d16-3193-4a3d-bc39-97e4cbe57bfe	8aeefd6a-535e-4b26-9fb5-74c9ac6e26c3	DISPATCH_ACCEPTED	ServiceRequest	8acc4416-3f99-494e-b1e0-382044a6306b	{"mechanicId": "f7c85961-11eb-4bd0-a43c-78717392496c", "breakdownReportId": "f420ce28-fa3d-4497-96fc-b0b0659da2db"}	\N	\N	2026-11-22 10:00:37.126
d374eb33-8d77-40d8-9878-7aaff5f3e892	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 10:03:47.593
2dcbc77b-91c9-47af-8676-609b03f70988	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	cdd78f8b-6821-4528-a0a0-5b29dab653ad	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:03:49.85
6d90919a-834c-41a1-9ea3-9977919dac04	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 10:03:50.863
528cb839-e1db-41ab-84ea-ba1ee0db0fa3	473401ce-0803-422f-8baa-a47de557f84e	DISPATCH_ACCEPTED	ServiceRequest	00069d2d-4e34-4455-b9be-83395dc1600c	{"mechanicId": "6a01cdea-a7ee-43e1-8a1f-77ecba9b0890", "breakdownReportId": "cdd78f8b-6821-4528-a0a0-5b29dab653ad"}	\N	\N	2026-11-22 10:03:56.817
3826120f-e7d2-47f1-96b1-b29bc2b82033	65531d90-d509-44d8-8c50-189197b32adf	USER_REGISTERED	User	65531d90-d509-44d8-8c50-189197b32adf	{"role": "CUSTOMER", "email": "m4.customer.1795341861470@vbrs.local"}	\N	\N	2026-11-22 10:04:22.16
c0e24db2-26fe-4b3d-b11f-6163b5081b8d	3508ead1-81a7-4452-a2f1-fd5599a1f576	USER_REGISTERED	User	3508ead1-81a7-4452-a2f1-fd5599a1f576	{"role": "MECHANIC", "email": "m4.mech1.1795341861470@vbrs.local"}	\N	\N	2026-11-22 10:04:22.625
06c1a331-315d-4562-8a9e-e10249769552	71be654d-8646-43a1-985d-0f9757ec84b7	USER_REGISTERED	User	71be654d-8646-43a1-985d-0f9757ec84b7	{"role": "MECHANIC", "email": "m4.mech2.1795341861470@vbrs.local"}	\N	\N	2026-11-22 10:04:23.067
51768738-caa0-4120-a7e9-bdf3e12dc73b	65531d90-d509-44d8-8c50-189197b32adf	BREAKDOWN_REPORT_CREATED	BreakdownReport	1f870c2e-ede8-4cd6-9f92-c796f2910793	{"category": "FLAT_TIRE_WHEEL", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:04:23.119
819bad23-7e6c-4ddc-bee7-1d902e2eea02	3508ead1-81a7-4452-a2f1-fd5599a1f576	DISPATCH_ACCEPTED	ServiceRequest	bf2db744-237c-4241-ad11-3ab3edd93f13	{"mechanicId": "e480aef5-fc43-4db6-bc14-a589c85cc159", "breakdownReportId": "1f870c2e-ede8-4cd6-9f92-c796f2910793"}	\N	\N	2026-11-22 10:04:23.427
f35204ee-2055-45c1-9123-25239ce43f9d	e7df7f99-0377-492f-baa6-1a71ef06d94b	USER_REGISTERED	User	e7df7f99-0377-492f-baa6-1a71ef06d94b	{"role": "CUSTOMER", "email": "m2.customer.1795341862987@vbrs.local"}	\N	\N	2026-11-22 10:04:23.719
82477255-c2f3-4466-9a84-2ce98ec0c756	4d0a14bc-7faa-4a5d-b04d-3f0d657598d4	USER_REGISTERED	User	4d0a14bc-7faa-4a5d-b04d-3f0d657598d4	{"role": "CUSTOMER", "email": "audit.customer.1795341863037@vbrs.local"}	\N	\N	2026-11-22 10:04:23.797
7d2087cb-4df3-4aea-8bca-505f7fa2e1f6	a9541389-845a-425d-9b38-1de039a56cdc	USER_REGISTERED	User	a9541389-845a-425d-9b38-1de039a56cdc	{"role": "CUSTOMER", "email": "m3.customer.1795341863165@vbrs.local"}	\N	\N	2026-11-22 10:04:23.878
33fd78c0-7ed1-4131-8b73-182c4e4ba287	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	USER_REGISTERED	User	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	{"role": "CUSTOMER", "email": "m3.edge.custa.1795341863222@vbrs.local"}	\N	\N	2026-11-22 10:04:23.916
480c3250-0b4c-4978-8162-d774bea47f0a	e7df7f99-0377-492f-baa6-1a71ef06d94b	USER_LOGGED_IN	User	e7df7f99-0377-492f-baa6-1a71ef06d94b	\N	\N	\N	2026-11-22 10:04:24.169
b33580dc-5c2a-497c-8dc3-cc5bac85d445	be6ce21c-27af-4c83-838d-9252f2ed8b52	USER_REGISTERED	User	be6ce21c-27af-4c83-838d-9252f2ed8b52	{"role": "MECHANIC", "email": "audit.mechanic.1795341863037@vbrs.local"}	\N	\N	2026-11-22 10:04:24.269
fe794ac4-f951-41b8-8d2e-340862b0fefc	4d0a14bc-7faa-4a5d-b04d-3f0d657598d4	USER_LOGGED_IN	User	4d0a14bc-7faa-4a5d-b04d-3f0d657598d4	\N	\N	\N	2026-11-22 10:04:24.696
fe86b0ff-81cb-462f-8102-f89c43084eb6	be6ce21c-27af-4c83-838d-9252f2ed8b52	USER_LOGGED_IN	User	be6ce21c-27af-4c83-838d-9252f2ed8b52	\N	\N	\N	2026-11-22 10:04:25.094
efba612f-2460-4c1f-bc6f-531e7209f589	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 10:04:25.473
4b20dcca-be98-4aa4-ad0e-a1c53ad79618	002fc4a3-6450-4661-8aac-be73b003405b	USER_REGISTERED	User	002fc4a3-6450-4661-8aac-be73b003405b	{"role": "CUSTOMER", "email": "audit.userb.1795341863037@vbrs.local"}	\N	\N	2026-11-22 10:04:26.226
25468901-8cc4-4d1b-87ea-fe940622a6f2	4d0a14bc-7faa-4a5d-b04d-3f0d657598d4	VEHICLE_ADDED	Vehicle	fedb3198-2c25-46d7-8c5b-7687732db014	{"make": "Porsche", "model": "Taycan GTS", "plate": "AUD-3039"}	\N	\N	2026-11-22 10:04:27.059
474aa031-253c-4a05-b1f0-72d7ba066c86	4d0a14bc-7faa-4a5d-b04d-3f0d657598d4	VEHICLE_UPDATED	Vehicle	fedb3198-2c25-46d7-8c5b-7687732db014	\N	\N	\N	2026-11-22 10:04:27.096
53338794-0124-4f70-a6cc-3df74934fa35	4d0a14bc-7faa-4a5d-b04d-3f0d657598d4	VEHICLE_DELETED	Vehicle	fedb3198-2c25-46d7-8c5b-7687732db014	{"plate": "AUD-3039"}	\N	\N	2026-11-22 10:04:27.141
fd222620-e399-4de4-bd66-c4e5f1dff4c9	abe608a6-40c5-47bc-98f9-709af459f3a5	USER_REGISTERED	User	abe608a6-40c5-47bc-98f9-709af459f3a5	{"role": "CUSTOMER", "email": "m3.userb.1795341863165@vbrs.local"}	\N	\N	2026-11-22 10:04:24.326
6e34aa5a-e965-4566-90aa-b88ed411b770	a9541389-845a-425d-9b38-1de039a56cdc	BREAKDOWN_REPORT_CREATED	BreakdownReport	2fd9cbd0-08a2-447d-9773-fc029b8a443f	{"category": "ENGINE_FAILURE", "severity": "CRITICAL", "imageCount": 1, "requiresTowing": true}	\N	\N	2026-11-22 10:04:24.414
99ef8185-1319-4fb9-a46f-ea9d6d0632e1	a9541389-845a-425d-9b38-1de039a56cdc	BREAKDOWN_REPORT_CREATED	BreakdownReport	53f67df2-b542-4764-a1b2-8b758f50f8c7	{"category": "FLAT_TIRE_WHEEL", "severity": "LOW", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:04:24.445
4e50d02b-f68c-42a4-9463-af60220a9577	6735a628-9f69-43e8-9647-4859b129ce73	USER_REGISTERED	User	6735a628-9f69-43e8-9647-4859b129ce73	{"role": "CUSTOMER", "email": "m3.edge.custb.1795341863222@vbrs.local"}	\N	\N	2026-11-22 10:04:24.351
e4ac59f8-4af0-4e64-8d61-bcd613a2f4e8	a40c3731-4a5e-4537-8dc4-3d81ed50c82e	USER_REGISTERED	User	a40c3731-4a5e-4537-8dc4-3d81ed50c82e	{"role": "MECHANIC", "email": "m3.edge.mech.1795341863222@vbrs.local"}	\N	\N	2026-11-22 10:04:24.811
55a36a20-3c18-4bc4-9cce-743f8eeddbca	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	VEHICLE_ADDED	Vehicle	32c6134f-d4c0-4950-a441-63335b7673b6	{"make": "Porsche", "model": "911 GT3", "plate": "EDGE-A-4817"}	\N	\N	2026-11-22 10:04:24.835
962a0b47-782f-49f8-8082-d79ffaadba9f	6735a628-9f69-43e8-9647-4859b129ce73	VEHICLE_ADDED	Vehicle	b731e180-9b03-4865-9bef-b3af744fc646	{"make": "Tesla", "model": "Model S Plaid", "plate": "EDGE-B-4837"}	\N	\N	2026-11-22 10:04:24.849
ccae8084-cbda-4e13-be7e-bf9543550093	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	BREAKDOWN_REPORT_CREATED	BreakdownReport	fc8dc4c5-ab5c-473d-bb51-22b9cc8d6dd5	{"category": "COLLISION_ACCIDENT", "severity": "CRITICAL", "imageCount": 5, "requiresTowing": true}	\N	\N	2026-11-22 10:04:24.966
b63df201-4951-4126-9128-10ed97ecf849	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	BREAKDOWN_REPORT_CREATED	BreakdownReport	9909c3eb-b894-449e-b6d5-2049b92f7175	{"category": "BRAKE_SYSTEM_FAILURE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 10:04:25.05
07a15cef-3987-47e7-a0f8-63fbdc44e25a	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	BREAKDOWN_REPORT_CREATED	BreakdownReport	a578c4ff-cee0-4946-af65-f559f4b9b6fa	{"category": "BATTERY_DEAD_ELECTRICAL", "severity": "MEDIUM", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 10:04:25.086
dc3edad8-0f71-4bff-a95b-29c7389cb4d1	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	BREAKDOWN_REPORT_CREATED	BreakdownReport	46bd39e8-861b-40d8-9cb7-cd6bc6b8e35e	{"category": "TRANSMISSION_ISSUE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 10:04:25.123
8d4ef25d-b34f-4fea-a37c-113e09e3cdc5	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	BREAKDOWN_REPORT_CREATED	BreakdownReport	a016f173-c441-45c4-9cf4-152f75c6e3d2	{"category": "FUEL_EMPTY_OR_CONTAMINATED", "severity": "LOW", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:04:25.169
f5daa21d-657b-423d-bc85-c64c8b559753	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	BREAKDOWN_REPORT_CREATED	BreakdownReport	885504d8-bd8d-4147-a152-c92ce24fc194	{"category": "OVERHEATING_COOLANT", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:04:25.194
3c04d2dc-d397-4ceb-9613-f9e3daf9576c	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	BREAKDOWN_REPORT_CREATED	BreakdownReport	29d41ded-c68e-4260-b27f-092c3fcc0597	{"category": "LOCKOUT_KEY_LOST", "severity": "LOW", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 10:04:25.241
2636bdb4-7c53-47eb-8ee0-ccd97df752fe	e7df7f99-0377-492f-baa6-1a71ef06d94b	VEHICLE_ADDED	Vehicle	04684a94-8562-44e2-a4a8-0816f26ae12c	{"make": "Ford", "model": "Mustang Mach-E", "plate": "M2-4625"}	\N	\N	2026-11-22 10:04:24.639
d13e5a32-01c4-4002-ae56-36d33ebf66c3	e7df7f99-0377-492f-baa6-1a71ef06d94b	VEHICLE_UPDATED	Vehicle	04684a94-8562-44e2-a4a8-0816f26ae12c	\N	\N	\N	2026-11-22 10:04:24.687
da1df3f2-a3f7-4b34-bd90-f07a339f7bc5	e7df7f99-0377-492f-baa6-1a71ef06d94b	VEHICLE_DELETED	Vehicle	04684a94-8562-44e2-a4a8-0816f26ae12c	{"plate": "M2-4625"}	\N	\N	2026-11-22 10:04:24.716
70c0b207-0f46-46b2-84b5-6fd734975c84	e7df7f99-0377-492f-baa6-1a71ef06d94b	USER_LOGGED_OUT	User	e7df7f99-0377-492f-baa6-1a71ef06d94b	\N	\N	\N	2026-11-22 10:04:24.734
b3be6cc8-b3b3-4f38-965b-d48f917dff16	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 10:04:52.825
9ae4c93b-37d1-4945-b149-6e8d769073d0	e22478b0-00a4-44f8-b146-3649213c7a20	VEHICLE_ADDED	Vehicle	ca62ec10-022d-4fa3-8897-11837507c603	{"make": "Audi", "model": "RS6 Avant", "plate": "E2E-4379"}	\N	\N	2026-11-22 10:04:54.443
5f878be0-fd39-4222-af51-6d1f2cb22865	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 10:05:03.608
6db017c8-28ac-4435-be53-59af90e320e1	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	a4d02411-9a89-44d9-b8e2-6da48e39119d	{"category": "TRANSMISSION_ISSUE", "severity": "CRITICAL", "imageCount": 1, "requiresTowing": true}	\N	\N	2026-11-22 10:05:07.18
f007ed2a-b47b-4ca9-8b60-2b6143b9d98e	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 10:05:09.658
aa202024-9efe-425c-a6ae-bc1253d51949	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	7982f72d-591b-4a2e-8878-75d20cf69880	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 10:05:14.522
89711b1d-2b82-407b-bd9f-7345c85bf91a	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 10:05:17.275
2603ba21-c717-470a-b058-264d9ecf0dce	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	82947b09-584a-4553-a16e-7cd456f98066	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:05:19.37
e6ffe8d8-d776-4738-8796-01827bbbd76c	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 10:05:20.285
01f49d12-1c6c-4b77-8f91-965c7ea230bc	a1479806-db8e-432b-a61a-04b1494faf85	BREAKDOWN_REPORT_CREATED	BreakdownReport	fdcf9966-eba5-43a9-b670-91bb394d61e6	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 10:05:52.275
b02a5258-a0e1-4642-819d-f150c51c9381	a1479806-db8e-432b-a61a-04b1494faf85	USER_LOGGED_OUT	User	a1479806-db8e-432b-a61a-04b1494faf85	\N	\N	\N	2026-11-22 10:06:07.441
97510e65-3144-44c1-a755-301b1c8f2fa4	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 10:06:23.46
11d7a40d-409f-4a4e-83b6-4fd1a3a003cc	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	f50dc5a4-d7b1-46eb-8cdd-51a606ded16b	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:06:25.763
8baa7634-0e06-433b-882b-f8d2cd96b9d3	a1479806-db8e-432b-a61a-04b1494faf85	USER_LOGGED_IN	User	a1479806-db8e-432b-a61a-04b1494faf85	\N	\N	\N	2026-11-22 10:06:25.897
176c3c28-276d-429c-ad3c-decebd57e0b0	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 10:06:27.29
c4fea736-b18b-4712-9879-7a445554279b	473401ce-0803-422f-8baa-a47de557f84e	DISPATCH_ACCEPTED	ServiceRequest	6e01dd2d-cb2a-4da0-bcfa-b132dac75733	{"mechanicId": "6a01cdea-a7ee-43e1-8a1f-77ecba9b0890", "breakdownReportId": "f50dc5a4-d7b1-46eb-8cdd-51a606ded16b"}	\N	\N	2026-11-22 10:06:34.283
6db66adc-601e-4b51-a383-35e5677d4f0d	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 10:06:56.244
786ce92f-611e-477c-afce-d798ec8107da	e22478b0-00a4-44f8-b146-3649213c7a20	VEHICLE_ADDED	Vehicle	68195c76-7a2f-4cef-9319-7a855f75455a	{"make": "Audi", "model": "RS6 Avant", "plate": "E2E-7797"}	\N	\N	2026-11-22 10:06:57.86
98f307d3-acad-4380-9d7b-bbdd39450e2c	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 10:07:07.005
e599fedb-f674-4ebb-833e-03304fb9caff	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	91c3a15d-1bf1-4abf-8431-29f025c4f750	{"category": "TRANSMISSION_ISSUE", "severity": "CRITICAL", "imageCount": 1, "requiresTowing": true}	\N	\N	2026-11-22 10:07:10.638
6d9aa4f5-aca9-41d0-9fef-ee9bfd91a5dc	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 10:07:13.025
2dd38b24-05be-4aac-b48c-5595257865e9	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	e3e49559-2c2a-4d4e-b8d8-0fb7975bacf1	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 10:07:17.83
32a11031-bdd2-4cd8-96dd-e59649f09d33	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 10:07:20.185
ffeac34f-500b-463b-9813-f1da7a8f6dd4	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	128efdcf-99ee-4e29-abb9-d7a0ac285072	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:07:22.445
0ab4c34c-f308-4426-9991-4139695912a7	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 10:07:23.295
3c51fa6d-40d2-4d31-854a-817b18e873bb	473401ce-0803-422f-8baa-a47de557f84e	DISPATCH_ACCEPTED	ServiceRequest	bb2ecca6-c686-44d1-8717-e22d5c7ac0eb	{"mechanicId": "6a01cdea-a7ee-43e1-8a1f-77ecba9b0890", "breakdownReportId": "128efdcf-99ee-4e29-abb9-d7a0ac285072"}	\N	\N	2026-11-22 10:07:30.367
4bb38ee7-a73a-48c7-a5ad-35631e32d987	a1479806-db8e-432b-a61a-04b1494faf85	USER_LOGGED_IN	User	a1479806-db8e-432b-a61a-04b1494faf85	\N	\N	\N	2026-11-22 10:09:43.5
c0db2b0e-8d00-4630-9368-f9ecfc06fc1d	a1479806-db8e-432b-a61a-04b1494faf85	USER_LOGGED_IN	User	a1479806-db8e-432b-a61a-04b1494faf85	\N	\N	\N	2026-11-22 10:11:10.045
1781050c-7b37-4092-9869-84f8b02d5dc8	a1479806-db8e-432b-a61a-04b1494faf85	BREAKDOWN_REPORT_CREATED	BreakdownReport	df37a324-4d01-4d94-a376-1d2a6d82fcc7	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:11:20.743
7cd61fcd-0c3d-4a9c-8b2c-7ac9f1694824	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 10:14:46.617
0348a35d-54b5-4ea7-8b0e-6b6868127a86	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	7556b623-3902-4eff-8a9a-4b3be77aa533	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:14:48.553
208466f4-ba8b-440f-be27-eb0644a07f16	20c92ae9-cda7-4be7-a444-d9ec67df8fbc	USER_LOGGED_IN	User	20c92ae9-cda7-4be7-a444-d9ec67df8fbc	\N	\N	\N	2026-11-22 10:14:48.9
6132e8bc-9349-4b42-ba8a-a3cc783103fc	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 10:14:49.737
6d655c02-b604-48b9-8905-70f834f788cf	20c92ae9-cda7-4be7-a444-d9ec67df8fbc	DISPATCH_ACCEPTED	ServiceRequest	cc46598d-dcfb-4c7d-a0e0-8870a7fce0a4	{"mechanicId": "26862790-bdc3-4714-aa48-5991f7550785", "breakdownReportId": "7556b623-3902-4eff-8a9a-4b3be77aa533"}	\N	\N	2026-11-22 10:14:54.232
eda1bf26-222b-4f1e-bdc8-d9c0528a92d3	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 10:16:18.891
403e9c6c-e43c-435b-aaf9-8fcb0e83f0a9	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	caef5174-7257-4164-a0c8-d5ca83b3ad21	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:16:21.173
f9f8f851-5ef6-4962-b576-fa6c50bf934b	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 10:16:22.102
88c1701d-1f3c-42ae-8687-fce50f09fd37	b492f8a7-29a4-4012-a173-bb1cf5135319	USER_REGISTERED	User	b492f8a7-29a4-4012-a173-bb1cf5135319	{"role": "CUSTOMER", "email": "m5.cust1.1795343229953@vbrs.local"}	\N	\N	2026-11-22 10:27:10.326
7895ad72-52dd-463c-9714-6fe1a54f21d2	7ec8d5ac-2f2c-4bee-a45c-cbe4db28152f	USER_REGISTERED	User	7ec8d5ac-2f2c-4bee-a45c-cbe4db28152f	{"role": "CUSTOMER", "email": "m5.cust2.1795343229953@vbrs.local"}	\N	\N	2026-11-22 10:27:10.573
83a66b8a-952c-4ee0-8746-9e0436eaeccd	b492f8a7-29a4-4012-a173-bb1cf5135319	BREAKDOWN_REPORT_CREATED	BreakdownReport	dda8d6a2-240d-4b27-b15f-54bcc9a5beba	{"category": "FLAT_TIRE_WHEEL", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:27:10.622
78115d3a-60b5-4e82-8987-6b00ced520b0	9ad0fc29-8daf-4688-925e-9fa71d6a2e80	USER_REGISTERED	User	9ad0fc29-8daf-4688-925e-9fa71d6a2e80	{"role": "CUSTOMER", "email": "m5.cust1.1795343253901@vbrs.local"}	\N	\N	2026-11-22 10:27:34.265
f72d4863-538a-459c-a15b-76f126800263	7090b34f-dafd-4c68-965c-71bb401de60d	USER_REGISTERED	User	7090b34f-dafd-4c68-965c-71bb401de60d	{"role": "CUSTOMER", "email": "m5.cust2.1795343253901@vbrs.local"}	\N	\N	2026-11-22 10:27:34.509
84420d97-cdbe-44a7-89cd-6dcf5c852bab	8ad6b40d-ab52-471f-b6dc-4dcc2d132efe	USER_REGISTERED	User	8ad6b40d-ab52-471f-b6dc-4dcc2d132efe	{"role": "MECHANIC", "email": "m5.mech1.1795343253901@vbrs.local"}	\N	\N	2026-11-22 10:27:34.752
3db28e22-0019-4040-ae1c-a4da9f5be317	99cb03ac-7b72-4f0c-bb2f-b153c954e67b	USER_REGISTERED	User	99cb03ac-7b72-4f0c-bb2f-b153c954e67b	{"role": "MECHANIC", "email": "m5.mech2.1795343253901@vbrs.local"}	\N	\N	2026-11-22 10:27:34.995
58594034-b5b5-43fe-a2db-6fb84de8582a	07e2bb34-05fe-462f-9b45-1ac77a36ee96	USER_REGISTERED	User	07e2bb34-05fe-462f-9b45-1ac77a36ee96	{"role": "ADMIN", "email": "m5.admin.1795343253901@vbrs.local"}	\N	\N	2026-11-22 10:27:35.227
5f20c742-90bc-4764-b56b-7c2310e87f5a	9ad0fc29-8daf-4688-925e-9fa71d6a2e80	BREAKDOWN_REPORT_CREATED	BreakdownReport	e672ae2d-233d-4c1f-a871-97933ebc0aeb	{"category": "ENGINE_FAILURE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 10:27:35.255
dfeaa0c8-1f43-4dcc-aeab-f686bfc67a6a	8ad6b40d-ab52-471f-b6dc-4dcc2d132efe	DISPATCH_ACCEPTED	ServiceRequest	3ff1ea13-607d-456a-a855-6218f6449202	{"mechanicId": "2bd8c6e5-44ca-4c80-a6bb-2ddc2b6fe55e", "breakdownReportId": "e672ae2d-233d-4c1f-a871-97933ebc0aeb"}	\N	\N	2026-11-22 10:27:35.283
caa03472-3264-4db4-a100-599c824915da	8ad6b40d-ab52-471f-b6dc-4dcc2d132efe	SERVICE_STATUS_EN_ROUTE	ServiceRequest	3ff1ea13-607d-456a-a855-6218f6449202	{"notes": "Technician departed garage; en route via arterial highway.", "toStatus": "EN_ROUTE", "fromStatus": "ACCEPTED"}	\N	\N	2026-11-22 10:27:35.385
bf771dac-e6a7-4567-a891-98da9c7997f7	8ad6b40d-ab52-471f-b6dc-4dcc2d132efe	SERVICE_STATUS_ARRIVED	ServiceRequest	3ff1ea13-607d-456a-a855-6218f6449202	{"notes": "Arrived at incident site; positioning emergency safety cones.", "toStatus": "ARRIVED", "fromStatus": "EN_ROUTE"}	\N	\N	2026-11-22 10:27:35.409
0d4b287c-d8e1-4cf4-a657-b9f63956f0a7	8ad6b40d-ab52-471f-b6dc-4dcc2d132efe	SERVICE_STATUS_IN_PROGRESS	ServiceRequest	3ff1ea13-607d-456a-a855-6218f6449202	{"notes": "Disassembled ignition harness; installing new OEM coils.", "toStatus": "IN_PROGRESS", "fromStatus": "ARRIVED"}	\N	\N	2026-11-22 10:27:35.535
79d0b7b7-c176-4a26-8739-43ed489d0f4d	8ad6b40d-ab52-471f-b6dc-4dcc2d132efe	SERVICE_STATUS_COMPLETED	ServiceRequest	3ff1ea13-607d-456a-a855-6218f6449202	{"toStatus": "COMPLETED", "fromStatus": "IN_PROGRESS"}	\N	\N	2026-11-22 10:27:35.56
8c967b06-7d3c-4f5c-b144-ad4313b5888c	9ad0fc29-8daf-4688-925e-9fa71d6a2e80	BREAKDOWN_REPORT_CREATED	BreakdownReport	8ff0aadf-81d0-4301-9924-e3a44262c18d	{"category": "FLAT_TIRE_WHEEL", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:27:35.605
8f0d76b4-e5a1-49b0-8635-015a5d011d9f	8ad6b40d-ab52-471f-b6dc-4dcc2d132efe	DISPATCH_ACCEPTED	ServiceRequest	5e172816-2bbd-40fa-8ab1-9681da002123	{"mechanicId": "2bd8c6e5-44ca-4c80-a6bb-2ddc2b6fe55e", "breakdownReportId": "8ff0aadf-81d0-4301-9924-e3a44262c18d"}	\N	\N	2026-11-22 10:27:35.624
50b510c9-1064-4201-bcd0-df22696b77cf	9ad0fc29-8daf-4688-925e-9fa71d6a2e80	SERVICE_STATUS_CANCELLED	ServiceRequest	5e172816-2bbd-40fa-8ab1-9681da002123	{"notes": "Cancellation reason: Spare tire located; vehicle changed independently.", "toStatus": "CANCELLED", "fromStatus": "ACCEPTED", "cancellationReason": "Spare tire located; vehicle changed independently."}	\N	\N	2026-11-22 10:27:35.643
3521bd40-9d54-46b8-baa3-5e7c1a93881d	201144dc-4d12-4765-8873-8573ebc70566	USER_REGISTERED	User	201144dc-4d12-4765-8873-8573ebc70566	{"role": "CUSTOMER", "email": "m5.cust1.1795343269323@vbrs.local"}	\N	\N	2026-11-22 10:27:49.757
854b9987-484a-4c72-aa01-1d25afe046e0	1b76c709-fd68-4cca-b699-3ce4793290d1	USER_REGISTERED	User	1b76c709-fd68-4cca-b699-3ce4793290d1	{"role": "CUSTOMER", "email": "m5.cust2.1795343269323@vbrs.local"}	\N	\N	2026-11-22 10:27:50.042
963089d8-adef-4d6c-a343-ee0186d8b5e2	58ea9816-d0a5-42ae-92d8-55f32ab1135f	USER_REGISTERED	User	58ea9816-d0a5-42ae-92d8-55f32ab1135f	{"role": "MECHANIC", "email": "m5.mech1.1795343269323@vbrs.local"}	\N	\N	2026-11-22 10:27:50.337
2e1bf8ba-2b0f-47bc-9891-def485e61649	020de9be-8c9a-4232-a522-39dfbf87cf9c	USER_REGISTERED	User	020de9be-8c9a-4232-a522-39dfbf87cf9c	{"role": "CUSTOMER", "email": "m4.customer.1795343270142@vbrs.local"}	\N	\N	2026-11-22 10:27:50.595
424c802d-9edc-4619-9d28-df7cf0304411	90810c7b-ed32-4e65-993f-2371c000eb9b	USER_REGISTERED	User	90810c7b-ed32-4e65-993f-2371c000eb9b	{"role": "MECHANIC", "email": "m5.mech2.1795343269323@vbrs.local"}	\N	\N	2026-11-22 10:27:50.602
3f399df3-53a6-4674-a6f1-b53728e240bd	3d1bfe42-4c49-425d-aa93-9f8e9c52b45f	USER_REGISTERED	User	3d1bfe42-4c49-425d-aa93-9f8e9c52b45f	{"role": "CUSTOMER", "email": "m2.customer.1795343270129@vbrs.local"}	\N	\N	2026-11-22 10:27:50.601
446d469a-a698-4bf0-9bfb-d2f776a9d5e2	4fb4b922-a2e7-4d24-9e81-1bae59ab792b	USER_REGISTERED	User	4fb4b922-a2e7-4d24-9e81-1bae59ab792b	{"role": "CUSTOMER", "email": "m3.customer.1795343270266@vbrs.local"}	\N	\N	2026-11-22 10:27:50.699
283526fa-4b01-425a-9fed-b19757faab8b	2453cf81-de2b-42e1-9cbd-394d92e735f6	USER_REGISTERED	User	2453cf81-de2b-42e1-9cbd-394d92e735f6	{"role": "CUSTOMER", "email": "audit.customer.1795343270278@vbrs.local"}	\N	\N	2026-11-22 10:27:50.719
31bb1ee8-ba62-4d2e-bb8b-c1a812584e7a	e05d0c61-e1ae-4921-8453-3dc06525dc08	USER_REGISTERED	User	e05d0c61-e1ae-4921-8453-3dc06525dc08	{"role": "CUSTOMER", "email": "m3.edge.custa.1795343270316@vbrs.local"}	\N	\N	2026-11-22 10:27:50.726
99bb9f73-d7c4-4904-bab8-b1f7a421d544	d2a30eee-6528-4896-97ac-c1b16dbcd28b	USER_REGISTERED	User	d2a30eee-6528-4896-97ac-c1b16dbcd28b	{"role": "ADMIN", "email": "m5.admin.1795343269323@vbrs.local"}	\N	\N	2026-11-22 10:27:50.846
eae4a116-dc31-46e1-8a22-84b9e5b45598	3d1bfe42-4c49-425d-aa93-9f8e9c52b45f	USER_LOGGED_IN	User	3d1bfe42-4c49-425d-aa93-9f8e9c52b45f	\N	\N	\N	2026-11-22 10:27:50.871
0756290b-a9d0-438b-a9e0-0fcfd84c3afe	ab64f7e0-5ae5-4282-826f-e08e48227f23	USER_REGISTERED	User	ab64f7e0-5ae5-4282-826f-e08e48227f23	{"role": "MECHANIC", "email": "m4.mech1.1795343270142@vbrs.local"}	\N	\N	2026-11-22 10:27:50.854
faa20794-3617-4cc6-92c5-dcbfbe41e702	92ec996c-90a3-4cd5-a1bf-0861cd595b15	USER_REGISTERED	User	92ec996c-90a3-4cd5-a1bf-0861cd595b15	{"role": "MECHANIC", "email": "m4.mech2.1795343270142@vbrs.local"}	\N	\N	2026-11-22 10:27:51.124
ce75ca96-6007-4baa-bfc1-27255330d59b	020de9be-8c9a-4232-a522-39dfbf87cf9c	BREAKDOWN_REPORT_CREATED	BreakdownReport	d2f9d6a5-3800-423d-b90e-84b8d1349581	{"category": "FLAT_TIRE_WHEEL", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:27:51.164
371c37c7-838b-499f-be0c-f0163e447b77	ab64f7e0-5ae5-4282-826f-e08e48227f23	DISPATCH_ACCEPTED	ServiceRequest	984347f6-637a-4011-98b2-17e322bf14ec	{"mechanicId": "695d4e72-2e32-45ab-8730-762885e4b76b", "breakdownReportId": "d2f9d6a5-3800-423d-b90e-84b8d1349581"}	\N	\N	2026-11-22 10:27:51.393
b11237a5-1a7b-495b-8923-4164e6e19a12	201144dc-4d12-4765-8873-8573ebc70566	BREAKDOWN_REPORT_CREATED	BreakdownReport	d54c176b-181b-4a76-b260-9f49db13bc87	{"category": "ENGINE_FAILURE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 10:27:50.879
d0179d92-0e20-48d6-9984-f1e1d96350f8	58ea9816-d0a5-42ae-92d8-55f32ab1135f	DISPATCH_ACCEPTED	ServiceRequest	a0f6e6c2-fba1-49c2-923b-dd60e4c0e159	{"mechanicId": "723df3b7-5251-4293-a82b-1646a8ce2fc5", "breakdownReportId": "d54c176b-181b-4a76-b260-9f49db13bc87"}	\N	\N	2026-11-22 10:27:50.907
b58fa9d6-9e59-4db2-95fd-bb0ac6041a3a	58ea9816-d0a5-42ae-92d8-55f32ab1135f	SERVICE_STATUS_EN_ROUTE	ServiceRequest	a0f6e6c2-fba1-49c2-923b-dd60e4c0e159	{"notes": "Technician departed garage; en route via arterial highway.", "toStatus": "EN_ROUTE", "fromStatus": "ACCEPTED"}	\N	\N	2026-11-22 10:27:51.031
77e19efc-d42b-4623-9046-cc857bf189a1	58ea9816-d0a5-42ae-92d8-55f32ab1135f	SERVICE_STATUS_ARRIVED	ServiceRequest	a0f6e6c2-fba1-49c2-923b-dd60e4c0e159	{"notes": "Arrived at incident site; positioning emergency safety cones.", "toStatus": "ARRIVED", "fromStatus": "EN_ROUTE"}	\N	\N	2026-11-22 10:27:51.059
c18a3934-4d97-40e7-a607-57f8519ae975	58ea9816-d0a5-42ae-92d8-55f32ab1135f	SERVICE_STATUS_IN_PROGRESS	ServiceRequest	a0f6e6c2-fba1-49c2-923b-dd60e4c0e159	{"notes": "Disassembled ignition harness; installing new OEM coils.", "toStatus": "IN_PROGRESS", "fromStatus": "ARRIVED"}	\N	\N	2026-11-22 10:27:51.18
39a49467-f8ad-4910-8a56-41d30f00f67c	58ea9816-d0a5-42ae-92d8-55f32ab1135f	SERVICE_STATUS_COMPLETED	ServiceRequest	a0f6e6c2-fba1-49c2-923b-dd60e4c0e159	{"toStatus": "COMPLETED", "fromStatus": "IN_PROGRESS"}	\N	\N	2026-11-22 10:27:51.209
3ad2835d-c060-4380-82b7-50fa6f2e209a	201144dc-4d12-4765-8873-8573ebc70566	BREAKDOWN_REPORT_CREATED	BreakdownReport	79851066-2d2b-4a9f-9dd3-d8bb0c442eb3	{"category": "FLAT_TIRE_WHEEL", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:27:51.263
afd75836-e847-4f86-b10e-f8a2638dd5b6	58ea9816-d0a5-42ae-92d8-55f32ab1135f	DISPATCH_ACCEPTED	ServiceRequest	43f9bea4-e74b-494e-ac24-ff66160fcc33	{"mechanicId": "723df3b7-5251-4293-a82b-1646a8ce2fc5", "breakdownReportId": "79851066-2d2b-4a9f-9dd3-d8bb0c442eb3"}	\N	\N	2026-11-22 10:27:51.286
85aeb9bc-600c-45f5-b35d-a5f61766ba80	201144dc-4d12-4765-8873-8573ebc70566	SERVICE_STATUS_CANCELLED	ServiceRequest	43f9bea4-e74b-494e-ac24-ff66160fcc33	{"notes": "Cancellation reason: Spare tire located; vehicle changed independently.", "toStatus": "CANCELLED", "fromStatus": "ACCEPTED", "cancellationReason": "Spare tire located; vehicle changed independently."}	\N	\N	2026-11-22 10:27:51.309
e24fa24b-0a39-478d-86b2-7ab26162da52	abdc3f09-7dcb-4b9d-be66-455330a09529	USER_REGISTERED	User	abdc3f09-7dcb-4b9d-be66-455330a09529	{"role": "CUSTOMER", "email": "m3.userb.1795343270266@vbrs.local"}	\N	\N	2026-11-22 10:27:50.963
41510454-4319-4ce0-a6ed-f1e2f6b3b3d0	4fb4b922-a2e7-4d24-9e81-1bae59ab792b	BREAKDOWN_REPORT_CREATED	BreakdownReport	b47d75cc-de1f-4ef0-9db4-e371cca6c0a8	{"category": "ENGINE_FAILURE", "severity": "CRITICAL", "imageCount": 1, "requiresTowing": true}	\N	\N	2026-11-22 10:27:51.026
2063d97b-bcc0-4f24-8689-2ae0c0ef1e91	4fb4b922-a2e7-4d24-9e81-1bae59ab792b	BREAKDOWN_REPORT_CREATED	BreakdownReport	63198c8d-3d23-45b6-bc85-044e2ee375b1	{"category": "FLAT_TIRE_WHEEL", "severity": "LOW", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:27:51.054
857c2cd9-6640-494d-8eee-3d0078e65998	87f1f769-abfe-4f96-b595-46a1bc413388	USER_REGISTERED	User	87f1f769-abfe-4f96-b595-46a1bc413388	{"role": "CUSTOMER", "email": "m3.edge.custb.1795343270316@vbrs.local"}	\N	\N	2026-11-22 10:27:50.981
8a00e536-83e5-46ad-8d90-acd26a22f0bf	7407b151-116c-44be-bd28-20d2ea8e9da2	USER_REGISTERED	User	7407b151-116c-44be-bd28-20d2ea8e9da2	{"role": "MECHANIC", "email": "m3.edge.mech.1795343270316@vbrs.local"}	\N	\N	2026-11-22 10:27:51.243
e51d670a-5685-4a8c-a2a5-ee27ffae7b7d	e05d0c61-e1ae-4921-8453-3dc06525dc08	VEHICLE_ADDED	Vehicle	51cd1921-76c9-4b82-9a67-5688ae2d6f31	{"make": "Porsche", "model": "911 GT3", "plate": "EDGE-A-1250"}	\N	\N	2026-11-22 10:27:51.27
6afc34fd-b988-4404-9a31-bde285fdfa19	87f1f769-abfe-4f96-b595-46a1bc413388	VEHICLE_ADDED	Vehicle	b1cd0de9-5fde-4d7a-afd9-d4efd8bbf325	{"make": "Tesla", "model": "Model S Plaid", "plate": "EDGE-B-1273"}	\N	\N	2026-11-22 10:27:51.283
60be1744-f11a-450e-849c-90c4df4d56a6	e05d0c61-e1ae-4921-8453-3dc06525dc08	BREAKDOWN_REPORT_CREATED	BreakdownReport	1ba05733-bff4-477d-8dfc-a8841f2f748e	{"category": "COLLISION_ACCIDENT", "severity": "CRITICAL", "imageCount": 5, "requiresTowing": true}	\N	\N	2026-11-22 10:27:51.38
137612cd-0490-41d6-8625-47e058e39c37	e05d0c61-e1ae-4921-8453-3dc06525dc08	BREAKDOWN_REPORT_CREATED	BreakdownReport	177e2af1-8d2d-4e15-8535-c0bd9ea873d3	{"category": "BRAKE_SYSTEM_FAILURE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 10:27:51.433
6fcb2669-c126-4fea-9784-e7f592d812ca	e05d0c61-e1ae-4921-8453-3dc06525dc08	BREAKDOWN_REPORT_CREATED	BreakdownReport	7a6b871f-550a-4d03-a9cf-71ece348d97a	{"category": "BATTERY_DEAD_ELECTRICAL", "severity": "MEDIUM", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 10:27:51.462
23ec948b-d1e1-4909-bd8a-98dbf98b53f0	e05d0c61-e1ae-4921-8453-3dc06525dc08	BREAKDOWN_REPORT_CREATED	BreakdownReport	6f521e4d-97b7-4daf-8fcd-c6d0edc39fa5	{"category": "TRANSMISSION_ISSUE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 10:27:51.483
e59511b1-ea60-451b-8ebc-bc73b7b31aae	e05d0c61-e1ae-4921-8453-3dc06525dc08	BREAKDOWN_REPORT_CREATED	BreakdownReport	194fa08d-3216-4710-ad41-ce79605b6167	{"category": "FUEL_EMPTY_OR_CONTAMINATED", "severity": "LOW", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:27:51.526
e22538d1-b818-4d91-9d92-be80a5d761eb	e05d0c61-e1ae-4921-8453-3dc06525dc08	BREAKDOWN_REPORT_CREATED	BreakdownReport	45212516-769e-48e1-9d56-9f797caa2695	{"category": "OVERHEATING_COOLANT", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:27:51.543
14c767ce-6f58-4831-973e-d6e1c7876b17	e05d0c61-e1ae-4921-8453-3dc06525dc08	BREAKDOWN_REPORT_CREATED	BreakdownReport	f7650823-b3a6-4fbf-b870-efe2b99ebb8f	{"category": "LOCKOUT_KEY_LOST", "severity": "LOW", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 10:27:51.581
7109b936-a2dc-4660-96bf-6cb292e458ab	29c945b2-a680-4d39-9f8d-ee67d94c8272	USER_REGISTERED	User	29c945b2-a680-4d39-9f8d-ee67d94c8272	{"role": "MECHANIC", "email": "audit.mechanic.1795343270278@vbrs.local"}	\N	\N	2026-11-22 10:27:50.985
fd44f58a-2cf2-4ad3-8ebd-17f78f6f3a19	2453cf81-de2b-42e1-9cbd-394d92e735f6	USER_LOGGED_IN	User	2453cf81-de2b-42e1-9cbd-394d92e735f6	\N	\N	\N	2026-11-22 10:27:51.252
68e0de8b-65a7-42f1-ac67-f11f793bc801	29c945b2-a680-4d39-9f8d-ee67d94c8272	USER_LOGGED_IN	User	29c945b2-a680-4d39-9f8d-ee67d94c8272	\N	\N	\N	2026-11-22 10:27:51.492
5a652971-678d-46e9-927c-a76e18e897e3	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 10:27:51.726
901db4b7-c57d-47fd-8017-db677b07f5e1	3d1bfe42-4c49-425d-aa93-9f8e9c52b45f	VEHICLE_ADDED	Vehicle	f20ee685-1328-4f0a-8577-c8a21a287fcb	{"make": "Ford", "model": "Mustang Mach-E", "plate": "M2-1166"}	\N	\N	2026-11-22 10:27:51.181
775f6727-6e92-44a2-9512-4ca27ae2acf2	3d1bfe42-4c49-425d-aa93-9f8e9c52b45f	VEHICLE_UPDATED	Vehicle	f20ee685-1328-4f0a-8577-c8a21a287fcb	\N	\N	\N	2026-11-22 10:27:51.221
356b46ed-009c-49f7-a878-688e97fc23e8	3d1bfe42-4c49-425d-aa93-9f8e9c52b45f	VEHICLE_DELETED	Vehicle	f20ee685-1328-4f0a-8577-c8a21a287fcb	{"plate": "M2-1166"}	\N	\N	2026-11-22 10:27:51.245
5c0718a9-172a-4ec8-973b-15312a004a81	3d1bfe42-4c49-425d-aa93-9f8e9c52b45f	USER_LOGGED_OUT	User	3d1bfe42-4c49-425d-aa93-9f8e9c52b45f	\N	\N	\N	2026-11-22 10:27:51.264
416fd9a5-8380-4a00-8fe9-3ea64d10ad1d	ecd14194-d465-4297-b876-4c714881b790	USER_REGISTERED	User	ecd14194-d465-4297-b876-4c714881b790	{"role": "CUSTOMER", "email": "audit.userb.1795343270278@vbrs.local"}	\N	\N	2026-11-22 10:27:52.203
6194f737-005f-4c27-8552-e0c3b6fab063	2453cf81-de2b-42e1-9cbd-394d92e735f6	VEHICLE_ADDED	Vehicle	c7df81a3-0e94-4f2e-858a-19ba377a8932	{"make": "Porsche", "model": "Taycan GTS", "plate": "AUD-0280"}	\N	\N	2026-11-22 10:27:52.719
294525de-0ff9-4833-bfd2-bf479b7ff17c	2453cf81-de2b-42e1-9cbd-394d92e735f6	VEHICLE_UPDATED	Vehicle	c7df81a3-0e94-4f2e-858a-19ba377a8932	\N	\N	\N	2026-11-22 10:27:52.739
80648eaf-8026-44fe-80e9-0f4d00163372	2453cf81-de2b-42e1-9cbd-394d92e735f6	VEHICLE_DELETED	Vehicle	c7df81a3-0e94-4f2e-858a-19ba377a8932	{"plate": "AUD-0280"}	\N	\N	2026-11-22 10:27:52.766
011ddd48-b56f-4b39-9d35-a72aaeb7719a	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 10:35:03.709
fdb91c0f-5b10-4ce5-949c-d0dcc01d090b	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	4f3570aa-66c5-4061-aebb-2dc2b9e84fa8	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:35:04.794
72df171e-98a1-4ee4-a741-8468f138a06a	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 10:36:11.791
050bd540-6ce4-4fd1-b131-3402f682be8e	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	827b2ca4-1958-4ee9-a506-7d53e59a37c4	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:36:13.036
f1ea3877-cb31-4580-9860-c64d65893cfd	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 10:36:14.438
1ecb9892-6e30-4281-9282-441a344e5c4a	473401ce-0803-422f-8baa-a47de557f84e	DISPATCH_ACCEPTED	ServiceRequest	e8622675-c26b-4432-8487-e7fa171c4d07	{"mechanicId": "6a01cdea-a7ee-43e1-8a1f-77ecba9b0890", "breakdownReportId": "177e2af1-8d2d-4e15-8535-c0bd9ea873d3"}	\N	\N	2026-11-22 10:36:16.365
d950373c-12a1-46dd-9357-fd0bfe196d1a	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_EN_ROUTE	ServiceRequest	e8622675-c26b-4432-8487-e7fa171c4d07	{"notes": "Technician departed base en route to incident site.", "toStatus": "EN_ROUTE", "fromStatus": "ACCEPTED"}	\N	\N	2026-11-22 10:36:16.426
1e66423f-8f05-4cf9-ba18-5c14dcece0d3	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_ARRIVED	ServiceRequest	e8622675-c26b-4432-8487-e7fa171c4d07	{"notes": "Technician arrived on scene at incident coordinates.", "toStatus": "ARRIVED", "fromStatus": "EN_ROUTE"}	\N	\N	2026-11-22 10:36:19.245
209deca1-911d-4c18-97e3-a1f36ac8ad9e	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_IN_PROGRESS	ServiceRequest	e8622675-c26b-4432-8487-e7fa171c4d07	{"notes": "Beginning diagnostic disassembly and component servicing.", "toStatus": "IN_PROGRESS", "fromStatus": "ARRIVED"}	\N	\N	2026-11-22 10:36:20.91
d2759e61-7bf2-48e2-8b21-5f97ddb98dc8	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_COMPLETED	ServiceRequest	e8622675-c26b-4432-8487-e7fa171c4d07	{"notes": "Service finished successfully.", "toStatus": "COMPLETED", "fromStatus": "IN_PROGRESS"}	\N	\N	2026-11-22 10:36:21.021
3869ced5-0451-4d20-a9c7-bf867710bd93	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 10:37:44.397
da40e0f6-10ba-41c9-8a97-f95182403cbd	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	45a12b7f-7c1d-4f45-88cf-5f1a176b248f	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 10:37:45.613
1fb186b6-cfb0-4982-95f9-f0b8cd937114	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 10:37:46.975
287b3e3e-7fbf-4a3a-ad5f-0ded7631aa00	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 10:38:34.549
2548c121-6a01-40fa-8c18-d791d5c7d813	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	b41f8148-a8cc-415a-a969-080e2567ec3a	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 10:38:35.65
31350e7b-0314-4704-9609-7d66afd865a8	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 10:38:37.003
2cb250a5-9ef5-4ff2-9c56-294651ccc452	473401ce-0803-422f-8baa-a47de557f84e	DISPATCH_ACCEPTED	ServiceRequest	5667e3e6-1685-49a1-ae1b-73e2d7019d11	{"mechanicId": "6a01cdea-a7ee-43e1-8a1f-77ecba9b0890", "breakdownReportId": "b41f8148-a8cc-415a-a969-080e2567ec3a"}	\N	\N	2026-11-22 10:38:39.073
878c166b-5d82-474b-a99e-22b00e921486	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_EN_ROUTE	ServiceRequest	5667e3e6-1685-49a1-ae1b-73e2d7019d11	{"notes": "Technician departed base en route to incident site.", "toStatus": "EN_ROUTE", "fromStatus": "ACCEPTED"}	\N	\N	2026-11-22 10:38:39.129
0fd22245-f2fd-4638-91ad-7e2dff2cf6de	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_ARRIVED	ServiceRequest	5667e3e6-1685-49a1-ae1b-73e2d7019d11	{"notes": "Technician arrived on scene at incident coordinates.", "toStatus": "ARRIVED", "fromStatus": "EN_ROUTE"}	\N	\N	2026-11-22 10:38:41.669
5dcb7528-95b5-424e-a322-14bba22aabfc	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_IN_PROGRESS	ServiceRequest	5667e3e6-1685-49a1-ae1b-73e2d7019d11	{"notes": "Beginning diagnostic disassembly and component servicing.", "toStatus": "IN_PROGRESS", "fromStatus": "ARRIVED"}	\N	\N	2026-11-22 10:38:43.312
9bdc90dd-0fd8-4477-9ed1-eac4d657b062	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_COMPLETED	ServiceRequest	5667e3e6-1685-49a1-ae1b-73e2d7019d11	{"notes": "Service finished successfully.", "toStatus": "COMPLETED", "fromStatus": "IN_PROGRESS"}	\N	\N	2026-11-22 10:38:43.421
c50cc70c-8130-4514-be73-be43e709612e	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 10:39:08.163
51adf288-bde5-47cf-a9b8-c9335c86ade7	e22478b0-00a4-44f8-b146-3649213c7a20	VEHICLE_ADDED	Vehicle	dee7f69a-7c9e-4bcf-b223-f0108c3201f4	{"make": "Audi", "model": "RS6 Avant", "plate": "E2E-9729"}	\N	\N	2026-11-22 10:39:09.802
20f95715-405f-411b-ba4f-fb9dfbcb9b48	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 10:39:18.99
d1ae3ade-dfdd-46a8-a7a6-8cd32e4322c3	9979cb67-e488-44d8-b0df-569a81cec64d	USER_LOGGED_IN	User	9979cb67-e488-44d8-b0df-569a81cec64d	\N	\N	\N	2026-11-22 10:42:22.592
f4fd4714-c922-4596-9668-ec0d1869e605	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	3060a900-70eb-4d89-b657-6c40840f6826	{"category": "TRANSMISSION_ISSUE", "severity": "CRITICAL", "imageCount": 1, "requiresTowing": true}	\N	\N	2026-11-22 10:39:22.563
768fcd79-c31d-44ff-ba4a-103b7f9aaa93	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 10:39:25
adaa6912-0da0-4ace-b486-a360e6b9aa7d	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	8f445627-881d-455d-b1c9-a6d74934aa1e	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 10:39:29.797
5d09225e-1e68-4b22-8cb6-4d2453fb2951	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 10:39:32.179
aaf11def-4507-40df-ba39-0aca123a4a06	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	01a454d5-60c7-4f76-952a-c8ceae5c11a5	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:39:34.268
c88518d4-cf64-4a77-83cf-2733e474157c	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 10:39:35.11
aebac551-4195-410f-a2ff-4514c238f6ff	473401ce-0803-422f-8baa-a47de557f84e	DISPATCH_ACCEPTED	ServiceRequest	a16cb0b7-dff9-4c7c-9af0-b66ad02b20d3	{"mechanicId": "6a01cdea-a7ee-43e1-8a1f-77ecba9b0890", "breakdownReportId": "01a454d5-60c7-4f76-952a-c8ceae5c11a5"}	\N	\N	2026-11-22 10:39:42.228
9f7bd6dd-53af-4e52-95bc-949280088b1b	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 10:39:59.568
989bd92c-aa93-445f-a1e3-e64bdaf0f88e	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	4adea7f8-dfaa-41aa-a515-63c4226ce422	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:40:01.762
76d8fa55-7e09-4518-a249-b3515cf0952b	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 10:40:02.606
710213c6-e769-4fb0-9535-a75475c40318	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 10:41:04.561
21d75265-c51d-4aa3-be1b-c81998949e86	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	19fc7b7d-4ead-4e91-90f1-4011beba0cfe	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:41:06.874
2b7f3bbb-ce8c-4345-ad2f-e8fb914b2859	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 10:41:07.88
f55a2c12-95e0-40b9-af7c-19c56bfd6157	473401ce-0803-422f-8baa-a47de557f84e	DISPATCH_ACCEPTED	ServiceRequest	1dd07957-0c54-452c-b8aa-9d314d95eb48	{"mechanicId": "6a01cdea-a7ee-43e1-8a1f-77ecba9b0890", "breakdownReportId": "19fc7b7d-4ead-4e91-90f1-4011beba0cfe"}	\N	\N	2026-11-22 10:41:14.868
e404b110-bf6c-4aef-b972-1206078a010c	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 10:41:17.874
8077ef9e-753e-4a3f-8382-e02c310fc893	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	6834daf4-6750-4e88-8fa5-4eefbd06435e	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 10:41:19.071
c3334db6-ddba-4e05-96fd-ef14bd1df512	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 10:41:20.659
37d42ab4-93ba-4bba-9efd-c94ccb619d88	473401ce-0803-422f-8baa-a47de557f84e	DISPATCH_ACCEPTED	ServiceRequest	5fc2a975-92bf-4ae6-bea8-2b08fe76c1f5	{"mechanicId": "6a01cdea-a7ee-43e1-8a1f-77ecba9b0890", "breakdownReportId": "6834daf4-6750-4e88-8fa5-4eefbd06435e"}	\N	\N	2026-11-22 10:41:22.636
1a9aeb96-0c92-4cae-bd84-ee57d48c044e	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 10:41:47.482
009f83ea-f061-4d0a-9a47-12107663603d	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	33b43356-f4a9-42ac-a15c-158e87f1cb36	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 10:41:48.682
0b4fbf16-50c6-486d-83c4-dc900e3b0be7	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 10:41:50.057
68e8723e-5258-4217-8a86-d960e2f0d20d	473401ce-0803-422f-8baa-a47de557f84e	DISPATCH_ACCEPTED	ServiceRequest	38ab3d1d-0dd4-4a0b-9a07-a072a106b9ea	{"mechanicId": "6a01cdea-a7ee-43e1-8a1f-77ecba9b0890", "breakdownReportId": "33b43356-f4a9-42ac-a15c-158e87f1cb36"}	\N	\N	2026-11-22 10:41:51.997
1bc7e984-9813-4858-a58c-7b6028b2aac5	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_EN_ROUTE	ServiceRequest	38ab3d1d-0dd4-4a0b-9a07-a072a106b9ea	{"notes": "Technician departed base en route to incident site.", "toStatus": "EN_ROUTE", "fromStatus": "ACCEPTED"}	\N	\N	2026-11-22 10:41:52.054
a9f3940a-149b-43d3-99d6-e590bfc85647	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_ARRIVED	ServiceRequest	38ab3d1d-0dd4-4a0b-9a07-a072a106b9ea	{"notes": "Technician arrived on scene at incident coordinates.", "toStatus": "ARRIVED", "fromStatus": "EN_ROUTE"}	\N	\N	2026-11-22 10:41:54.607
a7e6e2b4-6e99-4b36-9d36-5182b5f36316	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_IN_PROGRESS	ServiceRequest	38ab3d1d-0dd4-4a0b-9a07-a072a106b9ea	{"notes": "Beginning diagnostic disassembly and component servicing.", "toStatus": "IN_PROGRESS", "fromStatus": "ARRIVED"}	\N	\N	2026-11-22 10:41:56.252
87de7af2-f1f3-4cb1-a9f2-9a9ed2dc7592	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_COMPLETED	ServiceRequest	38ab3d1d-0dd4-4a0b-9a07-a072a106b9ea	{"notes": "Service finished successfully.", "toStatus": "COMPLETED", "fromStatus": "IN_PROGRESS"}	\N	\N	2026-11-22 10:41:56.352
63ddaacd-97e8-4b82-b6b7-4537192ba2bb	b347ca38-e44c-42ac-a846-63d4b6c28e3a	USER_REGISTERED	User	b347ca38-e44c-42ac-a846-63d4b6c28e3a	{"role": "CUSTOMER", "email": "m3.edge.custa.1795344141577@vbrs.local"}	\N	\N	2026-11-22 10:42:22.047
9dd56d5f-1d88-43f8-9596-2d55c087591e	9979cb67-e488-44d8-b0df-569a81cec64d	USER_REGISTERED	User	9979cb67-e488-44d8-b0df-569a81cec64d	{"role": "CUSTOMER", "email": "audit.customer.1795344141549@vbrs.local"}	\N	\N	2026-11-22 10:42:22.049
7bb91477-279e-4895-af4d-234dc766d60e	a17cea7b-22a1-44e0-a813-5f16ce79bc69	USER_REGISTERED	User	a17cea7b-22a1-44e0-a813-5f16ce79bc69	{"role": "CUSTOMER", "email": "m4.customer.1795344141614@vbrs.local"}	\N	\N	2026-11-22 10:42:22.066
f5bda6e3-f6e9-44c6-9695-42fc8cbd92d3	e51a5048-6c2d-466a-ae62-613927b40269	USER_REGISTERED	User	e51a5048-6c2d-466a-ae62-613927b40269	{"role": "CUSTOMER", "email": "m3.customer.1795344141625@vbrs.local"}	\N	\N	2026-11-22 10:42:22.08
573ea289-959e-4401-b533-64c24cb0154e	24d8704e-eebc-4c21-986b-d85a1ed5a92a	USER_REGISTERED	User	24d8704e-eebc-4c21-986b-d85a1ed5a92a	{"role": "CUSTOMER", "email": "m5.cust1.1795344141649@vbrs.local"}	\N	\N	2026-11-22 10:42:22.09
6ffb5f23-317a-485a-80ff-ca7e0a8c5155	eada0765-6f29-428a-9687-0f1bdf9aaacb	USER_REGISTERED	User	eada0765-6f29-428a-9687-0f1bdf9aaacb	{"role": "CUSTOMER", "email": "m2.customer.1795344141629@vbrs.local"}	\N	\N	2026-11-22 10:42:22.109
2ec0891c-c35e-4c52-b948-18ed26e008f9	87dac236-69b8-470f-b92f-efef6a6e2d67	USER_REGISTERED	User	87dac236-69b8-470f-b92f-efef6a6e2d67	{"role": "CUSTOMER", "email": "m3.edge.custb.1795344141577@vbrs.local"}	\N	\N	2026-11-22 10:42:22.321
a371f057-c86a-4fe7-93e6-a02a63653bea	17f8c042-b632-48cf-8e97-53a057ab03fd	USER_REGISTERED	User	17f8c042-b632-48cf-8e97-53a057ab03fd	{"role": "MECHANIC", "email": "audit.mechanic.1795344141549@vbrs.local"}	\N	\N	2026-11-22 10:42:22.333
b8613bee-1585-4449-b867-abeb553f2278	7469c3f3-91d7-4857-ad8a-a6e99f73a521	USER_REGISTERED	User	7469c3f3-91d7-4857-ad8a-a6e99f73a521	{"role": "CUSTOMER", "email": "m3.userb.1795344141625@vbrs.local"}	\N	\N	2026-11-22 10:42:22.344
dcc0d908-e74e-49c9-a46f-e13641079277	6dffcd9a-0d48-4863-a865-8f96c2680bf5	USER_REGISTERED	User	6dffcd9a-0d48-4863-a865-8f96c2680bf5	{"role": "MECHANIC", "email": "m4.mech1.1795344141614@vbrs.local"}	\N	\N	2026-11-22 10:42:22.353
9b013383-b35f-445c-8d64-cc091fae8515	bfe64bf0-bb93-405b-a336-a1453240ac67	USER_REGISTERED	User	bfe64bf0-bb93-405b-a336-a1453240ac67	{"role": "CUSTOMER", "email": "m5.cust2.1795344141649@vbrs.local"}	\N	\N	2026-11-22 10:42:22.372
e74bfdaa-5a5d-432a-8ea5-a3b2871e91cf	e51a5048-6c2d-466a-ae62-613927b40269	BREAKDOWN_REPORT_CREATED	BreakdownReport	9e94c210-60e1-4216-897c-10cbddf91eeb	{"category": "ENGINE_FAILURE", "severity": "CRITICAL", "imageCount": 1, "requiresTowing": true}	\N	\N	2026-11-22 10:42:22.399
10f8b4ec-1de4-4bfe-bc28-16a8801d977a	eada0765-6f29-428a-9687-0f1bdf9aaacb	USER_LOGGED_IN	User	eada0765-6f29-428a-9687-0f1bdf9aaacb	\N	\N	\N	2026-11-22 10:42:22.409
c65d4f55-2c82-4f95-be68-64db46e6063b	885f49f3-4df5-48f9-aeaf-9e7b29015b02	USER_REGISTERED	User	885f49f3-4df5-48f9-aeaf-9e7b29015b02	{"role": "MECHANIC", "email": "m3.edge.mech.1795344141577@vbrs.local"}	\N	\N	2026-11-22 10:42:22.587
bc06ddb0-78a4-400c-908a-dbb0e9261065	e51a5048-6c2d-466a-ae62-613927b40269	BREAKDOWN_REPORT_CREATED	BreakdownReport	99590f73-1eef-4a9e-b6ae-78f5cfb87434	{"category": "FLAT_TIRE_WHEEL", "severity": "LOW", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:42:22.423
d4bfba63-2aee-4944-8ef0-cc73ef53af39	b347ca38-e44c-42ac-a846-63d4b6c28e3a	VEHICLE_ADDED	Vehicle	8f8af963-f33f-4ef7-ab39-a9fb66446f50	{"make": "Porsche", "model": "911 GT3", "plate": "EDGE-A-2593"}	\N	\N	2026-11-22 10:42:22.609
90d5faf8-a7d2-4cdf-ab0f-a3e44d875adc	87dac236-69b8-470f-b92f-efef6a6e2d67	VEHICLE_ADDED	Vehicle	030f76d1-9136-446f-be98-73f088f19dbd	{"make": "Tesla", "model": "Model S Plaid", "plate": "EDGE-B-2612"}	\N	\N	2026-11-22 10:42:22.624
9838e67f-5d37-4afb-b960-7dac94ae7199	b347ca38-e44c-42ac-a846-63d4b6c28e3a	BREAKDOWN_REPORT_CREATED	BreakdownReport	f36961f4-c7dc-4b8a-9d17-58ec54f3ebb0	{"category": "COLLISION_ACCIDENT", "severity": "CRITICAL", "imageCount": 5, "requiresTowing": true}	\N	\N	2026-11-22 10:42:22.718
6a074664-3d7c-4245-a11a-fc36ec33040d	b347ca38-e44c-42ac-a846-63d4b6c28e3a	BREAKDOWN_REPORT_CREATED	BreakdownReport	3e3c598a-bce1-4477-95db-2e1f397dd5ae	{"category": "BRAKE_SYSTEM_FAILURE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 10:42:22.783
8120b73c-8b08-4edc-8f55-2cc748129875	b347ca38-e44c-42ac-a846-63d4b6c28e3a	BREAKDOWN_REPORT_CREATED	BreakdownReport	37ec9d06-b6dc-467b-aa06-dca2c2261de5	{"category": "BATTERY_DEAD_ELECTRICAL", "severity": "MEDIUM", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 10:42:22.816
701d01ba-cfe4-4bc7-9443-7b0889eb9f7e	b347ca38-e44c-42ac-a846-63d4b6c28e3a	BREAKDOWN_REPORT_CREATED	BreakdownReport	731f9dfc-8b40-4c89-bf73-6c022755f9e8	{"category": "TRANSMISSION_ISSUE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 10:42:22.843
7cc1a1bb-0db1-47ae-b2bd-b927d6f6c1eb	b347ca38-e44c-42ac-a846-63d4b6c28e3a	BREAKDOWN_REPORT_CREATED	BreakdownReport	0965a46b-e716-4562-bf7e-d6860dd16d85	{"category": "FUEL_EMPTY_OR_CONTAMINATED", "severity": "LOW", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:42:22.879
df8cd55b-44a3-4e06-9451-738a2cd951a8	b347ca38-e44c-42ac-a846-63d4b6c28e3a	BREAKDOWN_REPORT_CREATED	BreakdownReport	1c237f6e-ad6e-44b7-bdb8-ba299173c09e	{"category": "OVERHEATING_COOLANT", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:42:22.894
b6f43513-372c-413e-b0fd-43bd0f7bf7bc	b347ca38-e44c-42ac-a846-63d4b6c28e3a	BREAKDOWN_REPORT_CREATED	BreakdownReport	72b4a60c-fd53-46a6-97a0-687038d1c7ae	{"category": "LOCKOUT_KEY_LOST", "severity": "LOW", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 10:42:22.935
afe172c8-aada-4df6-b574-563c327ef473	568f1967-6055-40f4-bd07-97ee79559948	USER_REGISTERED	User	568f1967-6055-40f4-bd07-97ee79559948	{"role": "MECHANIC", "email": "m4.mech2.1795344141614@vbrs.local"}	\N	\N	2026-11-22 10:42:22.621
eee056cc-a7d2-470d-8c79-1917f7f4c01c	a17cea7b-22a1-44e0-a813-5f16ce79bc69	BREAKDOWN_REPORT_CREATED	BreakdownReport	4b11b62a-d28e-4a29-8673-1d588a34c3d9	{"category": "FLAT_TIRE_WHEEL", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:42:22.657
f4abab4f-ac89-4a87-a4b9-1db7364b20a0	6dffcd9a-0d48-4863-a865-8f96c2680bf5	DISPATCH_ACCEPTED	ServiceRequest	dff4bfd6-f7b6-4c8a-b8a7-eda1c0f3fed6	{"mechanicId": "f95c00f1-a886-4c05-9222-f50e52a5bff5", "breakdownReportId": "4b11b62a-d28e-4a29-8673-1d588a34c3d9"}	\N	\N	2026-11-22 10:42:22.902
511b2119-0068-41dc-999f-f3d3da5c0ade	fd109b4c-5829-497b-8da6-252d426b4a4d	USER_REGISTERED	User	fd109b4c-5829-497b-8da6-252d426b4a4d	{"role": "MECHANIC", "email": "m5.mech1.1795344141649@vbrs.local"}	\N	\N	2026-11-22 10:42:22.631
ed81ed66-74cd-49a0-9b46-da4b60b1f83d	754478bf-6a8e-4cc5-9aa9-f783e59d909a	USER_REGISTERED	User	754478bf-6a8e-4cc5-9aa9-f783e59d909a	{"role": "MECHANIC", "email": "m5.mech2.1795344141649@vbrs.local"}	\N	\N	2026-11-22 10:42:22.9
c8b1ede0-c679-43c3-b314-2c60c0d6bdca	cd86f585-75aa-49d3-ba65-a6fc616c5d70	USER_REGISTERED	User	cd86f585-75aa-49d3-ba65-a6fc616c5d70	{"role": "ADMIN", "email": "m5.admin.1795344141649@vbrs.local"}	\N	\N	2026-11-22 10:42:23.136
d0dd2de1-1b8a-446f-b7c4-ba243d4f75a2	24d8704e-eebc-4c21-986b-d85a1ed5a92a	BREAKDOWN_REPORT_CREATED	BreakdownReport	6b1cdabf-63d4-48d3-b4c4-eb8149b50d3c	{"category": "ENGINE_FAILURE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 10:42:23.17
ba322625-7c98-451d-928d-3eb65f0bbac1	fd109b4c-5829-497b-8da6-252d426b4a4d	DISPATCH_ACCEPTED	ServiceRequest	c0196faf-c92c-4aa7-803d-e5f968d1ee3d	{"mechanicId": "44d77d53-44ac-4dbd-b34c-964ec9926154", "breakdownReportId": "6b1cdabf-63d4-48d3-b4c4-eb8149b50d3c"}	\N	\N	2026-11-22 10:42:23.208
13f66445-339a-4cc6-9316-9e62cc344558	fd109b4c-5829-497b-8da6-252d426b4a4d	SERVICE_STATUS_EN_ROUTE	ServiceRequest	c0196faf-c92c-4aa7-803d-e5f968d1ee3d	{"notes": "Technician departed garage; en route via arterial highway.", "toStatus": "EN_ROUTE", "fromStatus": "ACCEPTED"}	\N	\N	2026-11-22 10:42:23.343
cdcb1d1c-3e7c-4508-b607-f0a1a13116a4	fd109b4c-5829-497b-8da6-252d426b4a4d	SERVICE_STATUS_ARRIVED	ServiceRequest	c0196faf-c92c-4aa7-803d-e5f968d1ee3d	{"notes": "Arrived at incident site; positioning emergency safety cones.", "toStatus": "ARRIVED", "fromStatus": "EN_ROUTE"}	\N	\N	2026-11-22 10:42:23.373
8099ce3e-0312-4f5a-92fa-517f172a5561	fd109b4c-5829-497b-8da6-252d426b4a4d	SERVICE_STATUS_IN_PROGRESS	ServiceRequest	c0196faf-c92c-4aa7-803d-e5f968d1ee3d	{"notes": "Disassembled ignition harness; installing new OEM coils.", "toStatus": "IN_PROGRESS", "fromStatus": "ARRIVED"}	\N	\N	2026-11-22 10:42:23.48
41b8539f-6f15-4e18-92cf-0bc126a3ccca	fd109b4c-5829-497b-8da6-252d426b4a4d	SERVICE_STATUS_COMPLETED	ServiceRequest	c0196faf-c92c-4aa7-803d-e5f968d1ee3d	{"toStatus": "COMPLETED", "fromStatus": "IN_PROGRESS"}	\N	\N	2026-11-22 10:42:23.508
14e002b0-d087-4a26-97f8-0217bd083b59	24d8704e-eebc-4c21-986b-d85a1ed5a92a	BREAKDOWN_REPORT_CREATED	BreakdownReport	0432331c-96e7-45cf-8354-6ab3d5101bbc	{"category": "FLAT_TIRE_WHEEL", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:42:23.558
df2ed23a-7be8-4dca-9cb5-7217d5738e07	fd109b4c-5829-497b-8da6-252d426b4a4d	DISPATCH_ACCEPTED	ServiceRequest	a4fd96c9-1891-4547-bf8a-253904e5cd55	{"mechanicId": "44d77d53-44ac-4dbd-b34c-964ec9926154", "breakdownReportId": "0432331c-96e7-45cf-8354-6ab3d5101bbc"}	\N	\N	2026-11-22 10:42:23.578
fc3f8b8b-3dab-4f44-bea0-f558c2e34686	24d8704e-eebc-4c21-986b-d85a1ed5a92a	SERVICE_STATUS_CANCELLED	ServiceRequest	a4fd96c9-1891-4547-bf8a-253904e5cd55	{"notes": "Cancellation reason: Spare tire located; vehicle changed independently.", "toStatus": "CANCELLED", "fromStatus": "ACCEPTED", "cancellationReason": "Spare tire located; vehicle changed independently."}	\N	\N	2026-11-22 10:42:23.599
e39b4d63-4556-491f-a12d-04e2298fc06c	eada0765-6f29-428a-9687-0f1bdf9aaacb	VEHICLE_ADDED	Vehicle	6382644d-c77c-43a0-a83e-5b951f061722	{"make": "Ford", "model": "Mustang Mach-E", "plate": "M2-2705"}	\N	\N	2026-11-22 10:42:22.719
705b3bb9-469e-4a8b-8612-8abcbdebc88a	eada0765-6f29-428a-9687-0f1bdf9aaacb	VEHICLE_UPDATED	Vehicle	6382644d-c77c-43a0-a83e-5b951f061722	\N	\N	\N	2026-11-22 10:42:22.764
db8366bf-c289-4606-ad30-3e17d07724e4	eada0765-6f29-428a-9687-0f1bdf9aaacb	VEHICLE_DELETED	Vehicle	6382644d-c77c-43a0-a83e-5b951f061722	{"plate": "M2-2705"}	\N	\N	2026-11-22 10:42:22.791
3c85621d-12ee-4a23-a413-a16808404786	eada0765-6f29-428a-9687-0f1bdf9aaacb	USER_LOGGED_OUT	User	eada0765-6f29-428a-9687-0f1bdf9aaacb	\N	\N	\N	2026-11-22 10:42:22.811
59abb7f3-74c1-4c10-8587-b6cb7b8b96fd	17f8c042-b632-48cf-8e97-53a057ab03fd	USER_LOGGED_IN	User	17f8c042-b632-48cf-8e97-53a057ab03fd	\N	\N	\N	2026-11-22 10:42:22.855
1c4b9b87-9646-4628-8da9-cf22916cc9cb	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 10:42:23.095
ec10ee31-b6a2-4ade-9eaf-9ea5a5274e75	309fc985-8fee-44cf-8b3f-7c963665f95a	USER_REGISTERED	User	309fc985-8fee-44cf-8b3f-7c963665f95a	{"role": "CUSTOMER", "email": "audit.userb.1795344141549@vbrs.local"}	\N	\N	2026-11-22 10:42:23.584
b213801d-299f-440f-8f83-675ef397b6c7	9979cb67-e488-44d8-b0df-569a81cec64d	VEHICLE_ADDED	Vehicle	3d8533b8-e799-4a5e-b55e-da5145b2edb9	{"make": "Porsche", "model": "Taycan GTS", "plate": "AUD-1550"}	\N	\N	2026-11-22 10:42:24.12
9fb2e167-8930-424d-a6d6-3bdce0249cd7	9979cb67-e488-44d8-b0df-569a81cec64d	VEHICLE_UPDATED	Vehicle	3d8533b8-e799-4a5e-b55e-da5145b2edb9	\N	\N	\N	2026-11-22 10:42:24.144
ec5f773a-fd93-4224-92cc-87cbe440bd1c	9979cb67-e488-44d8-b0df-569a81cec64d	VEHICLE_DELETED	Vehicle	3d8533b8-e799-4a5e-b55e-da5145b2edb9	{"plate": "AUD-1550"}	\N	\N	2026-11-22 10:42:24.172
6bc12e98-7afe-4bf2-8a69-88869eaab75e	d8bcfbbb-5b9c-41f3-8c41-e601d5e105c3	USER_REGISTERED	User	d8bcfbbb-5b9c-41f3-8c41-e601d5e105c3	{"role": "ADMIN", "email": "m6.admin.1795345105502@vbrs.local"}	\N	\N	2026-11-22 10:58:25.876
d69dce11-363a-4e79-96d7-15567f73446b	20e961e5-4364-4013-ac83-b3cdac902909	USER_REGISTERED	User	20e961e5-4364-4013-ac83-b3cdac902909	{"role": "CUSTOMER", "email": "m6.customer.1795345105502@vbrs.local"}	\N	\N	2026-11-22 10:58:26.121
ee2b7760-faa9-4689-904d-c32b41a8a252	912d1cb2-475d-4b50-8a70-7c6efd34617e	USER_REGISTERED	User	912d1cb2-475d-4b50-8a70-7c6efd34617e	{"role": "MECHANIC", "email": "m6.pending.mech.1795345105502@vbrs.local"}	\N	\N	2026-11-22 10:58:26.36
07291d70-1c50-4a32-a300-d621001af61d	20e961e5-4364-4013-ac83-b3cdac902909	BREAKDOWN_REPORT_CREATED	BreakdownReport	2f6f5479-7230-441a-a606-89737498bd2e	{"category": "BRAKE_SYSTEM_FAILURE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 10:58:26.393
22c17e07-7e91-4f21-91c2-6d2729ec74ce	d8bcfbbb-5b9c-41f3-8c41-e601d5e105c3	MECHANIC_VERIFICATION_APPROVED	MechanicProfile	0d1b1de5-fb9c-4c50-a6ea-9632c885d0d7	{"notes": "ASE Master Certificate #88391 confirmed valid with State Board.", "newStatus": "APPROVED", "previousStatus": "PENDING", "technicianEmail": "m6.pending.mech.1795345105502@vbrs.local"}	\N	\N	2026-11-22 10:58:26.445
20699a98-9337-4082-b05f-7883540516fb	20e961e5-4364-4013-ac83-b3cdac902909	COMPLAINT_FILED	Complaint	2cadaabb-2737-483f-8540-1a0a31f51212	{"subject": "Late Arrival & Tow Rig Discrepancy", "serviceRequestId": "cfcb4df3-b199-4ed3-9448-0f6165f70602"}	\N	\N	2026-11-22 10:58:26.464
f1543390-2724-42b9-a7e1-e86876fae35e	d8bcfbbb-5b9c-41f3-8c41-e601d5e105c3	COMPLAINT_STATUS_INVESTIGATING	Complaint	2cadaabb-2737-483f-8540-1a0a31f51212	{"toStatus": "INVESTIGATING", "fromStatus": "PENDING", "resolutionNotes": "Contacted fleet dispatch log to verify arterial traffic delay."}	\N	\N	2026-11-22 10:58:26.499
8c6ab8b3-53a4-437c-ac9f-d721a8d2a836	d8bcfbbb-5b9c-41f3-8c41-e601d5e105c3	COMPLAINT_STATUS_RESOLVED	Complaint	2cadaabb-2737-483f-8540-1a0a31f51212	{"toStatus": "RESOLVED", "fromStatus": "INVESTIGATING", "resolutionNotes": "Traffic bottleneck verified on camera feed. Courtesy credit applied."}	\N	\N	2026-11-22 10:58:26.51
9ef7b4e7-bf20-4d65-ae05-b29a9522ed00	4c460def-df40-44ae-85e2-abc656c5c0da	USER_REGISTERED	User	4c460def-df40-44ae-85e2-abc656c5c0da	{"role": "ADMIN", "email": "m6.admin.1795345132328@vbrs.local"}	\N	\N	2026-11-22 10:58:52.695
6d77cf1a-801f-4071-b7b6-046d383a7f8e	a180a88c-5a9a-4731-add7-99d767857c44	USER_REGISTERED	User	a180a88c-5a9a-4731-add7-99d767857c44	{"role": "CUSTOMER", "email": "m6.customer.1795345132328@vbrs.local"}	\N	\N	2026-11-22 10:58:52.941
8673da58-139e-4239-ad71-b9bc605d921f	6f799c5a-2d5d-417b-9baa-f7b0c803557a	USER_REGISTERED	User	6f799c5a-2d5d-417b-9baa-f7b0c803557a	{"role": "MECHANIC", "email": "m6.pending.mech.1795345132328@vbrs.local"}	\N	\N	2026-11-22 10:58:53.18
11a9012f-2d11-4db2-ba6e-54e2aa444d5c	a180a88c-5a9a-4731-add7-99d767857c44	BREAKDOWN_REPORT_CREATED	BreakdownReport	0fb0713e-6959-4252-9617-409ed77d5d0b	{"category": "BRAKE_SYSTEM_FAILURE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 10:58:53.21
c43f5b01-54ed-4f64-a988-6d9631bf70f5	4c460def-df40-44ae-85e2-abc656c5c0da	MECHANIC_VERIFICATION_APPROVED	MechanicProfile	0a61aad9-8b92-44d4-a3cc-1eb4ec5ad4a1	{"notes": "ASE Master Certificate #88391 confirmed valid with State Board.", "newStatus": "APPROVED", "previousStatus": "PENDING", "technicianEmail": "m6.pending.mech.1795345132328@vbrs.local"}	\N	\N	2026-11-22 10:58:53.261
0878632e-1fc1-4199-b01c-0615eb1517c4	a180a88c-5a9a-4731-add7-99d767857c44	COMPLAINT_FILED	Complaint	8a0ade19-abd3-4bfb-bb21-4369a97fd3fc	{"subject": "Late Arrival & Tow Rig Discrepancy", "serviceRequestId": "46de9cc7-0ffd-4f17-934b-809a3ff3be0e"}	\N	\N	2026-11-22 10:58:53.279
39b10e0d-122a-452d-bb95-c6d991e434de	4c460def-df40-44ae-85e2-abc656c5c0da	COMPLAINT_STATUS_INVESTIGATING	Complaint	8a0ade19-abd3-4bfb-bb21-4369a97fd3fc	{"toStatus": "INVESTIGATING", "fromStatus": "PENDING", "resolutionNotes": "Contacted fleet dispatch log to verify arterial traffic delay."}	\N	\N	2026-11-22 10:58:53.317
52662850-f7e2-453b-8817-6f17af81aaf5	4c460def-df40-44ae-85e2-abc656c5c0da	COMPLAINT_STATUS_RESOLVED	Complaint	8a0ade19-abd3-4bfb-bb21-4369a97fd3fc	{"toStatus": "RESOLVED", "fromStatus": "INVESTIGATING", "resolutionNotes": "Traffic bottleneck verified on camera feed. Courtesy credit applied."}	\N	\N	2026-11-22 10:58:53.334
5e8fdc05-8230-486d-98e0-83672e746c78	02768d0a-f84d-490d-9480-615e95224db6	USER_REGISTERED	User	02768d0a-f84d-490d-9480-615e95224db6	{"role": "ADMIN", "email": "m6.admin.1795345149818@vbrs.local"}	\N	\N	2026-11-22 10:59:10.281
a1c87179-61be-4d5a-8772-767d2f878e5a	2ae75f04-e851-4d24-81dc-67588ba24232	USER_REGISTERED	User	2ae75f04-e851-4d24-81dc-67588ba24232	{"role": "CUSTOMER", "email": "m6.customer.1795345149818@vbrs.local"}	\N	\N	2026-11-22 10:59:10.582
0b8c5f4d-1e89-4fa1-b296-02378319b93b	6f863f00-571b-44cc-a075-aa555329997f	USER_REGISTERED	User	6f863f00-571b-44cc-a075-aa555329997f	{"role": "MECHANIC", "email": "m6.pending.mech.1795345149818@vbrs.local"}	\N	\N	2026-11-22 10:59:10.878
c1b68c33-caf0-4ff9-889f-9f7735970db3	2ae75f04-e851-4d24-81dc-67588ba24232	BREAKDOWN_REPORT_CREATED	BreakdownReport	356f7a77-62de-4030-8ff7-bc494a984788	{"category": "BRAKE_SYSTEM_FAILURE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 10:59:10.918
6fb5ee8e-a27f-4893-8cc9-262745698e6c	02768d0a-f84d-490d-9480-615e95224db6	MECHANIC_VERIFICATION_APPROVED	MechanicProfile	c4fae49e-0427-418d-b5b7-030c3343c488	{"notes": "ASE Master Certificate #88391 confirmed valid with State Board.", "newStatus": "APPROVED", "previousStatus": "PENDING", "technicianEmail": "m6.pending.mech.1795345149818@vbrs.local"}	\N	\N	2026-11-22 10:59:10.998
4e1e1301-0612-45e4-8a01-0a18757dca07	2ae75f04-e851-4d24-81dc-67588ba24232	COMPLAINT_FILED	Complaint	834eb098-3585-440b-b1f8-41f8d4f2b083	{"subject": "Late Arrival & Tow Rig Discrepancy", "serviceRequestId": "0c60b08f-e918-4c69-a585-045e9c65ff7d"}	\N	\N	2026-11-22 10:59:11.02
477cb768-0d85-4d71-a77e-83ac7d42f5ab	02768d0a-f84d-490d-9480-615e95224db6	COMPLAINT_STATUS_INVESTIGATING	Complaint	834eb098-3585-440b-b1f8-41f8d4f2b083	{"toStatus": "INVESTIGATING", "fromStatus": "PENDING", "resolutionNotes": "Contacted fleet dispatch log to verify arterial traffic delay."}	\N	\N	2026-11-22 10:59:11.064
332cfb51-1589-4845-8521-78eb1f6021b9	c93c737a-04f0-431c-827c-5f260c78cf87	USER_REGISTERED	User	c93c737a-04f0-431c-827c-5f260c78cf87	{"role": "CUSTOMER", "email": "audit.customer.1795345150583@vbrs.local"}	\N	\N	2026-11-22 10:59:11.068
f5bd12e8-989f-49d2-9f21-fd36ecc7e63a	02768d0a-f84d-490d-9480-615e95224db6	COMPLAINT_STATUS_RESOLVED	Complaint	834eb098-3585-440b-b1f8-41f8d4f2b083	{"toStatus": "RESOLVED", "fromStatus": "INVESTIGATING", "resolutionNotes": "Traffic bottleneck verified on camera feed. Courtesy credit applied."}	\N	\N	2026-11-22 10:59:11.077
e7047751-b0ef-4cdb-97d4-7b2d56595d00	b342c509-acd4-40e2-9a9e-a576fa6e5061	USER_REGISTERED	User	b342c509-acd4-40e2-9a9e-a576fa6e5061	{"role": "CUSTOMER", "email": "m2.customer.1795345150616@vbrs.local"}	\N	\N	2026-11-22 10:59:11.106
df1832b3-2fbd-4382-b89b-294379b82393	49c5925b-fda2-4bcc-b6b0-87b387231f58	USER_REGISTERED	User	49c5925b-fda2-4bcc-b6b0-87b387231f58	{"role": "CUSTOMER", "email": "m4.customer.1795345150708@vbrs.local"}	\N	\N	2026-11-22 10:59:11.17
d5b21c70-3de4-4232-a0f5-450f9ef3a34b	23e55200-8e86-4e87-92e2-b55e228b92f3	USER_REGISTERED	User	23e55200-8e86-4e87-92e2-b55e228b92f3	{"role": "CUSTOMER", "email": "m3.customer.1795345150749@vbrs.local"}	\N	\N	2026-11-22 10:59:11.212
e9075e66-9fc1-4325-9d48-afb6d15177ed	11947c9d-6f0f-425d-b26d-1cd07a25138a	USER_REGISTERED	User	11947c9d-6f0f-425d-b26d-1cd07a25138a	{"role": "CUSTOMER", "email": "m5.cust1.1795345150789@vbrs.local"}	\N	\N	2026-11-22 10:59:11.219
3a6900ca-380b-429d-8fff-1ee96ba53a13	245a9356-c816-4507-8269-0fc18dd346f9	USER_REGISTERED	User	245a9356-c816-4507-8269-0fc18dd346f9	{"role": "CUSTOMER", "email": "m3.edge.custa.1795345150764@vbrs.local"}	\N	\N	2026-11-22 10:59:11.225
d8451e29-9ac8-4af1-a19b-be3dc5aae1fd	c1c59c54-9a85-4892-957a-65df00abe10f	USER_REGISTERED	User	c1c59c54-9a85-4892-957a-65df00abe10f	{"role": "MECHANIC", "email": "audit.mechanic.1795345150583@vbrs.local"}	\N	\N	2026-11-22 10:59:11.342
3cc1d300-f2c4-4e1b-9568-f5fbe33244f2	b342c509-acd4-40e2-9a9e-a576fa6e5061	USER_LOGGED_IN	User	b342c509-acd4-40e2-9a9e-a576fa6e5061	\N	\N	\N	2026-11-22 10:59:11.384
7af69f27-0706-4093-807e-9e3050762ad1	459fd1f2-01ce-465d-b584-90ce7e7c8297	USER_REGISTERED	User	459fd1f2-01ce-465d-b584-90ce7e7c8297	{"role": "MECHANIC", "email": "m4.mech1.1795345150708@vbrs.local"}	\N	\N	2026-11-22 10:59:11.428
42a1b472-a1f4-4634-b6b4-a0a809dfcbac	0e56d598-d475-40e8-9e5e-8a18e9c9c26c	USER_REGISTERED	User	0e56d598-d475-40e8-9e5e-8a18e9c9c26c	{"role": "CUSTOMER", "email": "m3.userb.1795345150749@vbrs.local"}	\N	\N	2026-11-22 10:59:11.464
265286cb-9c81-4e8e-a326-564a93233547	a8f2696e-55dc-4a9b-97f3-8bffbcf18c45	USER_REGISTERED	User	a8f2696e-55dc-4a9b-97f3-8bffbcf18c45	{"role": "CUSTOMER", "email": "m5.cust2.1795345150789@vbrs.local"}	\N	\N	2026-11-22 10:59:11.467
823e6973-13a5-4863-977d-389858b2ec19	e4414a47-df1f-4ad5-9049-bf14c3ed41cc	USER_REGISTERED	User	e4414a47-df1f-4ad5-9049-bf14c3ed41cc	{"role": "CUSTOMER", "email": "m3.edge.custb.1795345150764@vbrs.local"}	\N	\N	2026-11-22 10:59:11.478
671c06aa-e9bc-4fa1-b6df-471e62f30a9d	23e55200-8e86-4e87-92e2-b55e228b92f3	BREAKDOWN_REPORT_CREATED	BreakdownReport	d344af6f-43a1-4062-894c-f5a74b153061	{"category": "ENGINE_FAILURE", "severity": "CRITICAL", "imageCount": 1, "requiresTowing": true}	\N	\N	2026-11-22 10:59:11.525
4df74fed-a1d4-467d-919f-0c86ec2cd3e6	23e55200-8e86-4e87-92e2-b55e228b92f3	BREAKDOWN_REPORT_CREATED	BreakdownReport	6e0769cf-4206-4c87-adf3-2c0306c5b847	{"category": "FLAT_TIRE_WHEEL", "severity": "LOW", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:59:11.553
62603886-2b8d-494f-9acb-a2dd6f2cf72d	c93c737a-04f0-431c-827c-5f260c78cf87	USER_LOGGED_IN	User	c93c737a-04f0-431c-827c-5f260c78cf87	\N	\N	\N	2026-11-22 10:59:11.594
1900e9dd-f760-4bea-9a13-6df35d330fee	b342c509-acd4-40e2-9a9e-a576fa6e5061	VEHICLE_ADDED	Vehicle	491e5c87-bc7b-4086-9301-3c631be02b79	{"make": "Ford", "model": "Mustang Mach-E", "plate": "M2-1666"}	\N	\N	2026-11-22 10:59:11.68
eea09252-819f-4f17-ad4e-8165604f1e49	14397d2c-11bd-4647-babe-a86165af58d4	USER_REGISTERED	User	14397d2c-11bd-4647-babe-a86165af58d4	{"role": "MECHANIC", "email": "m4.mech2.1795345150708@vbrs.local"}	\N	\N	2026-11-22 10:59:11.687
9dd9538a-4db7-4728-a87f-c42ad604936f	b342c509-acd4-40e2-9a9e-a576fa6e5061	VEHICLE_UPDATED	Vehicle	491e5c87-bc7b-4086-9301-3c631be02b79	\N	\N	\N	2026-11-22 10:59:11.716
4bf2ca74-570e-477f-bcf5-6131fd6f9adc	49c5925b-fda2-4bcc-b6b0-87b387231f58	BREAKDOWN_REPORT_CREATED	BreakdownReport	4041c645-eab7-49c3-9d38-1c9fafb5dde0	{"category": "FLAT_TIRE_WHEEL", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:59:11.72
5d1d9698-2d89-423e-9da4-4baf507f719d	04a4b6cb-3c82-45bb-acab-d78e0713971a	USER_REGISTERED	User	04a4b6cb-3c82-45bb-acab-d78e0713971a	{"role": "MECHANIC", "email": "m5.mech1.1795345150789@vbrs.local"}	\N	\N	2026-11-22 10:59:11.724
64871313-cdb2-4297-94ac-5273e0e77cfc	e840f0bf-ae92-4006-aa6a-de7fc0c1873d	USER_REGISTERED	User	e840f0bf-ae92-4006-aa6a-de7fc0c1873d	{"role": "MECHANIC", "email": "m3.edge.mech.1795345150764@vbrs.local"}	\N	\N	2026-11-22 10:59:11.729
8f0f328f-3d20-4041-a5d9-2264b608559e	b342c509-acd4-40e2-9a9e-a576fa6e5061	VEHICLE_DELETED	Vehicle	491e5c87-bc7b-4086-9301-3c631be02b79	{"plate": "M2-1666"}	\N	\N	2026-11-22 10:59:11.742
46b0c129-ca54-47b7-8da5-91fad7e74877	245a9356-c816-4507-8269-0fc18dd346f9	VEHICLE_ADDED	Vehicle	f4f34e7f-632a-4c44-9dac-dd01760a638f	{"make": "Porsche", "model": "911 GT3", "plate": "EDGE-A-1735"}	\N	\N	2026-11-22 10:59:11.753
70c2200f-d5ce-43a8-884a-152296990981	b342c509-acd4-40e2-9a9e-a576fa6e5061	USER_LOGGED_OUT	User	b342c509-acd4-40e2-9a9e-a576fa6e5061	\N	\N	\N	2026-11-22 10:59:11.758
cb582983-6a9a-4e9d-857a-fe378a57e338	e4414a47-df1f-4ad5-9049-bf14c3ed41cc	VEHICLE_ADDED	Vehicle	68e94048-003e-44ef-9279-e9aea1e4871a	{"make": "Tesla", "model": "Model S Plaid", "plate": "EDGE-B-1756"}	\N	\N	2026-11-22 10:59:11.765
a946d141-07fb-468b-8b6f-8c9f5e012460	c1c59c54-9a85-4892-957a-65df00abe10f	USER_LOGGED_IN	User	c1c59c54-9a85-4892-957a-65df00abe10f	\N	\N	\N	2026-11-22 10:59:11.834
fa787f20-950f-4376-9275-dac5a2433cdd	245a9356-c816-4507-8269-0fc18dd346f9	BREAKDOWN_REPORT_CREATED	BreakdownReport	55e388e0-043b-4202-96e8-652a34019aff	{"category": "COLLISION_ACCIDENT", "severity": "CRITICAL", "imageCount": 5, "requiresTowing": true}	\N	\N	2026-11-22 10:59:11.854
93752086-ef3f-4bfc-b6c1-3115591f633f	245a9356-c816-4507-8269-0fc18dd346f9	BREAKDOWN_REPORT_CREATED	BreakdownReport	9cc682bc-3f0d-49cb-8d74-a50b0a2c1f64	{"category": "BRAKE_SYSTEM_FAILURE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 10:59:11.93
3c055e30-fa70-4f5c-864d-877e2a0017c4	459fd1f2-01ce-465d-b584-90ce7e7c8297	DISPATCH_ACCEPTED	ServiceRequest	283252d6-d0b6-4be3-89db-41879add66e3	{"mechanicId": "a75ec860-72f8-4ab3-84f5-503a8ae57676", "breakdownReportId": "4041c645-eab7-49c3-9d38-1c9fafb5dde0"}	\N	\N	2026-11-22 10:59:11.958
e416836b-3b2e-407f-87d1-141d9d5ed0aa	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 10:59:12.085
395f787a-509c-4314-9a49-5b496d0e51e6	245a9356-c816-4507-8269-0fc18dd346f9	BREAKDOWN_REPORT_CREATED	BreakdownReport	3983c895-de71-4f78-a820-71f8d744ad5f	{"category": "BATTERY_DEAD_ELECTRICAL", "severity": "MEDIUM", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 10:59:11.975
7501fc53-8ada-4718-802f-55f19395e22d	245a9356-c816-4507-8269-0fc18dd346f9	BREAKDOWN_REPORT_CREATED	BreakdownReport	d23ddb79-7494-446a-8054-b9d150bf8d0a	{"category": "TRANSMISSION_ISSUE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 10:59:12.004
4a6869ca-1acb-4111-99f5-4711d1762e23	245a9356-c816-4507-8269-0fc18dd346f9	BREAKDOWN_REPORT_CREATED	BreakdownReport	030263f0-7c25-4dff-bc45-b4a438485bb9	{"category": "FUEL_EMPTY_OR_CONTAMINATED", "severity": "LOW", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:59:12.043
e55320ff-1ab5-4437-8d19-a0a37f514241	245a9356-c816-4507-8269-0fc18dd346f9	BREAKDOWN_REPORT_CREATED	BreakdownReport	71b0773e-ebf7-4244-a6a6-9dc933b7f8d8	{"category": "OVERHEATING_COOLANT", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:59:12.059
4d20394d-07bd-4822-a4e7-07ed7138fa5e	245a9356-c816-4507-8269-0fc18dd346f9	BREAKDOWN_REPORT_CREATED	BreakdownReport	e00d1b38-6c85-4b2f-87aa-30dae9d24a31	{"category": "LOCKOUT_KEY_LOST", "severity": "LOW", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 10:59:12.096
365ce4ca-1771-471c-92c1-5d3ccf9a5456	d3f75e7f-79cd-4f70-8bf5-d71a46c0c651	USER_REGISTERED	User	d3f75e7f-79cd-4f70-8bf5-d71a46c0c651	{"role": "MECHANIC", "email": "m5.mech2.1795345150789@vbrs.local"}	\N	\N	2026-11-22 10:59:11.988
c504df5a-01bb-4453-9a03-3b79f0c64482	35de3760-92fd-4769-9d8c-11acf299ce83	USER_REGISTERED	User	35de3760-92fd-4769-9d8c-11acf299ce83	{"role": "ADMIN", "email": "m5.admin.1795345150789@vbrs.local"}	\N	\N	2026-11-22 10:59:12.226
a42e750d-b5fb-49bb-bd6d-5bf7db60f461	11947c9d-6f0f-425d-b26d-1cd07a25138a	BREAKDOWN_REPORT_CREATED	BreakdownReport	03ae0a20-4f05-42c1-86d2-ffd0a983be28	{"category": "ENGINE_FAILURE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 10:59:12.256
80da5832-8339-4648-a39b-5c4e10b19faa	04a4b6cb-3c82-45bb-acab-d78e0713971a	DISPATCH_ACCEPTED	ServiceRequest	1de5bce5-6431-4d04-a84f-ea33e64551cd	{"mechanicId": "60596275-9d97-4592-812b-ef52c5d5734a", "breakdownReportId": "03ae0a20-4f05-42c1-86d2-ffd0a983be28"}	\N	\N	2026-11-22 10:59:12.286
d6f06b4a-e85e-4f6a-9fe8-c144fb0c4984	04a4b6cb-3c82-45bb-acab-d78e0713971a	SERVICE_STATUS_EN_ROUTE	ServiceRequest	1de5bce5-6431-4d04-a84f-ea33e64551cd	{"notes": "Technician departed garage; en route via arterial highway.", "toStatus": "EN_ROUTE", "fromStatus": "ACCEPTED"}	\N	\N	2026-11-22 10:59:12.403
7769883f-25db-4942-93cc-0ab3c5b181be	04a4b6cb-3c82-45bb-acab-d78e0713971a	SERVICE_STATUS_ARRIVED	ServiceRequest	1de5bce5-6431-4d04-a84f-ea33e64551cd	{"notes": "Arrived at incident site; positioning emergency safety cones.", "toStatus": "ARRIVED", "fromStatus": "EN_ROUTE"}	\N	\N	2026-11-22 10:59:12.431
471fb5bb-9c80-4480-a943-a88e09771652	04a4b6cb-3c82-45bb-acab-d78e0713971a	SERVICE_STATUS_IN_PROGRESS	ServiceRequest	1de5bce5-6431-4d04-a84f-ea33e64551cd	{"notes": "Disassembled ignition harness; installing new OEM coils.", "toStatus": "IN_PROGRESS", "fromStatus": "ARRIVED"}	\N	\N	2026-11-22 10:59:12.542
06a78c5a-979c-4850-8264-d9f0c4cba9e1	04a4b6cb-3c82-45bb-acab-d78e0713971a	SERVICE_STATUS_COMPLETED	ServiceRequest	1de5bce5-6431-4d04-a84f-ea33e64551cd	{"toStatus": "COMPLETED", "fromStatus": "IN_PROGRESS"}	\N	\N	2026-11-22 10:59:12.569
b1d5061a-df07-4859-bcc7-514bc1f22dfa	11947c9d-6f0f-425d-b26d-1cd07a25138a	BREAKDOWN_REPORT_CREATED	BreakdownReport	048050d1-e8b9-4e1a-8210-ba60f9268ff8	{"category": "FLAT_TIRE_WHEEL", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 10:59:12.618
fd4b3346-f141-47c1-8e0a-8b17184ad1db	04a4b6cb-3c82-45bb-acab-d78e0713971a	DISPATCH_ACCEPTED	ServiceRequest	94d757d5-a968-4f25-b8c3-e11713ac4303	{"mechanicId": "60596275-9d97-4592-812b-ef52c5d5734a", "breakdownReportId": "048050d1-e8b9-4e1a-8210-ba60f9268ff8"}	\N	\N	2026-11-22 10:59:12.637
2801999c-7c74-4e41-af6a-e71b9bb468cd	11947c9d-6f0f-425d-b26d-1cd07a25138a	SERVICE_STATUS_CANCELLED	ServiceRequest	94d757d5-a968-4f25-b8c3-e11713ac4303	{"notes": "Cancellation reason: Spare tire located; vehicle changed independently.", "toStatus": "CANCELLED", "fromStatus": "ACCEPTED", "cancellationReason": "Spare tire located; vehicle changed independently."}	\N	\N	2026-11-22 10:59:12.656
60e91331-8f8b-4f18-a980-7063ef35da36	1e062702-c6de-4826-a848-4c15c3b0a27c	USER_REGISTERED	User	1e062702-c6de-4826-a848-4c15c3b0a27c	{"role": "CUSTOMER", "email": "audit.userb.1795345150583@vbrs.local"}	\N	\N	2026-11-22 10:59:12.566
5e720924-08e3-4377-8d21-c69f3b9c6b66	c93c737a-04f0-431c-827c-5f260c78cf87	VEHICLE_ADDED	Vehicle	e372ef4b-4b06-4205-8249-1719f2386347	{"make": "Porsche", "model": "Taycan GTS", "plate": "AUD-0585"}	\N	\N	2026-11-22 10:59:13.082
731e6771-d7c2-434b-8de8-60368368713a	c93c737a-04f0-431c-827c-5f260c78cf87	VEHICLE_UPDATED	Vehicle	e372ef4b-4b06-4205-8249-1719f2386347	\N	\N	\N	2026-11-22 10:59:13.104
0f9f8aea-e296-4431-9a76-2405369b695a	c93c737a-04f0-431c-827c-5f260c78cf87	VEHICLE_DELETED	Vehicle	e372ef4b-4b06-4205-8249-1719f2386347	{"plate": "AUD-0585"}	\N	\N	2026-11-22 10:59:13.13
78bef0e1-74fc-4f67-a70d-feb8288ac119	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 11:06:02.688
4fcb08c5-3958-4ee9-be8b-bb37860cfee7	a3a45b01-9ac2-4382-9551-68f1762d33c2	MECHANIC_VERIFICATION_APPROVED	MechanicProfile	15de8912-b812-4f41-a847-2b114d96e37a	{"notes": "E2E Audit Verification: Trade license and ASE certifications verified with state registry.", "newStatus": "APPROVED", "previousStatus": "PENDING", "technicianEmail": "m5.mech2.1795345150789@vbrs.local"}	\N	\N	2026-11-22 11:06:04.023
fce3c5f7-8ddb-46d6-a9fc-adc7e39ba5f7	a3a45b01-9ac2-4382-9551-68f1762d33c2	COMPLAINT_STATUS_RESOLVED	Complaint	834eb098-3585-440b-b1f8-41f8d4f2b083	{"toStatus": "RESOLVED", "fromStatus": "RESOLVED", "resolutionNotes": "E2E Resolution: Motorist and certified technician mutually agreed on final diagnostic adjustment."}	\N	\N	2026-11-22 11:06:06.62
0fc8cdae-babd-46c9-9c9c-ff6bfda3f09e	4bc6bd4b-da8e-4372-8bac-0333b1e85ab1	USER_REGISTERED	User	4bc6bd4b-da8e-4372-8bac-0333b1e85ab1	{"role": "CUSTOMER", "email": "m4.customer.1795345590894@vbrs.local"}	\N	\N	2026-11-22 11:06:31.426
e89eb0ac-5605-4c56-83c5-d941bd31d66d	1302fef8-4b27-4105-8596-a34489c6c8a0	USER_REGISTERED	User	1302fef8-4b27-4105-8596-a34489c6c8a0	{"role": "CUSTOMER", "email": "m5.cust1.1795345590904@vbrs.local"}	\N	\N	2026-11-22 11:06:31.429
9689c62d-65f3-483e-b383-e0ff165e320e	52982a88-12e7-4a4c-aafc-6534a8542ddb	USER_REGISTERED	User	52982a88-12e7-4a4c-aafc-6534a8542ddb	{"role": "ADMIN", "email": "m6.admin.1795345591025@vbrs.local"}	\N	\N	2026-11-22 11:06:31.503
1d62ae61-0f0e-444c-b25d-367627ae2548	6f0c5a39-62c6-49b0-9305-3747a819cf83	USER_REGISTERED	User	6f0c5a39-62c6-49b0-9305-3747a819cf83	{"role": "CUSTOMER", "email": "m3.customer.1795345591025@vbrs.local"}	\N	\N	2026-11-22 11:06:31.529
c2e61e94-4c8f-4a51-9279-44f0c80e5131	6eb0337a-0d67-46c4-8936-66203ebb5009	USER_REGISTERED	User	6eb0337a-0d67-46c4-8936-66203ebb5009	{"role": "CUSTOMER", "email": "audit.customer.1795345591012@vbrs.local"}	\N	\N	2026-11-22 11:06:31.541
13020aae-839f-412e-addd-ff3dd6b8e4e0	3ef04ba8-1823-457e-bdf2-2741130aa339	USER_REGISTERED	User	3ef04ba8-1823-457e-bdf2-2741130aa339	{"role": "CUSTOMER", "email": "m2.customer.1795345591034@vbrs.local"}	\N	\N	2026-11-22 11:06:31.551
31838297-396e-41fb-bb64-76d33b9ef654	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	USER_REGISTERED	User	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	{"role": "CUSTOMER", "email": "m3.edge.custa.1795345591031@vbrs.local"}	\N	\N	2026-11-22 11:06:31.555
be6eac49-e23e-4c7f-b576-e9af215ec46e	7b0dbcf4-d748-4a20-b6b8-1429d8471663	USER_REGISTERED	User	7b0dbcf4-d748-4a20-b6b8-1429d8471663	{"role": "CUSTOMER", "email": "m5.cust2.1795345590904@vbrs.local"}	\N	\N	2026-11-22 11:06:31.729
ec96a65b-21d9-4e26-9ec3-c41e0d3ce011	29db8df8-1b56-42f1-9da5-e687727e448e	USER_REGISTERED	User	29db8df8-1b56-42f1-9da5-e687727e448e	{"role": "MECHANIC", "email": "m4.mech1.1795345590894@vbrs.local"}	\N	\N	2026-11-22 11:06:31.732
1e0e268a-704b-4ec0-bd3b-b705195adcc7	15372eae-1d2d-4d1b-af92-e71b76d3393e	USER_REGISTERED	User	15372eae-1d2d-4d1b-af92-e71b76d3393e	{"role": "CUSTOMER", "email": "m6.customer.1795345591025@vbrs.local"}	\N	\N	2026-11-22 11:06:31.806
e3152b22-80e2-41e1-9237-d2c624557fb0	7c98ba9a-4b3d-4780-8493-facdc9ec499f	USER_REGISTERED	User	7c98ba9a-4b3d-4780-8493-facdc9ec499f	{"role": "CUSTOMER", "email": "m3.userb.1795345591025@vbrs.local"}	\N	\N	2026-11-22 11:06:31.835
8f7e5b7a-4aa0-45d8-bc70-41c7dad1bf99	4d62bb62-77c2-48f9-8e07-3e9ea0a6a73d	USER_REGISTERED	User	4d62bb62-77c2-48f9-8e07-3e9ea0a6a73d	{"role": "MECHANIC", "email": "audit.mechanic.1795345591012@vbrs.local"}	\N	\N	2026-11-22 11:06:31.85
ae8b289f-375d-4597-be69-a570ef661825	3ef04ba8-1823-457e-bdf2-2741130aa339	USER_LOGGED_IN	User	3ef04ba8-1823-457e-bdf2-2741130aa339	\N	\N	\N	2026-11-22 11:06:31.862
903f56cb-e7f7-4466-8014-89f687370590	ebdad843-b10b-492a-b5bb-4ae10b4e5340	USER_REGISTERED	User	ebdad843-b10b-492a-b5bb-4ae10b4e5340	{"role": "CUSTOMER", "email": "m3.edge.custb.1795345591031@vbrs.local"}	\N	\N	2026-11-22 11:06:31.863
a0b9923a-7810-4be0-8809-e63386e23473	6f0c5a39-62c6-49b0-9305-3747a819cf83	BREAKDOWN_REPORT_CREATED	BreakdownReport	93aa1a4b-ca37-41db-9b99-f4f29405b397	{"category": "ENGINE_FAILURE", "severity": "CRITICAL", "imageCount": 1, "requiresTowing": true}	\N	\N	2026-11-22 11:06:31.896
9205d7d3-d835-4c9c-b339-79333d58fb1c	6f0c5a39-62c6-49b0-9305-3747a819cf83	BREAKDOWN_REPORT_CREATED	BreakdownReport	6859dfb4-688b-4470-bbe7-fff1440dd235	{"category": "FLAT_TIRE_WHEEL", "severity": "LOW", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:06:31.922
19d39257-444e-4d44-bbf8-64e1f7cc500f	91e6be61-ca06-4bb8-9843-38b5edc72e0b	USER_REGISTERED	User	91e6be61-ca06-4bb8-9843-38b5edc72e0b	{"role": "MECHANIC", "email": "m5.mech1.1795345590904@vbrs.local"}	\N	\N	2026-11-22 11:06:32.002
7a3beb56-f94a-4b31-ace0-ef58456ccf23	3ea42b7f-99a0-4120-991f-7047bbb58050	USER_REGISTERED	User	3ea42b7f-99a0-4120-991f-7047bbb58050	{"role": "MECHANIC", "email": "m4.mech2.1795345590894@vbrs.local"}	\N	\N	2026-11-22 11:06:32.032
ed0c0e5d-4c46-4e17-80c4-9a37a3cb45ea	4bc6bd4b-da8e-4372-8bac-0333b1e85ab1	BREAKDOWN_REPORT_CREATED	BreakdownReport	3d2d1e51-9774-4695-a9b9-fa0b3220a39a	{"category": "FLAT_TIRE_WHEEL", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:06:32.077
64221fc6-5c21-460d-a402-0de03f0d0a8a	6b36993f-4add-41d2-aa57-89b13b0ed876	USER_REGISTERED	User	6b36993f-4add-41d2-aa57-89b13b0ed876	{"role": "MECHANIC", "email": "m6.pending.mech.1795345591025@vbrs.local"}	\N	\N	2026-11-22 11:06:32.086
d277282b-04e9-431e-9a63-36e718e93bcc	15372eae-1d2d-4d1b-af92-e71b76d3393e	BREAKDOWN_REPORT_CREATED	BreakdownReport	f8d491ec-cbde-4ea3-a381-a9119fac61bf	{"category": "BRAKE_SYSTEM_FAILURE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 11:06:32.126
e016a45e-b2f6-468d-9114-db58e16b384d	6eb0337a-0d67-46c4-8936-66203ebb5009	USER_LOGGED_IN	User	6eb0337a-0d67-46c4-8936-66203ebb5009	\N	\N	\N	2026-11-22 11:06:32.134
59706804-93c3-470d-9187-c56c6e12957a	44add884-dad8-4e5a-a51f-c16a642f3873	USER_REGISTERED	User	44add884-dad8-4e5a-a51f-c16a642f3873	{"role": "MECHANIC", "email": "m3.edge.mech.1795345591031@vbrs.local"}	\N	\N	2026-11-22 11:06:32.156
c7721f74-0f1e-45bf-96c6-82bd7d51008e	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	VEHICLE_ADDED	Vehicle	fe3f2481-0fd6-44af-9faf-2ea950606f85	{"make": "Porsche", "model": "911 GT3", "plate": "EDGE-A-2167"}	\N	\N	2026-11-22 11:06:32.19
66432ba9-bcd4-4a99-b073-323872319ac9	ebdad843-b10b-492a-b5bb-4ae10b4e5340	VEHICLE_ADDED	Vehicle	29b5fa80-b00c-49c8-8379-387453514cbf	{"make": "Tesla", "model": "Model S Plaid", "plate": "EDGE-B-2194"}	\N	\N	2026-11-22 11:06:32.207
8f8f2aa1-59d8-49af-8566-d941ae8901fb	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	BREAKDOWN_REPORT_CREATED	BreakdownReport	845e6757-b885-4e3a-bbed-6c57749bd625	{"category": "COLLISION_ACCIDENT", "severity": "CRITICAL", "imageCount": 5, "requiresTowing": true}	\N	\N	2026-11-22 11:06:32.329
3e29fa39-5ebf-4623-9319-f18123c8a57b	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	BREAKDOWN_REPORT_CREATED	BreakdownReport	b82016f6-9dd1-4f11-a746-4550ebf6f96d	{"category": "BRAKE_SYSTEM_FAILURE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 11:06:32.4
26193c77-09e6-4b85-acfa-5772ac7a1e61	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	BREAKDOWN_REPORT_CREATED	BreakdownReport	250c2a5b-9c33-4b33-aba6-cf5c2162e9fd	{"category": "BATTERY_DEAD_ELECTRICAL", "severity": "MEDIUM", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 11:06:32.434
f228c4bf-aa4d-42be-a8d6-61dead92c401	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	BREAKDOWN_REPORT_CREATED	BreakdownReport	1b94f0f6-75c5-4580-bddf-c748edec2c94	{"category": "TRANSMISSION_ISSUE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 11:06:32.458
ff99e34c-fa05-4256-be08-6e57ebeffea7	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	BREAKDOWN_REPORT_CREATED	BreakdownReport	898cc3c8-4023-4798-a7b9-0d2be73fc7a7	{"category": "FUEL_EMPTY_OR_CONTAMINATED", "severity": "LOW", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:06:32.495
228c5c7a-ad46-4f4f-91a0-eb0d3ad0b49d	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	BREAKDOWN_REPORT_CREATED	BreakdownReport	9996c2aa-0bd0-4024-aa01-e6a55bc9d558	{"category": "OVERHEATING_COOLANT", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:06:32.512
121dd472-3b47-40df-90a1-be9881ba981a	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	BREAKDOWN_REPORT_CREATED	BreakdownReport	45337736-a7f4-4754-af92-d1009d3ac658	{"category": "LOCKOUT_KEY_LOST", "severity": "LOW", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 11:06:32.552
6cbcba65-f2e7-4438-85d4-3ff65376e9ea	3ef04ba8-1823-457e-bdf2-2741130aa339	VEHICLE_ADDED	Vehicle	3743e6b8-12f6-4a7a-a67e-5eba5f1b7242	{"make": "Ford", "model": "Mustang Mach-E", "plate": "M2-2191"}	\N	\N	2026-11-22 11:06:32.211
e87b0f6f-f8d1-4549-aca2-0d73a5b0a634	3ef04ba8-1823-457e-bdf2-2741130aa339	VEHICLE_UPDATED	Vehicle	3743e6b8-12f6-4a7a-a67e-5eba5f1b7242	\N	\N	\N	2026-11-22 11:06:32.262
ac50fb05-e729-4555-bc5d-26dc7aa06c6d	3ef04ba8-1823-457e-bdf2-2741130aa339	VEHICLE_DELETED	Vehicle	3743e6b8-12f6-4a7a-a67e-5eba5f1b7242	{"plate": "M2-2191"}	\N	\N	2026-11-22 11:06:32.293
6656bc70-fcb0-4995-8aee-ac04204a2c78	3ef04ba8-1823-457e-bdf2-2741130aa339	USER_LOGGED_OUT	User	3ef04ba8-1823-457e-bdf2-2741130aa339	\N	\N	\N	2026-11-22 11:06:32.318
e061efc8-793d-49e9-b4dd-e8ee97da5f5f	52982a88-12e7-4a4c-aafc-6534a8542ddb	MECHANIC_VERIFICATION_APPROVED	MechanicProfile	ca24de3e-f5f6-4277-8d98-0c3959824412	{"notes": "ASE Master Certificate #88391 confirmed valid with State Board.", "newStatus": "APPROVED", "previousStatus": "PENDING", "technicianEmail": "m6.pending.mech.1795345591025@vbrs.local"}	\N	\N	2026-11-22 11:06:32.221
d9df8410-e2c3-47b4-b2c6-6b4021028d75	15372eae-1d2d-4d1b-af92-e71b76d3393e	COMPLAINT_FILED	Complaint	0c46d018-93d4-44b4-921d-c8ebcdf336ac	{"subject": "Late Arrival & Tow Rig Discrepancy", "serviceRequestId": "903fc3ca-67b9-4e24-8310-97f0211dd5be"}	\N	\N	2026-11-22 11:06:32.247
5447ebd7-ebfa-4b29-a4e4-2020977edf24	52982a88-12e7-4a4c-aafc-6534a8542ddb	COMPLAINT_STATUS_INVESTIGATING	Complaint	0c46d018-93d4-44b4-921d-c8ebcdf336ac	{"toStatus": "INVESTIGATING", "fromStatus": "PENDING", "resolutionNotes": "Contacted fleet dispatch log to verify arterial traffic delay."}	\N	\N	2026-11-22 11:06:32.302
36a6d354-7a95-4f8f-b0c9-2045b5c1da55	52982a88-12e7-4a4c-aafc-6534a8542ddb	COMPLAINT_STATUS_RESOLVED	Complaint	0c46d018-93d4-44b4-921d-c8ebcdf336ac	{"toStatus": "RESOLVED", "fromStatus": "INVESTIGATING", "resolutionNotes": "Traffic bottleneck verified on camera feed. Courtesy credit applied."}	\N	\N	2026-11-22 11:06:32.321
660a93c8-fba6-44a1-a74f-5b17487d42ef	af870543-67bd-4053-a056-9cb0328c528c	USER_REGISTERED	User	af870543-67bd-4053-a056-9cb0328c528c	{"role": "MECHANIC", "email": "m5.mech2.1795345590904@vbrs.local"}	\N	\N	2026-11-22 11:06:32.291
0a691d55-1156-4884-90cf-3ebca0cb96fd	707b69df-c296-4059-9aa2-b0b8882b3c97	USER_REGISTERED	User	707b69df-c296-4059-9aa2-b0b8882b3c97	{"role": "ADMIN", "email": "m5.admin.1795345590904@vbrs.local"}	\N	\N	2026-11-22 11:06:32.553
8357b0be-e012-4e1a-94e7-c3c24e75252b	1302fef8-4b27-4105-8596-a34489c6c8a0	BREAKDOWN_REPORT_CREATED	BreakdownReport	7738f408-4034-4b3c-a39e-4028de0e74b3	{"category": "ENGINE_FAILURE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 11:06:32.587
7ce8cec7-e706-40a7-b8b0-ef35c4a66757	91e6be61-ca06-4bb8-9843-38b5edc72e0b	DISPATCH_ACCEPTED	ServiceRequest	efd1162e-7195-48b0-a84c-fac36036f0c8	{"mechanicId": "772e7702-913f-44cc-8c7e-3444b6741f61", "breakdownReportId": "7738f408-4034-4b3c-a39e-4028de0e74b3"}	\N	\N	2026-11-22 11:06:32.621
9fd17550-66fb-4c5a-af79-f3fa5d4a382f	91e6be61-ca06-4bb8-9843-38b5edc72e0b	SERVICE_STATUS_EN_ROUTE	ServiceRequest	efd1162e-7195-48b0-a84c-fac36036f0c8	{"notes": "Technician departed garage; en route via arterial highway.", "toStatus": "EN_ROUTE", "fromStatus": "ACCEPTED"}	\N	\N	2026-11-22 11:06:32.754
999b31aa-c836-4367-87bd-e6625d366090	91e6be61-ca06-4bb8-9843-38b5edc72e0b	SERVICE_STATUS_ARRIVED	ServiceRequest	efd1162e-7195-48b0-a84c-fac36036f0c8	{"notes": "Arrived at incident site; positioning emergency safety cones.", "toStatus": "ARRIVED", "fromStatus": "EN_ROUTE"}	\N	\N	2026-11-22 11:06:32.784
65716b49-4be8-4809-b47e-b690c06d174c	91e6be61-ca06-4bb8-9843-38b5edc72e0b	SERVICE_STATUS_IN_PROGRESS	ServiceRequest	efd1162e-7195-48b0-a84c-fac36036f0c8	{"notes": "Disassembled ignition harness; installing new OEM coils.", "toStatus": "IN_PROGRESS", "fromStatus": "ARRIVED"}	\N	\N	2026-11-22 11:06:32.902
9d7a94e1-be72-4b78-b073-19fea14e1ba2	91e6be61-ca06-4bb8-9843-38b5edc72e0b	SERVICE_STATUS_COMPLETED	ServiceRequest	efd1162e-7195-48b0-a84c-fac36036f0c8	{"toStatus": "COMPLETED", "fromStatus": "IN_PROGRESS"}	\N	\N	2026-11-22 11:06:32.933
7c72f6fb-7bc1-489d-b9db-dca8a93f2e5d	1302fef8-4b27-4105-8596-a34489c6c8a0	BREAKDOWN_REPORT_CREATED	BreakdownReport	6f9a06f2-600d-4535-8cd1-9ff04860f1b1	{"category": "FLAT_TIRE_WHEEL", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:06:32.991
a830eb7a-0065-4e62-ba77-d0f5bb86da3f	91e6be61-ca06-4bb8-9843-38b5edc72e0b	DISPATCH_ACCEPTED	ServiceRequest	750c2301-8f4b-4032-9c9a-9c8d1075b241	{"mechanicId": "772e7702-913f-44cc-8c7e-3444b6741f61", "breakdownReportId": "6f9a06f2-600d-4535-8cd1-9ff04860f1b1"}	\N	\N	2026-11-22 11:06:33.014
16062ae5-b92b-4b22-bfa6-d4156ee12985	1302fef8-4b27-4105-8596-a34489c6c8a0	SERVICE_STATUS_CANCELLED	ServiceRequest	750c2301-8f4b-4032-9c9a-9c8d1075b241	{"notes": "Cancellation reason: Spare tire located; vehicle changed independently.", "toStatus": "CANCELLED", "fromStatus": "ACCEPTED", "cancellationReason": "Spare tire located; vehicle changed independently."}	\N	\N	2026-11-22 11:06:33.037
c075e5ec-52ba-41de-9a7c-04d4f60250c0	29db8df8-1b56-42f1-9da5-e687727e448e	DISPATCH_ACCEPTED	ServiceRequest	1dad5bfe-ba6c-40b8-8db5-93a2bcb4b6da	{"mechanicId": "fd3e3a5e-79bc-4b18-9e45-c7dde1a28efe", "breakdownReportId": "3d2d1e51-9774-4695-a9b9-fa0b3220a39a"}	\N	\N	2026-11-22 11:06:32.374
f4d55233-a8e6-4786-bfd1-d17bb74e4ee4	4d62bb62-77c2-48f9-8e07-3e9ea0a6a73d	USER_LOGGED_IN	User	4d62bb62-77c2-48f9-8e07-3e9ea0a6a73d	\N	\N	\N	2026-11-22 11:06:32.406
3c1a6d3b-5732-4688-b991-43a0f82ecb7e	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 11:06:32.65
d26f1934-ca8f-4fa2-88e8-654d7c2a1246	c32cde07-3798-4427-9651-2e442500f687	USER_REGISTERED	User	c32cde07-3798-4427-9651-2e442500f687	{"role": "CUSTOMER", "email": "audit.userb.1795345591012@vbrs.local"}	\N	\N	2026-11-22 11:06:33.145
73985e74-07e7-4b90-a265-e7c6e832204e	6eb0337a-0d67-46c4-8936-66203ebb5009	VEHICLE_ADDED	Vehicle	15dcec00-0e51-481a-9e9e-ba6d29c192e9	{"make": "Porsche", "model": "Taycan GTS", "plate": "AUD-1014"}	\N	\N	2026-11-22 11:06:33.676
58ec5d72-7e03-467d-9953-b60eb0e94265	6eb0337a-0d67-46c4-8936-66203ebb5009	VEHICLE_UPDATED	Vehicle	15dcec00-0e51-481a-9e9e-ba6d29c192e9	\N	\N	\N	2026-11-22 11:06:33.698
38a26c72-e94a-4a94-b04e-0f8db6c13806	6eb0337a-0d67-46c4-8936-66203ebb5009	VEHICLE_DELETED	Vehicle	15dcec00-0e51-481a-9e9e-ba6d29c192e9	{"plate": "AUD-1014"}	\N	\N	2026-11-22 11:06:33.724
c10b2172-89fa-4816-b367-c4d5a98719bf	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 11:07:02.06
d0579844-bab3-4307-b30c-a7e51e1e6c7e	e22478b0-00a4-44f8-b146-3649213c7a20	VEHICLE_ADDED	Vehicle	d5446d27-687e-437d-ae1e-c32557d71210	{"make": "Audi", "model": "RS6 Avant", "plate": "E2E-3615"}	\N	\N	2026-11-22 11:07:03.675
cf65b4de-84e6-4965-bd05-edb69e5afa08	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 11:07:32.702
d0368672-f1e4-4f5b-adad-3461aa80e443	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	312b7774-bd00-4e4b-9c0c-d0642c12a432	{"category": "TRANSMISSION_ISSUE", "severity": "CRITICAL", "imageCount": 1, "requiresTowing": true}	\N	\N	2026-11-22 11:07:36.265
5dc867e3-05cf-4766-9d44-46d9ca3aea67	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 11:07:38.755
bac7c705-96b8-488a-b9ed-482390bc80ea	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	1c0a5cf0-9df0-4afb-aa9d-e4a46395adcd	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 11:07:43.574
b95957b3-8d94-463e-ae42-56016455f62d	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 11:07:46
ea4b7f54-82d3-490a-b738-4f381b592714	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	36a184dc-b9a3-47f3-86a2-2efc97e7ede8	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:07:48.166
76af3eb1-9138-42f2-baa3-eb1655cc5690	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 11:07:49.02
3ad8e1c0-52ab-4d6f-a8bb-74f9c18d37e5	473401ce-0803-422f-8baa-a47de557f84e	DISPATCH_ACCEPTED	ServiceRequest	f1a85ac0-fa6c-4acf-b8f6-f4f0c3de8407	{"mechanicId": "6a01cdea-a7ee-43e1-8a1f-77ecba9b0890", "breakdownReportId": "36a184dc-b9a3-47f3-86a2-2efc97e7ede8"}	\N	\N	2026-11-22 11:07:56.086
1807b1e5-1b3b-4f2c-8c4e-515a79cb1f04	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 11:08:03.218
c6a0eaa6-2e4d-4dfa-9289-4f31cb956429	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	5b068a25-9e91-4e4c-95bb-b9f839bf9b5f	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:08:05.318
e341bab6-d474-40d1-ab2d-2f469b895452	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 11:08:06.172
96bd89f7-bd65-41f6-8bbe-acbd01b003eb	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 11:08:14.7
9513b208-fe21-4060-a9d9-86ad7016c7e0	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	1a1171b1-4a64-4812-b079-04eadd18361c	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 11:08:15.713
f1a9281c-feb5-4f29-bac2-9693f2d0751f	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 11:08:17.087
15abf433-4446-41fc-b859-3b8d487a2a33	473401ce-0803-422f-8baa-a47de557f84e	DISPATCH_ACCEPTED	ServiceRequest	9fc8566a-0976-4e4f-8426-6975285d5d70	{"mechanicId": "6a01cdea-a7ee-43e1-8a1f-77ecba9b0890", "breakdownReportId": "1a1171b1-4a64-4812-b079-04eadd18361c"}	\N	\N	2026-11-22 11:08:19.115
f4458245-1ae3-4255-81e6-b35a2ef3690d	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_EN_ROUTE	ServiceRequest	9fc8566a-0976-4e4f-8426-6975285d5d70	{"notes": "Technician departed base en route to incident site.", "toStatus": "EN_ROUTE", "fromStatus": "ACCEPTED"}	\N	\N	2026-11-22 11:08:19.184
d80858f1-fe42-46d0-955c-3373b20d902e	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_ARRIVED	ServiceRequest	9fc8566a-0976-4e4f-8426-6975285d5d70	{"notes": "Technician arrived on scene at incident coordinates.", "toStatus": "ARRIVED", "fromStatus": "EN_ROUTE"}	\N	\N	2026-11-22 11:08:21.722
36e89936-8a6b-4b36-ae40-3bbd66073f58	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_IN_PROGRESS	ServiceRequest	9fc8566a-0976-4e4f-8426-6975285d5d70	{"notes": "Beginning diagnostic disassembly and component servicing.", "toStatus": "IN_PROGRESS", "fromStatus": "ARRIVED"}	\N	\N	2026-11-22 11:08:23.371
65d91b9d-38eb-4ea8-a3ba-81aba5613fcb	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_COMPLETED	ServiceRequest	9fc8566a-0976-4e4f-8426-6975285d5d70	{"notes": "Service finished successfully.", "toStatus": "COMPLETED", "fromStatus": "IN_PROGRESS"}	\N	\N	2026-11-22 11:08:23.468
e7fa9b1b-26d7-4955-b02f-8113c11b6bf9	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 11:08:26.836
8361da9e-1d8b-4001-a28e-880395bc0763	a3a45b01-9ac2-4382-9551-68f1762d33c2	MECHANIC_VERIFICATION_APPROVED	MechanicProfile	9224268f-1791-45ee-a424-2a498ddb5dcf	{"notes": "E2E Audit Verification: Trade license and ASE certifications verified with state registry.", "newStatus": "APPROVED", "previousStatus": "PENDING", "technicianEmail": "m5.mech2.1795345590904@vbrs.local"}	\N	\N	2026-11-22 11:08:28.108
cc525b3c-35ad-4800-abd5-e46926014368	a3a45b01-9ac2-4382-9551-68f1762d33c2	COMPLAINT_STATUS_RESOLVED	Complaint	0c46d018-93d4-44b4-921d-c8ebcdf336ac	{"toStatus": "RESOLVED", "fromStatus": "RESOLVED", "resolutionNotes": "E2E Resolution: Motorist and certified technician mutually agreed on final diagnostic adjustment."}	\N	\N	2026-11-22 11:08:30.703
f84f4ba7-527c-4ea3-a4f8-b0d701acfde0	a1479806-db8e-432b-a61a-04b1494faf85	USER_LOGGED_IN	User	a1479806-db8e-432b-a61a-04b1494faf85	\N	\N	\N	2026-11-22 11:12:20.067
a70ae0e8-1764-4e71-b722-7ede02cb4a89	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 11:12:30.537
dc11575f-231d-48e6-a46a-8ecba9396a4a	a1479806-db8e-432b-a61a-04b1494faf85	USER_LOGGED_IN	User	a1479806-db8e-432b-a61a-04b1494faf85	\N	\N	\N	2026-11-22 11:12:53.249
82c018d3-03c1-4d2d-838b-4db9cec71bc5	abb68e9a-9974-4371-868d-ef5a78bf6045	USER_REGISTERED	User	abb68e9a-9974-4371-868d-ef5a78bf6045	{"role": "CUSTOMER", "email": "m7.customer1.1795346682390@vbrs.local"}	\N	\N	2026-11-22 11:24:42.63
83634aa9-a098-46a3-80a9-50edeb859177	1132af97-784d-403f-8439-ee32ce4c6295	USER_REGISTERED	User	1132af97-784d-403f-8439-ee32ce4c6295	{"role": "CUSTOMER", "email": "m7.customer2.1795346682390@vbrs.local"}	\N	\N	2026-11-22 11:24:42.867
3f646323-ecd8-4f4c-8f6d-6808a5405006	f94f9477-bc05-46e6-b444-9bb14d4ce5da	USER_REGISTERED	User	f94f9477-bc05-46e6-b444-9bb14d4ce5da	{"role": "MECHANIC", "email": "m7.mechanic.1795346682390@vbrs.local"}	\N	\N	2026-11-22 11:24:43.104
e3725535-7722-4566-831b-9b8d61a9cc74	6a3159ce-3ec1-46ee-8854-079b5cef5d0c	USER_REGISTERED	User	6a3159ce-3ec1-46ee-8854-079b5cef5d0c	{"role": "CUSTOMER", "email": "m7.customer1.1795346709879@vbrs.local"}	\N	\N	2026-11-22 11:25:10.119
83e2a74a-6ca5-4c57-8d34-bb98200e0b51	efeb8cd7-f7cc-4dfd-8689-240f124ae2a4	USER_REGISTERED	User	efeb8cd7-f7cc-4dfd-8689-240f124ae2a4	{"role": "CUSTOMER", "email": "m7.customer2.1795346709879@vbrs.local"}	\N	\N	2026-11-22 11:25:10.359
8f3eb2a3-713f-4405-a011-bf8f8a993183	5db3fe47-163f-4f45-82a3-256bc87a79b2	USER_REGISTERED	User	5db3fe47-163f-4f45-82a3-256bc87a79b2	{"role": "MECHANIC", "email": "m7.mechanic.1795346709879@vbrs.local"}	\N	\N	2026-11-22 11:25:10.596
2d1f5d74-79e9-4780-ae99-fc0ba0c0d702	6a3159ce-3ec1-46ee-8854-079b5cef5d0c	CUSTOMER_REVIEW_SUBMITTED	Review	0564b2d3-43c7-4184-95a8-d56519fcd64c	{"rating": 5, "mechanicId": "75f044c3-f5b8-4bd8-acf9-e6ad9535b56c", "totalReviews": 1, "ratingAverage": 5, "serviceRequestId": "3d12e366-056e-4d9e-a27e-c1b717198d9a"}	\N	\N	2026-11-22 11:25:10.737
c020dbb6-9952-47e6-bfc2-e936fd5c64a4	efeb8cd7-f7cc-4dfd-8689-240f124ae2a4	CUSTOMER_REVIEW_SUBMITTED	Review	e746c8f6-d66d-4bf8-9f3c-9004cdb9ce0d	{"rating": 3, "mechanicId": "75f044c3-f5b8-4bd8-acf9-e6ad9535b56c", "totalReviews": 2, "ratingAverage": 4, "serviceRequestId": "7af7a836-25ca-4a4f-bd06-caaac1bbeab1"}	\N	\N	2026-11-22 11:25:10.761
f5ea8ac5-d89c-4687-a2d5-ac7e40c45306	84ecd965-cf9b-4db3-92a0-2fb64a3e965f	USER_REGISTERED	User	84ecd965-cf9b-4db3-92a0-2fb64a3e965f	{"role": "CUSTOMER", "email": "m7.customer1.1795346731082@vbrs.local"}	\N	\N	2026-11-22 11:25:31.365
02cff3c2-b3d7-46b6-aff5-ac6c987dd50c	3517d75c-d341-43ab-b318-7b13f2026e31	USER_REGISTERED	User	3517d75c-d341-43ab-b318-7b13f2026e31	{"role": "CUSTOMER", "email": "m7.customer2.1795346731082@vbrs.local"}	\N	\N	2026-11-22 11:25:31.649
37cc7e81-a780-42f1-86f0-ca355d3783a2	b7cff01c-2936-4856-8de7-e2f1049987f0	USER_REGISTERED	User	b7cff01c-2936-4856-8de7-e2f1049987f0	{"role": "MECHANIC", "email": "m7.mechanic.1795346731082@vbrs.local"}	\N	\N	2026-11-22 11:25:31.949
93fed17b-fd33-4b56-af65-22ee03fa56e7	282be406-30b3-4a61-a470-484970fa2ef9	USER_REGISTERED	User	282be406-30b3-4a61-a470-484970fa2ef9	{"role": "CUSTOMER", "email": "m3.customer.1795346731630@vbrs.local"}	\N	\N	2026-11-22 11:25:32.16
ba1c6351-fa3a-4a5e-9061-e84b1446edeb	84ecd965-cf9b-4db3-92a0-2fb64a3e965f	CUSTOMER_REVIEW_SUBMITTED	Review	2a3203dd-fbf1-4ef4-8c28-11a9e70d674a	{"rating": 5, "mechanicId": "999b01aa-2778-4a6d-8a8d-174220f8ecb5", "totalReviews": 1, "ratingAverage": 5, "serviceRequestId": "6ad56e3d-d58d-4bf6-b034-c4b06c43d3e1"}	\N	\N	2026-11-22 11:25:32.17
cabec968-8951-4795-8966-70ab5cba8e8d	3517d75c-d341-43ab-b318-7b13f2026e31	CUSTOMER_REVIEW_SUBMITTED	Review	9e6e819a-74f5-48a4-9727-f2c9ca56d7fb	{"rating": 3, "mechanicId": "999b01aa-2778-4a6d-8a8d-174220f8ecb5", "totalReviews": 2, "ratingAverage": 4, "serviceRequestId": "03bcf51f-5635-4ed8-92c8-f4215a2cb872"}	\N	\N	2026-11-22 11:25:32.197
e8169a64-cc81-4dca-9000-4fa28973500e	f7dd7f6a-8e5b-4475-820e-8b796a13b4d0	USER_REGISTERED	User	f7dd7f6a-8e5b-4475-820e-8b796a13b4d0	{"role": "ADMIN", "email": "m6.admin.1795346731699@vbrs.local"}	\N	\N	2026-11-22 11:25:32.213
955c2647-9bfb-4744-94e5-d26b53722121	cd78682e-cc1a-4cc1-b024-3222b9c5e339	USER_REGISTERED	User	cd78682e-cc1a-4cc1-b024-3222b9c5e339	{"role": "CUSTOMER", "email": "m5.cust1.1795346731751@vbrs.local"}	\N	\N	2026-11-22 11:25:32.249
52f363dd-9982-4a0e-97f0-c05c5d7b1a9e	fed47de1-aa48-4bd6-9c68-199068e2cf77	USER_REGISTERED	User	fed47de1-aa48-4bd6-9c68-199068e2cf77	{"role": "CUSTOMER", "email": "m2.customer.1795346731735@vbrs.local"}	\N	\N	2026-11-22 11:25:32.281
db0c2e06-9f2f-46a3-9930-10bff9a8e45a	50ade227-7e8a-46fd-8685-2e2878c91b01	USER_REGISTERED	User	50ade227-7e8a-46fd-8685-2e2878c91b01	{"role": "CUSTOMER", "email": "m3.edge.custa.1795346731779@vbrs.local"}	\N	\N	2026-11-22 11:25:32.287
0609ce02-831a-4c99-a977-2f72e1361c98	7a09bda9-bcb7-47db-9d6f-9cde4f8fe7cd	USER_REGISTERED	User	7a09bda9-bcb7-47db-9d6f-9cde4f8fe7cd	{"role": "CUSTOMER", "email": "m4.customer.1795346731790@vbrs.local"}	\N	\N	2026-11-22 11:25:32.299
295fe946-057d-4a1a-a2fe-ef65aa733f2a	6ad0fc2b-8f80-4225-9bf7-bdfe63dcfcb2	USER_REGISTERED	User	6ad0fc2b-8f80-4225-9bf7-bdfe63dcfcb2	{"role": "CUSTOMER", "email": "audit.customer.1795346731909@vbrs.local"}	\N	\N	2026-11-22 11:25:32.412
f247b2a3-c2bb-487d-8588-2429ae010104	d97f7a68-1e5b-4bbc-a2ae-efdb6e991a47	USER_REGISTERED	User	d97f7a68-1e5b-4bbc-a2ae-efdb6e991a47	{"role": "CUSTOMER", "email": "m3.userb.1795346731630@vbrs.local"}	\N	\N	2026-11-22 11:25:32.431
2c73b7fd-5eee-4c0e-8565-ef8e259fce18	282be406-30b3-4a61-a470-484970fa2ef9	BREAKDOWN_REPORT_CREATED	BreakdownReport	9459dbb4-eee9-4e78-97c2-343bf24cb143	{"category": "ENGINE_FAILURE", "severity": "CRITICAL", "imageCount": 1, "requiresTowing": true}	\N	\N	2026-11-22 11:25:32.484
1281291d-e320-4898-8bfd-5b2728a06eaf	8ce31ba5-bfb6-4062-8788-1d55d758fd08	USER_REGISTERED	User	8ce31ba5-bfb6-4062-8788-1d55d758fd08	{"role": "CUSTOMER", "email": "m6.customer.1795346731699@vbrs.local"}	\N	\N	2026-11-22 11:25:32.5
69cc3ecd-bda0-4e5c-bff6-b7dcabc639e6	282be406-30b3-4a61-a470-484970fa2ef9	BREAKDOWN_REPORT_CREATED	BreakdownReport	27d72a58-44f6-43a7-a9e4-a96b40330c20	{"category": "FLAT_TIRE_WHEEL", "severity": "LOW", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:25:32.509
e355b64f-ed47-4557-a31d-fa27f517a05f	5b7a3daf-7b92-462f-9fa1-95928376fca2	USER_REGISTERED	User	5b7a3daf-7b92-462f-9fa1-95928376fca2	{"role": "CUSTOMER", "email": "m5.cust2.1795346731751@vbrs.local"}	\N	\N	2026-11-22 11:25:32.514
26b0fc11-4473-4a89-b683-684420412460	bc905c8b-feee-4610-8e4c-c09401916566	USER_REGISTERED	User	bc905c8b-feee-4610-8e4c-c09401916566	{"role": "CUSTOMER", "email": "m3.edge.custb.1795346731779@vbrs.local"}	\N	\N	2026-11-22 11:25:32.553
e166ff14-245f-48c0-a6de-0e0379b2c2f6	f7687de7-1987-44af-85d9-9fcc9f286770	USER_REGISTERED	User	f7687de7-1987-44af-85d9-9fcc9f286770	{"role": "MECHANIC", "email": "m4.mech1.1795346731790@vbrs.local"}	\N	\N	2026-11-22 11:25:32.569
ace135d0-98c9-4128-80dc-d11a1401e67d	fed47de1-aa48-4bd6-9c68-199068e2cf77	USER_LOGGED_IN	User	fed47de1-aa48-4bd6-9c68-199068e2cf77	\N	\N	\N	2026-11-22 11:25:32.578
99fbb1f0-3b18-4bd9-8d8d-3133c598b8cd	7d5c1d7c-e190-4cd7-a73d-a3b2d317422c	USER_REGISTERED	User	7d5c1d7c-e190-4cd7-a73d-a3b2d317422c	{"role": "MECHANIC", "email": "audit.mechanic.1795346731909@vbrs.local"}	\N	\N	2026-11-22 11:25:32.682
7546786e-0fee-465f-a322-f417b889f383	6ad0fc2b-8f80-4225-9bf7-bdfe63dcfcb2	USER_LOGGED_IN	User	6ad0fc2b-8f80-4225-9bf7-bdfe63dcfcb2	\N	\N	\N	2026-11-22 11:25:32.953
38812882-b3e8-4a13-974d-5b0125b7e492	383ded7b-56cc-4419-8926-25fc9318ea0a	USER_REGISTERED	User	383ded7b-56cc-4419-8926-25fc9318ea0a	{"role": "MECHANIC", "email": "m6.pending.mech.1795346731699@vbrs.local"}	\N	\N	2026-11-22 11:25:32.761
96375edf-a033-4a05-9634-c936d69ea20e	8ce31ba5-bfb6-4062-8788-1d55d758fd08	BREAKDOWN_REPORT_CREATED	BreakdownReport	e6923eb3-18c2-4b16-b4a0-d4a3998a666c	{"category": "BRAKE_SYSTEM_FAILURE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 11:25:32.793
7af7adba-71f3-405a-bad4-46c356656df8	f7dd7f6a-8e5b-4475-820e-8b796a13b4d0	MECHANIC_VERIFICATION_APPROVED	MechanicProfile	799af39d-d7c2-42fe-8ac6-ad420e107247	{"notes": "ASE Master Certificate #88391 confirmed valid with State Board.", "newStatus": "APPROVED", "previousStatus": "PENDING", "technicianEmail": "m6.pending.mech.1795346731699@vbrs.local"}	\N	\N	2026-11-22 11:25:32.871
2a9e85f4-2695-4b46-9623-e98b9b7949ef	8ce31ba5-bfb6-4062-8788-1d55d758fd08	COMPLAINT_FILED	Complaint	8f11ef5b-d1c2-4148-ba32-b37b12ba1211	{"subject": "Late Arrival & Tow Rig Discrepancy", "serviceRequestId": "c40214eb-b743-42e2-9395-9b268084330c"}	\N	\N	2026-11-22 11:25:32.895
db76b74b-842c-4e51-ac86-1b7d6738a838	f7dd7f6a-8e5b-4475-820e-8b796a13b4d0	COMPLAINT_STATUS_INVESTIGATING	Complaint	8f11ef5b-d1c2-4148-ba32-b37b12ba1211	{"toStatus": "INVESTIGATING", "fromStatus": "PENDING", "resolutionNotes": "Contacted fleet dispatch log to verify arterial traffic delay."}	\N	\N	2026-11-22 11:25:32.942
b82b67f4-adf2-4287-87c1-4d0d2c2401ed	f7dd7f6a-8e5b-4475-820e-8b796a13b4d0	COMPLAINT_STATUS_RESOLVED	Complaint	8f11ef5b-d1c2-4148-ba32-b37b12ba1211	{"toStatus": "RESOLVED", "fromStatus": "INVESTIGATING", "resolutionNotes": "Traffic bottleneck verified on camera feed. Courtesy credit applied."}	\N	\N	2026-11-22 11:25:32.956
c5273d0a-a39d-4c0d-8b1d-9ab3c7d06c28	b6225e12-d48c-4709-97d5-6be7b6ef360d	USER_REGISTERED	User	b6225e12-d48c-4709-97d5-6be7b6ef360d	{"role": "MECHANIC", "email": "m5.mech1.1795346731751@vbrs.local"}	\N	\N	2026-11-22 11:25:32.772
96817c45-8024-4782-bcdd-4410036f29e9	32246199-32b0-4a1c-a009-c51b0345f9e5	USER_REGISTERED	User	32246199-32b0-4a1c-a009-c51b0345f9e5	{"role": "MECHANIC", "email": "m5.mech2.1795346731751@vbrs.local"}	\N	\N	2026-11-22 11:25:33.054
e89b81c6-985c-4af4-b299-d704b37fb21c	cf56a912-9c6f-4924-96f7-8c62662045cb	USER_REGISTERED	User	cf56a912-9c6f-4924-96f7-8c62662045cb	{"role": "ADMIN", "email": "m5.admin.1795346731751@vbrs.local"}	\N	\N	2026-11-22 11:25:33.306
28b9cfbd-0cf6-418f-ad0a-be513f42459f	cd78682e-cc1a-4cc1-b024-3222b9c5e339	BREAKDOWN_REPORT_CREATED	BreakdownReport	a3d91c21-bd2b-412e-8166-41a2f250c67f	{"category": "ENGINE_FAILURE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 11:25:33.337
0f927449-2aa8-4ced-b0b5-d6ac971c32e7	b6225e12-d48c-4709-97d5-6be7b6ef360d	DISPATCH_ACCEPTED	ServiceRequest	43519d31-f802-410d-915e-38f2fab6db62	{"mechanicId": "9ed08001-ef90-4dec-9ec9-97fd04ba6037", "breakdownReportId": "a3d91c21-bd2b-412e-8166-41a2f250c67f"}	\N	\N	2026-11-22 11:25:33.371
40be065f-80aa-4e66-ba5c-168f7575b2bc	b6225e12-d48c-4709-97d5-6be7b6ef360d	SERVICE_STATUS_EN_ROUTE	ServiceRequest	43519d31-f802-410d-915e-38f2fab6db62	{"notes": "Technician departed garage; en route via arterial highway.", "toStatus": "EN_ROUTE", "fromStatus": "ACCEPTED"}	\N	\N	2026-11-22 11:25:33.497
edb7a8c5-e5ce-4cdf-9f79-06066dac3f54	b6225e12-d48c-4709-97d5-6be7b6ef360d	SERVICE_STATUS_ARRIVED	ServiceRequest	43519d31-f802-410d-915e-38f2fab6db62	{"notes": "Arrived at incident site; positioning emergency safety cones.", "toStatus": "ARRIVED", "fromStatus": "EN_ROUTE"}	\N	\N	2026-11-22 11:25:33.523
a80b6095-0500-4395-83be-955d44a25bb2	b6225e12-d48c-4709-97d5-6be7b6ef360d	SERVICE_STATUS_IN_PROGRESS	ServiceRequest	43519d31-f802-410d-915e-38f2fab6db62	{"notes": "Disassembled ignition harness; installing new OEM coils.", "toStatus": "IN_PROGRESS", "fromStatus": "ARRIVED"}	\N	\N	2026-11-22 11:25:33.619
b7d68d6e-854f-4312-b04a-6f8f4684c914	b6225e12-d48c-4709-97d5-6be7b6ef360d	SERVICE_STATUS_COMPLETED	ServiceRequest	43519d31-f802-410d-915e-38f2fab6db62	{"toStatus": "COMPLETED", "fromStatus": "IN_PROGRESS"}	\N	\N	2026-11-22 11:25:33.643
cadd4949-6a24-442f-95c9-5bde67981cb5	cd78682e-cc1a-4cc1-b024-3222b9c5e339	BREAKDOWN_REPORT_CREATED	BreakdownReport	33bbeee6-4536-405b-a9b2-d8aed27e4209	{"category": "FLAT_TIRE_WHEEL", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:25:33.689
16af5014-f2ca-4786-99ea-dc13ee640481	b6225e12-d48c-4709-97d5-6be7b6ef360d	DISPATCH_ACCEPTED	ServiceRequest	c1c415f2-33da-43d2-b4b0-187f5847ac31	{"mechanicId": "9ed08001-ef90-4dec-9ec9-97fd04ba6037", "breakdownReportId": "33bbeee6-4536-405b-a9b2-d8aed27e4209"}	\N	\N	2026-11-22 11:25:33.709
ea24037f-9352-4c5a-ac44-0182f64f424e	cd78682e-cc1a-4cc1-b024-3222b9c5e339	SERVICE_STATUS_CANCELLED	ServiceRequest	c1c415f2-33da-43d2-b4b0-187f5847ac31	{"notes": "Cancellation reason: Spare tire located; vehicle changed independently.", "toStatus": "CANCELLED", "fromStatus": "ACCEPTED", "cancellationReason": "Spare tire located; vehicle changed independently."}	\N	\N	2026-11-22 11:25:33.729
f32d3346-1da6-44b8-acbc-10c0d1e442df	8890fb8f-a65c-4c1e-90cd-cb9d063b7634	USER_REGISTERED	User	8890fb8f-a65c-4c1e-90cd-cb9d063b7634	{"role": "MECHANIC", "email": "m3.edge.mech.1795346731779@vbrs.local"}	\N	\N	2026-11-22 11:25:32.808
5b905666-bef1-454b-887d-684ac9f7ad2c	50ade227-7e8a-46fd-8685-2e2878c91b01	VEHICLE_ADDED	Vehicle	42527336-e329-4b38-9fb3-5430e812ae29	{"make": "Porsche", "model": "911 GT3", "plate": "EDGE-A-2815"}	\N	\N	2026-11-22 11:25:32.835
ad46d004-8a09-440a-a617-b2e63dd86cf0	bc905c8b-feee-4610-8e4c-c09401916566	VEHICLE_ADDED	Vehicle	0a8a43db-8772-4d54-9f33-07a713bf8dc0	{"make": "Tesla", "model": "Model S Plaid", "plate": "EDGE-B-2838"}	\N	\N	2026-11-22 11:25:32.85
c48a3259-822d-49c8-9373-2da9403a9dc8	50ade227-7e8a-46fd-8685-2e2878c91b01	BREAKDOWN_REPORT_CREATED	BreakdownReport	6becf48c-b717-4a4e-a1bd-01d4de22626a	{"category": "COLLISION_ACCIDENT", "severity": "CRITICAL", "imageCount": 5, "requiresTowing": true}	\N	\N	2026-11-22 11:25:32.952
7e91ca82-bfaa-43c1-82c6-99b3ba375bbf	50ade227-7e8a-46fd-8685-2e2878c91b01	BREAKDOWN_REPORT_CREATED	BreakdownReport	969cc92d-226b-4e5b-977d-7f642db8a5f5	{"category": "BRAKE_SYSTEM_FAILURE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 11:25:33.023
4717610b-0991-4c38-a308-82889af37385	50ade227-7e8a-46fd-8685-2e2878c91b01	BREAKDOWN_REPORT_CREATED	BreakdownReport	f23b78d1-b4a0-4ea2-b3ca-2af9d7489f1e	{"category": "BATTERY_DEAD_ELECTRICAL", "severity": "MEDIUM", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 11:25:33.054
501495fb-37c2-4df0-9f1d-8168146c988c	50ade227-7e8a-46fd-8685-2e2878c91b01	BREAKDOWN_REPORT_CREATED	BreakdownReport	37063bc8-54b1-46dd-afca-64681a16d2aa	{"category": "TRANSMISSION_ISSUE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 11:25:33.078
2d5ab63f-d5d1-4f52-a55f-15c5817b1862	50ade227-7e8a-46fd-8685-2e2878c91b01	BREAKDOWN_REPORT_CREATED	BreakdownReport	eab83563-92d4-4bfb-89b7-cfcfe67966ce	{"category": "FUEL_EMPTY_OR_CONTAMINATED", "severity": "LOW", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:25:33.12
a86d088b-5683-45f1-840b-6ecc05e9420d	50ade227-7e8a-46fd-8685-2e2878c91b01	BREAKDOWN_REPORT_CREATED	BreakdownReport	8746d8c6-a64d-46f1-ba26-6dec37df5253	{"category": "OVERHEATING_COOLANT", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:25:33.135
a1609268-8077-4b39-b7f3-9fd4e81d4fb9	50ade227-7e8a-46fd-8685-2e2878c91b01	BREAKDOWN_REPORT_CREATED	BreakdownReport	3ebb4225-a2a8-4378-b7a3-103251e9a9d4	{"category": "LOCKOUT_KEY_LOST", "severity": "LOW", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 11:25:33.18
766c5124-a87a-41f3-9908-611125fd7542	599a1a84-5e64-44df-acaa-8e4c4e40cae3	USER_REGISTERED	User	599a1a84-5e64-44df-acaa-8e4c4e40cae3	{"role": "MECHANIC", "email": "m4.mech2.1795346731790@vbrs.local"}	\N	\N	2026-11-22 11:25:32.836
0c9da3b9-0a92-4954-ad9d-de528fb1a9ce	7a09bda9-bcb7-47db-9d6f-9cde4f8fe7cd	BREAKDOWN_REPORT_CREATED	BreakdownReport	0d30da36-9f22-4786-9125-0e3145158573	{"category": "FLAT_TIRE_WHEEL", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:25:32.875
703b218f-d8a3-4a86-8f1b-b334ead62fef	f7687de7-1987-44af-85d9-9fcc9f286770	DISPATCH_ACCEPTED	ServiceRequest	e7003bae-6761-4520-b750-9b0c2d548428	{"mechanicId": "aa7c06fb-61a0-4c00-a555-0042c6af990b", "breakdownReportId": "0d30da36-9f22-4786-9125-0e3145158573"}	\N	\N	2026-11-22 11:25:33.117
f72470e8-5f50-4664-ab7d-846e391635a5	fed47de1-aa48-4bd6-9c68-199068e2cf77	VEHICLE_ADDED	Vehicle	9f6bef6a-67fd-4f52-8f95-7e75061c3618	{"make": "Ford", "model": "Mustang Mach-E", "plate": "M2-2875"}	\N	\N	2026-11-22 11:25:32.892
f7d2ac8f-0df4-4f30-aea2-9a940e65ee6d	fed47de1-aa48-4bd6-9c68-199068e2cf77	VEHICLE_UPDATED	Vehicle	9f6bef6a-67fd-4f52-8f95-7e75061c3618	\N	\N	\N	2026-11-22 11:25:32.941
c97ec3e0-5cfa-40f3-bac6-03e9146dd228	fed47de1-aa48-4bd6-9c68-199068e2cf77	VEHICLE_DELETED	Vehicle	9f6bef6a-67fd-4f52-8f95-7e75061c3618	{"plate": "M2-2875"}	\N	\N	2026-11-22 11:25:32.968
d9cc34fc-6c18-423b-960d-9953d5a4356a	fed47de1-aa48-4bd6-9c68-199068e2cf77	USER_LOGGED_OUT	User	fed47de1-aa48-4bd6-9c68-199068e2cf77	\N	\N	\N	2026-11-22 11:25:32.993
9c5530af-4cc1-4197-aee6-ffc52aa5011f	7d5c1d7c-e190-4cd7-a73d-a3b2d317422c	USER_LOGGED_IN	User	7d5c1d7c-e190-4cd7-a73d-a3b2d317422c	\N	\N	\N	2026-11-22 11:25:33.21
e72c6266-66d1-459d-9081-a4461080c1cb	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 11:25:33.443
54da9e4e-e74f-4efc-8120-64818d5c4edf	e59b6392-d01c-4bd7-9fdb-786873430a38	USER_REGISTERED	User	e59b6392-d01c-4bd7-9fdb-786873430a38	{"role": "CUSTOMER", "email": "audit.userb.1795346731909@vbrs.local"}	\N	\N	2026-11-22 11:25:33.923
5e049a3d-8369-4d15-b3dc-16bd1ff86f26	6ad0fc2b-8f80-4225-9bf7-bdfe63dcfcb2	VEHICLE_ADDED	Vehicle	cc249f69-eae0-483a-a65f-938b3df2a35a	{"make": "Porsche", "model": "Taycan GTS", "plate": "AUD-1910"}	\N	\N	2026-11-22 11:25:34.433
573d2f64-e994-4a66-bb04-99743ef4e018	6ad0fc2b-8f80-4225-9bf7-bdfe63dcfcb2	VEHICLE_UPDATED	Vehicle	cc249f69-eae0-483a-a65f-938b3df2a35a	\N	\N	\N	2026-11-22 11:25:34.454
43598b5a-07e5-457e-9bfe-755f4cfde599	6ad0fc2b-8f80-4225-9bf7-bdfe63dcfcb2	VEHICLE_DELETED	Vehicle	cc249f69-eae0-483a-a65f-938b3df2a35a	{"plate": "AUD-1910"}	\N	\N	2026-11-22 11:25:34.48
9a152142-e640-4f41-9a44-a02e2ce7400d	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 11:31:03.945
b0aa23a9-15d4-487c-8b3b-2830cb3d17b9	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	ac94019b-d02f-4c1b-989b-749ce80ecf04	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:31:05.896
047d0a05-1fcd-4802-8af4-11903e8f125c	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 11:32:42.421
50376d87-c3ee-4d6d-ad1b-9d2f9fbacfac	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	ce937235-7304-4408-a12d-bd7e6c054024	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:32:44.384
9e0c8875-251d-4718-b9f6-3228886437f7	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 11:32:45.777
c5a676ec-ec08-4d62-836d-db81d57e1dd3	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 11:33:43.253
484f3b77-abdb-45e8-afea-2c4b2ea0edf4	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	d872046f-47b1-4b24-b3a4-aae87870c8c6	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:33:45.354
f39e8acb-cf5e-4d2e-9d5b-5ea23e07af8a	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 11:33:46.703
4634cd91-f688-48bc-9e63-5eec75d34e3f	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 11:35:04.448
09b4e1cc-a196-4ba5-a98a-44bee8971ee6	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	5012bca7-4cb4-4e82-8916-4f1bdad195b3	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:35:06.591
539d9ea4-9c91-497c-82ab-07406ff66af6	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 11:35:07.947
e8e251b3-f80d-438c-a516-93b5a88e3228	473401ce-0803-422f-8baa-a47de557f84e	DISPATCH_ACCEPTED	ServiceRequest	9553175c-91fb-4c65-9a98-4d69aa929cd8	{"mechanicId": "6a01cdea-a7ee-43e1-8a1f-77ecba9b0890", "breakdownReportId": "5012bca7-4cb4-4e82-8916-4f1bdad195b3"}	\N	\N	2026-11-22 11:35:11.431
78b8abf1-f8b1-4504-a639-1da26dad2edb	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_EN_ROUTE	ServiceRequest	9553175c-91fb-4c65-9a98-4d69aa929cd8	{"notes": "Technician departed base en route to incident site.", "toStatus": "EN_ROUTE", "fromStatus": "ACCEPTED"}	\N	\N	2026-11-22 11:35:11.504
6798ed64-a212-47fe-a3f0-50b96624cdd7	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_ARRIVED	ServiceRequest	9553175c-91fb-4c65-9a98-4d69aa929cd8	{"notes": "Technician arrived on scene at incident coordinates.", "toStatus": "ARRIVED", "fromStatus": "EN_ROUTE"}	\N	\N	2026-11-22 11:35:11.611
7819f851-f63d-4ab5-a9ee-bb0d97ac1edc	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 11:36:03.192
abe603fd-69f1-4966-8cc5-e4270fc0d9c7	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	552d5408-a375-458e-a45f-be861f2b2eba	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:36:05.043
06acfb36-e8b2-48fe-bd74-c3e40dfdbd55	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 11:36:06.367
fcf41779-465d-4b51-83a0-916a89dd395c	473401ce-0803-422f-8baa-a47de557f84e	DISPATCH_ACCEPTED	ServiceRequest	4fcacb83-fe1b-460a-bf1f-1a5c80cccd66	{"mechanicId": "6a01cdea-a7ee-43e1-8a1f-77ecba9b0890", "breakdownReportId": "552d5408-a375-458e-a45f-be861f2b2eba"}	\N	\N	2026-11-22 11:36:09.885
fa2edce8-9556-4470-8b02-0eab19671935	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_EN_ROUTE	ServiceRequest	4fcacb83-fe1b-460a-bf1f-1a5c80cccd66	{"notes": "Technician departed base en route to incident site.", "toStatus": "EN_ROUTE", "fromStatus": "ACCEPTED"}	\N	\N	2026-11-22 11:36:10
9afbb314-14dc-427d-acd1-6c54b155b842	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_ARRIVED	ServiceRequest	4fcacb83-fe1b-460a-bf1f-1a5c80cccd66	{"notes": "Technician arrived on scene at incident coordinates.", "toStatus": "ARRIVED", "fromStatus": "EN_ROUTE"}	\N	\N	2026-11-22 11:36:10.098
7e64e653-8989-4b49-ae5c-ee746137d170	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_IN_PROGRESS	ServiceRequest	4fcacb83-fe1b-460a-bf1f-1a5c80cccd66	{"notes": "Beginning diagnostic disassembly and component servicing.", "toStatus": "IN_PROGRESS", "fromStatus": "ARRIVED"}	\N	\N	2026-11-22 11:36:11.785
696e301c-c8c6-409a-9a14-9afebd940b1c	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_COMPLETED	ServiceRequest	4fcacb83-fe1b-460a-bf1f-1a5c80cccd66	{"notes": "Service finished successfully.", "toStatus": "COMPLETED", "fromStatus": "IN_PROGRESS"}	\N	\N	2026-11-22 11:36:11.901
37cd8a3d-9de3-4481-965f-7648f700be35	e22478b0-00a4-44f8-b146-3649213c7a20	CUSTOMER_REVIEW_SUBMITTED	Review	1c38b5cd-297c-4632-bcef-00143da905a8	{"rating": 5, "mechanicId": "6a01cdea-a7ee-43e1-8a1f-77ecba9b0890", "totalReviews": 1, "ratingAverage": 5, "serviceRequestId": "4fcacb83-fe1b-460a-bf1f-1a5c80cccd66"}	\N	\N	2026-11-22 11:36:12.987
0778b802-b6b4-4c1b-aab0-957a85676405	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 11:36:14.289
9a2c9730-1816-4874-ba4d-8476d5cd20aa	02d88990-b57a-4b82-a5b4-e44022b802f4	USER_REGISTERED	User	02d88990-b57a-4b82-a5b4-e44022b802f4	{"role": "ADMIN", "email": "m6.admin.1795347397635@vbrs.local"}	\N	\N	2026-11-22 11:36:38.186
c16fef28-921c-4160-be1d-81a57fa963e0	147459dd-88dc-4f76-89cc-14a93c36d249	USER_REGISTERED	User	147459dd-88dc-4f76-89cc-14a93c36d249	{"role": "CUSTOMER", "email": "audit.customer.1795347397646@vbrs.local"}	\N	\N	2026-11-22 11:36:38.201
e62bb94b-1d98-4def-adcb-e0ed6410c9d3	4b4b0149-ece4-4281-9c87-ad93e8ccf2a8	USER_LOGGED_IN	User	4b4b0149-ece4-4281-9c87-ad93e8ccf2a8	\N	\N	\N	2026-11-22 11:55:24.357
001962d3-be80-4bbd-9064-e37b9106864a	4a059e43-c586-45be-b371-252f448bbdd8	USER_REGISTERED	User	4a059e43-c586-45be-b371-252f448bbdd8	{"role": "CUSTOMER", "email": "m5.cust1.1795347397710@vbrs.local"}	\N	\N	2026-11-22 11:36:38.218
e9739d9c-fd40-4a31-b918-fdd3d539fb99	03049ccb-baf0-499d-aa2d-d5dce89114ad	USER_REGISTERED	User	03049ccb-baf0-499d-aa2d-d5dce89114ad	{"role": "CUSTOMER", "email": "m7.customer1.1795347398006@vbrs.local"}	\N	\N	2026-11-22 11:36:38.275
7a86c9b9-ad4e-4963-89de-47f157b0294c	ae128b65-26b9-4aaf-aebe-80153c2e1b12	USER_REGISTERED	User	ae128b65-26b9-4aaf-aebe-80153c2e1b12	{"role": "CUSTOMER", "email": "m2.customer.1795347397724@vbrs.local"}	\N	\N	2026-11-22 11:36:38.278
a532dd85-c83e-40e3-b166-1a31c37b0d09	bbdc9439-1243-4dec-a18b-8b6512cede79	USER_REGISTERED	User	bbdc9439-1243-4dec-a18b-8b6512cede79	{"role": "CUSTOMER", "email": "m3.edge.custa.1795347397757@vbrs.local"}	\N	\N	2026-11-22 11:36:38.289
2433beac-3a6d-464c-8dde-20e19001f9d8	12a59ca0-ebce-49aa-b8c8-2d6021a4d980	USER_REGISTERED	User	12a59ca0-ebce-49aa-b8c8-2d6021a4d980	{"role": "CUSTOMER", "email": "m4.customer.1795347397802@vbrs.local"}	\N	\N	2026-11-22 11:36:38.322
51773df6-e16d-4eb1-a336-24cca48c4b83	487c98dd-e41e-417a-81df-6160ad2f08bd	USER_REGISTERED	User	487c98dd-e41e-417a-81df-6160ad2f08bd	{"role": "CUSTOMER", "email": "m3.customer.1795347397822@vbrs.local"}	\N	\N	2026-11-22 11:36:38.324
b46e3eeb-6db5-4c87-b671-c96a7f778468	8b1e24ae-3d0f-45a1-a091-b99dbccc5094	USER_REGISTERED	User	8b1e24ae-3d0f-45a1-a091-b99dbccc5094	{"role": "CUSTOMER", "email": "m5.cust2.1795347397710@vbrs.local"}	\N	\N	2026-11-22 11:36:38.515
579939e3-7519-4b25-b261-7c774f16fb6d	4c50ae6c-ef63-4e39-a5b0-d01121d5eb64	USER_REGISTERED	User	4c50ae6c-ef63-4e39-a5b0-d01121d5eb64	{"role": "CUSTOMER", "email": "m7.customer2.1795347398006@vbrs.local"}	\N	\N	2026-11-22 11:36:38.58
cfd44222-f1c3-4803-bd5b-4ac4988c8329	c8830dc5-34eb-4c8c-a34d-e1ff3bc55773	USER_REGISTERED	User	c8830dc5-34eb-4c8c-a34d-e1ff3bc55773	{"role": "CUSTOMER", "email": "m3.edge.custb.1795347397757@vbrs.local"}	\N	\N	2026-11-22 11:36:38.581
b3d24917-01a1-46ca-85e6-679adc97949b	ae128b65-26b9-4aaf-aebe-80153c2e1b12	USER_LOGGED_IN	User	ae128b65-26b9-4aaf-aebe-80153c2e1b12	\N	\N	\N	2026-11-22 11:36:38.592
2c6a41f9-66cd-4c32-9996-2949b558ac2e	2efbe1ad-1413-4ae8-81ae-49e8b990d633	USER_REGISTERED	User	2efbe1ad-1413-4ae8-81ae-49e8b990d633	{"role": "CUSTOMER", "email": "m3.userb.1795347397822@vbrs.local"}	\N	\N	2026-11-22 11:36:38.613
c0ee1bfc-99b9-4159-828d-bd2094e6d561	13608b64-3065-4aea-99b6-4633b454b56d	USER_REGISTERED	User	13608b64-3065-4aea-99b6-4633b454b56d	{"role": "MECHANIC", "email": "m4.mech1.1795347397802@vbrs.local"}	\N	\N	2026-11-22 11:36:38.636
3ec444fe-1fd4-404c-b97f-7acd4bb33467	487c98dd-e41e-417a-81df-6160ad2f08bd	BREAKDOWN_REPORT_CREATED	BreakdownReport	0ab7ffcd-1395-4d0c-b3e2-9e9bdf425b15	{"category": "ENGINE_FAILURE", "severity": "CRITICAL", "imageCount": 1, "requiresTowing": true}	\N	\N	2026-11-22 11:36:38.672
e488969e-3c42-463b-bf6a-e94faeb6e427	487c98dd-e41e-417a-81df-6160ad2f08bd	BREAKDOWN_REPORT_CREATED	BreakdownReport	8e59617b-5a64-4ded-8303-eaed2f929ac4	{"category": "FLAT_TIRE_WHEEL", "severity": "LOW", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:36:38.7
a4949d92-6f9c-4324-a047-c0c39c5258ca	6fce9f62-804c-480a-ba62-c337fa44ace7	USER_REGISTERED	User	6fce9f62-804c-480a-ba62-c337fa44ace7	{"role": "MECHANIC", "email": "m5.mech1.1795347397710@vbrs.local"}	\N	\N	2026-11-22 11:36:38.809
e37acb86-5b49-459b-9ea1-7598c6226d52	3fab570e-2937-4fe4-8e48-b6bc7ba4b2f0	USER_REGISTERED	User	3fab570e-2937-4fe4-8e48-b6bc7ba4b2f0	{"role": "MECHANIC", "email": "m7.mechanic.1795347398006@vbrs.local"}	\N	\N	2026-11-22 11:36:38.854
079d6501-770e-4723-bc15-898ddafd81e4	9d5010e7-020c-41ba-81ac-6b878a91889e	USER_REGISTERED	User	9d5010e7-020c-41ba-81ac-6b878a91889e	{"role": "MECHANIC", "email": "m3.edge.mech.1795347397757@vbrs.local"}	\N	\N	2026-11-22 11:36:38.876
35a08194-0fe6-4a9d-bb68-49d6664c2ef1	bbdc9439-1243-4dec-a18b-8b6512cede79	VEHICLE_ADDED	Vehicle	45b61161-5415-4ad2-ae34-c28f07ebb8e8	{"make": "Porsche", "model": "911 GT3", "plate": "EDGE-A-8883"}	\N	\N	2026-11-22 11:36:38.906
d75b9cc7-4c36-4738-bf64-07db1dae63e8	b49fbfc0-75b1-4417-9a7b-b2b55bb451d6	USER_REGISTERED	User	b49fbfc0-75b1-4417-9a7b-b2b55bb451d6	{"role": "MECHANIC", "email": "m4.mech2.1795347397802@vbrs.local"}	\N	\N	2026-11-22 11:36:38.923
6ff11eb7-0892-49d8-a606-2118522c2193	c8830dc5-34eb-4c8c-a34d-e1ff3bc55773	VEHICLE_ADDED	Vehicle	cc63d73f-ba70-4dfe-96b6-c3a7dade93e6	{"make": "Tesla", "model": "Model S Plaid", "plate": "EDGE-B-8909"}	\N	\N	2026-11-22 11:36:38.924
59c43f9d-3cd7-4824-9a30-b785860f2190	ae128b65-26b9-4aaf-aebe-80153c2e1b12	VEHICLE_ADDED	Vehicle	0e1327bc-efba-490a-a611-602de8b9feed	{"make": "Ford", "model": "Mustang Mach-E", "plate": "M2-8909"}	\N	\N	2026-11-22 11:36:38.927
b856f3c4-423d-45b1-90e8-d9d9acdde27f	12a59ca0-ebce-49aa-b8c8-2d6021a4d980	BREAKDOWN_REPORT_CREATED	BreakdownReport	2524c83a-698d-4dcf-b25d-098dce069ec0	{"category": "FLAT_TIRE_WHEEL", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:36:38.97
57f330ba-06a9-419b-875a-f8032d4f693c	ae128b65-26b9-4aaf-aebe-80153c2e1b12	VEHICLE_UPDATED	Vehicle	0e1327bc-efba-490a-a611-602de8b9feed	\N	\N	\N	2026-11-22 11:36:38.983
13bee941-0395-4147-85b9-4c2884d46792	ae128b65-26b9-4aaf-aebe-80153c2e1b12	VEHICLE_DELETED	Vehicle	0e1327bc-efba-490a-a611-602de8b9feed	{"plate": "M2-8909"}	\N	\N	2026-11-22 11:36:39.029
c86e3177-7c72-4ae7-9b80-96af5c4bc58f	ae128b65-26b9-4aaf-aebe-80153c2e1b12	USER_LOGGED_OUT	User	ae128b65-26b9-4aaf-aebe-80153c2e1b12	\N	\N	\N	2026-11-22 11:36:39.054
418fc76e-b1c4-4fa8-a694-7d584437b6a3	bbdc9439-1243-4dec-a18b-8b6512cede79	BREAKDOWN_REPORT_CREATED	BreakdownReport	7aacdfa6-e34b-4805-9d3e-c62e0d71be25	{"category": "COLLISION_ACCIDENT", "severity": "CRITICAL", "imageCount": 5, "requiresTowing": true}	\N	\N	2026-11-22 11:36:39.077
b1a8d1ab-520b-45fb-a24f-91c1e5fcedef	03049ccb-baf0-499d-aa2d-d5dce89114ad	CUSTOMER_REVIEW_SUBMITTED	Review	00def108-07e7-48e0-9416-77f2aa6d4611	{"rating": 5, "mechanicId": "589cd51a-0952-445a-98ce-8b00ad9d3e44", "totalReviews": 1, "ratingAverage": 5, "serviceRequestId": "8444154d-cd02-40d3-92f1-0cbcad7d9fef"}	\N	\N	2026-11-22 11:36:39.093
0f7ddf1e-e492-44db-86ed-84ad52c81ef3	da494868-688f-4802-823a-432be9bc80b5	USER_REGISTERED	User	da494868-688f-4802-823a-432be9bc80b5	{"role": "MECHANIC", "email": "m5.mech2.1795347397710@vbrs.local"}	\N	\N	2026-11-22 11:36:39.111
3d855c6b-4bc5-4a7f-ad13-a00c9cb92e12	4c50ae6c-ef63-4e39-a5b0-d01121d5eb64	CUSTOMER_REVIEW_SUBMITTED	Review	d0e98bcc-42b1-4b25-af8f-df1f4808b811	{"rating": 3, "mechanicId": "589cd51a-0952-445a-98ce-8b00ad9d3e44", "totalReviews": 2, "ratingAverage": 4, "serviceRequestId": "29942811-6dc9-482d-ac87-f157debf369e"}	\N	\N	2026-11-22 11:36:39.127
f92cc60d-13f0-4c55-8875-50fcb65b0461	bbdc9439-1243-4dec-a18b-8b6512cede79	BREAKDOWN_REPORT_CREATED	BreakdownReport	08758044-73c1-468f-b742-bce92751dbd7	{"category": "BRAKE_SYSTEM_FAILURE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 11:36:39.144
68d0d4bf-07df-4a89-9f80-8d807f0fd9c8	67685e48-6314-4741-9f3e-7869f819b961	USER_REGISTERED	User	67685e48-6314-4741-9f3e-7869f819b961	{"role": "ADMIN", "email": "m5.admin.1795347397710@vbrs.local"}	\N	\N	2026-11-22 11:36:39.358
75f126ff-cc8f-4e1a-a71f-23aa484676ea	6108dc7f-6c15-4ee6-8a47-92ff7487b689	USER_REGISTERED	User	6108dc7f-6c15-4ee6-8a47-92ff7487b689	{"role": "CUSTOMER", "email": "m6.customer.1795347397635@vbrs.local"}	\N	\N	2026-11-22 11:36:38.487
8e19e55b-dfd3-46a7-a36c-e1416c95c81e	b0bcbe4c-6c84-4113-a38b-62338ce06d8d	USER_REGISTERED	User	b0bcbe4c-6c84-4113-a38b-62338ce06d8d	{"role": "MECHANIC", "email": "m6.pending.mech.1795347397635@vbrs.local"}	\N	\N	2026-11-22 11:36:38.761
07f3fe21-1b4a-4189-a111-ba8fbbd3733a	6108dc7f-6c15-4ee6-8a47-92ff7487b689	BREAKDOWN_REPORT_CREATED	BreakdownReport	4ba3c798-67ff-4b33-b544-41fd9088a67a	{"category": "BRAKE_SYSTEM_FAILURE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 11:36:38.802
eca316af-559e-44da-a682-598094805a93	02d88990-b57a-4b82-a5b4-e44022b802f4	MECHANIC_VERIFICATION_APPROVED	MechanicProfile	85c362bd-919d-4514-b93d-20d8a05d38f9	{"notes": "ASE Master Certificate #88391 confirmed valid with State Board.", "newStatus": "APPROVED", "previousStatus": "PENDING", "technicianEmail": "m6.pending.mech.1795347397635@vbrs.local"}	\N	\N	2026-11-22 11:36:38.885
524d6bbb-e7a7-4857-b086-e67fffaa3cf5	6108dc7f-6c15-4ee6-8a47-92ff7487b689	COMPLAINT_FILED	Complaint	dcd3c309-cb07-4dd8-bd43-d5f7cdb86f82	{"subject": "Late Arrival & Tow Rig Discrepancy", "serviceRequestId": "71a0e527-0076-48b3-b1d1-d458adef3aba"}	\N	\N	2026-11-22 11:36:38.913
0be02086-c017-44a8-89a1-8a8047000232	02d88990-b57a-4b82-a5b4-e44022b802f4	COMPLAINT_STATUS_INVESTIGATING	Complaint	dcd3c309-cb07-4dd8-bd43-d5f7cdb86f82	{"toStatus": "INVESTIGATING", "fromStatus": "PENDING", "resolutionNotes": "Contacted fleet dispatch log to verify arterial traffic delay."}	\N	\N	2026-11-22 11:36:38.971
0ab8de36-cbb0-42bd-a253-c60bbea3ddd7	02d88990-b57a-4b82-a5b4-e44022b802f4	COMPLAINT_STATUS_RESOLVED	Complaint	dcd3c309-cb07-4dd8-bd43-d5f7cdb86f82	{"toStatus": "RESOLVED", "fromStatus": "INVESTIGATING", "resolutionNotes": "Traffic bottleneck verified on camera feed. Courtesy credit applied."}	\N	\N	2026-11-22 11:36:38.989
13f45335-e62d-44f3-9112-ec12eaa69e1a	afe64e04-d47c-4aff-97a5-498252ffd13a	USER_REGISTERED	User	afe64e04-d47c-4aff-97a5-498252ffd13a	{"role": "MECHANIC", "email": "audit.mechanic.1795347397646@vbrs.local"}	\N	\N	2026-11-22 11:36:38.508
9f3db640-90dc-4d94-bd9d-0a11ef2abfe4	147459dd-88dc-4f76-89cc-14a93c36d249	USER_LOGGED_IN	User	147459dd-88dc-4f76-89cc-14a93c36d249	\N	\N	\N	2026-11-22 11:36:38.781
8c6e5d9a-f4a7-44f8-a35e-aa37790de190	afe64e04-d47c-4aff-97a5-498252ffd13a	USER_LOGGED_IN	User	afe64e04-d47c-4aff-97a5-498252ffd13a	\N	\N	\N	2026-11-22 11:36:39.067
7042c0ff-ea8c-4dae-a756-e94d65be91f3	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 11:36:39.322
28da050e-586b-4b3c-a8fa-cab959267b10	7baddfaa-81ca-4ccc-83c2-2d0e94f4f82b	USER_REGISTERED	User	7baddfaa-81ca-4ccc-83c2-2d0e94f4f82b	{"role": "CUSTOMER", "email": "audit.userb.1795347397646@vbrs.local"}	\N	\N	2026-11-22 11:36:39.8
59630b90-63c5-4853-a8bb-ff944e48b713	147459dd-88dc-4f76-89cc-14a93c36d249	VEHICLE_ADDED	Vehicle	ee636eb5-61d8-4c17-be8c-d7de9d4592cd	{"make": "Porsche", "model": "Taycan GTS", "plate": "AUD-7648"}	\N	\N	2026-11-22 11:36:40.329
9fdf8f8e-07d2-405d-8fed-5047bbdb26cc	147459dd-88dc-4f76-89cc-14a93c36d249	VEHICLE_UPDATED	Vehicle	ee636eb5-61d8-4c17-be8c-d7de9d4592cd	\N	\N	\N	2026-11-22 11:36:40.351
28fad3c3-322d-4ea0-bd88-0e2b5d207e33	147459dd-88dc-4f76-89cc-14a93c36d249	VEHICLE_DELETED	Vehicle	ee636eb5-61d8-4c17-be8c-d7de9d4592cd	{"plate": "AUD-7648"}	\N	\N	2026-11-22 11:36:40.379
cd62faef-47b9-4a3a-9fb4-d3c693cc6c2c	bbdc9439-1243-4dec-a18b-8b6512cede79	BREAKDOWN_REPORT_CREATED	BreakdownReport	fb7b8b5b-800f-42d6-887e-fdcbeee3bbfc	{"category": "BATTERY_DEAD_ELECTRICAL", "severity": "MEDIUM", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 11:36:39.173
5b949293-e1a3-4c2e-8a39-9607ad6204cb	bbdc9439-1243-4dec-a18b-8b6512cede79	BREAKDOWN_REPORT_CREATED	BreakdownReport	ebdcc180-2ba4-45d8-9ab1-cbe009e4eaea	{"category": "TRANSMISSION_ISSUE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 11:36:39.195
a3ac0843-bf2f-42a9-9c6c-47e016bf7319	bbdc9439-1243-4dec-a18b-8b6512cede79	BREAKDOWN_REPORT_CREATED	BreakdownReport	65a2e74c-6677-468c-8339-8db363fe524d	{"category": "FUEL_EMPTY_OR_CONTAMINATED", "severity": "LOW", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:36:39.235
a8f01331-679a-42d7-a9b3-561d9527580a	bbdc9439-1243-4dec-a18b-8b6512cede79	BREAKDOWN_REPORT_CREATED	BreakdownReport	a82f9c72-4778-4c3b-835c-f78992aecb3b	{"category": "OVERHEATING_COOLANT", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:36:39.252
faac5657-a098-4000-91d0-a39c38108b4d	bbdc9439-1243-4dec-a18b-8b6512cede79	BREAKDOWN_REPORT_CREATED	BreakdownReport	d6880598-5bd4-497c-856e-4963a457dd15	{"category": "LOCKOUT_KEY_LOST", "severity": "LOW", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 11:36:39.287
1d2631b2-f784-46d0-96f9-ae5f3ba3e9b4	13608b64-3065-4aea-99b6-4633b454b56d	DISPATCH_ACCEPTED	ServiceRequest	6488e5ba-3fc9-4aa1-9e17-59777828f470	{"mechanicId": "7ceb1f55-7d15-42cc-b366-610d301d023d", "breakdownReportId": "2524c83a-698d-4dcf-b25d-098dce069ec0"}	\N	\N	2026-11-22 11:36:39.234
08ad2ece-4082-4014-a7d2-403a41aee994	4a059e43-c586-45be-b371-252f448bbdd8	BREAKDOWN_REPORT_CREATED	BreakdownReport	c74273d7-4f72-4d58-9ed4-29cc12d0e18c	{"category": "ENGINE_FAILURE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 11:36:39.387
96a71f3d-f724-49a6-9a68-e6010a9a6f91	6fce9f62-804c-480a-ba62-c337fa44ace7	DISPATCH_ACCEPTED	ServiceRequest	434a11c9-298a-432a-9454-30ba7fee3ca0	{"mechanicId": "2c562b7b-1e07-4e32-a8ef-12d935fe25e4", "breakdownReportId": "c74273d7-4f72-4d58-9ed4-29cc12d0e18c"}	\N	\N	2026-11-22 11:36:39.419
3eae6627-c340-4da8-8959-a4b4b705ae8b	6fce9f62-804c-480a-ba62-c337fa44ace7	SERVICE_STATUS_EN_ROUTE	ServiceRequest	434a11c9-298a-432a-9454-30ba7fee3ca0	{"notes": "Technician departed garage; en route via arterial highway.", "toStatus": "EN_ROUTE", "fromStatus": "ACCEPTED"}	\N	\N	2026-11-22 11:36:39.531
acee5513-c9b6-49d1-9d4e-85177be85aa9	6fce9f62-804c-480a-ba62-c337fa44ace7	SERVICE_STATUS_ARRIVED	ServiceRequest	434a11c9-298a-432a-9454-30ba7fee3ca0	{"notes": "Arrived at incident site; positioning emergency safety cones.", "toStatus": "ARRIVED", "fromStatus": "EN_ROUTE"}	\N	\N	2026-11-22 11:36:39.556
d8c39d12-8dbf-4465-8bc7-b6f0e6ddefb1	6fce9f62-804c-480a-ba62-c337fa44ace7	SERVICE_STATUS_IN_PROGRESS	ServiceRequest	434a11c9-298a-432a-9454-30ba7fee3ca0	{"notes": "Disassembled ignition harness; installing new OEM coils.", "toStatus": "IN_PROGRESS", "fromStatus": "ARRIVED"}	\N	\N	2026-11-22 11:36:39.664
c0dc3b89-c95e-4c2a-acb6-7499739a4e3a	6fce9f62-804c-480a-ba62-c337fa44ace7	SERVICE_STATUS_COMPLETED	ServiceRequest	434a11c9-298a-432a-9454-30ba7fee3ca0	{"toStatus": "COMPLETED", "fromStatus": "IN_PROGRESS"}	\N	\N	2026-11-22 11:36:39.691
022b968f-f95f-4238-aad8-2950ab1fdbaf	4a059e43-c586-45be-b371-252f448bbdd8	BREAKDOWN_REPORT_CREATED	BreakdownReport	2d100af3-8bd2-4963-8b0d-22ff3a5ade37	{"category": "FLAT_TIRE_WHEEL", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:36:39.741
45b5f9e2-21dd-4947-901d-2eabc7be84fb	6fce9f62-804c-480a-ba62-c337fa44ace7	DISPATCH_ACCEPTED	ServiceRequest	dd612d8a-26a8-4a09-a02b-eca0f2864e8f	{"mechanicId": "2c562b7b-1e07-4e32-a8ef-12d935fe25e4", "breakdownReportId": "2d100af3-8bd2-4963-8b0d-22ff3a5ade37"}	\N	\N	2026-11-22 11:36:39.763
77850537-353b-45d9-b0e1-e3edb5da2dcb	4a059e43-c586-45be-b371-252f448bbdd8	SERVICE_STATUS_CANCELLED	ServiceRequest	dd612d8a-26a8-4a09-a02b-eca0f2864e8f	{"notes": "Cancellation reason: Spare tire located; vehicle changed independently.", "toStatus": "CANCELLED", "fromStatus": "ACCEPTED", "cancellationReason": "Spare tire located; vehicle changed independently."}	\N	\N	2026-11-22 11:36:39.787
c254e362-babd-4fe8-b000-dda9e7c2e7fc	a1479806-db8e-432b-a61a-04b1494faf85	USER_LOGGED_OUT	User	a1479806-db8e-432b-a61a-04b1494faf85	\N	\N	\N	2026-11-22 11:37:58.348
94536c0e-67aa-40f4-a1ef-38deb2c3cefc	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 11:38:01.75
da9fb29c-6121-43d2-8079-08f00eaa02dd	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_OUT	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 11:38:30.784
6212247a-f526-45a2-9286-d542f9cc17ec	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 11:38:34.329
1db86499-7fa8-48fa-9653-9c30c40c1d13	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_IN_PROGRESS	ServiceRequest	9553175c-91fb-4c65-9a98-4d69aa929cd8	{"notes": "Beginning diagnostic disassembly and component servicing.", "toStatus": "IN_PROGRESS", "fromStatus": "ARRIVED"}	\N	\N	2026-11-22 11:38:40.826
891f7c2b-2109-4162-8fe0-cdc78dfed54b	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_COMPLETED	ServiceRequest	9553175c-91fb-4c65-9a98-4d69aa929cd8	{"notes": "Service finished successfully.", "toStatus": "COMPLETED", "fromStatus": "IN_PROGRESS"}	\N	\N	2026-11-22 11:38:44.938
5c1dbc9b-f385-4420-8cbf-fb5047e1e0c8	473401ce-0803-422f-8baa-a47de557f84e	DISPATCH_ACCEPTED	ServiceRequest	ed02d6e6-6d00-4e09-a9b5-60af2a5f76db	{"mechanicId": "6a01cdea-a7ee-43e1-8a1f-77ecba9b0890", "breakdownReportId": "df37a324-4d01-4d94-a376-1d2a6d82fcc7"}	\N	\N	2026-11-22 11:39:05.459
484508bf-13b1-4937-a34f-21130d046f3e	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_EN_ROUTE	ServiceRequest	ed02d6e6-6d00-4e09-a9b5-60af2a5f76db	{"notes": "Technician departed base en route to incident site.", "toStatus": "EN_ROUTE", "fromStatus": "ACCEPTED"}	\N	\N	2026-11-22 11:39:08.58
f5e634b0-05f3-4958-ac8e-2d1bcfba6e0c	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_ARRIVED	ServiceRequest	ed02d6e6-6d00-4e09-a9b5-60af2a5f76db	{"notes": "Technician arrived on scene at incident coordinates.", "toStatus": "ARRIVED", "fromStatus": "EN_ROUTE"}	\N	\N	2026-11-22 11:39:48.465
c91f9fe1-f049-40a7-a6bc-974b13287b4c	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_IN_PROGRESS	ServiceRequest	ed02d6e6-6d00-4e09-a9b5-60af2a5f76db	{"notes": "Beginning diagnostic disassembly and component servicing.", "toStatus": "IN_PROGRESS", "fromStatus": "ARRIVED"}	\N	\N	2026-11-22 11:39:52.872
3b0d0c19-2477-4615-a036-fa96b7cb3dae	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_COMPLETED	ServiceRequest	ed02d6e6-6d00-4e09-a9b5-60af2a5f76db	{"notes": "Service finished successfully.", "toStatus": "COMPLETED", "fromStatus": "IN_PROGRESS"}	\N	\N	2026-11-22 11:40:29.462
9e1a6e98-4c7e-4d04-a771-7acc4bb71088	473401ce-0803-422f-8baa-a47de557f84e	DISPATCH_ACCEPTED	ServiceRequest	fda2ccbc-d095-4eda-8b7b-1a80c0424b2d	{"mechanicId": "6a01cdea-a7ee-43e1-8a1f-77ecba9b0890", "breakdownReportId": "1a3bbc18-ad93-4373-bb4b-85764d9fdf5f"}	\N	\N	2026-11-22 11:40:33.116
19168402-9b78-4701-a2aa-0cf81a6ac8a6	473401ce-0803-422f-8baa-a47de557f84e	DISPATCH_ACCEPTED	ServiceRequest	676d0e70-58d8-4342-80bd-69e5410d04d2	{"mechanicId": "6a01cdea-a7ee-43e1-8a1f-77ecba9b0890", "breakdownReportId": "fdcf9966-eba5-43a9-b670-91bb394d61e6"}	\N	\N	2026-11-22 11:40:37.044
6b57f811-ce3e-49dc-888a-3a636cea3bb8	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_EN_ROUTE	ServiceRequest	676d0e70-58d8-4342-80bd-69e5410d04d2	{"notes": "Technician departed base en route to incident site.", "toStatus": "EN_ROUTE", "fromStatus": "ACCEPTED"}	\N	\N	2026-11-22 11:40:39.962
269a72e8-5d9b-4137-9abb-955a80ecaba4	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_ARRIVED	ServiceRequest	676d0e70-58d8-4342-80bd-69e5410d04d2	{"notes": "Technician arrived on scene at incident coordinates.", "toStatus": "ARRIVED", "fromStatus": "EN_ROUTE"}	\N	\N	2026-11-22 11:40:40.655
548eadfe-eb64-40ee-a1c6-21271e808a67	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_IN_PROGRESS	ServiceRequest	676d0e70-58d8-4342-80bd-69e5410d04d2	{"notes": "Beginning diagnostic disassembly and component servicing.", "toStatus": "IN_PROGRESS", "fromStatus": "ARRIVED"}	\N	\N	2026-11-22 11:40:41.262
f260e50a-b05e-429c-b7b1-2dcd0cc020bd	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_COMPLETED	ServiceRequest	676d0e70-58d8-4342-80bd-69e5410d04d2	{"notes": "Service finished successfully.", "toStatus": "COMPLETED", "fromStatus": "IN_PROGRESS"}	\N	\N	2026-11-22 11:40:42.363
cc95ad7c-b290-4bb8-8c39-1037fe6e2247	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_EN_ROUTE	ServiceRequest	fda2ccbc-d095-4eda-8b7b-1a80c0424b2d	{"notes": "Technician departed base en route to incident site.", "toStatus": "EN_ROUTE", "fromStatus": "ACCEPTED"}	\N	\N	2026-11-22 11:41:10.303
cffe053a-3cab-4769-98fb-53da6c087bc3	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_ARRIVED	ServiceRequest	fda2ccbc-d095-4eda-8b7b-1a80c0424b2d	{"notes": "Technician arrived on scene at incident coordinates.", "toStatus": "ARRIVED", "fromStatus": "EN_ROUTE"}	\N	\N	2026-11-22 11:41:11.301
b6f5f689-308e-4ff1-8cdb-1e8ef83696b8	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_IN_PROGRESS	ServiceRequest	fda2ccbc-d095-4eda-8b7b-1a80c0424b2d	{"notes": "Beginning diagnostic disassembly and component servicing.", "toStatus": "IN_PROGRESS", "fromStatus": "ARRIVED"}	\N	\N	2026-11-22 11:41:12.322
b853dab9-783c-4647-a493-f1def5ec5551	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_COMPLETED	ServiceRequest	fda2ccbc-d095-4eda-8b7b-1a80c0424b2d	{"notes": "Service finished successfully.", "toStatus": "COMPLETED", "fromStatus": "IN_PROGRESS"}	\N	\N	2026-11-22 11:41:13.399
7e8744ab-d580-4832-8ae0-23b95b9e81ad	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 11:41:26.003
35bb11c4-f37e-4377-88b3-38345849a08c	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_OUT	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 11:41:47.525
b6b79c88-2677-450b-bae0-12c4aacc124d	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 11:41:50.864
b412ceb2-4d52-40a6-946f-18594e232f4e	a1479806-db8e-432b-a61a-04b1494faf85	USER_LOGGED_IN	User	a1479806-db8e-432b-a61a-04b1494faf85	\N	\N	\N	2026-11-22 11:42:01.626
cfcdd511-f35a-415c-be84-2cba0d2c3c26	a1479806-db8e-432b-a61a-04b1494faf85	BREAKDOWN_REPORT_CREATED	BreakdownReport	9b64d833-e393-469b-bab9-6f3561589965	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:42:14.5
f7804bf5-e3e2-46c9-aa12-5eb397b38a39	a1479806-db8e-432b-a61a-04b1494faf85	USER_LOGGED_OUT	User	a1479806-db8e-432b-a61a-04b1494faf85	\N	\N	\N	2026-11-22 11:42:59.314
4ebb7d2b-19e5-4025-9003-e9df89a163a9	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 11:43:02.213
182317ed-08da-409f-9e54-9641484c58f9	473401ce-0803-422f-8baa-a47de557f84e	DISPATCH_ACCEPTED	ServiceRequest	3ec2a6c1-9aba-4659-921a-7a24abe3118c	{"mechanicId": "6a01cdea-a7ee-43e1-8a1f-77ecba9b0890", "breakdownReportId": "9b64d833-e393-469b-bab9-6f3561589965"}	\N	\N	2026-11-22 11:43:23.282
f059569c-fe29-4242-84c1-481cadc807c4	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_EN_ROUTE	ServiceRequest	3ec2a6c1-9aba-4659-921a-7a24abe3118c	{"notes": "Technician departed base en route to incident site.", "toStatus": "EN_ROUTE", "fromStatus": "ACCEPTED"}	\N	\N	2026-11-22 11:43:53.939
6c381d2e-9bce-4ff8-8d74-462834faaab9	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_ARRIVED	ServiceRequest	3ec2a6c1-9aba-4659-921a-7a24abe3118c	{"notes": "Technician arrived on scene at incident coordinates.", "toStatus": "ARRIVED", "fromStatus": "EN_ROUTE"}	\N	\N	2026-11-22 11:43:58.608
816d1941-021a-4f11-9018-fe0d1e8018ee	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_IN_PROGRESS	ServiceRequest	3ec2a6c1-9aba-4659-921a-7a24abe3118c	{"notes": "Beginning diagnostic disassembly and component servicing.", "toStatus": "IN_PROGRESS", "fromStatus": "ARRIVED"}	\N	\N	2026-11-22 11:44:05.575
3899e337-2f2b-457a-93f6-8115f632994b	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_COMPLETED	ServiceRequest	3ec2a6c1-9aba-4659-921a-7a24abe3118c	{"notes": "Service finished successfully.", "toStatus": "COMPLETED", "fromStatus": "IN_PROGRESS"}	\N	\N	2026-11-22 11:44:18.571
f9b76d4e-ca94-4490-bbae-640eaa98180a	a89d8a1e-ad80-4555-a258-0392941f695b	USER_REGISTERED	User	a89d8a1e-ad80-4555-a258-0392941f695b	{"role": "CUSTOMER", "email": "sec.cust1.1795348331140@vbrs.local"}	\N	\N	2026-11-22 11:52:11.381
08a7a9a3-6c20-4374-bbc9-cb9b38186949	3ed21b94-d1fe-4433-8464-75cf1d4fb9e4	USER_REGISTERED	User	3ed21b94-d1fe-4433-8464-75cf1d4fb9e4	{"role": "CUSTOMER", "email": "sec.cust2.1795348331140@vbrs.local"}	\N	\N	2026-11-22 11:52:11.622
0f113245-2da8-44fe-bafe-bdba3eec0987	a62fc8d6-66ce-471b-b268-b23c2051f9f1	USER_REGISTERED	User	a62fc8d6-66ce-471b-b268-b23c2051f9f1	{"role": "MECHANIC", "email": "sec.mech.1795348331140@vbrs.local"}	\N	\N	2026-11-22 11:52:11.859
718c4662-b8ac-482c-b4df-e9406312d184	028383ec-4ed0-4010-b4a2-c4cc161da698	USER_REGISTERED	User	028383ec-4ed0-4010-b4a2-c4cc161da698	{"role": "ADMIN", "email": "sec.admin.1795348331140@vbrs.local"}	\N	\N	2026-11-22 11:52:12.093
00ca3bbe-cee7-4d45-9631-452bbbbad047	766576f6-0959-4864-8a7e-649df595336b	USER_REGISTERED	User	766576f6-0959-4864-8a7e-649df595336b	{"role": "CUSTOMER", "email": "sec.cust1.1795348371142@vbrs.local"}	\N	\N	2026-11-22 11:52:51.38
24351ccf-e119-494a-8c51-87a08344950a	0c20acda-40da-4f0e-b42f-44bbbc0a1af1	USER_REGISTERED	User	0c20acda-40da-4f0e-b42f-44bbbc0a1af1	{"role": "CUSTOMER", "email": "sec.cust2.1795348371142@vbrs.local"}	\N	\N	2026-11-22 11:52:51.617
321d59f4-6b17-4c4a-a9ee-67313a67e126	d8815573-617c-4a9f-a950-507542203e55	USER_REGISTERED	User	d8815573-617c-4a9f-a950-507542203e55	{"role": "MECHANIC", "email": "sec.mech.1795348371142@vbrs.local"}	\N	\N	2026-11-22 11:52:51.855
b161f59b-b8d3-45f7-8cad-c47a4655126a	a6b612af-845d-49fa-b456-67250cdb4014	USER_REGISTERED	User	a6b612af-845d-49fa-b456-67250cdb4014	{"role": "ADMIN", "email": "sec.admin.1795348371142@vbrs.local"}	\N	\N	2026-11-22 11:52:52.085
879f83f4-48a9-4140-ada6-d79ef6c80c5d	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 11:54:11.999
519c52bd-2c01-419e-803c-6c46153f9f45	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 11:54:21.797
23270b05-33ca-4cee-a4fa-398ab46eeebf	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 11:54:31.461
e03e5d6f-e8b6-4b49-a406-417303d4e233	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 11:54:40.938
30ad73c2-d345-4b6a-8630-3f5c74985aa5	ff166c12-fa96-4a4d-8523-7e1801d01b3f	USER_REGISTERED	User	ff166c12-fa96-4a4d-8523-7e1801d01b3f	{"role": "CUSTOMER", "email": "m5.cust1.1795348523391@vbrs.local"}	\N	\N	2026-11-22 11:55:23.953
de22638f-b46b-4a8c-91e0-28b6a772a660	f2486095-f7f5-4923-8dd4-bbdfad681499	USER_REGISTERED	User	f2486095-f7f5-4923-8dd4-bbdfad681499	{"role": "CUSTOMER", "email": "audit.customer.1795348523404@vbrs.local"}	\N	\N	2026-11-22 11:55:23.984
94cb2848-d2b4-439f-a3e0-58a46fb62593	eeec89bd-77f1-4b87-b039-63f9778b4621	USER_REGISTERED	User	eeec89bd-77f1-4b87-b039-63f9778b4621	{"role": "CUSTOMER", "email": "m3.edge.custa.1795348523471@vbrs.local"}	\N	\N	2026-11-22 11:55:24.022
7f63dfb3-bcc4-4914-8518-1076ed4b08a1	4b4b0149-ece4-4281-9c87-ad93e8ccf2a8	USER_REGISTERED	User	4b4b0149-ece4-4281-9c87-ad93e8ccf2a8	{"role": "CUSTOMER", "email": "m2.customer.1795348523467@vbrs.local"}	\N	\N	2026-11-22 11:55:24.047
ac01cd98-3458-4c3d-b729-d711f761dde7	fe4fed22-b93a-4dfe-b237-66a079f96a50	USER_REGISTERED	User	fe4fed22-b93a-4dfe-b237-66a079f96a50	{"role": "CUSTOMER", "email": "m4.customer.1795348523552@vbrs.local"}	\N	\N	2026-11-22 11:55:24.078
274e0afd-dff7-47a5-a229-44df5580ae5b	e43779a3-03a2-4ed0-a27b-1c66d4ab40bf	USER_REGISTERED	User	e43779a3-03a2-4ed0-a27b-1c66d4ab40bf	{"role": "CUSTOMER", "email": "sec.cust1.1795348523793@vbrs.local"}	\N	\N	2026-11-22 11:55:24.085
b1abbbcb-191f-464f-bfab-4277a41e717c	c5be2c05-7982-46af-9db0-2f3f296f630b	USER_REGISTERED	User	c5be2c05-7982-46af-9db0-2f3f296f630b	{"role": "CUSTOMER", "email": "m7.customer1.1795348523820@vbrs.local"}	\N	\N	2026-11-22 11:55:24.134
dd2236d9-e315-4c65-b9b3-d1b25606b300	9cf8cdc2-da2f-4b7a-ac59-c6b590ebed6a	USER_REGISTERED	User	9cf8cdc2-da2f-4b7a-ac59-c6b590ebed6a	{"role": "ADMIN", "email": "m6.admin.1795348523689@vbrs.local"}	\N	\N	2026-11-22 11:55:24.139
dd77ffc8-8a88-458e-bef5-c18cabb5c789	935f0c45-76f4-4be0-8fb0-95fb6009b2dd	USER_REGISTERED	User	935f0c45-76f4-4be0-8fb0-95fb6009b2dd	{"role": "CUSTOMER", "email": "m3.customer.1795348523653@vbrs.local"}	\N	\N	2026-11-22 11:55:24.14
555770cb-3287-4f5f-b8b5-069abc832a57	863029a2-5a25-4be2-be07-0680e859f3f2	USER_REGISTERED	User	863029a2-5a25-4be2-be07-0680e859f3f2	{"role": "CUSTOMER", "email": "m7.customer2.1795348523820@vbrs.local"}	\N	\N	2026-11-22 11:55:24.407
35fc230a-e491-46fc-86e0-9ba6b82df58e	958f62e7-0865-4490-a441-8d32eb95ef31	USER_REGISTERED	User	958f62e7-0865-4490-a441-8d32eb95ef31	{"role": "CUSTOMER", "email": "m3.userb.1795348523653@vbrs.local"}	\N	\N	2026-11-22 11:55:24.417
6a6fb197-adcb-4dfd-8cda-0630fd75dfce	413f9c28-135a-41dc-9ae3-29f264612e2c	USER_REGISTERED	User	413f9c28-135a-41dc-9ae3-29f264612e2c	{"role": "CUSTOMER", "email": "m6.customer.1795348523689@vbrs.local"}	\N	\N	2026-11-22 11:55:24.432
81a56481-06f0-4ab0-b4f3-ead7059bd90c	935f0c45-76f4-4be0-8fb0-95fb6009b2dd	BREAKDOWN_REPORT_CREATED	BreakdownReport	4044d874-f4a8-4af4-b5b1-391d300c67a1	{"category": "ENGINE_FAILURE", "severity": "CRITICAL", "imageCount": 1, "requiresTowing": true}	\N	\N	2026-11-22 11:55:24.478
4f873644-1e5e-4177-8a48-01074785b598	935f0c45-76f4-4be0-8fb0-95fb6009b2dd	BREAKDOWN_REPORT_CREATED	BreakdownReport	9d3051c0-8388-42a6-9915-01e654a8f25e	{"category": "FLAT_TIRE_WHEEL", "severity": "LOW", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:55:24.509
bb43437a-3c59-4652-a6f4-87d025dae519	8bc999de-3d28-4b57-af72-a5c2e2ac6dab	USER_REGISTERED	User	8bc999de-3d28-4b57-af72-a5c2e2ac6dab	{"role": "MECHANIC", "email": "m7.mechanic.1795348523820@vbrs.local"}	\N	\N	2026-11-22 11:55:24.693
9751b17e-a976-4a59-bb04-58cea3186973	e50326f1-92b0-4149-ab38-88e681b1037c	USER_REGISTERED	User	e50326f1-92b0-4149-ab38-88e681b1037c	{"role": "MECHANIC", "email": "m6.pending.mech.1795348523689@vbrs.local"}	\N	\N	2026-11-22 11:55:24.722
5b94e84a-fafd-40ed-987c-b851f6a1d541	413f9c28-135a-41dc-9ae3-29f264612e2c	BREAKDOWN_REPORT_CREATED	BreakdownReport	28561722-6044-40b7-8585-fa98bc261428	{"category": "BRAKE_SYSTEM_FAILURE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 11:55:24.768
4f49f5bc-5b43-4cb2-ad2c-954f58e43c78	9cf8cdc2-da2f-4b7a-ac59-c6b590ebed6a	MECHANIC_VERIFICATION_APPROVED	MechanicProfile	c9051638-c88a-4e64-92f9-215e1db40cbe	{"notes": "ASE Master Certificate #88391 confirmed valid with State Board.", "newStatus": "APPROVED", "previousStatus": "PENDING", "technicianEmail": "m6.pending.mech.1795348523689@vbrs.local"}	\N	\N	2026-11-22 11:55:24.87
21810a92-44db-4158-8331-241a045770ab	413f9c28-135a-41dc-9ae3-29f264612e2c	COMPLAINT_FILED	Complaint	142084f8-2ad0-42bb-9398-0fd57a7d20c5	{"subject": "Late Arrival & Tow Rig Discrepancy", "serviceRequestId": "0d5a0499-55d9-4794-bd0c-0b8547a88bb5"}	\N	\N	2026-11-22 11:55:24.898
1c23746e-8acf-4beb-89e2-9e43cdbdb895	c5be2c05-7982-46af-9db0-2f3f296f630b	CUSTOMER_REVIEW_SUBMITTED	Review	40f5929f-7393-45ac-808b-42d7ae5615bd	{"rating": 5, "mechanicId": "243c49ee-6224-4c57-95ee-8b9a7367ed63", "totalReviews": 1, "ratingAverage": 5, "serviceRequestId": "ed670800-8de3-451e-9d9d-1140d81e0f62"}	\N	\N	2026-11-22 11:55:24.934
bcfecfa0-0d2b-41ab-8175-ea97e3394f05	9cf8cdc2-da2f-4b7a-ac59-c6b590ebed6a	COMPLAINT_STATUS_INVESTIGATING	Complaint	142084f8-2ad0-42bb-9398-0fd57a7d20c5	{"toStatus": "INVESTIGATING", "fromStatus": "PENDING", "resolutionNotes": "Contacted fleet dispatch log to verify arterial traffic delay."}	\N	\N	2026-11-22 11:55:24.956
1348ea9b-1fdb-44b1-9535-d364dba4648d	863029a2-5a25-4be2-be07-0680e859f3f2	CUSTOMER_REVIEW_SUBMITTED	Review	6cacda2c-1625-4f73-a427-33fb6833e800	{"rating": 3, "mechanicId": "243c49ee-6224-4c57-95ee-8b9a7367ed63", "totalReviews": 2, "ratingAverage": 4, "serviceRequestId": "d73e5417-717c-4745-9e50-e1b68a2d557b"}	\N	\N	2026-11-22 11:55:24.967
d977c159-126b-4c54-ace5-9b37adeeaf50	9cf8cdc2-da2f-4b7a-ac59-c6b590ebed6a	COMPLAINT_STATUS_RESOLVED	Complaint	142084f8-2ad0-42bb-9398-0fd57a7d20c5	{"toStatus": "RESOLVED", "fromStatus": "INVESTIGATING", "resolutionNotes": "Traffic bottleneck verified on camera feed. Courtesy credit applied."}	\N	\N	2026-11-22 11:55:24.971
68059e25-fb70-4180-b709-ed2947f01627	a995ae67-343e-4363-bdf9-0375d0f33f4e	USER_REGISTERED	User	a995ae67-343e-4363-bdf9-0375d0f33f4e	{"role": "CUSTOMER", "email": "m5.cust2.1795348523391@vbrs.local"}	\N	\N	2026-11-22 11:55:24.247
9a3c2ec0-3700-4ea9-a0a5-2a6e00cf7130	93379134-a271-44fa-bf5a-314fe8520bca	USER_REGISTERED	User	93379134-a271-44fa-bf5a-314fe8520bca	{"role": "MECHANIC", "email": "m5.mech1.1795348523391@vbrs.local"}	\N	\N	2026-11-22 11:55:24.52
5d53cc77-d9a4-41ce-9de8-0e25fd4d9d16	4469db4e-5fa2-4654-a406-28cdc4c47994	USER_REGISTERED	User	4469db4e-5fa2-4654-a406-28cdc4c47994	{"role": "MECHANIC", "email": "m5.mech2.1795348523391@vbrs.local"}	\N	\N	2026-11-22 11:55:24.816
c4230703-8a15-4b70-ac51-61f97721b56f	bbdeedcd-4da8-41f3-9c48-fda072eb1658	USER_REGISTERED	User	bbdeedcd-4da8-41f3-9c48-fda072eb1658	{"role": "ADMIN", "email": "m5.admin.1795348523391@vbrs.local"}	\N	\N	2026-11-22 11:55:25.094
215392f3-5357-42a1-88e9-d5c048aba574	ff166c12-fa96-4a4d-8523-7e1801d01b3f	BREAKDOWN_REPORT_CREATED	BreakdownReport	2cf2f727-6312-48cd-bd20-16380a1cbb20	{"category": "ENGINE_FAILURE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 11:55:25.134
568df47d-8f68-41db-b2c5-e9b79c0a0b44	93379134-a271-44fa-bf5a-314fe8520bca	DISPATCH_ACCEPTED	ServiceRequest	5021bb4b-6cac-4433-99b7-ba950e814865	{"mechanicId": "26a6a314-dba2-4b11-b975-81ddcf76ef3a", "breakdownReportId": "2cf2f727-6312-48cd-bd20-16380a1cbb20"}	\N	\N	2026-11-22 11:55:25.17
83c91752-167d-43ab-aca7-f0154f96f785	93379134-a271-44fa-bf5a-314fe8520bca	SERVICE_STATUS_EN_ROUTE	ServiceRequest	5021bb4b-6cac-4433-99b7-ba950e814865	{"notes": "Technician departed garage; en route via arterial highway.", "toStatus": "EN_ROUTE", "fromStatus": "ACCEPTED"}	\N	\N	2026-11-22 11:55:25.307
470bc97e-2c86-4b47-bd14-2ac24a521d1a	93379134-a271-44fa-bf5a-314fe8520bca	SERVICE_STATUS_ARRIVED	ServiceRequest	5021bb4b-6cac-4433-99b7-ba950e814865	{"notes": "Arrived at incident site; positioning emergency safety cones.", "toStatus": "ARRIVED", "fromStatus": "EN_ROUTE"}	\N	\N	2026-11-22 11:55:25.334
4b436696-fe5f-4406-86de-e6c98293b03f	93379134-a271-44fa-bf5a-314fe8520bca	SERVICE_STATUS_IN_PROGRESS	ServiceRequest	5021bb4b-6cac-4433-99b7-ba950e814865	{"notes": "Disassembled ignition harness; installing new OEM coils.", "toStatus": "IN_PROGRESS", "fromStatus": "ARRIVED"}	\N	\N	2026-11-22 11:55:25.447
1df894c3-aad8-4bac-9d52-22f6e35d28ce	93379134-a271-44fa-bf5a-314fe8520bca	SERVICE_STATUS_COMPLETED	ServiceRequest	5021bb4b-6cac-4433-99b7-ba950e814865	{"toStatus": "COMPLETED", "fromStatus": "IN_PROGRESS"}	\N	\N	2026-11-22 11:55:25.473
de4c1e4d-b18c-4cb2-bf53-7ab718f70b86	ff166c12-fa96-4a4d-8523-7e1801d01b3f	BREAKDOWN_REPORT_CREATED	BreakdownReport	29ef0dd0-0c14-4218-9e47-f83a126bf3ee	{"category": "FLAT_TIRE_WHEEL", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:55:25.524
4793c65f-e3f9-45aa-afc4-432522151eaa	93379134-a271-44fa-bf5a-314fe8520bca	DISPATCH_ACCEPTED	ServiceRequest	aa3b0763-ff80-411c-ad22-c35fd8344202	{"mechanicId": "26a6a314-dba2-4b11-b975-81ddcf76ef3a", "breakdownReportId": "29ef0dd0-0c14-4218-9e47-f83a126bf3ee"}	\N	\N	2026-11-22 11:55:25.546
0c972d01-e13f-483a-881d-368e00ff2256	ff166c12-fa96-4a4d-8523-7e1801d01b3f	SERVICE_STATUS_CANCELLED	ServiceRequest	aa3b0763-ff80-411c-ad22-c35fd8344202	{"notes": "Cancellation reason: Spare tire located; vehicle changed independently.", "toStatus": "CANCELLED", "fromStatus": "ACCEPTED", "cancellationReason": "Spare tire located; vehicle changed independently."}	\N	\N	2026-11-22 11:55:25.567
d72d0007-0d41-45ec-a41e-044ff505a1fb	cf2a50da-6587-4cf0-8fbf-fbbd1a6474a4	USER_REGISTERED	User	cf2a50da-6587-4cf0-8fbf-fbbd1a6474a4	{"role": "MECHANIC", "email": "audit.mechanic.1795348523404@vbrs.local"}	\N	\N	2026-11-22 11:55:24.273
618ac90d-068c-4620-80cc-62708f120a95	f2486095-f7f5-4923-8dd4-bbdfad681499	USER_LOGGED_IN	User	f2486095-f7f5-4923-8dd4-bbdfad681499	\N	\N	\N	2026-11-22 11:55:24.547
997d6a47-2fc8-400a-9690-8cfd3561ca8f	cf2a50da-6587-4cf0-8fbf-fbbd1a6474a4	USER_LOGGED_IN	User	cf2a50da-6587-4cf0-8fbf-fbbd1a6474a4	\N	\N	\N	2026-11-22 11:55:24.826
f9de64e9-9909-4519-a716-728c422795ca	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 11:55:25.107
300df9b6-cb90-4f18-bd70-8f433670bc81	bd268487-3f47-4226-9287-a6f28215b3ef	USER_REGISTERED	User	bd268487-3f47-4226-9287-a6f28215b3ef	{"role": "CUSTOMER", "email": "audit.userb.1795348523404@vbrs.local"}	\N	\N	2026-11-22 11:55:25.598
5798b2af-39cf-44da-8e2c-a9ea609eab87	f2486095-f7f5-4923-8dd4-bbdfad681499	VEHICLE_ADDED	Vehicle	a01f33be-7d01-4011-a8ac-0f7ba90ce7aa	{"make": "Porsche", "model": "Taycan GTS", "plate": "AUD-3406"}	\N	\N	2026-11-22 11:55:26.118
80ae6025-f565-4d71-9e94-3216754dea57	f2486095-f7f5-4923-8dd4-bbdfad681499	VEHICLE_UPDATED	Vehicle	a01f33be-7d01-4011-a8ac-0f7ba90ce7aa	\N	\N	\N	2026-11-22 11:55:26.14
a06d6dfb-8e09-4f2d-a735-aa76ae4e7d0b	f2486095-f7f5-4923-8dd4-bbdfad681499	VEHICLE_DELETED	Vehicle	a01f33be-7d01-4011-a8ac-0f7ba90ce7aa	{"plate": "AUD-3406"}	\N	\N	2026-11-22 11:55:26.164
c328ba58-af71-47b4-9df7-2b6821ec33c3	189ee5a7-5c5b-4120-a133-e29310c9dc2a	USER_REGISTERED	User	189ee5a7-5c5b-4120-a133-e29310c9dc2a	{"role": "CUSTOMER", "email": "m3.edge.custb.1795348523471@vbrs.local"}	\N	\N	2026-11-22 11:55:24.304
6f27eacc-7d0d-46a4-830f-0b5b290e8827	94ae7a86-4904-4f65-be33-bcd6730fcb95	USER_REGISTERED	User	94ae7a86-4904-4f65-be33-bcd6730fcb95	{"role": "MECHANIC", "email": "m3.edge.mech.1795348523471@vbrs.local"}	\N	\N	2026-11-22 11:55:24.613
f56173ef-424e-443c-bc37-2c6687eb787d	eeec89bd-77f1-4b87-b039-63f9778b4621	VEHICLE_ADDED	Vehicle	a1f35bc6-bdfa-4770-ac93-26622cd77c2e	{"make": "Porsche", "model": "911 GT3", "plate": "EDGE-A-4622"}	\N	\N	2026-11-22 11:55:24.642
568a545e-e5c5-4e12-a5f1-77f7de0abc90	189ee5a7-5c5b-4120-a133-e29310c9dc2a	VEHICLE_ADDED	Vehicle	384836fb-2ab2-4ce8-a79c-0dc2c8a27240	{"make": "Tesla", "model": "Model S Plaid", "plate": "EDGE-B-4646"}	\N	\N	2026-11-22 11:55:24.657
1cff6fca-04b2-425b-86b9-31a0f19366b1	eeec89bd-77f1-4b87-b039-63f9778b4621	BREAKDOWN_REPORT_CREATED	BreakdownReport	4293a444-f8c9-4993-8c12-683415bf4f95	{"category": "COLLISION_ACCIDENT", "severity": "CRITICAL", "imageCount": 5, "requiresTowing": true}	\N	\N	2026-11-22 11:55:24.777
68e44dbd-8669-4fb8-95da-f4e194a7461e	eeec89bd-77f1-4b87-b039-63f9778b4621	BREAKDOWN_REPORT_CREATED	BreakdownReport	c47a7165-a241-47b3-9e5c-e74bcadc472f	{"category": "BRAKE_SYSTEM_FAILURE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 11:55:24.865
707dee86-75f5-4aa7-a325-fe739b7553ca	eeec89bd-77f1-4b87-b039-63f9778b4621	BREAKDOWN_REPORT_CREATED	BreakdownReport	3ad6e8f9-bb57-4011-8b0c-c6e394cefbfe	{"category": "BATTERY_DEAD_ELECTRICAL", "severity": "MEDIUM", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 11:55:24.902
a67fd07d-7c46-4594-bf61-73454a96d78d	eeec89bd-77f1-4b87-b039-63f9778b4621	BREAKDOWN_REPORT_CREATED	BreakdownReport	3944cf87-4b61-42bd-8823-ab0a9d694c59	{"category": "TRANSMISSION_ISSUE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 11:55:24.933
f4b1e4aa-2fb2-4c3c-b818-308a62260d4f	eeec89bd-77f1-4b87-b039-63f9778b4621	BREAKDOWN_REPORT_CREATED	BreakdownReport	e0440403-d555-44d7-a484-7bd3ab1fa1d7	{"category": "FUEL_EMPTY_OR_CONTAMINATED", "severity": "LOW", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:55:24.977
3956c46a-3395-420e-9e37-97fc83cdf48f	eeec89bd-77f1-4b87-b039-63f9778b4621	BREAKDOWN_REPORT_CREATED	BreakdownReport	52954004-6d7c-4584-90cc-7085607573fe	{"category": "OVERHEATING_COOLANT", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:55:25.002
23ece788-cf0c-475a-b78a-1c8f51f830cb	eeec89bd-77f1-4b87-b039-63f9778b4621	BREAKDOWN_REPORT_CREATED	BreakdownReport	1ebc6681-1a3a-4015-82aa-5989a808cb7c	{"category": "LOCKOUT_KEY_LOST", "severity": "LOW", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 11:55:25.05
462de306-ad58-4b35-bdd6-8d6c0c74f219	064a6840-01ae-4133-8933-d1d2fd6a3af5	USER_REGISTERED	User	064a6840-01ae-4133-8933-d1d2fd6a3af5	{"role": "CUSTOMER", "email": "sec.cust2.1795348523793@vbrs.local"}	\N	\N	2026-11-22 11:55:24.353
8d62742a-600e-4da4-95fa-8b3bbbc9d3c2	62b2d075-5944-43e7-89a8-26146484ab12	USER_REGISTERED	User	62b2d075-5944-43e7-89a8-26146484ab12	{"role": "MECHANIC", "email": "sec.mech.1795348523793@vbrs.local"}	\N	\N	2026-11-22 11:55:24.63
11fc4d31-21b8-4191-9961-e1be1855de8e	86063df1-5f0d-4cda-9d5c-5124c3c670d6	USER_REGISTERED	User	86063df1-5f0d-4cda-9d5c-5124c3c670d6	{"role": "ADMIN", "email": "sec.admin.1795348523793@vbrs.local"}	\N	\N	2026-11-22 11:55:24.906
c2415416-8db1-4565-a26f-50bd48a21ec2	0c0768ce-b175-46fb-8444-26488c274cba	USER_REGISTERED	User	0c0768ce-b175-46fb-8444-26488c274cba	{"role": "MECHANIC", "email": "m4.mech1.1795348523552@vbrs.local"}	\N	\N	2026-11-22 11:55:24.38
30f4a081-47f7-42b3-ba33-6803ed5aacc8	d3900c77-40a4-4e6e-8255-038d9aed2a21	USER_REGISTERED	User	d3900c77-40a4-4e6e-8255-038d9aed2a21	{"role": "MECHANIC", "email": "m4.mech2.1795348523552@vbrs.local"}	\N	\N	2026-11-22 11:55:24.675
f1242ae7-cfe3-4551-9008-bd82d48c1905	fe4fed22-b93a-4dfe-b237-66a079f96a50	BREAKDOWN_REPORT_CREATED	BreakdownReport	99e0bd8d-3fec-4c08-ae5c-ed0fc3bc32a7	{"category": "FLAT_TIRE_WHEEL", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:55:24.719
bff374a9-ba29-4862-85fb-43a994e522ec	0c0768ce-b175-46fb-8444-26488c274cba	DISPATCH_ACCEPTED	ServiceRequest	3eebafd4-0699-42ae-b201-6b0d739f9f1f	{"mechanicId": "56596f10-d230-44c3-b5b0-a52fcc7a0302", "breakdownReportId": "99e0bd8d-3fec-4c08-ae5c-ed0fc3bc32a7"}	\N	\N	2026-11-22 11:55:25.027
c14e1d36-40e6-4d3a-a58c-79581f0fdab8	4b4b0149-ece4-4281-9c87-ad93e8ccf2a8	VEHICLE_ADDED	Vehicle	0de936b9-8173-4162-b0c3-1e0e369e9e21	{"make": "Ford", "model": "Mustang Mach-E", "plate": "M2-4690"}	\N	\N	2026-11-22 11:55:24.709
e59a5a6c-3d25-4f7d-895b-3dfda8e66b11	4b4b0149-ece4-4281-9c87-ad93e8ccf2a8	VEHICLE_UPDATED	Vehicle	0de936b9-8173-4162-b0c3-1e0e369e9e21	\N	\N	\N	2026-11-22 11:55:24.764
1e67993e-6d92-4acb-92fc-38572adfb431	4b4b0149-ece4-4281-9c87-ad93e8ccf2a8	VEHICLE_DELETED	Vehicle	0de936b9-8173-4162-b0c3-1e0e369e9e21	{"plate": "M2-4690"}	\N	\N	2026-11-22 11:55:24.798
ad17e792-5a23-48c3-953f-954dba59f6b3	4b4b0149-ece4-4281-9c87-ad93e8ccf2a8	USER_LOGGED_OUT	User	4b4b0149-ece4-4281-9c87-ad93e8ccf2a8	\N	\N	\N	2026-11-22 11:55:24.824
c7cc73f6-4fd9-4ad1-bf08-9df690593023	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 11:56:10.044
8d2c9029-4add-4dc9-aa8a-7b084f7b2edc	e22478b0-00a4-44f8-b146-3649213c7a20	VEHICLE_ADDED	Vehicle	798c9053-f133-400f-a625-0247195d69cf	{"make": "Audi", "model": "RS6 Avant", "plate": "E2E-1606"}	\N	\N	2026-11-22 11:56:11.663
e2907a89-5c67-4e45-9f87-389e038ffc34	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 11:56:20.459
3427324b-c50f-4039-b7ce-7570421e9a3b	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	e317df69-1c34-4324-a280-aa0d53c1112d	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 11:56:31.045
4d51913c-eaad-4b24-9daf-d6cfddd3c97a	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 11:56:33.099
4499ff84-ea8e-4991-99fa-60d5a7400fb8	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	f6f383be-6c44-4f0e-bb2b-45cea04224da	{"category": "TRANSMISSION_ISSUE", "severity": "CRITICAL", "imageCount": 1, "requiresTowing": true}	\N	\N	2026-11-22 11:56:24.031
96927501-da20-4b83-a3bf-89ac71250e8d	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 11:56:26.218
f6293b21-f5f2-48cc-b0d0-fcbc9b8495ea	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	ea3fcfd7-078d-499f-a11d-37196fec2b8a	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 11:56:35.185
4b1e940b-1605-4f8b-b692-3395e1591e74	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 11:56:36.055
185960f5-e13b-4f74-9806-be4bd8b3cc54	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 12:00:45.795
d91cd90d-e42e-4ea0-8b33-7253d5054edf	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	e54e3755-f888-459b-9047-60691b32802d	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 12:00:47.675
8b30d728-7dae-4fe2-9ff9-ec10ac70f893	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 12:00:48.6
c7f49b5a-f5fd-43ee-89a4-17bee271ffae	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 12:02:53.125
67469db0-1092-4f9f-853a-6dcc409b0f6e	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	e33d20bb-2436-466d-b117-61201f06b5dc	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 12:02:55.219
d53df85b-8b6d-4337-9eed-35507bb5a0ed	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 12:02:56.1
3cc20e26-1112-4a1e-b84b-e4a664aed756	473401ce-0803-422f-8baa-a47de557f84e	DISPATCH_ACCEPTED	ServiceRequest	84f3f21a-d1eb-49dc-99b0-98e662f808b0	{"mechanicId": "6a01cdea-a7ee-43e1-8a1f-77ecba9b0890", "breakdownReportId": "e33d20bb-2436-466d-b117-61201f06b5dc"}	\N	\N	2026-11-22 12:03:02.159
752bb7df-40b5-4a6f-b0f3-d4e59d9bb1f4	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 12:03:28.617
73050b01-0e88-40a6-a0d8-accab1b54745	e22478b0-00a4-44f8-b146-3649213c7a20	VEHICLE_ADDED	Vehicle	26f2f846-36f2-4118-bf6f-283738a7ba33	{"make": "Audi", "model": "RS6 Avant", "plate": "E2E-0176"}	\N	\N	2026-11-22 12:03:30.23
d4b9092c-51e5-4af7-94b8-ffb090f9b26f	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 12:03:39.011
89a26e1d-8fb6-49ab-9390-a93d2b59b266	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	6dc19581-1f1f-4a36-a677-4a50b150fce5	{"category": "TRANSMISSION_ISSUE", "severity": "CRITICAL", "imageCount": 1, "requiresTowing": true}	\N	\N	2026-11-22 12:03:42.575
6277d948-d1ac-4d08-bc29-8277d0c07d6d	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 12:03:44.638
8980a5f9-ecf1-48de-abbc-4b7c134039a7	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	69551a64-33a8-4e75-8baf-2b9e850826fe	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 12:03:49.439
4826fb58-bdd7-4a67-8c94-b0f093f6a4d8	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 12:03:51.46
43ddcf2e-51a5-4afb-abfe-341fd447afe6	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	8e424443-420f-42b5-9879-0e150a72f664	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 12:03:53.532
4e22debd-aa51-48d2-a66c-cac9ff6f680a	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 12:03:54.38
e394164a-f97e-436c-9746-224f37d476d3	473401ce-0803-422f-8baa-a47de557f84e	DISPATCH_ACCEPTED	ServiceRequest	e10cd90e-038b-4282-a97a-20bd7447dec4	{"mechanicId": "6a01cdea-a7ee-43e1-8a1f-77ecba9b0890", "breakdownReportId": "8e424443-420f-42b5-9879-0e150a72f664"}	\N	\N	2026-11-22 12:04:01.472
b257ff76-5513-40f9-9f91-d40016495310	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 12:04:03.462
2587a7f9-4f6f-41a1-b53e-24f81b2a1de8	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	825701fc-b817-4525-83ad-1d4baa29a894	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 12:04:05.57
f34c2cd7-4f40-45e3-9ea0-a35b8079ecb9	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 12:04:06.432
e8e0d6cf-8755-4229-aa6d-11c265f660fd	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 12:04:14.71
4f97d1e6-313a-48ae-adc9-41ae57520464	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	d3a66f3c-c30d-48f1-b4d1-c872902b948d	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 12:04:15.811
23c5dcc2-3eaf-498b-9f48-b2efb9fdb8ad	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 12:04:17.171
8cadff2b-12ef-4006-8436-13b5a2a13e16	473401ce-0803-422f-8baa-a47de557f84e	DISPATCH_ACCEPTED	ServiceRequest	8803967b-4005-4993-965c-e4c5354f7349	{"mechanicId": "6a01cdea-a7ee-43e1-8a1f-77ecba9b0890", "breakdownReportId": "d3a66f3c-c30d-48f1-b4d1-c872902b948d"}	\N	\N	2026-11-22 12:04:19.127
67489c79-de6b-4300-9eb6-f297280061b4	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_EN_ROUTE	ServiceRequest	8803967b-4005-4993-965c-e4c5354f7349	{"notes": "Technician departed base en route to incident site.", "toStatus": "EN_ROUTE", "fromStatus": "ACCEPTED"}	\N	\N	2026-11-22 12:04:19.219
396519f6-d49a-47a1-88fd-add8da5ab85f	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_ARRIVED	ServiceRequest	8803967b-4005-4993-965c-e4c5354f7349	{"notes": "Technician arrived on scene at incident coordinates.", "toStatus": "ARRIVED", "fromStatus": "EN_ROUTE"}	\N	\N	2026-11-22 12:04:21.768
c574dfb0-5674-4812-8c22-19d479b6a532	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_IN_PROGRESS	ServiceRequest	8803967b-4005-4993-965c-e4c5354f7349	{"notes": "Beginning diagnostic disassembly and component servicing.", "toStatus": "IN_PROGRESS", "fromStatus": "ARRIVED"}	\N	\N	2026-11-22 12:04:23.429
456d6391-6694-47bd-8376-e3190a5be4b9	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_COMPLETED	ServiceRequest	8803967b-4005-4993-965c-e4c5354f7349	{"notes": "Service finished successfully.", "toStatus": "COMPLETED", "fromStatus": "IN_PROGRESS"}	\N	\N	2026-11-22 12:04:23.535
103f1104-221c-4854-bede-95d1d20c1367	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 12:04:26.596
b8f4a9e5-9eb3-4b23-a5e8-c5082a4ec0d4	a3a45b01-9ac2-4382-9551-68f1762d33c2	MECHANIC_VERIFICATION_APPROVED	MechanicProfile	b6caff1d-1517-4114-8d4d-87fd03ac1b0d	{"notes": "E2E Audit Verification: Trade license and ASE certifications verified with state registry.", "newStatus": "APPROVED", "previousStatus": "PENDING", "technicianEmail": "m5.mech2.1795348523391@vbrs.local"}	\N	\N	2026-11-22 12:04:27.883
403088f5-afb2-4010-907c-c23e9fa7deaa	a3a45b01-9ac2-4382-9551-68f1762d33c2	COMPLAINT_STATUS_RESOLVED	Complaint	142084f8-2ad0-42bb-9398-0fd57a7d20c5	{"toStatus": "RESOLVED", "fromStatus": "RESOLVED", "resolutionNotes": "E2E Resolution: Motorist and certified technician mutually agreed on final diagnostic adjustment."}	\N	\N	2026-11-22 12:04:30.479
40f72fd6-9fa9-41a7-b8fa-8f57df1fb47a	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 12:04:36.852
875c24be-1dc5-4921-9cd9-92cfa9b53aa3	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	9cd03908-707c-4205-94b7-73f44fa0c574	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 12:04:38.698
ddcbf0ca-f04b-429d-b5e9-9ade92a82616	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 12:04:40.045
9274a5a6-a22d-48dc-8663-8e1bff7c3940	473401ce-0803-422f-8baa-a47de557f84e	DISPATCH_ACCEPTED	ServiceRequest	509d0dc3-a2fa-46ad-b58c-2af009fdab06	{"mechanicId": "6a01cdea-a7ee-43e1-8a1f-77ecba9b0890", "breakdownReportId": "9cd03908-707c-4205-94b7-73f44fa0c574"}	\N	\N	2026-11-22 12:04:43.474
9385d815-d178-4f0d-8fcb-623966c42b64	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_EN_ROUTE	ServiceRequest	509d0dc3-a2fa-46ad-b58c-2af009fdab06	{"notes": "Technician departed base en route to incident site.", "toStatus": "EN_ROUTE", "fromStatus": "ACCEPTED"}	\N	\N	2026-11-22 12:04:43.567
c9efb475-9770-4b60-aac2-6575f5a628f6	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_ARRIVED	ServiceRequest	509d0dc3-a2fa-46ad-b58c-2af009fdab06	{"notes": "Technician arrived on scene at incident coordinates.", "toStatus": "ARRIVED", "fromStatus": "EN_ROUTE"}	\N	\N	2026-11-22 12:04:43.683
4665ccc8-9ce3-4cc0-b963-6380643c2b82	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_IN_PROGRESS	ServiceRequest	509d0dc3-a2fa-46ad-b58c-2af009fdab06	{"notes": "Beginning diagnostic disassembly and component servicing.", "toStatus": "IN_PROGRESS", "fromStatus": "ARRIVED"}	\N	\N	2026-11-22 12:04:45.374
66fd1289-6fe7-4c5f-9eb3-1355f03085af	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_COMPLETED	ServiceRequest	509d0dc3-a2fa-46ad-b58c-2af009fdab06	{"notes": "Service finished successfully.", "toStatus": "COMPLETED", "fromStatus": "IN_PROGRESS"}	\N	\N	2026-11-22 12:04:45.489
b0399833-fab8-4120-8ae7-4e6af80bf55c	e22478b0-00a4-44f8-b146-3649213c7a20	CUSTOMER_REVIEW_SUBMITTED	Review	dda6921d-03ff-4741-bc74-83c8c19bf818	{"rating": 5, "mechanicId": "6a01cdea-a7ee-43e1-8a1f-77ecba9b0890", "totalReviews": 2, "ratingAverage": 5, "serviceRequestId": "509d0dc3-a2fa-46ad-b58c-2af009fdab06"}	\N	\N	2026-11-22 12:04:46.58
159d41d1-b6e3-45fc-8727-a5ea2891b487	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 12:04:47.891
ad2b6188-1955-47b4-9136-b7b24bd2d451	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 12:04:49.968
66fb184a-e85e-4b05-8c91-c05c641be7cc	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 12:04:59.585
bd7c94c3-2c38-44f6-866e-d6c3d62a859e	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 12:05:09.179
22c17a3b-15ed-446e-832b-8c56db1591a4	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 12:05:18.896
1eddee73-49cf-4d82-99e3-b71fb6c59920	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 12:09:39.652
f9eff299-080d-4a6a-86cc-e16c8d323704	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 12:10:56.123
32f65fcf-0f32-4562-8b71-038fbc7e4b83	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_CANCELLED	ServiceRequest	e10cd90e-038b-4282-a97a-20bd7447dec4	{"notes": "Cancellation reason: far", "toStatus": "CANCELLED", "fromStatus": "ACCEPTED", "cancellationReason": "far"}	\N	\N	2026-11-22 12:12:16.568
83c820f5-d7e1-4f87-b84f-487dab5d6e1e	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_OUT	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 12:12:34.726
f0ad2461-0265-4718-b135-e100dfc2852e	a1479806-db8e-432b-a61a-04b1494faf85	USER_LOGGED_IN	User	a1479806-db8e-432b-a61a-04b1494faf85	\N	\N	\N	2026-11-22 12:12:37.606
f02ad351-6848-4a50-9e13-540c9e4cca88	a1479806-db8e-432b-a61a-04b1494faf85	BREAKDOWN_REPORT_CREATED	BreakdownReport	3a38191a-aba1-4735-9a13-ed6afac739cb	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 1, "requiresTowing": false}	\N	\N	2026-11-22 12:13:07.308
66290c05-3174-4073-b05f-646c1fc53296	473401ce-0803-422f-8baa-a47de557f84e	DISPATCH_ACCEPTED	ServiceRequest	6c736916-d02f-4279-8270-49f6f054f32f	{"mechanicId": "6a01cdea-a7ee-43e1-8a1f-77ecba9b0890", "breakdownReportId": "3a38191a-aba1-4735-9a13-ed6afac739cb"}	\N	\N	2026-11-22 12:13:42.674
85aa07e9-781b-4333-b9de-f7a72aabce08	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_EN_ROUTE	ServiceRequest	6c736916-d02f-4279-8270-49f6f054f32f	{"notes": "Technician departed base en route to incident site.", "toStatus": "EN_ROUTE", "fromStatus": "ACCEPTED"}	\N	\N	2026-11-22 12:14:07.174
2ca11e97-5848-46dd-9d8a-f599fcc1a543	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_ARRIVED	ServiceRequest	6c736916-d02f-4279-8270-49f6f054f32f	{"notes": "Technician arrived on scene at incident coordinates.", "toStatus": "ARRIVED", "fromStatus": "EN_ROUTE"}	\N	\N	2026-11-22 12:14:21.352
9685bbc8-f1ba-4b56-954d-71e3f8f04a32	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_IN_PROGRESS	ServiceRequest	6c736916-d02f-4279-8270-49f6f054f32f	{"notes": "Beginning diagnostic disassembly and component servicing.", "toStatus": "IN_PROGRESS", "fromStatus": "ARRIVED"}	\N	\N	2026-11-22 12:14:22.934
ce1f7104-0707-4caa-9786-7d0cb3b07261	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_COMPLETED	ServiceRequest	6c736916-d02f-4279-8270-49f6f054f32f	{"notes": "Service finished successfully.", "toStatus": "COMPLETED", "fromStatus": "IN_PROGRESS"}	\N	\N	2026-11-22 12:14:31.486
f741793c-a93a-4b1a-b200-164ea48a8436	a1479806-db8e-432b-a61a-04b1494faf85	CUSTOMER_REVIEW_SUBMITTED	Review	fbf448af-d3bf-478f-8823-0a9687ce4875	{"rating": 5, "mechanicId": "6a01cdea-a7ee-43e1-8a1f-77ecba9b0890", "totalReviews": 3, "ratingAverage": 5, "serviceRequestId": "6c736916-d02f-4279-8270-49f6f054f32f"}	\N	\N	2026-11-22 12:14:40.997
d65cc8a4-5e81-4aac-95fd-f3431d75ff81	a1479806-db8e-432b-a61a-04b1494faf85	BREAKDOWN_REPORT_CREATED	BreakdownReport	1e25ba21-ffad-4310-aeae-5963f9323c16	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 12:16:00.005
4bfc32c5-a3bc-4dc2-a48f-649ebc549381	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 13:42:04.447
8b89161c-4121-43ea-b0b4-14b0129bb359	a1479806-db8e-432b-a61a-04b1494faf85	SERVICE_STATUS_CANCELLED	ServiceRequest	c558ad89-ed30-48c7-bae9-45578a8f3638	{"notes": "Cancellation reason: it solved", "toStatus": "CANCELLED", "fromStatus": "SUBMITTED", "cancellationReason": "it solved"}	\N	\N	2026-11-22 12:16:22.334
d968f9ef-88de-47e6-a363-32d1295f2492	473401ce-0803-422f-8baa-a47de557f84e	SERVICE_STATUS_CANCELLED	ServiceRequest	84f3f21a-d1eb-49dc-99b0-98e662f808b0	{"notes": "Cancellation reason: dafasf", "toStatus": "CANCELLED", "fromStatus": "ACCEPTED", "cancellationReason": "dafasf"}	\N	\N	2026-11-22 12:16:48.859
afd018cd-2d4b-4941-9d75-73bb89523667	a1479806-db8e-432b-a61a-04b1494faf85	BREAKDOWN_REPORT_CREATED	BreakdownReport	f05ff4a3-34c7-45dc-8533-9bc02a7e1195	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 12:17:08.912
3fbfc900-17fe-4273-9c55-a569f728a70f	473401ce-0803-422f-8baa-a47de557f84e	DISPATCH_ACCEPTED	ServiceRequest	40f85150-f5c1-4abf-97ad-9dc2b347074a	{"mechanicId": "6a01cdea-a7ee-43e1-8a1f-77ecba9b0890", "breakdownReportId": "f05ff4a3-34c7-45dc-8533-9bc02a7e1195"}	\N	\N	2026-11-22 12:17:26.223
4f01b19f-e1f6-483a-9392-c2b2be7075a5	a1479806-db8e-432b-a61a-04b1494faf85	SERVICE_STATUS_CANCELLED	ServiceRequest	40f85150-f5c1-4abf-97ad-9dc2b347074a	{"notes": "Cancellation reason: mabchjkakujgfa", "toStatus": "CANCELLED", "fromStatus": "ACCEPTED", "cancellationReason": "mabchjkakujgfa"}	\N	\N	2026-11-22 12:17:32.246
68157d61-aaa4-46b5-ba13-d1a16e269fa0	b058b251-3038-4f94-837d-98d390b907c9	USER_REGISTERED	User	b058b251-3038-4f94-837d-98d390b907c9	{"role": "CUSTOMER", "email": "m2.customer.1795352168743@vbrs.local"}	\N	\N	2026-11-22 12:56:09.12
3d60512b-a13c-4ac4-8ae3-6e737a67c920	b058b251-3038-4f94-837d-98d390b907c9	USER_LOGGED_IN	User	b058b251-3038-4f94-837d-98d390b907c9	\N	\N	\N	2026-11-22 12:56:09.386
fbd1000c-0c01-4a76-bd36-ebe247420d56	b058b251-3038-4f94-837d-98d390b907c9	VEHICLE_ADDED	Vehicle	51e48638-bb0f-40b5-bd66-b7e4ab199a8b	{"make": "Ford", "model": "Mustang Mach-E", "plate": "M2-9649"}	\N	\N	2026-11-22 12:56:09.668
e879e04b-5908-4ecb-8e6c-739a0e72d72c	b058b251-3038-4f94-837d-98d390b907c9	VEHICLE_UPDATED	Vehicle	51e48638-bb0f-40b5-bd66-b7e4ab199a8b	\N	\N	\N	2026-11-22 12:56:09.704
993be072-0680-4b0c-81ad-d5f7139b5912	b058b251-3038-4f94-837d-98d390b907c9	VEHICLE_DELETED	Vehicle	51e48638-bb0f-40b5-bd66-b7e4ab199a8b	{"plate": "M2-9649"}	\N	\N	2026-11-22 12:56:09.729
5df66904-989b-47af-b115-0c54cdd5eefd	b058b251-3038-4f94-837d-98d390b907c9	USER_LOGGED_OUT	User	b058b251-3038-4f94-837d-98d390b907c9	\N	\N	\N	2026-11-22 12:56:09.744
1bc847d8-c6d9-4594-bbd0-4491bfe7722a	40e6fef7-48b0-4b4f-b5d1-643f8c4665d7	USER_REGISTERED	User	40e6fef7-48b0-4b4f-b5d1-643f8c4665d7	{"role": "CUSTOMER", "email": "audit.customer.1795352182033@vbrs.local"}	\N	\N	2026-11-22 12:56:22.399
c505e9e5-2e92-4b39-8214-27cf2c1a8f18	6a574d53-ad46-4c43-b3d2-054578f0fbbe	USER_REGISTERED	User	6a574d53-ad46-4c43-b3d2-054578f0fbbe	{"role": "MECHANIC", "email": "audit.mechanic.1795352182033@vbrs.local"}	\N	\N	2026-11-22 12:56:22.652
631bf679-22e2-4bd2-82c0-6fb62170939d	40e6fef7-48b0-4b4f-b5d1-643f8c4665d7	USER_LOGGED_IN	User	40e6fef7-48b0-4b4f-b5d1-643f8c4665d7	\N	\N	\N	2026-11-22 12:56:22.895
c9f84c1a-b8a8-4e58-b5a5-49854f449703	6a574d53-ad46-4c43-b3d2-054578f0fbbe	USER_LOGGED_IN	User	6a574d53-ad46-4c43-b3d2-054578f0fbbe	\N	\N	\N	2026-11-22 12:56:23.128
4ab53606-5ba6-4e20-80a7-ab18c7d8a3ec	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 12:56:23.362
8f09f769-0f73-416a-8cc7-59ce75837e80	793e166b-ae9f-4eba-bdf4-3915924ac842	USER_REGISTERED	User	793e166b-ae9f-4eba-bdf4-3915924ac842	{"role": "CUSTOMER", "email": "audit.userb.1795352182033@vbrs.local"}	\N	\N	2026-11-22 12:56:23.837
64fb3d78-384b-4e4c-aa13-8c0758380d22	40e6fef7-48b0-4b4f-b5d1-643f8c4665d7	VEHICLE_ADDED	Vehicle	57424f82-0611-4f83-ba22-9b4ec36d4408	{"make": "Porsche", "model": "Taycan GTS", "plate": "AUD-2034"}	\N	\N	2026-11-22 12:56:24.349
a4e135cd-76b2-4c98-882d-b5fe3f99d1e3	40e6fef7-48b0-4b4f-b5d1-643f8c4665d7	VEHICLE_UPDATED	Vehicle	57424f82-0611-4f83-ba22-9b4ec36d4408	\N	\N	\N	2026-11-22 12:56:24.371
24223241-703a-4c66-826c-3d697eb8b1a7	40e6fef7-48b0-4b4f-b5d1-643f8c4665d7	VEHICLE_DELETED	Vehicle	57424f82-0611-4f83-ba22-9b4ec36d4408	{"plate": "AUD-2034"}	\N	\N	2026-11-22 12:56:24.398
e8719b8b-5381-4791-9bb0-24be04cb6163	\N	USER_LOGGED_IN	User	47cf0a3c-6944-4252-b73f-679d81f835f0	\N	\N	\N	2026-11-22 13:03:42.675
da316169-11cc-4036-bed6-448a803dd7a9	\N	USER_LOGGED_IN	User	a3a7f623-2142-4bff-9756-f818c1e4ab41	\N	\N	\N	2026-11-22 13:03:42.749
772c29ce-af4c-4917-9546-b656e45214de	\N	USER_LOGGED_IN	User	e7497b02-b4de-4512-bf18-a19014906195	\N	\N	\N	2026-11-22 13:03:42.818
3aee4071-a024-4277-bbc5-3bc52b47cba0	\N	MECHANIC_LICENSE_UPDATED_PENDING_AUDIT	MechanicProfile	a49eadba-4afb-4d2e-ae4b-94d353388346	{"newStatus": "PENDING", "newLicense": "ASE-NEW-LICENSE-999", "previousStatus": "APPROVED", "previousLicense": "ASE-KOENIG-01"}	\N	\N	2026-11-22 13:03:42.939
415f50d6-267e-4ca6-b141-bfb69bf5a047	f34fa6c9-f73a-42c4-9160-85d695a71a2b	USER_REGISTERED	User	f34fa6c9-f73a-42c4-9160-85d695a71a2b	{"role": "CUSTOMER", "email": "m5.cust1.1795352676131@vbrs.local"}	\N	\N	2026-11-22 13:04:36.504
d801dd1a-47dc-4a83-a811-e96e3d040140	4ffc6d3f-77f9-48e0-bbaa-e37af292b892	USER_REGISTERED	User	4ffc6d3f-77f9-48e0-bbaa-e37af292b892	{"role": "CUSTOMER", "email": "m2.customer.1795352676132@vbrs.local"}	\N	\N	2026-11-22 13:04:36.516
58206426-7070-411b-8586-ee58c95aaf3c	7728fd21-9b94-481c-b739-87c80836528a	USER_REGISTERED	User	7728fd21-9b94-481c-b739-87c80836528a	{"role": "CUSTOMER", "email": "m4.customer.1795352676147@vbrs.local"}	\N	\N	2026-11-22 13:04:36.539
345e5216-47a1-4fbc-899b-423c942131f6	8b8e01b0-ced8-44e7-8ac3-11a5129be596	USER_REGISTERED	User	8b8e01b0-ced8-44e7-8ac3-11a5129be596	{"role": "CUSTOMER", "email": "m5.cust2.1795352676131@vbrs.local"}	\N	\N	2026-11-22 13:04:36.75
fd5730fa-b6f5-4c85-831e-68de3a7ee411	4ffc6d3f-77f9-48e0-bbaa-e37af292b892	USER_LOGGED_IN	User	4ffc6d3f-77f9-48e0-bbaa-e37af292b892	\N	\N	\N	2026-11-22 13:04:36.779
fb7ce829-e695-474b-9c42-1c843f5436f6	93c9a1ba-11fc-41ef-bc41-0bba5b0a0634	USER_REGISTERED	User	93c9a1ba-11fc-41ef-bc41-0bba5b0a0634	{"role": "MECHANIC", "email": "m4.mech1.1795352676147@vbrs.local"}	\N	\N	2026-11-22 13:04:36.791
33f066a3-22f7-4726-b469-1afcb89b1864	fc725f56-3a5d-4cfb-ae3a-285db185f44e	USER_REGISTERED	User	fc725f56-3a5d-4cfb-ae3a-285db185f44e	{"role": "MECHANIC", "email": "m5.mech1.1795352676131@vbrs.local"}	\N	\N	2026-11-22 13:04:36.99
70f3cf59-6de2-4ef7-a38a-99dc432d02b7	3b2178a5-100c-422e-96c5-992e3283239f	USER_REGISTERED	User	3b2178a5-100c-422e-96c5-992e3283239f	{"role": "MECHANIC", "email": "m4.mech2.1795352676147@vbrs.local"}	\N	\N	2026-11-22 13:04:37.04
1a3d8841-6b32-4077-a5df-3bd3e0f93fd9	7728fd21-9b94-481c-b739-87c80836528a	BREAKDOWN_REPORT_CREATED	BreakdownReport	fd037608-4158-4dd2-81b1-0fc7cb9e1b0b	{"category": "FLAT_TIRE_WHEEL", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 13:04:37.078
d5694894-d574-446d-bf5c-5cabe4263c1b	93c9a1ba-11fc-41ef-bc41-0bba5b0a0634	DISPATCH_ACCEPTED	ServiceRequest	53a38438-b162-488a-8f21-ed21401c44f5	{"mechanicId": "1289d317-4894-4f30-b510-b726e68fd866", "breakdownReportId": "fd037608-4158-4dd2-81b1-0fc7cb9e1b0b"}	\N	\N	2026-11-22 13:04:37.304
bf944566-6713-44f7-a61b-fc7018c6fa8a	4ffc6d3f-77f9-48e0-bbaa-e37af292b892	VEHICLE_ADDED	Vehicle	6c3f08b8-b9f0-4ca3-a68e-06f3d677a6c3	{"make": "Ford", "model": "Mustang Mach-E", "plate": "M2-7053"}	\N	\N	2026-11-22 13:04:37.069
a09e750f-662e-4f78-a725-475f8c503383	4ffc6d3f-77f9-48e0-bbaa-e37af292b892	VEHICLE_UPDATED	Vehicle	6c3f08b8-b9f0-4ca3-a68e-06f3d677a6c3	\N	\N	\N	2026-11-22 13:04:37.107
4e6466b2-8228-4834-973f-801ce0c27051	4ffc6d3f-77f9-48e0-bbaa-e37af292b892	VEHICLE_DELETED	Vehicle	6c3f08b8-b9f0-4ca3-a68e-06f3d677a6c3	{"plate": "M2-7053"}	\N	\N	2026-11-22 13:04:37.132
535f7b16-ad03-44f6-b1d8-ab7b2bf9efb6	4ffc6d3f-77f9-48e0-bbaa-e37af292b892	USER_LOGGED_OUT	User	4ffc6d3f-77f9-48e0-bbaa-e37af292b892	\N	\N	\N	2026-11-22 13:04:37.15
0a372a82-8198-4aff-a859-d78deae19d54	38d387dd-e06f-4ea0-9155-587eb1ec7a7c	USER_REGISTERED	User	38d387dd-e06f-4ea0-9155-587eb1ec7a7c	{"role": "MECHANIC", "email": "m5.mech2.1795352676131@vbrs.local"}	\N	\N	2026-11-22 13:04:37.239
9fb67d87-28e2-45cd-8dd3-49cddd5881e0	e1f9196b-4bee-442b-903b-bf6bd88250e7	USER_REGISTERED	User	e1f9196b-4bee-442b-903b-bf6bd88250e7	{"role": "ADMIN", "email": "m5.admin.1795352676131@vbrs.local"}	\N	\N	2026-11-22 13:04:37.474
8ef8f0b4-134b-4eec-9347-898c704c8195	f34fa6c9-f73a-42c4-9160-85d695a71a2b	BREAKDOWN_REPORT_CREATED	BreakdownReport	b8024a20-a82d-4a25-958f-db501f08dd0d	{"category": "ENGINE_FAILURE", "severity": "CRITICAL", "imageCount": 0, "requiresTowing": true}	\N	\N	2026-11-22 13:04:37.504
e6293565-aa39-4f0b-8a57-5aee302d3688	fc725f56-3a5d-4cfb-ae3a-285db185f44e	DISPATCH_ACCEPTED	ServiceRequest	eba2b49f-8548-4d4a-b849-0157c18a0700	{"mechanicId": "25b004b4-75c9-445e-b00e-381f6924e7fc", "breakdownReportId": "b8024a20-a82d-4a25-958f-db501f08dd0d"}	\N	\N	2026-11-22 13:04:37.535
f3e4be62-f5b1-4fb8-aeba-eabf9159a45e	fc725f56-3a5d-4cfb-ae3a-285db185f44e	SERVICE_STATUS_EN_ROUTE	ServiceRequest	eba2b49f-8548-4d4a-b849-0157c18a0700	{"notes": "Technician departed garage; en route via arterial highway.", "toStatus": "EN_ROUTE", "fromStatus": "ACCEPTED"}	\N	\N	2026-11-22 13:04:37.649
d490f2b8-c684-44f4-aea4-27a65dd0cb3b	fc725f56-3a5d-4cfb-ae3a-285db185f44e	SERVICE_STATUS_ARRIVED	ServiceRequest	eba2b49f-8548-4d4a-b849-0157c18a0700	{"notes": "Arrived at incident site; positioning emergency safety cones.", "toStatus": "ARRIVED", "fromStatus": "EN_ROUTE"}	\N	\N	2026-11-22 13:04:37.674
0dc52863-3406-4557-a9b4-4bccca1389d0	fc725f56-3a5d-4cfb-ae3a-285db185f44e	SERVICE_STATUS_IN_PROGRESS	ServiceRequest	eba2b49f-8548-4d4a-b849-0157c18a0700	{"notes": "Disassembled ignition harness; installing new OEM coils.", "toStatus": "IN_PROGRESS", "fromStatus": "ARRIVED"}	\N	\N	2026-11-22 13:04:37.774
2c6ab369-664e-48af-8735-e3dda6563312	fc725f56-3a5d-4cfb-ae3a-285db185f44e	SERVICE_STATUS_COMPLETED	ServiceRequest	eba2b49f-8548-4d4a-b849-0157c18a0700	{"toStatus": "COMPLETED", "fromStatus": "IN_PROGRESS"}	\N	\N	2026-11-22 13:04:37.801
133a084f-c721-4dd8-b145-3e9fe3ddd0fb	f34fa6c9-f73a-42c4-9160-85d695a71a2b	BREAKDOWN_REPORT_CREATED	BreakdownReport	39cc810c-2b79-4754-81a5-33245e48a631	{"category": "FLAT_TIRE_WHEEL", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 13:04:37.849
24374548-06a8-43ea-a458-dc62aa7dab76	fc725f56-3a5d-4cfb-ae3a-285db185f44e	DISPATCH_ACCEPTED	ServiceRequest	344a61f0-a1c8-4e1c-ad05-ea8a7b093321	{"mechanicId": "25b004b4-75c9-445e-b00e-381f6924e7fc", "breakdownReportId": "39cc810c-2b79-4754-81a5-33245e48a631"}	\N	\N	2026-11-22 13:04:37.869
c65a06db-5123-450e-8539-b148c8ad120d	f34fa6c9-f73a-42c4-9160-85d695a71a2b	SERVICE_STATUS_CANCELLED	ServiceRequest	344a61f0-a1c8-4e1c-ad05-ea8a7b093321	{"notes": "Cancellation reason: Spare tire located; vehicle changed independently.", "toStatus": "CANCELLED", "fromStatus": "ACCEPTED", "cancellationReason": "Spare tire located; vehicle changed independently."}	\N	\N	2026-11-22 13:04:37.887
15a4f6a5-0338-4757-8e58-8196382d429a	a1479806-db8e-432b-a61a-04b1494faf85	USER_LOGGED_OUT	User	a1479806-db8e-432b-a61a-04b1494faf85	\N	\N	\N	2026-11-22 13:05:33.889
c86f8c79-d604-4924-a6b0-212a7ac46fd2	a1479806-db8e-432b-a61a-04b1494faf85	USER_LOGGED_IN	User	a1479806-db8e-432b-a61a-04b1494faf85	\N	\N	\N	2026-11-22 13:05:37.891
93c96b13-9ec6-4a1a-ad39-0f1634255628	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 13:13:49.34
efe538be-9e4b-4c65-b993-efea53f59db6	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 13:15:09.044
399bc914-a7aa-48d4-ae3c-ce02771863ad	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 13:15:47.807
3d87c5c1-d8c6-454f-888e-22d2c526a287	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 13:16:47.257
9081e9d6-10cd-45a0-949d-c461e4d2b439	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 13:17:43.456
ecb339e0-7d86-4c4e-9254-1269b5f0777a	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 13:18:45.383
84eb463e-6691-4ce5-87d5-2ac388973747	\N	USER_LOGGED_IN	User	96c6169c-117e-46d9-9e9f-ffde0e6c757f	\N	\N	\N	2026-11-22 13:19:13.154
edc7d637-8f99-4140-a6ab-fbe968df3ef1	\N	USER_LOGGED_IN	User	17431fbd-eb76-4e16-afe7-818be3e9704f	\N	\N	\N	2026-11-22 13:19:13.227
6285e621-2181-4058-8993-ca942888f228	\N	USER_LOGGED_IN	User	3e060ab9-bf3d-4b75-9339-2b416d5c934b	\N	\N	\N	2026-11-22 13:19:13.295
30c07d2c-35fb-4ec1-80e3-55c459af34ce	\N	MECHANIC_LICENSE_UPDATED_PENDING_AUDIT	MechanicProfile	f3e81ec1-d62e-4bda-9d0e-bced84b59f01	{"newStatus": "PENDING", "newLicense": "ASE-NEW-LICENSE-999", "previousStatus": "APPROVED", "previousLicense": "ASE-KOENIG-01"}	\N	\N	2026-11-22 13:19:13.395
1793b47e-006c-4dd2-8dc8-17ae0db8a22f	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 13:19:15.803
c2f458fb-385a-48ec-8811-241c4ecd3a5e	e22478b0-00a4-44f8-b146-3649213c7a20	BREAKDOWN_REPORT_CREATED	BreakdownReport	46a295dd-9804-4bb2-89df-48c6eb40c4c8	{"category": "TRANSMISSION_ISSUE", "severity": "CRITICAL", "imageCount": 1, "requiresTowing": true}	\N	\N	2026-11-22 13:19:19.432
9509101a-9849-4fa3-b79f-11e917fcfa06	a1479806-db8e-432b-a61a-04b1494faf85	USER_LOGGED_OUT	User	a1479806-db8e-432b-a61a-04b1494faf85	\N	\N	\N	2026-11-22 13:27:29.379
b97939ce-f423-4ede-a86a-2b6becb73a72	a1479806-db8e-432b-a61a-04b1494faf85	USER_LOGGED_IN	User	a1479806-db8e-432b-a61a-04b1494faf85	\N	\N	\N	2026-11-22 13:27:53.295
cd78f648-9e05-4152-a9c2-6cfcafbbd1cb	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_OUT	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 13:31:51.952
56fa9ac8-66f5-408a-984e-f4e6163a017b	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 13:31:55.382
eeda2e2d-f2ba-499c-a767-e58f678d112b	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 13:32:13.254
d58c99e2-bd93-472f-91cb-c0813923136e	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 13:39:39.175
5a7168b2-0e72-44aa-9fe2-3a5b3198321e	473401ce-0803-422f-8baa-a47de557f84e	MECHANIC_LICENSE_UPDATED_PENDING_AUDIT	MechanicProfile	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	{"newStatus": "PENDING", "newLicense": "LIC-AUDIT-1795354934235", "previousStatus": "APPROVED", "previousLicense": "ASE-MASTER-99482"}	\N	\N	2026-11-22 13:42:14.269
b8ce4b26-a8ce-473c-aba1-a43ba0d89637	\N	USER_LOGGED_IN	User	39b33c50-26ad-47a0-bfd5-417e43cbbacc	\N	\N	\N	2026-11-22 13:42:41.123
15978e16-5888-419b-9a86-c20c484a792f	\N	USER_LOGGED_IN	User	39aff644-e2ed-462f-926e-319d0e924467	\N	\N	\N	2026-11-22 13:42:41.196
aa46f27b-0f92-460d-9356-051b25c8469f	\N	USER_LOGGED_IN	User	d261b3d1-0c6b-4d9b-8340-5d32c57d2386	\N	\N	\N	2026-11-22 13:42:41.264
dbf2ed96-e2b2-42c6-868a-f0a7e935f983	\N	MECHANIC_LICENSE_UPDATED_PENDING_AUDIT	MechanicProfile	351ad3e6-9674-41e8-a97e-0e924c1a80b4	{"newStatus": "PENDING", "newLicense": "ASE-NEW-LICENSE-999", "previousStatus": "APPROVED", "previousLicense": "ASE-KOENIG-01"}	\N	\N	2026-11-22 13:42:41.368
9c7567b2-55be-407e-b2b5-63fc391439ee	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 13:42:43.741
6cb6579d-e84a-4def-a2be-2431ab38b102	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 13:54:55.663
3b2d8855-9594-47c8-a959-afd72f49fd42	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 13:56:53.33
5c2e9399-7740-4928-9592-dadca0524122	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 13:57:21.965
62a99a50-475c-47a3-8e86-2b886527d523	473401ce-0803-422f-8baa-a47de557f84e	MECHANIC_LICENSE_UPDATED_PENDING_AUDIT	MechanicProfile	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	{"newStatus": "PENDING", "newLicense": "LIC-AUDIT-1795355852257", "previousStatus": "PENDING", "previousLicense": "LIC-AUDIT-1795354934235"}	\N	\N	2026-11-22 13:57:32.287
62a6b7a1-ca3a-4a9a-81db-f1397a660939	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 13:57:49.771
ba370361-b74b-4d47-9254-42c9f04d3fea	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 14:11:57.919
6915f009-ab03-404e-874e-5df8071a27a6	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 14:12:23.801
b62a1226-b9a9-404b-8dfc-d285f724e5bb	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 14:12:38.211
6b3d4bfe-ef12-4d9f-9a09-8a82e0d2645f	473401ce-0803-422f-8baa-a47de557f84e	MECHANIC_LICENSE_UPDATED_PENDING_AUDIT	MechanicProfile	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	{"newStatus": "PENDING", "newLicense": "LIC-AUDIT-1795356768507", "previousStatus": "PENDING", "previousLicense": "LIC-AUDIT-1795355852257"}	\N	\N	2026-11-22 14:12:48.54
1e2c516f-9a1a-449d-a977-29e5138845b5	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 14:12:54.203
6774e499-eee2-4c25-9ac6-8530e21516d6	\N	USER_LOGGED_IN	User	d689520c-6e51-43a6-a66f-1425d9d3dfb1	\N	\N	\N	2026-11-22 14:13:20.533
45f11edd-7906-4bc1-b514-3f97bdfa85a8	\N	USER_LOGGED_IN	User	ddff4a24-081a-4227-854e-d12ce7598d9f	\N	\N	\N	2026-11-22 14:13:20.607
7e53cafe-66a3-40ea-8de1-abb57a340eeb	\N	USER_LOGGED_IN	User	414af189-6771-4165-a311-c2c689bc83de	\N	\N	\N	2026-11-22 14:13:20.674
1115bcea-8a55-427c-9d7a-1fd3e6b79da7	\N	MECHANIC_LICENSE_UPDATED_PENDING_AUDIT	MechanicProfile	87ef736d-e5b5-4a42-9747-dfcc57669595	{"newStatus": "PENDING", "newLicense": "ASE-NEW-LICENSE-999", "previousStatus": "APPROVED", "previousLicense": "ASE-KOENIG-01"}	\N	\N	2026-11-22 14:13:20.775
456ad794-1824-4f99-80bd-0bb8c695fe29	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 14:53:36.706
49ece9af-aaa4-427d-8886-b4a301ddf681	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 15:00:51.475
8fde19c6-b6ee-4cd6-a2c1-95b49683a3f1	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 15:01:15.876
c77ea032-941b-467f-8bd8-b6042d3da837	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 15:18:22.516
1b1f955d-c906-4ff3-87c1-75a75b9c6e10	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_OUT	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 15:18:33.621
00d7078f-9015-42a5-be5c-e632879c464f	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 15:18:35.95
c93bacd4-580b-4b7b-add3-396c83a96a19	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 15:20:28.579
fff8f9d8-a06b-4d2b-9b62-4ccae1ec1f08	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_OUT	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 15:20:39.698
19fe0eec-e6a6-4788-91e0-b2f8e9efe7ef	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 15:20:42.013
3fdbd273-6dd7-49d4-bd10-be127ed95b1c	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_OUT	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 15:20:58.284
1a5eb159-cc9a-4cab-b877-1586335e7f00	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 15:21:00.594
cedad910-e2d5-4a5a-b25a-b220deff4ac5	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 15:21:26.677
175e3bd5-1b89-42f8-bb03-c3b737452892	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 15:21:44.873
a7642407-71bc-4b2d-b9ef-e9de1539437a	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 15:39:26.844
157b664e-b53f-4fac-ab34-6ae90609f492	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 15:39:32.488
63aed9ea-d48c-412e-adf5-529ef03285fc	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 15:39:38.145
df2a4f60-ff07-4b01-a8d3-20c839602202	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_IN	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 15:40:25.815
528854fe-00a2-45f8-9e05-2189d1e2c6fc	e22478b0-00a4-44f8-b146-3649213c7a20	USER_LOGGED_OUT	User	e22478b0-00a4-44f8-b146-3649213c7a20	\N	\N	\N	2026-11-22 15:40:36.913
7ad174e4-0d2f-4b66-95ac-435da0bd2cc9	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 15:40:39.238
aa6c9ec1-f89f-4bd5-aced-83991440dc89	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_OUT	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 15:40:55.297
2ead4c65-3586-43d0-9291-b6094aeae8fd	a3a45b01-9ac2-4382-9551-68f1762d33c2	USER_LOGGED_IN	User	a3a45b01-9ac2-4382-9551-68f1762d33c2	\N	\N	\N	2026-11-22 15:40:57.604
0e296064-787c-4cc5-9d67-c460861640cc	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 15:41:29.274
0b2b1298-a373-44a6-aca1-c39e129b71f7	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 15:42:30.712
976177f0-71ab-4b5a-b559-9ddfb900fce2	473401ce-0803-422f-8baa-a47de557f84e	USER_LOGGED_IN	User	473401ce-0803-422f-8baa-a47de557f84e	\N	\N	\N	2026-11-22 15:42:42.655
09d8bf73-880e-4dee-aff6-acb0e040063f	a1479806-db8e-432b-a61a-04b1494faf85	BREAKDOWN_REPORT_CREATED	BreakdownReport	04a25238-d813-492c-8e98-59baff62cdba	{"category": "ENGINE_FAILURE", "severity": "MEDIUM", "imageCount": 0, "requiresTowing": false}	\N	\N	2026-11-22 15:46:06.612
2662de58-7fc5-458f-8a64-dd1312c1dcfa	a3a45b01-9ac2-4382-9551-68f1762d33c2	COMPLAINT_STATUS_RESOLVED	Complaint	142084f8-2ad0-42bb-9398-0fd57a7d20c5	{"toStatus": "RESOLVED", "fromStatus": "RESOLVED", "resolutionNotes": "E2E Resolution: Motorist and certified technician mutually agreed on final diagnostic adjustment."}	\N	\N	2026-11-22 15:47:38.823
facfd77e-1480-4582-a173-0d82672b3967	a3a45b01-9ac2-4382-9551-68f1762d33c2	COMPLAINT_STATUS_RESOLVED	Complaint	142084f8-2ad0-42bb-9398-0fd57a7d20c5	{"toStatus": "RESOLVED", "fromStatus": "RESOLVED", "resolutionNotes": "E2E Resolution: Motorist and certified technician mutually agreed on final diagnostic adjustment."}	\N	\N	2026-11-22 15:47:44.637
c5ed357c-bf31-4625-b3d6-148f9c08cef3	a3a45b01-9ac2-4382-9551-68f1762d33c2	MECHANIC_VERIFICATION_APPROVED	MechanicProfile	d4d7570a-71a9-49fd-acf8-21fda3d7f48e	{"newStatus": "APPROVED", "previousStatus": "PENDING", "technicianEmail": "m5.mech2.1795352676131@vbrs.local"}	\N	\N	2026-11-22 15:49:39.149
bff185fc-fa9a-4ad3-8ff5-23b2adf1b4ae	a3a45b01-9ac2-4382-9551-68f1762d33c2	MECHANIC_VERIFICATION_REJECTED	MechanicProfile	c64cf11c-7971-413a-bcc2-b4496909ccc1	{"newStatus": "REJECTED", "previousStatus": "PENDING", "technicianEmail": "audit.mechanic.1795352182033@vbrs.local"}	\N	\N	2026-11-22 15:50:42.241
\.


--
-- Data for Name: BreakdownReport; Type: TABLE DATA; Schema: public; Owner: vbrs_admin
--

COPY public."BreakdownReport" (id, "customerId", "vehicleId", category, severity, description, latitude, longitude, "addressText", "ruleDiagnosis", "requiresTowing", "createdAt", "updatedAt") FROM stdin;
0a6ec4bc-6c69-41a4-8c12-16da50b7eed2	50d7979c-85db-4cec-8bb2-83ba29ebae7d	\N	FLAT_TIRE_WHEEL	LOW	Slow puncture in right rear tire. Vehicle safely parked on curb with spare ready.	40.73061	-73.935242	Brooklyn Greenpoint Ave	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 09:21:13.146	2026-11-22 09:21:13.146
96554164-ec44-4988-80f1-01ab3b1c79d1	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	TRANSMISSION_ISSUE	CRITICAL	Sudden transmission shudder followed by gear slip and complete loss of drive on highway shoulder. Heavy fluid leak observed underneath gearbox.	40.710996	-74.001495	Interstate 95 Northbound, Mile Marker 42.5 Shoulder	[DIAGNOSIS PROTOCOL]: Transmission Gearbox / Direct-Drive Lockup\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 09:26:53.35	2026-11-22 09:26:53.35
7a88dee1-d1a2-4e53-94f5-40d9b4416e45	15a87756-ecb4-4394-8fb7-5555263f9a09	\N	FLAT_TIRE_WHEEL	LOW	Slow puncture in right rear tire. Vehicle safely parked on curb with spare ready.	40.73061	-73.935242	Brooklyn Greenpoint Ave	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 09:27:11.284	2026-11-22 09:27:11.284
4b1cbadd-3c17-469f-9e59-9fa9f8caeddf	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	TRANSMISSION_ISSUE	CRITICAL	Sudden transmission shudder followed by gear slip and complete loss of drive on highway shoulder. Heavy fluid leak observed underneath gearbox.	40.710996	-74.001495	Interstate 95 Northbound, Mile Marker 42.5 Shoulder	[DIAGNOSIS PROTOCOL]: Transmission Gearbox / Direct-Drive Lockup\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 09:27:47.817	2026-11-22 09:27:47.817
1a3bbc18-ad93-4373-bb4b-85764d9fdf5f	a1479806-db8e-432b-a61a-04b1494faf85	ace1cb6e-1e74-4c0d-84df-622d529c8a5e	ENGINE_FAILURE	CRITICAL	engine failure	16.354305	80.52969	\N	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 09:34:49.166	2026-11-22 09:34:49.166
f76e9070-3aba-4f3a-9e33-ac94e6faf02a	baf36b48-83b6-4d2a-acaf-1145a539c456	\N	COLLISION_ACCIDENT	CRITICAL	Multiple collision impact angles documented with 5 photographs	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Chassis Structural Impact / Collision Damage\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Emergency scene protocol: Remain behind highway barrier until first responders arrive. | Inspect roadway for combustible fluid spillage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Heavy Flatbed Recovery Unit, Fluid Absorption Spills Kit	t	2026-11-22 09:44:12.092	2026-11-22 09:44:12.092
4a2c7d09-7c83-448d-98a0-23054976798f	baf36b48-83b6-4d2a-acaf-1145a539c456	685d419d-2e68-4907-95d5-1bdec89b7325	BRAKE_SYSTEM_FAILURE	CRITICAL	Brakes completely lost hydraulic pressure on off-ramp	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Hydraulic Brake Line Breach / ABS Caliper Lock\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: CRITICAL SAFETY RISK: Do not attempt to operate vehicle under any circumstances. | Hydraulic brake pressure loss requires immediate workshop bleed and master cylinder triage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Flatbed Winch Carrier, Wheel Chocks	t	2026-11-22 09:44:12.177	2026-11-22 09:44:12.177
ad9b7940-13bd-440f-8757-71e7b294e60b	baf36b48-83b6-4d2a-acaf-1145a539c456	685d419d-2e68-4907-95d5-1bdec89b7325	BATTERY_DEAD_ELECTRICAL	MEDIUM	Auxiliary battery failure requiring jump start on highway	40.748817	-73.985428	Near Empire State Building	[DIAGNOSIS PROTOCOL]: 12V Cranking Battery Drain / Alternator Failure\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Neutral gear lockout override may be required if electronic shifter is unpowered. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Commercial 12V/24V Jump-Pack, Digital Multimeter / Alternator Tester	f	2026-11-22 09:44:12.209	2026-11-22 09:44:12.209
c37150a4-c1a3-4e50-98f6-69c74acc7660	baf36b48-83b6-4d2a-acaf-1145a539c456	\N	TRANSMISSION_ISSUE	CRITICAL	Independent submission 1: Gearbox stuck in 3rd	40.71	-74	\N	[DIAGNOSIS PROTOCOL]: Transmission Gearbox / Direct-Drive Lockup\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 09:44:12.236	2026-11-22 09:44:12.236
32b617aa-ebc7-47e0-af57-bd79e34f9620	baf36b48-83b6-4d2a-acaf-1145a539c456	\N	FUEL_EMPTY_OR_CONTAMINATED	LOW	Independent submission 2: Ran dry on frontage road	40.72	-74.01	\N	[DIAGNOSIS PROTOCOL]: Fuel Starvation / System Contamination\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 09:44:12.279	2026-11-22 09:44:12.279
2089cf9c-dcc4-419d-8c04-6196c3a0c4cd	baf36b48-83b6-4d2a-acaf-1145a539c456	\N	OVERHEATING_COOLANT	MEDIUM	Independent submission 3: Steam escaping radiator	40.73	-74.02	\N	[DIAGNOSIS PROTOCOL]: Coolant System Rupture / Radiator Overpressure\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: SCALDING HAZARD: Engine coolant under extreme pressure. DO NOT open radiator or expansion tank cap. | Turn engine off immediately to prevent cylinder head warpage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Coolant Refill Reservoir, Infrared Thermometer, OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 09:44:12.297	2026-11-22 09:44:12.297
fa67a7ad-7e89-43f7-80fd-99f58a73a552	19b6e30e-7ab8-4db5-87e5-443815e3d455	\N	COLLISION_ACCIDENT	CRITICAL	Multiple collision impact angles documented with 5 photographs	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Chassis Structural Impact / Collision Damage\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Emergency scene protocol: Remain behind highway barrier until first responders arrive. | Inspect roadway for combustible fluid spillage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Heavy Flatbed Recovery Unit, Fluid Absorption Spills Kit	t	2026-11-22 09:45:06.012	2026-11-22 09:45:06.012
3a7e419c-1ce3-4144-b326-0170d6e45376	19b6e30e-7ab8-4db5-87e5-443815e3d455	42b6160d-d5c3-499b-9f7a-54cc3b72dedb	BRAKE_SYSTEM_FAILURE	CRITICAL	Brakes completely lost hydraulic pressure on off-ramp	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Hydraulic Brake Line Breach / ABS Caliper Lock\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: CRITICAL SAFETY RISK: Do not attempt to operate vehicle under any circumstances. | Hydraulic brake pressure loss requires immediate workshop bleed and master cylinder triage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Flatbed Winch Carrier, Wheel Chocks	t	2026-11-22 09:45:06.1	2026-11-22 09:45:06.1
c44d9de9-e220-471a-a660-f9e9889172e6	19b6e30e-7ab8-4db5-87e5-443815e3d455	42b6160d-d5c3-499b-9f7a-54cc3b72dedb	BATTERY_DEAD_ELECTRICAL	MEDIUM	Auxiliary battery failure requiring jump start on highway	40.748817	-73.985428	Near Empire State Building	[DIAGNOSIS PROTOCOL]: 12V Cranking Battery Drain / Alternator Failure\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Neutral gear lockout override may be required if electronic shifter is unpowered. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Commercial 12V/24V Jump-Pack, Digital Multimeter / Alternator Tester	f	2026-11-22 09:45:06.135	2026-11-22 09:45:06.135
674595de-9258-485b-b45d-77d2ecee5127	19b6e30e-7ab8-4db5-87e5-443815e3d455	\N	TRANSMISSION_ISSUE	CRITICAL	Independent submission 1: Gearbox stuck in 3rd	40.71	-74	\N	[DIAGNOSIS PROTOCOL]: Transmission Gearbox / Direct-Drive Lockup\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 09:45:06.166	2026-11-22 09:45:06.166
0291a50b-a345-4dd0-acf0-3bf5a8db0ee9	19b6e30e-7ab8-4db5-87e5-443815e3d455	\N	FUEL_EMPTY_OR_CONTAMINATED	LOW	Independent submission 2: Ran dry on frontage road	40.72	-74.01	\N	[DIAGNOSIS PROTOCOL]: Fuel Starvation / System Contamination\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 09:45:06.206	2026-11-22 09:45:06.206
5fa41250-ea00-41e9-abd0-04429f937a1d	19b6e30e-7ab8-4db5-87e5-443815e3d455	\N	OVERHEATING_COOLANT	MEDIUM	Independent submission 3: Steam escaping radiator	40.73	-74.02	\N	[DIAGNOSIS PROTOCOL]: Coolant System Rupture / Radiator Overpressure\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: SCALDING HAZARD: Engine coolant under extreme pressure. DO NOT open radiator or expansion tank cap. | Turn engine off immediately to prevent cylinder head warpage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Coolant Refill Reservoir, Infrared Thermometer, OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 09:45:06.225	2026-11-22 09:45:06.225
c2c45bd0-744a-4cfc-8f98-da75dbaa6856	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	Manual coordinate breakdown submission: Brake squeal and spongy pedal on mountain descent.	40.709174	-73.996948	Route 9W Scenic Overlook, Mile Marker 12	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 09:45:23.468	2026-11-22 09:45:23.468
e036aab4-73c2-4e0e-9747-23dc5a2f4c85	436d667c-cc9f-4294-b2c9-cc95e0cb3d7e	\N	FLAT_TIRE_WHEEL	LOW	Slow puncture in right rear tire. Vehicle safely parked on curb with spare ready.	40.73061	-73.935242	Brooklyn Greenpoint Ave	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 09:45:40.8	2026-11-22 09:45:40.8
5a8686f4-daa6-49c0-b823-5a8638ebe9be	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	\N	COLLISION_ACCIDENT	CRITICAL	Multiple collision impact angles documented with 5 photographs	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Chassis Structural Impact / Collision Damage\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Emergency scene protocol: Remain behind highway barrier until first responders arrive. | Inspect roadway for combustible fluid spillage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Heavy Flatbed Recovery Unit, Fluid Absorption Spills Kit	t	2026-11-22 09:45:41.299	2026-11-22 09:45:41.299
587fdbe5-1a1b-428c-b115-56f9e2f8a082	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	3f0353ea-4192-4114-b623-1d63f46b7b14	BRAKE_SYSTEM_FAILURE	CRITICAL	Brakes completely lost hydraulic pressure on off-ramp	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Hydraulic Brake Line Breach / ABS Caliper Lock\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: CRITICAL SAFETY RISK: Do not attempt to operate vehicle under any circumstances. | Hydraulic brake pressure loss requires immediate workshop bleed and master cylinder triage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Flatbed Winch Carrier, Wheel Chocks	t	2026-11-22 09:45:41.383	2026-11-22 09:45:41.383
1908a4f7-7d10-4220-b719-a210724204b4	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	3f0353ea-4192-4114-b623-1d63f46b7b14	BATTERY_DEAD_ELECTRICAL	MEDIUM	Auxiliary battery failure requiring jump start on highway	40.748817	-73.985428	Near Empire State Building	[DIAGNOSIS PROTOCOL]: 12V Cranking Battery Drain / Alternator Failure\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Neutral gear lockout override may be required if electronic shifter is unpowered. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Commercial 12V/24V Jump-Pack, Digital Multimeter / Alternator Tester	f	2026-11-22 09:45:41.418	2026-11-22 09:45:41.418
4ab03dd0-a9f5-4e79-98b3-4836fec17438	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	\N	TRANSMISSION_ISSUE	CRITICAL	Independent submission 1: Gearbox stuck in 3rd	40.71	-74	\N	[DIAGNOSIS PROTOCOL]: Transmission Gearbox / Direct-Drive Lockup\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 09:45:41.447	2026-11-22 09:45:41.447
7c2217e1-09be-41f7-b5bb-34f267cf8522	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	\N	FUEL_EMPTY_OR_CONTAMINATED	LOW	Independent submission 2: Ran dry on frontage road	40.72	-74.01	\N	[DIAGNOSIS PROTOCOL]: Fuel Starvation / System Contamination\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 09:45:41.499	2026-11-22 09:45:41.499
731f9dfc-8b40-4c89-bf73-6c022755f9e8	b347ca38-e44c-42ac-a846-63d4b6c28e3a	\N	TRANSMISSION_ISSUE	CRITICAL	Independent submission 1: Gearbox stuck in 3rd	40.71	-74	\N	[DIAGNOSIS PROTOCOL]: Transmission Gearbox / Direct-Drive Lockup\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 10:42:22.838	2026-11-22 10:42:22.838
8decfb7a-033e-455d-8aa0-e0e1ac809af7	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	\N	OVERHEATING_COOLANT	MEDIUM	Independent submission 3: Steam escaping radiator	40.73	-74.02	\N	[DIAGNOSIS PROTOCOL]: Coolant System Rupture / Radiator Overpressure\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: SCALDING HAZARD: Engine coolant under extreme pressure. DO NOT open radiator or expansion tank cap. | Turn engine off immediately to prevent cylinder head warpage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Coolant Refill Reservoir, Infrared Thermometer, OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 09:45:41.518	2026-11-22 09:45:41.518
a6fcd4c2-f7f3-430e-8150-212f49720f2c	babb78bc-8995-47e3-873b-d77a0c81a425	\N	FLAT_TIRE_WHEEL	MEDIUM	Tire blowout on highway shoulder near exit 14	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 09:59:33.361	2026-11-22 09:59:33.361
f420ce28-fa3d-4497-96fc-b0b0659da2db	2dba2391-5f04-4a66-b103-d008daa1d7cb	\N	FLAT_TIRE_WHEEL	MEDIUM	Tire blowout on highway shoulder near exit 14	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 10:00:36.918	2026-11-22 10:00:36.918
cdd78f8b-6821-4528-a0a0-5b29dab653ad	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	E2E Milestone 4 Test: Engine stalling on FDR Drive shoulder with battery warning.	40.7128	-74.006	FDR Drive Southbound near Houston St	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 10:03:49.835	2026-11-22 10:03:49.835
1f870c2e-ede8-4cd6-9f92-c796f2910793	65531d90-d509-44d8-8c50-189197b32adf	\N	FLAT_TIRE_WHEEL	MEDIUM	Tire blowout on highway shoulder near exit 14	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 10:04:23.105	2026-11-22 10:04:23.105
53f67df2-b542-4764-a1b2-8b758f50f8c7	a9541389-845a-425d-9b38-1de039a56cdc	\N	FLAT_TIRE_WHEEL	LOW	Slow puncture in right rear tire. Vehicle safely parked on curb with spare ready.	40.73061	-73.935242	Brooklyn Greenpoint Ave	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 10:04:24.441	2026-11-22 10:04:24.441
fc8dc4c5-ab5c-473d-bb51-22b9cc8d6dd5	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	\N	COLLISION_ACCIDENT	CRITICAL	Multiple collision impact angles documented with 5 photographs	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Chassis Structural Impact / Collision Damage\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Emergency scene protocol: Remain behind highway barrier until first responders arrive. | Inspect roadway for combustible fluid spillage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Heavy Flatbed Recovery Unit, Fluid Absorption Spills Kit	t	2026-11-22 10:04:24.951	2026-11-22 10:04:24.951
9909c3eb-b894-449e-b6d5-2049b92f7175	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	32c6134f-d4c0-4950-a441-63335b7673b6	BRAKE_SYSTEM_FAILURE	CRITICAL	Brakes completely lost hydraulic pressure on off-ramp	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Hydraulic Brake Line Breach / ABS Caliper Lock\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: CRITICAL SAFETY RISK: Do not attempt to operate vehicle under any circumstances. | Hydraulic brake pressure loss requires immediate workshop bleed and master cylinder triage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Flatbed Winch Carrier, Wheel Chocks	t	2026-11-22 10:04:25.045	2026-11-22 10:04:25.045
a578c4ff-cee0-4946-af65-f559f4b9b6fa	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	32c6134f-d4c0-4950-a441-63335b7673b6	BATTERY_DEAD_ELECTRICAL	MEDIUM	Auxiliary battery failure requiring jump start on highway	40.748817	-73.985428	Near Empire State Building	[DIAGNOSIS PROTOCOL]: 12V Cranking Battery Drain / Alternator Failure\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Neutral gear lockout override may be required if electronic shifter is unpowered. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Commercial 12V/24V Jump-Pack, Digital Multimeter / Alternator Tester	f	2026-11-22 10:04:25.081	2026-11-22 10:04:25.081
46bd39e8-861b-40d8-9cb7-cd6bc6b8e35e	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	\N	TRANSMISSION_ISSUE	CRITICAL	Independent submission 1: Gearbox stuck in 3rd	40.71	-74	\N	[DIAGNOSIS PROTOCOL]: Transmission Gearbox / Direct-Drive Lockup\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 10:04:25.116	2026-11-22 10:04:25.116
a016f173-c441-45c4-9cf4-152f75c6e3d2	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	\N	FUEL_EMPTY_OR_CONTAMINATED	LOW	Independent submission 2: Ran dry on frontage road	40.72	-74.01	\N	[DIAGNOSIS PROTOCOL]: Fuel Starvation / System Contamination\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 10:04:25.165	2026-11-22 10:04:25.165
885504d8-bd8d-4147-a152-c92ce24fc194	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	\N	OVERHEATING_COOLANT	MEDIUM	Independent submission 3: Steam escaping radiator	40.73	-74.02	\N	[DIAGNOSIS PROTOCOL]: Coolant System Rupture / Radiator Overpressure\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: SCALDING HAZARD: Engine coolant under extreme pressure. DO NOT open radiator or expansion tank cap. | Turn engine off immediately to prevent cylinder head warpage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Coolant Refill Reservoir, Infrared Thermometer, OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 10:04:25.188	2026-11-22 10:04:25.188
a4d02411-9a89-44d9-b8e2-6da48e39119d	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	TRANSMISSION_ISSUE	CRITICAL	Sudden transmission shudder followed by gear slip and complete loss of drive on highway shoulder. Heavy fluid leak observed underneath gearbox.	40.710996	-74.001495	Interstate 95 Northbound, Mile Marker 42.5 Shoulder	[DIAGNOSIS PROTOCOL]: Transmission Gearbox / Direct-Drive Lockup\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 10:05:07.168	2026-11-22 10:05:07.168
7982f72d-591b-4a2e-8878-75d20cf69880	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	Manual coordinate breakdown submission: Brake squeal and spongy pedal on mountain descent.	40.709174	-73.996948	Route 9W Scenic Overlook, Mile Marker 12	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 10:05:14.514	2026-11-22 10:05:14.514
82947b09-584a-4553-a16e-7cd456f98066	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	E2E Milestone 4 Test: Engine stalling on FDR Drive shoulder with battery warning.	40.7128	-74.006	FDR Drive Southbound near Houston St	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 10:05:19.364	2026-11-22 10:05:19.364
fdcf9966-eba5-43a9-b670-91bb394d61e6	a1479806-db8e-432b-a61a-04b1494faf85	ace1cb6e-1e74-4c0d-84df-622d529c8a5e	ENGINE_FAILURE	MEDIUM	jbkjb	16.354215	80.529629	\N	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 10:05:52.266	2026-11-22 10:05:52.266
f50dc5a4-d7b1-46eb-8cdd-51a606ded16b	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	E2E Milestone 4 Test: Engine stalling on FDR Drive shoulder with battery warning.	40.7128	-74.006	FDR Drive Southbound near Houston St	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 10:06:25.55	2026-11-22 10:06:25.55
91c3a15d-1bf1-4abf-8431-29f025c4f750	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	TRANSMISSION_ISSUE	CRITICAL	Sudden transmission shudder followed by gear slip and complete loss of drive on highway shoulder. Heavy fluid leak observed underneath gearbox.	40.710996	-74.001495	Interstate 95 Northbound, Mile Marker 42.5 Shoulder	[DIAGNOSIS PROTOCOL]: Transmission Gearbox / Direct-Drive Lockup\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 10:07:10.631	2026-11-22 10:07:10.631
e3e49559-2c2a-4d4e-b8d8-0fb7975bacf1	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	Manual coordinate breakdown submission: Brake squeal and spongy pedal on mountain descent.	40.709174	-73.996948	Route 9W Scenic Overlook, Mile Marker 12	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 10:07:17.826	2026-11-22 10:07:17.826
128efdcf-99ee-4e29-abb9-d7a0ac285072	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	E2E Milestone 4 Test: Engine stalling on FDR Drive shoulder with battery warning.	40.7128	-74.006	FDR Drive Southbound near Houston St	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 10:07:22.439	2026-11-22 10:07:22.439
df37a324-4d01-4d94-a376-1d2a6d82fcc7	a1479806-db8e-432b-a61a-04b1494faf85	ace1cb6e-1e74-4c0d-84df-622d529c8a5e	ENGINE_FAILURE	MEDIUM	jbkkk	16.354188	80.52966	\N	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 10:11:20.731	2026-11-22 10:11:20.731
7556b623-3902-4eff-8a9a-4b3be77aa533	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	Concurrency Race Test 1795342488463: Gearbox locking up on highway	40.7128	-74.006	Broadway & 42nd St Intersection	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 10:14:48.539	2026-11-22 10:14:48.539
caef5174-7257-4164-a0c8-d5ca83b3ad21	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	Rollback Verification Test 1795342581095: Gearbox locking up on highway	40.7128	-74.006	Broadway & 42nd St Intersection	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 10:16:21.16	2026-11-22 10:16:21.16
dda8d6a2-240d-4b27-b15f-54bcc9a5beba	b492f8a7-29a4-4012-a173-bb1cf5135319	\N	FLAT_TIRE_WHEEL	MEDIUM	Flat passenger tire in driveway.	37.775	-122.419	\N	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 10:27:10.612	2026-11-22 10:27:10.612
e672ae2d-233d-4c1f-a871-97933ebc0aeb	9ad0fc29-8daf-4688-925e-9fa71d6a2e80	\N	ENGINE_FAILURE	CRITICAL	Engine shut down completely on highway shoulder with oil warning.	37.7755	-122.418	Highway 101 Northbound Mile 4	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 10:27:35.246	2026-11-22 10:27:35.246
8ff0aadf-81d0-4301-9924-e3a44262c18d	9ad0fc29-8daf-4688-925e-9fa71d6a2e80	\N	FLAT_TIRE_WHEEL	MEDIUM	Flat passenger tire in driveway.	37.775	-122.419	\N	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 10:27:35.602	2026-11-22 10:27:35.602
d54c176b-181b-4a76-b260-9f49db13bc87	201144dc-4d12-4765-8873-8573ebc70566	\N	ENGINE_FAILURE	CRITICAL	Engine shut down completely on highway shoulder with oil warning.	37.7755	-122.418	Highway 101 Northbound Mile 4	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 10:27:50.868	2026-11-22 10:27:50.868
63198c8d-3d23-45b6-bc85-044e2ee375b1	4fb4b922-a2e7-4d24-9e81-1bae59ab792b	\N	FLAT_TIRE_WHEEL	LOW	Slow puncture in right rear tire. Vehicle safely parked on curb with spare ready.	40.73061	-73.935242	Brooklyn Greenpoint Ave	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 10:27:51.049	2026-11-22 10:27:51.049
d2f9d6a5-3800-423d-b90e-84b8d1349581	020de9be-8c9a-4232-a522-39dfbf87cf9c	\N	FLAT_TIRE_WHEEL	MEDIUM	Tire blowout on highway shoulder near exit 14	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 10:27:51.15	2026-11-22 10:27:51.15
79851066-2d2b-4a9f-9dd3-d8bb0c442eb3	201144dc-4d12-4765-8873-8573ebc70566	\N	FLAT_TIRE_WHEEL	MEDIUM	Flat passenger tire in driveway.	37.775	-122.419	\N	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 10:27:51.259	2026-11-22 10:27:51.259
1ba05733-bff4-477d-8dfc-a8841f2f748e	e05d0c61-e1ae-4921-8453-3dc06525dc08	\N	COLLISION_ACCIDENT	CRITICAL	Multiple collision impact angles documented with 5 photographs	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Chassis Structural Impact / Collision Damage\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Emergency scene protocol: Remain behind highway barrier until first responders arrive. | Inspect roadway for combustible fluid spillage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Heavy Flatbed Recovery Unit, Fluid Absorption Spills Kit	t	2026-11-22 10:27:51.366	2026-11-22 10:27:51.366
177e2af1-8d2d-4e15-8535-c0bd9ea873d3	e05d0c61-e1ae-4921-8453-3dc06525dc08	51cd1921-76c9-4b82-9a67-5688ae2d6f31	BRAKE_SYSTEM_FAILURE	CRITICAL	Brakes completely lost hydraulic pressure on off-ramp	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Hydraulic Brake Line Breach / ABS Caliper Lock\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: CRITICAL SAFETY RISK: Do not attempt to operate vehicle under any circumstances. | Hydraulic brake pressure loss requires immediate workshop bleed and master cylinder triage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Flatbed Winch Carrier, Wheel Chocks	t	2026-11-22 10:27:51.431	2026-11-22 10:27:51.431
7a6b871f-550a-4d03-a9cf-71ece348d97a	e05d0c61-e1ae-4921-8453-3dc06525dc08	51cd1921-76c9-4b82-9a67-5688ae2d6f31	BATTERY_DEAD_ELECTRICAL	MEDIUM	Auxiliary battery failure requiring jump start on highway	40.748817	-73.985428	Near Empire State Building	[DIAGNOSIS PROTOCOL]: 12V Cranking Battery Drain / Alternator Failure\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Neutral gear lockout override may be required if electronic shifter is unpowered. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Commercial 12V/24V Jump-Pack, Digital Multimeter / Alternator Tester	f	2026-11-22 10:27:51.458	2026-11-22 10:27:51.458
6f521e4d-97b7-4daf-8fcd-c6d0edc39fa5	e05d0c61-e1ae-4921-8453-3dc06525dc08	\N	TRANSMISSION_ISSUE	CRITICAL	Independent submission 1: Gearbox stuck in 3rd	40.71	-74	\N	[DIAGNOSIS PROTOCOL]: Transmission Gearbox / Direct-Drive Lockup\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 10:27:51.48	2026-11-22 10:27:51.48
194fa08d-3216-4710-ad41-ce79605b6167	e05d0c61-e1ae-4921-8453-3dc06525dc08	\N	FUEL_EMPTY_OR_CONTAMINATED	LOW	Independent submission 2: Ran dry on frontage road	40.72	-74.01	\N	[DIAGNOSIS PROTOCOL]: Fuel Starvation / System Contamination\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 10:27:51.524	2026-11-22 10:27:51.524
45212516-769e-48e1-9d56-9f797caa2695	e05d0c61-e1ae-4921-8453-3dc06525dc08	\N	OVERHEATING_COOLANT	MEDIUM	Independent submission 3: Steam escaping radiator	40.73	-74.02	\N	[DIAGNOSIS PROTOCOL]: Coolant System Rupture / Radiator Overpressure\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: SCALDING HAZARD: Engine coolant under extreme pressure. DO NOT open radiator or expansion tank cap. | Turn engine off immediately to prevent cylinder head warpage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Coolant Refill Reservoir, Infrared Thermometer, OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 10:27:51.539	2026-11-22 10:27:51.539
4f3570aa-66c5-4061-aebb-2dc2b9e84fa8	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	Engine stopped running on freeway shoulder with severe shaking and loss of compression.	37.7749	-122.4194	Interstate 80 Westbound, Mile Marker 12	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 10:35:04.783	2026-11-22 10:35:04.783
827b2ca4-1958-4ee9-a506-7d53e59a37c4	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	Engine stopped running on freeway shoulder with severe shaking and loss of compression.	37.7749	-122.4194	Interstate 80 Westbound, Mile Marker 12	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 10:36:13.026	2026-11-22 10:36:13.026
45a12b7f-7c1d-4f45-88cf-5f1a176b248f	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	Engine stopped running on shoulder. Oil light illuminated. Reference: I-80 Mile 12 Marker #3117	37.7749	-122.4194	I-80 Mile 12 Marker #3117	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 10:37:45.605	2026-11-22 10:37:45.605
4adea7f8-dfaa-41aa-a515-63c4226ce422	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	Rollback Verification Test 1795344001681: Gearbox locking up on highway	40.7128	-74.006	Broadway & 42nd St Intersection	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 10:40:01.755	2026-11-22 10:40:01.755
b41f8148-a8cc-415a-a969-080e2567ec3a	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	Engine stopped running on shoulder. Oil light illuminated. Reference: I-80 Mile 12 Marker #3240	40.7128	-74.006	I-80 Mile 12 Marker #3240	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 10:38:35.645	2026-11-22 10:38:35.645
3060a900-70eb-4d89-b657-6c40840f6826	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	TRANSMISSION_ISSUE	CRITICAL	Sudden transmission shudder followed by gear slip and complete loss of drive on highway shoulder. Heavy fluid leak observed underneath gearbox.	40.710996	-74.001495	Interstate 95 Northbound, Mile Marker 42.5 Shoulder	[DIAGNOSIS PROTOCOL]: Transmission Gearbox / Direct-Drive Lockup\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 10:39:22.558	2026-11-22 10:39:22.558
8f445627-881d-455d-b1c9-a6d74934aa1e	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	Manual coordinate breakdown submission: Brake squeal and spongy pedal on mountain descent.	40.709174	-73.996948	Route 9W Scenic Overlook, Mile Marker 12	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 10:39:29.793	2026-11-22 10:39:29.793
01a454d5-60c7-4f76-952a-c8ceae5c11a5	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	E2E Milestone 4 Test: Engine stalling on FDR Drive shoulder with battery warning.	40.7128	-74.006	FDR Drive Southbound near Houston St	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 10:39:34.262	2026-11-22 10:39:34.262
19fc7b7d-4ead-4e91-90f1-4011beba0cfe	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	E2E Milestone 4 Test: Engine stalling on FDR Drive shoulder with battery warning.	40.7128	-74.006	FDR Drive Southbound near Houston St	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 10:41:06.861	2026-11-22 10:41:06.861
6834daf4-6750-4e88-8fa5-4eefbd06435e	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	Engine stopped running on shoulder. Oil light illuminated. Reference: I-80 Mile 12 Marker #6411	40.7128	-74.006	I-80 Mile 12 Marker #6411	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 10:41:19.061	2026-11-22 10:41:19.061
33b43356-f4a9-42ac-a15c-158e87f1cb36	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	Engine stopped running on shoulder. Oil light illuminated. Reference: I-80 Mile 12 Marker #6178	40.7128	-74.006	I-80 Mile 12 Marker #6178	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 10:41:48.677	2026-11-22 10:41:48.677
99590f73-1eef-4a9e-b6ae-78f5cfb87434	e51a5048-6c2d-466a-ae62-613927b40269	\N	FLAT_TIRE_WHEEL	LOW	Slow puncture in right rear tire. Vehicle safely parked on curb with spare ready.	40.73061	-73.935242	Brooklyn Greenpoint Ave	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 10:42:22.419	2026-11-22 10:42:22.419
4b11b62a-d28e-4a29-8673-1d588a34c3d9	a17cea7b-22a1-44e0-a813-5f16ce79bc69	\N	FLAT_TIRE_WHEEL	MEDIUM	Tire blowout on highway shoulder near exit 14	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 10:42:22.645	2026-11-22 10:42:22.645
f36961f4-c7dc-4b8a-9d17-58ec54f3ebb0	b347ca38-e44c-42ac-a846-63d4b6c28e3a	\N	COLLISION_ACCIDENT	CRITICAL	Multiple collision impact angles documented with 5 photographs	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Chassis Structural Impact / Collision Damage\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Emergency scene protocol: Remain behind highway barrier until first responders arrive. | Inspect roadway for combustible fluid spillage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Heavy Flatbed Recovery Unit, Fluid Absorption Spills Kit	t	2026-11-22 10:42:22.702	2026-11-22 10:42:22.702
3e3c598a-bce1-4477-95db-2e1f397dd5ae	b347ca38-e44c-42ac-a846-63d4b6c28e3a	8f8af963-f33f-4ef7-ab39-a9fb66446f50	BRAKE_SYSTEM_FAILURE	CRITICAL	Brakes completely lost hydraulic pressure on off-ramp	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Hydraulic Brake Line Breach / ABS Caliper Lock\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: CRITICAL SAFETY RISK: Do not attempt to operate vehicle under any circumstances. | Hydraulic brake pressure loss requires immediate workshop bleed and master cylinder triage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Flatbed Winch Carrier, Wheel Chocks	t	2026-11-22 10:42:22.779	2026-11-22 10:42:22.779
37ec9d06-b6dc-467b-aa06-dca2c2261de5	b347ca38-e44c-42ac-a846-63d4b6c28e3a	8f8af963-f33f-4ef7-ab39-a9fb66446f50	BATTERY_DEAD_ELECTRICAL	MEDIUM	Auxiliary battery failure requiring jump start on highway	40.748817	-73.985428	Near Empire State Building	[DIAGNOSIS PROTOCOL]: 12V Cranking Battery Drain / Alternator Failure\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Neutral gear lockout override may be required if electronic shifter is unpowered. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Commercial 12V/24V Jump-Pack, Digital Multimeter / Alternator Tester	f	2026-11-22 10:42:22.81	2026-11-22 10:42:22.81
0965a46b-e716-4562-bf7e-d6860dd16d85	b347ca38-e44c-42ac-a846-63d4b6c28e3a	\N	FUEL_EMPTY_OR_CONTAMINATED	LOW	Independent submission 2: Ran dry on frontage road	40.72	-74.01	\N	[DIAGNOSIS PROTOCOL]: Fuel Starvation / System Contamination\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 10:42:22.876	2026-11-22 10:42:22.876
1c237f6e-ad6e-44b7-bdb8-ba299173c09e	b347ca38-e44c-42ac-a846-63d4b6c28e3a	\N	OVERHEATING_COOLANT	MEDIUM	Independent submission 3: Steam escaping radiator	40.73	-74.02	\N	[DIAGNOSIS PROTOCOL]: Coolant System Rupture / Radiator Overpressure\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: SCALDING HAZARD: Engine coolant under extreme pressure. DO NOT open radiator or expansion tank cap. | Turn engine off immediately to prevent cylinder head warpage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Coolant Refill Reservoir, Infrared Thermometer, OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 10:42:22.891	2026-11-22 10:42:22.891
6b1cdabf-63d4-48d3-b4c4-eb8149b50d3c	24d8704e-eebc-4c21-986b-d85a1ed5a92a	\N	ENGINE_FAILURE	CRITICAL	Engine shut down completely on highway shoulder with oil warning.	37.7755	-122.418	Highway 101 Northbound Mile 4	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 10:42:23.158	2026-11-22 10:42:23.158
0432331c-96e7-45cf-8354-6ab3d5101bbc	24d8704e-eebc-4c21-986b-d85a1ed5a92a	\N	FLAT_TIRE_WHEEL	MEDIUM	Flat passenger tire in driveway.	37.775	-122.419	\N	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 10:42:23.555	2026-11-22 10:42:23.555
2f6f5479-7230-441a-a606-89737498bd2e	20e961e5-4364-4013-ac83-b3cdac902909	\N	BRAKE_SYSTEM_FAILURE	CRITICAL	Brake pedal collapsed to floorboards on exit ramp.	40.7128	-74.006	Exit 14C Hudson Toll Plaza	[DIAGNOSIS PROTOCOL]: Hydraulic Brake Line Breach / ABS Caliper Lock\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: CRITICAL SAFETY RISK: Do not attempt to operate vehicle under any circumstances. | Hydraulic brake pressure loss requires immediate workshop bleed and master cylinder triage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Flatbed Winch Carrier, Wheel Chocks	t	2026-11-22 10:58:26.384	2026-11-22 10:58:26.384
0fb0713e-6959-4252-9617-409ed77d5d0b	a180a88c-5a9a-4731-add7-99d767857c44	\N	BRAKE_SYSTEM_FAILURE	CRITICAL	Brake pedal collapsed to floorboards on exit ramp.	40.7128	-74.006	Exit 14C Hudson Toll Plaza	[DIAGNOSIS PROTOCOL]: Hydraulic Brake Line Breach / ABS Caliper Lock\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: CRITICAL SAFETY RISK: Do not attempt to operate vehicle under any circumstances. | Hydraulic brake pressure loss requires immediate workshop bleed and master cylinder triage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Flatbed Winch Carrier, Wheel Chocks	t	2026-11-22 10:58:53.202	2026-11-22 10:58:53.202
356f7a77-62de-4030-8ff7-bc494a984788	2ae75f04-e851-4d24-81dc-67588ba24232	\N	BRAKE_SYSTEM_FAILURE	CRITICAL	Brake pedal collapsed to floorboards on exit ramp.	40.7128	-74.006	Exit 14C Hudson Toll Plaza	[DIAGNOSIS PROTOCOL]: Hydraulic Brake Line Breach / ABS Caliper Lock\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: CRITICAL SAFETY RISK: Do not attempt to operate vehicle under any circumstances. | Hydraulic brake pressure loss requires immediate workshop bleed and master cylinder triage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Flatbed Winch Carrier, Wheel Chocks	t	2026-11-22 10:59:10.905	2026-11-22 10:59:10.905
6e0769cf-4206-4c87-adf3-2c0306c5b847	23e55200-8e86-4e87-92e2-b55e228b92f3	\N	FLAT_TIRE_WHEEL	LOW	Slow puncture in right rear tire. Vehicle safely parked on curb with spare ready.	40.73061	-73.935242	Brooklyn Greenpoint Ave	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 10:59:11.55	2026-11-22 10:59:11.55
4041c645-eab7-49c3-9d38-1c9fafb5dde0	49c5925b-fda2-4bcc-b6b0-87b387231f58	\N	FLAT_TIRE_WHEEL	MEDIUM	Tire blowout on highway shoulder near exit 14	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 10:59:11.71	2026-11-22 10:59:11.71
55e388e0-043b-4202-96e8-652a34019aff	245a9356-c816-4507-8269-0fc18dd346f9	\N	COLLISION_ACCIDENT	CRITICAL	Multiple collision impact angles documented with 5 photographs	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Chassis Structural Impact / Collision Damage\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Emergency scene protocol: Remain behind highway barrier until first responders arrive. | Inspect roadway for combustible fluid spillage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Heavy Flatbed Recovery Unit, Fluid Absorption Spills Kit	t	2026-11-22 10:59:11.839	2026-11-22 10:59:11.839
9cc682bc-3f0d-49cb-8d74-a50b0a2c1f64	245a9356-c816-4507-8269-0fc18dd346f9	f4f34e7f-632a-4c44-9dac-dd01760a638f	BRAKE_SYSTEM_FAILURE	CRITICAL	Brakes completely lost hydraulic pressure on off-ramp	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Hydraulic Brake Line Breach / ABS Caliper Lock\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: CRITICAL SAFETY RISK: Do not attempt to operate vehicle under any circumstances. | Hydraulic brake pressure loss requires immediate workshop bleed and master cylinder triage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Flatbed Winch Carrier, Wheel Chocks	t	2026-11-22 10:59:11.922	2026-11-22 10:59:11.922
3983c895-de71-4f78-a820-71f8d744ad5f	245a9356-c816-4507-8269-0fc18dd346f9	f4f34e7f-632a-4c44-9dac-dd01760a638f	BATTERY_DEAD_ELECTRICAL	MEDIUM	Auxiliary battery failure requiring jump start on highway	40.748817	-73.985428	Near Empire State Building	[DIAGNOSIS PROTOCOL]: 12V Cranking Battery Drain / Alternator Failure\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Neutral gear lockout override may be required if electronic shifter is unpowered. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Commercial 12V/24V Jump-Pack, Digital Multimeter / Alternator Tester	f	2026-11-22 10:59:11.959	2026-11-22 10:59:11.959
d23ddb79-7494-446a-8054-b9d150bf8d0a	245a9356-c816-4507-8269-0fc18dd346f9	\N	TRANSMISSION_ISSUE	CRITICAL	Independent submission 1: Gearbox stuck in 3rd	40.71	-74	\N	[DIAGNOSIS PROTOCOL]: Transmission Gearbox / Direct-Drive Lockup\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 10:59:12	2026-11-22 10:59:12
030263f0-7c25-4dff-bc45-b4a438485bb9	245a9356-c816-4507-8269-0fc18dd346f9	\N	FUEL_EMPTY_OR_CONTAMINATED	LOW	Independent submission 2: Ran dry on frontage road	40.72	-74.01	\N	[DIAGNOSIS PROTOCOL]: Fuel Starvation / System Contamination\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 10:59:12.04	2026-11-22 10:59:12.04
71b0773e-ebf7-4244-a6a6-9dc933b7f8d8	245a9356-c816-4507-8269-0fc18dd346f9	\N	OVERHEATING_COOLANT	MEDIUM	Independent submission 3: Steam escaping radiator	40.73	-74.02	\N	[DIAGNOSIS PROTOCOL]: Coolant System Rupture / Radiator Overpressure\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: SCALDING HAZARD: Engine coolant under extreme pressure. DO NOT open radiator or expansion tank cap. | Turn engine off immediately to prevent cylinder head warpage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Coolant Refill Reservoir, Infrared Thermometer, OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 10:59:12.055	2026-11-22 10:59:12.055
03ae0a20-4f05-42c1-86d2-ffd0a983be28	11947c9d-6f0f-425d-b26d-1cd07a25138a	\N	ENGINE_FAILURE	CRITICAL	Engine shut down completely on highway shoulder with oil warning.	37.7755	-122.418	Highway 101 Northbound Mile 4	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 10:59:12.247	2026-11-22 10:59:12.247
048050d1-e8b9-4e1a-8210-ba60f9268ff8	11947c9d-6f0f-425d-b26d-1cd07a25138a	\N	FLAT_TIRE_WHEEL	MEDIUM	Flat passenger tire in driveway.	37.775	-122.419	\N	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 10:59:12.615	2026-11-22 10:59:12.615
6859dfb4-688b-4470-bbe7-fff1440dd235	6f0c5a39-62c6-49b0-9305-3747a819cf83	\N	FLAT_TIRE_WHEEL	LOW	Slow puncture in right rear tire. Vehicle safely parked on curb with spare ready.	40.73061	-73.935242	Brooklyn Greenpoint Ave	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 11:06:31.919	2026-11-22 11:06:31.919
3d2d1e51-9774-4695-a9b9-fa0b3220a39a	4bc6bd4b-da8e-4372-8bac-0333b1e85ab1	\N	FLAT_TIRE_WHEEL	MEDIUM	Tire blowout on highway shoulder near exit 14	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 11:06:32.064	2026-11-22 11:06:32.064
f8d491ec-cbde-4ea3-a381-a9119fac61bf	15372eae-1d2d-4d1b-af92-e71b76d3393e	\N	BRAKE_SYSTEM_FAILURE	CRITICAL	Brake pedal collapsed to floorboards on exit ramp.	40.7128	-74.006	Exit 14C Hudson Toll Plaza	[DIAGNOSIS PROTOCOL]: Hydraulic Brake Line Breach / ABS Caliper Lock\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: CRITICAL SAFETY RISK: Do not attempt to operate vehicle under any circumstances. | Hydraulic brake pressure loss requires immediate workshop bleed and master cylinder triage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Flatbed Winch Carrier, Wheel Chocks	t	2026-11-22 11:06:32.115	2026-11-22 11:06:32.115
845e6757-b885-4e3a-bbed-6c57749bd625	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	\N	COLLISION_ACCIDENT	CRITICAL	Multiple collision impact angles documented with 5 photographs	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Chassis Structural Impact / Collision Damage\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Emergency scene protocol: Remain behind highway barrier until first responders arrive. | Inspect roadway for combustible fluid spillage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Heavy Flatbed Recovery Unit, Fluid Absorption Spills Kit	t	2026-11-22 11:06:32.307	2026-11-22 11:06:32.307
b82016f6-9dd1-4f11-a746-4550ebf6f96d	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	fe3f2481-0fd6-44af-9faf-2ea950606f85	BRAKE_SYSTEM_FAILURE	CRITICAL	Brakes completely lost hydraulic pressure on off-ramp	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Hydraulic Brake Line Breach / ABS Caliper Lock\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: CRITICAL SAFETY RISK: Do not attempt to operate vehicle under any circumstances. | Hydraulic brake pressure loss requires immediate workshop bleed and master cylinder triage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Flatbed Winch Carrier, Wheel Chocks	t	2026-11-22 11:06:32.396	2026-11-22 11:06:32.396
250c2a5b-9c33-4b33-aba6-cf5c2162e9fd	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	fe3f2481-0fd6-44af-9faf-2ea950606f85	BATTERY_DEAD_ELECTRICAL	MEDIUM	Auxiliary battery failure requiring jump start on highway	40.748817	-73.985428	Near Empire State Building	[DIAGNOSIS PROTOCOL]: 12V Cranking Battery Drain / Alternator Failure\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Neutral gear lockout override may be required if electronic shifter is unpowered. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Commercial 12V/24V Jump-Pack, Digital Multimeter / Alternator Tester	f	2026-11-22 11:06:32.43	2026-11-22 11:06:32.43
1b94f0f6-75c5-4580-bddf-c748edec2c94	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	\N	TRANSMISSION_ISSUE	CRITICAL	Independent submission 1: Gearbox stuck in 3rd	40.71	-74	\N	[DIAGNOSIS PROTOCOL]: Transmission Gearbox / Direct-Drive Lockup\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 11:06:32.454	2026-11-22 11:06:32.454
898cc3c8-4023-4798-a7b9-0d2be73fc7a7	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	\N	FUEL_EMPTY_OR_CONTAMINATED	LOW	Independent submission 2: Ran dry on frontage road	40.72	-74.01	\N	[DIAGNOSIS PROTOCOL]: Fuel Starvation / System Contamination\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 11:06:32.492	2026-11-22 11:06:32.492
9996c2aa-0bd0-4024-aa01-e6a55bc9d558	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	\N	OVERHEATING_COOLANT	MEDIUM	Independent submission 3: Steam escaping radiator	40.73	-74.02	\N	[DIAGNOSIS PROTOCOL]: Coolant System Rupture / Radiator Overpressure\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: SCALDING HAZARD: Engine coolant under extreme pressure. DO NOT open radiator or expansion tank cap. | Turn engine off immediately to prevent cylinder head warpage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Coolant Refill Reservoir, Infrared Thermometer, OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 11:06:32.508	2026-11-22 11:06:32.508
7738f408-4034-4b3c-a39e-4028de0e74b3	1302fef8-4b27-4105-8596-a34489c6c8a0	\N	ENGINE_FAILURE	CRITICAL	Engine shut down completely on highway shoulder with oil warning.	37.7755	-122.418	Highway 101 Northbound Mile 4	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 11:06:32.576	2026-11-22 11:06:32.576
6f9a06f2-600d-4535-8cd1-9ff04860f1b1	1302fef8-4b27-4105-8596-a34489c6c8a0	\N	FLAT_TIRE_WHEEL	MEDIUM	Flat passenger tire in driveway.	37.775	-122.419	\N	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 11:06:32.987	2026-11-22 11:06:32.987
312b7774-bd00-4e4b-9c0c-d0642c12a432	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	TRANSMISSION_ISSUE	CRITICAL	Sudden transmission shudder followed by gear slip and complete loss of drive on highway shoulder. Heavy fluid leak observed underneath gearbox.	40.710996	-74.001495	Interstate 95 Northbound, Mile Marker 42.5 Shoulder	[DIAGNOSIS PROTOCOL]: Transmission Gearbox / Direct-Drive Lockup\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 11:07:36.254	2026-11-22 11:07:36.254
1c0a5cf0-9df0-4afb-aa9d-e4a46395adcd	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	Manual coordinate breakdown submission: Brake squeal and spongy pedal on mountain descent.	40.709174	-73.996948	Route 9W Scenic Overlook, Mile Marker 12	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 11:07:43.563	2026-11-22 11:07:43.563
36a184dc-b9a3-47f3-86a2-2efc97e7ede8	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	E2E Milestone 4 Test: Engine stalling on FDR Drive shoulder with battery warning.	40.7128	-74.006	FDR Drive Southbound near Houston St	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 11:07:48.161	2026-11-22 11:07:48.161
5b068a25-9e91-4e4c-95bb-b9f839bf9b5f	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	Rollback Verification Test 1795345685244: Gearbox locking up on highway	40.7128	-74.006	Broadway & 42nd St Intersection	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 11:08:05.314	2026-11-22 11:08:05.314
1a1171b1-4a64-4812-b079-04eadd18361c	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	Engine stopped running on shoulder. Oil light illuminated. Reference: I-80 Mile 12 Marker #3371	40.7128	-74.006	I-80 Mile 12 Marker #3371	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 11:08:15.708	2026-11-22 11:08:15.708
1d1a241e-bf02-4a78-80f4-ae93adf87072	6a3159ce-3ec1-46ee-8854-079b5cef5d0c	\N	ENGINE_FAILURE	CRITICAL	Engine stalled with metallic knock on I-95.	40.7128	-74.006	\N	\N	t	2026-11-22 11:25:10.606	2026-11-22 11:25:10.606
607116f4-a13b-475a-bb6e-20b308f824fd	efeb8cd7-f7cc-4dfd-8689-240f124ae2a4	\N	FLAT_TIRE_WHEEL	MEDIUM	Sidewall puncture on Turnpike.	40.73	-74.02	\N	\N	f	2026-11-22 11:25:10.614	2026-11-22 11:25:10.614
cd3571e7-de39-4457-b3d5-fdc410810e1d	6a3159ce-3ec1-46ee-8854-079b5cef5d0c	\N	BATTERY_DEAD_ELECTRICAL	MEDIUM	Battery dead in garage.	40.72	-74.01	\N	\N	f	2026-11-22 11:25:10.618	2026-11-22 11:25:10.618
aecf39c9-71a8-48a8-af93-59161a7c37a1	84ecd965-cf9b-4db3-92a0-2fb64a3e965f	\N	ENGINE_FAILURE	CRITICAL	Engine stalled with metallic knock on I-95.	40.7128	-74.006	\N	\N	t	2026-11-22 11:25:31.964	2026-11-22 11:25:31.964
31291c72-b865-4861-9b6b-b2c0f6def9c8	3517d75c-d341-43ab-b318-7b13f2026e31	\N	FLAT_TIRE_WHEEL	MEDIUM	Sidewall puncture on Turnpike.	40.73	-74.02	\N	\N	f	2026-11-22 11:25:31.975	2026-11-22 11:25:31.975
a4381bf2-ed14-4497-bf2d-c3bf18dc0f35	84ecd965-cf9b-4db3-92a0-2fb64a3e965f	\N	BATTERY_DEAD_ELECTRICAL	MEDIUM	Battery dead in garage.	40.72	-74.01	\N	\N	f	2026-11-22 11:25:31.983	2026-11-22 11:25:31.983
27d72a58-44f6-43a7-a9e4-a96b40330c20	282be406-30b3-4a61-a470-484970fa2ef9	\N	FLAT_TIRE_WHEEL	LOW	Slow puncture in right rear tire. Vehicle safely parked on curb with spare ready.	40.73061	-73.935242	Brooklyn Greenpoint Ave	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 11:25:32.505	2026-11-22 11:25:32.505
e6923eb3-18c2-4b16-b4a0-d4a3998a666c	8ce31ba5-bfb6-4062-8788-1d55d758fd08	\N	BRAKE_SYSTEM_FAILURE	CRITICAL	Brake pedal collapsed to floorboards on exit ramp.	40.7128	-74.006	Exit 14C Hudson Toll Plaza	[DIAGNOSIS PROTOCOL]: Hydraulic Brake Line Breach / ABS Caliper Lock\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: CRITICAL SAFETY RISK: Do not attempt to operate vehicle under any circumstances. | Hydraulic brake pressure loss requires immediate workshop bleed and master cylinder triage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Flatbed Winch Carrier, Wheel Chocks	t	2026-11-22 11:25:32.783	2026-11-22 11:25:32.783
0d30da36-9f22-4786-9125-0e3145158573	7a09bda9-bcb7-47db-9d6f-9cde4f8fe7cd	\N	FLAT_TIRE_WHEEL	MEDIUM	Tire blowout on highway shoulder near exit 14	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 11:25:32.864	2026-11-22 11:25:32.864
6becf48c-b717-4a4e-a1bd-01d4de22626a	50ade227-7e8a-46fd-8685-2e2878c91b01	\N	COLLISION_ACCIDENT	CRITICAL	Multiple collision impact angles documented with 5 photographs	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Chassis Structural Impact / Collision Damage\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Emergency scene protocol: Remain behind highway barrier until first responders arrive. | Inspect roadway for combustible fluid spillage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Heavy Flatbed Recovery Unit, Fluid Absorption Spills Kit	t	2026-11-22 11:25:32.936	2026-11-22 11:25:32.936
969cc92d-226b-4e5b-977d-7f642db8a5f5	50ade227-7e8a-46fd-8685-2e2878c91b01	42527336-e329-4b38-9fb3-5430e812ae29	BRAKE_SYSTEM_FAILURE	CRITICAL	Brakes completely lost hydraulic pressure on off-ramp	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Hydraulic Brake Line Breach / ABS Caliper Lock\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: CRITICAL SAFETY RISK: Do not attempt to operate vehicle under any circumstances. | Hydraulic brake pressure loss requires immediate workshop bleed and master cylinder triage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Flatbed Winch Carrier, Wheel Chocks	t	2026-11-22 11:25:33.019	2026-11-22 11:25:33.019
f23b78d1-b4a0-4ea2-b3ca-2af9d7489f1e	50ade227-7e8a-46fd-8685-2e2878c91b01	42527336-e329-4b38-9fb3-5430e812ae29	BATTERY_DEAD_ELECTRICAL	MEDIUM	Auxiliary battery failure requiring jump start on highway	40.748817	-73.985428	Near Empire State Building	[DIAGNOSIS PROTOCOL]: 12V Cranking Battery Drain / Alternator Failure\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Neutral gear lockout override may be required if electronic shifter is unpowered. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Commercial 12V/24V Jump-Pack, Digital Multimeter / Alternator Tester	f	2026-11-22 11:25:33.047	2026-11-22 11:25:33.047
37063bc8-54b1-46dd-afca-64681a16d2aa	50ade227-7e8a-46fd-8685-2e2878c91b01	\N	TRANSMISSION_ISSUE	CRITICAL	Independent submission 1: Gearbox stuck in 3rd	40.71	-74	\N	[DIAGNOSIS PROTOCOL]: Transmission Gearbox / Direct-Drive Lockup\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 11:25:33.075	2026-11-22 11:25:33.075
eab83563-92d4-4bfb-89b7-cfcfe67966ce	50ade227-7e8a-46fd-8685-2e2878c91b01	\N	FUEL_EMPTY_OR_CONTAMINATED	LOW	Independent submission 2: Ran dry on frontage road	40.72	-74.01	\N	[DIAGNOSIS PROTOCOL]: Fuel Starvation / System Contamination\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 11:25:33.117	2026-11-22 11:25:33.117
8746d8c6-a64d-46f1-ba26-6dec37df5253	50ade227-7e8a-46fd-8685-2e2878c91b01	\N	OVERHEATING_COOLANT	MEDIUM	Independent submission 3: Steam escaping radiator	40.73	-74.02	\N	[DIAGNOSIS PROTOCOL]: Coolant System Rupture / Radiator Overpressure\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: SCALDING HAZARD: Engine coolant under extreme pressure. DO NOT open radiator or expansion tank cap. | Turn engine off immediately to prevent cylinder head warpage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Coolant Refill Reservoir, Infrared Thermometer, OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 11:25:33.131	2026-11-22 11:25:33.131
a3d91c21-bd2b-412e-8166-41a2f250c67f	cd78682e-cc1a-4cc1-b024-3222b9c5e339	\N	ENGINE_FAILURE	CRITICAL	Engine shut down completely on highway shoulder with oil warning.	37.7755	-122.418	Highway 101 Northbound Mile 4	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 11:25:33.327	2026-11-22 11:25:33.327
33bbeee6-4536-405b-a9b2-d8aed27e4209	cd78682e-cc1a-4cc1-b024-3222b9c5e339	\N	FLAT_TIRE_WHEEL	MEDIUM	Flat passenger tire in driveway.	37.775	-122.419	\N	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 11:25:33.686	2026-11-22 11:25:33.686
ac94019b-d02f-4c1b-989b-749ce80ecf04	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	Milestone 7 Review Test: Transmission stall near FDR Marker M7-1795347065815	40.7128	-74.006	FDR Marker M7-1795347065815	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 11:31:05.885	2026-11-22 11:31:05.885
ce937235-7304-4408-a12d-bd7e6c054024	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	Milestone 7 Review Test: Transmission stall near FDR Marker M7-1795347164307	40.7128	-74.006	FDR Marker M7-1795347164307	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 11:32:44.374	2026-11-22 11:32:44.374
d872046f-47b1-4b24-b3a4-aae87870c8c6	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	Milestone 7 Review Test: Transmission stall near FDR Marker M7-1795347225287	40.7128	-74.006	FDR Marker M7-1795347225287	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 11:33:45.349	2026-11-22 11:33:45.349
5012bca7-4cb4-4e82-8916-4f1bdad195b3	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	Milestone 7 Review Test: Transmission stall near FDR Marker M7-1795347306524	40.7128	-74.006	FDR Marker M7-1795347306524	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 11:35:06.586	2026-11-22 11:35:06.586
552d5408-a375-458e-a45f-be861f2b2eba	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	Milestone 7 Review Test: Transmission stall near FDR Marker M7-1795347364977	40.7128	-74.006	FDR Marker M7-1795347364977	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 11:36:05.038	2026-11-22 11:36:05.038
8e59617b-5a64-4ded-8303-eaed2f929ac4	487c98dd-e41e-417a-81df-6160ad2f08bd	\N	FLAT_TIRE_WHEEL	LOW	Slow puncture in right rear tire. Vehicle safely parked on curb with spare ready.	40.73061	-73.935242	Brooklyn Greenpoint Ave	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 11:36:38.697	2026-11-22 11:36:38.697
4ba3c798-67ff-4b33-b544-41fd9088a67a	6108dc7f-6c15-4ee6-8a47-92ff7487b689	\N	BRAKE_SYSTEM_FAILURE	CRITICAL	Brake pedal collapsed to floorboards on exit ramp.	40.7128	-74.006	Exit 14C Hudson Toll Plaza	[DIAGNOSIS PROTOCOL]: Hydraulic Brake Line Breach / ABS Caliper Lock\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: CRITICAL SAFETY RISK: Do not attempt to operate vehicle under any circumstances. | Hydraulic brake pressure loss requires immediate workshop bleed and master cylinder triage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Flatbed Winch Carrier, Wheel Chocks	t	2026-11-22 11:36:38.789	2026-11-22 11:36:38.789
d132efdb-0d4c-4588-9a16-621c3920c2e9	03049ccb-baf0-499d-aa2d-d5dce89114ad	\N	ENGINE_FAILURE	CRITICAL	Engine stalled with metallic knock on I-95.	40.7128	-74.006	\N	\N	t	2026-11-22 11:36:38.866	2026-11-22 11:36:38.866
62e18235-9d10-4a84-8e41-4a07a40444b6	4c50ae6c-ef63-4e39-a5b0-d01121d5eb64	\N	FLAT_TIRE_WHEEL	MEDIUM	Sidewall puncture on Turnpike.	40.73	-74.02	\N	\N	f	2026-11-22 11:36:38.875	2026-11-22 11:36:38.875
ee92f51f-1dba-4d3d-883e-2da4a41c4381	03049ccb-baf0-499d-aa2d-d5dce89114ad	\N	BATTERY_DEAD_ELECTRICAL	MEDIUM	Battery dead in garage.	40.72	-74.01	\N	\N	f	2026-11-22 11:36:38.882	2026-11-22 11:36:38.882
2524c83a-698d-4dcf-b25d-098dce069ec0	12a59ca0-ebce-49aa-b8c8-2d6021a4d980	\N	FLAT_TIRE_WHEEL	MEDIUM	Tire blowout on highway shoulder near exit 14	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 11:36:38.957	2026-11-22 11:36:38.957
7aacdfa6-e34b-4805-9d3e-c62e0d71be25	bbdc9439-1243-4dec-a18b-8b6512cede79	\N	COLLISION_ACCIDENT	CRITICAL	Multiple collision impact angles documented with 5 photographs	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Chassis Structural Impact / Collision Damage\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Emergency scene protocol: Remain behind highway barrier until first responders arrive. | Inspect roadway for combustible fluid spillage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Heavy Flatbed Recovery Unit, Fluid Absorption Spills Kit	t	2026-11-22 11:36:39.041	2026-11-22 11:36:39.041
08758044-73c1-468f-b742-bce92751dbd7	bbdc9439-1243-4dec-a18b-8b6512cede79	45b61161-5415-4ad2-ae34-c28f07ebb8e8	BRAKE_SYSTEM_FAILURE	CRITICAL	Brakes completely lost hydraulic pressure on off-ramp	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Hydraulic Brake Line Breach / ABS Caliper Lock\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: CRITICAL SAFETY RISK: Do not attempt to operate vehicle under any circumstances. | Hydraulic brake pressure loss requires immediate workshop bleed and master cylinder triage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Flatbed Winch Carrier, Wheel Chocks	t	2026-11-22 11:36:39.14	2026-11-22 11:36:39.14
fb7b8b5b-800f-42d6-887e-fdcbeee3bbfc	bbdc9439-1243-4dec-a18b-8b6512cede79	45b61161-5415-4ad2-ae34-c28f07ebb8e8	BATTERY_DEAD_ELECTRICAL	MEDIUM	Auxiliary battery failure requiring jump start on highway	40.748817	-73.985428	Near Empire State Building	[DIAGNOSIS PROTOCOL]: 12V Cranking Battery Drain / Alternator Failure\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Neutral gear lockout override may be required if electronic shifter is unpowered. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Commercial 12V/24V Jump-Pack, Digital Multimeter / Alternator Tester	f	2026-11-22 11:36:39.169	2026-11-22 11:36:39.169
ebdcc180-2ba4-45d8-9ab1-cbe009e4eaea	bbdc9439-1243-4dec-a18b-8b6512cede79	\N	TRANSMISSION_ISSUE	CRITICAL	Independent submission 1: Gearbox stuck in 3rd	40.71	-74	\N	[DIAGNOSIS PROTOCOL]: Transmission Gearbox / Direct-Drive Lockup\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 11:36:39.192	2026-11-22 11:36:39.192
65a2e74c-6677-468c-8339-8db363fe524d	bbdc9439-1243-4dec-a18b-8b6512cede79	\N	FUEL_EMPTY_OR_CONTAMINATED	LOW	Independent submission 2: Ran dry on frontage road	40.72	-74.01	\N	[DIAGNOSIS PROTOCOL]: Fuel Starvation / System Contamination\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 11:36:39.232	2026-11-22 11:36:39.232
a82f9c72-4778-4c3b-835c-f78992aecb3b	bbdc9439-1243-4dec-a18b-8b6512cede79	\N	OVERHEATING_COOLANT	MEDIUM	Independent submission 3: Steam escaping radiator	40.73	-74.02	\N	[DIAGNOSIS PROTOCOL]: Coolant System Rupture / Radiator Overpressure\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: SCALDING HAZARD: Engine coolant under extreme pressure. DO NOT open radiator or expansion tank cap. | Turn engine off immediately to prevent cylinder head warpage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Coolant Refill Reservoir, Infrared Thermometer, OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 11:36:39.248	2026-11-22 11:36:39.248
c74273d7-4f72-4d58-9ed4-29cc12d0e18c	4a059e43-c586-45be-b371-252f448bbdd8	\N	ENGINE_FAILURE	CRITICAL	Engine shut down completely on highway shoulder with oil warning.	37.7755	-122.418	Highway 101 Northbound Mile 4	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 11:36:39.378	2026-11-22 11:36:39.378
2cf2f727-6312-48cd-bd20-16380a1cbb20	ff166c12-fa96-4a4d-8523-7e1801d01b3f	\N	ENGINE_FAILURE	CRITICAL	Engine shut down completely on highway shoulder with oil warning.	37.7755	-122.418	Highway 101 Northbound Mile 4	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 11:55:25.123	2026-11-22 11:55:25.123
2d100af3-8bd2-4963-8b0d-22ff3a5ade37	4a059e43-c586-45be-b371-252f448bbdd8	\N	FLAT_TIRE_WHEEL	MEDIUM	Flat passenger tire in driveway.	37.775	-122.419	\N	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 11:36:39.738	2026-11-22 11:36:39.738
9b64d833-e393-469b-bab9-6f3561589965	a1479806-db8e-432b-a61a-04b1494faf85	ace1cb6e-1e74-4c0d-84df-622d529c8a5e	ENGINE_FAILURE	MEDIUM	kmlklkmklm	16.354086	80.529583	\N	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 11:42:14.492	2026-11-22 11:42:14.492
7b3bf718-ece7-4e61-af69-7314be4d52d9	a89d8a1e-ad80-4555-a258-0392941f695b	\N	ENGINE_FAILURE	CRITICAL	Engine failure on West Side Hwy	40.75	-74	\N	\N	f	2026-11-22 11:52:12.1	2026-11-22 11:52:12.1
494eb78b-51b0-42e6-b1a5-d890f3a4b279	766576f6-0959-4864-8a7e-649df595336b	\N	ENGINE_FAILURE	CRITICAL	Engine failure on West Side Hwy	40.75	-74	\N	\N	f	2026-11-22 11:52:52.093	2026-11-22 11:52:52.093
9d3051c0-8388-42a6-9915-01e654a8f25e	935f0c45-76f4-4be0-8fb0-95fb6009b2dd	\N	FLAT_TIRE_WHEEL	LOW	Slow puncture in right rear tire. Vehicle safely parked on curb with spare ready.	40.73061	-73.935242	Brooklyn Greenpoint Ave	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 11:55:24.505	2026-11-22 11:55:24.505
c3203b0c-f0c1-45a5-b45f-7476117d5877	c5be2c05-7982-46af-9db0-2f3f296f630b	\N	ENGINE_FAILURE	CRITICAL	Engine stalled with metallic knock on I-95.	40.7128	-74.006	\N	\N	t	2026-11-22 11:55:24.705	2026-11-22 11:55:24.705
99e0bd8d-3fec-4c08-ae5c-ed0fc3bc32a7	fe4fed22-b93a-4dfe-b237-66a079f96a50	\N	FLAT_TIRE_WHEEL	MEDIUM	Tire blowout on highway shoulder near exit 14	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 11:55:24.705	2026-11-22 11:55:24.705
aa3a0cc7-2095-48db-9385-5fa8b374b272	863029a2-5a25-4be2-be07-0680e859f3f2	\N	FLAT_TIRE_WHEEL	MEDIUM	Sidewall puncture on Turnpike.	40.73	-74.02	\N	\N	f	2026-11-22 11:55:24.716	2026-11-22 11:55:24.716
e09942b9-cbe9-48d2-8dce-62626bf85792	c5be2c05-7982-46af-9db0-2f3f296f630b	\N	BATTERY_DEAD_ELECTRICAL	MEDIUM	Battery dead in garage.	40.72	-74.01	\N	\N	f	2026-11-22 11:55:24.723	2026-11-22 11:55:24.723
28561722-6044-40b7-8585-fa98bc261428	413f9c28-135a-41dc-9ae3-29f264612e2c	\N	BRAKE_SYSTEM_FAILURE	CRITICAL	Brake pedal collapsed to floorboards on exit ramp.	40.7128	-74.006	Exit 14C Hudson Toll Plaza	[DIAGNOSIS PROTOCOL]: Hydraulic Brake Line Breach / ABS Caliper Lock\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: CRITICAL SAFETY RISK: Do not attempt to operate vehicle under any circumstances. | Hydraulic brake pressure loss requires immediate workshop bleed and master cylinder triage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Flatbed Winch Carrier, Wheel Chocks	t	2026-11-22 11:55:24.754	2026-11-22 11:55:24.754
4293a444-f8c9-4993-8c12-683415bf4f95	eeec89bd-77f1-4b87-b039-63f9778b4621	\N	COLLISION_ACCIDENT	CRITICAL	Multiple collision impact angles documented with 5 photographs	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Chassis Structural Impact / Collision Damage\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Emergency scene protocol: Remain behind highway barrier until first responders arrive. | Inspect roadway for combustible fluid spillage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Heavy Flatbed Recovery Unit, Fluid Absorption Spills Kit	t	2026-11-22 11:55:24.758	2026-11-22 11:55:24.758
c47a7165-a241-47b3-9e5c-e74bcadc472f	eeec89bd-77f1-4b87-b039-63f9778b4621	a1f35bc6-bdfa-4770-ac93-26622cd77c2e	BRAKE_SYSTEM_FAILURE	CRITICAL	Brakes completely lost hydraulic pressure on off-ramp	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Hydraulic Brake Line Breach / ABS Caliper Lock\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: CRITICAL SAFETY RISK: Do not attempt to operate vehicle under any circumstances. | Hydraulic brake pressure loss requires immediate workshop bleed and master cylinder triage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Flatbed Winch Carrier, Wheel Chocks	t	2026-11-22 11:55:24.859	2026-11-22 11:55:24.859
3ad6e8f9-bb57-4011-8b0c-c6e394cefbfe	eeec89bd-77f1-4b87-b039-63f9778b4621	a1f35bc6-bdfa-4770-ac93-26622cd77c2e	BATTERY_DEAD_ELECTRICAL	MEDIUM	Auxiliary battery failure requiring jump start on highway	40.748817	-73.985428	Near Empire State Building	[DIAGNOSIS PROTOCOL]: 12V Cranking Battery Drain / Alternator Failure\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Neutral gear lockout override may be required if electronic shifter is unpowered. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Commercial 12V/24V Jump-Pack, Digital Multimeter / Alternator Tester	f	2026-11-22 11:55:24.896	2026-11-22 11:55:24.896
c48d0928-218b-4b6f-a048-727e8b5aa30d	e43779a3-03a2-4ed0-a27b-1c66d4ab40bf	\N	ENGINE_FAILURE	CRITICAL	Engine failure on West Side Hwy	40.75	-74	\N	\N	f	2026-11-22 11:55:24.914	2026-11-22 11:55:24.914
3944cf87-4b61-42bd-8823-ab0a9d694c59	eeec89bd-77f1-4b87-b039-63f9778b4621	\N	TRANSMISSION_ISSUE	CRITICAL	Independent submission 1: Gearbox stuck in 3rd	40.71	-74	\N	[DIAGNOSIS PROTOCOL]: Transmission Gearbox / Direct-Drive Lockup\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 11:55:24.927	2026-11-22 11:55:24.927
e0440403-d555-44d7-a484-7bd3ab1fa1d7	eeec89bd-77f1-4b87-b039-63f9778b4621	\N	FUEL_EMPTY_OR_CONTAMINATED	LOW	Independent submission 2: Ran dry on frontage road	40.72	-74.01	\N	[DIAGNOSIS PROTOCOL]: Fuel Starvation / System Contamination\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 11:55:24.972	2026-11-22 11:55:24.972
52954004-6d7c-4584-90cc-7085607573fe	eeec89bd-77f1-4b87-b039-63f9778b4621	\N	OVERHEATING_COOLANT	MEDIUM	Independent submission 3: Steam escaping radiator	40.73	-74.02	\N	[DIAGNOSIS PROTOCOL]: Coolant System Rupture / Radiator Overpressure\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: SCALDING HAZARD: Engine coolant under extreme pressure. DO NOT open radiator or expansion tank cap. | Turn engine off immediately to prevent cylinder head warpage. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: Coolant Refill Reservoir, Infrared Thermometer, OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 11:55:24.995	2026-11-22 11:55:24.995
29ef0dd0-0c14-4218-9e47-f83a126bf3ee	ff166c12-fa96-4a4d-8523-7e1801d01b3f	\N	FLAT_TIRE_WHEEL	MEDIUM	Flat passenger tire in driveway.	37.775	-122.419	\N	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 11:55:25.521	2026-11-22 11:55:25.521
f6f383be-6c44-4f0e-bb2b-45cea04224da	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	TRANSMISSION_ISSUE	CRITICAL	Sudden transmission shudder followed by gear slip and complete loss of drive on highway shoulder. Heavy fluid leak observed underneath gearbox.	40.710996	-74.001495	Interstate 95 Northbound, Mile Marker 42.5 Shoulder	[DIAGNOSIS PROTOCOL]: Transmission Gearbox / Direct-Drive Lockup\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 11:56:24.023	2026-11-22 11:56:24.023
e317df69-1c34-4324-a280-aa0d53c1112d	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	Manual coordinate breakdown submission: Brake squeal and spongy pedal on mountain descent.	40.709174	-73.996948	Route 9W Scenic Overlook, Mile Marker 12	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 11:56:31.035	2026-11-22 11:56:31.035
ea3fcfd7-078d-499f-a11d-37196fec2b8a	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	E2E Milestone 4 Test: Engine stalling on FDR Drive shoulder with battery warning.	40.7128	-74.006	FDR Drive Southbound near Houston St	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 11:56:35.181	2026-11-22 11:56:35.181
e54e3755-f888-459b-9047-60691b32802d	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	E2E Milestone 4 Test: Engine stalling on FDR Drive shoulder with battery warning.	40.7128	-74.006	FDR Drive Southbound near Houston St	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 12:00:47.663	2026-11-22 12:00:47.663
e33d20bb-2436-466d-b117-61201f06b5dc	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	E2E Milestone 4 Test: Engine stalling on FDR Drive shoulder with battery warning.	40.7128	-74.006	FDR Drive Southbound near Houston St	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 12:02:55.214	2026-11-22 12:02:55.214
6dc19581-1f1f-4a36-a677-4a50b150fce5	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	TRANSMISSION_ISSUE	CRITICAL	Sudden transmission shudder followed by gear slip and complete loss of drive on highway shoulder. Heavy fluid leak observed underneath gearbox.	40.710996	-74.001495	Interstate 95 Northbound, Mile Marker 42.5 Shoulder	[DIAGNOSIS PROTOCOL]: Transmission Gearbox / Direct-Drive Lockup\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 12:03:42.565	2026-11-22 12:03:42.565
69551a64-33a8-4e75-8baf-2b9e850826fe	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	Manual coordinate breakdown submission: Brake squeal and spongy pedal on mountain descent.	40.709174	-73.996948	Route 9W Scenic Overlook, Mile Marker 12	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 12:03:49.434	2026-11-22 12:03:49.434
8e424443-420f-42b5-9879-0e150a72f664	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	E2E Milestone 4 Test: Engine stalling on FDR Drive shoulder with battery warning.	40.7128	-74.006	FDR Drive Southbound near Houston St	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 12:03:53.527	2026-11-22 12:03:53.527
825701fc-b817-4525-83ad-1d4baa29a894	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	Rollback Verification Test 1795349045483: Gearbox locking up on highway	40.7128	-74.006	Broadway & 42nd St Intersection	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 12:04:05.562	2026-11-22 12:04:05.562
d3a66f3c-c30d-48f1-b4d1-c872902b948d	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	Engine stopped running on shoulder. Oil light illuminated. Reference: I-80 Mile 12 Marker #3408	40.7128	-74.006	I-80 Mile 12 Marker #3408	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 12:04:15.807	2026-11-22 12:04:15.807
9cd03908-707c-4205-94b7-73f44fa0c574	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	ENGINE_FAILURE	MEDIUM	Milestone 7 Review Test: Transmission stall near FDR Marker M7-1795349078628	40.7128	-74.006	FDR Marker M7-1795349078628	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 12:04:38.691	2026-11-22 12:04:38.691
3a38191a-aba1-4735-9a13-ed6afac739cb	a1479806-db8e-432b-a61a-04b1494faf85	ace1cb6e-1e74-4c0d-84df-622d529c8a5e	ENGINE_FAILURE	MEDIUM	engine failure	16.354215	80.529629	\N	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 12:13:07.299	2026-11-22 12:13:07.299
1e25ba21-ffad-4310-aeae-5963f9323c16	a1479806-db8e-432b-a61a-04b1494faf85	ace1cb6e-1e74-4c0d-84df-622d529c8a5e	ENGINE_FAILURE	MEDIUM	jxbajhdakdgaddaegugdud	16.354106	80.529639	\N	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 12:15:59.997	2026-11-22 12:15:59.997
f05ff4a3-34c7-45dc-8533-9bc02a7e1195	a1479806-db8e-432b-a61a-04b1494faf85	ace1cb6e-1e74-4c0d-84df-622d529c8a5e	ENGINE_FAILURE	MEDIUM	afadfafaf	16.354108	80.529642	\N	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 12:17:08.904	2026-11-22 12:17:08.904
fd037608-4158-4dd2-81b1-0fc7cb9e1b0b	7728fd21-9b94-481c-b739-87c80836528a	\N	FLAT_TIRE_WHEEL	MEDIUM	Tire blowout on highway shoulder near exit 14	40.7128	-74.006	\N	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 13:04:37.064	2026-11-22 13:04:37.064
b8024a20-a82d-4a25-958f-db501f08dd0d	f34fa6c9-f73a-42c4-9160-85d695a71a2b	\N	ENGINE_FAILURE	CRITICAL	Engine shut down completely on highway shoulder with oil warning.	37.7755	-122.418	Highway 101 Northbound Mile 4	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 13:04:37.493	2026-11-22 13:04:37.493
39cc810c-2b79-4754-81a5-33245e48a631	f34fa6c9-f73a-42c4-9160-85d695a71a2b	\N	FLAT_TIRE_WHEEL	MEDIUM	Flat passenger tire in driveway.	37.775	-122.419	\N	[DIAGNOSIS PROTOCOL]: Pneumatic Tire Puncture / Sidewall Breach\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Position vehicle entirely onto emergency shoulder before inspecting tire. | Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: 3-Ton Pneumatic Low-Profile Jack, Impact Wrench, Tire Sealant Kit	f	2026-11-22 13:04:37.846	2026-11-22 13:04:37.846
46a295dd-9804-4bb2-89df-48c6eb40c4c8	e22478b0-00a4-44f8-b146-3649213c7a20	a260d478-71b9-4303-9ec5-c6fd70ab4c4a	TRANSMISSION_ISSUE	CRITICAL	Sudden transmission shudder followed by gear slip and complete loss of drive on highway shoulder. Heavy fluid leak observed underneath gearbox.	40.710996	-74.001495	Interstate 95 Northbound, Mile Marker 42.5 Shoulder	[DIAGNOSIS PROTOCOL]: Transmission Gearbox / Direct-Drive Lockup\n[DISPATCH TIER]: FLATBED WINCH EXTRACTION\n[TOWING VERDICT]: MANDATORY FLATBED RECOVERY\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	t	2026-11-22 13:19:19.422	2026-11-22 13:19:19.422
04a25238-d813-492c-8e98-59baff62cdba	a1479806-db8e-432b-a61a-04b1494faf85	ace1cb6e-1e74-4c0d-84df-622d529c8a5e	ENGINE_FAILURE	MEDIUM	gjjyjyf	16.354295	80.529639	\N	[DIAGNOSIS PROTOCOL]: Internal Combustion Powertrain Seizure / Stalling\n[DISPATCH TIER]: MOBILE ROADSIDE FIELD DISPATCH\n[TOWING VERDICT]: ROADSIDE MOBILE REPAIR ELIGIBLE\n[SAFETY ADVISORIES]: Ensure emergency hazard flashers are active.\n[RECOMMENDED GEAR]: OBD-II CAN-Bus Diagnostic Scanner, Standard Roadside Field Toolkit	f	2026-11-22 15:46:06.598	2026-11-22 15:46:06.598
\.


--
-- Data for Name: Complaint; Type: TABLE DATA; Schema: public; Owner: vbrs_admin
--

COPY public."Complaint" (id, "serviceRequestId", "filedById", "targetUserId", subject, description, status, "resolutionNotes", "resolvedAt", "createdAt", "updatedAt") FROM stdin;
2cadaabb-2737-483f-8540-1a0a31f51212	cfcb4df3-b199-4ed3-9448-0f6165f70602	20e961e5-4364-4013-ac83-b3cdac902909	\N	Late Arrival & Tow Rig Discrepancy	Flatbed recovery arrived 45 minutes beyond scheduled ETA window.	RESOLVED	Traffic bottleneck verified on camera feed. Courtesy credit applied.	2026-11-22 10:58:26.506	2026-11-22 10:58:26.458	2026-11-22 10:58:26.507
8a0ade19-abd3-4bfb-bb21-4369a97fd3fc	46de9cc7-0ffd-4f17-934b-809a3ff3be0e	a180a88c-5a9a-4731-add7-99d767857c44	\N	Late Arrival & Tow Rig Discrepancy	Flatbed recovery arrived 45 minutes beyond scheduled ETA window.	RESOLVED	Traffic bottleneck verified on camera feed. Courtesy credit applied.	2026-11-22 10:58:53.326	2026-11-22 10:58:53.273	2026-11-22 10:58:53.33
834eb098-3585-440b-b1f8-41f8d4f2b083	0c60b08f-e918-4c69-a585-045e9c65ff7d	2ae75f04-e851-4d24-81dc-67588ba24232	\N	Late Arrival & Tow Rig Discrepancy	Flatbed recovery arrived 45 minutes beyond scheduled ETA window.	RESOLVED	E2E Resolution: Motorist and certified technician mutually agreed on final diagnostic adjustment.	2026-11-22 11:06:06.611	2026-11-22 10:59:11.013	2026-11-22 11:06:06.613
0c46d018-93d4-44b4-921d-c8ebcdf336ac	903fc3ca-67b9-4e24-8310-97f0211dd5be	15372eae-1d2d-4d1b-af92-e71b76d3393e	\N	Late Arrival & Tow Rig Discrepancy	Flatbed recovery arrived 45 minutes beyond scheduled ETA window.	RESOLVED	E2E Resolution: Motorist and certified technician mutually agreed on final diagnostic adjustment.	2026-11-22 11:08:30.696	2026-11-22 11:06:32.24	2026-11-22 11:08:30.697
8f11ef5b-d1c2-4148-ba32-b37b12ba1211	c40214eb-b743-42e2-9395-9b268084330c	8ce31ba5-bfb6-4062-8788-1d55d758fd08	\N	Late Arrival & Tow Rig Discrepancy	Flatbed recovery arrived 45 minutes beyond scheduled ETA window.	RESOLVED	Traffic bottleneck verified on camera feed. Courtesy credit applied.	2026-11-22 11:25:32.95	2026-11-22 11:25:32.888	2026-11-22 11:25:32.952
dcd3c309-cb07-4dd8-bd43-d5f7cdb86f82	71a0e527-0076-48b3-b1d1-d458adef3aba	6108dc7f-6c15-4ee6-8a47-92ff7487b689	\N	Late Arrival & Tow Rig Discrepancy	Flatbed recovery arrived 45 minutes beyond scheduled ETA window.	RESOLVED	Traffic bottleneck verified on camera feed. Courtesy credit applied.	2026-11-22 11:36:38.979	2026-11-22 11:36:38.904	2026-11-22 11:36:38.983
142084f8-2ad0-42bb-9398-0fd57a7d20c5	0d5a0499-55d9-4794-bd0c-0b8547a88bb5	413f9c28-135a-41dc-9ae3-29f264612e2c	\N	Late Arrival & Tow Rig Discrepancy	Flatbed recovery arrived 45 minutes beyond scheduled ETA window.	RESOLVED	E2E Resolution: Motorist and certified technician mutually agreed on final diagnostic adjustment.	2026-11-22 15:47:44.63	2026-11-22 11:55:24.89	2026-11-22 15:47:44.63
\.


--
-- Data for Name: MechanicLocation; Type: TABLE DATA; Schema: public; Owner: vbrs_admin
--

COPY public."MechanicLocation" (id, "mechanicId", latitude, longitude, heading, speed, accuracy, "updatedAt") FROM stdin;
ff80dcfe-7e7c-412d-ab6f-123759812a0d	fce909a3-d9e9-465a-9888-a8f8c68db27a	0	0	\N	\N	\N	2026-11-22 09:07:24.002
9a55f300-16d0-443b-a87e-9d1b15574839	4556fadd-87e5-44d1-af2f-6b5225659fdf	0	0	\N	\N	\N	2026-11-22 09:08:01.458
6164366c-ca58-4b47-bed3-9348b0c8bcd1	7225b3bb-039c-482a-88a8-09b49bf1f425	0	0	\N	\N	\N	2026-11-22 09:12:41.079
4851cc07-51e6-41a3-ad8f-e2ff61027827	307f9202-3089-435d-9ac1-9bb56b31fd56	0	0	\N	\N	\N	2026-11-22 09:27:11.991
0f61d698-a3bc-442f-863f-f991851405c9	09df5c33-7e55-4f86-9636-87ee91f2c81a	0	0	\N	\N	\N	2026-11-22 09:44:11.95
f1d9f73c-5e7b-47df-a4d5-4902b4c24854	d7cfb7f8-4c34-4745-825f-632ec8dd00ad	0	0	\N	\N	\N	2026-11-22 09:45:05.868
5be5db86-d708-46b9-a3b6-74440470d4e4	c67c3eb8-2b39-44a9-8845-1ec234a4152f	0	0	\N	\N	\N	2026-11-22 09:45:40.724
a916343c-c423-44a2-bc71-78c49bbaacf8	71ad4aaa-62bd-42b7-b30b-6f08467d5e39	0	0	\N	\N	\N	2026-11-22 09:45:41.131
0b70d86c-2a58-427f-b367-3e3160456d43	82bf7363-8458-413c-8221-c2f33cfde016	0	0	\N	\N	\N	2026-11-22 09:58:36.892
22e73460-784f-4027-9a02-3171c1f4d02f	3361b30c-8faf-4e79-9f4c-701168af2069	41	-74	\N	\N	\N	2026-11-22 09:59:33.344
22c078a0-7315-413a-a5da-5361eba6e175	e11d2861-51e7-4f1b-9d3c-596ba5c6ba45	40.7135	-74.0055	180	25	3.5	2026-11-22 09:59:33.487
7d310a9b-3f55-4493-83ef-638a24acc330	9f94d7c5-8ecc-4c6b-b4cc-6f87579bebad	41	-74	\N	\N	\N	2026-11-22 10:00:36.907
8978161f-8bb8-4dfe-97e0-c063e82bb9f9	f7c85961-11eb-4bd0-a43c-78717392496c	40.7135	-74.0055	180	25	3.5	2026-11-22 10:00:37.005
730c792a-8507-4755-8f8d-60420d63b4d3	8498d36c-ee14-4ca2-9869-dc800e9117d3	41	-74	\N	\N	\N	2026-11-22 10:04:23.084
9cd3e7f7-c214-4bc6-a129-aed021454ae8	e480aef5-fc43-4db6-bc14-a589c85cc159	40.7135	-74.0055	180	25	3.5	2026-11-22 10:04:23.26
472d3f9d-95ec-4a3e-a800-38d9fe7b1e5f	2c5ce821-5884-40d5-af0d-5f526ccc38f3	0	0	\N	\N	\N	2026-11-22 10:04:24.267
7cd45ab2-4592-4c49-bc36-c7184ed63b5b	5fae4444-280b-4f5e-9f7d-1c144eb46eba	0	0	\N	\N	\N	2026-11-22 10:04:24.809
258c6b14-f795-4273-bc4a-7b2498d2a177	26862790-bdc3-4714-aa48-5991f7550785	40.7128	-74.006	\N	\N	\N	2026-11-22 10:14:48.926
c4715ce7-f61c-4453-acf5-e0eb8864ced5	2bd8c6e5-44ca-4c80-a6bb-2ddc2b6fe55e	37.7749	-122.4194	90	35	5	2026-11-22 10:27:34.765
aabdc50a-67c5-4eb5-87d2-f192fee57002	42f852f1-461c-48a4-984e-a3b0045eefa7	0	0	\N	\N	\N	2026-11-22 10:27:34.994
2b8e7407-3d84-4ca5-9db5-5f96be4d359b	723df3b7-5251-4293-a82b-1646a8ce2fc5	37.7749	-122.4194	90	35	5	2026-11-22 10:27:50.353
4f5824b7-1f5c-46d2-a5b8-88d8ff32087a	62c72e86-9b07-4e78-948d-ac30406b8dc6	0	0	\N	\N	\N	2026-11-22 10:27:50.601
8eca3e7e-3fca-48b0-b2d3-5c87736d3724	5dc1773f-a20b-4bc2-bed8-31c8ef41aec8	0	0	\N	\N	\N	2026-11-22 10:27:50.982
d41e0393-73c4-47ea-a11c-78217fbdc3b2	a3c9c018-f96c-4180-8416-6bf3044c207b	41	-74	\N	\N	\N	2026-11-22 10:27:51.136
5549d769-516b-431e-be56-c66a1f07e84f	e393a2d1-6039-4b1e-bd63-0fb5a0495ade	0	0	\N	\N	\N	2026-11-22 10:27:51.241
56e1a138-6ae9-454c-9a5a-6ee9a1936aca	695d4e72-2e32-45ab-8730-762885e4b76b	40.7135	-74.0055	180	25	3.5	2026-11-22 10:27:51.259
b28538b8-efbc-4c36-8fe8-00904a37675b	7fe31726-0593-4876-bf73-0d455ab53276	0	0	\N	\N	\N	2026-11-22 10:42:22.331
e3c89049-8f28-41ae-b8fe-2469e29830df	09a39c9c-7cf7-49f6-a130-40a8c0a1de53	0	0	\N	\N	\N	2026-11-22 10:42:22.586
69661560-39d1-4316-befe-164ce96ec01b	045a8bdf-4f76-411d-88e3-eb74d2e64fdd	41	-74	\N	\N	\N	2026-11-22 10:42:22.634
e8d3201b-aeb9-4a84-8276-939ef76ffb01	44d77d53-44ac-4dbd-b34c-964ec9926154	37.7749	-122.4194	90	35	5	2026-11-22 10:42:22.644
f7085bf9-4a0c-418b-8da3-b566081ce49b	f95c00f1-a886-4c05-9222-f50e52a5bff5	40.7135	-74.0055	180	25	3.5	2026-11-22 10:42:22.759
0860fd29-b0e6-4eb7-b255-d1a5b9d33da1	ddcf08a4-4e7e-4c4a-8de9-1024187a7fa4	0	0	\N	\N	\N	2026-11-22 10:42:22.899
ee885f80-c11a-4b2e-a71e-31985cef3c6c	0d1b1de5-fb9c-4c50-a6ea-9632c885d0d7	0	0	\N	\N	\N	2026-11-22 10:58:26.359
5857085f-9b4c-4cb9-9bc7-5db41e40a67f	0a61aad9-8b92-44d4-a3cc-1eb4ec5ad4a1	0	0	\N	\N	\N	2026-11-22 10:58:53.179
3251e50b-21fd-4c39-97f4-0766ff7f9650	c4fae49e-0427-418d-b5b7-030c3343c488	0	0	\N	\N	\N	2026-11-22 10:59:10.875
8a08e42c-41d2-44b8-8f33-271a0291a811	4ae57606-5752-4e04-a68a-2c0ed767d817	0	0	\N	\N	\N	2026-11-22 10:59:11.34
9afccda0-5153-4702-b827-2631829d96ee	bbf4ecf2-a44a-4e3d-ac30-e25dad9a7f5a	41	-74	\N	\N	\N	2026-11-22 10:59:11.699
6bfbb4b6-ddaf-47a4-ae7f-2a60b6b3cbcc	17480038-7a9e-4fb3-84a5-66e68816308a	0	0	\N	\N	\N	2026-11-22 10:59:11.727
0fc73b39-113d-41f0-b422-c6d2ffb0f3bf	60596275-9d97-4592-812b-ef52c5d5734a	37.7749	-122.4194	90	35	5	2026-11-22 10:59:11.736
3b3b7958-e8fe-4f0c-b028-9383b37bd402	a75ec860-72f8-4ab3-84f5-503a8ae57676	40.7135	-74.0055	180	25	3.5	2026-11-22 10:59:11.813
7e2ca13b-d9fa-4332-b73f-a6dacc0efc79	15de8912-b812-4f41-a847-2b114d96e37a	0	0	\N	\N	\N	2026-11-22 10:59:11.986
b56353d9-7713-424a-898d-a24d14f2899d	6ee92a8c-3e18-4605-ade9-75432643754b	0	0	\N	\N	\N	2026-11-22 11:06:31.848
886c470f-e5ee-4c7b-b34a-6bbac99adcf4	772e7702-913f-44cc-8c7e-3444b6741f61	37.7749	-122.4194	90	35	5	2026-11-22 11:06:32.016
84064544-be3d-4e01-a8f9-fa05bcee259b	f8443f55-88f4-4b67-83f3-8b0f165bcf8b	41	-74	\N	\N	\N	2026-11-22 11:06:32.043
ec4bbb28-6316-4f6f-ac8a-efcfd5335895	ca24de3e-f5f6-4277-8d98-0c3959824412	0	0	\N	\N	\N	2026-11-22 11:06:32.083
738c50c4-0624-4620-823a-2928b031f2b5	0ca9453b-5b38-4fbc-b2e4-366255563963	0	0	\N	\N	\N	2026-11-22 11:06:32.153
918ff638-c05c-41e1-912d-d08435e13e95	fd3e3a5e-79bc-4b18-9e45-c7dde1a28efe	40.7135	-74.0055	180	25	3.5	2026-11-22 11:06:32.2
b3238070-3a8c-400e-8998-f2b5000255de	9224268f-1791-45ee-a424-2a498ddb5dcf	0	0	\N	\N	\N	2026-11-22 11:06:32.29
36fc2036-389c-409d-b54f-c5543df9e968	52a3ee19-9abe-4204-bd13-3a2935acbb9e	0	0	\N	\N	\N	2026-11-22 11:24:43.102
52505981-5a0c-41aa-b076-a18eb5a8039f	75f044c3-f5b8-4bd8-acf9-e6ad9535b56c	0	0	\N	\N	\N	2026-11-22 11:25:10.594
9f43a858-5617-4aab-b0c5-1bccaa96d1c0	999b01aa-2778-4a6d-8a8d-174220f8ecb5	0	0	\N	\N	\N	2026-11-22 11:25:31.946
26628d67-9e33-41f5-9934-bbaa5cd6d36a	dc6f4f7e-a53f-4614-8187-9a132b20eb39	0	0	\N	\N	\N	2026-11-22 11:25:32.68
f7ec1553-804f-4715-b2dc-8047a950fbe3	799af39d-d7c2-42fe-8ac6-ad420e107247	0	0	\N	\N	\N	2026-11-22 11:25:32.76
175c1a66-4d98-4753-a105-ccb65d7dc54d	9ed08001-ef90-4dec-9ec9-97fd04ba6037	37.7749	-122.4194	90	35	5	2026-11-22 11:25:32.784
d1d0091c-f2d1-4d31-a179-f1584d56c9dd	67e2385a-b713-4d5a-bb05-3a1014c8cb8d	0	0	\N	\N	\N	2026-11-22 11:25:32.805
d1e5da9b-1be9-45de-b993-34bde3ae02ac	aa7c06fb-61a0-4c00-a555-0042c6af990b	40.7135	-74.0055	180	25	3.5	2026-11-22 11:25:32.982
d06a6236-536f-4685-b5fe-9e3584eed5d3	7f6ed720-881a-402d-9e49-991bec251060	0	0	\N	\N	\N	2026-11-22 11:25:33.053
ec1dd792-6240-4036-a553-b61f14578a2b	4e58038a-ac77-46dd-bf6c-aa8c6e722463	41	-74	\N	\N	\N	2026-11-22 11:25:32.849
b4914317-9282-4825-9270-dd8bc1129b9b	e2419fa2-50ef-4df5-b4d4-a88a559dc507	0	0	\N	\N	\N	2026-11-22 11:36:38.505
d82934af-b140-43e7-b04c-38b0d83a98f1	85c362bd-919d-4514-b93d-20d8a05d38f9	0	0	\N	\N	\N	2026-11-22 11:36:38.76
4ea8cfcb-c86b-4351-8d7a-1a4aec9daa86	2c562b7b-1e07-4e32-a8ef-12d935fe25e4	37.7749	-122.4194	90	35	5	2026-11-22 11:36:38.823
917eba64-ee88-4451-b82c-f480ab9c4801	589cd51a-0952-445a-98ce-8b00ad9d3e44	0	0	\N	\N	\N	2026-11-22 11:36:38.851
57d48c82-3606-4b49-b826-1df6cd450a5c	264cdbad-2eec-4e0c-9c8e-56151a595944	0	0	\N	\N	\N	2026-11-22 11:36:38.873
6e2a4589-0978-4f8e-b54d-1831d9bca63d	9ec3c918-b4b3-466c-8880-6dbc3eeddfd5	41	-74	\N	\N	\N	2026-11-22 11:36:38.942
793421a6-e765-4daa-89ea-ea28129e68f2	7ceb1f55-7d15-42cc-b366-610d301d023d	40.7135	-74.0055	180	25	3.5	2026-11-22 11:36:39.101
c4f2c6d8-cf9f-4ab1-a5c6-f3eac7cda432	1ca55cfe-e2e4-4d70-87de-01bc62bc07b1	0	0	\N	\N	\N	2026-11-22 11:36:39.11
54759c5c-84b5-4951-a69e-bfe60fe34a6b	e93ba894-c5f7-4715-ade0-9b222e46e868	0	0	\N	\N	\N	2026-11-22 11:52:11.856
41da5ade-8cd7-4655-a061-fd593fb10dd8	306e4439-36f7-4a8b-95b6-068c4ab64e68	0	0	\N	\N	\N	2026-11-22 11:52:51.854
eaa8112f-71f1-4a5a-8e94-5aa2554ca2e7	4b4c87fe-5d9c-4011-ba3e-28ab12af2738	0	0	\N	\N	\N	2026-11-22 11:55:24.27
91034774-dc80-4c1f-8d4c-cf43dde63cd1	26a6a314-dba2-4b11-b975-81ddcf76ef3a	37.7749	-122.4194	90	35	5	2026-11-22 11:55:24.535
b1fec39d-343b-4cbf-948b-36be60e8346c	16b772d1-97e6-4cf9-a933-2ed1804a2f26	0	0	\N	\N	\N	2026-11-22 11:55:24.61
86a08633-4de4-4374-8ef0-beeae6635b80	cd8b1c9a-c59b-4abd-bd30-45764e35606d	0	0	\N	\N	\N	2026-11-22 11:55:24.627
a8e0947e-f486-447c-a86c-48a376f6906e	c33b4cb1-243d-473c-96e3-fb84e9177513	41	-74	\N	\N	\N	2026-11-22 11:55:24.689
6f233343-5495-4dc2-905b-9ce8cf56bb40	243c49ee-6224-4c57-95ee-8b9a7367ed63	0	0	\N	\N	\N	2026-11-22 11:55:24.69
a60673a4-e700-4e6a-afab-32ddc6301c6d	c9051638-c88a-4e64-92f9-215e1db40cbe	0	0	\N	\N	\N	2026-11-22 11:55:24.719
72da0293-a849-4d9d-82c8-d989d1213959	b6caff1d-1517-4114-8d4d-87fd03ac1b0d	0	0	\N	\N	\N	2026-11-22 11:55:24.815
364ef714-7fb1-420e-8ba1-9bad5176c083	56596f10-d230-44c3-b5b0-a52fcc7a0302	40.7135	-74.0055	180	25	3.5	2026-11-22 11:55:24.847
17bb457f-1264-4b4a-a47a-564c42776ada	c64cf11c-7971-413a-bcc2-b4496909ccc1	0	0	\N	\N	\N	2026-11-22 12:56:22.65
763bf845-baca-49f6-a41e-1b98eca88d49	25b004b4-75c9-445e-b00e-381f6924e7fc	37.7749	-122.4194	90	35	5	2026-11-22 13:04:37.004
ac497d25-4995-45ed-a4ab-92f64bd444f1	76b65f56-71f5-430b-8bd9-38c1f239f7f4	41	-74	\N	\N	\N	2026-11-22 13:04:37.052
34b86b8a-509c-4929-b31d-8393a119e3ac	1289d317-4894-4f30-b510-b726e68fd866	40.7135	-74.0055	180	25	3.5	2026-11-22 13:04:37.165
cad85383-97e5-49b1-a89b-dd7dc713fd81	d4d7570a-71a9-49fd-acf8-21fda3d7f48e	0	0	\N	\N	\N	2026-11-22 13:04:37.238
8714026e-de86-4003-b8f5-5190167dc5e2	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	16.354216	80.52963	\N	\N	82	2026-11-22 13:45:12.641
\.


--
-- Data for Name: MechanicProfile; Type: TABLE DATA; Schema: public; Owner: vbrs_admin
--

COPY public."MechanicProfile" (id, "userId", "workshopName", "tradeLicenseNumber", "experienceYears", "verificationStatus", "verificationNotes", "availabilityStatus", "operatingRadiusKm", "ratingAverage", "totalReviews", "totalJobsCompleted", "documentUrl", "createdAt", "updatedAt", bio, certifications, specializations, "workshopAddress") FROM stdin;
c64cf11c-7971-413a-bcc2-b4496909ccc1	6a574d53-ad46-4c43-b3d2-054578f0fbbe	Audit Precision Garage	ASE-MASTER-9988	8	REJECTED	\N	OFFLINE	25	0	0	0	\N	2026-11-22 12:56:22.646	2026-11-22 15:50:42.227	\N	{}	{}	\N
52a3ee19-9abe-4204-bd13-3a2935acbb9e	f94f9477-bc05-46e6-b444-9bb14d4ce5da	David Sterling's Roadside Service	\N	1	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 11:24:43.099	2026-11-22 12:00:39.444	\N	{}	{}	\N
bbf4ecf2-a44a-4e3d-ac30-e25dad9a7f5a	14397d2c-11bd-4647-babe-a86165af58d4	Far Hills Rescue Inc	\N	8	APPROVED	\N	AVAILABLE	20	0	0	0	\N	2026-11-22 10:59:11.685	2026-11-22 12:00:39.444	\N	{}	{}	\N
17480038-7a9e-4fb3-84a5-66e68816308a	e840f0bf-ae92-4006-aa6a-de7fc0c1873d	Edge Precision Garage	\N	7	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 10:59:11.724	2026-11-22 12:00:39.444	\N	{}	{}	\N
6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	473401ce-0803-422f-8baa-a47de557f84e	Apex Precision Motors M8	LIC-AUDIT-1795356768507	12	PENDING	Trade license modified to "LIC-AUDIT-1795356768507". Pending administrative credential audit.	AVAILABLE	35	5	3	71	/uploads/cert_alex.pdf	2026-11-22 06:59:47.735	2026-11-22 14:12:48.547	\N	{}	{"High-Voltage EV Powertrains"}	\N
9224268f-1791-45ee-a424-2a498ddb5dcf	af870543-67bd-4053-a056-9cb0328c528c	Grey Roadside Ops	\N	1	APPROVED	E2E Audit Verification: Trade license and ASE certifications verified with state registry.	AVAILABLE	25	0	0	0	\N	2026-11-22 11:06:32.288	2026-11-22 12:00:39.444	\N	{}	{}	\N
6ee92a8c-3e18-4605-ade9-75432643754b	4d62bb62-77c2-48f9-8e07-3e9ea0a6a73d	Audit Precision Garage	ASE-MASTER-9988	8	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 11:06:31.844	2026-11-22 12:00:39.444	\N	{}	{}	\N
75f044c3-f5b8-4bd8-acf9-e6ad9535b56c	5db3fe47-163f-4f45-82a3-256bc87a79b2	Sterling Diagnostic Lab	ASE-M7-1795346709879	1	APPROVED	\N	AVAILABLE	40	4	2	5	\N	2026-11-22 11:25:10.592	2026-11-22 12:00:39.444	\N	{}	{}	\N
f8443f55-88f4-4b67-83f3-8b0f165bcf8b	3ea42b7f-99a0-4120-991f-7047bbb58050	Far Hills Rescue Inc	\N	8	APPROVED	\N	AVAILABLE	20	0	0	0	\N	2026-11-22 11:06:32.03	2026-11-22 12:00:39.444	\N	{}	{}	\N
0ca9453b-5b38-4fbc-b2e4-366255563963	44add884-dad8-4e5a-a51f-c16a642f3873	Edge Precision Garage	\N	7	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 11:06:32.149	2026-11-22 12:00:39.444	\N	{}	{}	\N
999b01aa-2778-4a6d-8a8d-174220f8ecb5	b7cff01c-2936-4856-8de7-e2f1049987f0	Sterling Diagnostic Lab	ASE-M7-1795346731082	1	APPROVED	\N	AVAILABLE	40	4	2	5	\N	2026-11-22 11:25:31.942	2026-11-22 12:00:39.444	\N	{}	{}	\N
ca24de3e-f5f6-4277-8d98-0c3959824412	6b36993f-4add-41d2-aa57-89b13b0ed876	Moss Specialized Mobile Workshop	ASE-MASTER-88391	7	APPROVED	ASE Master Certificate #88391 confirmed valid with State Board.	AVAILABLE	25	0	0	0	\N	2026-11-22 11:06:32.077	2026-11-22 12:00:39.444	\N	{}	{}	\N
fd3e3a5e-79bc-4b18-9e45-c7dde1a28efe	29db8df8-1b56-42f1-9da5-e687727e448e	Downtown Elite Precision	\N	12	APPROVED	\N	AVAILABLE	30	0	0	0	\N	2026-11-22 11:06:31.723	2026-11-22 12:00:39.444	\N	{}	{}	\N
dc6f4f7e-a53f-4614-8187-9a132b20eb39	7d5c1d7c-e190-4cd7-a73d-a3b2d317422c	Audit Precision Garage	ASE-MASTER-9988	8	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 11:25:32.677	2026-11-22 12:00:39.444	\N	{}	{}	\N
772e7702-913f-44cc-8c7e-3444b6741f61	91e6be61-ca06-4bb8-9843-38b5edc72e0b	Hunt High-Performance Roadside	\N	1	APPROVED	\N	AVAILABLE	30	0	0	1	\N	2026-11-22 11:06:31.997	2026-11-22 12:00:39.444	\N	{}	{}	\N
67e2385a-b713-4d5a-bb05-3a1014c8cb8d	8890fb8f-a65c-4c1e-90cd-cb9d063b7634	Edge Precision Garage	\N	7	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 11:25:32.802	2026-11-22 12:00:39.444	\N	{}	{}	\N
4e58038a-ac77-46dd-bf6c-aa8c6e722463	599a1a84-5e64-44df-acaa-8e4c4e40cae3	Far Hills Rescue Inc	\N	8	APPROVED	\N	AVAILABLE	20	0	0	0	\N	2026-11-22 11:25:32.833	2026-11-22 12:00:39.444	\N	{}	{}	\N
799af39d-d7c2-42fe-8ac6-ad420e107247	383ded7b-56cc-4419-8926-25fc9318ea0a	Moss Specialized Mobile Workshop	ASE-MASTER-88391	7	APPROVED	ASE Master Certificate #88391 confirmed valid with State Board.	AVAILABLE	25	0	0	0	\N	2026-11-22 11:25:32.757	2026-11-22 12:00:39.444	\N	{}	{}	\N
7f6ed720-881a-402d-9e49-991bec251060	32246199-32b0-4a1c-a009-c51b0345f9e5	Grey Roadside Ops	\N	1	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 11:25:33.051	2026-11-22 12:00:39.444	\N	{}	{}	\N
aa7c06fb-61a0-4c00-a555-0042c6af990b	f7687de7-1987-44af-85d9-9fcc9f286770	Downtown Elite Precision	\N	12	APPROVED	\N	AVAILABLE	30	0	0	0	\N	2026-11-22 11:25:32.562	2026-11-22 12:00:39.444	\N	{}	{}	\N
9ed08001-ef90-4dec-9ec9-97fd04ba6037	b6225e12-d48c-4709-97d5-6be7b6ef360d	Hunt High-Performance Roadside	\N	1	APPROVED	\N	AVAILABLE	30	0	0	1	\N	2026-11-22 11:25:32.767	2026-11-22 12:00:39.444	\N	{}	{}	\N
e2419fa2-50ef-4df5-b4d4-a88a559dc507	afe64e04-d47c-4aff-97a5-498252ffd13a	Audit Precision Garage	ASE-MASTER-9988	8	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 11:36:38.501	2026-11-22 12:00:39.444	\N	{}	{}	\N
264cdbad-2eec-4e0c-9c8e-56151a595944	9d5010e7-020c-41ba-81ac-6b878a91889e	Edge Precision Garage	\N	7	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 11:36:38.87	2026-11-22 12:00:39.444	\N	{}	{}	\N
85c362bd-919d-4514-b93d-20d8a05d38f9	b0bcbe4c-6c84-4113-a38b-62338ce06d8d	Moss Specialized Mobile Workshop	ASE-MASTER-88391	7	APPROVED	ASE Master Certificate #88391 confirmed valid with State Board.	AVAILABLE	25	0	0	0	\N	2026-11-22 11:36:38.756	2026-11-22 12:00:39.444	\N	{}	{}	\N
9ec3c918-b4b3-466c-8880-6dbc3eeddfd5	b49fbfc0-75b1-4417-9a7b-b2b55bb451d6	Far Hills Rescue Inc	\N	8	APPROVED	\N	AVAILABLE	20	0	0	0	\N	2026-11-22 11:36:38.919	2026-11-22 12:00:39.444	\N	{}	{}	\N
1ca55cfe-e2e4-4d70-87de-01bc62bc07b1	da494868-688f-4802-823a-432be9bc80b5	Grey Roadside Ops	\N	1	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 11:36:39.109	2026-11-22 12:00:39.444	\N	{}	{}	\N
589cd51a-0952-445a-98ce-8b00ad9d3e44	3fab570e-2937-4fe4-8e48-b6bc7ba4b2f0	Sterling Diagnostic Lab	ASE-M7-1795347398006	1	APPROVED	\N	AVAILABLE	40	4	2	5	\N	2026-11-22 11:36:38.849	2026-11-22 12:00:39.444	\N	{}	{}	\N
7ceb1f55-7d15-42cc-b366-610d301d023d	13608b64-3065-4aea-99b6-4633b454b56d	Downtown Elite Precision	\N	12	APPROVED	\N	AVAILABLE	30	0	0	0	\N	2026-11-22 11:36:38.63	2026-11-22 12:00:39.444	\N	{}	{}	\N
2c562b7b-1e07-4e32-a8ef-12d935fe25e4	6fce9f62-804c-480a-ba62-c337fa44ace7	Hunt High-Performance Roadside	\N	1	APPROVED	\N	AVAILABLE	30	0	0	1	\N	2026-11-22 11:36:38.802	2026-11-22 12:00:39.444	\N	{}	{}	\N
306e4439-36f7-4a8b-95b6-068c4ab64e68	d8815573-617c-4a9f-a950-507542203e55	Charlie Mechanic's Roadside Service	\N	1	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 11:52:51.851	2026-11-22 12:00:39.444	\N	{}	{}	\N
4b4c87fe-5d9c-4011-ba3e-28ab12af2738	cf2a50da-6587-4cf0-8fbf-fbbd1a6474a4	Audit Precision Garage	ASE-MASTER-9988	8	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 11:55:24.268	2026-11-22 12:00:39.444	\N	{}	{}	\N
e93ba894-c5f7-4715-ade0-9b222e46e868	a62fc8d6-66ce-471b-b268-b23c2051f9f1	Charlie Mechanic's Roadside Service	\N	1	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 11:52:11.854	2026-11-22 12:00:39.444	\N	{}	{}	\N
16b772d1-97e6-4cf9-a933-2ed1804a2f26	94ae7a86-4904-4f65-be33-bcd6730fcb95	Edge Precision Garage	\N	7	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 11:55:24.607	2026-11-22 12:00:39.444	\N	{}	{}	\N
cd8b1c9a-c59b-4abd-bd30-45764e35606d	62b2d075-5944-43e7-89a8-26146484ab12	Charlie Mechanic's Roadside Service	\N	1	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 11:55:24.623	2026-11-22 12:00:39.444	\N	{}	{}	\N
c33b4cb1-243d-473c-96e3-fb84e9177513	d3900c77-40a4-4e6e-8255-038d9aed2a21	Far Hills Rescue Inc	\N	8	APPROVED	\N	AVAILABLE	20	0	0	0	\N	2026-11-22 11:55:24.672	2026-11-22 12:00:39.444	\N	{}	{}	\N
56596f10-d230-44c3-b5b0-a52fcc7a0302	0c0768ce-b175-46fb-8444-26488c274cba	Downtown Elite Precision	\N	12	APPROVED	\N	AVAILABLE	30	0	0	0	\N	2026-11-22 11:55:24.375	2026-11-22 12:00:39.444	\N	{}	{}	\N
26a6a314-dba2-4b11-b975-81ddcf76ef3a	93379134-a271-44fa-bf5a-314fe8520bca	Hunt High-Performance Roadside	\N	1	APPROVED	\N	AVAILABLE	30	0	0	1	\N	2026-11-22 11:55:24.515	2026-11-22 12:00:39.444	\N	{}	{}	\N
c9051638-c88a-4e64-92f9-215e1db40cbe	e50326f1-92b0-4149-ab38-88e681b1037c	Moss Specialized Mobile Workshop	ASE-MASTER-88391	7	APPROVED	ASE Master Certificate #88391 confirmed valid with State Board.	AVAILABLE	25	0	0	0	\N	2026-11-22 11:55:24.715	2026-11-22 12:00:39.444	\N	{}	{}	\N
243c49ee-6224-4c57-95ee-8b9a7367ed63	8bc999de-3d28-4b57-af72-a5c2e2ac6dab	Sterling Diagnostic Lab	ASE-M7-1795348523820	1	APPROVED	\N	AVAILABLE	40	4	2	5	\N	2026-11-22 11:55:24.687	2026-11-22 12:00:39.444	\N	{}	{}	\N
76b65f56-71f5-430b-8bd9-38c1f239f7f4	3b2178a5-100c-422e-96c5-992e3283239f	Far Hills Rescue Inc	\N	8	APPROVED	\N	AVAILABLE	20	0	0	0	\N	2026-11-22 13:04:37.038	2026-11-22 13:04:37.049	\N	{}	{}	\N
1289d317-4894-4f30-b510-b726e68fd866	93c9a1ba-11fc-41ef-bc41-0bba5b0a0634	Downtown Elite Precision	\N	12	APPROVED	\N	ON_JOB	30	0	0	0	\N	2026-11-22 13:04:36.785	2026-11-22 13:04:37.301	\N	{}	{}	\N
fce909a3-d9e9-465a-9888-a8f8c68db27a	f497148d-d3c5-45be-b500-72020fd86949	Audit Precision Garage	ASE-MASTER-9988	8	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 09:07:23.999	2026-11-22 12:00:39.444	\N	{}	{}	\N
4556fadd-87e5-44d1-af2f-6b5225659fdf	b7eed690-1ed3-46ed-882a-8ff0ca54af9d	Audit Precision Garage	ASE-MASTER-9988	8	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 09:08:01.455	2026-11-22 12:00:39.444	\N	{}	{}	\N
7225b3bb-039c-482a-88a8-09b49bf1f425	0579580b-0d74-488f-9878-c209546a5c2e	Audit Precision Garage	ASE-MASTER-9988	8	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 09:12:41.075	2026-11-22 12:00:39.444	\N	{}	{}	\N
307f9202-3089-435d-9ac1-9bb56b31fd56	abe634c7-837c-4fc9-8d62-af59c97d8fd7	Audit Precision Garage	ASE-MASTER-9988	8	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 09:27:11.988	2026-11-22 12:00:39.444	\N	{}	{}	\N
09df5c33-7e55-4f86-9636-87ee91f2c81a	c7966587-138d-4fb6-a6d9-b638c3646f4c	Edge Precision Garage	\N	7	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 09:44:11.946	2026-11-22 12:00:39.444	\N	{}	{}	\N
d7cfb7f8-4c34-4745-825f-632ec8dd00ad	29b31365-442a-4af5-9665-541885e6c2ad	Edge Precision Garage	\N	7	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 09:45:05.865	2026-11-22 12:00:39.444	\N	{}	{}	\N
c67c3eb8-2b39-44a9-8845-1ec234a4152f	2eca2933-96e6-4fa7-bda8-a1d0479de90c	Audit Precision Garage	ASE-MASTER-9988	8	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 09:45:40.719	2026-11-22 12:00:39.444	\N	{}	{}	\N
71ad4aaa-62bd-42b7-b30b-6f08467d5e39	ebf4e83b-ea5a-4e92-bf15-8c58e0b49d3b	Edge Precision Garage	\N	7	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 09:45:41.127	2026-11-22 12:00:39.444	\N	{}	{}	\N
82bf7363-8458-413c-8221-c2f33cfde016	23dfa73c-7d5b-46cb-a1f1-cfe57a65b3db	Downtown Rapid Roadside	\N	10	APPROVED	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 09:58:36.888	2026-11-22 12:00:39.444	\N	{}	{}	\N
3361b30c-8faf-4e79-9f4c-701168af2069	f69dd74f-2981-40af-9eea-5269a5fa8340	Far Hills Rescue Inc	\N	8	APPROVED	\N	AVAILABLE	20	0	0	0	\N	2026-11-22 09:59:33.328	2026-11-22 12:00:39.444	\N	{}	{}	\N
e11d2861-51e7-4f1b-9d3c-596ba5c6ba45	838cdf88-b812-44c0-a890-3e53d54aafe1	Downtown Elite Precision	\N	12	APPROVED	\N	AVAILABLE	30	0	0	0	\N	2026-11-22 09:59:32.95	2026-11-22 12:00:39.444	\N	{}	{}	\N
9f94d7c5-8ecc-4c6b-b4cc-6f87579bebad	6d34d30f-9a1e-492c-9781-a28cf649ca03	Far Hills Rescue Inc	\N	8	APPROVED	\N	AVAILABLE	20	0	0	0	\N	2026-11-22 10:00:36.893	2026-11-22 12:00:39.444	\N	{}	{}	\N
7fe31726-0593-4876-bf73-0d455ab53276	17f8c042-b632-48cf-8e97-53a057ab03fd	Audit Precision Garage	ASE-MASTER-9988	8	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 10:42:22.328	2026-11-22 12:00:39.444	\N	{}	{}	\N
09a39c9c-7cf7-49f6-a130-40a8c0a1de53	885f49f3-4df5-48f9-aeaf-9e7b29015b02	Edge Precision Garage	\N	7	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 10:42:22.583	2026-11-22 12:00:39.444	\N	{}	{}	\N
f7c85961-11eb-4bd0-a43c-78717392496c	8aeefd6a-535e-4b26-9fb5-74c9ac6e26c3	Downtown Elite Precision	\N	12	APPROVED	\N	AVAILABLE	30	0	0	0	\N	2026-11-22 10:00:36.642	2026-11-22 12:00:39.444	\N	{}	{}	\N
045a8bdf-4f76-411d-88e3-eb74d2e64fdd	568f1967-6055-40f4-bd07-97ee79559948	Far Hills Rescue Inc	\N	8	APPROVED	\N	AVAILABLE	20	0	0	0	\N	2026-11-22 10:42:22.617	2026-11-22 12:00:39.444	\N	{}	{}	\N
f95c00f1-a886-4c05-9222-f50e52a5bff5	6dffcd9a-0d48-4863-a865-8f96c2680bf5	Downtown Elite Precision	\N	12	APPROVED	\N	AVAILABLE	30	0	0	0	\N	2026-11-22 10:42:22.348	2026-11-22 12:00:39.444	\N	{}	{}	\N
8498d36c-ee14-4ca2-9869-dc800e9117d3	71be654d-8646-43a1-985d-0f9757ec84b7	Far Hills Rescue Inc	\N	8	APPROVED	\N	AVAILABLE	20	0	0	0	\N	2026-11-22 10:04:23.064	2026-11-22 12:00:39.444	\N	{}	{}	\N
ddcf08a4-4e7e-4c4a-8de9-1024187a7fa4	754478bf-6a8e-4cc5-9aa9-f783e59d909a	Grey Roadside Ops	\N	1	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 10:42:22.897	2026-11-22 12:00:39.444	\N	{}	{}	\N
e480aef5-fc43-4db6-bc14-a589c85cc159	3508ead1-81a7-4452-a2f1-fd5599a1f576	Downtown Elite Precision	\N	12	APPROVED	\N	AVAILABLE	30	0	0	0	\N	2026-11-22 10:04:22.617	2026-11-22 12:00:39.444	\N	{}	{}	\N
2c5ce821-5884-40d5-af0d-5f526ccc38f3	be6ce21c-27af-4c83-838d-9252f2ed8b52	Audit Precision Garage	ASE-MASTER-9988	8	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 10:04:24.264	2026-11-22 12:00:39.444	\N	{}	{}	\N
5fae4444-280b-4f5e-9f7d-1c144eb46eba	a40c3731-4a5e-4537-8dc4-3d81ed50c82e	Edge Precision Garage	\N	7	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 10:04:24.806	2026-11-22 12:00:39.444	\N	{}	{}	\N
44d77d53-44ac-4dbd-b34c-964ec9926154	fd109b4c-5829-497b-8da6-252d426b4a4d	Hunt High-Performance Roadside	\N	1	APPROVED	\N	AVAILABLE	30	0	0	1	\N	2026-11-22 10:42:22.626	2026-11-22 12:00:39.444	\N	{}	{}	\N
0d1b1de5-fb9c-4c50-a6ea-9632c885d0d7	912d1cb2-475d-4b50-8a70-7c6efd34617e	Moss Specialized Mobile Workshop	ASE-MASTER-88391	7	APPROVED	ASE Master Certificate #88391 confirmed valid with State Board.	AVAILABLE	25	0	0	0	\N	2026-11-22 10:58:26.356	2026-11-22 12:00:39.444	\N	{}	{}	\N
0a61aad9-8b92-44d4-a3cc-1eb4ec5ad4a1	6f799c5a-2d5d-417b-9baa-f7b0c803557a	Moss Specialized Mobile Workshop	ASE-MASTER-88391	7	APPROVED	ASE Master Certificate #88391 confirmed valid with State Board.	AVAILABLE	25	0	0	0	\N	2026-11-22 10:58:53.176	2026-11-22 12:00:39.444	\N	{}	{}	\N
26862790-bdc3-4714-aa48-5991f7550785	20c92ae9-cda7-4be7-a444-d9ec67df8fbc	Sterling Heavy Towing & Roadside	TOW-NJ-48821	8	APPROVED	Flatbed tow truck operator certified.	AVAILABLE	50	4.7	18	42	/uploads/cert_marcus.pdf	2026-11-22 06:59:47.754	2026-11-22 12:00:39.444	\N	{}	{}	\N
c4fae49e-0427-418d-b5b7-030c3343c488	6f863f00-571b-44cc-a075-aa555329997f	Moss Specialized Mobile Workshop	ASE-MASTER-88391	7	APPROVED	ASE Master Certificate #88391 confirmed valid with State Board.	AVAILABLE	25	0	0	0	\N	2026-11-22 10:59:10.871	2026-11-22 12:00:39.444	\N	{}	{}	\N
4ae57606-5752-4e04-a68a-2c0ed767d817	c1c59c54-9a85-4892-957a-65df00abe10f	Audit Precision Garage	ASE-MASTER-9988	8	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 10:59:11.338	2026-11-22 12:00:39.444	\N	{}	{}	\N
42f852f1-461c-48a4-984e-a3b0045eefa7	99cb03ac-7b72-4f0c-bb2f-b153c954e67b	Grey Roadside Ops	\N	1	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 10:27:34.993	2026-11-22 12:00:39.444	\N	{}	{}	\N
2bd8c6e5-44ca-4c80-a6bb-2ddc2b6fe55e	8ad6b40d-ab52-471f-b6dc-4dcc2d132efe	Hunt High-Performance Roadside	\N	1	APPROVED	\N	AVAILABLE	30	0	0	1	\N	2026-11-22 10:27:34.747	2026-11-22 12:00:39.444	\N	{}	{}	\N
62c72e86-9b07-4e78-948d-ac30406b8dc6	90810c7b-ed32-4e65-993f-2371c000eb9b	Grey Roadside Ops	\N	1	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 10:27:50.6	2026-11-22 12:00:39.444	\N	{}	{}	\N
5dc1773f-a20b-4bc2-bed8-31c8ef41aec8	29c945b2-a680-4d39-9f8d-ee67d94c8272	Audit Precision Garage	ASE-MASTER-9988	8	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 10:27:50.98	2026-11-22 12:00:39.444	\N	{}	{}	\N
a75ec860-72f8-4ab3-84f5-503a8ae57676	459fd1f2-01ce-465d-b584-90ce7e7c8297	Downtown Elite Precision	\N	12	APPROVED	\N	AVAILABLE	30	0	0	0	\N	2026-11-22 10:59:11.424	2026-11-22 12:00:39.444	\N	{}	{}	\N
a3c9c018-f96c-4180-8416-6bf3044c207b	92ec996c-90a3-4cd5-a1bf-0861cd595b15	Far Hills Rescue Inc	\N	8	APPROVED	\N	AVAILABLE	20	0	0	0	\N	2026-11-22 10:27:51.122	2026-11-22 12:00:39.444	\N	{}	{}	\N
e393a2d1-6039-4b1e-bd63-0fb5a0495ade	7407b151-116c-44be-bd28-20d2ea8e9da2	Edge Precision Garage	\N	7	PENDING	\N	AVAILABLE	25	0	0	0	\N	2026-11-22 10:27:51.238	2026-11-22 12:00:39.444	\N	{}	{}	\N
723df3b7-5251-4293-a82b-1646a8ce2fc5	58ea9816-d0a5-42ae-92d8-55f32ab1135f	Hunt High-Performance Roadside	\N	1	APPROVED	\N	AVAILABLE	30	0	0	1	\N	2026-11-22 10:27:50.328	2026-11-22 12:00:39.444	\N	{}	{}	\N
695d4e72-2e32-45ab-8730-762885e4b76b	ab64f7e0-5ae5-4282-826f-e08e48227f23	Downtown Elite Precision	\N	12	APPROVED	\N	AVAILABLE	30	0	0	0	\N	2026-11-22 10:27:50.849	2026-11-22 12:00:39.444	\N	{}	{}	\N
60596275-9d97-4592-812b-ef52c5d5734a	04a4b6cb-3c82-45bb-acab-d78e0713971a	Hunt High-Performance Roadside	\N	1	APPROVED	\N	AVAILABLE	30	0	0	1	\N	2026-11-22 10:59:11.719	2026-11-22 12:00:39.444	\N	{}	{}	\N
15de8912-b812-4f41-a847-2b114d96e37a	d3f75e7f-79cd-4f70-8bf5-d71a46c0c651	Grey Roadside Ops	\N	1	APPROVED	E2E Audit Verification: Trade license and ASE certifications verified with state registry.	AVAILABLE	25	0	0	0	\N	2026-11-22 10:59:11.984	2026-11-22 12:00:39.444	\N	{}	{}	\N
b6caff1d-1517-4114-8d4d-87fd03ac1b0d	4469db4e-5fa2-4654-a406-28cdc4c47994	Grey Roadside Ops	\N	1	APPROVED	E2E Audit Verification: Trade license and ASE certifications verified with state registry.	AVAILABLE	25	0	0	0	\N	2026-11-22 11:55:24.813	2026-11-22 12:04:27.878	\N	{}	{}	\N
25b004b4-75c9-445e-b00e-381f6924e7fc	fc725f56-3a5d-4cfb-ae3a-285db185f44e	Hunt High-Performance Roadside	\N	1	APPROVED	\N	AVAILABLE	30	0	0	1	\N	2026-11-22 13:04:36.985	2026-11-22 13:04:37.882	\N	{}	{}	\N
d4d7570a-71a9-49fd-acf8-21fda3d7f48e	38d387dd-e06f-4ea0-9155-587eb1ec7a7c	Grey Roadside Ops	\N	1	APPROVED	\N	OFFLINE	25	0	0	0	\N	2026-11-22 13:04:37.236	2026-11-22 15:49:39.142	\N	{}	{}	\N
\.


--
-- Data for Name: MechanicService; Type: TABLE DATA; Schema: public; Owner: vbrs_admin
--

COPY public."MechanicService" (id, "mechanicId", category, "priceEstimateMin", "priceEstimateMax", description, "createdAt") FROM stdin;
0a992a92-b061-4f6c-9de1-55505742b06c	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	ENGINE_FAILURE	80	250	Engine diagnostics, belt replacement, sensor swaps	2026-11-22 06:59:47.744
f45bd43b-c429-4898-af9a-477514379d15	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	BATTERY_DEAD_ELECTRICAL	45	120	Jump start, alternator testing, battery replacement	2026-11-22 06:59:47.744
9ce1a668-7b35-43f7-acf0-bf89e447f2e7	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	FLAT_TIRE_WHEEL	35	80	Tire repair, spare tire installation	2026-11-22 06:59:47.744
da4ecfc3-c7b6-4555-88d8-aee3f7c2b92c	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	BRAKE_SYSTEM_FAILURE	70	200	Brake pad swap, fluid line bleed	2026-11-22 06:59:47.744
ed88acb0-f624-4129-8abe-87a594b8e901	26862790-bdc3-4714-aa48-5991f7550785	COLLISION_ACCIDENT	120	400	Flatbed emergency towing and winching	2026-11-22 06:59:47.756
8c1d204b-4237-4df9-b1fe-f2298f869335	26862790-bdc3-4714-aa48-5991f7550785	TRANSMISSION_ISSUE	100	300	Roadside transmission lockout and tow	2026-11-22 06:59:47.756
44dfad08-7118-4ee1-9135-ba5f7000e198	26862790-bdc3-4714-aa48-5991f7550785	FUEL_EMPTY_OR_CONTAMINATED	40	90	Emergency 5-gallon fuel delivery	2026-11-22 06:59:47.756
\.


--
-- Data for Name: Notification; Type: TABLE DATA; Schema: public; Owner: vbrs_admin
--

COPY public."Notification" (id, "userId", title, message, type, payload, "isRead", "createdAt") FROM stdin;
\.


--
-- Data for Name: RefreshToken; Type: TABLE DATA; Schema: public; Owner: vbrs_admin
--

COPY public."RefreshToken" (id, "tokenHash", "userId", "expiresAt", "revokedAt", "createdAt") FROM stdin;
f35bb384-710c-4384-bbbf-eaae57ae495a	1cd4755d30777a50b74c921ded197f7520b71f5db9dbaaa2d750c8660a572b9f	c972ff02-c8ee-4306-af30-97d17afddc20	2026-11-29 09:08:01.695	2026-11-22 09:08:02.464	2026-11-22 09:08:01.699
603d7bea-2680-4c81-ae17-6a7e059a169f	5c5e9ca9f41b9405510a8422c4eb355d1b547eddde6c591c06199c3775310056	ddac9980-193c-46b4-80e4-8cf4a1d55d97	2026-11-29 09:05:21.209	2026-11-22 09:05:22.147	2026-11-22 09:05:21.211
6d62e7c5-ded7-4270-83d6-cb72527cf66a	eb90455f62cb87c5adc2daed957e6b5490bcfd5502809e969d15dbed64bca265	ac3508cb-830b-424e-86b8-303c71462968	2026-11-29 07:11:50.455	2026-11-22 07:11:51.074	2026-11-22 07:11:50.457
c4ab7dbb-2e79-41f8-b61b-6955bbc314e6	6927b8b5a0ff0225033a448825edfbba76df5d2ef8a660afcb232e22d72d3c4f	ac3508cb-830b-424e-86b8-303c71462968	2026-11-29 07:11:50.708	2026-11-22 07:11:51.074	2026-11-22 07:11:50.709
05fdb2cc-654d-45ae-a1eb-3edd5504c181	8ade6f9571e857aa17d912b18a3b21a3e6f0a8d7276279b5a4899c0db7b1da08	ac3508cb-830b-424e-86b8-303c71462968	2026-11-29 07:11:50.971	2026-11-22 07:11:51.074	2026-11-22 07:11:50.972
5efa6c0b-4bc8-4644-9f47-d22db0445815	842d8d1363c014b9941c8f2fa111f74dcc3ce633a4e4fbe6b1550925b8aa753c	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 07:12:37.22	\N	2026-11-22 07:12:37.222
185a24ff-f85c-4a95-95aa-f193367beb4b	4cc53b60004fe503ebf74edabcb4d85d79a3e663d3a507e2b6484e0f4e771c18	ddac9980-193c-46b4-80e4-8cf4a1d55d97	2026-11-29 09:05:21.599	2026-11-22 09:05:22.147	2026-11-22 09:05:21.6
9e0e1ee5-5f23-41a3-8ed3-63d63ef894d0	3216c886465064e73707efa39d74e9ea71f4320fc84ec1e7bed577c4cf78d84e	ddac9980-193c-46b4-80e4-8cf4a1d55d97	2026-11-29 09:05:22.001	2026-11-22 09:05:22.147	2026-11-22 09:05:22.002
f4d4b74e-3bfa-464f-9394-15ca566303ec	9a0d2547b4d03b601b65867135b646d6b976b0cc10abecfc4c8de6e4887eebd4	bde388dc-1767-4bbc-a67f-22901fc816a8	2026-11-29 07:15:37.705	2026-11-22 07:15:38.31	2026-11-22 07:15:37.718
d8c4319c-2386-4f93-903c-07199e2e568a	52d264b46c2d72c8acc52f0d11c9f87131a042fd6a2999841365168ff8475f26	bde388dc-1767-4bbc-a67f-22901fc816a8	2026-11-29 07:15:37.954	2026-11-22 07:15:38.31	2026-11-22 07:15:37.967
cf22b306-ca1f-47f5-b375-4cb4b08f8c0b	23bdfa79802bca7f6395d0e8b89062a5df7998982333b3cdb34f3ddbd1a0f32c	bde388dc-1767-4bbc-a67f-22901fc816a8	2026-11-29 07:15:38.213	2026-11-22 07:15:38.31	2026-11-22 07:15:38.226
edfa6ecd-e3dc-4e1c-88c3-bbb77605e547	37d4858b08d123bd50704458abb18d7d3a50cb0b47fa940a904a6d33da2fa85e	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 07:19:37.843	\N	2026-11-22 07:19:37.845
426ec9de-307f-41a1-b5cd-157acc183075	36db4ed783543895decb9fbf35280c75886d44d95cf526b63b246be5db05b5d8	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 07:20:08.205	2026-11-22 07:20:43.55	2026-11-22 07:20:08.206
563e5bdd-5794-4f3a-af59-0268f1033811	b9f0f00ad5ac2dda38945531d56225e35d2a58f66546d541f0c2b9cd15c34044	7a13794a-e022-4261-9b33-6ce596779309	2026-11-29 09:07:23.758	\N	2026-11-22 09:07:23.76
1f0e3373-21d5-439b-881c-aa33f4bb9ef6	6bc23c7744448b7d78e01f33584285c53e1a781347ab4f5f24101a65b70a7d0b	f497148d-d3c5-45be-b500-72020fd86949	2026-11-29 09:07:24.008	\N	2026-11-22 09:07:24.011
9440015f-a1fe-4b0d-8a67-275c6e119d6d	0d0b8dc995c99d8e9a68d4b6c785abd58c81895983a5b59ae077f08d93557584	c1b7fe66-784a-4964-a091-320fa60f5489	2026-11-29 07:32:19.089	2026-11-22 07:32:19.713	2026-11-22 07:32:19.093
60320b1a-0133-443a-b298-1fa12c97ad32	9769fd28b139152862e2ddcece507983397adbca4897d16cb33cc2d4f466f51a	c1b7fe66-784a-4964-a091-320fa60f5489	2026-11-29 07:32:19.342	2026-11-22 07:32:19.713	2026-11-22 07:32:19.346
38bb4176-45d1-4fb6-b2a2-e71ab3274e44	232f2a3eb5819f76fe6ee68fdcfe3c6d10895a60c2c2adee08bbb91af2a83a91	c1b7fe66-784a-4964-a091-320fa60f5489	2026-11-29 07:32:19.605	2026-11-22 07:32:19.713	2026-11-22 07:32:19.609
2525b4e9-8099-43cf-b8c9-9701a5197345	8cf9301df942eae8a4a6f589349681a16efb5f295d1028a38ecdd719d007b888	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 07:34:17.63	\N	2026-11-22 07:34:17.632
3bc7607b-3743-4711-9855-70cdfe551f69	1f6cf614a9ed2b29eed7a2ea4804255ee178f5b4e01ca89718d5bec6d3a98aa7	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 07:34:52.488	2026-11-22 07:56:43.223	2026-11-22 07:34:52.49
632e3be9-870b-4133-a3f2-3042357fc9d8	100df7cdfc2f00fcc2a22177d33668d7a4f535761569c0c74d61e77e13c23ba4	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 07:56:43.229	2026-11-22 08:04:02.819	2026-11-22 07:56:43.231
ba66e891-0c84-4735-98be-183599ac2029	7cde70018fbe592318682ab5d09e9ef0d9d2c03662006b34eab01c762bbd91ec	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 08:04:12.627	2026-11-22 08:39:09.312	2026-11-22 08:04:12.629
1cc9c056-0126-4b57-95bb-d70e8e458c07	98365f6818689f2887d81936cd2f1fb1ba18f20baba1730ecbeac9cf9bf155c9	c972ff02-c8ee-4306-af30-97d17afddc20	2026-11-29 09:08:02.468	\N	2026-11-22 09:08:02.471
e79f4d95-d551-4536-86e8-70c363c6d272	2c799ba9cc2d20bc69df34f4b047e95ed16e96c9ecce99e64f497b96e4c71545	f497148d-d3c5-45be-b500-72020fd86949	2026-11-29 09:07:24.475	\N	2026-11-22 09:07:24.477
8032a120-dfff-40c4-83e0-01ee26ec3fd4	53ca87aad07964999a831cb59f63b13b3cec130dc1824d39d73f86f6dcc1796a	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 09:07:24.707	\N	2026-11-22 09:07:24.71
9d2764ff-c162-4041-912d-7b1b3b215e01	d94bd6c4b249579561d1c9ea53e41bca6e9e4218aea2135f5c2eec79346630cb	7a13794a-e022-4261-9b33-6ce596779309	2026-11-29 09:07:24.241	2026-11-22 09:07:24.954	2026-11-22 09:07:24.243
df01978f-0517-467f-8d8c-124d30fcb57c	e2e8303f56a74ae647e00360997a52c500cb873cea2622925028fcafaa9d555c	7a13794a-e022-4261-9b33-6ce596779309	2026-11-29 09:07:24.958	\N	2026-11-22 09:07:24.961
2bc3fb0c-efb7-4f58-8644-a80aac441d08	cbb22f3d03b2185a13b1db0062e07fcdcfeccc281c6fc18bbfda768fafe517b2	13f321bb-a96d-47dc-84d9-c6e12d82ae2e	2026-11-29 09:07:25.194	2026-11-22 09:07:25.21	2026-11-22 09:07:25.197
8a258453-6945-44f8-afeb-e682801c11cc	6ec471ddd5e5fd76fdee77b6f9e73247707a6bca7616657f1c55b7b89a88b02e	13f321bb-a96d-47dc-84d9-c6e12d82ae2e	2026-11-29 09:07:25.204	2026-11-22 09:07:25.21	2026-11-22 09:07:25.206
f4a0d646-7203-436a-a4f1-099ab0080fce	9b0e38b4546b4a5779e848337be08bdd5d14f59b5fa0c170dd225f266f855d56	c972ff02-c8ee-4306-af30-97d17afddc20	2026-11-29 09:08:01.213	\N	2026-11-22 09:08:01.217
c9ae95eb-5368-4194-bb56-9622e94fe10e	e5b51cbfbb4bbd1c8f9346d5ad5916686c6a34738273ac965b7b8996c84ff2d9	b7eed690-1ed3-46ed-882a-8ff0ca54af9d	2026-11-29 09:08:01.461	\N	2026-11-22 09:08:01.465
42ee541d-5b17-4dfc-afa0-f8047b44c9b2	5721d5901b548a6fac4707d4b977c5610a26329af03dce1f7ee8df3f33a2c1f3	b7eed690-1ed3-46ed-882a-8ff0ca54af9d	2026-11-29 09:08:01.931	\N	2026-11-22 09:08:01.935
79fa8d35-40cf-4ab0-9a6a-1c77fe3f233d	5c19ed19f535ca379e03db4744c70369ebc1539d971b92aba5c68535b5bc5540	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 09:08:02.165	\N	2026-11-22 09:08:02.169
da807910-6037-45b8-aa77-7965aea3dbf9	f743fcfcca5d4c1d45064d7367d7da95342aaf954897391fe6ccba514216d8f8	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 08:39:09.318	2026-11-22 09:09:04.087	2026-11-22 08:39:09.32
aa20ebdf-3246-4ffc-84db-30680562b057	0eec5c22816e1f3890b0132a8b0e6e0d2616055ad29f5aba4a0f0ab55db40d59	cf8c2466-215a-460b-a889-2f47bce8dd02	2026-11-29 09:08:02.705	2026-11-22 09:08:02.72	2026-11-22 09:08:02.708
2a8c9296-ff44-4d29-a734-1196ec200ef6	315831f1892dd2756dbb0161d914a12dc5fb333b26718d229283afd787ebafd9	cf8c2466-215a-460b-a889-2f47bce8dd02	2026-11-29 09:08:02.714	2026-11-22 09:08:02.72	2026-11-22 09:08:02.718
bfeb4a0d-09d1-4e98-a212-065124a81842	a26e0f452e8f38c81b69efeeb22cca6b051921d28fa4fe84f55bf5db66d7c24e	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 09:10:00.092	\N	2026-11-22 09:10:00.093
f1519ad9-fc66-4743-b825-935210622ce4	5a45e0c6a4f4d0434b85eeb9cdc6ec8b0050dc7e4ca3b324c166376e28cdfdfa	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 09:10:52.401	\N	2026-11-22 09:10:52.403
c799b094-6966-4606-83a5-38fcb480137e	6225f65728ca9688f575649538c48e5a917d992fba1a3ae7e0c714ed65471765	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 09:11:25.284	\N	2026-11-22 09:11:25.285
62182174-b0ab-47d8-a03f-7e8825951087	2ebd0d0f5c38ee73dfa5238b89ae0093aec53f72aeceee81316cccdfbd0dc2c1	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 09:12:09.943	\N	2026-11-22 09:12:09.944
b76ce5eb-5ec9-450c-b515-656533c66192	adf87590bf067ef9d4e190451e0fa10e028928fd5b74a289bb371f41de50b0cb	df30359f-fb78-4f77-8c18-936d3d870d43	2026-11-29 09:12:40.831	\N	2026-11-22 09:12:40.832
e257ccee-2649-44af-b411-62fbc7868f62	808934f2de132f308f057586bb03d9e65ad1810c41acfb527608de1b206141bb	0579580b-0d74-488f-9878-c209546a5c2e	2026-11-29 09:12:41.087	\N	2026-11-22 09:12:41.088
625f035c-8cb0-4edf-858b-c5623af8b74a	531c2235ef1ed31d73ede634b6f20d070c73e254c15145490e8122c94f42efba	8be98a6e-8e34-4741-8dbc-8105dd3d6b2d	2026-11-29 09:12:40.827	2026-11-22 09:12:41.468	2026-11-22 09:12:40.828
02922ba9-8ea6-4c53-8282-a5053b5f2867	545a2c144a4d8067ebbe0c5ba3a078655e0b4c2e79aa971d35cbf0d0746cdd47	8be98a6e-8e34-4741-8dbc-8105dd3d6b2d	2026-11-29 09:12:41.081	2026-11-22 09:12:41.468	2026-11-22 09:12:41.082
16bfb17b-1d39-44b6-b8d1-077001253e73	03d79fbbba0dc59c28c5b2526e88921c9e5f3dcf9a7a7b9877e0d91e0c378d01	8be98a6e-8e34-4741-8dbc-8105dd3d6b2d	2026-11-29 09:12:41.343	2026-11-22 09:12:41.468	2026-11-22 09:12:41.344
1f3cf693-0bd6-40b1-bf18-cdbfe48ec9db	60318e33f5b143c7c45ff1dab52d5bc31acfc26d5e042798e63305b3535bc34f	0579580b-0d74-488f-9878-c209546a5c2e	2026-11-29 09:12:41.573	\N	2026-11-22 09:12:41.574
7bafb7bb-0dd4-49d4-858a-1ffbc1db7fe4	b59d013d5c6248ce9fa26c3240159505a71f86119bcf00d53e94282f8af3dae9	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 09:12:41.814	\N	2026-11-22 09:12:41.815
3ec82818-3585-47a2-ac9e-f2fa69b65251	7f811867c4d8e3a5dc1f1def2c6ed35cf0d706992c6b8a0b4d84fe6af32b2cab	df30359f-fb78-4f77-8c18-936d3d870d43	2026-11-29 09:12:41.323	2026-11-22 09:12:42.059	2026-11-22 09:12:41.324
0bad1891-265c-42ed-aaee-7f7c17370b3d	727487bada6d4cef56dfe54c91a12ad3be98415415dc3275d5bf91ed61800068	df30359f-fb78-4f77-8c18-936d3d870d43	2026-11-29 09:12:42.065	\N	2026-11-22 09:12:42.066
bdf71cbc-31a1-4809-9ca3-eb11015535fc	3ce0ede2e1b8dadf7e47227f0ad63d8335b5068a11f59810804baa0a1b12cdb4	5832bba9-40a1-44a9-b92f-c1fd04bfdcf0	2026-11-29 09:12:42.303	2026-11-22 09:12:42.319	2026-11-22 09:12:42.304
3b87fbc8-6edd-4352-b7e4-2ce46346d974	4d39cb37bc671ad47ee169217d57f682ff9593c233001cf1a0c0d8f1c5d2c723	5832bba9-40a1-44a9-b92f-c1fd04bfdcf0	2026-11-29 09:12:42.312	2026-11-22 09:12:42.319	2026-11-22 09:12:42.313
02797d3d-684a-4382-8c7f-188654e8bef9	32419ee257ecbd1b815b6a57d5c1b671aa737ecb38873d97e36d8d78d04a07af	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 09:13:04.762	\N	2026-11-22 09:13:04.764
88921681-53ef-4cf2-b70b-df1c6dfa754f	8b1578a107085684be448ffde4624e5b72596920e85442a48c6648e6a37a87d3	50d7979c-85db-4cec-8bb2-83ba29ebae7d	2026-11-29 09:21:12.806	\N	2026-11-22 09:21:12.816
8374d2fe-de27-41a6-803c-62c0ec9927fe	ee333cbaf219cd76da7e400ffc0c24b5595749aa46418fd019c7ab988fc80584	3bde293e-b15a-438f-82ca-84c742dd02d3	2026-11-29 09:21:13.057	\N	2026-11-22 09:21:13.067
7b668c1a-0174-4f42-a43a-f178b4025d15	b14a420ebc74dee4399f633070f979baed860f11ecae201c537019696a0fe7f3	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 09:26:49.89	\N	2026-11-22 09:26:49.891
7b7d721a-b91d-4e73-b0bd-5b9f855ba6cd	f4c62e817c5e139a6c7abf4c6ca72874a3ba24894ff16f80ae5b6e7e888d858b	15a87756-ecb4-4394-8fb7-5555263f9a09	2026-11-29 09:27:10.955	\N	2026-11-22 09:27:10.957
0fd05c8d-b0c9-4460-8e0a-d993d56e0306	141a570f495ac8e0ef786a53289c0924bbc9f8b13454c65ccefeb730e60ef255	788ef40a-1c70-448f-9ebf-8d36ef3884e0	2026-11-29 09:27:11.201	\N	2026-11-22 09:27:11.203
6fd22a2d-e6c6-4431-ba76-92f64d8e72e0	112273c59c3dd1afebabb82266113d0031772d98d3561391656167c85cdc823f	99327fc9-e815-4c83-aeb3-6c3616c22e99	2026-11-29 09:27:11.741	\N	2026-11-22 09:27:11.742
f323b546-5f9a-4fe6-b860-2f2edb19f86b	25d6551ed5c68e61964be98055889a0fdc60368cb9467723802784c956ad2784	abe634c7-837c-4fc9-8d62-af59c97d8fd7	2026-11-29 09:27:11.996	\N	2026-11-22 09:27:11.998
ee98aab5-278a-46a5-a966-e57749303503	6e81904dbb4abef70623ff551d14d2e57ad8b318c405eb88dab345c2a66cbd59	ebf4e83b-ea5a-4e92-bf15-8c58e0b49d3b	2026-11-29 09:45:41.139	\N	2026-11-22 09:45:41.14
3a7794e3-64e3-4ac6-b76e-9a13dc64dc75	88da28449890c82fe46cba339b04ab834cd59ae82037ad9285fcd4d42fd1bd74	277153e2-5d4b-4efb-8456-e5e9a3e56241	2026-11-29 09:45:40.232	2026-11-22 09:45:41.278	2026-11-22 09:45:40.234
6690851f-67e7-409e-a606-87edae51a88a	ccc5802e47f5b41856290a636d0c220595072ddb045478afca3106394c16a035	77d18c5b-d7f6-4a88-8a79-9d96d9c45dc3	2026-11-29 09:27:11.651	2026-11-22 09:27:12.261	2026-11-22 09:27:11.656
3020dc29-9d12-4e21-8057-793981881115	73112e9f5cee07f2c4889cd9cf1ec67f2f5122ca383a1d04db1c18fc6f02db57	77d18c5b-d7f6-4a88-8a79-9d96d9c45dc3	2026-11-29 09:27:11.9	2026-11-22 09:27:12.261	2026-11-22 09:27:11.905
a0131ed7-0c17-4c41-a28b-85a56edabe5f	a5a766f8dedfc046883a6763d4ca76ce4fc6b2bdf7ee5c60282c02ea33e1dee5	77d18c5b-d7f6-4a88-8a79-9d96d9c45dc3	2026-11-29 09:27:12.159	2026-11-22 09:27:12.261	2026-11-22 09:27:12.164
2299f7f5-6133-4228-8c85-4dcfb0edb1fc	ee89ecc19005529deaf4b7723b9269bc179e1e28554328d69241065efdcc8d43	abe634c7-837c-4fc9-8d62-af59c97d8fd7	2026-11-29 09:27:12.464	\N	2026-11-22 09:27:12.466
13976fd3-baaf-4fc1-8d63-3ed85b01ffce	9fd328feb5bf2c0e82059fe68a223e16b2b12a72c9c3c067eab7b8ecd28fee1c	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 09:27:12.712	\N	2026-11-22 09:27:12.714
5e0cd854-c9f4-4f86-b548-87201b443e81	a40b84c857a98209b9297261d185f5c4594885db3de8e302f8815e129d49216c	99327fc9-e815-4c83-aeb3-6c3616c22e99	2026-11-29 09:27:12.233	2026-11-22 09:27:12.958	2026-11-22 09:27:12.234
8f8f18d8-9e1e-47f9-9381-81195817c0f8	f1a0cc7177a2dced75cc8d96a6d98e0e868fd1ad975161f9c93d03142ccf4bc0	99327fc9-e815-4c83-aeb3-6c3616c22e99	2026-11-29 09:27:12.962	\N	2026-11-22 09:27:12.964
31e955f8-fe09-4bbc-b6ce-c6c4668ec7c8	d149d4c00c9658935025f4c2511b56c6e097e809be1e3ca21e356fe24610c7b3	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 09:31:44.192	2026-11-22 09:49:09.905	2026-11-22 09:31:44.193
b99d30c6-4139-4725-aa71-d8b30c6d1b81	69a0ac7165479959ab9b8c937dc451b0e0f5e7a20121cc26293b0798eeb1b9b4	f652e135-854d-4680-9b11-2e96bdc6eda4	2026-11-29 09:27:13.201	2026-11-22 09:27:13.217	2026-11-22 09:27:13.202
6e03af8b-cdef-4702-8f09-ace65028911c	ca22f10e089ce608fbc17de616cc560de518bd6784ebe021068aaadd2d79d970	f652e135-854d-4680-9b11-2e96bdc6eda4	2026-11-29 09:27:13.21	2026-11-22 09:27:13.217	2026-11-22 09:27:13.212
b528d5be-12d3-47ab-8891-bee783a307b8	7b40cbaeb39d92d4f47487de35cfc62da9eb296a7d0c3f3cd0341fc5270dbade	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 09:27:33.907	\N	2026-11-22 09:27:33.908
e3235e6b-c50d-4281-a000-f9fd25623ac8	adbc5d04e51a7f342bb38514b76101038a527f5415111287ccecec13c620de00	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 09:27:44.153	\N	2026-11-22 09:27:44.154
aafe0df8-e7b0-4fa5-94db-7c5ca33d3610	581b007463395a23fc660d282cec3ecaac05a9182ce302253ac90d9d7a0704bd	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 09:09:04.093	2026-11-22 09:31:44.187	2026-11-22 09:09:04.094
89cf2763-ee60-4aa3-8054-c0b23149434c	0cae67002965845ebb88851f2acf750943ae37f06db9af10bcdbf908dafed2f0	baf36b48-83b6-4d2a-acaf-1145a539c456	2026-11-29 09:44:11.173	\N	2026-11-22 09:44:11.175
56e8cce4-15a8-410a-9ccc-885c984a7897	24a92f336fb2a7a88fc646e4bd52dfb86230f30a7c67f3f9c1300cae1530f112	4ddd4a39-70fa-42ed-bfbb-f2c557e01ec5	2026-11-29 09:44:11.577	\N	2026-11-22 09:44:11.578
a01bfb37-47c1-4382-80d8-21d292a2b3dd	e742ad60f5c59ee15c7655a4052f40cbd688c673da583b28ce1fc9b29c729480	c7966587-138d-4fb6-a6d9-b638c3646f4c	2026-11-29 09:44:11.956	\N	2026-11-22 09:44:11.957
a9099ce1-0473-432d-adaa-959fa12c1c90	7573c8a070853614f0f62aa9feae151d67d566c3d4ce9b0a50a997a4ab40ca07	19b6e30e-7ab8-4db5-87e5-443815e3d455	2026-11-29 09:45:05.148	\N	2026-11-22 09:45:05.151
c1650a50-5f21-4daf-9658-37b7dd92e664	d2ee79a1a514a4d27c377e94685a0c6a284c5f8c74f0538a8ba19b7dc208735a	30d6feea-b385-4632-bdf1-274829eada18	2026-11-29 09:45:05.515	\N	2026-11-22 09:45:05.516
04b16ffc-90a4-4eee-9684-7d5bca53d4a4	36780fb318d20ef79c17813765fc28eb3f2f3e1251a71655263af31d14d924b9	29b31365-442a-4af5-9665-541885e6c2ad	2026-11-29 09:45:05.874	\N	2026-11-22 09:45:05.875
24dfd2f6-8b09-4e4e-aafd-e0acc8885d58	be136e93413f2e0f706c1160b61a78f4ed9c058f52f96822578baa0f89cda82f	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 09:45:18.858	\N	2026-11-22 09:45:18.859
4e2b1bd6-44ea-44bb-85a7-70dfd824a606	83d1a5b06f837ea7b3e1bf899712eb28aa5548202f1c4f4f421527d573c64594	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	2026-11-29 09:45:40.246	\N	2026-11-22 09:45:40.248
813f2976-4c2b-416d-8b81-5433ceb891bd	12cbb3eeb10e1523cf1184b6f798dbbc3c19e3df66d1e9f6cceeb98a19a16657	436d667c-cc9f-4294-b2c9-cc95e0cb3d7e	2026-11-29 09:45:40.285	\N	2026-11-22 09:45:40.287
818b3bd6-3791-4399-9345-1834c798e5e1	250607411f6c0ee9d4905d9631a27f726b079622591103f63ed5ea5ca0831b10	d47dec16-a57d-46ee-b2e9-8e7b594fae34	2026-11-29 09:45:40.3	\N	2026-11-22 09:45:40.302
8cc52d8c-2388-4335-bb72-cd3f2c3a2a41	ed977afb32e1f90d982ee31adbcb4fab6ed4ba1bf28dab5f5303fe45fc82281f	d76fafdd-5428-40c5-8632-142aab1c5539	2026-11-29 09:45:40.697	\N	2026-11-22 09:45:40.698
1bb9f932-07c0-400c-8bb9-77d2350382ca	e1cdf91b4a459ae3c32adba9f7940d55c190ff30f504e7866185cdef22d359fe	86ac2e5d-4c47-4b60-900b-7d610ad1cdd0	2026-11-29 09:45:40.709	\N	2026-11-22 09:45:40.71
a85c44ad-f923-416a-adbd-c56653dff93e	ae99fb3cd4da15dfa0343ad0cb65937ac4c1bb04a997334168ecab527141e1fc	277153e2-5d4b-4efb-8456-e5e9a3e56241	2026-11-29 09:45:40.711	2026-11-22 09:45:41.278	2026-11-22 09:45:40.712
01843848-85ca-4438-9752-5c34d0597f5c	4b1c5346abf961a654be5d4b21d15ed2da110c9d353a081ad4c3d257ab53ba5f	277153e2-5d4b-4efb-8456-e5e9a3e56241	2026-11-29 09:45:41.121	2026-11-22 09:45:41.278	2026-11-22 09:45:41.122
81d5e762-b4c8-45fb-8957-8171fb59d59f	961fdffe5004fc4b9cfa95cc644e2a235b562f70240f6ababa268b783b9386c6	2eca2933-96e6-4fa7-bda8-a1d0479de90c	2026-11-29 09:45:40.729	\N	2026-11-22 09:45:40.731
1c7757dd-3135-44fa-a83d-183811c4e9f8	f29c0939676b35c4852caf1a7c4b42844d9a6b0da62b25881f5bd301e3aaef3e	2eca2933-96e6-4fa7-bda8-a1d0479de90c	2026-11-29 09:45:41.542	\N	2026-11-22 09:45:41.543
9870f37b-a0a9-46db-be7b-58677467ed07	2b52a022e79034f96bae5a1ca2542454c68d7c09684dbee1afcd57152fbce9bf	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 09:45:41.895	\N	2026-11-22 09:45:41.897
5f8a9ca8-e422-4a94-9a70-04f22183d845	ddfac0e8af4762b567ffa6de548d92e733e5613f3127e2b2cc7b1f2afd8a2c2a	d47dec16-a57d-46ee-b2e9-8e7b594fae34	2026-11-29 09:45:41.157	2026-11-22 09:45:42.275	2026-11-22 09:45:41.158
97b3cec7-6615-4c2c-819b-9fb376e15587	b006cf80b01dd1acef521ee8be06e10ae64c0200f0b515bf50390ab3c9748f59	d47dec16-a57d-46ee-b2e9-8e7b594fae34	2026-11-29 09:45:42.281	\N	2026-11-22 09:45:42.282
ce91ca29-62f9-4d38-9aa1-7309347373a1	c9eaea685d931c1e3cf79da71068c3984274190626689140b57c66bd12e32b72	4d0a14bc-7faa-4a5d-b04d-3f0d657598d4	2026-11-29 10:04:24.69	2026-11-22 10:04:25.852	2026-11-22 10:04:24.693
5ace665c-2b7e-4250-bdcc-924bf599021e	ee55cdc253e2a83915867930b3cf5dfc0f1893af03c95c61ef4bc4c06a878d6f	8aa2fb1e-2ce9-4b57-b38c-e182c0320226	2026-11-29 09:45:42.647	2026-11-22 09:45:42.67	2026-11-22 09:45:42.649
d6c1bb73-74bf-4f32-a445-7ff24abef8ec	5b566b693aafb72f05f29f352b8f97b24ceef199b850e9067cd28459060b7d82	8aa2fb1e-2ce9-4b57-b38c-e182c0320226	2026-11-29 09:45:42.661	2026-11-22 09:45:42.67	2026-11-22 09:45:42.663
331e71a5-c573-45b6-bade-1a7deb4edb23	ad43a52988f5f87cda6ea06f4a7055fc27ffb0b274b080ea872e483e26882d93	8b3cfcfc-79bc-4fc5-b337-656b2fec774d	2026-11-29 09:58:36.525	\N	2026-11-22 09:58:36.526
998f1210-6607-429d-99e8-e7308793ae81	b5faf3d015d7ace5c0822766cb0c3fa23b5eeb8304b6304e9d699416ad925d05	23dfa73c-7d5b-46cb-a1f1-cfe57a65b3db	2026-11-29 09:58:36.901	\N	2026-11-22 09:58:36.902
3bd542da-b43f-4a76-80ad-6bfba52a546f	af63e30ef2fc03c66dffd2bcb395d1aa3439617587d06922c6e74c922ea01108	babb78bc-8995-47e3-873b-d77a0c81a425	2026-11-29 09:59:32.584	\N	2026-11-22 09:59:32.587
817e7c06-7483-4cf5-8ec0-41314dad8bd8	cd92e13f61c93ced19dfc1fa4d7b6d33f3222cb7204319a9c673e69a694ec1d2	838cdf88-b812-44c0-a890-3e53d54aafe1	2026-11-29 09:59:32.959	\N	2026-11-22 09:59:32.962
ed297b7e-e44b-4209-b56c-183152c60a74	0178b468e4a2f64af4b62d525b6d46a6187ef07665c59a35076d186381d84e03	f69dd74f-2981-40af-9eea-5269a5fa8340	2026-11-29 09:59:33.332	\N	2026-11-22 09:59:33.335
556b191f-eac9-4dbe-b9ce-3ec15c3796ea	6d7ca0ceaea5f48f3102ab6a00294d0f5af1f62d4682745c5687d8cf867c9deb	2dba2391-5f04-4a66-b103-d008daa1d7cb	2026-11-29 10:00:36.398	\N	2026-11-22 10:00:36.4
38953f16-d678-4d0c-8024-a6b408175630	31c0e4a8e67a9447a4cde489ba8cc714ca15bfa6ab8ccbf707ea51aed87fd5c2	8aeefd6a-535e-4b26-9fb5-74c9ac6e26c3	2026-11-29 10:00:36.651	\N	2026-11-22 10:00:36.653
13dbaf25-d7e6-414c-a40d-54a245f89945	67cb37585cf5d0637406bd976c18444123031e53fc33a454bb6f8956b4bf4a92	6d34d30f-9a1e-492c-9781-a28cf649ca03	2026-11-29 10:00:36.898	\N	2026-11-22 10:00:36.9
2b2eba1e-5756-45bb-8995-6d492e014738	1a414e78f5dadf277fb9bb73e0a0c5c37945b8db44b43e6f73a64bfde04e75a1	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 10:03:47.585	\N	2026-11-22 10:03:47.588
5530f277-2f33-434b-bf91-d5f6fd8b71f2	cb7df029001baa71af044276c2f4be3dba62219667fc2461c2b77255d74da28a	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 10:03:50.855	\N	2026-11-22 10:03:50.857
c4d6dec9-df82-4507-b5f1-036b24100015	65a35bef28ca2a4fe0d2a3225c1a9d30d3fe66fa6e1bdd58c8b4f064c934e450	65531d90-d509-44d8-8c50-189197b32adf	2026-11-29 10:04:22.172	\N	2026-11-22 10:04:22.174
adef929e-dd72-458f-8760-14d7f25f464a	e905e1021a9af4d6d20143d671e3739ede2cf5482509dfda15f0701daecc2fb7	3508ead1-81a7-4452-a2f1-fd5599a1f576	2026-11-29 10:04:22.631	\N	2026-11-22 10:04:22.633
042e39ea-8781-4603-8c20-bc3c7f136516	9dbf60559082cb7cf74c5f4a2f966b4f05e0bd0f76ef65a1c023eeb00b857eaa	71be654d-8646-43a1-985d-0f9757ec84b7	2026-11-29 10:04:23.072	\N	2026-11-22 10:04:23.073
a7223a76-2fb0-426a-960b-02472093abcf	9dc126f79c60d37be1449ebfd2fc7c5038795d21dfe65cf08c82140d2c1ed1ee	4d0a14bc-7faa-4a5d-b04d-3f0d657598d4	2026-11-29 10:04:23.803	\N	2026-11-22 10:04:23.806
5b8c5bad-6fd7-4568-938f-997fe360579a	3ae92b1acee6b5c7bf3f68568c3108e333c63d8574fb85bc750278107a2fe6bc	a9541389-845a-425d-9b38-1de039a56cdc	2026-11-29 10:04:23.886	\N	2026-11-22 10:04:23.888
e6950b72-cfbf-441d-9be3-270d531d752c	56670397a9655d0d6073f9330e9dab97b7d8733a9daedf42b3c02562b897944b	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	2026-11-29 10:04:23.923	\N	2026-11-22 10:04:23.925
b4b8dfb9-0994-410f-a6bd-85c39396e552	93a7493ed40662428a56c398898c1556d2d77529c84d39eb3dbd9dc227010e5f	be6ce21c-27af-4c83-838d-9252f2ed8b52	2026-11-29 10:04:24.271	\N	2026-11-22 10:04:24.274
7515eac0-fd10-4a83-9e36-61395f52baf2	2d22c1cd123fa266c989096c0b67c42b25d6558b376acc8873a2e87922df5f48	abe608a6-40c5-47bc-98f9-709af459f3a5	2026-11-29 10:04:24.33	\N	2026-11-22 10:04:24.332
c306bb8e-3a27-4e65-89fc-db304b14bf19	4b0139b28e39c6341d9277f775c072895b854c1a354ef662bd6dcad1413441ab	6735a628-9f69-43e8-9647-4859b129ce73	2026-11-29 10:04:24.353	\N	2026-11-22 10:04:24.355
5f532eaa-f87a-45a8-9171-2492b9f11e59	b6295a995fc67d2409fea0b012c1321597033004a3243002329c834da73a5006	4d0a14bc-7faa-4a5d-b04d-3f0d657598d4	2026-11-29 10:04:25.858	\N	2026-11-22 10:04:25.861
4b456b4e-5a47-430e-9b8c-a5f21b6b5878	1ee93d4ef2c4d307c2e9b32f0bceff1fec93a254d0a7dec15f892eeb96ec21e9	e7df7f99-0377-492f-baa6-1a71ef06d94b	2026-11-29 10:04:23.726	2026-11-22 10:04:24.741	2026-11-22 10:04:23.727
c79440ba-c287-4573-903c-f2a8badf7384	544b06d686c120af119e9e0ceabf73280727d5bf6c2f6bb0239314bce7e7d1cf	e7df7f99-0377-492f-baa6-1a71ef06d94b	2026-11-29 10:04:24.164	2026-11-22 10:04:24.741	2026-11-22 10:04:24.165
0895007f-83b8-4608-8c7e-defb3a9ee27c	c1376f1962fb9dab02ebf3e328c01b3208ebe9a1983829397809f769173f6f40	e7df7f99-0377-492f-baa6-1a71ef06d94b	2026-11-29 10:04:24.608	2026-11-22 10:04:24.741	2026-11-22 10:04:24.61
08ca4c18-3d02-422b-91d3-3a5b938022eb	fc7c3f3e7c972af38e47bfe3165d67aef41365e69926dd7f299ee08ad68d8052	a40c3731-4a5e-4537-8dc4-3d81ed50c82e	2026-11-29 10:04:24.814	\N	2026-11-22 10:04:24.816
a0070104-49a8-4815-8087-9621e49c82c2	4432cc100eeac83bcf4068aa2c56968b8d05db02ffba6fc2bb6c2c5b137ca5b2	be6ce21c-27af-4c83-838d-9252f2ed8b52	2026-11-29 10:04:25.089	\N	2026-11-22 10:04:25.092
8bc5950c-8ad5-4d75-a38c-e290813df671	c18d0b6a0d58aadd9d927e22711a73e15c1b009f48c7f1c27ac7762c7320480e	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 10:04:25.466	\N	2026-11-22 10:04:25.469
dcbb3e7f-bc85-41e9-a434-c14cb500d5b8	c09620e51f1ee07143b4a6466ab462374259001d74f3c67706ea3adc57ea7fbd	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 10:04:52.819	\N	2026-11-22 10:04:52.821
6efcf6c9-e9a5-41b7-9549-cba02b1310a4	30a0d5b16663ac7dbcf44346a1348dd35ec13d4af26604b930faf9d12e198330	002fc4a3-6450-4661-8aac-be73b003405b	2026-11-29 10:04:26.229	2026-11-22 10:04:26.254	2026-11-22 10:04:26.232
9ecd6504-a89d-45c9-bc22-4e2860ccabb4	18f3f63f2ee8dd22432ac6567a1e8e23abd9773e34c7422a05636c7601cd8426	002fc4a3-6450-4661-8aac-be73b003405b	2026-11-29 10:04:26.244	2026-11-22 10:04:26.254	2026-11-22 10:04:26.246
0612b25e-c519-41b8-863f-133ba2a0310a	d69e310ec71574be3f9adacabf43559abc1b42a3ec0d513fff41c58082be49fc	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 10:05:03.601	\N	2026-11-22 10:05:03.602
ba2fe846-af3a-44af-9704-a21eec7b455b	ae07ddb9613508cfebe545b7cc8deb987971e397178a7c659fc5771e75928e1d	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 10:05:09.652	\N	2026-11-22 10:05:09.654
0e901fb0-b608-484f-8a54-f7a66b139cd9	56b6422604557cd5a39271ab0425ffc2b3f0c7ad2acaeb1f0b62f19b394f4a5f	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 10:05:17.268	\N	2026-11-22 10:05:17.27
c6d92b59-7999-4791-839e-d60b662421be	eef0424372a39afd8abfeeafe83284579a8ebb8f818466af93189bb6b40d8011	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 10:05:20.279	\N	2026-11-22 10:05:20.28
3640fb56-5075-449f-a0fd-b5c2b4b7e380	b69df5320341f517d2a374c3dea2c303ee9cc09a92c6be0280220e0e75e42c26	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 09:49:09.911	2026-11-22 10:05:27.799	2026-11-22 09:49:09.913
b7de3883-c994-40a4-9dc0-f111d9a5f6dc	b4c99cb6f8d646fcc1a53bb5a1430e0cad3c34ee2dca011b7c7b5a5a38f9308f	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 10:05:27.804	2026-11-22 10:06:07.434	2026-11-22 10:05:27.806
3c9e5c86-5e41-490c-91c9-33aea3b0fc2f	02fb5601e5df9ebb70906f7c5ef4dc0713f53ea98df06298e85492e28ac36563	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 10:06:23.454	\N	2026-11-22 10:06:23.455
7910729e-83f6-414a-b3e3-b7a416b3ae57	3a5e3e721368fb4d19e6e5c1714fb9b8f9d5561323124c2425da492d8eba7a57	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 10:06:25.892	\N	2026-11-22 10:06:25.893
252101a1-2be2-4ae7-90ec-1c8922827a9d	524db356e5db27c6d2b34b2ccc11669a2cdd07efe6c7b69ffd01ed0c394d3dbe	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 10:06:27.284	\N	2026-11-22 10:06:27.285
6680d686-ca5e-4d2b-8486-af7609d2fed2	81db78177ef7dab2825c44c8e29686f37c9c696f850495f9ae52510fb7611fbd	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 10:06:56.238	\N	2026-11-22 10:06:56.24
50f66e76-aebd-4c6b-b8a7-61c55356e27a	fdbf873b2f5812f4ed0fd6e4f76bd9bf39bd95d8dc99c8912bd7220ba71f4275	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 10:07:06.999	\N	2026-11-22 10:07:07.001
059f5b45-e5fd-4219-86de-06c62baf59d8	87fd98775ae06494e045303278844da088b9d8b0a90db767202c6ae95417506b	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 10:07:13.02	\N	2026-11-22 10:07:13.022
428e937c-c8bc-4496-80d3-4c817350f346	2076cdb2e69c843d365706f5a676dfec4490fbb0556f998e1574ab7a23ab9272	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 10:07:20.18	\N	2026-11-22 10:07:20.182
abc6dd2e-721f-4145-9d37-de6e376a6208	71e71546c3925ee797b0ab17ead724538bf59c7affc8e8cbf5e6fcd6876acfb0	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 10:07:23.29	\N	2026-11-22 10:07:23.291
2f27bc5a-6ef8-48c8-83fd-53f4ccc490e2	8284d8a603cc2ddd5b6b4810549740ce9a05ced8cc88ec2d1f519df7a3ecc65a	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 10:09:43.493	\N	2026-11-22 10:09:43.495
ac91aa8a-fc5d-4e9a-acd3-7ee21b1c48c1	b6d194b8e6eef4a1abae2a82323084532539dfc8cb56c27e84029c94b42c5245	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 10:14:46.609	\N	2026-11-22 10:14:46.61
55a3c75c-a906-4972-8e6b-bdfe6f8f0a0d	c84e41757474e42f727daac386f6923f93a5eeae3f157791041963e885f350cf	20c92ae9-cda7-4be7-a444-d9ec67df8fbc	2026-11-29 10:14:48.892	\N	2026-11-22 10:14:48.894
a47b5633-22d8-411f-98c3-925bcada3c15	f8944fac9f8f6492f8949b5df0ccdfe9e556ed957ad043e18bd3684fc484d1b8	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 10:14:49.731	\N	2026-11-22 10:14:49.733
13e49519-3f0a-451f-8189-b815a37e004c	94e65d5b845bf7e5b34ec4fe903940cc1c8a592f51045e15d68850bd74a40590	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 10:16:18.885	\N	2026-11-22 10:16:18.886
58bbb227-6079-4b90-b494-3934926c4dac	e6eb63f07cabee807bfe8aec0663d4e68d27d9ab474e7daba07a7bfa3d4aa01f	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 10:16:22.097	\N	2026-11-22 10:16:22.097
1dc35069-0d3c-458a-8248-0a993d7e4e37	e0c84d341f315db99a007aa1e2315fffb93b8bb78e4b5996e598262c3bc25883	b492f8a7-29a4-4012-a173-bb1cf5135319	2026-11-29 10:27:10.334	\N	2026-11-22 10:27:10.335
0bba28d9-4863-4f49-9dfa-d6a1dd2ad008	b9905a13bd40a8984fe470254a94029b7cf9a36dbce8e950ec4c7b9bdaabc76a	7ec8d5ac-2f2c-4bee-a45c-cbe4db28152f	2026-11-29 10:27:10.576	\N	2026-11-22 10:27:10.577
a316cf18-5edc-4fbd-a0a0-c711ac216065	65e1fe6e03955025077692d1fb1ea384dd1572680b73dabcfa4911f99a41fb4f	9ad0fc29-8daf-4688-925e-9fa71d6a2e80	2026-11-29 10:27:34.272	\N	2026-11-22 10:27:34.274
e6d83755-7859-4720-afb7-c15e7244d155	4e7c43bba7f27a47fddfef960c39233e816604f048f70b62453937ec3f30a9d6	7090b34f-dafd-4c68-965c-71bb401de60d	2026-11-29 10:27:34.515	\N	2026-11-22 10:27:34.516
7486a2a4-411c-4f67-a5ea-52f6c9c151f8	04ce3479b715229de7a3fadbb07cbbdafd8b7cd02a061b91ae1a441916844e74	8ad6b40d-ab52-471f-b6dc-4dcc2d132efe	2026-11-29 10:27:34.756	\N	2026-11-22 10:27:34.757
8c8bda4f-63d2-4c6c-998e-be0b77dafcdf	fbb9066ff33666a5076a87521277a18c489383cb91e1797270e7342141713971	99cb03ac-7b72-4f0c-bb2f-b153c954e67b	2026-11-29 10:27:34.997	\N	2026-11-22 10:27:34.998
e46e907e-df5d-450e-b9d4-e96dce7062c9	a6028631305133b41d8481fb7e5a21310d02ef5e5f3abca6c67aaa097111fb80	07e2bb34-05fe-462f-9b45-1ac77a36ee96	2026-11-29 10:27:35.23	\N	2026-11-22 10:27:35.231
63d49fdf-30a1-441f-bed4-98157ca0f057	d0577e29207c2946d74b6f238a3be6eb9b40c362a69c7bfbdd58411c99e01aa8	201144dc-4d12-4765-8873-8573ebc70566	2026-11-29 10:27:49.763	\N	2026-11-22 10:27:49.767
db37a69d-1884-4fb1-865e-8464f07fd264	06f03034e0048234c4e231b7a8254d8e268c3a48e4ca71bb91c02ce87cc1abb1	1b76c709-fd68-4cca-b699-3ce4793290d1	2026-11-29 10:27:50.045	\N	2026-11-22 10:27:50.049
624365b9-35fd-45c9-8629-e80b017145eb	bb11cefb1548b220dbfb15c966db64929db36c4f5d08d5570e264c135fb169ce	58ea9816-d0a5-42ae-92d8-55f32ab1135f	2026-11-29 10:27:50.339	\N	2026-11-22 10:27:50.342
c81f78b6-3d77-4ab0-a36b-86e03d7a2033	2d2d0a0ab0eda8e15b7b28c7690ede7f3580d58943c1dd44aedffcd5fe939330	020de9be-8c9a-4232-a522-39dfbf87cf9c	2026-11-29 10:27:50.603	\N	2026-11-22 10:27:50.604
e5d614c3-02ee-47f9-9e4a-212f2430f930	133a7434b662e1e234d0d387999f54acf8fd59f895f2b5393272d67972f8047f	90810c7b-ed32-4e65-993f-2371c000eb9b	2026-11-29 10:27:50.602	\N	2026-11-22 10:27:50.605
2867a821-0d55-412e-a41d-ef428937fe04	42f6ac17efa1b1f38e7768f7cd6b363b2288e224092b79eeb46f99315b4fa94e	4fb4b922-a2e7-4d24-9e81-1bae59ab792b	2026-11-29 10:27:50.705	\N	2026-11-22 10:27:50.707
fb48bb4e-5089-4ea4-9a73-c6643f5a94ee	31f60198cffcdbe5c631428a6730649201307aadaf68f8eb68b3f60c51b8d05d	2453cf81-de2b-42e1-9cbd-394d92e735f6	2026-11-29 10:27:50.725	\N	2026-11-22 10:27:50.726
a244db89-dc8c-4d87-8c76-1400dcbfc42d	bc3c740f7ab90e6a90dd8c0676c402ea54f12f4f9e423ff3afe63c8c2ae8514d	e05d0c61-e1ae-4921-8453-3dc06525dc08	2026-11-29 10:27:50.731	\N	2026-11-22 10:27:50.733
8774b890-32b1-4bc9-9f15-052923591adc	435aab202342aad510670b7d03e0ef3af9168e46510c24e8dba048c6655dda8e	d2a30eee-6528-4896-97ac-c1b16dbcd28b	2026-11-29 10:27:50.848	\N	2026-11-22 10:27:50.851
bf0ab0ee-9065-4983-8f62-aca517350591	6b81ffbf57dec04fffad10bc1f45b33facb53463026297d7d8c90d95a0913ef8	ab64f7e0-5ae5-4282-826f-e08e48227f23	2026-11-29 10:27:50.857	\N	2026-11-22 10:27:50.858
d74242e7-325c-44da-a6dd-6ca2cc5486cf	3e3d377a923d9ad6ce8736fe8f21d841c49f55745d19fe34433843f365372cf0	abdc3f09-7dcb-4b9d-be66-455330a09529	2026-11-29 10:27:50.966	\N	2026-11-22 10:27:50.968
a4bb3262-fe60-4424-872d-056ddad69ff7	b9f2bbd8c1bc59887ffb14a3d8b4ab649d16eb316ef64b699835987bbb1de6c2	87f1f769-abfe-4f96-b595-46a1bc413388	2026-11-29 10:27:50.983	\N	2026-11-22 10:27:50.985
ba210dbc-06d8-4408-8d96-6f249cbd5b12	03529eedf4282e5807b99294870fa0b1473a5dff97ae3ac63863b71093b81884	29c945b2-a680-4d39-9f8d-ee67d94c8272	2026-11-29 10:27:50.988	\N	2026-11-22 10:27:50.989
7cadf79a-37d3-4f09-9736-0db0146d814f	9fc14438cc2b86c7ba96bd4d13ca585ab9a567f21f1d39d3eaa616bdf45dea90	92ec996c-90a3-4cd5-a1bf-0861cd595b15	2026-11-29 10:27:51.127	\N	2026-11-22 10:27:51.128
6b1bda49-13a6-468d-8af7-7590077016d5	fe6e02b9975e0c6f3fb3cd65201ec2719934645cc3e0a358635949bb96b417b3	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 10:11:10.035	2026-11-22 10:41:07.999	2026-11-22 10:11:10.039
aefbc54c-b415-4607-b935-7e231580a085	6784d12786fa5f9078813d684072b8b11d5ec1c6c2a6c1775009717a8a3f0c40	7407b151-116c-44be-bd28-20d2ea8e9da2	2026-11-29 10:27:51.245	\N	2026-11-22 10:27:51.247
c478c09e-90fb-492e-89d8-2c7d2e7ac5ef	161b30bb9b440a60f48ec09618edd7d775ae63b1f41fd9c1d35d856044763bdd	3d1bfe42-4c49-425d-aa93-9f8e9c52b45f	2026-11-29 10:27:50.606	2026-11-22 10:27:51.27	2026-11-22 10:27:50.609
8a2b2bdd-6131-4a11-b32c-7c238830a94a	baac18544e38f51ca0d056d699ba7b57cd4343703d723f90255905955b7c418b	29c945b2-a680-4d39-9f8d-ee67d94c8272	2026-11-29 10:27:51.488	\N	2026-11-22 10:27:51.489
6a2bd708-f530-4de2-bbbd-6ff8395fa44e	afb9921ba9cbf1c41d445e61945b277515aa350b7bf120ba82ac7e34b1829a5e	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 10:27:51.721	\N	2026-11-22 10:27:51.722
39ea4dbc-b7c7-4e0f-a06a-257ca2d46e9d	8c179de9c16f8fd2663fedf146547dcb063992fc34be3b208f67ec3c71d3e72e	2453cf81-de2b-42e1-9cbd-394d92e735f6	2026-11-29 10:27:51.247	2026-11-22 10:27:51.965	2026-11-22 10:27:51.248
4c5c80fe-56cc-461d-9b2e-3b9c46cb5221	d8d84033d3cf76717e630f56dbd7d66e05bd11d8beb4c9428e36f520c7aee4fc	2453cf81-de2b-42e1-9cbd-394d92e735f6	2026-11-29 10:27:51.969	\N	2026-11-22 10:27:51.97
8563dfde-00e9-4673-8292-2d3d8024efc0	b200a327947ac97a2a161e96f8bd81f7881ce08905cfbf607f4041a41ea1e101	ecd14194-d465-4297-b876-4c714881b790	2026-11-29 10:27:52.207	2026-11-22 10:27:52.224	2026-11-22 10:27:52.208
083e69ed-80b7-41a6-b507-f1ae1f34fbdd	75c1b251f2e5cc13e4920b3f493a589ce6745025016f20ebf91b8aaedd14d610	ecd14194-d465-4297-b876-4c714881b790	2026-11-29 10:27:52.217	2026-11-22 10:27:52.224	2026-11-22 10:27:52.218
3d583585-f09f-4060-9c8a-f76e4ea1da64	8bb1bacf6e9ed4ea7ae4ce651350bf6fd743a84771ee3cefb51ad09fbcc42097	3d1bfe42-4c49-425d-aa93-9f8e9c52b45f	2026-11-29 10:27:50.865	2026-11-22 10:27:51.27	2026-11-22 10:27:50.868
60aa68c8-471f-4226-a593-6c3629948b80	b7364894b336e3f66b6545609aaaac779fa342f537c70e32ceaf620849bae3a3	3d1bfe42-4c49-425d-aa93-9f8e9c52b45f	2026-11-29 10:27:51.146	2026-11-22 10:27:51.27	2026-11-22 10:27:51.148
cb6adc11-51e7-49d0-ba61-3218ffc414f2	97b26c356d56547415082be611f7745cd15e2a99f4519cc07131a02735ec8c92	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 10:35:03.701	\N	2026-11-22 10:35:03.704
1195ce25-f1d6-4cd0-9408-fdeae12485de	064975612dca985dfc1edf89427b05e63821033b49b3ffdb3fb6511d943d0395	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 10:36:11.783	\N	2026-11-22 10:36:11.785
2f1277e0-1049-400b-91cb-69ae37b969dc	77ef3927773132f294a6bb6a536ab7cb63bff84a2d7be75f38c6cd22aee8b8e1	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 10:36:14.431	\N	2026-11-22 10:36:14.433
03eb4f99-3ef0-49e7-8f2c-08344b6f8851	ff2ecd10c3a4331c09a37442151c482d529c1cdac85f9311eff1c049d680ac87	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 10:37:44.391	\N	2026-11-22 10:37:44.393
9ac01456-a807-45da-84d7-65e44f0e6a1c	597b5b5b6758126d3763607001df676b078879738f3c9a2ffee32c99339c155b	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 10:37:46.968	\N	2026-11-22 10:37:46.97
f2c75e26-b1a3-449f-a37b-743731cd5989	eaa3c6f8f1c94fa31c661797b5764c7a0a5d3dfa960486bf5a38229598368cfd	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 10:38:34.544	\N	2026-11-22 10:38:34.545
795cacc3-5980-4ece-b811-5e7aabc50d95	0e752a40e05b6e3c4bbf792aa873f8d84db09f9c1c4d377dd9eef064a9955dd7	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 10:38:36.997	\N	2026-11-22 10:38:36.999
9e7f36cd-3ec7-48fc-a28f-8c8f3d9482c1	747dea53eb6c7c55d6f40b5f96894053169e1160789a2f64b65029057c91aabf	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 10:39:08.157	\N	2026-11-22 10:39:08.159
57dedb50-29ea-4efd-a352-2476764c3a56	81f31db50e052a4d41865fcb8d2c6403465d03badbe68c29b254958fa64b87c7	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 10:39:18.983	\N	2026-11-22 10:39:18.985
6edd597c-98cc-4330-81b7-66f242ca23d0	bc3e19399adfbded9178b31276e270a814798a33abd8d78ebe33610a5878c81b	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 10:39:24.994	\N	2026-11-22 10:39:24.996
6e2b4fd9-6d11-4f50-93d4-6267d9454855	8dacd5988c6c9e6f41002cddef6912dded7cd9e385bdf6541f1cc9962a1c4b45	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 10:39:32.174	\N	2026-11-22 10:39:32.175
cd3370a9-21f7-44db-b876-c40d72b76616	9fb1c044572804c4f6b30a8d086b76cf33cbb6d5f27b41af3a93cf78f56ee7f5	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 10:39:35.105	\N	2026-11-22 10:39:35.107
f84b649d-eb38-4e2f-ad9f-691d7e4c693b	cff9b726e5c7ac0d275ad4198d99f37df234cdf911d1b1aa3c2e9281797b6057	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 10:39:59.563	\N	2026-11-22 10:39:59.564
c8e14797-29d1-4ee5-ab23-3fc4f8af321f	4827dd8e6d59597b7115eab9b1435954d3532e847d5930a36843105eed563509	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 10:40:02.6	\N	2026-11-22 10:40:02.601
a9b6e27b-0772-4ac5-a001-be3a10e718c5	cd87756c50783262e1140b174e4b9ef32d73980880a1b5fef20be287ec9ab950	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 10:41:04.554	\N	2026-11-22 10:41:04.555
0b70da0b-2334-4121-8abd-398801b3239c	5c8d94f56ac7642f0019504c678334f6c45cb0c91f46703fb48c419a28ec0324	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 10:41:07.873	\N	2026-11-22 10:41:07.874
1dae5f4d-c571-4597-a8cd-f6b34b8fd564	4208b2e6485b99b8c9b6b1554b8b0f2e2721a0eb221aafb00e6953babfa4a41c	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 10:41:17.869	\N	2026-11-22 10:41:17.87
2bdecd89-7ce2-4121-a298-477ef0ab7d3f	ca9f54ba863e1dd9ebc435dd924bdf9ef3525e7aad2025f8a6a4e4e3a8df6b30	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 10:41:20.652	\N	2026-11-22 10:41:20.653
f377e950-532f-41ce-aa39-6e2eab955986	91ff30280fd1fe7523b4d777003e6c34abc09a702ac979d368dc36b0ad93a0c9	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 10:41:47.478	\N	2026-11-22 10:41:47.479
a1d5ca24-cd6e-426d-9021-6c6a781be041	7394306bdc8cfacb32c69563ab1e972d65ee89534d80636670263620e8861ca3	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 10:41:50.05	\N	2026-11-22 10:41:50.051
ba2f1a37-f309-4022-b1af-2c63b6fc48e3	b3ef45886acf71ed08546ae7006028de68d6b375841e6e2cde27ffe7d1ab148a	b347ca38-e44c-42ac-a846-63d4b6c28e3a	2026-11-29 10:42:22.055	\N	2026-11-22 10:42:22.057
9bc8ab87-2773-458c-98dc-c1785d102aef	c075cbf6459a77d48c068663c0aa8ce6773661754a35429ba831f320bf5f1dd7	9979cb67-e488-44d8-b0df-569a81cec64d	2026-11-29 10:42:22.056	\N	2026-11-22 10:42:22.057
183c97c4-b46a-4273-bf49-09659af5b0b1	9ef9a72b839bb6977d26dad1e53a5d2cb05e2cd99e3a0dca798156005eecd1bd	a17cea7b-22a1-44e0-a813-5f16ce79bc69	2026-11-29 10:42:22.07	\N	2026-11-22 10:42:22.073
98e190a7-9617-43d8-9bc1-560f83432ee0	bef9230d91298d4e19db96be19338fb48f8e279d9c6752afb9c7ef21e03fd9f2	e51a5048-6c2d-466a-ae62-613927b40269	2026-11-29 10:42:22.087	\N	2026-11-22 10:42:22.088
094f74f8-044b-42b6-b7f4-b21e455f7809	27b06141be31c12ddf0cd33745895e1f930d08e6aceda7481368f59794f8e096	24d8704e-eebc-4c21-986b-d85a1ed5a92a	2026-11-29 10:42:22.096	\N	2026-11-22 10:42:22.098
fa19af96-dac8-4606-a794-d7d1106d9e3e	adfe6b8f51302d1271ebfe681a06b9cdcd395ff19748df4bed9a2d6c5a523d7b	87dac236-69b8-470f-b92f-efef6a6e2d67	2026-11-29 10:42:22.324	\N	2026-11-22 10:42:22.326
9c5a98ab-637c-4a71-95c9-8a0dc33e3502	23becbd0608e9ad543b58b89e91eceafb2c2f8205069d9d8c4dbb021d55bf07c	17f8c042-b632-48cf-8e97-53a057ab03fd	2026-11-29 10:42:22.336	\N	2026-11-22 10:42:22.337
9af7cea9-18eb-42ef-a4e4-b8115040989d	34dd93c1f5140b14b9c4a6555357cef71830012a1d46cd29df2396033d32b570	7469c3f3-91d7-4857-ad8a-a6e99f73a521	2026-11-29 10:42:22.347	\N	2026-11-22 10:42:22.348
f87bd12f-2cce-4e27-b26d-11bfb71e791a	67b057103b38de516596e4e73ab5334cbc2b01eb5eb5a920aaac12a8dc16a4ca	6dffcd9a-0d48-4863-a865-8f96c2680bf5	2026-11-29 10:42:22.354	\N	2026-11-22 10:42:22.358
1729eebf-6331-47b9-b616-e3e4e2f9cafb	fedb829db557ee9fbea5a4e53ad0539138cf4f34eda8ef526c8680d57862904b	bfe64bf0-bb93-405b-a336-a1453240ac67	2026-11-29 10:42:22.374	\N	2026-11-22 10:42:22.376
0b4a81e5-7a9b-4450-9acc-d103b5453bb1	053527697846ada1baeacadb4eb31f51f2152ef7fdfd9de053de4d268a62ebc0	885f49f3-4df5-48f9-aeaf-9e7b29015b02	2026-11-29 10:42:22.59	\N	2026-11-22 10:42:22.591
7a625a42-a0ce-43d0-a4a1-68365b8b7605	99e9a0528e0d20aba6e2411ff0877d8553eab155ceb7f423daf427fcbfebb954	568f1967-6055-40f4-bd07-97ee79559948	2026-11-29 10:42:22.622	\N	2026-11-22 10:42:22.625
b86ca24f-6c93-4edf-87e6-255b4f44d627	6e954efcb941e10a605a16bb0b779619f25664c55fb3d64ac0ae934232de6608	fd109b4c-5829-497b-8da6-252d426b4a4d	2026-11-29 10:42:22.634	\N	2026-11-22 10:42:22.635
c6b08439-da62-428f-b7a4-c475fe182d60	4e8ec81cb94998f154b4a6fd3171c04c36dbb0a8c2248f171608375e33064e75	9979cb67-e488-44d8-b0df-569a81cec64d	2026-11-29 10:42:22.587	2026-11-22 10:42:23.34	2026-11-22 10:42:22.588
89553a13-726e-441e-ad85-63ddf4efd6db	235646511e87a46d8b3ac4017ce66f59a82afdf6828fc05a0fc83474fa84989a	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 10:41:08.004	2026-11-22 11:07:36.311	2026-11-22 10:41:08.005
2f07b90d-cb56-41ed-898f-71e48a63287e	e151e53e64c83c86271ad8461de0f6e276cc882185d7f54be4d9813b7724fdce	eada0765-6f29-428a-9687-0f1bdf9aaacb	2026-11-29 10:42:22.119	2026-11-22 10:42:22.819	2026-11-22 10:42:22.121
49c2584d-df85-4db4-88c1-987bf30ea0c1	d4f1b564398356094d25d1d1ff2cbf31729ad1e3c8a1e57f4abba34f45fa7206	eada0765-6f29-428a-9687-0f1bdf9aaacb	2026-11-29 10:42:22.405	2026-11-22 10:42:22.819	2026-11-22 10:42:22.406
b4f14d89-a29c-4272-be72-37f693a44b75	b49b6d00c6f7599f042a5679b793708491efb7243a0aa1fe5dca3e3f52e735fb	eada0765-6f29-428a-9687-0f1bdf9aaacb	2026-11-29 10:42:22.69	2026-11-22 10:42:22.819	2026-11-22 10:42:22.691
7edcd77b-e78d-4953-b4e2-1d12a1cf2138	4cedae7cf42c83f2d5567dc85a4ded9569c80f98b88b8a824320791f71fbdaac	17f8c042-b632-48cf-8e97-53a057ab03fd	2026-11-29 10:42:22.851	\N	2026-11-22 10:42:22.852
d19d3766-1048-455f-828c-599bf67fef67	c4a42f9082817abb6364dde140e6fb445a2c13cae531a2ce094228094e5af43c	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 10:42:23.09	\N	2026-11-22 10:42:23.091
7be1345c-49b2-4c05-aec6-cbb813d1be4f	5e8a0cf79b1560dd8e18b5f0e107e8a6029f4f2cf6df980c1d92296ec3a3e9b9	9979cb67-e488-44d8-b0df-569a81cec64d	2026-11-29 10:42:23.345	\N	2026-11-22 10:42:23.346
f02ba8c1-7277-4e8d-bd7e-7ea5f394eb89	b735c2bfb1524a36ce350fa7a8927be0b60968b0a3cd067dc752bc49073965b2	309fc985-8fee-44cf-8b3f-7c963665f95a	2026-11-29 10:42:23.586	2026-11-22 10:42:23.604	2026-11-22 10:42:23.587
546ec53a-9c01-4160-b122-d763a65e9494	8530ffe3af79685349657e6c0473b0a2d941def72df754f57f64a30dcec98f27	309fc985-8fee-44cf-8b3f-7c963665f95a	2026-11-29 10:42:23.597	2026-11-22 10:42:23.604	2026-11-22 10:42:23.598
cc7e0599-909e-4b37-95f4-820faff369aa	de6eeb5016e0e434c370875336d40259966906f9e533ba5b2f84e70cf08d8b20	754478bf-6a8e-4cc5-9aa9-f783e59d909a	2026-11-29 10:42:22.902	\N	2026-11-22 10:42:22.903
bfbb28af-dc45-40c1-a8af-e584858f0d35	cd82d90c60bf35aaa79b9b01393f921e49f0b50a58b9130993397638ecf3d4fe	cd86f585-75aa-49d3-ba65-a6fc616c5d70	2026-11-29 10:42:23.139	\N	2026-11-22 10:42:23.14
e31ffcdc-f93a-42ba-ba90-158883f64824	1969ff52078fba35875b7752803fe07b081a6bb320f6c90e5201d4dc251031e9	d8bcfbbb-5b9c-41f3-8c41-e601d5e105c3	2026-11-29 10:58:25.884	\N	2026-11-22 10:58:25.885
913f2c6d-8344-49a7-9e8e-da5757d558c0	1e25e12482cb224768fca70de7459ed256000632b7d24a1208aa294245b77f3b	20e961e5-4364-4013-ac83-b3cdac902909	2026-11-29 10:58:26.125	\N	2026-11-22 10:58:26.126
4fb4065a-2c95-48f0-89e0-85c4d6eb3d41	5bd40cfa13827f96f5aca0f3890e10b1b92e028aaded11643c73bf37743d3e23	912d1cb2-475d-4b50-8a70-7c6efd34617e	2026-11-29 10:58:26.365	\N	2026-11-22 10:58:26.366
ffca3208-eaa4-4c49-991e-5e4afbc1db41	f44fa0c2b7a071aef776dc866661291f7d7d6f5eea8c35b4f80570584dbdba2c	4c460def-df40-44ae-85e2-abc656c5c0da	2026-11-29 10:58:52.701	\N	2026-11-22 10:58:52.704
33a9a75b-bb71-485a-96d7-b603e18f39eb	a33ede5b050d6b2709645a8a068bae222bcf1ea6d185ee59661399941f22b5ce	a180a88c-5a9a-4731-add7-99d767857c44	2026-11-29 10:58:52.942	\N	2026-11-22 10:58:52.946
26dedf13-24d9-4e43-8d2c-3ddb34915881	6a3ecf08d4a199bb3ab064a63c4d1a863851f38da385eda750e9ac6a8e70c7ca	6f799c5a-2d5d-417b-9baa-f7b0c803557a	2026-11-29 10:58:53.182	\N	2026-11-22 10:58:53.185
183798da-ce84-4a3d-b011-72063fbc759f	31f504aae9ab5b750b2f7802bb8b8720163fe37ab195044b32f4ef368fa4941d	02768d0a-f84d-490d-9480-615e95224db6	2026-11-29 10:59:10.29	\N	2026-11-22 10:59:10.292
20aa799d-ce2a-4149-ac6a-5fcbd8be8400	1c4c51d0fb8c8a895a127622e10d49a9f176b31abcceabf8001ee4239bd59777	2ae75f04-e851-4d24-81dc-67588ba24232	2026-11-29 10:59:10.586	\N	2026-11-22 10:59:10.588
ebdacb54-4de6-4d36-bf39-da108417f3f7	bc3081800f792f0261f4b9e929d23cee54128754c159f52424035f48437f0858	6f863f00-571b-44cc-a075-aa555329997f	2026-11-29 10:59:10.881	\N	2026-11-22 10:59:10.883
6109622a-37eb-439f-858b-61a2f6073921	326a1356c1c3bec8eec0849d0d12a9f89535bb3facf6cbe223f12153d0e036dd	c93c737a-04f0-431c-827c-5f260c78cf87	2026-11-29 10:59:11.074	\N	2026-11-22 10:59:11.077
4654eb03-38c2-4355-a332-945edf4a114d	06b775979ad37913eea142a201c02564fee6670b2bb55e9881bd223abe6a6393	49c5925b-fda2-4bcc-b6b0-87b387231f58	2026-11-29 10:59:11.178	\N	2026-11-22 10:59:11.179
fb069c89-3a5c-4c2c-80cb-3e41dafa2986	b301fbf92f9335ff9085463650928d9269f855439185b181d950df7b010a1705	23e55200-8e86-4e87-92e2-b55e228b92f3	2026-11-29 10:59:11.218	\N	2026-11-22 10:59:11.22
5f595c60-167c-4a55-a244-cf9649df93a7	32ab27c27d297463dd70cb0e2875ca459045475cc674c005c5e0d2b09847c05e	11947c9d-6f0f-425d-b26d-1cd07a25138a	2026-11-29 10:59:11.221	\N	2026-11-22 10:59:11.225
ad415aec-1e6c-4e7b-aa43-10cf0f22f6a3	ef23d9d9068c084f54ba5beb72c234fd2c1be6dc5b6c71c92d52332afbc788d9	245a9356-c816-4507-8269-0fc18dd346f9	2026-11-29 10:59:11.231	\N	2026-11-22 10:59:11.233
05764d3a-faf7-4baf-b120-29ae1d1453aa	2a2afc4513914240b8ac9d706fff806a6b3b2ae6e595be26f27d31227ba65ec5	c1c59c54-9a85-4892-957a-65df00abe10f	2026-11-29 10:59:11.344	\N	2026-11-22 10:59:11.346
71f881c7-2449-4878-8dca-1ddb5ef88157	fb0a3d53e18c87ce539c0ccd63c4507423ffebf9ebd4081ea489a63f4d06f314	459fd1f2-01ce-465d-b584-90ce7e7c8297	2026-11-29 10:59:11.43	\N	2026-11-22 10:59:11.432
3dd58552-3059-4d35-a294-62b6f28d8e3e	a3263c63e39058c4ba33dc23e8078102306157237e1145c7b01ef5dd8754548a	0e56d598-d475-40e8-9e5e-8a18e9c9c26c	2026-11-29 10:59:11.465	\N	2026-11-22 10:59:11.467
ac234d6f-0058-4287-b698-58e73c5b023b	bea7aabc3a8cf7ab2a75c54a3b297ea726ad54349922501ccad331a9760ced10	a8f2696e-55dc-4a9b-97f3-8bffbcf18c45	2026-11-29 10:59:11.468	\N	2026-11-22 10:59:11.471
1ca9cf2f-75d5-4e1a-956a-faff978c6dce	afb6fe4ac6745576a257f2a6905294c1145ef7b3813ae092f8f5954cdd9eebdd	e4414a47-df1f-4ad5-9049-bf14c3ed41cc	2026-11-29 10:59:11.481	\N	2026-11-22 10:59:11.482
d2728582-ba77-47e5-b8e3-267c5c9da16c	d629a90e9d854cb4fc78ecdd72e109447f1feee7b396925d04addafde3240f1a	14397d2c-11bd-4647-babe-a86165af58d4	2026-11-29 10:59:11.689	\N	2026-11-22 10:59:11.691
b25414ad-505f-4f38-ba3f-244798ffafef	49d5df0656e52fe43e981bcb33ae5e165defff39e2ebe7acfbdea05cda300371	04a4b6cb-3c82-45bb-acab-d78e0713971a	2026-11-29 10:59:11.723	\N	2026-11-22 10:59:11.727
6f953bb4-2f2d-474b-930b-b8a02fc28f04	1427fc5e2a2f767fcc2e4d98b7dfb9f22883ee570aa1598b857f1aeb5324b61a	e840f0bf-ae92-4006-aa6a-de7fc0c1873d	2026-11-29 10:59:11.731	\N	2026-11-22 10:59:11.732
e519cb8a-2624-49d8-8dcb-b7df945696c5	bf4f1fe7f54aa6f673cfd6b393fe3fe6c5af6175b8c871ba87e4772c73154887	b342c509-acd4-40e2-9a9e-a576fa6e5061	2026-11-29 10:59:11.113	2026-11-22 10:59:11.762	2026-11-22 10:59:11.116
60a89be0-345e-4fa8-ac8f-997a35defff3	c477023da759f74d9782931339343fdd9fd21386cf2332679205d79d03a5c87f	b342c509-acd4-40e2-9a9e-a576fa6e5061	2026-11-29 10:59:11.379	2026-11-22 10:59:11.762	2026-11-22 10:59:11.381
3032dc2c-55b2-4b76-8eb4-5cf9dcb799ac	1a01ee9d380c4410f835d35ff025377879c782310a9a2107a354c0bec4e29414	b342c509-acd4-40e2-9a9e-a576fa6e5061	2026-11-29 10:59:11.651	2026-11-22 10:59:11.762	2026-11-22 10:59:11.654
5445023d-53b2-4cf6-8d2d-8ee71987261f	4a4aae5ef0770f77e9179c35eed053e3df24e5f99838f155611d67d980485932	c1c59c54-9a85-4892-957a-65df00abe10f	2026-11-29 10:59:11.829	\N	2026-11-22 10:59:11.831
7aec861b-7053-42d9-80e6-6002cfc7497f	2ad15755bc7b5477895887c5cfdbc25b173d610a60ff63ccade0f622b948b166	d3f75e7f-79cd-4f70-8bf5-d71a46c0c651	2026-11-29 10:59:11.989	\N	2026-11-22 10:59:11.993
d43a31e5-615f-4c4b-94f9-e9609ed0483a	cd1226afc0cf9834e3545f0005643dce31c4ac73be7ff6b6f76ffd42749442cb	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 10:59:12.08	\N	2026-11-22 10:59:12.081
bf34ed70-27ab-4a30-a273-854d50e06ecd	960a847acb8d09da82dd689f1a253d8db6d811219224be010eac87a28e602450	35de3760-92fd-4769-9d8c-11acf299ce83	2026-11-29 10:59:12.227	\N	2026-11-22 10:59:12.23
888136e9-5085-492c-bc8e-eb43efd48382	f139ba32253e9305409230a0b244e3602e4a1820bc1d09eb3cdded185e21c287	c93c737a-04f0-431c-827c-5f260c78cf87	2026-11-29 10:59:11.589	2026-11-22 10:59:12.326	2026-11-22 10:59:11.591
860520ee-2b97-4d5a-acee-0129f4bd2a15	62212d879a8b558143d0da713b340619906748b41da39911c1c184271ff1b64e	c93c737a-04f0-431c-827c-5f260c78cf87	2026-11-29 10:59:12.33	\N	2026-11-22 10:59:12.332
c4bd9b6a-295a-43fa-bcb5-7f16417cd78d	e920815fd6da9592f7ae53d8046a754459451d31ec4d096059a9bb7fde9863de	1e062702-c6de-4826-a848-4c15c3b0a27c	2026-11-29 10:59:12.567	2026-11-22 10:59:12.585	2026-11-22 10:59:12.569
4b9a3003-c7f1-4f14-a5e2-c25c46521287	eacd50758e7163e486c1f9de765b73be2442eb65578d172cee22392b2aa10086	1e062702-c6de-4826-a848-4c15c3b0a27c	2026-11-29 10:59:12.578	2026-11-22 10:59:12.585	2026-11-22 10:59:12.579
dc48b529-8ff0-45f7-96e6-1f6568f8901a	41f8081466a846e8bb2458a4bb0599671c8f66668c34d28863fd729c8b85ec97	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 11:06:02.68	\N	2026-11-22 11:06:02.682
81e93f80-6aec-487a-a1b6-2c2a078defe6	5409101256b39228ce3358444a0c4f6114db502afcfdcb280f1352cb4137a9b3	4bc6bd4b-da8e-4372-8bac-0333b1e85ab1	2026-11-29 11:06:31.434	\N	2026-11-22 11:06:31.436
4810beca-c182-42d1-a7fe-e598bce48164	b671250fb9f7c7ebb367e87f4fa206b9e9e7fcaf7fc846188b24f4b84546d3f0	1302fef8-4b27-4105-8596-a34489c6c8a0	2026-11-29 11:06:31.436	\N	2026-11-22 11:06:31.437
3bb0ee62-c664-4370-875c-33d94e9fe59c	2a22acece53e909cbffb7cacf4cfd31d5694975855da66a6608a83989a3636c5	52982a88-12e7-4a4c-aafc-6534a8542ddb	2026-11-29 11:06:31.505	\N	2026-11-22 11:06:31.511
188164c9-ca62-4538-89f8-22a53c88c345	e9b33831ca8543d1db59c9fddeeec93900f4a925d36573a4f709a6dcdfc3915a	6f0c5a39-62c6-49b0-9305-3747a819cf83	2026-11-29 11:06:31.534	\N	2026-11-22 11:06:31.537
fc869d92-fe47-44ca-b4be-d3c5ebe780c8	cd9a7de064d01f6c5508a87f652273e9a5a9bac2102d4cedf4d2d160ff1c3cc7	6eb0337a-0d67-46c4-8936-66203ebb5009	2026-11-29 11:06:31.546	\N	2026-11-22 11:06:31.549
14026dc2-664e-4724-8cee-2ba77e37dc92	2542a564f447c7aadc69226d99e2b2f64838f2aefa2fcd3a14e9251ef18422df	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	2026-11-29 11:06:31.563	\N	2026-11-22 11:06:31.565
f406708f-37a2-4a0f-9c98-8429f2e161fc	0bc5643a519c152689c35e8acde80bc5fc8c8bbd6c152732994c43195b1930f8	4d62bb62-77c2-48f9-8e07-3e9ea0a6a73d	2026-11-29 11:06:31.852	\N	2026-11-22 11:06:31.855
b922842c-0d1b-46b0-bdde-ff44b956bdbf	57f64c1ed57a5ff1f35d233352b3fcba036b3fa3c55c63a1d8a2d79d88ba1e4c	ebdad843-b10b-492a-b5bb-4ae10b4e5340	2026-11-29 11:06:31.866	\N	2026-11-22 11:06:31.867
12e7aecc-0533-48d9-9611-d3a6b558ca0a	20cf079400f953e1d4e6c62f081da67f4acacc9fcbda6b313016beca5e698c0b	44add884-dad8-4e5a-a51f-c16a642f3873	2026-11-29 11:06:32.16	\N	2026-11-22 11:06:32.162
4094b6d9-353a-4121-8d45-838cc0e590f5	91fe6be3b30d80a684ab6fe614e31cd60a426e802ba935d1e7a72518fd820002	3ef04ba8-1823-457e-bdf2-2741130aa339	2026-11-29 11:06:31.556	2026-11-22 11:06:32.324	2026-11-22 11:06:31.56
a4046a69-e1a6-4cd3-a51b-467cf14cc0c7	b119a9a3dfb3758ddca57e94526b2417e9e44c1a3399ada698d273275c4de9d3	3ef04ba8-1823-457e-bdf2-2741130aa339	2026-11-29 11:06:31.855	2026-11-22 11:06:32.324	2026-11-22 11:06:31.859
b805dd02-7ef0-46ea-8f88-631e5a852c2c	11ca96224fa942f4e714ba7a0a5c56816241b3d2fd5fa2f6b0f025c0abbe359a	3ef04ba8-1823-457e-bdf2-2741130aa339	2026-11-29 11:06:32.172	2026-11-22 11:06:32.324	2026-11-22 11:06:32.176
a3d5a7d7-6c1a-432d-8aa8-b4c355bfa462	02d834eab8bb402d0b7a295a9dab79ecae7abccff5fce0712308eaa8af1924e1	4d62bb62-77c2-48f9-8e07-3e9ea0a6a73d	2026-11-29 11:06:32.399	\N	2026-11-22 11:06:32.401
389d20b8-6e07-419d-9625-8149a6291a9b	6aabb29dba55e3b81a33045261bea4151c73c35e823a724b59d97a00995431c4	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 11:06:32.645	\N	2026-11-22 11:06:32.648
81dd1fca-0ebc-4cc8-95ed-5051c8439a2c	1aac30672972286b8252d2b54be8bbe6fd3bcc87c4c1bb96e5eaae939328d99c	6eb0337a-0d67-46c4-8936-66203ebb5009	2026-11-29 11:06:32.129	2026-11-22 11:06:32.898	2026-11-22 11:06:32.131
dfcc17b3-85ef-44a1-bdad-ded1e2dd74b4	8a90c40cf156881f8622f6f573d97ede4d8ccf4b2668d891ce9643f953600b85	6eb0337a-0d67-46c4-8936-66203ebb5009	2026-11-29 11:06:32.902	\N	2026-11-22 11:06:32.904
8b6e9163-6436-437d-8ad2-3a87fc6b7c03	30c12e62ae5636755dc6eced1f46f4b4667f0584597f18c7434dd1a39168fa12	c32cde07-3798-4427-9651-2e442500f687	2026-11-29 11:06:33.147	2026-11-22 11:06:33.165	2026-11-22 11:06:33.149
65b5dfca-4862-4318-8bef-cb8a53502e77	b053bd0fd8cf2ea305e738ae74cf2f5f0ccf0db8ca3bd8272c997e5dbad757e9	c32cde07-3798-4427-9651-2e442500f687	2026-11-29 11:06:33.158	2026-11-22 11:06:33.165	2026-11-22 11:06:33.16
3ccec876-cfd8-4025-98ec-4a65c1308675	d67264960ebfb64a86ed0a0aa36ccb128bf558c90ef9c487c6e378e3be2e68de	7b0dbcf4-d748-4a20-b6b8-1429d8471663	2026-11-29 11:06:31.733	\N	2026-11-22 11:06:31.734
8724ccd7-d798-4e30-807f-1de1a0cf0bd6	1cfd9df0d6877ddb8af517b61fdb9a1df5141867c7657efc93a1870eaa659e1c	91e6be61-ca06-4bb8-9843-38b5edc72e0b	2026-11-29 11:06:32.005	\N	2026-11-22 11:06:32.006
e42495e9-2f5d-4b66-8b97-3c030846db72	c71b682ebbfc77ee6b3e86c96b57e5c9bd4bd33b6e32ef5d1ad5e7503559916c	af870543-67bd-4053-a056-9cb0328c528c	2026-11-29 11:06:32.294	\N	2026-11-22 11:06:32.295
b8cde658-2ad5-4b10-8058-15f0a4feb15e	54f4ae2ce392950c693d52323ac7eed38a26b0c643be6493cdcb8d885955de59	707b69df-c296-4059-9aa2-b0b8882b3c97	2026-11-29 11:06:32.557	\N	2026-11-22 11:06:32.558
0598e45d-f018-4b5e-ab6e-ff219b34013b	5e65dc6b3b3f182d58f3259a3931632d3d691094daffc7ca3cbb5bbe987efbf2	29db8df8-1b56-42f1-9da5-e687727e448e	2026-11-29 11:06:31.735	\N	2026-11-22 11:06:31.737
8ace5e7d-7816-4c0b-8746-ea4868a2d976	3737150c874411dad39bd9dacc7f873512e116017485a556627206bf35defebe	3ea42b7f-99a0-4120-991f-7047bbb58050	2026-11-29 11:06:32.033	\N	2026-11-22 11:06:32.035
a5100d1a-f201-4157-8185-4a6e91abcbf2	6d6f61c3435d8a2a4c639f0b806d02d1d714920983e850943b5c3ed99b8bbdae	15372eae-1d2d-4d1b-af92-e71b76d3393e	2026-11-29 11:06:31.806	\N	2026-11-22 11:06:31.812
afed31c9-4112-4fa3-b971-be5f3a91d0e6	faa32a922fa7e2eccef089c43f4b9a1b01ba7a130b8341dd40bb91df6c9705f3	6b36993f-4add-41d2-aa57-89b13b0ed876	2026-11-29 11:06:32.085	\N	2026-11-22 11:06:32.09
4a13af2e-ce47-4425-87d6-e1735713c8a9	ea01ec393686980f275eb72b6f7f7e22b37cee7de458c39406272d4b68de1172	7c98ba9a-4b3d-4780-8493-facdc9ec499f	2026-11-29 11:06:31.836	\N	2026-11-22 11:06:31.839
cada542c-4436-40d6-b999-cbb1fc5c2cef	5268591859fee0bf64a183276d97cc3c54d972424461e99731d5d68639732fe1	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 11:07:02.052	\N	2026-11-22 11:07:02.054
04bddc5e-b735-4151-b567-9c42af6f7425	b5c4ea13e58f793819b3f081f2714f88d3c9f1512bc4824d2304c6e849b62af5	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 11:07:32.696	\N	2026-11-22 11:07:32.697
50414112-a796-4c6b-b5ec-45a84e0d8e1d	87b702918abdd54e83484c6c53e39cf86ba788d6b01f983447ab31e95cee7b84	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 11:07:36.317	\N	2026-11-22 11:07:36.318
21484fa2-dc3d-4432-8263-234db56cdf6d	c8317dea8869da122e0c1ef68832e982cfa50ffeab3aa38b2cfb00b0f4a53ff3	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 11:07:38.746	\N	2026-11-22 11:07:38.748
12a5497f-babc-4d2e-9d91-3209562534fc	e212d26fb5e631500e1ce3e1c1c6d2574354a795c593c9339f5eba3adce3c0b2	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 11:07:45.994	\N	2026-11-22 11:07:45.996
a800a75f-f574-4d70-8497-b68f9ae882ae	0b6b251a5b87adac66c042600a82f8a70f62eb0db94b444cf42a47e92bb0d9b5	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 11:07:49.015	\N	2026-11-22 11:07:49.016
9d2e4b8f-7c55-4139-a307-8c4d3a5315c2	e28536031b91d9738ad33d0561c9d7a7df4aa1844428d6c9e86cb921adcf227e	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 11:08:03.211	\N	2026-11-22 11:08:03.213
beae704a-7efc-4c75-b7a7-62c65bf79bd3	1de1764f4a017ba65d59209ad7f4ce7ec6b4596d210c7a78af58c626d3cf2ce2	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 11:08:06.167	\N	2026-11-22 11:08:06.168
1c26fc10-431a-4fcd-998d-ec8f31a3927a	8c70a201893298eac7b0f69b2733c33ff8b76f763adf155b93e71b8e1e9073d4	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 11:08:14.695	\N	2026-11-22 11:08:14.696
7b3d4041-6da4-46e8-a905-bfa79d36b94c	2797724b7cd381086b95209aec32d4fb0146be83ed97cc88e55f814b5beeef26	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 11:08:17.081	\N	2026-11-22 11:08:17.082
2575b70d-142c-4148-9d4f-be753f3f43a6	027ae7d382a7f3a18df6bdac0ad1a635538a4c9ea5a290f70c04d6f43a63a1c1	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 11:08:26.83	\N	2026-11-22 11:08:26.831
80775f35-96b0-4003-a218-3c61cc8572e8	ce7a1d5993e0d962e2197e4f0940d2be8523baddd8313c7c8f70865ac2c42ead	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 11:12:20.059	\N	2026-11-22 11:12:20.06
6abcd22d-5317-4c10-b0c2-a724d738f3bd	0fd2c9dbcc8102c3a332a5456aed4130d5c3dfaf28a954be3b0bef7206b763e2	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 11:12:30.531	\N	2026-11-22 11:12:30.532
51cd51cd-2fb6-4e80-9d0c-b71a8cda92f1	1bc776c03610db470c20ad1b80b19a3a769f416dd363e7c40b3b76958581ff13	abb68e9a-9974-4371-868d-ef5a78bf6045	2026-11-29 11:24:42.634	\N	2026-11-22 11:24:42.638
d5888ec7-c5ac-4313-ac86-770e31fcd839	bcb27ef562739687610704d213dc3ea4a104002bc7be11ecac68f1d2a25cb9d5	1132af97-784d-403f-8439-ee32ce4c6295	2026-11-29 11:24:42.868	\N	2026-11-22 11:24:42.872
a99515bf-0ab9-41b9-a025-292bbf86dd7b	eccc44049df1a3dd4ff2f8e106978b4c8ba0be778d25603aedb4790d6115bd48	f94f9477-bc05-46e6-b444-9bb14d4ce5da	2026-11-29 11:24:43.105	\N	2026-11-22 11:24:43.109
3a13cb51-6408-48a4-b004-bdb9addddbd9	dd5724072fbba45c57ff330f0dd680ca9f8c7a6e30581f7ecfaa4b08ceaa58d2	6a3159ce-3ec1-46ee-8854-079b5cef5d0c	2026-11-29 11:25:10.125	\N	2026-11-22 11:25:10.129
dcb264a9-8e7c-4616-94d4-0d174f67a358	5d3c0d85e635a620a1afb706a7ec6e36fdad7433270dfd21c60a5d0efac434bc	efeb8cd7-f7cc-4dfd-8689-240f124ae2a4	2026-11-29 11:25:10.361	\N	2026-11-22 11:25:10.364
bd0c75ab-0cb5-4c1b-89ac-af93d6ba539f	7766af603da419fbeeb6ad8ee5ffffca73ea9459e709a730f3835dd96dc0486a	5db3fe47-163f-4f45-82a3-256bc87a79b2	2026-11-29 11:25:10.598	\N	2026-11-22 11:25:10.601
0c23939b-e4a5-4a86-a92c-1aa6721617f1	de475e6a8e7ab076d2a10eb7b0551731684fe73e7a6e2039804a17838013c42f	84ecd965-cf9b-4db3-92a0-2fb64a3e965f	2026-11-29 11:25:31.375	\N	2026-11-22 11:25:31.377
056f9831-916c-4dc4-a3ba-b793c9e2eb4b	b4162b551ad43c1c2828034accc50f98ba8b61c006033350fd6c36f42c9aeb1f	3517d75c-d341-43ab-b318-7b13f2026e31	2026-11-29 11:25:31.654	\N	2026-11-22 11:25:31.656
437da764-e8ab-4370-9970-5e1bf5c3ffb6	4393f3cf8b1469c42ea63cd7dbb222ce1f632fff9e6c9405cf82a6b96e01479c	b7cff01c-2936-4856-8de7-e2f1049987f0	2026-11-29 11:25:31.953	\N	2026-11-22 11:25:31.955
cb3d2a58-9672-4835-8ccc-d3e84438990a	754e61716ab127e0186674b526aaa7d3add5e32e05667411f255a5715b3556aa	282be406-30b3-4a61-a470-484970fa2ef9	2026-11-29 11:25:32.165	\N	2026-11-22 11:25:32.169
647c13c1-1264-4c46-bb1c-b9f1513360b0	cf52cba47f946fea6c7c20d3fbc22a45c2ce6d070e0bb7efd9186e7517c9dc2e	f7dd7f6a-8e5b-4475-820e-8b796a13b4d0	2026-11-29 11:25:32.219	\N	2026-11-22 11:25:32.221
f881b399-31fa-4cb0-a80e-101e49c4dab2	d9558bd4346603de70c81f3b2ed19003ee6e74cc34c866a6145d67ecfdee68d2	cd78682e-cc1a-4cc1-b024-3222b9c5e339	2026-11-29 11:25:32.255	\N	2026-11-22 11:25:32.256
121ffb6e-cbd3-4761-818e-76ce95319d91	5ece917ec741749b11aad1b000e44c9b371c4d6e53877077081ebe9e6840efac	50ade227-7e8a-46fd-8685-2e2878c91b01	2026-11-29 11:25:32.292	\N	2026-11-22 11:25:32.294
a905a556-4002-45ca-bbb4-2a8f61a08633	797a6d6d05664655acb28b4d455f1ec00f866ae14fc9a105797601996a74069e	7a09bda9-bcb7-47db-9d6f-9cde4f8fe7cd	2026-11-29 11:25:32.305	\N	2026-11-22 11:25:32.307
b994f986-9a90-414e-97fe-106c11c0eded	243fccfcf763481d06e7497a9be36d1da5666324861ccb0a381b1fc8c8656812	6ad0fc2b-8f80-4225-9bf7-bdfe63dcfcb2	2026-11-29 11:25:32.417	\N	2026-11-22 11:25:32.419
8190d10b-17fb-4143-9e32-2baed96ec071	e79e03d9b4822d7034ebe3edbe2459985ce5093601a12bfe0a607c772b8dfb68	d97f7a68-1e5b-4bbc-a2ae-efdb6e991a47	2026-11-29 11:25:32.432	\N	2026-11-22 11:25:32.435
bac2842e-2aba-4c63-b8f0-2689736eff67	d178f26ac3910631d7d230533aa347059289122b51ef15c8c62a11533eceecbe	8ce31ba5-bfb6-4062-8788-1d55d758fd08	2026-11-29 11:25:32.502	\N	2026-11-22 11:25:32.503
1a80a89f-fb04-4be8-bad6-d82404c7aedf	8c7f751c7972fdec1edd7c402f67f9991e4037f8b20760f8320ae68af33bfe06	5b7a3daf-7b92-462f-9fa1-95928376fca2	2026-11-29 11:25:32.517	\N	2026-11-22 11:25:32.518
e6bd72f2-7d98-4a24-b870-4035d2a62c9f	5a5069d517cc0e2797643d94f57ebff04fca71c3d8758d81d45d40655055511a	bc905c8b-feee-4610-8e4c-c09401916566	2026-11-29 11:25:32.556	\N	2026-11-22 11:25:32.558
40483def-3684-4867-8c88-33e9f1850dc7	7053e1edb009088808938ad6999d913f566c8e844bbfc0cd33539cb041e82d8f	f7687de7-1987-44af-85d9-9fcc9f286770	2026-11-29 11:25:32.571	\N	2026-11-22 11:25:32.573
51faefeb-974f-4d7b-8eb7-32950f56b2c6	fc3f41d012379a6963ba852d6b04079b68b812e47e24addcf21b404a3702b8e1	7d5c1d7c-e190-4cd7-a73d-a3b2d317422c	2026-11-29 11:25:32.685	\N	2026-11-22 11:25:32.687
3651275b-5a74-42c5-a471-221901ce3fee	d6c874a92c9f6353e550e6a4a25af8538af5ada096264ccc4d8fe148fb3c7762	383ded7b-56cc-4419-8926-25fc9318ea0a	2026-11-29 11:25:32.764	\N	2026-11-22 11:25:32.765
39f9e0f7-5a5b-4077-9a3c-ba9ae9cae2f2	c41380cc8501b1df5cd4819bc7806aafdad382d26b163e40ca5f3df5b55ccbb7	b6225e12-d48c-4709-97d5-6be7b6ef360d	2026-11-29 11:25:32.774	\N	2026-11-22 11:25:32.775
1b142626-b4a0-4ce3-8fdd-b08fa731a477	7d311d06d822f8dfd6ccfa23385163272e815084b15ef96646040e1cd1dcc52c	8890fb8f-a65c-4c1e-90cd-cb9d063b7634	2026-11-29 11:25:32.81	\N	2026-11-22 11:25:32.813
247c6478-97c3-4311-aa7f-fa890e95e715	a338166d859b11e7d5f766a0b5f3454d80d789142c92bd0df0bd4aeb10b9556a	599a1a84-5e64-44df-acaa-8e4c4e40cae3	2026-11-29 11:25:32.839	\N	2026-11-22 11:25:32.841
a67d0ec6-6e12-4357-9b3d-f00fe314047a	33624932d5986ef40ed23b9d48244ba8d3c77f271ce34e6b1c659e62b165980a	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 11:12:53.241	2026-11-22 11:37:55.06	2026-11-22 11:12:53.242
def9fe7e-e8d7-4adc-9ea9-c1164bc0ec9e	381be913e5d333e091c33501b5fe7e27f87a3487ead075409c0f7fc527551e03	fed47de1-aa48-4bd6-9c68-199068e2cf77	2026-11-29 11:25:32.286	2026-11-22 11:25:32.999	2026-11-22 11:25:32.289
f7e3100b-4e72-4107-be64-2a710e8a7dd3	a4612d7fcda91c7b5b33085c20eb7ba6a15af389cf7d8607b857b850a7dfa70c	fed47de1-aa48-4bd6-9c68-199068e2cf77	2026-11-29 11:25:32.571	2026-11-22 11:25:32.999	2026-11-22 11:25:32.573
bd23ab86-c060-4ce7-988c-095ffdf5db56	f24062af285491091e910c6c2e5882806076d06a484985925e3006bbd694f12c	fed47de1-aa48-4bd6-9c68-199068e2cf77	2026-11-29 11:25:32.859	2026-11-22 11:25:32.999	2026-11-22 11:25:32.861
f511670c-b113-43dc-9b26-cf66051ecdbb	46b683cefeeb244537261b9020b20875bcb2870b03e3bcce091b7b1be45e33cf	7d5c1d7c-e190-4cd7-a73d-a3b2d317422c	2026-11-29 11:25:33.205	\N	2026-11-22 11:25:33.207
c4c31141-369b-498c-8e79-7e3ca3d35441	0e70a164047a6caa4059ace8b50d9c10540cb539e562781393eb15fb3406b75d	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 11:25:33.438	\N	2026-11-22 11:25:33.44
dd1d1119-7035-4dbd-a928-64f876329fb1	6fa6da9ea17076bd40edbc3e7c767aecc77bbc4264fb08458bd482a9b3d16590	6ad0fc2b-8f80-4225-9bf7-bdfe63dcfcb2	2026-11-29 11:25:32.948	2026-11-22 11:25:33.683	2026-11-22 11:25:32.95
db4e4950-a975-4591-ad1c-41320e71bd44	ae466926e494e96049b26ef65757b3ffaaf1d37d2a34a49682e8bcf7b557891e	6ad0fc2b-8f80-4225-9bf7-bdfe63dcfcb2	2026-11-29 11:25:33.687	\N	2026-11-22 11:25:33.689
08d8fb82-e8b4-4eb7-85ae-bca8affc9452	be7f96fab7539617ce2655cdc6ca6cefac7aa3ee900ad72be429f86ffa568895	e59b6392-d01c-4bd7-9fdb-786873430a38	2026-11-29 11:25:33.925	2026-11-22 11:25:33.942	2026-11-22 11:25:33.927
fc51b722-bb42-4a46-8b86-32c68427aa55	19709d5ea2ad0d84957c6fee42bf8462850d696a9dc76b862ce60f91c4b59065	e59b6392-d01c-4bd7-9fdb-786873430a38	2026-11-29 11:25:33.935	2026-11-22 11:25:33.942	2026-11-22 11:25:33.937
1ca22c3f-f46d-461d-9138-365a39e18ceb	7be49caef09a450df620eb32d0a5f81059c102dad95c6278d5a3db656c6e804d	32246199-32b0-4a1c-a009-c51b0345f9e5	2026-11-29 11:25:33.058	\N	2026-11-22 11:25:33.059
d78cbbb3-86cf-49da-8330-99148a3edeca	4c0f0fc14bfb4b43d2985a4d4d4bfe8f24eeb192e75f37a10fecddf490ea57ba	cf56a912-9c6f-4924-96f7-8c62662045cb	2026-11-29 11:25:33.309	\N	2026-11-22 11:25:33.31
0385677c-7222-4c8b-8a4b-2a687c93b41b	fb192710cfa990831c1df0b631e5d54ae295e7376cb5621489ce84c7b2e1a208	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 11:31:03.935	\N	2026-11-22 11:31:03.938
9c74f658-a862-4618-b4dc-25b0217a4ddb	133b32bf5f4cbf0c9007e8470e79ff3667b54059f531a3e99cabd117614c2adb	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 11:32:42.414	\N	2026-11-22 11:32:42.415
ad2f2d09-1b69-4fd1-a870-7a96540a033d	5e293b2d7e614960b9f8d39d9893b46a4991e1ac449ec7152b8b51a1033c100c	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 11:32:45.77	\N	2026-11-22 11:32:45.771
3174664f-be64-4910-b693-ce48a03a968d	167b576f8916836a034367e13f7356f9b0641378423b9de5866c95263db22f65	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 11:33:43.247	\N	2026-11-22 11:33:43.248
30aec100-f252-4c7a-8db3-3c02206d9b05	66b9e38424584b36cf7076beb4b637d0af35fe6d58fb7a66fe08940610d53b57	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 11:33:46.7	\N	2026-11-22 11:33:46.701
4a164ff9-1251-485e-b03e-36e0cf6e9109	532c1e0aa32814b34cf3ab3b1ec9cc5e4e9f4ead47e71b22bf959c6bc411d212	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 11:35:04.442	\N	2026-11-22 11:35:04.443
294471a9-d5c1-41a1-88d6-27ba68d74746	1c86f083d349851cd3219c1003f6da57ea9a5de7e24eee172f440e10b8be0694	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 11:35:07.941	\N	2026-11-22 11:35:07.942
cdc9195c-d4b6-475b-a59f-e055c3ef531b	889c1d52dbb5bb5550699169a5389822720294ef633b061ca9d550df6c0320f4	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 11:36:03.186	\N	2026-11-22 11:36:03.188
0141a7c4-9074-44da-9092-bc99797b5173	5d891385890e0324c96dbca4fff7a06d8dbc54fd0a8ff89e24837fed489ade2e	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 11:36:06.36	\N	2026-11-22 11:36:06.363
8770e037-e2b6-4aeb-b72a-7e6b26e64a91	4ebaedf0cb7883b5b9c1b76fd8e775b6ffa4ddd0199f82f63eeb861e123046d4	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 11:36:14.28	\N	2026-11-22 11:36:14.283
9a25a8d6-58bd-49d0-a15d-a9e4def5fa05	f4d3bcbd4ec34ae038f575cb747c936f666810674c97f22ab4553a187978d69b	02d88990-b57a-4b82-a5b4-e44022b802f4	2026-11-29 11:36:38.191	\N	2026-11-22 11:36:38.195
d01d6698-8a29-4948-835e-5c0cd0423107	770544dbe51cc8737441f313626db7dae5919acbc841da0406858a3d70b1486a	147459dd-88dc-4f76-89cc-14a93c36d249	2026-11-29 11:36:38.207	\N	2026-11-22 11:36:38.209
4f9bdf9c-1a33-4fc5-86bd-66d5d2f9dd1d	659351ccc0db8b43e160890433cbaafe65cdc263eb44b1ea658a2553448e658d	4a059e43-c586-45be-b371-252f448bbdd8	2026-11-29 11:36:38.224	\N	2026-11-22 11:36:38.226
6767c2ad-4e85-42e6-9559-5c57b310722c	2660524750add0bf3a160e63b7a33f9c8b245aeed23cf80faa3d25865f2c8ee4	03049ccb-baf0-499d-aa2d-d5dce89114ad	2026-11-29 11:36:38.281	\N	2026-11-22 11:36:38.283
88e87a63-1677-43fe-a318-4a24e31c5c12	03062ccfb6cd13ece7698eb73ccb1959c1eff2cb71254dd35757271592845453	bbdc9439-1243-4dec-a18b-8b6512cede79	2026-11-29 11:36:38.295	\N	2026-11-22 11:36:38.297
eca5bf93-bb1c-41a1-a8a0-63ffcc8a1a49	d65af95b6fd43244cccd1300de4a417576bacfba34edad560991df9583d5ec2d	12a59ca0-ebce-49aa-b8c8-2d6021a4d980	2026-11-29 11:36:38.328	\N	2026-11-22 11:36:38.329
a2a695fb-ec0d-4f7d-8db0-686d1f4e55ef	fb947d7aa98113e4208888d195db6d7684269023cf07f44a150567c1a9eeb6f9	487c98dd-e41e-417a-81df-6160ad2f08bd	2026-11-29 11:36:38.329	\N	2026-11-22 11:36:38.331
82e9a6f8-16cb-4a3f-9cd4-ad8cfc5ada90	92ac508cc8e96f996858898ff42eaea4b2c6d2094f211e285838085522e1cee5	6108dc7f-6c15-4ee6-8a47-92ff7487b689	2026-11-29 11:36:38.488	\N	2026-11-22 11:36:38.492
f6eeef1a-140a-4af3-8e38-0e0c669a7bb9	26a6466cd45e69d87fe5c34a0d4efa06cec4a18aa1637a97c33c46c88d0b4d77	afe64e04-d47c-4aff-97a5-498252ffd13a	2026-11-29 11:36:38.511	\N	2026-11-22 11:36:38.512
48fe56ba-0e05-4a16-8ff1-ba55522fb31e	2e9f2f381ca4dd1c568917de2c6c2c2d5e698ab374bf06b2e19d0f986b71cb9a	8b1e24ae-3d0f-45a1-a091-b99dbccc5094	2026-11-29 11:36:38.518	\N	2026-11-22 11:36:38.519
1af76b99-f72b-4720-a47f-0687614efc77	ca9b46e7adce5fa45db34e3492ee27ff8c87f6ffd2442a1e1ca27d29905663c1	4c50ae6c-ef63-4e39-a5b0-d01121d5eb64	2026-11-29 11:36:38.582	\N	2026-11-22 11:36:38.584
931fbd5f-7810-4fd6-9c0e-f5b16fc94c27	bfc436095e8d5c7eaf5eeafbeb473973d2642e5f2c9d5a33991fa994e5425bee	c8830dc5-34eb-4c8c-a34d-e1ff3bc55773	2026-11-29 11:36:38.583	\N	2026-11-22 11:36:38.586
9d81e3b3-652b-45f3-bd8a-ff8d29b5d3af	995343571660e71d6cbcfa32ba13748e6d60464044ee41fd9dbf2495e25a0be8	2efbe1ad-1413-4ae8-81ae-49e8b990d633	2026-11-29 11:36:38.615	\N	2026-11-22 11:36:38.616
1efbed64-e1a4-43d2-93a2-63f8560abc41	d17bf0018ef472bbc59da4773eb599a1fd08ffb28f9016dd010a5bcbd42fce94	13608b64-3065-4aea-99b6-4633b454b56d	2026-11-29 11:36:38.639	\N	2026-11-22 11:36:38.64
5bf77a61-4e0a-49c6-a7b3-d387a58e1972	8b4e6f4e77381a000d86288afa0a661bb15f73e0cbb31619b7e048df2d4c908e	b0bcbe4c-6c84-4113-a38b-62338ce06d8d	2026-11-29 11:36:38.761	\N	2026-11-22 11:36:38.765
a139a362-3870-411b-96fa-95e7a321b983	3a5c381fe52b784d103305396552582bf72f631422a947f21f838a5c1f60169f	6fce9f62-804c-480a-ba62-c337fa44ace7	2026-11-29 11:36:38.812	\N	2026-11-22 11:36:38.813
46da50d6-f22f-4655-a25c-3ba6e1f6731b	9dfd8a9d6f9f7d78958c19c480744396407913c1c9d4dbc75be2925ee42896ab	3fab570e-2937-4fe4-8e48-b6bc7ba4b2f0	2026-11-29 11:36:38.857	\N	2026-11-22 11:36:38.859
d6d1d7c5-9406-4662-a344-0ccae164c468	5ec0de38c895b36752fdb0ca90256d19b0fed16792071a59385a358738bd8c32	9d5010e7-020c-41ba-81ac-6b878a91889e	2026-11-29 11:36:38.878	\N	2026-11-22 11:36:38.88
a1fa0b97-b82b-4518-9eb3-e0239cdbd26e	1d6589a26769ecbf73beac600e85a460b634d207fd0c79d76cf43553031fd3fb	147459dd-88dc-4f76-89cc-14a93c36d249	2026-11-29 11:36:38.777	2026-11-22 11:36:39.562	2026-11-22 11:36:38.778
aabbf6b2-66d1-4b40-9eb5-aa0afff5daf4	90fce6958a96135ce232d4469dd2507090b30cc69f6843b760acac63326875f8	b49fbfc0-75b1-4417-9a7b-b2b55bb451d6	2026-11-29 11:36:38.927	\N	2026-11-22 11:36:38.928
0c097ea6-dbe3-4ab2-8e75-7e8586028e71	4db1069c3d10221a4555092f49cc7fd854e2883023f6cf68bb95787044671792	147459dd-88dc-4f76-89cc-14a93c36d249	2026-11-29 11:36:39.566	\N	2026-11-22 11:36:39.567
2df70892-99e4-450c-a0d1-e43e2fc25e19	56a72fd80d15b13ced473bcbed4d8edf19a88bad3910fa2f86971911fe28cb50	afe64e04-d47c-4aff-97a5-498252ffd13a	2026-11-29 11:36:39.063	\N	2026-11-22 11:36:39.064
9684ae85-d7ac-4754-92fe-4d25bfbad105	ec21a01debf7cd734ceca942606e19fd3074d26c0e1efd6839229997437305fb	ae128b65-26b9-4aaf-aebe-80153c2e1b12	2026-11-29 11:36:38.284	2026-11-22 11:36:39.062	2026-11-22 11:36:38.285
cfcfb481-be46-49cb-be01-9a3bc37f36fc	2efcd0efe63162fd670cd502d7c96e9bb8c49d1da130c5b4a6aaf8053e1e87fd	ae128b65-26b9-4aaf-aebe-80153c2e1b12	2026-11-29 11:36:38.588	2026-11-22 11:36:39.062	2026-11-22 11:36:38.589
8ad9732c-b420-43be-8f14-389a71e742f3	6a239d26be2ec7d456bfb7ee593774527533b760fd7f414dae34ea5376627f81	ae128b65-26b9-4aaf-aebe-80153c2e1b12	2026-11-29 11:36:38.889	2026-11-22 11:36:39.062	2026-11-22 11:36:38.89
568d6f11-4959-45eb-bcd8-dd340fd78b37	b6719a7ad4efe194f106e5256f739fcd4575e74c55a84e9004da847a72be4485	da494868-688f-4802-823a-432be9bc80b5	2026-11-29 11:36:39.114	\N	2026-11-22 11:36:39.115
e93c6d87-648b-4816-910c-b2623e8f93cd	e592a36b25216a10485a22760ad4baddcef0dd88b66c7f5c2524d7706854c5a6	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 11:36:39.318	\N	2026-11-22 11:36:39.319
bd0fd3bf-c2cb-4156-b7f1-a00956e14262	73e401f8479321064e32627e3ce6844d42320f8a708fbb56bf3a095b151fbaa7	7baddfaa-81ca-4ccc-83c2-2d0e94f4f82b	2026-11-29 11:36:39.803	2026-11-22 11:36:39.821	2026-11-22 11:36:39.804
676003ea-bbeb-4a97-8e53-ac0024a4ebba	d6f31685ecd59655af4ade2f9ecdacfe088a50f065ba69bfa5f13f8250b7bec7	7baddfaa-81ca-4ccc-83c2-2d0e94f4f82b	2026-11-29 11:36:39.814	2026-11-22 11:36:39.821	2026-11-22 11:36:39.815
314a0aaf-df7a-4931-9972-589eaaa50b02	2a6885c2cd142e547996bb0190a66cdc0f96bcf33d3e66d186c0a65eb799690c	67685e48-6314-4741-9f3e-7869f819b961	2026-11-29 11:36:39.361	\N	2026-11-22 11:36:39.361
cd637d3f-784a-414f-abfd-b040731b51f9	0be019ba4b113f3c5c2ac9655c80b268e3e2af51119c39d05863f0d294fbdd14	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 11:37:55.066	2026-11-22 11:37:58.341	2026-11-22 11:37:55.067
62638950-07e4-4d87-8212-9e035828cf5a	dca02505fc77ddc4426d6f420f99f312956e70bc83d0c1bacb54d48546ae85cd	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 11:38:01.744	2026-11-22 11:38:30.776	2026-11-22 11:38:01.745
d251e845-1ddf-49f0-a3b6-353ba354ea08	f4c2827aa56fd6388e5f5d6413b20e1666a20a8e8d045bf734511d746d8316e4	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 11:38:34.322	\N	2026-11-22 11:38:34.323
e0757602-3731-4134-b70f-f7a5ad5625f8	2391c1267985e9952fcd8d37b0eb89f459eb7f6e592b3b15309529f5d841b2e7	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 11:41:25.995	2026-11-22 11:41:47.517	2026-11-22 11:41:25.996
ba73e0c5-9e79-4df2-977f-e1e65dbb8df1	e8c0f5f0f772e9a3bf3ac0a315379dd52d987e103ca9ba69744a79f482b607f0	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 11:41:50.857	\N	2026-11-22 11:41:50.858
5ea1a23d-6d60-4fe5-8b78-44a99ba48320	0a0fd4ce9a5559a83543c00ae4c36148a45be1aeeda4c1840bfd9964df73a1cc	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 11:42:01.62	2026-11-22 11:42:59.31	2026-11-22 11:42:01.621
1335c728-d2e5-4e79-b966-e585d9bb038c	1951385ebf9480f8f713deb33266f5e53c5ce2136755d574849d824815af5d77	a89d8a1e-ad80-4555-a258-0392941f695b	2026-11-29 11:52:11.386	\N	2026-11-22 11:52:11.39
bcd446a3-0243-42c9-bbdc-8eddc08bf588	231a48a7f573db7155815d0be91681cc21f6401789c49138b498e67f996bb7a4	3ed21b94-d1fe-4433-8464-75cf1d4fb9e4	2026-11-29 11:52:11.623	\N	2026-11-22 11:52:11.627
9c183378-b835-4806-970b-366141bce515	4df65fc38582494c0f823e943cb6e87b9738a7b6cbf1707c72910800247a25cc	a62fc8d6-66ce-471b-b268-b23c2051f9f1	2026-11-29 11:52:11.861	\N	2026-11-22 11:52:11.865
20024708-5d00-4503-ab53-7078b437f030	432bee0ac63407285bbb688b00a52ef18350564b0497b628e6426d264f4f6d39	028383ec-4ed0-4010-b4a2-c4cc161da698	2026-11-29 11:52:12.094	\N	2026-11-22 11:52:12.098
4266d5ab-91dd-46d2-b52e-9c3d248cbf8d	4bfcdbe35d9539150c7acc7eada1454f49e725fd3079be2bc83cc21664d076aa	766576f6-0959-4864-8a7e-649df595336b	2026-11-29 11:52:51.387	\N	2026-11-22 11:52:51.389
d38fbf93-2ceb-4ac7-acef-1ac5326b556a	7a09a46342bca6559ca280f3123b5e27ef518f78a4c82807603713ba900ed757	0c20acda-40da-4f0e-b42f-44bbbc0a1af1	2026-11-29 11:52:51.622	\N	2026-11-22 11:52:51.623
88fdc284-0af6-4875-8909-19d75b025015	bbadc32861aa5cb317ec1be32722b181437f800d72de0cfa4597c791b74e27ed	d8815573-617c-4a9f-a950-507542203e55	2026-11-29 11:52:51.859	\N	2026-11-22 11:52:51.86
3456b025-704e-42e9-bd41-4725c6f97411	c1d34c6f0bfe37729cd4fc27b72fe000754362e083eb8e3badbb916aab9bf68a	a6b612af-845d-49fa-b456-67250cdb4014	2026-11-29 11:52:52.089	\N	2026-11-22 11:52:52.09
4d0fa36b-204d-4fba-8a8b-64f3fc23534c	1081764e90ebf7b3e09c6f8ba3a85184c547363038ef6a750315590c1ef63251	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 11:54:11.992	\N	2026-11-22 11:54:11.993
9b52031e-2df0-4c91-bd3e-d13af91bbd28	766a6cbcd7937204e9e5833c3012ece9dc4604447ea43887b5c6a3c24984152f	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 11:54:21.79	\N	2026-11-22 11:54:21.791
ca64df92-0d14-4789-a887-0fb69fc355f2	3ab9a722db45b49de6fab8d2303184fc9eb73f7a8c88c410c82948c9806574cf	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 11:54:31.456	\N	2026-11-22 11:54:31.456
d32a9b39-7692-4bbb-bd2b-4536e33622e0	c549c07639f2e5444c59d9d60795d58ab741c5abdf43478129d14ab20f3a574f	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 11:54:40.932	\N	2026-11-22 11:54:40.933
44da59c0-849c-4191-98e6-cc6f32a4a28c	55cf7fb1570f97e989b7493999487e18a7a4dfe7fec43c30b3fdcc576cac2112	ff166c12-fa96-4a4d-8523-7e1801d01b3f	2026-11-29 11:55:23.961	\N	2026-11-22 11:55:23.963
cae78c51-11de-4f1d-a7a4-8cb02e2dde8f	ee986582f67f9129005e2d1888ee4bd6862238bf276a144248ed8b0a950a3354	f2486095-f7f5-4923-8dd4-bbdfad681499	2026-11-29 11:55:23.988	\N	2026-11-22 11:55:23.991
9e7ca1ee-9a27-4cee-8f48-0fb01946ba7d	5796c4288270745d909e446ac8963e0f8a10ed95448e60b447a2ff6bf11a5b97	eeec89bd-77f1-4b87-b039-63f9778b4621	2026-11-29 11:55:24.028	\N	2026-11-22 11:55:24.029
95ceb8f5-be29-4a8d-998b-295550084ae3	070eb0bb9da0004b94e11f4926ea65cf227e6dbb24a1010c7e8c82fd79986f20	fe4fed22-b93a-4dfe-b237-66a079f96a50	2026-11-29 11:55:24.086	\N	2026-11-22 11:55:24.087
147b0bf3-3f96-4ba1-8ac5-55426194336a	8359809a5df5eef2b693bb19dbad93c95828c3bce3680e46a9c7e5724c5921e7	e43779a3-03a2-4ed0-a27b-1c66d4ab40bf	2026-11-29 11:55:24.091	\N	2026-11-22 11:55:24.093
9e9b3914-6714-431c-a712-31d46de767c8	c279fa18a458e252e9534e43cef1b8c185e79544a40ec4be1f209ca5575a663c	c5be2c05-7982-46af-9db0-2f3f296f630b	2026-11-29 11:55:24.141	\N	2026-11-22 11:55:24.143
446589bf-f802-4743-a714-27ee452763fe	2fe3d0a6205735461a1f058be4613b49918d8092519f0f32f1f61b90cfd0f4f3	9cf8cdc2-da2f-4b7a-ac59-c6b590ebed6a	2026-11-29 11:55:24.145	\N	2026-11-22 11:55:24.147
650f19f4-bbc4-4e02-bf41-5fec902169ce	4f9cda388d8f9ccf350f9344bb1dd2ecf172bd7466d7ca02cd48c92c3e50d8f2	935f0c45-76f4-4be0-8fb0-95fb6009b2dd	2026-11-29 11:55:24.147	\N	2026-11-22 11:55:24.149
b0f5be1d-0937-42e1-93ba-1dcf54849c53	9f0edbc4b79d04313c5953a8631f55d6ff9c176ca4bc1ccfef1e74daf2cdf2b4	a995ae67-343e-4363-bdf9-0375d0f33f4e	2026-11-29 11:55:24.25	\N	2026-11-22 11:55:24.251
e2c4009e-abe3-4a3b-874a-d194870f614d	02cb00b7367bc8ae3e24dbd728f6e8c3f545c68d3ee3f7d06dab10159d469374	cf2a50da-6587-4cf0-8fbf-fbbd1a6474a4	2026-11-29 11:55:24.274	\N	2026-11-22 11:55:24.276
366b9fed-3443-4a3e-8813-c55b7e89179d	c89bf36fb3c731b06122c84277d2cd7284a62ee9cbcaca3b55d1e5dcb0f43158	189ee5a7-5c5b-4120-a133-e29310c9dc2a	2026-11-29 11:55:24.306	\N	2026-11-22 11:55:24.307
a4d6802e-f86b-4e40-b4d6-f7b2c746d552	e8cfa1227eecab11c15344382401edc581196ffbdc304d94c2ce13145a24127d	064a6840-01ae-4133-8933-d1d2fd6a3af5	2026-11-29 11:55:24.356	\N	2026-11-22 11:55:24.358
f61575eb-a9dd-4902-8735-ed9e83034f66	a8892e108788beb79b4e6b3737fdb481edcc771e8a151ad2c3567ba9a8e2ce11	0c0768ce-b175-46fb-8444-26488c274cba	2026-11-29 11:55:24.383	\N	2026-11-22 11:55:24.384
c500d6df-73f8-4f16-9021-87aeab1ccc9a	720d3c971f64cb06329757ab00324cd368ebe8fd1360fe34b1cb53cac920d281	863029a2-5a25-4be2-be07-0680e859f3f2	2026-11-29 11:55:24.409	\N	2026-11-22 11:55:24.411
1a93a005-78a9-49d0-b739-73f49ceddd4b	e83915dddf67a7b9ab6c063e6ae23a4983db8a6d29a5d2479ee28c301eef1189	958f62e7-0865-4490-a441-8d32eb95ef31	2026-11-29 11:55:24.419	\N	2026-11-22 11:55:24.42
48994152-1de5-4533-96a2-0542b316bdc8	8030e59df956404b8444fac6e83bed6306ce183132dd44bcad6550409e154762	413f9c28-135a-41dc-9ae3-29f264612e2c	2026-11-29 11:55:24.433	\N	2026-11-22 11:55:24.435
5a5f0e3c-3df0-4796-b90a-3fff2f4c9fe1	b5343b991d8b45b8bae3d21fb9b1c5bea7a476718979ed810c4878424a8bd26c	93379134-a271-44fa-bf5a-314fe8520bca	2026-11-29 11:55:24.523	\N	2026-11-22 11:55:24.524
3341e2ef-b52b-4fc5-9719-2c7c92efe381	257b701fea9f3b87eca3eb5c23a4fa3acdc796d147e62be88df605ee3e6c2848	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 11:43:02.207	2026-11-22 12:00:47.732	2026-11-22 11:43:02.208
4b2f4bb0-5dff-4cc8-b7a1-a6fb3bd9fa69	d8620d961db1535c27b175a5b0889f3b8606523c0c037f18cab990e0b5f45e82	d3900c77-40a4-4e6e-8255-038d9aed2a21	2026-11-29 11:55:24.678	\N	2026-11-22 11:55:24.679
24ad703f-b2fc-4903-85c9-54e77edc92b7	871ff15c2913ea1d28772329de92979c92a3b664ea9054593d9c51c741c3d2b8	8bc999de-3d28-4b57-af72-a5c2e2ac6dab	2026-11-29 11:55:24.697	\N	2026-11-22 11:55:24.698
ecc6410e-2370-43d5-a0d8-862e9972d52b	07271d6bb7c71e8fb678b86d8eed0b38929edf01c9b3f6053209015e6c3b7d0c	4b4b0149-ece4-4281-9c87-ad93e8ccf2a8	2026-11-29 11:55:24.051	2026-11-22 11:55:24.833	2026-11-22 11:55:24.053
ba9f9301-a6f1-46f6-9f28-c4e56022323d	76725f10b17ca5d706ea3d1a4eae5115f468d184868e064c181a7580bae60330	cf2a50da-6587-4cf0-8fbf-fbbd1a6474a4	2026-11-29 11:55:24.819	\N	2026-11-22 11:55:24.821
84259207-cf4f-4ca8-809f-182e11fe7e69	8c52e2bff36d7268ff65f7d171b1a25f3d96eb7445bc42e4490e25554f6f644f	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 11:55:25.102	\N	2026-11-22 11:55:25.104
8e119b2d-4073-4881-b4de-96f2c2f88eb7	03352962989ff87127d22b9099b211a3805781bbb5eaeab4c4944135dc586e16	f2486095-f7f5-4923-8dd4-bbdfad681499	2026-11-29 11:55:24.541	2026-11-22 11:55:25.356	2026-11-22 11:55:24.543
c51b6a30-d775-46d9-96ba-e0da133ae1e7	b76669ab22a71f6103493f5fd47e830eb228d9b8c707412e7dc818165749133a	f2486095-f7f5-4923-8dd4-bbdfad681499	2026-11-29 11:55:25.36	\N	2026-11-22 11:55:25.362
a02893b5-0def-440b-a08f-4965c805b796	4d5fef96a42daf9a6ee10ebb284e1cf513fff0a1a9567745ae5ef25132b95214	bd268487-3f47-4226-9287-a6f28215b3ef	2026-11-29 11:55:25.601	2026-11-22 11:55:25.619	2026-11-22 11:55:25.603
5240ecbb-31e2-47fd-86d4-4136356d1722	613bc01e9c7efa8ece7e23d831594b64383e9ade8b2ea0db6fa3bf4a423fb7ac	bd268487-3f47-4226-9287-a6f28215b3ef	2026-11-29 11:55:25.612	2026-11-22 11:55:25.619	2026-11-22 11:55:25.614
9c3451b6-5d52-445f-b1f8-e1b1cad9d25b	75024865f69ad013ec92272e9a076e4b17f6784f3e8a16740010da3c4fbd7cfb	94ae7a86-4904-4f65-be33-bcd6730fcb95	2026-11-29 11:55:24.616	\N	2026-11-22 11:55:24.617
528e4071-6bd3-4895-9bed-4b7163f6b485	01bb87f87c6d76f595ec2445a3068a418d07752fe1382c221c611b9bbc9eb7fe	62b2d075-5944-43e7-89a8-26146484ab12	2026-11-29 11:55:24.633	\N	2026-11-22 11:55:24.635
ff3c1f4f-ca7f-42b1-a989-d595ff420b23	0b5b3477cecc636af1402b45d57ef5f5016a138383b0db01df0bc7c852d253db	86063df1-5f0d-4cda-9d5c-5124c3c670d6	2026-11-29 11:55:24.908	\N	2026-11-22 11:55:24.91
8159cd3c-4fda-4232-b566-bad52391dc47	1ece994b9117b3beb574421f05c4147a03b2f395e41acd21dfa123c261770994	e50326f1-92b0-4149-ab38-88e681b1037c	2026-11-29 11:55:24.724	\N	2026-11-22 11:55:24.726
c1c88326-97e6-47ad-83ce-f2fb055e7cfa	14cb0c4dbff9f6a59c9720c185814d5176ba59d67ffa9b78a019277efd131962	4469db4e-5fa2-4654-a406-28cdc4c47994	2026-11-29 11:55:24.819	\N	2026-11-22 11:55:24.821
0bd1d508-58d1-4a4a-a795-5ee9ce75d3f3	182b02fd1bb4a0d0ee152f3592632137016035d0a6185e0f4c33051ab43edf1e	bbdeedcd-4da8-41f3-9c48-fda072eb1658	2026-11-29 11:55:25.097	\N	2026-11-22 11:55:25.099
f2c446dd-1fda-44a9-9c56-6439e66b5dfd	2e335ea66aed9b5b387cf76daf97150df5ce7e802d141482b52a6b4345cc13f4	4b4b0149-ece4-4281-9c87-ad93e8ccf2a8	2026-11-29 11:55:24.351	2026-11-22 11:55:24.833	2026-11-22 11:55:24.353
0722d3ca-077b-43f9-b76d-a3de0bbf56a5	3ce175418f6d2d32d1a8a6194c1fefb0c59a9b5892f813c84aa087bb607430ff	4b4b0149-ece4-4281-9c87-ad93e8ccf2a8	2026-11-29 11:55:24.67	2026-11-22 11:55:24.833	2026-11-22 11:55:24.672
db62f689-86d5-4c8a-a5bf-00077d5c328f	a28828fe7f749702ab5411f45b4883c2851383746b6ddb112fef8a921c260bd6	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 11:56:10.038	\N	2026-11-22 11:56:10.039
260c9f46-c48e-48da-bfa2-e28937edba16	52bad5b83bb6082c063f151f686e0d05ef61b87e45739f6da17e5ee741d20b91	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 11:56:20.453	\N	2026-11-22 11:56:20.454
6686ddeb-730f-48ca-af04-d53688a75cae	95f76cb6b0f702f20cc93898ef5fd33c4e0a535af1983b2d4c0a45e43496ba9a	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 11:56:26.181	\N	2026-11-22 11:56:26.183
fb7cba90-ab6a-4cba-abe9-9ee71c7c7cb2	946dfbb44668ca7f28cbfa6b685448cb514fa5f144c90568e1360ee9694c0286	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 11:56:33.093	\N	2026-11-22 11:56:33.095
30b59bc9-0197-4dd8-9ad3-124480ed5ba8	a04ba519d1d494a159ef113336badf1b1720fff94ef2551e6dd0cd074f7a9584	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 11:56:36.049	\N	2026-11-22 11:56:36.051
c8008871-4327-4ed1-817b-c184ad0c9e31	f773283dfc9c083807f283104f0ab90b9bfa33af52caa3cec955f30b8f10c9ed	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 12:00:45.788	\N	2026-11-22 12:00:45.79
9a7fcb63-8fa5-4346-ab5e-8fe297ac7cfa	ce76e8dfe12f2e6f8799d80a11dc8e8ab551a3b03b9bbb3d25372310a543448e	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 12:00:48.593	\N	2026-11-22 12:00:48.595
f494665d-9f40-4483-9baa-f6f6c0adc437	cd348d2b040c41b9a88347956868aef9e7742e6b6443b4f05026be0b642b6723	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 12:02:53.118	\N	2026-11-22 12:02:53.12
a96579b6-0f8f-4872-b867-ce4fa7bf39a1	88464173fceb6b3ec4ac4361e9a391ccef3235219972bde4d4d876ba2d1183cb	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 12:02:56.094	\N	2026-11-22 12:02:56.096
b4eb0a0f-2b5a-4c30-b55d-605b09f9fc70	0742bc26f6c6a138178e72147833dd22a410e6c1ea3dda9380cad862ed49239a	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 12:03:28.612	\N	2026-11-22 12:03:28.613
6d2735a8-3915-45c1-bf40-8a3a6700887f	9a2725d4db8a18dd0b8ca95be0db3d88e6e90d7eaaa98135deae81c648481c5f	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 12:03:39.005	\N	2026-11-22 12:03:39.006
d715d6dc-5498-40bf-a7f7-9527c8af6cd6	3aa181141fcfb64e12a3d91a396ea46629df65127d8e0da9568f3c65a993f642	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 12:03:44.631	\N	2026-11-22 12:03:44.632
f4d6f71f-0dc5-427a-9934-917fd778b85c	05baf7fe4e42583e873797f4ba1fcb942748561e2030457dc357bdf0af42b96a	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 12:03:51.454	\N	2026-11-22 12:03:51.456
fbfe0dab-b87d-4348-b6be-2d9775727894	c40b8302de93a774b9328a2bfbdee9275622618efb2ceefd5fb74ded84f3ec43	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 12:03:54.374	\N	2026-11-22 12:03:54.375
d729d5dd-597c-4542-8fe1-efcafcb7adca	363f664fcdea25c9559cd09cffac6111da9df19e22d8118c1448a8ec41953222	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 12:04:03.458	\N	2026-11-22 12:04:03.459
628df785-5251-4681-9a14-c23d268c021f	37d319e5e331a52d1f2e276f91581552577e18e291dc7b0f3159e994e1bc9c13	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 12:04:06.427	\N	2026-11-22 12:04:06.428
a8f74451-7055-4b44-a68d-8e9311e61c8c	24c2afa7094106de7fc61c9427abdc2ec6d7173f5ab5af1205f86b73964a21f8	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 12:04:14.704	\N	2026-11-22 12:04:14.705
dc2977de-51c9-44e7-a89d-9bc0275e6604	cfcdd1b288f8b1d8192cd861de13e7393be556fcd2c34266009b9b63b1d55756	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 12:04:17.165	\N	2026-11-22 12:04:17.166
df6ed195-9182-4618-9e63-1ee1cfebeae3	ff1f5565b3a5abb90b56a4700a0dd6688f34a9130fe53d42be49d076db5f5518	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 12:04:26.59	\N	2026-11-22 12:04:26.591
c01742f7-5d7e-4442-aa1a-4decbead01ba	dfa163fa372c9ff0e49ad3b2f3a79f04db87f79393b17bc17101d99657e8c120	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 12:04:36.846	\N	2026-11-22 12:04:36.847
d0a63d26-86d8-4f79-8da9-30599107ba4c	371982f652806946d91ab6d1bb65fdf931f6a581818597c657db7bdfab4501c1	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 12:04:40.039	\N	2026-11-22 12:04:40.04
28a3f1ea-abd9-46f9-a650-f2f82c3000d2	b77229aecf3a2132b0f40d47f54fda8fa5f1815eb3a53928ed659996274d2d97	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 12:04:47.886	\N	2026-11-22 12:04:47.887
8ab9286f-ac14-477e-b0a0-f530f6088297	9f35da003151125e3beae320bf968c00b3c9c3144d68d1b58457e11a710987c1	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 12:04:49.961	\N	2026-11-22 12:04:49.962
c8adb83e-3d02-4386-8278-bd71dad8f2e4	0ff13b77c8a76e6218cb6f6148ee64b215af231cafa8d5b0da47ebc51d6040fe	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 12:04:59.578	\N	2026-11-22 12:04:59.579
4a3d7b17-4d66-41df-b247-2e3f19109898	f8cf5b19a6d33900af46ee67334768245bea8b5c9f85cf78cb39f60a820037a7	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 12:05:09.172	\N	2026-11-22 12:05:09.173
bd7e1f86-7655-47a4-923c-30f2a55452ad	12688a9954aaf8df5a2aaf6a9a8f5581ddb2d04ad711eca9530986af7418db49	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 12:05:18.89	\N	2026-11-22 12:05:18.891
9d1baab0-5b44-46a8-9f1f-e920e4e3162d	31a331c852438e24afa7f816ff01a38a3517cc85878ca1ec37eb6cb3d648fbb2	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 12:00:47.739	2026-11-22 12:12:34.718	2026-11-22 12:00:47.741
214969bc-a33a-4cf3-91ef-b557ad4a030c	cf82222340ae4c9ba6c169818d025245c222d3f332e41263834c91847cea358a	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 12:12:37.6	2026-11-22 12:43:52.673	2026-11-22 12:12:37.602
83f65b8f-67a5-48cd-8939-18f299cc13db	5841cf598bea880588d1040e756a00555bf0546ef41d914e931b80d1f579731f	40e6fef7-48b0-4b4f-b5d1-643f8c4665d7	2026-11-29 12:56:22.888	2026-11-22 12:56:23.6	2026-11-22 12:56:22.891
e5cb64e4-c537-473c-9268-7e8d4409e9f8	51b7dbd84f2e62426eb4a84d5e467f8fd1ad679aa63ce2d6b9fbd8388892962a	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 12:43:52.679	2026-11-22 13:05:29.538	2026-11-22 12:43:52.68
7ed6331b-4247-4253-ad07-dde7ad6249f7	4f0165ec6ac7b94567dea39a009d12c486925e078bcaf2a007a2b77a177e21dd	b058b251-3038-4f94-837d-98d390b907c9	2026-11-29 12:56:09.124	2026-11-22 12:56:09.744	2026-11-22 12:56:09.131
34a89f3c-daf3-4059-8af8-389e20a204ee	817445b5a7e3708ba5febb649de2f63bd1d339c4f232d3e3fcdb89c1309bd562	b058b251-3038-4f94-837d-98d390b907c9	2026-11-29 12:56:09.374	2026-11-22 12:56:09.744	2026-11-22 12:56:09.382
5d17c90c-d8a7-4d7f-8086-7efb7553083a	879f6e589a9aa2964bf2b46594e73717d73f916d1b3771e3774f98c6b9a0d045	b058b251-3038-4f94-837d-98d390b907c9	2026-11-29 12:56:09.635	2026-11-22 12:56:09.744	2026-11-22 12:56:09.643
f662e443-bf29-420c-9266-08bb6e2af13a	bb4552b4e67bbd70cf755226e137d34bd4dc159308214c08498dbad2382059bd	40e6fef7-48b0-4b4f-b5d1-643f8c4665d7	2026-11-29 12:56:22.405	\N	2026-11-22 12:56:22.408
8852a3d8-d120-4977-b33c-ae117cb52e4e	bc04efca060452f2b5ddb2663488b3a349076c7f164e33041d0a4ce8bdf6e316	6a574d53-ad46-4c43-b3d2-054578f0fbbe	2026-11-29 12:56:22.655	\N	2026-11-22 12:56:22.658
a6f73b63-72b9-4f0a-90ea-028b7d40baf6	870fbbfe6546ce79d266954686c1e4e822cd70a6ff6308064a4f8846527b2636	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 12:10:56.115	2026-11-22 13:31:48.599	2026-11-22 12:10:56.116
0725f531-b2ec-44a8-9a18-45792c363f52	92798b3aab3eb8ac417946d7ac484bd3788f74fcdf19e631c2c01ee5036480b2	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 12:09:39.645	2026-11-22 15:27:07.511	2026-11-22 12:09:39.646
18f5e160-3e11-4414-a514-9792fe66d750	ce90a04a717f7892744a67f7d7c2a23b18b5d7013dd1f1b86c58fd87997ed597	6a574d53-ad46-4c43-b3d2-054578f0fbbe	2026-11-29 12:56:23.121	\N	2026-11-22 12:56:23.124
d585959b-7330-41c9-a067-ed7edbc1f037	c52eed3cb3c6c7f43bed2a6158abded6de0dea27660b10d73f03b1ad502921e7	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 12:56:23.354	\N	2026-11-22 12:56:23.357
2aa1f22e-a297-41e8-83f3-62e9c6070328	0f4e6012c6ca0dd0d9647308acb488efba1bf6855a8a04ed9b57e2f625f54304	40e6fef7-48b0-4b4f-b5d1-643f8c4665d7	2026-11-29 12:56:23.604	\N	2026-11-22 12:56:23.606
90cd3a60-3f9c-46b8-badb-ba247500d930	3a7b5a4804d27f4d2534bf58677cd2aab45dc7c806b8d869f0d1825cfca087f7	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 13:19:15.794	\N	2026-11-22 13:19:15.797
52985913-bf40-4414-8955-8e39a4483db2	317741ad751804ea106292ccf31136a237e8b4477c5a11a7bfa17683b18cb55c	793e166b-ae9f-4eba-bdf4-3915924ac842	2026-11-29 12:56:23.838	2026-11-22 12:56:23.854	2026-11-22 12:56:23.84
233461b2-d6d0-4d55-8c21-e287e6d095f7	03a3fb768fa95302729a75a54dabcfdfc7a98e5c11c0ed37b1270bbad76d0ae6	793e166b-ae9f-4eba-bdf4-3915924ac842	2026-11-29 12:56:23.847	2026-11-22 12:56:23.854	2026-11-22 12:56:23.85
47dc4b00-56c4-4c84-a3d5-f678462b33f1	19d34dff02c5b5ecdd1816c2d345413b90a6cecc22d5d5b9c0fb214b87f19347	f34fa6c9-f73a-42c4-9160-85d695a71a2b	2026-11-29 13:04:36.51	\N	2026-11-22 13:04:36.511
0d000f6b-596f-4cc8-acf7-180064dbdcd6	2975e32efc203e4b787511507aeb0743823c7ae0e43f5407415f8a71f30f3daf	7728fd21-9b94-481c-b739-87c80836528a	2026-11-29 13:04:36.544	\N	2026-11-22 13:04:36.546
1fb7295f-1521-4797-83ad-b825dd96932b	3328932ebbf83f671f9d6a400087f93cd3f18bbf0a26e1ba96b7f38c3e6da4af	8b8e01b0-ced8-44e7-8ac3-11a5129be596	2026-11-29 13:04:36.753	\N	2026-11-22 13:04:36.754
3df19597-a994-4045-b647-be00e45733b6	05414013d084e8b1a90091b6d18bf90ffe1734e5de5f62f35a5eddc769bd6f91	93c9a1ba-11fc-41ef-bc41-0bba5b0a0634	2026-11-29 13:04:36.793	\N	2026-11-22 13:04:36.794
17afd51c-f4fb-4d33-968f-a78a7367bd82	3c0b7bf5790386bed2ff22bb1b1db414952dcd250def424fe652e6913cd656ed	fc725f56-3a5d-4cfb-ae3a-285db185f44e	2026-11-29 13:04:36.993	\N	2026-11-22 13:04:36.994
bd758dd2-e457-46eb-b2ea-d88984665a57	c4815080097f31103314a683c43cc8c36fe101740b56024dbe4a95cf8b1ecce4	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 13:05:37.886	2026-11-22 13:22:36.87	2026-11-22 13:05:37.887
0d7c1bc6-948a-470c-97b3-56c2482d27ce	5d8f2f17f2ec661244b37453ea9f25eaa4abf7fe7514c67438b1002c2ef1acdf	3b2178a5-100c-422e-96c5-992e3283239f	2026-11-29 13:04:37.042	\N	2026-11-22 13:04:37.044
26aba313-ca3f-450c-933e-9ef25a34066d	a4129f71ae8a93feed4838a99e8246096982b8a7799a919ca5f322a7bb8d5842	4ffc6d3f-77f9-48e0-bbaa-e37af292b892	2026-11-29 13:04:36.519	2026-11-22 13:04:37.153	2026-11-22 13:04:36.523
e6e78d23-3229-4500-be09-1254736c0afd	8a8d36fd876932d0841ef6435801549381f178ea8f5592a9666f1242b369b96b	4ffc6d3f-77f9-48e0-bbaa-e37af292b892	2026-11-29 13:04:36.772	2026-11-22 13:04:37.153	2026-11-22 13:04:36.776
e8eb49f9-2799-4152-9070-a72561179c3a	5681c743de937f1e79ccd298ec629338c7cf74df403ba53acc7d0b3db0f9ec75	4ffc6d3f-77f9-48e0-bbaa-e37af292b892	2026-11-29 13:04:37.039	2026-11-22 13:04:37.153	2026-11-22 13:04:37.043
66f22f47-604a-49a0-ada0-b6f850cfc3f1	3f999a261b9ead0474f110a5981a1458feddfc84515748a5ebbfa41f86e20759	38d387dd-e06f-4ea0-9155-587eb1ec7a7c	2026-11-29 13:04:37.241	\N	2026-11-22 13:04:37.242
09a40a26-a297-4ccc-bc7c-d5ffde968b07	530d5169413c1a841f79a61b66edbffff33efa43d437c4042b59d037f3491299	e1f9196b-4bee-442b-903b-bf6bd88250e7	2026-11-29 13:04:37.477	\N	2026-11-22 13:04:37.478
c268550f-c07a-4fa4-9489-80021880acb8	88db533b64fd34002ba09a688a95dd59e604e30d6281b394c9f3f92aac473632	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 13:05:29.546	2026-11-22 13:05:33.883	2026-11-22 13:05:29.547
c35451df-1cfb-419c-a08e-ef9a206d9fec	0537602f8330c464ab768f6f842c80a1db279e3e2d866e7836df2e8f8a151b58	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 13:13:49.332	\N	2026-11-22 13:13:49.333
4d6089f6-9dd9-4817-8e83-d618f42fb85b	2a7730439bcecdcc7f6435a5d6efa0912b801b3513cb75430ea1094b33109309	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 13:15:09.037	\N	2026-11-22 13:15:09.038
110af4f2-f334-40cf-b19b-84cca9d78f37	97c0b0c3d73332b40c4a6b4dcceca5cbd88ca3cfd3a690483775e668910e918d	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 13:15:47.799	\N	2026-11-22 13:15:47.8
33d74db3-da9c-4277-ac9a-4e7c20ab011a	d3fc6ae4c56f3f429ca7d5cf898211668b7dc152cc625abb33a59ee7f7202c70	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 13:16:47.249	\N	2026-11-22 13:16:47.251
3c9b4e89-4e74-4cd2-b2e1-7925bd1035c3	04a364fd4528ce9bb2f40b54f3db63b9e8f79299b2e2e8209d44b9b3039df734	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 13:17:43.45	\N	2026-11-22 13:17:43.452
42ce7b1f-95a2-4add-9479-062277946093	2def2c098071d8fb77289a17eb965e38a8fcaf50bfa65298fbcc4a90753f6602	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 13:18:45.376	\N	2026-11-22 13:18:45.378
c91cc2f7-17ec-46b0-8bd4-704c2ed1d592	0882b8831bde72b599834d589002e250d478a535033823d5c2751b93a872c657	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 13:22:36.876	2026-11-22 13:27:29.372	2026-11-22 13:22:36.878
75a42bea-462b-47fd-b2fd-006eefb4db67	439f962e3ae743b499c4131c659916fbc60176f963c7e298e8b06338338f510d	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 13:31:48.604	2026-11-22 13:31:51.945	2026-11-22 13:31:48.606
5b5efe89-d4e1-41ca-a19e-1bd49d6c210a	f7d4dc00599d9c6deafb969a94dd3e7017aee52d88397c57a5532425ac075a2e	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 13:31:55.374	\N	2026-11-22 13:31:55.376
83d5eae2-c371-42a7-8aa2-3b7f0c51729d	06fc7c1b31968c561f0b265b17e67c465ad545afb16117632ed633ce2a7d3822	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 13:39:39.167	\N	2026-11-22 13:39:39.168
1dbe2bff-49ae-477b-9e6e-134234943372	7a148628d9839718172b3a5ce6c8dd0951e0c2548207f323d3eaec1393ebe460	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 13:42:04.424	\N	2026-11-22 13:42:04.44
b80d16b1-a50e-41cd-aef5-d163e36c48f6	80084c4ec9913fe0ef072c27358a8026c4bc73dcccf1fdc0e42f6c23da4a29ee	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 13:42:43.719	\N	2026-11-22 13:42:43.736
492ced65-6c5f-46d4-b7f9-003fd1ebf93e	4ef53e98c247db92190995f8514cdbf1ae317b2347016a783e33cf763ec9e615	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 13:54:55.656	\N	2026-11-22 13:54:55.658
4c91746d-f20f-49dc-b2c2-a3a111a24ed0	a88d2fdf5c7256df5d161fb427ad8505599412216ac8c7778a1fd01be455dd59	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 13:56:53.323	\N	2026-11-22 13:56:53.323
175b31ea-67be-46ec-9502-9377c0645af0	8deaa08d0ca5586f49aaa1e80fa45986c2f19fd69a1b299f05307632d6d6e019	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 13:57:21.958	\N	2026-11-22 13:57:21.958
da02f832-bde0-4bbc-8e81-5045e18ed439	58b32d775cab5a49eeda4aa77b83c7d203a46120e44edda5596bb87f441f1929	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 13:57:49.764	\N	2026-11-22 13:57:49.765
a97dd1af-519f-49d2-b545-8e6b6be234a1	4b2e0dd5342fb2af2ee59b005d6c854e2c05076c9704a1d82a8eaee429736e23	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 13:32:13.247	2026-11-22 13:59:51.237	2026-11-22 13:32:13.249
54bd13a3-1c6c-447b-9d30-93cf1561e9a0	c1e3a99151be5b84c552f5013ae0a753209e674542a824d8bf0c4cd652851925	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 13:27:53.287	2026-11-22 14:03:18.378	2026-11-22 13:27:53.288
7d58af24-8950-46ae-8684-8a6614c907bc	7ddb0f3b78718cb6ce4c4a88a977cc29796afac253342b9e787968bf2d52b0e2	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 14:11:57.913	\N	2026-11-22 14:11:57.913
13e8ec3f-8ea2-4df7-8c77-0c7c79b89c13	ca4da1bf37cf5daf792a44e2b740628fd3a30e3feadfbb945503aea54bf4526a	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 14:12:23.794	\N	2026-11-22 14:12:23.795
f5c592b9-9e4a-4e58-aae7-fe24358e9b95	ef243e65bf06bb1dd5f7cd53a928f13b0df19961b1d0565b554285876847d798	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 13:59:51.241	2026-11-22 14:50:49.679	2026-11-22 13:59:51.243
e64bea7e-7c19-4b31-8d03-843eee4434d8	a1720e7efb8e21df8dd74bdcd99ecd57efbb2ff2bc47fe8490a8853cf3dbdcfc	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 14:03:18.383	2026-11-22 15:24:17.966	2026-11-22 14:03:18.385
b9540711-8e9b-481b-bb4f-ab5d8c100809	b3a2c91c07b68bcfc90c6a4bc56323eda57edbd5bbd0b13eb30db2176dadb8df	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 14:12:38.204	\N	2026-11-22 14:12:38.205
f758b71f-21a0-4276-94af-d52027cfd79d	18b077b7826162c6dc730dbb8e23693354b08428f82872de5a774cb8ee0ef6c9	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 14:12:54.198	\N	2026-11-22 14:12:54.199
12cbbffa-1d68-4ecb-96d7-c5e32fef5f6e	36903fc96dd347a6cf17d6819f50de164128cce0e751d3cd716b985c186c074a	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 14:50:49.685	\N	2026-11-22 14:50:49.687
9bb00e07-06fd-48c4-b0ed-ba65a173968a	89ded3b57b59eed63052b4c639e2a9ce69e23cd9d6bd0ab8c6f51658c3fbf6b9	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 15:00:51.467	\N	2026-11-22 15:00:51.468
efeaf8ba-7352-4162-a6b8-c9b1cfecf18d	e800c6a56459bb50e22901364026246b6022642b3bbd480eeb701734ff3bad43	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 15:01:15.869	\N	2026-11-22 15:01:15.87
b610ab53-fe15-4042-898a-7089feabbfea	51e6894c155f19b602ce29992f8865c5c6e47908b7c284560d166f2f28a47b6e	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 15:18:22.508	2026-11-22 15:18:33.614	2026-11-22 15:18:22.509
a1437be9-a3ae-4381-8a6f-928dfa4a33b6	39bb03611925e6556ada40d8ce3453c5203afa562e5fd98f35a1f1bdfde0adbf	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 15:18:35.943	\N	2026-11-22 15:18:35.944
f5d34867-efd6-4f53-b333-54cba7a70483	06ab62dfad5712096892ecfc12c20fd9b9380f0bc4ce4cfa8013948bd777a9e1	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 15:20:28.573	2026-11-22 15:20:39.692	2026-11-22 15:20:28.574
eeb4b574-99ed-4d93-8d9b-1519a01094b0	722e0c6134b3a4a8657b83c85b874dbe3f2a6fdf601922f5b22c4397006cc257	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 15:20:42.006	2026-11-22 15:20:58.276	2026-11-22 15:20:42.007
f7f1db8a-f6a7-4acf-91f7-7d77c3b386b5	2b8cb0ec323f0f1daa5b8f61425ee601b0d21c01687e024084d48f87433be686	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 15:21:00.587	\N	2026-11-22 15:21:00.589
967502cd-07ad-49ff-ac38-101e5b5acfd0	d77362f4bffac6d7b09258d3423101e866bf9646adf94936dab2d1db17441700	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 15:21:26.669	\N	2026-11-22 15:21:26.671
70884628-d7b4-4a48-9e00-f018fe9c080a	26a5a4de51ab4794f7c90d406cdcdbff6a1a64b84591befc44a78fa78c4a400c	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 15:21:44.865	\N	2026-11-22 15:21:44.867
9f840f49-5b95-46c1-b01b-3f6cdaaafb07	4f9b354d386d6f1c80ea6c54a2138d7823adf7b62175507cba8e7141b94b2844	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 14:53:36.699	2026-11-22 15:25:41.709	2026-11-22 14:53:36.7
5fea9293-8361-4007-846f-1c9ba39a5c06	581a28dc193ec6cdc13904c54417b4f09a5e21d418a79c4bea808dc83d742a9b	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 15:39:26.836	\N	2026-11-22 15:39:26.838
cd36bfa6-a1d2-4938-9c82-d57fcbb660eb	a1cde0688f1a5e808537787d4d940f300fa69ebad4965b2fd4b53a26c0fe104a	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 15:39:32.48	\N	2026-11-22 15:39:32.482
19771b50-4197-474e-bb9d-8f46ad9629b2	f15db345cb0c2720969588e716f897f4065a15ff31373f8461b9fb7a4ee9a837	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 15:39:38.138	\N	2026-11-22 15:39:38.14
1f05b4bf-945b-434b-8e4f-50c62be3a1d3	ecbe94eca205076792647d9d161f6d62e0e7fe67bf811677be0221848bc97782	e22478b0-00a4-44f8-b146-3649213c7a20	2026-11-29 15:40:25.807	2026-11-22 15:40:36.907	2026-11-22 15:40:25.809
3821f992-0279-4ff7-9f2d-496b11f5d664	85be47e9b7185169f03c703ad921eb96fbf37ada2f1d8f21f7bbaf0f8954d247	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 15:40:39.231	2026-11-22 15:40:55.289	2026-11-22 15:40:39.233
e47db09a-d1ad-48fe-a864-dde1907a4ec8	dcdf35ac2d9a904bbca7193e853e32c253bdab0a13df672e302f3d4f44cfbd25	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 15:40:57.598	\N	2026-11-22 15:40:57.6
20a46c51-6604-43cc-a31b-f72df6aaf662	bd76a62669c838df98b8ec06f0a601199b13d0bceb098c808be7b1c00815fc1c	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 15:41:29.267	\N	2026-11-22 15:41:29.268
6e080d3e-b9d6-4e2e-bd43-3ac533c6e40e	e1e45ad47976e5027455dabe8a368beb6b4c0c58e10dca0af200d7d9f435bb27	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 15:42:30.705	\N	2026-11-22 15:42:30.706
edc5e5fe-df33-4093-b619-8e67115dad15	1ae0bd1285cc906ac2831e80743012a923747762b162ca8f27ceeed115f30cf9	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 15:42:42.648	\N	2026-11-22 15:42:42.65
df599ec3-c7a2-4102-aac7-9617ef4fac46	da514b74842aebe032e4faf6e7932a583781e2f52bd74a835e5ed37f7f512031	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 15:25:41.713	2026-11-22 15:44:12.596	2026-11-22 15:25:41.714
74249ab0-b5f9-4962-84ea-17b44b94db84	4e8492263bb90b229b4c9325bd6b1ee19e50d077c2e204ca0b98284089b61138	473401ce-0803-422f-8baa-a47de557f84e	2026-11-29 15:44:12.602	\N	2026-11-22 15:44:12.603
574157da-58c0-411a-84f8-439e9680929d	cebc40ca5e60d7a07e026ad3560333127c49d1c2513b7c91349c36e41df8d1d0	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 15:27:07.517	2026-11-22 15:44:25.615	2026-11-22 15:27:07.518
461efcaf-7777-4d07-b115-6ae516d246c3	48b23ee8b9eda19d68e107d9d0fe3566de133dabc0ecaea1cb7f2256857029e1	a3a45b01-9ac2-4382-9551-68f1762d33c2	2026-11-29 15:44:25.619	\N	2026-11-22 15:44:25.62
2ddde817-0085-4201-a2b5-1fcef109074f	5e4dad438b77436cbda83201121c0a794a0b609e2ca53d3ecac6e9db2ec7a773	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 15:24:17.974	2026-11-22 15:44:33.042	2026-11-22 15:24:17.976
b62e47b8-b690-4a22-a38b-08315196d124	db4c6360a9c737681fd3f35151db3efc33344f5fc857f1bd6f7d982e31330ac9	a1479806-db8e-432b-a61a-04b1494faf85	2026-11-29 15:44:33.046	\N	2026-11-22 15:44:33.047
\.


--
-- Data for Name: ReportImage; Type: TABLE DATA; Schema: public; Owner: vbrs_admin
--

COPY public."ReportImage" (id, "reportId", "filePath", "fileName", "fileSize", "mimeType", "createdAt") FROM stdin;
afd16c00-8275-402e-93a3-0b353086a5ba	96554164-ec44-4988-80f1-01ab3b1c79d1	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/4689186b-e03d-4d9c-b575-dc8dc1a14be8.png	4689186b-e03d-4d9c-b575-dc8dc1a14be8.png	70	image/png	2026-11-22 09:26:53.354
5781a5db-b819-46d0-a820-3d297eec405b	4b1cbadd-3c17-469f-9e59-9fa9f8caeddf	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/f7fe34dc-7190-4c84-afe9-50e313b0e026.png	f7fe34dc-7190-4c84-afe9-50e313b0e026.png	70	image/png	2026-11-22 09:27:47.82
a0f295d8-965e-49f8-a2dc-5732a6fde17f	1a3bbc18-ad93-4373-bb4b-85764d9fdf5f	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/140e26f3-c6e6-4df3-b57b-ce0c87ba9115.png	140e26f3-c6e6-4df3-b57b-ce0c87ba9115.png	1202897	image/png	2026-11-22 09:34:49.17
dde670ed-1d7a-43b3-8a78-c1312cf26a07	f76e9070-3aba-4f3a-9e33-ac94e6faf02a	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/278f047e-3fa7-4a54-8d2a-4ee95cfa0073.jpg	278f047e-3fa7-4a54-8d2a-4ee95cfa0073.jpg	27	image/jpeg	2026-11-22 09:44:12.095
e85de89a-230e-46e3-82ef-6da54d9d1d3b	f76e9070-3aba-4f3a-9e33-ac94e6faf02a	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/767b9d7f-d1f0-48b4-9327-bdd15615a9dc.jpg	767b9d7f-d1f0-48b4-9327-bdd15615a9dc.jpg	27	image/jpeg	2026-11-22 09:44:12.097
74971bc5-c19a-4b3b-a99b-a8adb79f03ff	f76e9070-3aba-4f3a-9e33-ac94e6faf02a	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/0417be37-439e-4941-a92b-91a2303c56f0.jpg	0417be37-439e-4941-a92b-91a2303c56f0.jpg	27	image/jpeg	2026-11-22 09:44:12.098
84e5b068-9d6a-478b-9065-772eecf3aaf4	f76e9070-3aba-4f3a-9e33-ac94e6faf02a	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/89d46fc4-f695-4f60-8083-bc4bf2fbfbcf.jpg	89d46fc4-f695-4f60-8083-bc4bf2fbfbcf.jpg	27	image/jpeg	2026-11-22 09:44:12.099
62474258-5de1-4e64-b4ed-67867096863a	f76e9070-3aba-4f3a-9e33-ac94e6faf02a	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/44c35ca6-b324-4b3f-b83e-29edf625450a.jpg	44c35ca6-b324-4b3f-b83e-29edf625450a.jpg	27	image/jpeg	2026-11-22 09:44:12.1
83e09e1f-c98b-4622-a247-3a34538178f1	ad9b7940-13bd-440f-8757-71e7b294e60b	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/85a47b9f-7103-47c1-b3b0-8070072f42f8.jpg	85a47b9f-7103-47c1-b3b0-8070072f42f8.jpg	27	image/jpeg	2026-11-22 09:44:12.21
9e05dd3e-ad26-4588-91ee-1c3f72f7f511	fa67a7ad-7e89-43f7-80fd-99f58a73a552	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/717bbf84-fd83-49f7-98a6-179289934332.jpg	717bbf84-fd83-49f7-98a6-179289934332.jpg	27	image/jpeg	2026-11-22 09:45:06.015
da6bdfdd-9f64-4d49-9658-bc0b890a9abe	fa67a7ad-7e89-43f7-80fd-99f58a73a552	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/c1e2c9e2-9cfe-4d3f-8d4b-a2a07b7e1742.jpg	c1e2c9e2-9cfe-4d3f-8d4b-a2a07b7e1742.jpg	27	image/jpeg	2026-11-22 09:45:06.017
1b9eedac-4b62-41a4-a6a2-f026a877c5b3	fa67a7ad-7e89-43f7-80fd-99f58a73a552	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/679d3f5f-1ade-477b-a2e4-33d828af1e03.jpg	679d3f5f-1ade-477b-a2e4-33d828af1e03.jpg	27	image/jpeg	2026-11-22 09:45:06.017
278b7697-e60f-48d4-84fb-42eb51bb62a3	fa67a7ad-7e89-43f7-80fd-99f58a73a552	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/657e1cb3-bb61-4bcb-879b-06edb7497210.jpg	657e1cb3-bb61-4bcb-879b-06edb7497210.jpg	27	image/jpeg	2026-11-22 09:45:06.018
5472d99c-45f1-41d7-ad07-6130208769cc	fa67a7ad-7e89-43f7-80fd-99f58a73a552	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/38241f7e-b7b3-4545-8736-4ff9e179591b.jpg	38241f7e-b7b3-4545-8736-4ff9e179591b.jpg	27	image/jpeg	2026-11-22 09:45:06.02
1f4ac6cf-98c8-4c96-be87-1342588549e1	c44d9de9-e220-471a-a660-f9e9889172e6	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/dc75662f-9803-4cc9-afcb-5dbd26f0d81f.jpg	dc75662f-9803-4cc9-afcb-5dbd26f0d81f.jpg	27	image/jpeg	2026-11-22 09:45:06.137
f3edd8b1-cb31-4e21-bc4e-88eef41f1dc3	c2c45bd0-744a-4cfc-8f98-da75dbaa6856	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/fc259b47-c498-4743-8cc3-d26b6c171049.png	fc259b47-c498-4743-8cc3-d26b6c171049.png	1024	image/png	2026-11-22 09:45:23.471
25bbfe2e-9aff-41b1-9e9d-885ac5abd2cf	5a8686f4-daa6-49c0-b823-5a8638ebe9be	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/9f7b5308-1eb1-4bf3-842b-80d1d16a42e3.jpg	9f7b5308-1eb1-4bf3-842b-80d1d16a42e3.jpg	27	image/jpeg	2026-11-22 09:45:41.302
e27bc0ba-927d-4da4-92b6-0d6f18b598d6	5a8686f4-daa6-49c0-b823-5a8638ebe9be	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/76ebd434-6513-48e1-85e3-77cab85ad579.jpg	76ebd434-6513-48e1-85e3-77cab85ad579.jpg	27	image/jpeg	2026-11-22 09:45:41.304
f2f4d3ce-de7f-4880-bdb2-e64fd9d16350	5a8686f4-daa6-49c0-b823-5a8638ebe9be	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/ebcba251-7c73-4bbb-bbaa-4f8995797b92.jpg	ebcba251-7c73-4bbb-bbaa-4f8995797b92.jpg	27	image/jpeg	2026-11-22 09:45:41.306
d9a009a7-0dc9-4666-a96f-54d2cd3146db	5a8686f4-daa6-49c0-b823-5a8638ebe9be	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/cf07029a-0179-4b01-ba94-1179d76414cf.jpg	cf07029a-0179-4b01-ba94-1179d76414cf.jpg	27	image/jpeg	2026-11-22 09:45:41.307
6f04024e-8f95-44e8-8f34-11c42719626c	5a8686f4-daa6-49c0-b823-5a8638ebe9be	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/9e79f9e8-be4b-4e3d-a0ad-ac869f973ee7.jpg	9e79f9e8-be4b-4e3d-a0ad-ac869f973ee7.jpg	27	image/jpeg	2026-11-22 09:45:41.307
9676cfcd-083e-4c79-9b02-5fef64a02b2f	1908a4f7-7d10-4220-b719-a210724204b4	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/30433f64-db72-4fce-8bb9-6c7db5c36249.jpg	30433f64-db72-4fce-8bb9-6c7db5c36249.jpg	27	image/jpeg	2026-11-22 09:45:41.42
c554205e-8879-41bb-a15f-4dd6fc668004	fc8dc4c5-ab5c-473d-bb51-22b9cc8d6dd5	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/67b3c40d-e749-484a-b940-5879ec996b09.jpg	67b3c40d-e749-484a-b940-5879ec996b09.jpg	27	image/jpeg	2026-11-22 10:04:24.954
2f1c197b-9ece-4b29-b74e-2724057fdd2a	fc8dc4c5-ab5c-473d-bb51-22b9cc8d6dd5	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/e281df1a-41c8-4b9c-9ea1-280d61876102.jpg	e281df1a-41c8-4b9c-9ea1-280d61876102.jpg	27	image/jpeg	2026-11-22 10:04:24.956
4714c919-8574-4e02-a4c1-7bb84d3813ff	fc8dc4c5-ab5c-473d-bb51-22b9cc8d6dd5	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/e3e9caf6-4d6f-42c8-92ad-aa61e7061535.jpg	e3e9caf6-4d6f-42c8-92ad-aa61e7061535.jpg	27	image/jpeg	2026-11-22 10:04:24.957
7af562eb-9b97-4715-9a45-84a4723247ae	fc8dc4c5-ab5c-473d-bb51-22b9cc8d6dd5	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/19676d28-fbe6-4949-8e60-7394e4b825af.jpg	19676d28-fbe6-4949-8e60-7394e4b825af.jpg	27	image/jpeg	2026-11-22 10:04:24.958
2588a89c-4bb8-4c14-8607-e38327c80a95	fc8dc4c5-ab5c-473d-bb51-22b9cc8d6dd5	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/d036ab69-bf40-4521-89d1-17a0b6db1788.jpg	d036ab69-bf40-4521-89d1-17a0b6db1788.jpg	27	image/jpeg	2026-11-22 10:04:24.959
2cc93668-7122-4253-b4de-5f0d34de067e	a578c4ff-cee0-4946-af65-f559f4b9b6fa	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/1c21f1cb-c306-43dc-a6a9-6ff418ff9a28.jpg	1c21f1cb-c306-43dc-a6a9-6ff418ff9a28.jpg	27	image/jpeg	2026-11-22 10:04:25.082
21ae7939-3f53-4d0e-b072-1685ef0e8a7d	a4d02411-9a89-44d9-b8e2-6da48e39119d	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/15bd6007-86b4-40be-85be-269a0ddc5790.png	15bd6007-86b4-40be-85be-269a0ddc5790.png	70	image/png	2026-11-22 10:05:07.17
d7803f5d-4ff8-4a53-9485-f6d4286a3f8b	7982f72d-591b-4a2e-8878-75d20cf69880	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/41269dc5-0629-4520-98d4-2cd27988c629.png	41269dc5-0629-4520-98d4-2cd27988c629.png	1024	image/png	2026-11-22 10:05:14.516
03fa5d22-efe9-4cc7-8ade-a5c85793cc73	fdcf9966-eba5-43a9-b670-91bb394d61e6	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/92ddf5d0-d57d-42e2-ad75-8eed5cf6c633.png	92ddf5d0-d57d-42e2-ad75-8eed5cf6c633.png	103376	image/png	2026-11-22 10:05:52.268
6da21df4-0e3c-4aba-a67a-ecbfe745865b	91c3a15d-1bf1-4abf-8431-29f025c4f750	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/e684750e-2c0f-48ae-a50c-e3e36c37a4c9.png	e684750e-2c0f-48ae-a50c-e3e36c37a4c9.png	70	image/png	2026-11-22 10:07:10.634
54b6a33b-24c0-4505-be98-69c4f0438b1a	e3e49559-2c2a-4d4e-b8d8-0fb7975bacf1	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/762ff43b-32b7-4795-ae0f-0b1f9cb4110f.png	762ff43b-32b7-4795-ae0f-0b1f9cb4110f.png	1024	image/png	2026-11-22 10:07:17.827
091f9f87-5162-4de9-ab7b-ac7c89acc8d9	1ba05733-bff4-477d-8dfc-a8841f2f748e	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/ef2998a9-ab40-41fe-8413-7f7df8f2a75c.jpg	ef2998a9-ab40-41fe-8413-7f7df8f2a75c.jpg	27	image/jpeg	2026-11-22 10:27:51.368
0ab995c1-90b6-4bd9-af3c-2bedd6a96b97	1ba05733-bff4-477d-8dfc-a8841f2f748e	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/51ed36b8-a621-44f8-976d-dc62c71ebb7f.jpg	51ed36b8-a621-44f8-976d-dc62c71ebb7f.jpg	27	image/jpeg	2026-11-22 10:27:51.37
436c1e03-f69c-4178-a60c-4b01251a5e7a	1ba05733-bff4-477d-8dfc-a8841f2f748e	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/97bb8ed0-e739-400c-b437-7e12e493250a.jpg	97bb8ed0-e739-400c-b437-7e12e493250a.jpg	27	image/jpeg	2026-11-22 10:27:51.371
54c1d95a-4415-422c-b0c9-275342c5b2c8	1ba05733-bff4-477d-8dfc-a8841f2f748e	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/84227f62-f316-4458-a133-1f015443546e.jpg	84227f62-f316-4458-a133-1f015443546e.jpg	27	image/jpeg	2026-11-22 10:27:51.372
d85a3f56-97f3-472d-a647-8e6a94549b09	1ba05733-bff4-477d-8dfc-a8841f2f748e	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/57717246-f829-4944-945b-65132f775203.jpg	57717246-f829-4944-945b-65132f775203.jpg	27	image/jpeg	2026-11-22 10:27:51.373
dea4faa6-0928-4368-a80d-ba042337eb93	7a6b871f-550a-4d03-a9cf-71ece348d97a	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/d364fd28-78a6-4cd3-a179-b3578a402f08.jpg	d364fd28-78a6-4cd3-a179-b3578a402f08.jpg	27	image/jpeg	2026-11-22 10:27:51.459
c293eace-89b9-4e26-bee9-e0851f3fa030	3060a900-70eb-4d89-b657-6c40840f6826	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/49ed68a9-5135-48cd-b425-27618e13d21b.png	49ed68a9-5135-48cd-b425-27618e13d21b.png	70	image/png	2026-11-22 10:39:22.56
d384e585-423c-480f-8d4a-45cbc7bada5d	8f445627-881d-455d-b1c9-a6d74934aa1e	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/1c9879d8-a5b9-4a0d-8cb9-f854fd87b4f1.png	1c9879d8-a5b9-4a0d-8cb9-f854fd87b4f1.png	1024	image/png	2026-11-22 10:39:29.794
e3a2a561-3741-4104-98cd-b88b368d5ff1	f36961f4-c7dc-4b8a-9d17-58ec54f3ebb0	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/b6cefb29-2e7b-43f8-85ba-adcdac4eb00b.jpg	b6cefb29-2e7b-43f8-85ba-adcdac4eb00b.jpg	27	image/jpeg	2026-11-22 10:42:22.705
93500ec0-a708-44c2-9461-517cd9ad9d37	f36961f4-c7dc-4b8a-9d17-58ec54f3ebb0	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/be167c11-18fa-41c9-b995-9674bef6ff4f.jpg	be167c11-18fa-41c9-b995-9674bef6ff4f.jpg	27	image/jpeg	2026-11-22 10:42:22.707
fe619040-de65-4465-b07f-176de03f0519	f36961f4-c7dc-4b8a-9d17-58ec54f3ebb0	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/2305bf6a-9fea-4dfe-a8bf-73e56750ee94.jpg	2305bf6a-9fea-4dfe-a8bf-73e56750ee94.jpg	27	image/jpeg	2026-11-22 10:42:22.708
68c9bc1f-5eba-45bb-bbed-16776748503e	f36961f4-c7dc-4b8a-9d17-58ec54f3ebb0	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/e63813ca-7089-4c11-a67d-d0d5135e1bb6.jpg	e63813ca-7089-4c11-a67d-d0d5135e1bb6.jpg	27	image/jpeg	2026-11-22 10:42:22.709
85d7af06-6dbd-445a-be55-0a90fee61e50	f36961f4-c7dc-4b8a-9d17-58ec54f3ebb0	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/9872c274-41ed-4305-8c8d-99d6d7d5cf18.jpg	9872c274-41ed-4305-8c8d-99d6d7d5cf18.jpg	27	image/jpeg	2026-11-22 10:42:22.71
009ae49e-1dee-40b6-92c5-ea959d6c99b0	37ec9d06-b6dc-467b-aa06-dca2c2261de5	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/0bfb926c-d821-4b03-8be9-0753000a817d.jpg	0bfb926c-d821-4b03-8be9-0753000a817d.jpg	27	image/jpeg	2026-11-22 10:42:22.812
beec7f01-d04b-49cb-9034-171e87d9864b	55e388e0-043b-4202-96e8-652a34019aff	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/a69ac9e8-0a4a-4066-938d-b9f6987a8a71.jpg	a69ac9e8-0a4a-4066-938d-b9f6987a8a71.jpg	27	image/jpeg	2026-11-22 10:59:11.842
132cd346-3d2a-48bf-aa35-cf5af0886070	55e388e0-043b-4202-96e8-652a34019aff	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/942a89a0-ce50-4fc4-a440-cea7b1ec6780.jpg	942a89a0-ce50-4fc4-a440-cea7b1ec6780.jpg	27	image/jpeg	2026-11-22 10:59:11.844
005b97bf-9e34-41ad-bf1a-e86960ce4d1b	55e388e0-043b-4202-96e8-652a34019aff	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/917c4537-54f4-4c99-a72f-12c0e4c7175e.jpg	917c4537-54f4-4c99-a72f-12c0e4c7175e.jpg	27	image/jpeg	2026-11-22 10:59:11.845
e34006df-1648-4bc5-a224-5122f538cc96	55e388e0-043b-4202-96e8-652a34019aff	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/e0f21184-a113-459d-874a-ec09ba9030c3.jpg	e0f21184-a113-459d-874a-ec09ba9030c3.jpg	27	image/jpeg	2026-11-22 10:59:11.846
6b9b1283-9238-44be-a73f-39bfd5e9ef42	55e388e0-043b-4202-96e8-652a34019aff	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/4e616e5f-dbf7-4050-9ff6-10d395dd1a17.jpg	4e616e5f-dbf7-4050-9ff6-10d395dd1a17.jpg	27	image/jpeg	2026-11-22 10:59:11.846
3e3a9789-96a4-4395-bbf6-6979359034e3	3983c895-de71-4f78-a820-71f8d744ad5f	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/d6393535-9d00-404e-8d99-3e20db67dac3.jpg	d6393535-9d00-404e-8d99-3e20db67dac3.jpg	27	image/jpeg	2026-11-22 10:59:11.961
74280f8b-1652-47c0-b382-956080c3c7fb	845e6757-b885-4e3a-bbed-6c57749bd625	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/f3d59651-ef8b-47d4-8e85-a6596afe36d7.jpg	f3d59651-ef8b-47d4-8e85-a6596afe36d7.jpg	27	image/jpeg	2026-11-22 11:06:32.311
e3fb0c8f-2d28-47a5-ac08-b53d9533bbf1	845e6757-b885-4e3a-bbed-6c57749bd625	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/e295e4c5-7481-45cd-9495-d4b554a5b8cb.jpg	e295e4c5-7481-45cd-9495-d4b554a5b8cb.jpg	27	image/jpeg	2026-11-22 11:06:32.313
d416ceb2-eebb-4b6a-a9a2-ec992009bc55	845e6757-b885-4e3a-bbed-6c57749bd625	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/7e708744-bfda-4105-adf3-9711213f97fa.jpg	7e708744-bfda-4105-adf3-9711213f97fa.jpg	27	image/jpeg	2026-11-22 11:06:32.315
d4ae90fb-1eca-46e7-a710-3ef45804c32e	845e6757-b885-4e3a-bbed-6c57749bd625	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/1b2844f7-0ab7-4a41-8e46-bc8b2b5b0eab.jpg	1b2844f7-0ab7-4a41-8e46-bc8b2b5b0eab.jpg	27	image/jpeg	2026-11-22 11:06:32.316
7451bad2-129d-43e3-b892-bbbe3e51add7	845e6757-b885-4e3a-bbed-6c57749bd625	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/e7b23fca-9e8a-4fa1-83d6-2c232b428808.jpg	e7b23fca-9e8a-4fa1-83d6-2c232b428808.jpg	27	image/jpeg	2026-11-22 11:06:32.318
7b3dda34-2c6e-4815-b896-877d7fc8bc34	250c2a5b-9c33-4b33-aba6-cf5c2162e9fd	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/0fa967b9-5458-46c8-8431-de70f68664fd.jpg	0fa967b9-5458-46c8-8431-de70f68664fd.jpg	27	image/jpeg	2026-11-22 11:06:32.431
71477453-5703-4a42-99e2-924278879ee7	312b7774-bd00-4e4b-9c0c-d0642c12a432	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/b123517e-9945-4a48-9eac-f69e01cd7440.png	b123517e-9945-4a48-9eac-f69e01cd7440.png	70	image/png	2026-11-22 11:07:36.256
efa7078a-6c51-424b-a6a4-798935540a3a	1c0a5cf0-9df0-4afb-aa9d-e4a46395adcd	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/4d26c9b6-6aac-48e7-834d-4b4ec23a9762.png	4d26c9b6-6aac-48e7-834d-4b4ec23a9762.png	1024	image/png	2026-11-22 11:07:43.565
910ade72-b3e8-48d1-819d-b1e42f280249	6becf48c-b717-4a4e-a1bd-01d4de22626a	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/e989f0e5-8373-43e9-9a5e-e28cc0ac16b6.jpg	e989f0e5-8373-43e9-9a5e-e28cc0ac16b6.jpg	27	image/jpeg	2026-11-22 11:25:32.939
737b31ba-1ff9-40cd-8a04-b8d7099e21fe	6becf48c-b717-4a4e-a1bd-01d4de22626a	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/6d6ce4de-009e-4157-9d5c-d9811ce0cf96.jpg	6d6ce4de-009e-4157-9d5c-d9811ce0cf96.jpg	27	image/jpeg	2026-11-22 11:25:32.941
48bf46d1-9cf7-4433-bece-62780a6199f0	6becf48c-b717-4a4e-a1bd-01d4de22626a	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/fc0ac0d9-36f1-4702-8cfa-739fa5485b28.jpg	fc0ac0d9-36f1-4702-8cfa-739fa5485b28.jpg	27	image/jpeg	2026-11-22 11:25:32.941
cbdd80fa-af6e-4061-a309-d2d50800ee6f	6becf48c-b717-4a4e-a1bd-01d4de22626a	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/c54971c6-4d98-4cf6-bc14-175328f33c45.jpg	c54971c6-4d98-4cf6-bc14-175328f33c45.jpg	27	image/jpeg	2026-11-22 11:25:32.942
abe214d9-6e45-49a2-bc11-31e14560c2ee	6becf48c-b717-4a4e-a1bd-01d4de22626a	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/47593896-685d-4689-9fef-ebbce687b01d.jpg	47593896-685d-4689-9fef-ebbce687b01d.jpg	27	image/jpeg	2026-11-22 11:25:32.944
467f52b5-e164-4811-af30-999f2d4ac382	f23b78d1-b4a0-4ea2-b3ca-2af9d7489f1e	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/98245028-9ace-4e0a-93d1-159cb89af510.jpg	98245028-9ace-4e0a-93d1-159cb89af510.jpg	27	image/jpeg	2026-11-22 11:25:33.05
4bb861d5-2910-419d-a565-c5939b18f7f8	7aacdfa6-e34b-4805-9d3e-c62e0d71be25	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/6ebc9bba-fed5-41cd-ab4b-bb23395bbd83.jpg	6ebc9bba-fed5-41cd-ab4b-bb23395bbd83.jpg	27	image/jpeg	2026-11-22 11:36:39.045
8cae3a9d-418f-4498-abb1-bba603722df6	7aacdfa6-e34b-4805-9d3e-c62e0d71be25	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/3bf11f20-b038-4571-88ea-6d987a4beb0f.jpg	3bf11f20-b038-4571-88ea-6d987a4beb0f.jpg	27	image/jpeg	2026-11-22 11:36:39.047
41b68bc8-25aa-4784-beab-fef19362b575	7aacdfa6-e34b-4805-9d3e-c62e0d71be25	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/ef5e4cc3-f834-4a85-8ea6-e416a11cd56b.jpg	ef5e4cc3-f834-4a85-8ea6-e416a11cd56b.jpg	27	image/jpeg	2026-11-22 11:36:39.049
e9c137cf-aee5-4701-945b-986c7d36ba87	7aacdfa6-e34b-4805-9d3e-c62e0d71be25	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/fc78e44f-d3f6-4798-867c-9bf46742aeb7.jpg	fc78e44f-d3f6-4798-867c-9bf46742aeb7.jpg	27	image/jpeg	2026-11-22 11:36:39.05
860b827b-054b-4e62-bdcf-afafaa66c5b4	7aacdfa6-e34b-4805-9d3e-c62e0d71be25	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/de4038cf-1172-43d8-bff2-76e6191649d5.jpg	de4038cf-1172-43d8-bff2-76e6191649d5.jpg	27	image/jpeg	2026-11-22 11:36:39.051
114cd153-1dbf-4e1a-aef5-7e73352a3188	fb7b8b5b-800f-42d6-887e-fdcbeee3bbfc	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/56bd2cf9-aa66-4ebb-afab-9bee4b573aee.jpg	56bd2cf9-aa66-4ebb-afab-9bee4b573aee.jpg	27	image/jpeg	2026-11-22 11:36:39.17
cb4617fa-eae7-41fb-a2d1-9380a7f29228	4293a444-f8c9-4993-8c12-683415bf4f95	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/924cc24f-b586-434e-afe0-5eb1621b5710.jpg	924cc24f-b586-434e-afe0-5eb1621b5710.jpg	27	image/jpeg	2026-11-22 11:55:24.762
35a530d9-3c05-4ad0-b532-5169f95e9e26	4293a444-f8c9-4993-8c12-683415bf4f95	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/c3c2f5dc-a9b8-49ae-8793-ce18ea50f721.jpg	c3c2f5dc-a9b8-49ae-8793-ce18ea50f721.jpg	27	image/jpeg	2026-11-22 11:55:24.764
f2720a2d-ac87-4551-83a4-19c773c446ed	4293a444-f8c9-4993-8c12-683415bf4f95	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/4a56e19e-eb0c-4d77-80ef-215cbf319d5d.jpg	4a56e19e-eb0c-4d77-80ef-215cbf319d5d.jpg	27	image/jpeg	2026-11-22 11:55:24.765
e15f0e7c-36c5-403f-92fc-217d5f9a6c7d	4293a444-f8c9-4993-8c12-683415bf4f95	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/85b9777c-8491-4aef-909b-7aca3265b3b7.jpg	85b9777c-8491-4aef-909b-7aca3265b3b7.jpg	27	image/jpeg	2026-11-22 11:55:24.766
7d207632-46b3-4664-8874-1d31cc8016de	4293a444-f8c9-4993-8c12-683415bf4f95	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/ffd90192-bea9-4af4-bb8f-4cfbfa288ddb.jpg	ffd90192-bea9-4af4-bb8f-4cfbfa288ddb.jpg	27	image/jpeg	2026-11-22 11:55:24.767
84bf7688-85f8-43c6-8fc5-1ed5886c6e9b	3ad6e8f9-bb57-4011-8b0c-c6e394cefbfe	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/5707d863-e48e-4584-8b99-c4d5658b8516.jpg	5707d863-e48e-4584-8b99-c4d5658b8516.jpg	27	image/jpeg	2026-11-22 11:55:24.898
f26a4429-1a57-4406-bb51-70666d525c15	f6f383be-6c44-4f0e-bb2b-45cea04224da	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/9f9453a5-af6f-4b42-8c22-fe2a9f6f6537.png	9f9453a5-af6f-4b42-8c22-fe2a9f6f6537.png	70	image/png	2026-11-22 11:56:24.025
7082d1fd-d2a1-4298-9a54-0cdd4eb2b17f	e317df69-1c34-4324-a280-aa0d53c1112d	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/b7ceb518-f68c-4d2d-b22d-7067bb2ef2ee.png	b7ceb518-f68c-4d2d-b22d-7067bb2ef2ee.png	1024	image/png	2026-11-22 11:56:31.037
f93c9bb8-20a0-469d-ab24-dfdcb88e570d	6dc19581-1f1f-4a36-a677-4a50b150fce5	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/af480caa-b832-4d30-a3b6-bdbf0decb720.png	af480caa-b832-4d30-a3b6-bdbf0decb720.png	70	image/png	2026-11-22 12:03:42.568
8b329f17-91e3-4274-9314-dcb3a20e73c3	69551a64-33a8-4e75-8baf-2b9e850826fe	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/56bb6285-9ebb-4148-9430-edf90557f00d.png	56bb6285-9ebb-4148-9430-edf90557f00d.png	1024	image/png	2026-11-22 12:03:49.436
fe1bf476-9579-4608-a890-e972cbea8e14	3a38191a-aba1-4735-9a13-ed6afac739cb	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/7190d833-8538-4a38-8ff8-f2a4728e3b7b.png	7190d833-8538-4a38-8ff8-f2a4728e3b7b.png	407264	image/png	2026-11-22 12:13:07.301
9e7c8a19-fdc8-4f74-b9da-671255ad80db	46a295dd-9804-4bb2-89df-48c6eb40c4c8	D:/VEHICLE BRAKDOWN SYSTEM/backend/uploads/breakdowns/e8d92526-b841-4a7e-83fb-815716df8744.png	e8d92526-b841-4a7e-83fb-815716df8744.png	70	image/png	2026-11-22 13:19:19.424
\.


--
-- Data for Name: Review; Type: TABLE DATA; Schema: public; Owner: vbrs_admin
--

COPY public."Review" (id, "serviceRequestId", "customerId", "mechanicId", rating, comment, "timelinessRating", "costFairnessRating", "professionalismRating", "createdAt") FROM stdin;
0564b2d3-43c7-4184-95a8-d56519fcd64c	3d12e366-056e-4d9e-a27e-c1b717198d9a	6a3159ce-3ec1-46ee-8854-079b5cef5d0c	75f044c3-f5b8-4bd8-acf9-e6ad9535b56c	5	Alex arrived in 8 minutes and diagnosed the engine stall accurately. Professional work.	5	5	5	2026-11-22 11:25:10.731
e746c8f6-d66d-4bf8-9f3c-9004cdb9ce0d	7af7a836-25ca-4a4f-bd06-caaac1bbeab1	efeb8cd7-f7cc-4dfd-8689-240f124ae2a4	75f044c3-f5b8-4bd8-acf9-e6ad9535b56c	3	Service completed, but dispatch took longer than estimated.	2	4	4	2026-11-22 11:25:10.757
2a3203dd-fbf1-4ef4-8c28-11a9e70d674a	6ad56e3d-d58d-4bf6-b034-c4b06c43d3e1	84ecd965-cf9b-4db3-92a0-2fb64a3e965f	999b01aa-2778-4a6d-8a8d-174220f8ecb5	5	Alex arrived in 8 minutes and diagnosed the engine stall accurately. Professional work.	5	5	5	2026-11-22 11:25:32.162
9e6e819a-74f5-48a4-9727-f2c9ca56d7fb	03bcf51f-5635-4ed8-92c8-f4215a2cb872	3517d75c-d341-43ab-b318-7b13f2026e31	999b01aa-2778-4a6d-8a8d-174220f8ecb5	3	Service completed, but dispatch took longer than estimated.	2	4	4	2026-11-22 11:25:32.192
1c38b5cd-297c-4632-bcef-00143da905a8	4fcacb83-fe1b-460a-bf1f-1a5c80cccd66	e22478b0-00a4-44f8-b146-3649213c7a20	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	5	Alex Vance arrived in record time on the FDR Drive. Flawless diagnostics and repair.	5	5	5	2026-11-22 11:36:12.979
00def108-07e7-48e0-9416-77f2aa6d4611	8444154d-cd02-40d3-92f1-0cbcad7d9fef	03049ccb-baf0-499d-aa2d-d5dce89114ad	589cd51a-0952-445a-98ce-8b00ad9d3e44	5	Alex arrived in 8 minutes and diagnosed the engine stall accurately. Professional work.	5	5	5	2026-11-22 11:36:39.085
d0e98bcc-42b1-4b25-af8f-df1f4808b811	29942811-6dc9-482d-ac87-f157debf369e	4c50ae6c-ef63-4e39-a5b0-d01121d5eb64	589cd51a-0952-445a-98ce-8b00ad9d3e44	3	Service completed, but dispatch took longer than estimated.	2	4	4	2026-11-22 11:36:39.121
40f5929f-7393-45ac-808b-42d7ae5615bd	ed670800-8de3-451e-9d9d-1140d81e0f62	c5be2c05-7982-46af-9db0-2f3f296f630b	243c49ee-6224-4c57-95ee-8b9a7367ed63	5	Alex arrived in 8 minutes and diagnosed the engine stall accurately. Professional work.	5	5	5	2026-11-22 11:55:24.922
6cacda2c-1625-4f73-a427-33fb6833e800	d73e5417-717c-4745-9e50-e1b68a2d557b	863029a2-5a25-4be2-be07-0680e859f3f2	243c49ee-6224-4c57-95ee-8b9a7367ed63	3	Service completed, but dispatch took longer than estimated.	2	4	4	2026-11-22 11:55:24.961
dda6921d-03ff-4741-bc74-83c8c19bf818	509d0dc3-a2fa-46ad-b58c-2af009fdab06	e22478b0-00a4-44f8-b146-3649213c7a20	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	5	Alex Vance arrived in record time on the FDR Drive. Flawless diagnostics and repair.	5	5	5	2026-11-22 12:04:46.574
fbf448af-d3bf-478f-8823-0a9687ce4875	6c736916-d02f-4279-8270-49f6f054f32f	a1479806-db8e-432b-a61a-04b1494faf85	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	5	\N	5	5	5	2026-11-22 12:14:40.99
\.


--
-- Data for Name: SavedAddress; Type: TABLE DATA; Schema: public; Owner: vbrs_admin
--

COPY public."SavedAddress" (id, "userId", label, address, latitude, longitude, "isDefault", "createdAt", "updatedAt") FROM stdin;
aebd6d1b-26dc-46d2-afbd-6053caeec970	e22478b0-00a4-44f8-b146-3649213c7a20	Metro Office Headquarters	450 Lexington Ave, New York, NY 10017	40.7516	-73.9754	f	2026-11-22 13:15:55.506	2026-11-22 13:15:55.506
75e1232a-7073-4311-8557-bf720e3c4335	e22478b0-00a4-44f8-b146-3649213c7a20	Metro Office Headquarters	450 Lexington Ave, New York, NY 10017	40.7516	-73.9754	f	2026-11-22 13:16:55.021	2026-11-22 13:16:55.021
\.


--
-- Data for Name: ServiceRequest; Type: TABLE DATA; Schema: public; Owner: vbrs_admin
--

COPY public."ServiceRequest" (id, "breakdownReportId", "customerId", "mechanicId", "currentStatus", "agreedQuote", "resolutionNotes", "cancellationReason", "assignedAt", "acceptedAt", "enRouteAt", "arrivedAt", "completedAt", "cancelledAt", "createdAt", "updatedAt", "diagnosticQuote", "inProgressAt", "laborCost", "locationConsent", "partsCost") FROM stdin;
cfcb4df3-b199-4ed3-9448-0f6165f70602	2f6f5479-7230-441a-a606-89737498bd2e	20e961e5-4364-4013-ac83-b3cdac902909	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:58:26.386	2026-11-22 10:58:26.386	\N	\N	\N	t	\N
3d764039-fbc9-421e-a813-fb285f17d02a	0a6ec4bc-6c69-41a4-8c12-16da50b7eed2	50d7979c-85db-4cec-8bb2-83ba29ebae7d	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 09:21:13.147	2026-11-22 09:21:13.147	\N	\N	\N	t	\N
3886aef0-6b77-458e-9566-5b629a76125b	96554164-ec44-4988-80f1-01ab3b1c79d1	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 09:26:53.357	2026-11-22 09:26:53.357	\N	\N	\N	t	\N
8976714b-96d2-4287-b82a-15d56f1c5d19	f6f383be-6c44-4f0e-bb2b-45cea04224da	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:56:24.026	2026-11-22 11:56:24.026	\N	\N	\N	t	\N
eb433a1d-810f-4de2-ad63-76cdfd5002be	7a88dee1-d1a2-4e53-94f5-40d9b4416e45	15a87756-ecb4-4394-8fb7-5555263f9a09	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 09:27:11.286	2026-11-22 09:27:11.286	\N	\N	\N	t	\N
b4e332ba-a573-4996-bb86-4d2426139026	4b1cbadd-3c17-469f-9e59-9fa9f8caeddf	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 09:27:47.822	2026-11-22 09:27:47.822	\N	\N	\N	t	\N
fa8bf085-e45b-4a14-b1ad-67ca5618629b	ea3fcfd7-078d-499f-a11d-37196fec2b8a	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:56:35.183	2026-11-22 11:56:35.183	\N	\N	\N	t	\N
74b49a22-ee5d-4f5a-9ffd-3cd85e467198	f76e9070-3aba-4f3a-9e33-ac94e6faf02a	baf36b48-83b6-4d2a-acaf-1145a539c456	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 09:44:12.101	2026-11-22 09:44:12.101	\N	\N	\N	t	\N
f12da20a-ec70-4b56-98bf-9dc70a31fbb8	4a2c7d09-7c83-448d-98a0-23054976798f	baf36b48-83b6-4d2a-acaf-1145a539c456	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 09:44:12.179	2026-11-22 09:44:12.179	\N	\N	\N	t	\N
6e72a3b4-3fd5-4c32-9d7b-52f1f9da742f	ad9b7940-13bd-440f-8757-71e7b294e60b	baf36b48-83b6-4d2a-acaf-1145a539c456	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 09:44:12.211	2026-11-22 09:44:12.211	\N	\N	\N	t	\N
d4dd281f-5688-4008-b655-ebb668de760a	c37150a4-c1a3-4e50-98f6-69c74acc7660	baf36b48-83b6-4d2a-acaf-1145a539c456	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 09:44:12.237	2026-11-22 09:44:12.237	\N	\N	\N	t	\N
a5b34810-0c7f-431a-ad01-20a9249ab707	32b617aa-ebc7-47e0-af57-bd79e34f9620	baf36b48-83b6-4d2a-acaf-1145a539c456	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 09:44:12.281	2026-11-22 09:44:12.281	\N	\N	\N	t	\N
98bd288a-b73d-45aa-993b-a42c7e5e3a81	2089cf9c-dcc4-419d-8c04-6196c3a0c4cd	baf36b48-83b6-4d2a-acaf-1145a539c456	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 09:44:12.299	2026-11-22 09:44:12.299	\N	\N	\N	t	\N
39498ce0-ad28-487e-a944-cc96dcab3139	fa67a7ad-7e89-43f7-80fd-99f58a73a552	19b6e30e-7ab8-4db5-87e5-443815e3d455	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 09:45:06.021	2026-11-22 09:45:06.021	\N	\N	\N	t	\N
f96a076f-2d6a-4fe9-9cc3-f5100920d335	3a7e419c-1ce3-4144-b326-0170d6e45376	19b6e30e-7ab8-4db5-87e5-443815e3d455	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 09:45:06.102	2026-11-22 09:45:06.102	\N	\N	\N	t	\N
55ebdc47-4378-49c3-9dfd-0975112104ae	c44d9de9-e220-471a-a660-f9e9889172e6	19b6e30e-7ab8-4db5-87e5-443815e3d455	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 09:45:06.138	2026-11-22 09:45:06.138	\N	\N	\N	t	\N
dbacc02a-d49f-4754-bc77-ec30a4aed4ca	674595de-9258-485b-b45d-77d2ecee5127	19b6e30e-7ab8-4db5-87e5-443815e3d455	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 09:45:06.168	2026-11-22 09:45:06.168	\N	\N	\N	t	\N
78d11ea4-e697-419d-b356-f53b650e7e58	0291a50b-a345-4dd0-acf0-3bf5a8db0ee9	19b6e30e-7ab8-4db5-87e5-443815e3d455	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 09:45:06.208	2026-11-22 09:45:06.208	\N	\N	\N	t	\N
5cc2464e-95e7-4b5d-9e06-755bf56a8a5a	5fa41250-ea00-41e9-abd0-04429f937a1d	19b6e30e-7ab8-4db5-87e5-443815e3d455	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 09:45:06.226	2026-11-22 09:45:06.226	\N	\N	\N	t	\N
973c540e-4f58-4333-a50c-6365fe81abd5	c2c45bd0-744a-4cfc-8f98-da75dbaa6856	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 09:45:23.473	2026-11-22 09:45:23.473	\N	\N	\N	t	\N
57485083-3928-4650-9799-f7c920e0c346	e036aab4-73c2-4e0e-9747-23dc5a2f4c85	436d667c-cc9f-4294-b2c9-cc95e0cb3d7e	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 09:45:40.801	2026-11-22 09:45:40.801	\N	\N	\N	t	\N
9e9dd155-7f6d-4d89-a6cb-2e26a1b62a58	5a8686f4-daa6-49c0-b823-5a8638ebe9be	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 09:45:41.308	2026-11-22 09:45:41.308	\N	\N	\N	t	\N
750ea674-acc2-4bad-926f-8de19f88228b	587fdbe5-1a1b-428c-b115-56f9e2f8a082	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 09:45:41.384	2026-11-22 09:45:41.384	\N	\N	\N	t	\N
ead81a34-0bc4-437c-9103-d51418ee6d15	1908a4f7-7d10-4220-b719-a210724204b4	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 09:45:41.421	2026-11-22 09:45:41.421	\N	\N	\N	t	\N
f18463f0-068a-44f3-a5a1-ab4a682e8f00	4ab03dd0-a9f5-4e79-98b3-4836fec17438	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 09:45:41.448	2026-11-22 09:45:41.448	\N	\N	\N	t	\N
cf25bc49-02f4-41ba-93b8-58664fe797ed	7c2217e1-09be-41f7-b5bb-34f267cf8522	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 09:45:41.501	2026-11-22 09:45:41.501	\N	\N	\N	t	\N
66427ff8-abc6-4aae-9538-ec04fabfe06d	8decfb7a-033e-455d-8aa0-e0e1ac809af7	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 09:45:41.52	2026-11-22 09:45:41.52	\N	\N	\N	t	\N
ded6c69a-a1a8-4a2e-9f39-07bec4eb671d	53f67df2-b542-4764-a1b2-8b758f50f8c7	a9541389-845a-425d-9b38-1de039a56cdc	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:04:24.443	2026-11-22 10:04:24.443	\N	\N	\N	t	\N
af28145c-8626-49ce-9951-b35e22a477fc	fc8dc4c5-ab5c-473d-bb51-22b9cc8d6dd5	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:04:24.959	2026-11-22 10:04:24.959	\N	\N	\N	t	\N
043fa575-732d-4bb3-8633-3aa428b6ab3e	9909c3eb-b894-449e-b6d5-2049b92f7175	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:04:25.047	2026-11-22 10:04:25.047	\N	\N	\N	t	\N
97d35a87-f586-4ced-b07b-1ad365b5ed3a	a578c4ff-cee0-4946-af65-f559f4b9b6fa	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:04:25.084	2026-11-22 10:04:25.084	\N	\N	\N	t	\N
c2e4fc73-b24c-49f1-a2ed-45821cebf266	46bd39e8-861b-40d8-9cb7-cd6bc6b8e35e	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:04:25.118	2026-11-22 10:04:25.118	\N	\N	\N	t	\N
fa84672b-7066-49bc-9f46-ce92ef6f0908	a016f173-c441-45c4-9cf4-152f75c6e3d2	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:04:25.166	2026-11-22 10:04:25.166	\N	\N	\N	t	\N
4bd28846-0ecb-483e-9e8f-17c17600a14b	885504d8-bd8d-4147-a152-c92ce24fc194	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:04:25.19	2026-11-22 10:04:25.19	\N	\N	\N	t	\N
18c226e4-7de3-4271-a17b-f1a2d363fbc2	a4d02411-9a89-44d9-b8e2-6da48e39119d	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:05:07.173	2026-11-22 10:05:07.173	\N	\N	\N	t	\N
447719be-c9f3-4c7b-9648-482c23ff5e5e	7982f72d-591b-4a2e-8878-75d20cf69880	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:05:14.518	2026-11-22 10:05:14.518	\N	\N	\N	t	\N
78739135-48ab-424b-b74e-a39a01c16ec6	82947b09-584a-4553-a16e-7cd456f98066	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:05:19.367	2026-11-22 10:05:19.367	\N	\N	\N	t	\N
72c2a772-e60c-45c2-a82c-9d4473a4b4cc	91c3a15d-1bf1-4abf-8431-29f025c4f750	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:07:10.635	2026-11-22 10:07:10.635	\N	\N	\N	t	\N
48056c07-2335-49dd-a645-da59864ef674	e3e49559-2c2a-4d4e-b8d8-0fb7975bacf1	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:07:17.828	2026-11-22 10:07:17.828	\N	\N	\N	t	\N
e382972d-2908-4540-82bd-2ec090c370f1	e317df69-1c34-4324-a280-aa0d53c1112d	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:56:31.039	2026-11-22 11:56:31.039	\N	\N	\N	t	\N
46de9cc7-0ffd-4f17-934b-809a3ff3be0e	0fb0713e-6959-4252-9617-409ed77d5d0b	a180a88c-5a9a-4731-add7-99d767857c44	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:58:53.204	2026-11-22 10:58:53.204	\N	\N	\N	t	\N
a01211c3-c349-4cef-8093-5f025def504c	caef5174-7257-4164-a0c8-d5ca83b3ad21	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:16:21.164	2026-11-22 10:16:21.164	\N	\N	\N	t	\N
16969eb4-7b76-4134-b1fc-c50859b2b7a2	dda8d6a2-240d-4b27-b15f-54bcc9a5beba	b492f8a7-29a4-4012-a173-bb1cf5135319	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:27:10.614	2026-11-22 10:27:10.614	\N	\N	\N	t	\N
cc46598d-dcfb-4c7d-a0e0-8870a7fce0a4	7556b623-3902-4eff-8a9a-4b3be77aa533	e22478b0-00a4-44f8-b146-3649213c7a20	26862790-bdc3-4714-aa48-5991f7550785	COMPLETED	\N	\N	\N	\N	2026-11-22 10:14:54.222	\N	\N	2026-11-22 12:00:39.404	\N	2026-11-22 10:14:48.544	2026-11-22 12:00:39.433	\N	\N	\N	t	\N
43f9bea4-e74b-494e-ac24-ff66160fcc33	79851066-2d2b-4a9f-9dd3-d8bb0c442eb3	201144dc-4d12-4765-8873-8573ebc70566	723df3b7-5251-4293-a82b-1646a8ce2fc5	CANCELLED	\N	\N	Spare tire located; vehicle changed independently.	\N	2026-11-22 10:27:51.276	\N	\N	\N	2026-11-22 10:27:51.298	2026-11-22 10:27:51.26	2026-11-22 10:27:51.302	\N	\N	\N	t	\N
3ff1ea13-607d-456a-a855-6218f6449202	e672ae2d-233d-4c1f-a871-97933ebc0aeb	9ad0fc29-8daf-4688-925e-9fa71d6a2e80	2bd8c6e5-44ca-4c80-a6bb-2ddc2b6fe55e	COMPLETED	270	Replaced ignition coil pack #3, cleared DTC trouble codes, engine running smoothly at idle.	\N	\N	2026-11-22 10:27:35.275	2026-11-22 10:27:35.38	2026-11-22 10:27:35.404	2026-11-22 10:27:35.552	\N	2026-11-22 10:27:35.249	2026-11-22 10:27:35.555	65	2026-11-22 10:27:35.53	120	t	85
5e172816-2bbd-40fa-8ab1-9681da002123	8ff0aadf-81d0-4301-9924-e3a44262c18d	9ad0fc29-8daf-4688-925e-9fa71d6a2e80	2bd8c6e5-44ca-4c80-a6bb-2ddc2b6fe55e	CANCELLED	\N	\N	Spare tire located; vehicle changed independently.	\N	2026-11-22 10:27:35.619	\N	\N	\N	2026-11-22 10:27:35.637	2026-11-22 10:27:35.604	2026-11-22 10:27:35.639	\N	\N	\N	t	\N
51384e1b-99f0-4db4-82af-19765954040b	63198c8d-3d23-45b6-bc85-044e2ee375b1	4fb4b922-a2e7-4d24-9e81-1bae59ab792b	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:27:51.051	2026-11-22 10:27:51.051	\N	\N	\N	t	\N
edd9350f-57ba-4afc-9012-3c33bfee850f	1ba05733-bff4-477d-8dfc-a8841f2f748e	e05d0c61-e1ae-4921-8453-3dc06525dc08	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:27:51.373	2026-11-22 10:27:51.373	\N	\N	\N	t	\N
a0f6e6c2-fba1-49c2-923b-dd60e4c0e159	d54c176b-181b-4a76-b260-9f49db13bc87	201144dc-4d12-4765-8873-8573ebc70566	723df3b7-5251-4293-a82b-1646a8ce2fc5	COMPLETED	270	Replaced ignition coil pack #3, cleared DTC trouble codes, engine running smoothly at idle.	\N	\N	2026-11-22 10:27:50.897	2026-11-22 10:27:51.021	2026-11-22 10:27:51.05	2026-11-22 10:27:51.198	\N	2026-11-22 10:27:50.871	2026-11-22 10:27:51.203	65	2026-11-22 10:27:51.172	120	t	85
ce00cc34-7d7d-494a-b57e-100759b7de17	7a6b871f-550a-4d03-a9cf-71ece348d97a	e05d0c61-e1ae-4921-8453-3dc06525dc08	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:27:51.46	2026-11-22 10:27:51.46	\N	\N	\N	t	\N
96aa711f-4ebb-4db9-a126-2904883ac599	6f521e4d-97b7-4daf-8fcd-c6d0edc39fa5	e05d0c61-e1ae-4921-8453-3dc06525dc08	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:27:51.481	2026-11-22 10:27:51.481	\N	\N	\N	t	\N
b186dee4-58ad-4285-9ea0-51bfa75dcf31	194fa08d-3216-4710-ad41-ce79605b6167	e05d0c61-e1ae-4921-8453-3dc06525dc08	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:27:51.525	2026-11-22 10:27:51.525	\N	\N	\N	t	\N
89f3a469-2aae-40f1-aa53-d31dc6300aa9	45212516-769e-48e1-9d56-9f797caa2695	e05d0c61-e1ae-4921-8453-3dc06525dc08	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:27:51.54	2026-11-22 10:27:51.54	\N	\N	\N	t	\N
c96e2b21-805b-41cc-ab1a-ae5de8f32b56	4f3570aa-66c5-4061-aebb-2dc2b9e84fa8	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:35:04.787	2026-11-22 10:35:04.787	\N	\N	\N	t	\N
4aee0e90-eaf2-4979-97d8-40d337cfd0aa	827b2ca4-1958-4ee9-a506-7d53e59a37c4	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:36:13.029	2026-11-22 10:36:13.029	\N	\N	\N	t	\N
e8622675-c26b-4432-8487-e7fa171c4d07	177e2af1-8d2d-4e15-8535-c0bd9ea873d3	e05d0c61-e1ae-4921-8453-3dc06525dc08	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	COMPLETED	260	Service completed. Vehicle operation verified.	\N	\N	2026-11-22 10:36:16.353	2026-11-22 10:36:16.418	2026-11-22 10:36:19.237	2026-11-22 10:36:21.012	\N	2026-11-22 10:27:51.432	2026-11-22 10:36:21.016	65	2026-11-22 10:36:20.902	120	t	75
1ccb5362-0ecf-4938-842e-e453d9b4ed9b	45a12b7f-7c1d-4f45-88cf-5f1a176b248f	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:37:45.607	2026-11-22 10:37:45.607	\N	\N	\N	t	\N
5667e3e6-1685-49a1-ae1b-73e2d7019d11	b41f8148-a8cc-415a-a969-080e2567ec3a	e22478b0-00a4-44f8-b146-3649213c7a20	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	COMPLETED	260	Service completed. Vehicle operation verified.	\N	\N	2026-11-22 10:38:39.062	2026-11-22 10:38:39.121	2026-11-22 10:38:41.66	2026-11-22 10:38:43.411	\N	2026-11-22 10:38:35.647	2026-11-22 10:38:43.415	65	2026-11-22 10:38:43.306	120	t	75
49450716-fcc2-44a0-8567-0f8c5d6ab7a0	3060a900-70eb-4d89-b657-6c40840f6826	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:39:22.561	2026-11-22 10:39:22.561	\N	\N	\N	t	\N
1522a43d-a323-41f9-a9d5-67463ebc323d	8f445627-881d-455d-b1c9-a6d74934aa1e	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:39:29.795	2026-11-22 10:39:29.795	\N	\N	\N	t	\N
cf01e1d7-1509-40ec-a5d3-63f04e652d0c	4adea7f8-dfaa-41aa-a515-63c4226ce422	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:40:01.757	2026-11-22 10:40:01.757	\N	\N	\N	t	\N
f01f0ecf-e901-471b-a4b8-da8a852f0789	f36961f4-c7dc-4b8a-9d17-58ec54f3ebb0	b347ca38-e44c-42ac-a846-63d4b6c28e3a	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:42:22.711	2026-11-22 10:42:22.711	\N	\N	\N	t	\N
38ab3d1d-0dd4-4a0b-9a07-a072a106b9ea	33b43356-f4a9-42ac-a15c-158e87f1cb36	e22478b0-00a4-44f8-b146-3649213c7a20	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	COMPLETED	260	Service completed. Vehicle operation verified.	\N	\N	2026-11-22 10:41:51.987	2026-11-22 10:41:52.047	2026-11-22 10:41:54.6	2026-11-22 10:41:56.343	\N	2026-11-22 10:41:48.679	2026-11-22 10:41:56.346	65	2026-11-22 10:41:56.246	120	t	75
1d7dde36-f3a9-4f99-bad1-adcbbeab529d	99590f73-1eef-4a9e-b6ae-78f5cfb87434	e51a5048-6c2d-466a-ae62-613927b40269	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:42:22.421	2026-11-22 10:42:22.421	\N	\N	\N	t	\N
4e48bdf2-f63d-4b6f-8e2a-41641c5c2a86	3e3c598a-bce1-4477-95db-2e1f397dd5ae	b347ca38-e44c-42ac-a846-63d4b6c28e3a	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:42:22.78	2026-11-22 10:42:22.78	\N	\N	\N	t	\N
29996938-70f4-4fee-bed3-a90ad4e9c1f4	37ec9d06-b6dc-467b-aa06-dca2c2261de5	b347ca38-e44c-42ac-a846-63d4b6c28e3a	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:42:22.813	2026-11-22 10:42:22.813	\N	\N	\N	t	\N
3e903ed0-fb76-4875-9ebe-b8a9497781c7	731f9dfc-8b40-4c89-bf73-6c022755f9e8	b347ca38-e44c-42ac-a846-63d4b6c28e3a	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:42:22.84	2026-11-22 10:42:22.84	\N	\N	\N	t	\N
499fb770-ca14-4a73-9b75-3960da9e0f60	0965a46b-e716-4562-bf7e-d6860dd16d85	b347ca38-e44c-42ac-a846-63d4b6c28e3a	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:42:22.877	2026-11-22 10:42:22.877	\N	\N	\N	t	\N
da6cc39b-db40-465a-bc87-cb6f0c3fc8a3	1c237f6e-ad6e-44b7-bdb8-ba299173c09e	b347ca38-e44c-42ac-a846-63d4b6c28e3a	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:42:22.892	2026-11-22 10:42:22.892	\N	\N	\N	t	\N
0c60b08f-e918-4c69-a585-045e9c65ff7d	356f7a77-62de-4030-8ff7-bc494a984788	2ae75f04-e851-4d24-81dc-67588ba24232	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:59:10.908	2026-11-22 10:59:10.908	\N	\N	\N	t	\N
a7ba10f4-e2f0-4a33-abb1-fe9374a5fa7f	6e0769cf-4206-4c87-adf3-2c0306c5b847	23e55200-8e86-4e87-92e2-b55e228b92f3	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:59:11.551	2026-11-22 10:59:11.551	\N	\N	\N	t	\N
31fa8134-34e3-4836-859c-fe385f1765cd	a6fcd4c2-f7f3-430e-8150-212f49720f2c	babb78bc-8995-47e3-873b-d77a0c81a425	e11d2861-51e7-4f1b-9d3c-596ba5c6ba45	COMPLETED	\N	\N	\N	\N	2026-11-22 09:59:33.63	\N	\N	2026-11-22 12:00:39.404	\N	2026-11-22 09:59:33.365	2026-11-22 12:00:39.433	\N	\N	\N	t	\N
c29e8286-f16b-40c6-a762-4e6376c2e575	55e388e0-043b-4202-96e8-652a34019aff	245a9356-c816-4507-8269-0fc18dd346f9	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:59:11.847	2026-11-22 10:59:11.847	\N	\N	\N	t	\N
2631ce63-4446-4c41-820f-cbc61ef9da47	9cc682bc-3f0d-49cb-8d74-a50b0a2c1f64	245a9356-c816-4507-8269-0fc18dd346f9	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:59:11.925	2026-11-22 10:59:11.925	\N	\N	\N	t	\N
c0196faf-c92c-4aa7-803d-e5f968d1ee3d	6b1cdabf-63d4-48d3-b4c4-eb8149b50d3c	24d8704e-eebc-4c21-986b-d85a1ed5a92a	44d77d53-44ac-4dbd-b34c-964ec9926154	COMPLETED	270	Replaced ignition coil pack #3, cleared DTC trouble codes, engine running smoothly at idle.	\N	\N	2026-11-22 10:42:23.196	2026-11-22 10:42:23.333	2026-11-22 10:42:23.366	2026-11-22 10:42:23.5	\N	2026-11-22 10:42:23.161	2026-11-22 10:42:23.503	65	2026-11-22 10:42:23.473	120	t	85
43f56aac-9c0a-4c09-926e-e4a6d2533fb4	3983c895-de71-4f78-a820-71f8d744ad5f	245a9356-c816-4507-8269-0fc18dd346f9	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:59:11.962	2026-11-22 10:59:11.962	\N	\N	\N	t	\N
1995f625-de53-466f-a0d1-2fda96929924	d23ddb79-7494-446a-8054-b9d150bf8d0a	245a9356-c816-4507-8269-0fc18dd346f9	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:59:12.002	2026-11-22 10:59:12.002	\N	\N	\N	t	\N
a4fd96c9-1891-4547-bf8a-253904e5cd55	0432331c-96e7-45cf-8354-6ab3d5101bbc	24d8704e-eebc-4c21-986b-d85a1ed5a92a	44d77d53-44ac-4dbd-b34c-964ec9926154	CANCELLED	\N	\N	Spare tire located; vehicle changed independently.	\N	2026-11-22 10:42:23.572	\N	\N	\N	2026-11-22 10:42:23.591	2026-11-22 10:42:23.556	2026-11-22 10:42:23.594	\N	\N	\N	t	\N
018aeb68-6048-4881-b4ff-738da8e668e0	030263f0-7c25-4dff-bc45-b4a438485bb9	245a9356-c816-4507-8269-0fc18dd346f9	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:59:12.041	2026-11-22 10:59:12.041	\N	\N	\N	t	\N
94b34d54-bc76-47ef-b769-efc10addeae8	71b0773e-ebf7-4244-a6a6-9dc933b7f8d8	245a9356-c816-4507-8269-0fc18dd346f9	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 10:59:12.057	2026-11-22 10:59:12.057	\N	\N	\N	t	\N
527539ea-a112-466d-8283-1bad6080f1cc	1b94f0f6-75c5-4580-bddf-c748edec2c94	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:06:32.455	2026-11-22 11:06:32.455	\N	\N	\N	t	\N
14d6c4da-5e6b-4f7d-b78f-eddcab5ff2cf	898cc3c8-4023-4798-a7b9-0d2be73fc7a7	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:06:32.493	2026-11-22 11:06:32.493	\N	\N	\N	t	\N
2a767b3b-ac94-45d9-ad73-5efb065868ed	9996c2aa-0bd0-4024-aa01-e6a55bc9d558	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:06:32.51	2026-11-22 11:06:32.51	\N	\N	\N	t	\N
1de5bce5-6431-4d04-a84f-ea33e64551cd	03ae0a20-4f05-42c1-86d2-ffd0a983be28	11947c9d-6f0f-425d-b26d-1cd07a25138a	60596275-9d97-4592-812b-ef52c5d5734a	COMPLETED	270	Replaced ignition coil pack #3, cleared DTC trouble codes, engine running smoothly at idle.	\N	\N	2026-11-22 10:59:12.276	2026-11-22 10:59:12.393	2026-11-22 10:59:12.421	2026-11-22 10:59:12.559	\N	2026-11-22 10:59:12.249	2026-11-22 10:59:12.564	65	2026-11-22 10:59:12.532	120	t	85
94d757d5-a968-4f25-b8c3-e11713ac4303	048050d1-e8b9-4e1a-8210-ba60f9268ff8	11947c9d-6f0f-425d-b26d-1cd07a25138a	60596275-9d97-4592-812b-ef52c5d5734a	CANCELLED	\N	\N	Spare tire located; vehicle changed independently.	\N	2026-11-22 10:59:12.628	\N	\N	\N	2026-11-22 10:59:12.647	2026-11-22 10:59:12.616	2026-11-22 10:59:12.651	\N	\N	\N	t	\N
c2cde923-c55c-477a-ad50-72465af001fd	6859dfb4-688b-4470-bbe7-fff1440dd235	6f0c5a39-62c6-49b0-9305-3747a819cf83	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:06:31.92	2026-11-22 11:06:31.92	\N	\N	\N	t	\N
903fc3ca-67b9-4e24-8310-97f0211dd5be	f8d491ec-cbde-4ea3-a381-a9119fac61bf	15372eae-1d2d-4d1b-af92-e71b76d3393e	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:06:32.118	2026-11-22 11:06:32.118	\N	\N	\N	t	\N
7a499a66-d3db-4180-88ff-f9ef42bd53fb	845e6757-b885-4e3a-bbed-6c57749bd625	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:06:32.319	2026-11-22 11:06:32.319	\N	\N	\N	t	\N
d7e14310-326c-48b5-b1b4-db5ea2ae2ac1	b82016f6-9dd1-4f11-a746-4550ebf6f96d	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:06:32.398	2026-11-22 11:06:32.398	\N	\N	\N	t	\N
f94c387f-0755-4eca-8ae7-1ebab0dd36e2	250c2a5b-9c33-4b33-aba6-cf5c2162e9fd	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:06:32.432	2026-11-22 11:06:32.432	\N	\N	\N	t	\N
750c2301-8f4b-4032-9c9a-9c8d1075b241	6f9a06f2-600d-4535-8cd1-9ff04860f1b1	1302fef8-4b27-4105-8596-a34489c6c8a0	772e7702-913f-44cc-8c7e-3444b6741f61	CANCELLED	\N	\N	Spare tire located; vehicle changed independently.	\N	2026-11-22 11:06:33.007	\N	\N	\N	2026-11-22 11:06:33.029	2026-11-22 11:06:32.989	2026-11-22 11:06:33.031	\N	\N	\N	t	\N
efd1162e-7195-48b0-a84c-fac36036f0c8	7738f408-4034-4b3c-a39e-4028de0e74b3	1302fef8-4b27-4105-8596-a34489c6c8a0	772e7702-913f-44cc-8c7e-3444b6741f61	COMPLETED	270	Replaced ignition coil pack #3, cleared DTC trouble codes, engine running smoothly at idle.	\N	\N	2026-11-22 11:06:32.612	2026-11-22 11:06:32.747	2026-11-22 11:06:32.777	2026-11-22 11:06:32.924	\N	2026-11-22 11:06:32.579	2026-11-22 11:06:32.927	65	2026-11-22 11:06:32.895	120	t	85
e3e4e51d-ff0b-48f0-b9c4-f015c94588d4	312b7774-bd00-4e4b-9c0c-d0642c12a432	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:07:36.258	2026-11-22 11:07:36.258	\N	\N	\N	t	\N
d5c0638a-c27c-495f-9d55-8d96217cc241	1c0a5cf0-9df0-4afb-aa9d-e4a46395adcd	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:07:43.567	2026-11-22 11:07:43.567	\N	\N	\N	t	\N
c5d5b602-7553-4159-b0e3-590cb5ce8aae	5b068a25-9e91-4e4c-95bb-b9f839bf9b5f	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:08:05.316	2026-11-22 11:08:05.316	\N	\N	\N	t	\N
6ad56e3d-d58d-4bf6-b034-c4b06c43d3e1	aecf39c9-71a8-48a8-af93-59161a7c37a1	84ecd965-cf9b-4db3-92a0-2fb64a3e965f	999b01aa-2778-4a6d-8a8d-174220f8ecb5	COMPLETED	350	\N	\N	\N	\N	\N	\N	2026-11-22 11:25:31.967	\N	2026-11-22 11:25:31.969	2026-11-22 11:25:31.969	\N	\N	\N	t	\N
9fc8566a-0976-4e4f-8426-6975285d5d70	1a1171b1-4a64-4812-b079-04eadd18361c	e22478b0-00a4-44f8-b146-3649213c7a20	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	COMPLETED	260	Service completed. Vehicle operation verified.	\N	\N	2026-11-22 11:08:19.104	2026-11-22 11:08:19.176	2026-11-22 11:08:21.715	2026-11-22 11:08:23.459	\N	2026-11-22 11:08:15.71	2026-11-22 11:08:23.462	65	2026-11-22 11:08:23.363	120	t	75
3d12e366-056e-4d9e-a27e-c1b717198d9a	1d1a241e-bf02-4a78-80f4-ae93adf87072	6a3159ce-3ec1-46ee-8854-079b5cef5d0c	75f044c3-f5b8-4bd8-acf9-e6ad9535b56c	COMPLETED	350	\N	\N	\N	\N	\N	\N	2026-11-22 11:25:10.607	\N	2026-11-22 11:25:10.61	2026-11-22 11:25:10.61	\N	\N	\N	t	\N
7af7a836-25ca-4a4f-bd06-caaac1bbeab1	607116f4-a13b-475a-bb6e-20b308f824fd	efeb8cd7-f7cc-4dfd-8689-240f124ae2a4	75f044c3-f5b8-4bd8-acf9-e6ad9535b56c	COMPLETED	120	\N	\N	\N	\N	\N	\N	2026-11-22 11:25:10.613	\N	2026-11-22 11:25:10.616	2026-11-22 11:25:10.616	\N	\N	\N	t	\N
03bcf51f-5635-4ed8-92c8-f4215a2cb872	31291c72-b865-4861-9b6b-b2c0f6def9c8	3517d75c-d341-43ab-b318-7b13f2026e31	999b01aa-2778-4a6d-8a8d-174220f8ecb5	COMPLETED	120	\N	\N	\N	\N	\N	\N	2026-11-22 11:25:31.977	\N	2026-11-22 11:25:31.979	2026-11-22 11:25:31.979	\N	\N	\N	t	\N
2d0b828b-c930-4ad4-b038-fc146e8f44d3	27d72a58-44f6-43a7-a9e4-a96b40330c20	282be406-30b3-4a61-a470-484970fa2ef9	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:25:32.507	2026-11-22 11:25:32.507	\N	\N	\N	t	\N
c40214eb-b743-42e2-9395-9b268084330c	e6923eb3-18c2-4b16-b4a0-d4a3998a666c	8ce31ba5-bfb6-4062-8788-1d55d758fd08	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:25:32.786	2026-11-22 11:25:32.786	\N	\N	\N	t	\N
8acc4416-3f99-494e-b1e0-382044a6306b	f420ce28-fa3d-4497-96fc-b0b0659da2db	2dba2391-5f04-4a66-b103-d008daa1d7cb	f7c85961-11eb-4bd0-a43c-78717392496c	COMPLETED	\N	\N	\N	\N	2026-11-22 10:00:37.116	\N	\N	2026-11-22 12:00:39.404	\N	2026-11-22 10:00:36.921	2026-11-22 12:00:39.433	\N	\N	\N	t	\N
5d45ad7a-a03f-4ef3-bae4-a49030b85635	6becf48c-b717-4a4e-a1bd-01d4de22626a	50ade227-7e8a-46fd-8685-2e2878c91b01	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:25:32.945	2026-11-22 11:25:32.945	\N	\N	\N	t	\N
d68acdcf-c276-4c9c-80b6-c386f4d15034	969cc92d-226b-4e5b-977d-7f642db8a5f5	50ade227-7e8a-46fd-8685-2e2878c91b01	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:25:33.02	2026-11-22 11:25:33.02	\N	\N	\N	t	\N
47b304ea-af1a-4207-9de3-64d37323f5d4	f23b78d1-b4a0-4ea2-b3ca-2af9d7489f1e	50ade227-7e8a-46fd-8685-2e2878c91b01	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:25:33.051	2026-11-22 11:25:33.051	\N	\N	\N	t	\N
33662181-fc79-44b8-948b-2cd902924be7	37063bc8-54b1-46dd-afca-64681a16d2aa	50ade227-7e8a-46fd-8685-2e2878c91b01	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:25:33.076	2026-11-22 11:25:33.076	\N	\N	\N	t	\N
bcc2a542-c716-41aa-8135-f5d5f1a658b1	eab83563-92d4-4bfb-89b7-cfcfe67966ce	50ade227-7e8a-46fd-8685-2e2878c91b01	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:25:33.118	2026-11-22 11:25:33.118	\N	\N	\N	t	\N
f5bbcf2b-9a4a-46c4-9140-3798fbd0d60b	8746d8c6-a64d-46f1-ba26-6dec37df5253	50ade227-7e8a-46fd-8685-2e2878c91b01	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:25:33.133	2026-11-22 11:25:33.133	\N	\N	\N	t	\N
00069d2d-4e34-4455-b9be-83395dc1600c	cdd78f8b-6821-4528-a0a0-5b29dab653ad	e22478b0-00a4-44f8-b146-3649213c7a20	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	COMPLETED	\N	\N	\N	\N	2026-11-22 10:03:56.804	\N	\N	2026-11-22 12:00:39.404	\N	2026-11-22 10:03:49.84	2026-11-22 12:00:39.433	\N	\N	\N	t	\N
4887e56b-1b89-48f8-bf83-a4ceb5ed7a0a	a82f9c72-4778-4c3b-835c-f78992aecb3b	bbdc9439-1243-4dec-a18b-8b6512cede79	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:36:39.25	2026-11-22 11:36:39.25	\N	\N	\N	t	\N
43519d31-f802-410d-915e-38f2fab6db62	a3d91c21-bd2b-412e-8166-41a2f250c67f	cd78682e-cc1a-4cc1-b024-3222b9c5e339	9ed08001-ef90-4dec-9ec9-97fd04ba6037	COMPLETED	270	Replaced ignition coil pack #3, cleared DTC trouble codes, engine running smoothly at idle.	\N	\N	2026-11-22 11:25:33.362	2026-11-22 11:25:33.491	2026-11-22 11:25:33.518	2026-11-22 11:25:33.636	\N	2026-11-22 11:25:33.33	2026-11-22 11:25:33.638	65	2026-11-22 11:25:33.613	120	t	85
c1c415f2-33da-43d2-b4b0-187f5847ac31	33bbeee6-4536-405b-a9b2-d8aed27e4209	cd78682e-cc1a-4cc1-b024-3222b9c5e339	9ed08001-ef90-4dec-9ec9-97fd04ba6037	CANCELLED	\N	\N	Spare tire located; vehicle changed independently.	\N	2026-11-22 11:25:33.703	\N	\N	\N	2026-11-22 11:25:33.722	2026-11-22 11:25:33.687	2026-11-22 11:25:33.724	\N	\N	\N	t	\N
f051ceb5-0e36-4dcf-a0aa-c11a7a5d366e	ac94019b-d02f-4c1b-989b-749ce80ecf04	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:31:05.888	2026-11-22 11:31:05.888	\N	\N	\N	t	\N
1d2d18b3-62c9-4e6c-aa00-6c5cbdd293e4	ce937235-7304-4408-a12d-bd7e6c054024	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:32:44.377	2026-11-22 11:32:44.377	\N	\N	\N	t	\N
c76217d5-6e4d-4397-a5c9-9c35b21d1489	d872046f-47b1-4b24-b3a4-aae87870c8c6	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:33:45.351	2026-11-22 11:33:45.351	\N	\N	\N	t	\N
4fcacb83-fe1b-460a-bf1f-1a5c80cccd66	552d5408-a375-458e-a45f-be861f2b2eba	e22478b0-00a4-44f8-b146-3649213c7a20	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	COMPLETED	240	Transmission linkage secured. Fluid level topped up. Road test verified.	\N	\N	2026-11-22 11:36:09.873	2026-11-22 11:36:09.989	2026-11-22 11:36:10.089	2026-11-22 11:36:11.889	\N	2026-11-22 11:36:05.039	2026-11-22 11:36:11.894	80	2026-11-22 11:36:11.776	100	t	60
b33bf045-3d00-4e17-bd0b-65c10b5c5024	8e59617b-5a64-4ded-8303-eaed2f929ac4	487c98dd-e41e-417a-81df-6160ad2f08bd	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:36:38.698	2026-11-22 11:36:38.698	\N	\N	\N	t	\N
71a0e527-0076-48b3-b1d1-d458adef3aba	4ba3c798-67ff-4b33-b544-41fd9088a67a	6108dc7f-6c15-4ee6-8a47-92ff7487b689	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:36:38.792	2026-11-22 11:36:38.792	\N	\N	\N	t	\N
8444154d-cd02-40d3-92f1-0cbcad7d9fef	d132efdb-0d4c-4588-9a16-621c3920c2e9	03049ccb-baf0-499d-aa2d-d5dce89114ad	589cd51a-0952-445a-98ce-8b00ad9d3e44	COMPLETED	350	\N	\N	\N	\N	\N	\N	2026-11-22 11:36:38.868	\N	2026-11-22 11:36:38.87	2026-11-22 11:36:38.87	\N	\N	\N	t	\N
29942811-6dc9-482d-ac87-f157debf369e	62e18235-9d10-4a84-8e41-4a07a40444b6	4c50ae6c-ef63-4e39-a5b0-d01121d5eb64	589cd51a-0952-445a-98ce-8b00ad9d3e44	COMPLETED	120	\N	\N	\N	\N	\N	\N	2026-11-22 11:36:38.876	\N	2026-11-22 11:36:38.878	2026-11-22 11:36:38.878	\N	\N	\N	t	\N
662e5f7a-ff0a-485d-b7a6-ac43cd7b7384	7aacdfa6-e34b-4805-9d3e-c62e0d71be25	bbdc9439-1243-4dec-a18b-8b6512cede79	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:36:39.053	2026-11-22 11:36:39.053	\N	\N	\N	t	\N
aad8cea4-d171-4fee-b8f1-196ab8854575	08758044-73c1-468f-b742-bce92751dbd7	bbdc9439-1243-4dec-a18b-8b6512cede79	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:36:39.141	2026-11-22 11:36:39.141	\N	\N	\N	t	\N
2ae934e4-3acf-4a60-a335-960fb1fbc4d2	fb7b8b5b-800f-42d6-887e-fdcbeee3bbfc	bbdc9439-1243-4dec-a18b-8b6512cede79	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:36:39.171	2026-11-22 11:36:39.171	\N	\N	\N	t	\N
3ee29b71-f19b-4572-ab59-58ae86c2838c	ebdcc180-2ba4-45d8-9ab1-cbe009e4eaea	bbdc9439-1243-4dec-a18b-8b6512cede79	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:36:39.193	2026-11-22 11:36:39.193	\N	\N	\N	t	\N
86114bbb-7c1a-410d-a3b1-ca45557e6040	65a2e74c-6677-468c-8339-8db363fe524d	bbdc9439-1243-4dec-a18b-8b6512cede79	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:36:39.233	2026-11-22 11:36:39.233	\N	\N	\N	t	\N
dd612d8a-26a8-4a09-a02b-eca0f2864e8f	2d100af3-8bd2-4963-8b0d-22ff3a5ade37	4a059e43-c586-45be-b371-252f448bbdd8	2c562b7b-1e07-4e32-a8ef-12d935fe25e4	CANCELLED	\N	\N	Spare tire located; vehicle changed independently.	\N	2026-11-22 11:36:39.757	\N	\N	\N	2026-11-22 11:36:39.78	2026-11-22 11:36:39.74	2026-11-22 11:36:39.782	\N	\N	\N	t	\N
434a11c9-298a-432a-9454-30ba7fee3ca0	c74273d7-4f72-4d58-9ed4-29cc12d0e18c	4a059e43-c586-45be-b371-252f448bbdd8	2c562b7b-1e07-4e32-a8ef-12d935fe25e4	COMPLETED	270	Replaced ignition coil pack #3, cleared DTC trouble codes, engine running smoothly at idle.	\N	\N	2026-11-22 11:36:39.411	2026-11-22 11:36:39.525	2026-11-22 11:36:39.55	2026-11-22 11:36:39.683	\N	2026-11-22 11:36:39.381	2026-11-22 11:36:39.686	65	2026-11-22 11:36:39.658	120	t	85
9553175c-91fb-4c65-9a98-4d69aa929cd8	5012bca7-4cb4-4e82-8916-4f1bdad195b3	e22478b0-00a4-44f8-b146-3649213c7a20	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	COMPLETED	\N	Service completed. Vehicle operation verified.	\N	\N	2026-11-22 11:35:11.421	2026-11-22 11:35:11.494	2026-11-22 11:35:11.603	2026-11-22 11:38:44.928	\N	2026-11-22 11:35:06.588	2026-11-22 11:38:44.932	\N	2026-11-22 11:38:40.817	\N	t	\N
ed02d6e6-6d00-4e09-a9b5-60af2a5f76db	df37a324-4d01-4d94-a376-1d2a6d82fcc7	a1479806-db8e-432b-a61a-04b1494faf85	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	COMPLETED	\N	Service completed. Vehicle operation verified.	\N	\N	2026-11-22 11:39:05.449	2026-11-22 11:39:08.572	2026-11-22 11:39:48.455	2026-11-22 11:40:29.453	\N	2026-11-22 10:11:20.736	2026-11-22 11:40:29.457	\N	2026-11-22 11:39:52.863	\N	t	\N
676d0e70-58d8-4342-80bd-69e5410d04d2	fdcf9966-eba5-43a9-b670-91bb394d61e6	a1479806-db8e-432b-a61a-04b1494faf85	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	COMPLETED	\N	Service completed. Vehicle operation verified.	\N	\N	2026-11-22 11:40:37.035	2026-11-22 11:40:39.954	2026-11-22 11:40:40.647	2026-11-22 11:40:42.355	\N	2026-11-22 10:05:52.271	2026-11-22 11:40:42.358	\N	2026-11-22 11:40:41.254	\N	t	\N
fda2ccbc-d095-4eda-8b7b-1a80c0424b2d	1a3bbc18-ad93-4373-bb4b-85764d9fdf5f	a1479806-db8e-432b-a61a-04b1494faf85	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	COMPLETED	\N	Service completed. Vehicle operation verified.	\N	\N	2026-11-22 11:40:33.106	2026-11-22 11:41:10.295	2026-11-22 11:41:11.293	2026-11-22 11:41:13.391	\N	2026-11-22 09:34:49.174	2026-11-22 11:41:13.394	\N	2026-11-22 11:41:12.315	\N	t	\N
3ec2a6c1-9aba-4659-921a-7a24abe3118c	9b64d833-e393-469b-bab9-6f3561589965	a1479806-db8e-432b-a61a-04b1494faf85	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	COMPLETED	\N	Service completed. Vehicle operation verified.	\N	\N	2026-11-22 11:43:23.267	2026-11-22 11:43:53.928	2026-11-22 11:43:58.595	2026-11-22 11:44:18.559	\N	2026-11-22 11:42:14.494	2026-11-22 11:45:46.469	\N	2026-11-22 11:44:05.561	\N	t	\N
b962e9f6-289f-440d-8c96-93e7ad51ffec	7b3bf718-ece7-4e61-af69-7314be4d52d9	a89d8a1e-ad80-4555-a258-0392941f695b	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:52:12.104	2026-11-22 11:52:12.104	\N	\N	\N	t	\N
a3ec0669-05a1-4c5f-9ba1-58dd97b306a4	494eb78b-51b0-42e6-b1a5-d890f3a4b279	766576f6-0959-4864-8a7e-649df595336b	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:52:52.096	2026-11-22 11:52:52.096	\N	\N	\N	t	\N
bf2db744-237c-4241-ad11-3ab3edd93f13	1f870c2e-ede8-4cd6-9f92-c796f2910793	65531d90-d509-44d8-8c50-189197b32adf	e480aef5-fc43-4db6-bc14-a589c85cc159	COMPLETED	\N	\N	\N	\N	2026-11-22 10:04:23.414	\N	\N	2026-11-22 12:00:39.404	\N	2026-11-22 10:04:23.11	2026-11-22 12:00:39.433	\N	\N	\N	t	\N
5838ad9f-ab56-4f8f-a973-86f9fd586696	9d3051c0-8388-42a6-9915-01e654a8f25e	935f0c45-76f4-4be0-8fb0-95fb6009b2dd	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:55:24.506	2026-11-22 11:55:24.506	\N	\N	\N	t	\N
6e01dd2d-cb2a-4da0-bcfa-b132dac75733	f50dc5a4-d7b1-46eb-8cdd-51a606ded16b	e22478b0-00a4-44f8-b146-3649213c7a20	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	COMPLETED	\N	\N	\N	\N	2026-11-22 10:06:34.271	\N	\N	2026-11-22 12:00:39.404	\N	2026-11-22 10:06:25.555	2026-11-22 12:00:39.433	\N	\N	\N	t	\N
ed670800-8de3-451e-9d9d-1140d81e0f62	c3203b0c-f0c1-45a5-b45f-7476117d5877	c5be2c05-7982-46af-9db0-2f3f296f630b	243c49ee-6224-4c57-95ee-8b9a7367ed63	COMPLETED	350	\N	\N	\N	\N	\N	\N	2026-11-22 11:55:24.709	\N	2026-11-22 11:55:24.71	2026-11-22 11:55:24.71	\N	\N	\N	t	\N
d73e5417-717c-4745-9e50-e1b68a2d557b	aa3a0cc7-2095-48db-9385-5fa8b374b272	863029a2-5a25-4be2-be07-0680e859f3f2	243c49ee-6224-4c57-95ee-8b9a7367ed63	COMPLETED	120	\N	\N	\N	\N	\N	\N	2026-11-22 11:55:24.717	\N	2026-11-22 11:55:24.719	2026-11-22 11:55:24.719	\N	\N	\N	t	\N
0d5a0499-55d9-4794-bd0c-0b8547a88bb5	28561722-6044-40b7-8585-fa98bc261428	413f9c28-135a-41dc-9ae3-29f264612e2c	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:55:24.759	2026-11-22 11:55:24.759	\N	\N	\N	t	\N
c2ec6908-1615-441f-a5eb-966c18e8205d	4293a444-f8c9-4993-8c12-683415bf4f95	eeec89bd-77f1-4b87-b039-63f9778b4621	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:55:24.768	2026-11-22 11:55:24.768	\N	\N	\N	t	\N
ea667a0b-0cd9-44bb-962c-19ed97d32805	c47a7165-a241-47b3-9e5c-e74bcadc472f	eeec89bd-77f1-4b87-b039-63f9778b4621	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:55:24.861	2026-11-22 11:55:24.861	\N	\N	\N	t	\N
e8aab1bb-ad9b-4bdd-9b1a-c42e72146f7c	3ad6e8f9-bb57-4011-8b0c-c6e394cefbfe	eeec89bd-77f1-4b87-b039-63f9778b4621	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:55:24.899	2026-11-22 11:55:24.899	\N	\N	\N	t	\N
622b26aa-19b2-47d0-814e-306413ef57ea	c48d0928-218b-4b6f-a048-727e8b5aa30d	e43779a3-03a2-4ed0-a27b-1c66d4ab40bf	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:55:24.919	2026-11-22 11:55:24.919	\N	\N	\N	t	\N
ea47faad-e7e7-4914-90ed-34222037345d	3944cf87-4b61-42bd-8823-ab0a9d694c59	eeec89bd-77f1-4b87-b039-63f9778b4621	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:55:24.929	2026-11-22 11:55:24.929	\N	\N	\N	t	\N
33899de2-c76e-4b45-85bc-e89c257afd89	e0440403-d555-44d7-a484-7bd3ab1fa1d7	eeec89bd-77f1-4b87-b039-63f9778b4621	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:55:24.974	2026-11-22 11:55:24.974	\N	\N	\N	t	\N
ccddb1dc-aa53-47b2-8795-38d73c11d049	52954004-6d7c-4584-90cc-7085607573fe	eeec89bd-77f1-4b87-b039-63f9778b4621	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 11:55:24.998	2026-11-22 11:55:24.998	\N	\N	\N	t	\N
bb2ecca6-c686-44d1-8717-e22d5c7ac0eb	128efdcf-99ee-4e29-abb9-d7a0ac285072	e22478b0-00a4-44f8-b146-3649213c7a20	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	COMPLETED	\N	\N	\N	\N	2026-11-22 10:07:30.358	\N	\N	2026-11-22 12:00:39.404	\N	2026-11-22 10:07:22.441	2026-11-22 12:00:39.433	\N	\N	\N	t	\N
984347f6-637a-4011-98b2-17e322bf14ec	d2f9d6a5-3800-423d-b90e-84b8d1349581	020de9be-8c9a-4232-a522-39dfbf87cf9c	695d4e72-2e32-45ab-8730-762885e4b76b	COMPLETED	\N	\N	\N	\N	2026-11-22 10:27:51.385	\N	\N	2026-11-22 12:00:39.404	\N	2026-11-22 10:27:51.153	2026-11-22 12:00:39.433	\N	\N	\N	t	\N
5fc2a975-92bf-4ae6-bea8-2b08fe76c1f5	6834daf4-6750-4e88-8fa5-4eefbd06435e	e22478b0-00a4-44f8-b146-3649213c7a20	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	COMPLETED	\N	\N	\N	\N	2026-11-22 10:41:22.623	\N	\N	2026-11-22 12:00:39.404	\N	2026-11-22 10:41:19.063	2026-11-22 12:00:39.433	\N	\N	\N	t	\N
a16cb0b7-dff9-4c7c-9af0-b66ad02b20d3	01a454d5-60c7-4f76-952a-c8ceae5c11a5	e22478b0-00a4-44f8-b146-3649213c7a20	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	COMPLETED	\N	\N	\N	\N	2026-11-22 10:39:42.218	\N	\N	2026-11-22 12:00:39.404	\N	2026-11-22 10:39:34.263	2026-11-22 12:00:39.433	\N	\N	\N	t	\N
1dd07957-0c54-452c-b8aa-9d314d95eb48	19fc7b7d-4ead-4e91-90f1-4011beba0cfe	e22478b0-00a4-44f8-b146-3649213c7a20	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	COMPLETED	\N	\N	\N	\N	2026-11-22 10:41:14.852	\N	\N	2026-11-22 12:00:39.404	\N	2026-11-22 10:41:06.865	2026-11-22 12:00:39.433	\N	\N	\N	t	\N
dff4bfd6-f7b6-4c8a-b8a7-eda1c0f3fed6	4b11b62a-d28e-4a29-8673-1d588a34c3d9	a17cea7b-22a1-44e0-a813-5f16ce79bc69	f95c00f1-a886-4c05-9222-f50e52a5bff5	COMPLETED	\N	\N	\N	\N	2026-11-22 10:42:22.889	\N	\N	2026-11-22 12:00:39.404	\N	2026-11-22 10:42:22.648	2026-11-22 12:00:39.433	\N	\N	\N	t	\N
283252d6-d0b6-4be3-89db-41879add66e3	4041c645-eab7-49c3-9d38-1c9fafb5dde0	49c5925b-fda2-4bcc-b6b0-87b387231f58	a75ec860-72f8-4ab3-84f5-503a8ae57676	COMPLETED	\N	\N	\N	\N	2026-11-22 10:59:11.947	\N	\N	2026-11-22 12:00:39.404	\N	2026-11-22 10:59:11.713	2026-11-22 12:00:39.433	\N	\N	\N	t	\N
1dad5bfe-ba6c-40b8-8db5-93a2bcb4b6da	3d2d1e51-9774-4695-a9b9-fa0b3220a39a	4bc6bd4b-da8e-4372-8bac-0333b1e85ab1	fd3e3a5e-79bc-4b18-9e45-c7dde1a28efe	COMPLETED	\N	\N	\N	\N	2026-11-22 11:06:32.362	\N	\N	2026-11-22 12:00:39.404	\N	2026-11-22 11:06:32.067	2026-11-22 12:00:39.433	\N	\N	\N	t	\N
f1a85ac0-fa6c-4acf-b8f6-f4f0c3de8407	36a184dc-b9a3-47f3-86a2-2efc97e7ede8	e22478b0-00a4-44f8-b146-3649213c7a20	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	COMPLETED	\N	\N	\N	\N	2026-11-22 11:07:56.075	\N	\N	2026-11-22 12:00:39.404	\N	2026-11-22 11:07:48.163	2026-11-22 12:00:39.433	\N	\N	\N	t	\N
5021bb4b-6cac-4433-99b7-ba950e814865	2cf2f727-6312-48cd-bd20-16380a1cbb20	ff166c12-fa96-4a4d-8523-7e1801d01b3f	26a6a314-dba2-4b11-b975-81ddcf76ef3a	COMPLETED	270	Replaced ignition coil pack #3, cleared DTC trouble codes, engine running smoothly at idle.	\N	\N	2026-11-22 11:55:25.158	2026-11-22 11:55:25.3	2026-11-22 11:55:25.327	2026-11-22 11:55:25.465	\N	2026-11-22 11:55:25.126	2026-11-22 11:55:25.468	65	2026-11-22 11:55:25.439	120	t	85
ff5bba96-ed13-42c6-8fbe-65655435221c	cd3571e7-de39-4457-b3d5-fdc410810e1d	6a3159ce-3ec1-46ee-8854-079b5cef5d0c	75f044c3-f5b8-4bd8-acf9-e6ad9535b56c	COMPLETED	\N	\N	\N	\N	\N	\N	\N	2026-11-22 12:00:39.404	\N	2026-11-22 11:25:10.62	2026-11-22 12:00:39.433	\N	\N	\N	t	\N
020ca93b-b345-49ec-8f76-c1140591a3f2	a4381bf2-ed14-4497-bf2d-c3bf18dc0f35	84ecd965-cf9b-4db3-92a0-2fb64a3e965f	999b01aa-2778-4a6d-8a8d-174220f8ecb5	COMPLETED	\N	\N	\N	\N	\N	\N	\N	2026-11-22 12:00:39.404	\N	2026-11-22 11:25:31.987	2026-11-22 12:00:39.433	\N	\N	\N	t	\N
aa3b0763-ff80-411c-ad22-c35fd8344202	29ef0dd0-0c14-4218-9e47-f83a126bf3ee	ff166c12-fa96-4a4d-8523-7e1801d01b3f	26a6a314-dba2-4b11-b975-81ddcf76ef3a	CANCELLED	\N	\N	Spare tire located; vehicle changed independently.	\N	2026-11-22 11:55:25.538	\N	\N	\N	2026-11-22 11:55:25.559	2026-11-22 11:55:25.522	2026-11-22 11:55:25.562	\N	\N	\N	t	\N
e7003bae-6761-4520-b750-9b0c2d548428	0d30da36-9f22-4786-9125-0e3145158573	7a09bda9-bcb7-47db-9d6f-9cde4f8fe7cd	aa7c06fb-61a0-4c00-a555-0042c6af990b	COMPLETED	\N	\N	\N	\N	2026-11-22 11:25:33.108	\N	\N	2026-11-22 12:00:39.404	\N	2026-11-22 11:25:32.867	2026-11-22 12:00:39.433	\N	\N	\N	t	\N
02b6e9a2-434b-41d8-8351-09bd4346bbe8	ee92f51f-1dba-4d3d-883e-2da4a41c4381	03049ccb-baf0-499d-aa2d-d5dce89114ad	589cd51a-0952-445a-98ce-8b00ad9d3e44	COMPLETED	\N	\N	\N	\N	\N	\N	\N	2026-11-22 12:00:39.404	\N	2026-11-22 11:36:38.885	2026-11-22 12:00:39.433	\N	\N	\N	t	\N
6488e5ba-3fc9-4aa1-9e17-59777828f470	2524c83a-698d-4dcf-b25d-098dce069ec0	12a59ca0-ebce-49aa-b8c8-2d6021a4d980	7ceb1f55-7d15-42cc-b366-610d301d023d	COMPLETED	\N	\N	\N	\N	2026-11-22 11:36:39.225	\N	\N	2026-11-22 12:00:39.404	\N	2026-11-22 11:36:38.961	2026-11-22 12:00:39.433	\N	\N	\N	t	\N
52215dc2-cca9-4ae0-896d-f61dbe2ee148	e09942b9-cbe9-48d2-8dce-62626bf85792	c5be2c05-7982-46af-9db0-2f3f296f630b	243c49ee-6224-4c57-95ee-8b9a7367ed63	COMPLETED	\N	\N	\N	\N	\N	\N	\N	2026-11-22 12:00:39.404	\N	2026-11-22 11:55:24.726	2026-11-22 12:00:39.433	\N	\N	\N	t	\N
3eebafd4-0699-42ae-b201-6b0d739f9f1f	99e0bd8d-3fec-4c08-ae5c-ed0fc3bc32a7	fe4fed22-b93a-4dfe-b237-66a079f96a50	56596f10-d230-44c3-b5b0-a52fcc7a0302	COMPLETED	\N	\N	\N	\N	2026-11-22 11:55:25.017	\N	\N	2026-11-22 12:00:39.404	\N	2026-11-22 11:55:24.709	2026-11-22 12:00:39.433	\N	\N	\N	t	\N
61e5fa10-26e1-4a02-9459-5db3e9d74644	e54e3755-f888-459b-9047-60691b32802d	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 12:00:47.667	2026-11-22 12:00:47.667	\N	\N	\N	t	\N
c727ae75-5149-4eda-b137-3805e0538533	6dc19581-1f1f-4a36-a677-4a50b150fce5	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 12:03:42.569	2026-11-22 12:03:42.569	\N	\N	\N	t	\N
d7586aa9-cd20-426c-8f45-a5ddfe6ba980	69551a64-33a8-4e75-8baf-2b9e850826fe	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 12:03:49.437	2026-11-22 12:03:49.437	\N	\N	\N	t	\N
d1502ca8-5941-4be1-923e-7050647288bf	825701fc-b817-4525-83ad-1d4baa29a894	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 12:04:05.564	2026-11-22 12:04:05.564	\N	\N	\N	t	\N
8803967b-4005-4993-965c-e4c5354f7349	d3a66f3c-c30d-48f1-b4d1-c872902b948d	e22478b0-00a4-44f8-b146-3649213c7a20	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	COMPLETED	260	Service completed. Vehicle operation verified.	\N	\N	2026-11-22 12:04:19.117	2026-11-22 12:04:19.209	2026-11-22 12:04:21.761	2026-11-22 12:04:23.526	\N	2026-11-22 12:04:15.808	2026-11-22 12:04:23.529	65	2026-11-22 12:04:23.422	120	t	75
509d0dc3-a2fa-46ad-b58c-2af009fdab06	9cd03908-707c-4205-94b7-73f44fa0c574	e22478b0-00a4-44f8-b146-3649213c7a20	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	COMPLETED	240	Transmission linkage secured. Fluid level topped up. Road test verified.	\N	\N	2026-11-22 12:04:43.465	2026-11-22 12:04:43.557	2026-11-22 12:04:43.674	2026-11-22 12:04:45.479	\N	2026-11-22 12:04:38.693	2026-11-22 12:04:45.483	80	2026-11-22 12:04:45.367	100	t	60
e10cd90e-038b-4282-a97a-20bd7447dec4	8e424443-420f-42b5-9879-0e150a72f664	e22478b0-00a4-44f8-b146-3649213c7a20	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	CANCELLED	\N	\N	far	\N	2026-11-22 12:04:01.463	\N	\N	\N	2026-11-22 12:12:16.557	2026-11-22 12:03:53.529	2026-11-22 12:12:16.56	\N	\N	\N	t	\N
6c736916-d02f-4279-8270-49f6f054f32f	3a38191a-aba1-4735-9a13-ed6afac739cb	a1479806-db8e-432b-a61a-04b1494faf85	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	COMPLETED	\N	Service completed. Vehicle operation verified.	\N	\N	2026-11-22 12:13:42.663	2026-11-22 12:14:07.166	2026-11-22 12:14:21.345	2026-11-22 12:14:31.475	\N	2026-11-22 12:13:07.302	2026-11-22 12:15:12.209	\N	2026-11-22 12:14:22.924	\N	f	\N
c558ad89-ed30-48c7-bae9-45578a8f3638	1e25ba21-ffad-4310-aeae-5963f9323c16	a1479806-db8e-432b-a61a-04b1494faf85	\N	CANCELLED	\N	\N	it solved	\N	\N	\N	\N	\N	2026-11-22 12:16:22.326	2026-11-22 12:15:59.999	2026-11-22 12:16:22.327	\N	\N	\N	t	\N
84f3f21a-d1eb-49dc-99b0-98e662f808b0	e33d20bb-2436-466d-b117-61201f06b5dc	e22478b0-00a4-44f8-b146-3649213c7a20	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	CANCELLED	\N	\N	dafasf	\N	2026-11-22 12:03:02.149	\N	\N	\N	2026-11-22 12:16:48.848	2026-11-22 12:02:55.216	2026-11-22 12:16:48.851	\N	\N	\N	t	\N
40f85150-f5c1-4abf-97ad-9dc2b347074a	f05ff4a3-34c7-45dc-8533-9bc02a7e1195	a1479806-db8e-432b-a61a-04b1494faf85	6a01cdea-a7ee-43e1-8a1f-77ecba9b0890	CANCELLED	\N	\N	mabchjkakujgfa	\N	2026-11-22 12:17:26.214	\N	\N	\N	2026-11-22 12:17:32.237	2026-11-22 12:17:08.906	2026-11-22 12:17:32.24	\N	\N	\N	t	\N
53a38438-b162-488a-8f21-ed21401c44f5	fd037608-4158-4dd2-81b1-0fc7cb9e1b0b	7728fd21-9b94-481c-b739-87c80836528a	1289d317-4894-4f30-b510-b726e68fd866	ACCEPTED	\N	\N	\N	\N	2026-11-22 13:04:37.294	\N	\N	\N	\N	2026-11-22 13:04:37.069	2026-11-22 13:04:37.296	\N	\N	\N	t	\N
eba2b49f-8548-4d4a-b849-0157c18a0700	b8024a20-a82d-4a25-958f-db501f08dd0d	f34fa6c9-f73a-42c4-9160-85d695a71a2b	25b004b4-75c9-445e-b00e-381f6924e7fc	COMPLETED	270	Replaced ignition coil pack #3, cleared DTC trouble codes, engine running smoothly at idle.	\N	\N	2026-11-22 13:04:37.526	2026-11-22 13:04:37.643	2026-11-22 13:04:37.668	2026-11-22 13:04:37.792	\N	2026-11-22 13:04:37.497	2026-11-22 13:04:37.795	65	2026-11-22 13:04:37.768	120	t	85
344a61f0-a1c8-4e1c-ad05-ea8a7b093321	39cc810c-2b79-4754-81a5-33245e48a631	f34fa6c9-f73a-42c4-9160-85d695a71a2b	25b004b4-75c9-445e-b00e-381f6924e7fc	CANCELLED	\N	\N	Spare tire located; vehicle changed independently.	\N	2026-11-22 13:04:37.862	\N	\N	\N	2026-11-22 13:04:37.881	2026-11-22 13:04:37.847	2026-11-22 13:04:37.883	\N	\N	\N	t	\N
1dc09508-5a99-4bd9-9954-16155fc4c0cc	46a295dd-9804-4bb2-89df-48c6eb40c4c8	e22478b0-00a4-44f8-b146-3649213c7a20	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 13:19:19.426	2026-11-22 13:19:19.426	\N	\N	\N	t	\N
2b2b7dc7-cbae-42f9-bc5e-1b5929640f4c	04a25238-d813-492c-8e98-59baff62cdba	a1479806-db8e-432b-a61a-04b1494faf85	\N	SUBMITTED	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-11-22 15:46:06.601	2026-11-22 15:46:06.601	\N	\N	\N	t	\N
\.


--
-- Data for Name: ServiceStatusHistory; Type: TABLE DATA; Schema: public; Owner: vbrs_admin
--

COPY public."ServiceStatusHistory" (id, "serviceRequestId", "fromStatus", "toStatus", "changedById", notes, "timestamp") FROM stdin;
ec394299-20ca-44ef-8a0e-5fac6d8b3f39	3d764039-fbc9-421e-a813-fb285f17d02a	\N	SUBMITTED	50d7979c-85db-4cec-8bb2-83ba29ebae7d	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 09:21:13.148
f753af57-662f-4e6e-98c8-2b2ec7f879db	3886aef0-6b77-458e-9566-5b629a76125b	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: TRANSMISSION_ISSUE. Towing required: true.	2026-11-22 09:26:53.359
c78ee03b-7e9d-4a23-a107-1c769bac6021	eb433a1d-810f-4de2-ad63-76cdfd5002be	\N	SUBMITTED	15a87756-ecb4-4394-8fb7-5555263f9a09	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 09:27:11.287
9e58a12b-6486-4240-a648-e91c82d457af	b4e332ba-a573-4996-bb86-4d2426139026	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: TRANSMISSION_ISSUE. Towing required: true.	2026-11-22 09:27:47.825
27a0dd7e-9128-431c-adce-1478c222c0c5	fda2ccbc-d095-4eda-8b7b-1a80c0424b2d	\N	SUBMITTED	a1479806-db8e-432b-a61a-04b1494faf85	Breakdown reported: ENGINE_FAILURE. Towing required: true.	2026-11-22 09:34:49.178
9eaf3801-1f16-4add-896f-a3edbc28e7e2	74b49a22-ee5d-4f5a-9ffd-3cd85e467198	\N	SUBMITTED	baf36b48-83b6-4d2a-acaf-1145a539c456	Breakdown reported: COLLISION_ACCIDENT. Towing required: true.	2026-11-22 09:44:12.103
c1297b41-5181-4f30-ac19-db3bc6cc542d	f12da20a-ec70-4b56-98bf-9dc70a31fbb8	\N	SUBMITTED	baf36b48-83b6-4d2a-acaf-1145a539c456	Breakdown reported: BRAKE_SYSTEM_FAILURE. Towing required: true.	2026-11-22 09:44:12.18
12779811-d76d-402a-bf77-7599facfceaf	6e72a3b4-3fd5-4c32-9d7b-52f1f9da742f	\N	SUBMITTED	baf36b48-83b6-4d2a-acaf-1145a539c456	Breakdown reported: BATTERY_DEAD_ELECTRICAL. Towing required: false.	2026-11-22 09:44:12.212
3facddb6-118b-41bc-8644-df827e9d28be	d4dd281f-5688-4008-b655-ebb668de760a	\N	SUBMITTED	baf36b48-83b6-4d2a-acaf-1145a539c456	Breakdown reported: TRANSMISSION_ISSUE. Towing required: true.	2026-11-22 09:44:12.238
f239e7dc-3544-486a-ab04-6526fb2e4989	a5b34810-0c7f-431a-ad01-20a9249ab707	\N	SUBMITTED	baf36b48-83b6-4d2a-acaf-1145a539c456	Breakdown reported: FUEL_EMPTY_OR_CONTAMINATED. Towing required: false.	2026-11-22 09:44:12.282
5df76ffb-1b38-419e-9543-5add87d456ed	98bd288a-b73d-45aa-993b-a42c7e5e3a81	\N	SUBMITTED	baf36b48-83b6-4d2a-acaf-1145a539c456	Breakdown reported: OVERHEATING_COOLANT. Towing required: false.	2026-11-22 09:44:12.3
b6b255d4-88c6-4f7c-b66e-8d24add86fa3	39498ce0-ad28-487e-a944-cc96dcab3139	\N	SUBMITTED	19b6e30e-7ab8-4db5-87e5-443815e3d455	Breakdown reported: COLLISION_ACCIDENT. Towing required: true.	2026-11-22 09:45:06.023
09c6b187-1c1a-4cc6-97f1-db188f6f9304	f96a076f-2d6a-4fe9-9cc3-f5100920d335	\N	SUBMITTED	19b6e30e-7ab8-4db5-87e5-443815e3d455	Breakdown reported: BRAKE_SYSTEM_FAILURE. Towing required: true.	2026-11-22 09:45:06.104
404672d7-e4d4-49a2-8680-9df254cf5eb3	55ebdc47-4378-49c3-9dfd-0975112104ae	\N	SUBMITTED	19b6e30e-7ab8-4db5-87e5-443815e3d455	Breakdown reported: BATTERY_DEAD_ELECTRICAL. Towing required: false.	2026-11-22 09:45:06.139
3d8dd968-2f49-41de-899b-5febb97428ea	dbacc02a-d49f-4754-bc77-ec30a4aed4ca	\N	SUBMITTED	19b6e30e-7ab8-4db5-87e5-443815e3d455	Breakdown reported: TRANSMISSION_ISSUE. Towing required: true.	2026-11-22 09:45:06.169
217d37bc-eba2-480a-a61a-13c1ca17c6fe	78d11ea4-e697-419d-b356-f53b650e7e58	\N	SUBMITTED	19b6e30e-7ab8-4db5-87e5-443815e3d455	Breakdown reported: FUEL_EMPTY_OR_CONTAMINATED. Towing required: false.	2026-11-22 09:45:06.209
15ad4cc0-216c-418d-9a3d-01e241229758	5cc2464e-95e7-4b5d-9e06-755bf56a8a5a	\N	SUBMITTED	19b6e30e-7ab8-4db5-87e5-443815e3d455	Breakdown reported: OVERHEATING_COOLANT. Towing required: false.	2026-11-22 09:45:06.228
d42dac5c-bf13-49f2-87ff-15b8ba5c56dc	973c540e-4f58-4333-a50c-6365fe81abd5	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 09:45:23.476
54a596bd-ccf5-420f-874c-ebbe4d75f9c9	57485083-3928-4650-9799-f7c920e0c346	\N	SUBMITTED	436d667c-cc9f-4294-b2c9-cc95e0cb3d7e	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 09:45:40.803
8b19302a-63da-46e8-92ce-f896c0bd94a1	9e9dd155-7f6d-4d89-a6cb-2e26a1b62a58	\N	SUBMITTED	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	Breakdown reported: COLLISION_ACCIDENT. Towing required: true.	2026-11-22 09:45:41.311
404a6719-2c37-45b3-8484-02137f3f2cff	750ea674-acc2-4bad-926f-8de19f88228b	\N	SUBMITTED	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	Breakdown reported: BRAKE_SYSTEM_FAILURE. Towing required: true.	2026-11-22 09:45:41.386
765aacb9-e221-456c-8482-7fb354f50cd1	ead81a34-0bc4-437c-9103-d51418ee6d15	\N	SUBMITTED	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	Breakdown reported: BATTERY_DEAD_ELECTRICAL. Towing required: false.	2026-11-22 09:45:41.422
680bb457-45c5-4a53-ab48-c5d94d18356e	f18463f0-068a-44f3-a5a1-ab4a682e8f00	\N	SUBMITTED	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	Breakdown reported: TRANSMISSION_ISSUE. Towing required: true.	2026-11-22 09:45:41.449
b5edeee1-b89a-44b4-9f20-06012751cfec	cf25bc49-02f4-41ba-93b8-58664fe797ed	\N	SUBMITTED	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	Breakdown reported: FUEL_EMPTY_OR_CONTAMINATED. Towing required: false.	2026-11-22 09:45:41.502
27e68dd2-e0da-48eb-a5a7-ddb5d485f597	66427ff8-abc6-4aae-9538-ec04fabfe06d	\N	SUBMITTED	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	Breakdown reported: OVERHEATING_COOLANT. Towing required: false.	2026-11-22 09:45:41.521
7632271f-0ce9-4dd0-8071-192646e19a9c	31fa8134-34e3-4836-859c-fe385f1765cd	\N	SUBMITTED	babb78bc-8995-47e3-873b-d77a0c81a425	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 09:59:33.369
cdc34793-355a-4038-b0c9-0125ac4f1eba	31fa8134-34e3-4836-859c-fe385f1765cd	SUBMITTED	ACCEPTED	838cdf88-b812-44c0-a890-3e53d54aafe1	Dispatch claimed by Downtown Elite Precision	2026-11-22 09:59:33.641
9e4d67da-47e1-4cdf-83f1-665922a46b73	8acc4416-3f99-494e-b1e0-382044a6306b	\N	SUBMITTED	2dba2391-5f04-4a66-b103-d008daa1d7cb	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 10:00:36.923
ff75a229-44c1-4e65-9004-6ab43c4f1547	8acc4416-3f99-494e-b1e0-382044a6306b	SUBMITTED	ACCEPTED	8aeefd6a-535e-4b26-9fb5-74c9ac6e26c3	Dispatch claimed by Downtown Elite Precision	2026-11-22 10:00:37.125
ad917bc6-8bbb-4cd0-95fd-e6ae37382454	00069d2d-4e34-4455-b9be-83395dc1600c	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 10:03:49.844
444f75e6-295a-4bfe-b0e6-9f821f3f3264	00069d2d-4e34-4455-b9be-83395dc1600c	SUBMITTED	ACCEPTED	473401ce-0803-422f-8baa-a47de557f84e	Dispatch claimed by Apex Mobile Roadside Services	2026-11-22 10:03:56.815
28ab40f9-f473-4379-81e3-66449d350a3c	bf2db744-237c-4241-ad11-3ab3edd93f13	\N	SUBMITTED	65531d90-d509-44d8-8c50-189197b32adf	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 10:04:23.114
246c67b4-b71a-4fde-83f3-0c0a28dc66d8	bf2db744-237c-4241-ad11-3ab3edd93f13	SUBMITTED	ACCEPTED	3508ead1-81a7-4452-a2f1-fd5599a1f576	Dispatch claimed by Downtown Elite Precision	2026-11-22 10:04:23.424
f3adc524-960e-4531-8610-7b3d8c8b3753	ded6c69a-a1a8-4a2e-9f39-07bec4eb671d	\N	SUBMITTED	a9541389-845a-425d-9b38-1de039a56cdc	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 10:04:24.444
07264296-3b13-4d9c-a973-ebaa2dcf0495	af28145c-8626-49ce-9951-b35e22a477fc	\N	SUBMITTED	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	Breakdown reported: COLLISION_ACCIDENT. Towing required: true.	2026-11-22 10:04:24.961
90de7064-da86-4485-923c-d73ca238eff5	043fa575-732d-4bb3-8633-3aa428b6ab3e	\N	SUBMITTED	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	Breakdown reported: BRAKE_SYSTEM_FAILURE. Towing required: true.	2026-11-22 10:04:25.049
213b7f6b-ccb8-48af-937a-8e119f8cf0f4	97d35a87-f586-4ced-b07b-1ad365b5ed3a	\N	SUBMITTED	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	Breakdown reported: BATTERY_DEAD_ELECTRICAL. Towing required: false.	2026-11-22 10:04:25.085
8f2eacb4-8a80-4b13-8dbb-d57e36b8e1f7	c2e4fc73-b24c-49f1-a2ed-45821cebf266	\N	SUBMITTED	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	Breakdown reported: TRANSMISSION_ISSUE. Towing required: true.	2026-11-22 10:04:25.12
235c8ad1-a95c-4a77-8654-f91c1d6a20c3	fa84672b-7066-49bc-9f46-ce92ef6f0908	\N	SUBMITTED	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	Breakdown reported: FUEL_EMPTY_OR_CONTAMINATED. Towing required: false.	2026-11-22 10:04:25.168
e890c00e-da45-49f5-bf90-d7a3c7359eba	4bd28846-0ecb-483e-9e8f-17c17600a14b	\N	SUBMITTED	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	Breakdown reported: OVERHEATING_COOLANT. Towing required: false.	2026-11-22 10:04:25.192
d46f19dd-0b7f-4c17-af60-981600e309ef	18c226e4-7de3-4271-a17b-f1a2d363fbc2	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: TRANSMISSION_ISSUE. Towing required: true.	2026-11-22 10:05:07.176
d246fcec-06b6-4f49-ba04-d5fb92e90229	447719be-c9f3-4c7b-9648-482c23ff5e5e	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 10:05:14.52
ddd2a969-410e-4e80-9c1e-8a21c7214f06	78739135-48ab-424b-b74e-a39a01c16ec6	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 10:05:19.369
d0f8cb64-7b11-41bb-b8a6-190d14294a52	676d0e70-58d8-4342-80bd-69e5410d04d2	\N	SUBMITTED	a1479806-db8e-432b-a61a-04b1494faf85	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 10:05:52.274
7f747046-1016-4d52-bf34-8c0f41670b7f	6e01dd2d-cb2a-4da0-bcfa-b132dac75733	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 10:06:25.559
645ea8dd-5108-46f2-82b5-27268f962495	6e01dd2d-cb2a-4da0-bcfa-b132dac75733	SUBMITTED	ACCEPTED	473401ce-0803-422f-8baa-a47de557f84e	Dispatch claimed by Apex Mobile Roadside Services	2026-11-22 10:06:34.281
a4824d44-dbe5-4984-8d9e-bfd028e476f2	72c2a772-e60c-45c2-a82c-9d4473a4b4cc	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: TRANSMISSION_ISSUE. Towing required: true.	2026-11-22 10:07:10.637
486f0ef0-08e0-44ef-8f83-a9edace12165	48056c07-2335-49dd-a645-da59864ef674	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 10:07:17.829
c11a0afe-7fef-4c6f-96aa-673ce5baf3c5	bb2ecca6-c686-44d1-8717-e22d5c7ac0eb	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 10:07:22.443
8ed560c2-1e2e-418d-93c8-3092a9d38d1f	bb2ecca6-c686-44d1-8717-e22d5c7ac0eb	SUBMITTED	ACCEPTED	473401ce-0803-422f-8baa-a47de557f84e	Dispatch claimed by Apex Mobile Roadside Services	2026-11-22 10:07:30.366
53082a45-e140-4ddc-8abb-29f7e2944a4c	ed02d6e6-6d00-4e09-a9b5-60af2a5f76db	\N	SUBMITTED	a1479806-db8e-432b-a61a-04b1494faf85	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 10:11:20.739
a6f586c7-2a33-41d3-bebe-ebb0f0d15e47	cc46598d-dcfb-4c7d-a0e0-8870a7fce0a4	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 10:14:48.547
4481a4c3-ec32-4d23-9e11-cc720b9baf5d	cc46598d-dcfb-4c7d-a0e0-8870a7fce0a4	SUBMITTED	ACCEPTED	20c92ae9-cda7-4be7-a444-d9ec67df8fbc	Dispatch claimed by Sterling Heavy Towing & Roadside	2026-11-22 10:14:54.231
04a7467f-29bf-4158-9c34-1123723d07da	a01211c3-c349-4cef-8093-5f025def504c	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 10:16:21.168
e41580e7-4fb9-4818-9458-284798198efb	16969eb4-7b76-4134-b1fc-c50859b2b7a2	\N	SUBMITTED	b492f8a7-29a4-4012-a173-bb1cf5135319	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 10:27:10.617
21c572cc-58a3-4642-825e-2319be99037c	3ff1ea13-607d-456a-a855-6218f6449202	\N	SUBMITTED	9ad0fc29-8daf-4688-925e-9fa71d6a2e80	Breakdown reported: ENGINE_FAILURE. Towing required: true.	2026-11-22 10:27:35.251
f3936a2f-b32c-43c9-9b30-08996fde8724	3ff1ea13-607d-456a-a855-6218f6449202	SUBMITTED	ACCEPTED	8ad6b40d-ab52-471f-b6dc-4dcc2d132efe	Dispatch claimed by Hunt High-Performance Roadside	2026-11-22 10:27:35.282
12777323-fbf9-469b-afc3-a71cbd08828d	3ff1ea13-607d-456a-a855-6218f6449202	ACCEPTED	EN_ROUTE	8ad6b40d-ab52-471f-b6dc-4dcc2d132efe	Technician departed garage; en route via arterial highway.	2026-11-22 10:27:35.385
855dd230-a3e2-44c9-b243-9238ad447d3b	3ff1ea13-607d-456a-a855-6218f6449202	EN_ROUTE	ARRIVED	8ad6b40d-ab52-471f-b6dc-4dcc2d132efe	Arrived at incident site; positioning emergency safety cones.	2026-11-22 10:27:35.409
14657718-45e5-4778-b82c-bf27020eaccd	3ff1ea13-607d-456a-a855-6218f6449202	ARRIVED	ARRIVED	8ad6b40d-ab52-471f-b6dc-4dcc2d132efe	Quotation updated: Diagnostic=$65, Labor=$120, Parts=$85. Total=$270.	2026-11-22 10:27:35.437
086919cf-62b6-4bb7-9665-e6c1f7be386d	3ff1ea13-607d-456a-a855-6218f6449202	ARRIVED	IN_PROGRESS	8ad6b40d-ab52-471f-b6dc-4dcc2d132efe	Disassembled ignition harness; installing new OEM coils.	2026-11-22 10:27:35.534
70b9775b-668a-4826-a122-fce1284d99b3	3ff1ea13-607d-456a-a855-6218f6449202	IN_PROGRESS	COMPLETED	8ad6b40d-ab52-471f-b6dc-4dcc2d132efe	Replaced ignition coil pack #3, cleared DTC trouble codes, engine running smoothly at idle.	2026-11-22 10:27:35.559
e8762033-1733-4d23-9ec3-7e8967b2056e	5e172816-2bbd-40fa-8ab1-9681da002123	\N	SUBMITTED	9ad0fc29-8daf-4688-925e-9fa71d6a2e80	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 10:27:35.605
4b95b0aa-6352-4ffe-8729-5ec54f34edc5	5e172816-2bbd-40fa-8ab1-9681da002123	SUBMITTED	ACCEPTED	8ad6b40d-ab52-471f-b6dc-4dcc2d132efe	Dispatch claimed by Hunt High-Performance Roadside	2026-11-22 10:27:35.623
9e608ac1-eeb1-4bfb-b80a-f0e7862ebc13	5e172816-2bbd-40fa-8ab1-9681da002123	ACCEPTED	CANCELLED	9ad0fc29-8daf-4688-925e-9fa71d6a2e80	Cancellation reason: Spare tire located; vehicle changed independently.	2026-11-22 10:27:35.642
d5ccc78f-611c-476e-9cda-e7120c0bb146	a0f6e6c2-fba1-49c2-923b-dd60e4c0e159	\N	SUBMITTED	201144dc-4d12-4765-8873-8573ebc70566	Breakdown reported: ENGINE_FAILURE. Towing required: true.	2026-11-22 10:27:50.874
067e82f8-d4ca-4106-9d67-1d83f032251c	a0f6e6c2-fba1-49c2-923b-dd60e4c0e159	SUBMITTED	ACCEPTED	58ea9816-d0a5-42ae-92d8-55f32ab1135f	Dispatch claimed by Hunt High-Performance Roadside	2026-11-22 10:27:50.906
17d23920-9dac-4e05-a551-b96e2002b8ad	a0f6e6c2-fba1-49c2-923b-dd60e4c0e159	ACCEPTED	EN_ROUTE	58ea9816-d0a5-42ae-92d8-55f32ab1135f	Technician departed garage; en route via arterial highway.	2026-11-22 10:27:51.03
1d22c5dc-b2de-421a-8551-175e3bde3f9d	51384e1b-99f0-4db4-82af-19765954040b	\N	SUBMITTED	4fb4b922-a2e7-4d24-9e81-1bae59ab792b	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 10:27:51.053
2183c5ce-0f2f-4f33-be07-7cc6611bb6ba	a0f6e6c2-fba1-49c2-923b-dd60e4c0e159	EN_ROUTE	ARRIVED	58ea9816-d0a5-42ae-92d8-55f32ab1135f	Arrived at incident site; positioning emergency safety cones.	2026-11-22 10:27:51.058
e248c03b-ccdd-4a11-ba8d-b0ef185ad6df	a0f6e6c2-fba1-49c2-923b-dd60e4c0e159	ARRIVED	ARRIVED	58ea9816-d0a5-42ae-92d8-55f32ab1135f	Quotation updated: Diagnostic=$65, Labor=$120, Parts=$85. Total=$270.	2026-11-22 10:27:51.083
20a14115-c4a0-4303-a5ea-4b21db3e26fa	984347f6-637a-4011-98b2-17e322bf14ec	\N	SUBMITTED	020de9be-8c9a-4232-a522-39dfbf87cf9c	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 10:27:51.156
97578360-3646-4375-ac3e-9546ff1a0d57	a0f6e6c2-fba1-49c2-923b-dd60e4c0e159	ARRIVED	IN_PROGRESS	58ea9816-d0a5-42ae-92d8-55f32ab1135f	Disassembled ignition harness; installing new OEM coils.	2026-11-22 10:27:51.179
1c8f6df0-f50c-4527-a21c-0a9f886677f9	984347f6-637a-4011-98b2-17e322bf14ec	SUBMITTED	ACCEPTED	ab64f7e0-5ae5-4282-826f-e08e48227f23	Dispatch claimed by Downtown Elite Precision	2026-11-22 10:27:51.392
179098d6-94a5-4c36-a766-bd329dd6e2d5	a0f6e6c2-fba1-49c2-923b-dd60e4c0e159	IN_PROGRESS	COMPLETED	58ea9816-d0a5-42ae-92d8-55f32ab1135f	Replaced ignition coil pack #3, cleared DTC trouble codes, engine running smoothly at idle.	2026-11-22 10:27:51.208
f1ab49de-f191-4b65-b88e-5bd4ff6d220e	43f9bea4-e74b-494e-ac24-ff66160fcc33	\N	SUBMITTED	201144dc-4d12-4765-8873-8573ebc70566	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 10:27:51.261
788fad0c-0828-405f-a891-f0b233d68fbf	43f9bea4-e74b-494e-ac24-ff66160fcc33	SUBMITTED	ACCEPTED	58ea9816-d0a5-42ae-92d8-55f32ab1135f	Dispatch claimed by Hunt High-Performance Roadside	2026-11-22 10:27:51.285
34b05f87-c64e-456a-b2ea-b42e374d3393	43f9bea4-e74b-494e-ac24-ff66160fcc33	ACCEPTED	CANCELLED	201144dc-4d12-4765-8873-8573ebc70566	Cancellation reason: Spare tire located; vehicle changed independently.	2026-11-22 10:27:51.308
95f80740-95d0-4fb9-9991-9cc48e05edcc	edd9350f-57ba-4afc-9012-3c33bfee850f	\N	SUBMITTED	e05d0c61-e1ae-4921-8453-3dc06525dc08	Breakdown reported: COLLISION_ACCIDENT. Towing required: true.	2026-11-22 10:27:51.376
9d8843a4-a758-4357-8624-f9858752c3bd	e8622675-c26b-4432-8487-e7fa171c4d07	\N	SUBMITTED	e05d0c61-e1ae-4921-8453-3dc06525dc08	Breakdown reported: BRAKE_SYSTEM_FAILURE. Towing required: true.	2026-11-22 10:27:51.433
0aa7f0f3-09ec-4da6-9f7a-ad1dc61e44de	ce00cc34-7d7d-494a-b57e-100759b7de17	\N	SUBMITTED	e05d0c61-e1ae-4921-8453-3dc06525dc08	Breakdown reported: BATTERY_DEAD_ELECTRICAL. Towing required: false.	2026-11-22 10:27:51.461
b6717da3-47f2-4c40-9e4f-96eb22596564	96aa711f-4ebb-4db9-a126-2904883ac599	\N	SUBMITTED	e05d0c61-e1ae-4921-8453-3dc06525dc08	Breakdown reported: TRANSMISSION_ISSUE. Towing required: true.	2026-11-22 10:27:51.482
32d16bad-9096-448d-9bf9-6ea86cf86e3f	b186dee4-58ad-4285-9ea0-51bfa75dcf31	\N	SUBMITTED	e05d0c61-e1ae-4921-8453-3dc06525dc08	Breakdown reported: FUEL_EMPTY_OR_CONTAMINATED. Towing required: false.	2026-11-22 10:27:51.526
d93557da-e340-4f40-a89b-79cd728177a9	89f3a469-2aae-40f1-aa53-d31dc6300aa9	\N	SUBMITTED	e05d0c61-e1ae-4921-8453-3dc06525dc08	Breakdown reported: OVERHEATING_COOLANT. Towing required: false.	2026-11-22 10:27:51.541
3b2d220c-e014-4177-b460-86e81e945470	c96e2b21-805b-41cc-ab1a-ae5de8f32b56	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 10:35:04.789
26dce1e8-6dcb-4d79-8499-36724f22e233	4aee0e90-eaf2-4979-97d8-40d337cfd0aa	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 10:36:13.032
2601d706-6bc0-4555-8607-ad4c4fd5b060	e8622675-c26b-4432-8487-e7fa171c4d07	SUBMITTED	ACCEPTED	473401ce-0803-422f-8baa-a47de557f84e	Dispatch claimed by Apex Mobile Roadside Services	2026-11-22 10:36:16.363
70ece781-78dc-4a29-bf03-30056bf607fa	e8622675-c26b-4432-8487-e7fa171c4d07	ACCEPTED	EN_ROUTE	473401ce-0803-422f-8baa-a47de557f84e	Technician departed base en route to incident site.	2026-11-22 10:36:16.425
c4a4590a-2977-4650-974c-0da825f4bc2c	e8622675-c26b-4432-8487-e7fa171c4d07	EN_ROUTE	ARRIVED	473401ce-0803-422f-8baa-a47de557f84e	Technician arrived on scene at incident coordinates.	2026-11-22 10:36:19.244
e9024bd0-47c3-4843-ab62-a639d2b4e811	e8622675-c26b-4432-8487-e7fa171c4d07	ARRIVED	ARRIVED	473401ce-0803-422f-8baa-a47de557f84e	Quotation updated: Diagnostic=$65, Labor=$120, Parts=$75. Total=$260.	2026-11-22 10:36:19.388
96219b85-5f4d-407d-ab9f-2edfc704e477	e8622675-c26b-4432-8487-e7fa171c4d07	ARRIVED	IN_PROGRESS	473401ce-0803-422f-8baa-a47de557f84e	Beginning diagnostic disassembly and component servicing.	2026-11-22 10:36:20.909
3570f65f-8886-4518-9f5e-7812a25e6e6f	e8622675-c26b-4432-8487-e7fa171c4d07	IN_PROGRESS	COMPLETED	473401ce-0803-422f-8baa-a47de557f84e	Service finished successfully.	2026-11-22 10:36:21.02
51f12d4c-0d89-42a8-8bea-a86c2128ebc1	1ccb5362-0ecf-4938-842e-e453d9b4ed9b	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: true.	2026-11-22 10:37:45.61
2db40ffc-575d-4ced-876d-27109403ed0f	5667e3e6-1685-49a1-ae1b-73e2d7019d11	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: true.	2026-11-22 10:38:35.649
d72cfc79-d958-4b10-9ea8-85d4c903d9c2	5667e3e6-1685-49a1-ae1b-73e2d7019d11	SUBMITTED	ACCEPTED	473401ce-0803-422f-8baa-a47de557f84e	Dispatch claimed by Apex Mobile Roadside Services	2026-11-22 10:38:39.071
5c8543cc-1ca9-4d38-94fd-5d1ad4e4fe41	5667e3e6-1685-49a1-ae1b-73e2d7019d11	ACCEPTED	EN_ROUTE	473401ce-0803-422f-8baa-a47de557f84e	Technician departed base en route to incident site.	2026-11-22 10:38:39.128
4242fa44-bc2b-49bd-84ac-0caa1b5a9275	5667e3e6-1685-49a1-ae1b-73e2d7019d11	EN_ROUTE	ARRIVED	473401ce-0803-422f-8baa-a47de557f84e	Technician arrived on scene at incident coordinates.	2026-11-22 10:38:41.667
5de4c8b2-480e-4da6-ac52-46554f3de1b1	5667e3e6-1685-49a1-ae1b-73e2d7019d11	ARRIVED	ARRIVED	473401ce-0803-422f-8baa-a47de557f84e	Quotation updated: Diagnostic=$65, Labor=$120, Parts=$75. Total=$260.	2026-11-22 10:38:41.79
0ddc7a91-a5ce-4d5a-a10c-b9a9e9b6969a	5667e3e6-1685-49a1-ae1b-73e2d7019d11	ARRIVED	IN_PROGRESS	473401ce-0803-422f-8baa-a47de557f84e	Beginning diagnostic disassembly and component servicing.	2026-11-22 10:38:43.311
51c812c3-0f10-4c54-a150-fc6eeed18052	5667e3e6-1685-49a1-ae1b-73e2d7019d11	IN_PROGRESS	COMPLETED	473401ce-0803-422f-8baa-a47de557f84e	Service finished successfully.	2026-11-22 10:38:43.42
7e0229ea-d486-44e3-9d80-a0063efdfc47	49450716-fcc2-44a0-8567-0f8c5d6ab7a0	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: TRANSMISSION_ISSUE. Towing required: true.	2026-11-22 10:39:22.562
26e04875-7131-4853-9906-fbe7ab7d4f1f	1522a43d-a323-41f9-a9d5-67463ebc323d	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 10:39:29.796
624c1b9c-1018-4001-aa86-a2971e1f2594	a16cb0b7-dff9-4c7c-9af0-b66ad02b20d3	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 10:39:34.266
f616b2d4-2981-418d-a25b-8c70b7a77d1c	a16cb0b7-dff9-4c7c-9af0-b66ad02b20d3	SUBMITTED	ACCEPTED	473401ce-0803-422f-8baa-a47de557f84e	Dispatch claimed by Apex Mobile Roadside Services	2026-11-22 10:39:42.227
2e3a5000-24dc-4155-a556-2c110a280677	cf01e1d7-1509-40ec-a5d3-63f04e652d0c	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 10:40:01.76
7e10e267-bfba-44b2-b413-d01a0e99a077	1dd07957-0c54-452c-b8aa-9d314d95eb48	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 10:41:06.868
0f11696c-7e42-4c1d-af28-50d143860aa2	1dd07957-0c54-452c-b8aa-9d314d95eb48	SUBMITTED	ACCEPTED	473401ce-0803-422f-8baa-a47de557f84e	Dispatch claimed by Apex Mobile Roadside Services	2026-11-22 10:41:14.865
2127b8e7-7112-4199-a06e-0c36e0dfa258	5fc2a975-92bf-4ae6-bea8-2b08fe76c1f5	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: true.	2026-11-22 10:41:19.067
d6566a20-ec71-4150-9fc7-db58a75bcd62	5fc2a975-92bf-4ae6-bea8-2b08fe76c1f5	SUBMITTED	ACCEPTED	473401ce-0803-422f-8baa-a47de557f84e	Dispatch claimed by Apex Mobile Roadside Services	2026-11-22 10:41:22.633
5ce078c2-b66f-46a5-9618-c2cc31335485	38ab3d1d-0dd4-4a0b-9a07-a072a106b9ea	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: true.	2026-11-22 10:41:48.681
48b1bf77-56bd-48fc-83e4-262ce23d179f	38ab3d1d-0dd4-4a0b-9a07-a072a106b9ea	SUBMITTED	ACCEPTED	473401ce-0803-422f-8baa-a47de557f84e	Dispatch claimed by Apex Mobile Roadside Services	2026-11-22 10:41:51.995
6ba607c7-25fe-4742-915f-affc4281ca7a	38ab3d1d-0dd4-4a0b-9a07-a072a106b9ea	ACCEPTED	EN_ROUTE	473401ce-0803-422f-8baa-a47de557f84e	Technician departed base en route to incident site.	2026-11-22 10:41:52.053
c0fa297e-f41e-48f3-874c-88fb26736e37	38ab3d1d-0dd4-4a0b-9a07-a072a106b9ea	ARRIVED	ARRIVED	473401ce-0803-422f-8baa-a47de557f84e	Quotation updated: Diagnostic=$65, Labor=$120, Parts=$75. Total=$260.	2026-11-22 10:41:54.733
131294cf-8d97-48c7-8176-48b31689e0bf	38ab3d1d-0dd4-4a0b-9a07-a072a106b9ea	ARRIVED	IN_PROGRESS	473401ce-0803-422f-8baa-a47de557f84e	Beginning diagnostic disassembly and component servicing.	2026-11-22 10:41:56.251
b3ee7bfe-ce83-4cc6-9983-7a691bacdf7e	38ab3d1d-0dd4-4a0b-9a07-a072a106b9ea	EN_ROUTE	ARRIVED	473401ce-0803-422f-8baa-a47de557f84e	Technician arrived on scene at incident coordinates.	2026-11-22 10:41:54.606
5c8daa56-668d-4d90-9ea3-b56172db2f17	38ab3d1d-0dd4-4a0b-9a07-a072a106b9ea	IN_PROGRESS	COMPLETED	473401ce-0803-422f-8baa-a47de557f84e	Service finished successfully.	2026-11-22 10:41:56.35
3f6e0559-fd5f-4f9c-8d96-e2793181ad7e	1d7dde36-f3a9-4f99-bad1-adcbbeab529d	\N	SUBMITTED	e51a5048-6c2d-466a-ae62-613927b40269	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 10:42:22.422
9c12135f-ef79-4e62-91a8-df5d71c855c6	dff4bfd6-f7b6-4c8a-b8a7-eda1c0f3fed6	\N	SUBMITTED	a17cea7b-22a1-44e0-a813-5f16ce79bc69	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 10:42:22.651
6d87634b-9850-4b54-a002-5bdd19f4f5bc	f01f0ecf-e901-471b-a4b8-da8a852f0789	\N	SUBMITTED	b347ca38-e44c-42ac-a846-63d4b6c28e3a	Breakdown reported: COLLISION_ACCIDENT. Towing required: true.	2026-11-22 10:42:22.713
f8b700e8-248f-4155-aec4-273e8551d3fb	4e48bdf2-f63d-4b6f-8e2a-41641c5c2a86	\N	SUBMITTED	b347ca38-e44c-42ac-a846-63d4b6c28e3a	Breakdown reported: BRAKE_SYSTEM_FAILURE. Towing required: true.	2026-11-22 10:42:22.781
adb204ab-7bc5-4910-b5a6-7e73eedc3610	29996938-70f4-4fee-bed3-a90ad4e9c1f4	\N	SUBMITTED	b347ca38-e44c-42ac-a846-63d4b6c28e3a	Breakdown reported: BATTERY_DEAD_ELECTRICAL. Towing required: false.	2026-11-22 10:42:22.814
20fbdb2c-df63-4010-8d9f-830ac4681983	3e903ed0-fb76-4875-9ebe-b8a9497781c7	\N	SUBMITTED	b347ca38-e44c-42ac-a846-63d4b6c28e3a	Breakdown reported: TRANSMISSION_ISSUE. Towing required: true.	2026-11-22 10:42:22.841
7a2ae1a0-7222-4b7c-86ca-8f4f8b2b43a5	499fb770-ca14-4a73-9b75-3960da9e0f60	\N	SUBMITTED	b347ca38-e44c-42ac-a846-63d4b6c28e3a	Breakdown reported: FUEL_EMPTY_OR_CONTAMINATED. Towing required: false.	2026-11-22 10:42:22.878
cab29e25-e329-485f-aa64-2d3f720f1ca5	da6cc39b-db40-465a-bc87-cb6f0c3fc8a3	\N	SUBMITTED	b347ca38-e44c-42ac-a846-63d4b6c28e3a	Breakdown reported: OVERHEATING_COOLANT. Towing required: false.	2026-11-22 10:42:22.893
d459babc-6d61-4cb1-827c-d3b896ce8f63	dff4bfd6-f7b6-4c8a-b8a7-eda1c0f3fed6	SUBMITTED	ACCEPTED	6dffcd9a-0d48-4863-a865-8f96c2680bf5	Dispatch claimed by Downtown Elite Precision	2026-11-22 10:42:22.9
68403c3c-7c2a-4c0b-ad1f-99f350d55ffb	c0196faf-c92c-4aa7-803d-e5f968d1ee3d	\N	SUBMITTED	24d8704e-eebc-4c21-986b-d85a1ed5a92a	Breakdown reported: ENGINE_FAILURE. Towing required: true.	2026-11-22 10:42:23.165
07576a66-7717-461c-a2bf-8c3308bffffc	c0196faf-c92c-4aa7-803d-e5f968d1ee3d	SUBMITTED	ACCEPTED	fd109b4c-5829-497b-8da6-252d426b4a4d	Dispatch claimed by Hunt High-Performance Roadside	2026-11-22 10:42:23.206
2457a505-0545-4e5c-89ff-da4f5855323c	c0196faf-c92c-4aa7-803d-e5f968d1ee3d	ACCEPTED	EN_ROUTE	fd109b4c-5829-497b-8da6-252d426b4a4d	Technician departed garage; en route via arterial highway.	2026-11-22 10:42:23.341
630adab8-f8dc-4bd8-bd8e-13bee1c4d0eb	c0196faf-c92c-4aa7-803d-e5f968d1ee3d	EN_ROUTE	ARRIVED	fd109b4c-5829-497b-8da6-252d426b4a4d	Arrived at incident site; positioning emergency safety cones.	2026-11-22 10:42:23.372
2dab13e4-3d5f-4fb3-aaad-5163be4ebbf9	c0196faf-c92c-4aa7-803d-e5f968d1ee3d	ARRIVED	ARRIVED	fd109b4c-5829-497b-8da6-252d426b4a4d	Quotation updated: Diagnostic=$65, Labor=$120, Parts=$85. Total=$270.	2026-11-22 10:42:23.396
de394ef5-57ae-4c1e-bc81-82115aa6d54c	c0196faf-c92c-4aa7-803d-e5f968d1ee3d	ARRIVED	IN_PROGRESS	fd109b4c-5829-497b-8da6-252d426b4a4d	Disassembled ignition harness; installing new OEM coils.	2026-11-22 10:42:23.479
858cfe14-c737-454f-966a-d5f2e21c9854	c0196faf-c92c-4aa7-803d-e5f968d1ee3d	IN_PROGRESS	COMPLETED	fd109b4c-5829-497b-8da6-252d426b4a4d	Replaced ignition coil pack #3, cleared DTC trouble codes, engine running smoothly at idle.	2026-11-22 10:42:23.507
ca2703b7-4ed5-4b5e-a832-a80572b4e967	a4fd96c9-1891-4547-bf8a-253904e5cd55	\N	SUBMITTED	24d8704e-eebc-4c21-986b-d85a1ed5a92a	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 10:42:23.557
d7677f05-ebcc-46fe-a9a9-0511579f115d	a4fd96c9-1891-4547-bf8a-253904e5cd55	SUBMITTED	ACCEPTED	fd109b4c-5829-497b-8da6-252d426b4a4d	Dispatch claimed by Hunt High-Performance Roadside	2026-11-22 10:42:23.577
c24da809-2410-4e87-866d-a21b9d70cbbf	a4fd96c9-1891-4547-bf8a-253904e5cd55	ACCEPTED	CANCELLED	24d8704e-eebc-4c21-986b-d85a1ed5a92a	Cancellation reason: Spare tire located; vehicle changed independently.	2026-11-22 10:42:23.598
1d4016ae-4c95-48d6-95dd-0e0cb9e75ed7	cfcb4df3-b199-4ed3-9448-0f6165f70602	\N	SUBMITTED	20e961e5-4364-4013-ac83-b3cdac902909	Breakdown reported: BRAKE_SYSTEM_FAILURE. Towing required: true.	2026-11-22 10:58:26.389
93a5cb7a-2c96-499c-8f28-2bd3976ac7e2	46de9cc7-0ffd-4f17-934b-809a3ff3be0e	\N	SUBMITTED	a180a88c-5a9a-4731-add7-99d767857c44	Breakdown reported: BRAKE_SYSTEM_FAILURE. Towing required: true.	2026-11-22 10:58:53.206
7e133217-a90f-439c-bc54-9bbfb463e8dd	0c60b08f-e918-4c69-a585-045e9c65ff7d	\N	SUBMITTED	2ae75f04-e851-4d24-81dc-67588ba24232	Breakdown reported: BRAKE_SYSTEM_FAILURE. Towing required: true.	2026-11-22 10:59:10.912
a208149b-d094-4d91-bc1c-5414e9eafd86	a7ba10f4-e2f0-4a33-abb1-fe9374a5fa7f	\N	SUBMITTED	23e55200-8e86-4e87-92e2-b55e228b92f3	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 10:59:11.552
de7f9d29-3b79-4ded-94a1-9f16f1dcad41	283252d6-d0b6-4be3-89db-41879add66e3	\N	SUBMITTED	49c5925b-fda2-4bcc-b6b0-87b387231f58	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 10:59:11.715
1db84955-9be9-467c-b008-fef2ebc585f6	c29e8286-f16b-40c6-a762-4e6376c2e575	\N	SUBMITTED	245a9356-c816-4507-8269-0fc18dd346f9	Breakdown reported: COLLISION_ACCIDENT. Towing required: true.	2026-11-22 10:59:11.85
e129072a-df54-4110-b2e6-a8f48e8cb952	2631ce63-4446-4c41-820f-cbc61ef9da47	\N	SUBMITTED	245a9356-c816-4507-8269-0fc18dd346f9	Breakdown reported: BRAKE_SYSTEM_FAILURE. Towing required: true.	2026-11-22 10:59:11.928
7432044e-7973-4f08-a12c-1e74f69a2e20	283252d6-d0b6-4be3-89db-41879add66e3	SUBMITTED	ACCEPTED	459fd1f2-01ce-465d-b584-90ce7e7c8297	Dispatch claimed by Downtown Elite Precision	2026-11-22 10:59:11.956
9c7d367e-806d-4105-9a18-f9cf1058de1e	43f56aac-9c0a-4c09-926e-e4a6d2533fb4	\N	SUBMITTED	245a9356-c816-4507-8269-0fc18dd346f9	Breakdown reported: BATTERY_DEAD_ELECTRICAL. Towing required: false.	2026-11-22 10:59:11.964
f246683a-988c-45f1-94ff-071c831e3f53	1995f625-de53-466f-a0d1-2fda96929924	\N	SUBMITTED	245a9356-c816-4507-8269-0fc18dd346f9	Breakdown reported: TRANSMISSION_ISSUE. Towing required: true.	2026-11-22 10:59:12.003
adff306a-91e9-4f11-b4bd-d09f14f9eb98	018aeb68-6048-4881-b4ff-738da8e668e0	\N	SUBMITTED	245a9356-c816-4507-8269-0fc18dd346f9	Breakdown reported: FUEL_EMPTY_OR_CONTAMINATED. Towing required: false.	2026-11-22 10:59:12.043
b75073fa-53df-4d76-925c-10e4995af443	94b34d54-bc76-47ef-b769-efc10addeae8	\N	SUBMITTED	245a9356-c816-4507-8269-0fc18dd346f9	Breakdown reported: OVERHEATING_COOLANT. Towing required: false.	2026-11-22 10:59:12.058
647a8f07-0630-4de0-a21b-6cb1b0869bb7	1de5bce5-6431-4d04-a84f-ea33e64551cd	\N	SUBMITTED	11947c9d-6f0f-425d-b26d-1cd07a25138a	Breakdown reported: ENGINE_FAILURE. Towing required: true.	2026-11-22 10:59:12.251
1844aff7-2dcd-4eb4-9bb2-6b265dd077b0	1de5bce5-6431-4d04-a84f-ea33e64551cd	SUBMITTED	ACCEPTED	04a4b6cb-3c82-45bb-acab-d78e0713971a	Dispatch claimed by Hunt High-Performance Roadside	2026-11-22 10:59:12.285
38c95ad6-cd2f-412b-a885-0070a7a6a299	1de5bce5-6431-4d04-a84f-ea33e64551cd	ACCEPTED	EN_ROUTE	04a4b6cb-3c82-45bb-acab-d78e0713971a	Technician departed garage; en route via arterial highway.	2026-11-22 10:59:12.402
71d2ab65-b21d-46b8-8cad-e12d96f388ba	1de5bce5-6431-4d04-a84f-ea33e64551cd	EN_ROUTE	ARRIVED	04a4b6cb-3c82-45bb-acab-d78e0713971a	Arrived at incident site; positioning emergency safety cones.	2026-11-22 10:59:12.429
cdcfb03c-5cea-4c7f-bfa8-48e306176c89	1de5bce5-6431-4d04-a84f-ea33e64551cd	ARRIVED	ARRIVED	04a4b6cb-3c82-45bb-acab-d78e0713971a	Quotation updated: Diagnostic=$65, Labor=$120, Parts=$85. Total=$270.	2026-11-22 10:59:12.453
fe420bc6-e587-4550-b01f-6b77893aae5d	1de5bce5-6431-4d04-a84f-ea33e64551cd	ARRIVED	IN_PROGRESS	04a4b6cb-3c82-45bb-acab-d78e0713971a	Disassembled ignition harness; installing new OEM coils.	2026-11-22 10:59:12.541
1bf49e0e-9a04-43d3-a1f7-171a6448b876	1de5bce5-6431-4d04-a84f-ea33e64551cd	IN_PROGRESS	COMPLETED	04a4b6cb-3c82-45bb-acab-d78e0713971a	Replaced ignition coil pack #3, cleared DTC trouble codes, engine running smoothly at idle.	2026-11-22 10:59:12.568
ca006b4d-4109-4e81-b059-37546229d285	94d757d5-a968-4f25-b8c3-e11713ac4303	\N	SUBMITTED	11947c9d-6f0f-425d-b26d-1cd07a25138a	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 10:59:12.617
17e5a77e-8f6a-4b2a-a899-dc95faaf4b3f	94d757d5-a968-4f25-b8c3-e11713ac4303	SUBMITTED	ACCEPTED	04a4b6cb-3c82-45bb-acab-d78e0713971a	Dispatch claimed by Hunt High-Performance Roadside	2026-11-22 10:59:12.636
df280485-9360-40e5-b8f9-8cf986c7bdbf	94d757d5-a968-4f25-b8c3-e11713ac4303	ACCEPTED	CANCELLED	11947c9d-6f0f-425d-b26d-1cd07a25138a	Cancellation reason: Spare tire located; vehicle changed independently.	2026-11-22 10:59:12.655
f4a0104a-9a06-4258-943f-9cde891901f4	c2cde923-c55c-477a-ad50-72465af001fd	\N	SUBMITTED	6f0c5a39-62c6-49b0-9305-3747a819cf83	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 11:06:31.921
3fac8e91-af78-4b0d-9966-a1daf3fffde9	1dad5bfe-ba6c-40b8-8db5-93a2bcb4b6da	\N	SUBMITTED	4bc6bd4b-da8e-4372-8bac-0333b1e85ab1	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 11:06:32.071
d33ce89c-78f3-4824-884b-6699ad5d32f3	903fc3ca-67b9-4e24-8310-97f0211dd5be	\N	SUBMITTED	15372eae-1d2d-4d1b-af92-e71b76d3393e	Breakdown reported: BRAKE_SYSTEM_FAILURE. Towing required: true.	2026-11-22 11:06:32.121
1ba95e50-4006-47b8-b11f-8ee6c6223f93	7a499a66-d3db-4180-88ff-f9ef42bd53fb	\N	SUBMITTED	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	Breakdown reported: COLLISION_ACCIDENT. Towing required: true.	2026-11-22 11:06:32.323
3115e7d1-ca3a-49e3-b109-e11895ad6f40	1dad5bfe-ba6c-40b8-8db5-93a2bcb4b6da	SUBMITTED	ACCEPTED	29db8df8-1b56-42f1-9da5-e687727e448e	Dispatch claimed by Downtown Elite Precision	2026-11-22 11:06:32.372
8b21a20b-fb2f-477e-9699-6d12a97bda16	d7e14310-326c-48b5-b1b4-db5ea2ae2ac1	\N	SUBMITTED	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	Breakdown reported: BRAKE_SYSTEM_FAILURE. Towing required: true.	2026-11-22 11:06:32.399
d1eae17b-3c12-4609-a2ec-02253a4f05e0	f94c387f-0755-4eca-8ae7-1ebab0dd36e2	\N	SUBMITTED	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	Breakdown reported: BATTERY_DEAD_ELECTRICAL. Towing required: false.	2026-11-22 11:06:32.433
aa3adf5e-b611-45dc-a840-723e48c4ac94	527539ea-a112-466d-8283-1bad6080f1cc	\N	SUBMITTED	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	Breakdown reported: TRANSMISSION_ISSUE. Towing required: true.	2026-11-22 11:06:32.457
dac55890-d177-4b9f-977a-c60764b258b8	14d6c4da-5e6b-4f7d-b78f-eddcab5ff2cf	\N	SUBMITTED	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	Breakdown reported: FUEL_EMPTY_OR_CONTAMINATED. Towing required: false.	2026-11-22 11:06:32.494
d3d5e94c-e2fa-4a24-a37b-6336f1c7a9e1	2a767b3b-ac94-45d9-ad73-5efb065868ed	\N	SUBMITTED	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	Breakdown reported: OVERHEATING_COOLANT. Towing required: false.	2026-11-22 11:06:32.511
b3a5cce7-e31a-46d9-bdb1-865ad727fcdb	efd1162e-7195-48b0-a84c-fac36036f0c8	\N	SUBMITTED	1302fef8-4b27-4105-8596-a34489c6c8a0	Breakdown reported: ENGINE_FAILURE. Towing required: true.	2026-11-22 11:06:32.583
55186971-a366-4b9e-9905-0d4b94ce695b	efd1162e-7195-48b0-a84c-fac36036f0c8	SUBMITTED	ACCEPTED	91e6be61-ca06-4bb8-9843-38b5edc72e0b	Dispatch claimed by Hunt High-Performance Roadside	2026-11-22 11:06:32.62
1a77fb7e-b70b-4001-9fd6-dab74ac6b8ff	efd1162e-7195-48b0-a84c-fac36036f0c8	ACCEPTED	EN_ROUTE	91e6be61-ca06-4bb8-9843-38b5edc72e0b	Technician departed garage; en route via arterial highway.	2026-11-22 11:06:32.753
e969ef9d-c156-48f4-a4a2-c5b6fb5ed44e	efd1162e-7195-48b0-a84c-fac36036f0c8	EN_ROUTE	ARRIVED	91e6be61-ca06-4bb8-9843-38b5edc72e0b	Arrived at incident site; positioning emergency safety cones.	2026-11-22 11:06:32.783
1b23c996-1db5-4f0b-8e88-c917d8b4b696	efd1162e-7195-48b0-a84c-fac36036f0c8	ARRIVED	ARRIVED	91e6be61-ca06-4bb8-9843-38b5edc72e0b	Quotation updated: Diagnostic=$65, Labor=$120, Parts=$85. Total=$270.	2026-11-22 11:06:32.809
fe045a56-a5f2-4d7a-91e2-c780e1a3bb94	efd1162e-7195-48b0-a84c-fac36036f0c8	ARRIVED	IN_PROGRESS	91e6be61-ca06-4bb8-9843-38b5edc72e0b	Disassembled ignition harness; installing new OEM coils.	2026-11-22 11:06:32.901
4f03ec56-ab12-4544-b69d-3089097f4ed7	efd1162e-7195-48b0-a84c-fac36036f0c8	IN_PROGRESS	COMPLETED	91e6be61-ca06-4bb8-9843-38b5edc72e0b	Replaced ignition coil pack #3, cleared DTC trouble codes, engine running smoothly at idle.	2026-11-22 11:06:32.932
beec8482-960f-4ac5-8772-9000d054a9c6	750c2301-8f4b-4032-9c9a-9c8d1075b241	\N	SUBMITTED	1302fef8-4b27-4105-8596-a34489c6c8a0	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 11:06:32.99
a06669af-6049-4303-b848-b4dc69f00a15	750c2301-8f4b-4032-9c9a-9c8d1075b241	SUBMITTED	ACCEPTED	91e6be61-ca06-4bb8-9843-38b5edc72e0b	Dispatch claimed by Hunt High-Performance Roadside	2026-11-22 11:06:33.013
021217ae-faff-4ec7-8e41-1d9edd664e5d	750c2301-8f4b-4032-9c9a-9c8d1075b241	ACCEPTED	CANCELLED	1302fef8-4b27-4105-8596-a34489c6c8a0	Cancellation reason: Spare tire located; vehicle changed independently.	2026-11-22 11:06:33.036
3705f1b1-94a6-4b41-a052-2d1d0052221c	e3e4e51d-ff0b-48f0-b9c4-f015c94588d4	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: TRANSMISSION_ISSUE. Towing required: true.	2026-11-22 11:07:36.261
d9b4aa39-ad75-44c4-a7fd-d555d4c30e66	d5c0638a-c27c-495f-9d55-8d96217cc241	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 11:07:43.569
cdb01b81-69d0-4e12-83cc-6561651b0041	f1a85ac0-fa6c-4acf-b8f6-f4f0c3de8407	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 11:07:48.165
840d68b4-291a-4343-a60f-8ff801d128f0	f1a85ac0-fa6c-4acf-b8f6-f4f0c3de8407	SUBMITTED	ACCEPTED	473401ce-0803-422f-8baa-a47de557f84e	Dispatch claimed by Apex Mobile Roadside Services	2026-11-22 11:07:56.084
670ca061-e853-4d54-a060-4ad6ed347d31	c5d5b602-7553-4159-b0e3-590cb5ce8aae	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 11:08:05.317
ed35e00a-8c3a-4719-b468-7d426508db7e	9fc8566a-0976-4e4f-8426-6975285d5d70	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: true.	2026-11-22 11:08:15.712
4cda7686-b3a8-47be-8344-1548e9a4c5d2	9fc8566a-0976-4e4f-8426-6975285d5d70	SUBMITTED	ACCEPTED	473401ce-0803-422f-8baa-a47de557f84e	Dispatch claimed by Apex Mobile Roadside Services	2026-11-22 11:08:19.113
1bf78e1c-fc26-48d5-b238-c9c20ed3a184	9fc8566a-0976-4e4f-8426-6975285d5d70	ACCEPTED	EN_ROUTE	473401ce-0803-422f-8baa-a47de557f84e	Technician departed base en route to incident site.	2026-11-22 11:08:19.182
6233dcb7-6ec5-4cde-b4dc-074581cd815c	9fc8566a-0976-4e4f-8426-6975285d5d70	EN_ROUTE	ARRIVED	473401ce-0803-422f-8baa-a47de557f84e	Technician arrived on scene at incident coordinates.	2026-11-22 11:08:21.721
9a7fe6c5-64db-4605-8bf2-0471ae290746	9fc8566a-0976-4e4f-8426-6975285d5d70	ARRIVED	ARRIVED	473401ce-0803-422f-8baa-a47de557f84e	Quotation updated: Diagnostic=$65, Labor=$120, Parts=$75. Total=$260.	2026-11-22 11:08:21.846
43e16995-71aa-4f2b-9d01-d352a686219b	9fc8566a-0976-4e4f-8426-6975285d5d70	IN_PROGRESS	COMPLETED	473401ce-0803-422f-8baa-a47de557f84e	Service finished successfully.	2026-11-22 11:08:23.467
86e36e2f-c159-49c1-b5e8-88fea9ef661a	9fc8566a-0976-4e4f-8426-6975285d5d70	ARRIVED	IN_PROGRESS	473401ce-0803-422f-8baa-a47de557f84e	Beginning diagnostic disassembly and component servicing.	2026-11-22 11:08:23.37
966237ba-2d9e-40f9-a037-2839a5b42ccc	2d0b828b-c930-4ad4-b038-fc146e8f44d3	\N	SUBMITTED	282be406-30b3-4a61-a470-484970fa2ef9	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 11:25:32.508
4501ac61-36f1-4053-bd21-41bf3d2d61fb	c40214eb-b743-42e2-9395-9b268084330c	\N	SUBMITTED	8ce31ba5-bfb6-4062-8788-1d55d758fd08	Breakdown reported: BRAKE_SYSTEM_FAILURE. Towing required: true.	2026-11-22 11:25:32.788
6a7691f9-f0d2-4bcc-8b62-11f22b544938	e7003bae-6761-4520-b750-9b0c2d548428	\N	SUBMITTED	7a09bda9-bcb7-47db-9d6f-9cde4f8fe7cd	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 11:25:32.87
127d60d5-8e73-4d3f-870a-21f8af139d1d	5d45ad7a-a03f-4ef3-bae4-a49030b85635	\N	SUBMITTED	50ade227-7e8a-46fd-8685-2e2878c91b01	Breakdown reported: COLLISION_ACCIDENT. Towing required: true.	2026-11-22 11:25:32.947
f444b130-3109-487a-bd24-c9320186d4c9	d68acdcf-c276-4c9c-80b6-c386f4d15034	\N	SUBMITTED	50ade227-7e8a-46fd-8685-2e2878c91b01	Breakdown reported: BRAKE_SYSTEM_FAILURE. Towing required: true.	2026-11-22 11:25:33.022
e7ac0a6e-af0a-4c5b-a709-32ede1e15499	47b304ea-af1a-4207-9de3-64d37323f5d4	\N	SUBMITTED	50ade227-7e8a-46fd-8685-2e2878c91b01	Breakdown reported: BATTERY_DEAD_ELECTRICAL. Towing required: false.	2026-11-22 11:25:33.053
09bea1b0-07e7-4957-ac41-c66e7312c44d	33662181-fc79-44b8-948b-2cd902924be7	\N	SUBMITTED	50ade227-7e8a-46fd-8685-2e2878c91b01	Breakdown reported: TRANSMISSION_ISSUE. Towing required: true.	2026-11-22 11:25:33.077
6674c93a-67a9-45ee-a876-08adbe9fe01a	e7003bae-6761-4520-b750-9b0c2d548428	SUBMITTED	ACCEPTED	f7687de7-1987-44af-85d9-9fcc9f286770	Dispatch claimed by Downtown Elite Precision	2026-11-22 11:25:33.116
7ce16639-bf62-40a2-b343-75dba1401e99	bcc2a542-c716-41aa-8135-f5d5f1a658b1	\N	SUBMITTED	50ade227-7e8a-46fd-8685-2e2878c91b01	Breakdown reported: FUEL_EMPTY_OR_CONTAMINATED. Towing required: false.	2026-11-22 11:25:33.119
31637146-9adf-462f-9a4f-c35f2bd957ba	f5bbcf2b-9a4a-46c4-9140-3798fbd0d60b	\N	SUBMITTED	50ade227-7e8a-46fd-8685-2e2878c91b01	Breakdown reported: OVERHEATING_COOLANT. Towing required: false.	2026-11-22 11:25:33.134
47286917-8c36-47a9-9b5c-60b469d3649d	43519d31-f802-410d-915e-38f2fab6db62	\N	SUBMITTED	cd78682e-cc1a-4cc1-b024-3222b9c5e339	Breakdown reported: ENGINE_FAILURE. Towing required: true.	2026-11-22 11:25:33.333
3f8af5b2-cb0a-4a69-8722-bb8d0e4c45ec	43519d31-f802-410d-915e-38f2fab6db62	SUBMITTED	ACCEPTED	b6225e12-d48c-4709-97d5-6be7b6ef360d	Dispatch claimed by Hunt High-Performance Roadside	2026-11-22 11:25:33.37
021cd075-8c11-4468-8578-22a07a96af9d	43519d31-f802-410d-915e-38f2fab6db62	ACCEPTED	EN_ROUTE	b6225e12-d48c-4709-97d5-6be7b6ef360d	Technician departed garage; en route via arterial highway.	2026-11-22 11:25:33.496
fcd31ddb-3113-4304-9889-4890e32ca995	43519d31-f802-410d-915e-38f2fab6db62	EN_ROUTE	ARRIVED	b6225e12-d48c-4709-97d5-6be7b6ef360d	Arrived at incident site; positioning emergency safety cones.	2026-11-22 11:25:33.522
466b8c9f-8557-41db-8c70-b5ab2ea90b86	43519d31-f802-410d-915e-38f2fab6db62	ARRIVED	ARRIVED	b6225e12-d48c-4709-97d5-6be7b6ef360d	Quotation updated: Diagnostic=$65, Labor=$120, Parts=$85. Total=$270.	2026-11-22 11:25:33.544
e0520308-3ea9-44fc-8bb5-d0fe163f35bf	43519d31-f802-410d-915e-38f2fab6db62	ARRIVED	IN_PROGRESS	b6225e12-d48c-4709-97d5-6be7b6ef360d	Disassembled ignition harness; installing new OEM coils.	2026-11-22 11:25:33.618
3b393188-cfe3-4ab9-8f46-fee7add8c189	43519d31-f802-410d-915e-38f2fab6db62	IN_PROGRESS	COMPLETED	b6225e12-d48c-4709-97d5-6be7b6ef360d	Replaced ignition coil pack #3, cleared DTC trouble codes, engine running smoothly at idle.	2026-11-22 11:25:33.642
87f03eab-a8ef-4c26-90ec-439cdc9aeb19	c1c415f2-33da-43d2-b4b0-187f5847ac31	\N	SUBMITTED	cd78682e-cc1a-4cc1-b024-3222b9c5e339	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 11:25:33.688
dc2606e9-9ed0-4f12-bba4-4acded1161dc	c1c415f2-33da-43d2-b4b0-187f5847ac31	SUBMITTED	ACCEPTED	b6225e12-d48c-4709-97d5-6be7b6ef360d	Dispatch claimed by Hunt High-Performance Roadside	2026-11-22 11:25:33.709
bec75a2b-0884-46ce-9b00-77cf5e76d455	c1c415f2-33da-43d2-b4b0-187f5847ac31	ACCEPTED	CANCELLED	cd78682e-cc1a-4cc1-b024-3222b9c5e339	Cancellation reason: Spare tire located; vehicle changed independently.	2026-11-22 11:25:33.728
975725ec-0663-4880-bb54-f1b87caf074d	f051ceb5-0e36-4dcf-a0aa-c11a7a5d366e	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 11:31:05.891
c047b5cb-e30e-4620-8a13-3234e1338fb1	1d2d18b3-62c9-4e6c-aa00-6c5cbdd293e4	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 11:32:44.38
784c02a3-a50a-42ee-9f3b-3f6b19aa0dc0	c76217d5-6e4d-4397-a5c9-9c35b21d1489	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 11:33:45.353
94899227-efb5-4224-a9f1-b400e5db2889	9553175c-91fb-4c65-9a98-4d69aa929cd8	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 11:35:06.59
ba2a730d-dd9a-428e-af6c-671cf8f7f7ad	9553175c-91fb-4c65-9a98-4d69aa929cd8	SUBMITTED	ACCEPTED	473401ce-0803-422f-8baa-a47de557f84e	Dispatch claimed by Apex Mobile Roadside Services	2026-11-22 11:35:11.43
f895c076-6ac7-45ba-9d79-c41a56caccf1	9553175c-91fb-4c65-9a98-4d69aa929cd8	ACCEPTED	EN_ROUTE	473401ce-0803-422f-8baa-a47de557f84e	Technician departed base en route to incident site.	2026-11-22 11:35:11.502
df8e67d2-71ef-4f9a-9842-71d3839e6433	9553175c-91fb-4c65-9a98-4d69aa929cd8	EN_ROUTE	ARRIVED	473401ce-0803-422f-8baa-a47de557f84e	Technician arrived on scene at incident coordinates.	2026-11-22 11:35:11.61
34befe8e-1aed-4fce-8342-66eeadb203fd	4fcacb83-fe1b-460a-bf1f-1a5c80cccd66	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 11:36:05.041
057ea95e-dfda-482b-8d9a-d544efe76f0a	4fcacb83-fe1b-460a-bf1f-1a5c80cccd66	SUBMITTED	ACCEPTED	473401ce-0803-422f-8baa-a47de557f84e	Dispatch claimed by Apex Mobile Roadside Services	2026-11-22 11:36:09.883
819deb43-80c0-4011-bb89-5416ec7916c9	4fcacb83-fe1b-460a-bf1f-1a5c80cccd66	ACCEPTED	EN_ROUTE	473401ce-0803-422f-8baa-a47de557f84e	Technician departed base en route to incident site.	2026-11-22 11:36:09.998
ed2cc2f1-f1f1-4b33-b2e0-fc6f0fa3d063	4fcacb83-fe1b-460a-bf1f-1a5c80cccd66	EN_ROUTE	ARRIVED	473401ce-0803-422f-8baa-a47de557f84e	Technician arrived on scene at incident coordinates.	2026-11-22 11:36:10.097
73811363-ecf3-4a08-adda-f9576548d916	4fcacb83-fe1b-460a-bf1f-1a5c80cccd66	ARRIVED	ARRIVED	473401ce-0803-422f-8baa-a47de557f84e	Quotation updated: Diagnostic=$80, Labor=$100, Parts=$60. Total=$240.	2026-11-22 11:36:10.258
a593e07c-2e32-43c2-9d65-6a27819fce57	4fcacb83-fe1b-460a-bf1f-1a5c80cccd66	ARRIVED	IN_PROGRESS	473401ce-0803-422f-8baa-a47de557f84e	Beginning diagnostic disassembly and component servicing.	2026-11-22 11:36:11.784
78033cec-2116-432f-9374-6e32b3f9f9e2	4fcacb83-fe1b-460a-bf1f-1a5c80cccd66	IN_PROGRESS	COMPLETED	473401ce-0803-422f-8baa-a47de557f84e	Service finished successfully.	2026-11-22 11:36:11.9
ec2d2c03-a9e5-4e53-8b06-23a3306a8223	b33bf045-3d00-4e17-bd0b-65c10b5c5024	\N	SUBMITTED	487c98dd-e41e-417a-81df-6160ad2f08bd	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 11:36:38.699
0ed9b0e9-b718-4bf8-8316-192d4c55ae1f	71a0e527-0076-48b3-b1d1-d458adef3aba	\N	SUBMITTED	6108dc7f-6c15-4ee6-8a47-92ff7487b689	Breakdown reported: BRAKE_SYSTEM_FAILURE. Towing required: true.	2026-11-22 11:36:38.796
699c91a6-90a1-4166-8bb1-63ce0f25c6a1	6488e5ba-3fc9-4aa1-9e17-59777828f470	\N	SUBMITTED	12a59ca0-ebce-49aa-b8c8-2d6021a4d980	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 11:36:38.965
2c45c3ad-8e6a-40b2-9649-65e472c44cd0	662e5f7a-ff0a-485d-b7a6-ac43cd7b7384	\N	SUBMITTED	bbdc9439-1243-4dec-a18b-8b6512cede79	Breakdown reported: COLLISION_ACCIDENT. Towing required: true.	2026-11-22 11:36:39.069
b8b86ece-754e-4246-bfd5-2ad67edde5e8	aad8cea4-d171-4fee-b8f1-196ab8854575	\N	SUBMITTED	bbdc9439-1243-4dec-a18b-8b6512cede79	Breakdown reported: BRAKE_SYSTEM_FAILURE. Towing required: true.	2026-11-22 11:36:39.143
b22b0af8-4dfa-4d53-8970-d4fa2e17666b	2ae934e4-3acf-4a60-a335-960fb1fbc4d2	\N	SUBMITTED	bbdc9439-1243-4dec-a18b-8b6512cede79	Breakdown reported: BATTERY_DEAD_ELECTRICAL. Towing required: false.	2026-11-22 11:36:39.172
ee36d904-5534-4820-8a3b-4b93b440dc83	3ee29b71-f19b-4572-ab59-58ae86c2838c	\N	SUBMITTED	bbdc9439-1243-4dec-a18b-8b6512cede79	Breakdown reported: TRANSMISSION_ISSUE. Towing required: true.	2026-11-22 11:36:39.194
7c3770ce-4844-4240-98ab-4e288190a989	6488e5ba-3fc9-4aa1-9e17-59777828f470	SUBMITTED	ACCEPTED	13608b64-3065-4aea-99b6-4633b454b56d	Dispatch claimed by Downtown Elite Precision	2026-11-22 11:36:39.233
9c996817-5315-483e-a1f4-233611ad7a52	86114bbb-7c1a-410d-a3b1-ca45557e6040	\N	SUBMITTED	bbdc9439-1243-4dec-a18b-8b6512cede79	Breakdown reported: FUEL_EMPTY_OR_CONTAMINATED. Towing required: false.	2026-11-22 11:36:39.234
d3891136-cdd8-49a1-84dd-ab6ad3b6b021	4887e56b-1b89-48f8-bf83-a4ceb5ed7a0a	\N	SUBMITTED	bbdc9439-1243-4dec-a18b-8b6512cede79	Breakdown reported: OVERHEATING_COOLANT. Towing required: false.	2026-11-22 11:36:39.251
292b0ade-1b91-4d4b-8e1a-8575f1a6cc48	434a11c9-298a-432a-9454-30ba7fee3ca0	\N	SUBMITTED	4a059e43-c586-45be-b371-252f448bbdd8	Breakdown reported: ENGINE_FAILURE. Towing required: true.	2026-11-22 11:36:39.383
ed9abc08-1436-4580-8b64-5304a96b0777	434a11c9-298a-432a-9454-30ba7fee3ca0	SUBMITTED	ACCEPTED	6fce9f62-804c-480a-ba62-c337fa44ace7	Dispatch claimed by Hunt High-Performance Roadside	2026-11-22 11:36:39.418
86e5b1ee-f314-47d0-9183-61689f309bc6	434a11c9-298a-432a-9454-30ba7fee3ca0	ACCEPTED	EN_ROUTE	6fce9f62-804c-480a-ba62-c337fa44ace7	Technician departed garage; en route via arterial highway.	2026-11-22 11:36:39.53
375ad133-4ba8-4a0c-93d6-98c9cb692485	434a11c9-298a-432a-9454-30ba7fee3ca0	EN_ROUTE	ARRIVED	6fce9f62-804c-480a-ba62-c337fa44ace7	Arrived at incident site; positioning emergency safety cones.	2026-11-22 11:36:39.555
8590214f-e78a-446b-8172-33f75f9c0f87	434a11c9-298a-432a-9454-30ba7fee3ca0	ARRIVED	ARRIVED	6fce9f62-804c-480a-ba62-c337fa44ace7	Quotation updated: Diagnostic=$65, Labor=$120, Parts=$85. Total=$270.	2026-11-22 11:36:39.579
07d7a7a6-b9ab-4925-a280-fe4d30a41a0f	434a11c9-298a-432a-9454-30ba7fee3ca0	ARRIVED	IN_PROGRESS	6fce9f62-804c-480a-ba62-c337fa44ace7	Disassembled ignition harness; installing new OEM coils.	2026-11-22 11:36:39.664
286f5fe5-3dfc-447e-ae11-d1081d87aadb	434a11c9-298a-432a-9454-30ba7fee3ca0	IN_PROGRESS	COMPLETED	6fce9f62-804c-480a-ba62-c337fa44ace7	Replaced ignition coil pack #3, cleared DTC trouble codes, engine running smoothly at idle.	2026-11-22 11:36:39.69
aecb5e37-09d9-42e7-a854-01c82dc4387a	dd612d8a-26a8-4a09-a02b-eca0f2864e8f	\N	SUBMITTED	4a059e43-c586-45be-b371-252f448bbdd8	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 11:36:39.741
64c88b2e-1ce2-4e23-bda2-579b2a52aedc	dd612d8a-26a8-4a09-a02b-eca0f2864e8f	SUBMITTED	ACCEPTED	6fce9f62-804c-480a-ba62-c337fa44ace7	Dispatch claimed by Hunt High-Performance Roadside	2026-11-22 11:36:39.762
e6035532-1d73-4493-8c47-9abb8d7d787e	dd612d8a-26a8-4a09-a02b-eca0f2864e8f	ACCEPTED	CANCELLED	4a059e43-c586-45be-b371-252f448bbdd8	Cancellation reason: Spare tire located; vehicle changed independently.	2026-11-22 11:36:39.786
841edb0c-4183-421e-98b6-80ae4e7927d9	9553175c-91fb-4c65-9a98-4d69aa929cd8	ARRIVED	IN_PROGRESS	473401ce-0803-422f-8baa-a47de557f84e	Beginning diagnostic disassembly and component servicing.	2026-11-22 11:38:40.824
d00fff75-1ca5-4ddf-895b-e9a25de0077a	9553175c-91fb-4c65-9a98-4d69aa929cd8	IN_PROGRESS	COMPLETED	473401ce-0803-422f-8baa-a47de557f84e	Service finished successfully.	2026-11-22 11:38:44.937
5ed65068-83bb-4c5e-a5ab-e30a589c3387	ed02d6e6-6d00-4e09-a9b5-60af2a5f76db	SUBMITTED	ACCEPTED	473401ce-0803-422f-8baa-a47de557f84e	Dispatch claimed by Apex Mobile Roadside Services	2026-11-22 11:39:05.458
82119971-3f00-46db-a0dd-12c680294a56	ed02d6e6-6d00-4e09-a9b5-60af2a5f76db	ACCEPTED	EN_ROUTE	473401ce-0803-422f-8baa-a47de557f84e	Technician departed base en route to incident site.	2026-11-22 11:39:08.579
da9d02ef-a049-4de0-bf1e-8672fb03088c	ed02d6e6-6d00-4e09-a9b5-60af2a5f76db	EN_ROUTE	ARRIVED	473401ce-0803-422f-8baa-a47de557f84e	Technician arrived on scene at incident coordinates.	2026-11-22 11:39:48.463
b7b4cda3-48f1-411d-9744-d172977527d4	ed02d6e6-6d00-4e09-a9b5-60af2a5f76db	ARRIVED	IN_PROGRESS	473401ce-0803-422f-8baa-a47de557f84e	Beginning diagnostic disassembly and component servicing.	2026-11-22 11:39:52.87
31620fb3-115a-40c9-9321-562cefe187c3	ed02d6e6-6d00-4e09-a9b5-60af2a5f76db	IN_PROGRESS	COMPLETED	473401ce-0803-422f-8baa-a47de557f84e	Service finished successfully.	2026-11-22 11:40:29.461
93206761-9f3d-48b6-a89f-be77e27100be	fda2ccbc-d095-4eda-8b7b-1a80c0424b2d	SUBMITTED	ACCEPTED	473401ce-0803-422f-8baa-a47de557f84e	Dispatch claimed by Apex Mobile Roadside Services	2026-11-22 11:40:33.115
a9676bef-bb2c-474a-a267-80db650ef092	676d0e70-58d8-4342-80bd-69e5410d04d2	SUBMITTED	ACCEPTED	473401ce-0803-422f-8baa-a47de557f84e	Dispatch claimed by Apex Mobile Roadside Services	2026-11-22 11:40:37.043
6b122ab4-f604-4c27-991d-df978a1f5a8a	676d0e70-58d8-4342-80bd-69e5410d04d2	ACCEPTED	EN_ROUTE	473401ce-0803-422f-8baa-a47de557f84e	Technician departed base en route to incident site.	2026-11-22 11:40:39.961
7a08dd91-47f1-4127-b654-5f2519fb8c60	676d0e70-58d8-4342-80bd-69e5410d04d2	EN_ROUTE	ARRIVED	473401ce-0803-422f-8baa-a47de557f84e	Technician arrived on scene at incident coordinates.	2026-11-22 11:40:40.654
1004afb2-f8bd-483e-934e-eb5850821153	676d0e70-58d8-4342-80bd-69e5410d04d2	ARRIVED	IN_PROGRESS	473401ce-0803-422f-8baa-a47de557f84e	Beginning diagnostic disassembly and component servicing.	2026-11-22 11:40:41.261
576f068f-f2b3-4a1a-ac9f-d7ed5e60303c	676d0e70-58d8-4342-80bd-69e5410d04d2	IN_PROGRESS	COMPLETED	473401ce-0803-422f-8baa-a47de557f84e	Service finished successfully.	2026-11-22 11:40:42.362
a7c0d2ca-23cf-4a64-bec0-d8ccc513c2de	fda2ccbc-d095-4eda-8b7b-1a80c0424b2d	ACCEPTED	EN_ROUTE	473401ce-0803-422f-8baa-a47de557f84e	Technician departed base en route to incident site.	2026-11-22 11:41:10.302
25a3cbcb-cdb2-4afa-aa55-a5991208c30c	fda2ccbc-d095-4eda-8b7b-1a80c0424b2d	EN_ROUTE	ARRIVED	473401ce-0803-422f-8baa-a47de557f84e	Technician arrived on scene at incident coordinates.	2026-11-22 11:41:11.3
dee6298b-8224-4538-aff7-3ac60ca77696	fda2ccbc-d095-4eda-8b7b-1a80c0424b2d	ARRIVED	IN_PROGRESS	473401ce-0803-422f-8baa-a47de557f84e	Beginning diagnostic disassembly and component servicing.	2026-11-22 11:41:12.321
6e07228e-37ea-4bc0-aa95-2a2312dadf66	fda2ccbc-d095-4eda-8b7b-1a80c0424b2d	IN_PROGRESS	COMPLETED	473401ce-0803-422f-8baa-a47de557f84e	Service finished successfully.	2026-11-22 11:41:13.398
d8ceb3c9-d0b8-4518-9cd5-417384855daa	3ec2a6c1-9aba-4659-921a-7a24abe3118c	\N	SUBMITTED	a1479806-db8e-432b-a61a-04b1494faf85	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 11:42:14.497
e5c16f11-06eb-411d-a117-93ccc3eefe81	3ec2a6c1-9aba-4659-921a-7a24abe3118c	SUBMITTED	ACCEPTED	473401ce-0803-422f-8baa-a47de557f84e	Dispatch claimed by Apex Mobile Roadside Services	2026-11-22 11:43:23.279
183230f3-4b1c-49dc-b1c5-0efaceac8e83	3ec2a6c1-9aba-4659-921a-7a24abe3118c	ACCEPTED	EN_ROUTE	473401ce-0803-422f-8baa-a47de557f84e	Technician departed base en route to incident site.	2026-11-22 11:43:53.937
1f5ab08c-1955-4aa6-abe8-007128537005	3ec2a6c1-9aba-4659-921a-7a24abe3118c	EN_ROUTE	ARRIVED	473401ce-0803-422f-8baa-a47de557f84e	Technician arrived on scene at incident coordinates.	2026-11-22 11:43:58.606
e1cb6b0c-d9ec-443a-9813-6f09bb47d87f	3ec2a6c1-9aba-4659-921a-7a24abe3118c	ARRIVED	IN_PROGRESS	473401ce-0803-422f-8baa-a47de557f84e	Beginning diagnostic disassembly and component servicing.	2026-11-22 11:44:05.573
5b9eb118-ddea-4994-9622-227e1c94739f	3ec2a6c1-9aba-4659-921a-7a24abe3118c	IN_PROGRESS	COMPLETED	473401ce-0803-422f-8baa-a47de557f84e	Service finished successfully.	2026-11-22 11:44:18.57
d08356a3-4a02-4e4d-84c0-0356d782f9d8	5838ad9f-ab56-4f8f-a973-86f9fd586696	\N	SUBMITTED	935f0c45-76f4-4be0-8fb0-95fb6009b2dd	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 11:55:24.508
80820673-1f98-400b-b0ad-bcc1d43b139d	3eebafd4-0699-42ae-b201-6b0d739f9f1f	\N	SUBMITTED	fe4fed22-b93a-4dfe-b237-66a079f96a50	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 11:55:24.712
40283a8b-9357-4d11-a6e8-3a69ffd5d663	0d5a0499-55d9-4794-bd0c-0b8547a88bb5	\N	SUBMITTED	413f9c28-135a-41dc-9ae3-29f264612e2c	Breakdown reported: BRAKE_SYSTEM_FAILURE. Towing required: true.	2026-11-22 11:55:24.762
6cff8f84-2f8e-4398-aa05-c5d4c097caa6	c2ec6908-1615-441f-a5eb-966c18e8205d	\N	SUBMITTED	eeec89bd-77f1-4b87-b039-63f9778b4621	Breakdown reported: COLLISION_ACCIDENT. Towing required: true.	2026-11-22 11:55:24.772
10c12e55-3eec-41d3-9017-2b6914360e75	ea667a0b-0cd9-44bb-962c-19ed97d32805	\N	SUBMITTED	eeec89bd-77f1-4b87-b039-63f9778b4621	Breakdown reported: BRAKE_SYSTEM_FAILURE. Towing required: true.	2026-11-22 11:55:24.863
37753dee-848d-4aca-a3c0-3198ce79d7fc	e8aab1bb-ad9b-4bdd-9b1a-c42e72146f7c	\N	SUBMITTED	eeec89bd-77f1-4b87-b039-63f9778b4621	Breakdown reported: BATTERY_DEAD_ELECTRICAL. Towing required: false.	2026-11-22 11:55:24.9
e625b8ee-aec9-4497-b85c-1cb1f4ddcb18	ea47faad-e7e7-4914-90ed-34222037345d	\N	SUBMITTED	eeec89bd-77f1-4b87-b039-63f9778b4621	Breakdown reported: TRANSMISSION_ISSUE. Towing required: true.	2026-11-22 11:55:24.932
2148edc2-f1a1-485a-81bd-052146280124	33899de2-c76e-4b45-85bc-e89c257afd89	\N	SUBMITTED	eeec89bd-77f1-4b87-b039-63f9778b4621	Breakdown reported: FUEL_EMPTY_OR_CONTAMINATED. Towing required: false.	2026-11-22 11:55:24.976
fe1a1d5f-00a6-473a-bc59-66e9724b6fb5	ccddb1dc-aa53-47b2-8795-38d73c11d049	\N	SUBMITTED	eeec89bd-77f1-4b87-b039-63f9778b4621	Breakdown reported: OVERHEATING_COOLANT. Towing required: false.	2026-11-22 11:55:25
b5f59bdc-0008-472f-9444-67f58a55892d	3eebafd4-0699-42ae-b201-6b0d739f9f1f	SUBMITTED	ACCEPTED	0c0768ce-b175-46fb-8444-26488c274cba	Dispatch claimed by Downtown Elite Precision	2026-11-22 11:55:25.026
eb0ec4aa-6682-42f4-886a-ec011503eac4	5021bb4b-6cac-4433-99b7-ba950e814865	\N	SUBMITTED	ff166c12-fa96-4a4d-8523-7e1801d01b3f	Breakdown reported: ENGINE_FAILURE. Towing required: true.	2026-11-22 11:55:25.129
4765e824-404e-4d4f-a0cb-0249b5aa77ec	5021bb4b-6cac-4433-99b7-ba950e814865	SUBMITTED	ACCEPTED	93379134-a271-44fa-bf5a-314fe8520bca	Dispatch claimed by Hunt High-Performance Roadside	2026-11-22 11:55:25.168
ea1d995d-27c9-4f61-af6f-d2127281decf	5021bb4b-6cac-4433-99b7-ba950e814865	ACCEPTED	EN_ROUTE	93379134-a271-44fa-bf5a-314fe8520bca	Technician departed garage; en route via arterial highway.	2026-11-22 11:55:25.306
063862ae-1464-4f2d-baec-6cae0574e519	5021bb4b-6cac-4433-99b7-ba950e814865	EN_ROUTE	ARRIVED	93379134-a271-44fa-bf5a-314fe8520bca	Arrived at incident site; positioning emergency safety cones.	2026-11-22 11:55:25.333
1cddc4ae-24bc-4a2f-aaec-f3cd55f5286c	5021bb4b-6cac-4433-99b7-ba950e814865	ARRIVED	ARRIVED	93379134-a271-44fa-bf5a-314fe8520bca	Quotation updated: Diagnostic=$65, Labor=$120, Parts=$85. Total=$270.	2026-11-22 11:55:25.357
3f45e0ba-491b-4a11-b6f7-4c88598f83ff	5021bb4b-6cac-4433-99b7-ba950e814865	ARRIVED	IN_PROGRESS	93379134-a271-44fa-bf5a-314fe8520bca	Disassembled ignition harness; installing new OEM coils.	2026-11-22 11:55:25.446
cde1c84a-2f3e-4ef7-8232-7cbf1b7231f5	5021bb4b-6cac-4433-99b7-ba950e814865	IN_PROGRESS	COMPLETED	93379134-a271-44fa-bf5a-314fe8520bca	Replaced ignition coil pack #3, cleared DTC trouble codes, engine running smoothly at idle.	2026-11-22 11:55:25.472
08657b04-e8cc-4dcc-8931-72958ff8b4aa	aa3b0763-ff80-411c-ad22-c35fd8344202	\N	SUBMITTED	ff166c12-fa96-4a4d-8523-7e1801d01b3f	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 11:55:25.524
b7c29b68-1cc4-4cfe-b4de-2e4b4cc6c9ac	aa3b0763-ff80-411c-ad22-c35fd8344202	SUBMITTED	ACCEPTED	93379134-a271-44fa-bf5a-314fe8520bca	Dispatch claimed by Hunt High-Performance Roadside	2026-11-22 11:55:25.545
1079d4e5-4195-4bb6-835b-a5fb19974719	aa3b0763-ff80-411c-ad22-c35fd8344202	ACCEPTED	CANCELLED	ff166c12-fa96-4a4d-8523-7e1801d01b3f	Cancellation reason: Spare tire located; vehicle changed independently.	2026-11-22 11:55:25.566
6e66d4e0-4dad-4b6e-a78d-cd6268ea4506	8976714b-96d2-4287-b82a-15d56f1c5d19	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: TRANSMISSION_ISSUE. Towing required: true.	2026-11-22 11:56:24.028
399f0851-6201-441d-bf7a-7f8de2a26bf2	e382972d-2908-4540-82bd-2ec090c370f1	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 11:56:31.041
7fa67fb6-bdcf-43fb-99d3-159e5ed8baf0	fa8bf085-e45b-4a14-b1ad-67ca5618629b	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 11:56:35.184
e36f6bee-dc01-4832-bd4a-d4cee9f1090b	61e5fa10-26e1-4a02-9459-5db3e9d74644	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 12:00:47.671
5d1b1b8f-14f8-481b-be12-c8c66f50ddd9	84f3f21a-d1eb-49dc-99b0-98e662f808b0	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 12:02:55.217
c79785c0-a4d8-4230-9ebb-58885e36c48a	84f3f21a-d1eb-49dc-99b0-98e662f808b0	SUBMITTED	ACCEPTED	473401ce-0803-422f-8baa-a47de557f84e	Dispatch claimed by Apex Mobile Roadside Services	2026-11-22 12:03:02.158
f20c7b8b-9225-4e37-bf94-430b51c5f922	c727ae75-5149-4eda-b137-3805e0538533	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: TRANSMISSION_ISSUE. Towing required: true.	2026-11-22 12:03:42.571
baac92c2-bfc2-4499-9c83-25c382243ca5	d7586aa9-cd20-426c-8f45-a5ddfe6ba980	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 12:03:49.438
179392e3-0869-47c1-a620-84514e199dcf	e10cd90e-038b-4282-a97a-20bd7447dec4	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 12:03:53.531
84bc50e8-d9f6-4752-8d0b-ab70b491b2ef	e10cd90e-038b-4282-a97a-20bd7447dec4	SUBMITTED	ACCEPTED	473401ce-0803-422f-8baa-a47de557f84e	Dispatch claimed by Apex Mobile Roadside Services	2026-11-22 12:04:01.471
abd76fea-60bb-4a8a-acee-8008e0ad4e54	d1502ca8-5941-4be1-923e-7050647288bf	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 12:04:05.567
dba28319-4e90-4cda-9e54-1e5ec25a1a03	8803967b-4005-4993-965c-e4c5354f7349	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: true.	2026-11-22 12:04:15.809
fea5b15a-b99d-406b-ac48-b158ceb33c73	8803967b-4005-4993-965c-e4c5354f7349	SUBMITTED	ACCEPTED	473401ce-0803-422f-8baa-a47de557f84e	Dispatch claimed by Apex Mobile Roadside Services	2026-11-22 12:04:19.125
a4799022-87f3-4ee4-8300-042c8ec870a5	8803967b-4005-4993-965c-e4c5354f7349	ACCEPTED	EN_ROUTE	473401ce-0803-422f-8baa-a47de557f84e	Technician departed base en route to incident site.	2026-11-22 12:04:19.217
9031e591-5d54-4ce7-b75c-3d0b85e98a4a	8803967b-4005-4993-965c-e4c5354f7349	ARRIVED	ARRIVED	473401ce-0803-422f-8baa-a47de557f84e	Quotation updated: Diagnostic=$65, Labor=$120, Parts=$75. Total=$260.	2026-11-22 12:04:21.898
b32606b6-7d89-49ad-8b9f-c235f46c9b1c	8803967b-4005-4993-965c-e4c5354f7349	ARRIVED	IN_PROGRESS	473401ce-0803-422f-8baa-a47de557f84e	Beginning diagnostic disassembly and component servicing.	2026-11-22 12:04:23.427
8959737e-357a-480f-a4f7-561d760fcde8	8803967b-4005-4993-965c-e4c5354f7349	EN_ROUTE	ARRIVED	473401ce-0803-422f-8baa-a47de557f84e	Technician arrived on scene at incident coordinates.	2026-11-22 12:04:21.767
653ec5bc-b76c-42e8-b0c1-a1e3b723eae1	8803967b-4005-4993-965c-e4c5354f7349	IN_PROGRESS	COMPLETED	473401ce-0803-422f-8baa-a47de557f84e	Service finished successfully.	2026-11-22 12:04:23.534
06e6f29d-1a3d-4b40-9dda-0a92fef4f19a	509d0dc3-a2fa-46ad-b58c-2af009fdab06	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 12:04:38.695
c5c4d93b-c51b-4325-8bc8-fc77c7941971	509d0dc3-a2fa-46ad-b58c-2af009fdab06	SUBMITTED	ACCEPTED	473401ce-0803-422f-8baa-a47de557f84e	Dispatch claimed by Apex Mobile Roadside Services	2026-11-22 12:04:43.472
d27396bd-7147-4e65-9baa-4aca9b7cccde	509d0dc3-a2fa-46ad-b58c-2af009fdab06	ACCEPTED	EN_ROUTE	473401ce-0803-422f-8baa-a47de557f84e	Technician departed base en route to incident site.	2026-11-22 12:04:43.566
e801899c-afd7-4f57-b4c7-6996e58834eb	509d0dc3-a2fa-46ad-b58c-2af009fdab06	EN_ROUTE	ARRIVED	473401ce-0803-422f-8baa-a47de557f84e	Technician arrived on scene at incident coordinates.	2026-11-22 12:04:43.681
f92fefb9-62ac-4a66-a18d-a67913ffeedb	509d0dc3-a2fa-46ad-b58c-2af009fdab06	ARRIVED	ARRIVED	473401ce-0803-422f-8baa-a47de557f84e	Quotation updated: Diagnostic=$80, Labor=$100, Parts=$60. Total=$240.	2026-11-22 12:04:43.845
4d2896fe-331d-454d-934d-3fc28c8ddc87	509d0dc3-a2fa-46ad-b58c-2af009fdab06	ARRIVED	IN_PROGRESS	473401ce-0803-422f-8baa-a47de557f84e	Beginning diagnostic disassembly and component servicing.	2026-11-22 12:04:45.373
06dc6b75-4157-4f24-97c7-6a2aaf9227c1	509d0dc3-a2fa-46ad-b58c-2af009fdab06	IN_PROGRESS	COMPLETED	473401ce-0803-422f-8baa-a47de557f84e	Service finished successfully.	2026-11-22 12:04:45.488
b2957299-c82a-4970-87ef-d654f8be03f3	e10cd90e-038b-4282-a97a-20bd7447dec4	ACCEPTED	CANCELLED	473401ce-0803-422f-8baa-a47de557f84e	Cancellation reason: far	2026-11-22 12:12:16.566
6acd8645-6c54-43b3-955f-73624e018ebd	6c736916-d02f-4279-8270-49f6f054f32f	\N	SUBMITTED	a1479806-db8e-432b-a61a-04b1494faf85	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 12:13:07.304
3c3058f6-a3f1-4e65-9a79-08dae9f8f302	6c736916-d02f-4279-8270-49f6f054f32f	SUBMITTED	ACCEPTED	473401ce-0803-422f-8baa-a47de557f84e	Dispatch claimed by Apex Mobile Roadside Services	2026-11-22 12:13:42.672
ccacb563-2aa9-41d3-9e1e-3ab7577a6661	6c736916-d02f-4279-8270-49f6f054f32f	ACCEPTED	EN_ROUTE	473401ce-0803-422f-8baa-a47de557f84e	Technician departed base en route to incident site.	2026-11-22 12:14:07.173
5d0d9b3d-29b7-4011-9c5a-807107a204f4	6c736916-d02f-4279-8270-49f6f054f32f	EN_ROUTE	ARRIVED	473401ce-0803-422f-8baa-a47de557f84e	Technician arrived on scene at incident coordinates.	2026-11-22 12:14:21.351
794213e6-2a05-4cdc-b655-8efe57e0a6aa	6c736916-d02f-4279-8270-49f6f054f32f	ARRIVED	IN_PROGRESS	473401ce-0803-422f-8baa-a47de557f84e	Beginning diagnostic disassembly and component servicing.	2026-11-22 12:14:22.933
8e461fb6-4785-465e-b938-ad78f5c1e204	6c736916-d02f-4279-8270-49f6f054f32f	IN_PROGRESS	COMPLETED	473401ce-0803-422f-8baa-a47de557f84e	Service finished successfully.	2026-11-22 12:14:31.485
3ae8393f-a478-4c49-902e-ad8b0311afca	c558ad89-ed30-48c7-bae9-45578a8f3638	\N	SUBMITTED	a1479806-db8e-432b-a61a-04b1494faf85	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 12:16:00.001
45f81531-a846-47b8-9081-f0090b377039	c558ad89-ed30-48c7-bae9-45578a8f3638	SUBMITTED	CANCELLED	a1479806-db8e-432b-a61a-04b1494faf85	Cancellation reason: it solved	2026-11-22 12:16:22.332
da209795-2474-48c0-8cbd-1789cdff6a0e	84f3f21a-d1eb-49dc-99b0-98e662f808b0	ACCEPTED	CANCELLED	473401ce-0803-422f-8baa-a47de557f84e	Cancellation reason: dafasf	2026-11-22 12:16:48.857
b5450658-bc0f-4fe7-a36f-b20996ca21c3	40f85150-f5c1-4abf-97ad-9dc2b347074a	\N	SUBMITTED	a1479806-db8e-432b-a61a-04b1494faf85	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 12:17:08.907
bae67ead-221d-4d9d-a52d-956bf2ab1351	40f85150-f5c1-4abf-97ad-9dc2b347074a	SUBMITTED	ACCEPTED	473401ce-0803-422f-8baa-a47de557f84e	Dispatch claimed by Apex Mobile Roadside Services	2026-11-22 12:17:26.222
d1907865-d87e-4d6f-9c59-e1f7db666109	40f85150-f5c1-4abf-97ad-9dc2b347074a	ACCEPTED	CANCELLED	a1479806-db8e-432b-a61a-04b1494faf85	Cancellation reason: mabchjkakujgfa	2026-11-22 12:17:32.244
91f8c908-bfcf-4630-a628-863dca88eaf3	53a38438-b162-488a-8f21-ed21401c44f5	\N	SUBMITTED	7728fd21-9b94-481c-b739-87c80836528a	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 13:04:37.072
895e113a-ae63-4a2a-aece-666d391baedc	53a38438-b162-488a-8f21-ed21401c44f5	SUBMITTED	ACCEPTED	93c9a1ba-11fc-41ef-bc41-0bba5b0a0634	Dispatch claimed by Downtown Elite Precision	2026-11-22 13:04:37.302
999915da-3c97-42ef-9b2b-1000b5cdffc5	eba2b49f-8548-4d4a-b849-0157c18a0700	\N	SUBMITTED	f34fa6c9-f73a-42c4-9160-85d695a71a2b	Breakdown reported: ENGINE_FAILURE. Towing required: true.	2026-11-22 13:04:37.5
b98248aa-7321-498c-9364-7773fb8427dc	eba2b49f-8548-4d4a-b849-0157c18a0700	SUBMITTED	ACCEPTED	fc725f56-3a5d-4cfb-ae3a-285db185f44e	Dispatch claimed by Hunt High-Performance Roadside	2026-11-22 13:04:37.533
23862cd1-2921-49d4-b21b-50e5bafddcc0	eba2b49f-8548-4d4a-b849-0157c18a0700	ACCEPTED	EN_ROUTE	fc725f56-3a5d-4cfb-ae3a-285db185f44e	Technician departed garage; en route via arterial highway.	2026-11-22 13:04:37.648
9556c482-2cc5-4fea-83e3-4a54cee6fbd5	eba2b49f-8548-4d4a-b849-0157c18a0700	EN_ROUTE	ARRIVED	fc725f56-3a5d-4cfb-ae3a-285db185f44e	Arrived at incident site; positioning emergency safety cones.	2026-11-22 13:04:37.673
34d8fa6e-b402-4893-b730-1c7e92191ba9	eba2b49f-8548-4d4a-b849-0157c18a0700	ARRIVED	ARRIVED	fc725f56-3a5d-4cfb-ae3a-285db185f44e	Quotation updated: Diagnostic=$65, Labor=$120, Parts=$85. Total=$270.	2026-11-22 13:04:37.695
1ab7db65-8df1-4295-ad2e-6055e681dad9	eba2b49f-8548-4d4a-b849-0157c18a0700	ARRIVED	IN_PROGRESS	fc725f56-3a5d-4cfb-ae3a-285db185f44e	Disassembled ignition harness; installing new OEM coils.	2026-11-22 13:04:37.773
09b44b78-1f91-4095-bea8-1ad750fc04b3	eba2b49f-8548-4d4a-b849-0157c18a0700	IN_PROGRESS	COMPLETED	fc725f56-3a5d-4cfb-ae3a-285db185f44e	Replaced ignition coil pack #3, cleared DTC trouble codes, engine running smoothly at idle.	2026-11-22 13:04:37.8
2cd62e65-332a-4404-9188-add1a3a11188	344a61f0-a1c8-4e1c-ad05-ea8a7b093321	\N	SUBMITTED	f34fa6c9-f73a-42c4-9160-85d695a71a2b	Breakdown reported: FLAT_TIRE_WHEEL. Towing required: false.	2026-11-22 13:04:37.848
93c3ba3f-2a90-4e48-9894-a87a496a65bf	344a61f0-a1c8-4e1c-ad05-ea8a7b093321	SUBMITTED	ACCEPTED	fc725f56-3a5d-4cfb-ae3a-285db185f44e	Dispatch claimed by Hunt High-Performance Roadside	2026-11-22 13:04:37.868
0cbd4def-f6f1-4575-8fe3-a9361747627a	344a61f0-a1c8-4e1c-ad05-ea8a7b093321	ACCEPTED	CANCELLED	f34fa6c9-f73a-42c4-9160-85d695a71a2b	Cancellation reason: Spare tire located; vehicle changed independently.	2026-11-22 13:04:37.886
c8c1894e-816e-4b6f-895e-d2707f97dbbb	1dc09508-5a99-4bd9-9954-16155fc4c0cc	\N	SUBMITTED	e22478b0-00a4-44f8-b146-3649213c7a20	Breakdown reported: TRANSMISSION_ISSUE. Towing required: true.	2026-11-22 13:19:19.427
374126cb-1212-4778-ad8b-ab5b8a536a02	2b2b7dc7-cbae-42f9-bc5e-1b5929640f4c	\N	SUBMITTED	a1479806-db8e-432b-a61a-04b1494faf85	Breakdown reported: ENGINE_FAILURE. Towing required: false.	2026-11-22 15:46:06.604
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: vbrs_admin
--

COPY public."User" (id, email, "passwordHash", "fullName", phone, role, "avatarUrl", "isActive", "createdAt", "updatedAt") FROM stdin;
a3a45b01-9ac2-4382-9551-68f1762d33c2	admin@vbrs.local	$2b$12$s1/hBYJ3t7F0VCdBi6W4XOfU0mhNbovRn1jqEh4Jmxz6apr7Qt/pu	System Administrator	+1-555-0100	ADMIN	https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150	t	2026-11-22 06:59:47.72	2026-11-22 06:59:47.72
20c92ae9-cda7-4be7-a444-d9ec67df8fbc	mechanic.marcus@vbrs.local	$2b$12$s1/hBYJ3t7F0VCdBi6W4XOfU0mhNbovRn1jqEh4Jmxz6apr7Qt/pu	Marcus Sterling (Sterling Tow & Repair)	+1-555-0202	MECHANIC	https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150	t	2026-11-22 06:59:47.752	2026-11-22 06:59:47.752
9f992f35-9e68-40b0-b4fa-390233d42ee2	customer.sarah@vbrs.local	$2b$12$s1/hBYJ3t7F0VCdBi6W4XOfU0mhNbovRn1jqEh4Jmxz6apr7Qt/pu	Sarah Connor	+1-555-0302	CUSTOMER	https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150	t	2026-11-22 06:59:47.767	2026-11-22 06:59:47.767
ac3508cb-830b-424e-86b8-303c71462968	m2.customer.1795331509851@vbrs.local	$2b$12$7TWXWr.G7lmbTV83XsmChOhmtUdweOGVfuuAj56VGaVWNkcVe5SMu	David Michael Hasselhoff	+1-555-9999	CUSTOMER	\N	t	2026-11-22 07:11:50.443	2026-11-22 07:11:50.981
bde388dc-1767-4bbc-a67f-22901fc816a8	m2.customer.1795331737103@vbrs.local	$2b$12$4qw3V5PwmPqfXQX0wFTdpeBbAeby1I2i4f9183ZG9xxGyaRJYp2O2	David Michael Hasselhoff	+1-555-9999	CUSTOMER	\N	t	2026-11-22 07:15:37.708	2026-11-22 07:15:38.233
a1479806-db8e-432b-a61a-04b1494faf85	sahid.0777777@gmail.com	$2b$12$yS8s9.f3gVanlxZGv9ajqeCxlgqfm9NoML/7jNQrfS/IIVpQY4caO	Sahid Sk	9989921723	CUSTOMER	\N	t	2026-11-22 07:19:37.835	2026-11-22 07:19:37.835
c1b7fe66-784a-4964-a091-320fa60f5489	m2.customer.1795332738506@vbrs.local	$2b$12$Ei11KQv4J..kFQ6UhH5mE.jH5fRciDEHhoDk0Pe/.l8Sa/0qwTl2a	David Michael Hasselhoff	+1-555-9999	CUSTOMER	\N	t	2026-11-22 07:32:19.081	2026-11-22 07:32:19.618
ddac9980-193c-46b4-80e4-8cf4a1d55d97	m2.customer.1795338320195@vbrs.local	$2b$12$cipZLBHC6KUJrglQD37vX.uc0pcEUMewCmrwKC7Jt6xqHy6mC.EOC	David Michael Hasselhoff	+1-555-9999	CUSTOMER	\N	t	2026-11-22 09:05:21.199	2026-11-22 09:05:22.015
f497148d-d3c5-45be-b500-72020fd86949	audit.mechanic.1795338443181@vbrs.local	$2b$12$dOdPTPbDq8BjGgLdDwCQgeLXRPraEYjbkvN7yTpbjIdU0ybfr0F0G	Audit Mechanic	+1-555-2002	MECHANIC	\N	t	2026-11-22 09:07:23.998	2026-11-22 09:07:23.998
13f321bb-a96d-47dc-84d9-c6e12d82ae2e	audit.userb.1795338443181@vbrs.local	$2b$12$xbYMu0O13RKz5fkkSM3k7Oqun60LPvoMqvIVkuelrjpflb2Wi0LOq	User B	\N	CUSTOMER	\N	t	2026-11-22 09:07:25.192	2026-11-22 09:07:25.192
7a13794a-e022-4261-9b33-6ce596779309	audit.customer.1795338443181@vbrs.local	$2b$12$tLhuC.zJHixBzcca5pWNCOGojUxxH4E5tjZrGUxYlWz0vyM984SS2	Audit Customer Updated	+1-555-7777	CUSTOMER	\N	t	2026-11-22 09:07:23.748	2026-11-22 09:07:25.691
b7eed690-1ed3-46ed-882a-8ff0ca54af9d	audit.mechanic.1795338480610@vbrs.local	$2b$12$4qv6w/tEQVW2AgtrxkYvJuBMatD729Ccc76/Vt1XJWRE4jl9kwDvi	Audit Mechanic	+1-555-2002	MECHANIC	\N	t	2026-11-22 09:08:01.454	2026-11-22 09:08:01.454
cf8c2466-215a-460b-a889-2f47bce8dd02	audit.userb.1795338480610@vbrs.local	$2b$12$3Rwg3c.iHEj0DODUm6SvV.7zM8mI6mmJ1h3//zM7bR3wQfA1p93V6	User B	\N	CUSTOMER	\N	t	2026-11-22 09:08:02.702	2026-11-22 09:08:02.702
c972ff02-c8ee-4306-af30-97d17afddc20	audit.customer.1795338480610@vbrs.local	$2b$12$EmVJfnBq4q7lSitvjBUa3ewT5iGtYvbzbbtaOkN8AZbZoAKru8/x.	Audit Customer Updated	+1-555-7777	CUSTOMER	\N	t	2026-11-22 09:08:01.206	2026-11-22 09:08:03.198
0579580b-0d74-488f-9878-c209546a5c2e	audit.mechanic.1795338760217@vbrs.local	$2b$12$K.g3wtZizMzjhMgUit9Oz.YJ2ZURWfBS5qU5ExnbFga0ewASMbl/m	Audit Mechanic	+1-555-2002	MECHANIC	\N	t	2026-11-22 09:12:41.074	2026-11-22 09:12:41.074
8be98a6e-8e34-4741-8dbc-8105dd3d6b2d	m2.customer.1795338760218@vbrs.local	$2b$12$c7xBvu7cp5Ul.AGBCZrOuuGii/GQWjnRDRnWK3mf9oqm.Ku.2B4Je	David Michael Hasselhoff	+1-555-9999	CUSTOMER	\N	t	2026-11-22 09:12:40.818	2026-11-22 09:12:41.352
5832bba9-40a1-44a9-b92f-c1fd04bfdcf0	audit.userb.1795338760217@vbrs.local	$2b$12$B9KlThnC6T29ZqAkWl590O36hltpZXYLGOSRIykBEryKzpoo.qT0m	User B	\N	CUSTOMER	\N	t	2026-11-22 09:12:42.298	2026-11-22 09:12:42.298
df30359f-fb78-4f77-8c18-936d3d870d43	audit.customer.1795338760217@vbrs.local	$2b$12$5Pbv2x/WMGZXuQmZTNDkV.t3E1VTSPz7gvFuI8GQ5rrFwYVz/i6V6	Audit Customer Updated	+1-555-7777	CUSTOMER	\N	t	2026-11-22 09:12:40.822	2026-11-22 09:12:42.801
50d7979c-85db-4cec-8bb2-83ba29ebae7d	m3.customer.1795339272444@vbrs.local	$2b$12$lGe4I2Y8kwx1.REnqoLNPebfsmiKA6HTEhX3Mdb4KS2XgVx3j1sy2	Roadside Driver A	+1-555-3001	CUSTOMER	\N	t	2026-11-22 09:21:12.8	2026-11-22 09:21:12.8
3bde293e-b15a-438f-82ca-84c742dd02d3	m3.userb.1795339272444@vbrs.local	$2b$12$EXHMtv2sNOZ5yXGM3t8SIekNk5c2lvx/1VdF5EedFWeilQvInLhuu	Roadside Driver B	+1-555-3002	CUSTOMER	\N	t	2026-11-22 09:21:13.06	2026-11-22 09:21:13.06
15a87756-ecb4-4394-8fb7-5555263f9a09	m3.customer.1795339630618@vbrs.local	$2b$12$DTiwvM.0nL31nxrJjd4emO74BMZNG0blzUW.BREj50jUd6LBEoSdS	Roadside Driver A	+1-555-3001	CUSTOMER	\N	t	2026-11-22 09:27:10.944	2026-11-22 09:27:10.944
788ef40a-1c70-448f-9ebf-8d36ef3884e0	m3.userb.1795339630618@vbrs.local	$2b$12$TId7GHemstGo/yZO6uBij.8egem6K7WL11lzLwz2MMzNWqXpTdr3e	Roadside Driver B	+1-555-3002	CUSTOMER	\N	t	2026-11-22 09:27:11.196	2026-11-22 09:27:11.196
abe634c7-837c-4fc9-8d62-af59c97d8fd7	audit.mechanic.1795339631397@vbrs.local	$2b$12$yP6U0QV1bOhmD8T7GAJmWu9zXJBJApBAQIZclukZi/.4UA9FNPy9i	Audit Mechanic	+1-555-2002	MECHANIC	\N	t	2026-11-22 09:27:11.986	2026-11-22 09:27:11.986
77d18c5b-d7f6-4a88-8a79-9d96d9c45dc3	m2.customer.1795339631299@vbrs.local	$2b$12$Zi915/SeP8P9UAOhXOpN9uRhRVT9VVdBquoBWJxopQfzEMZpT8./W	David Michael Hasselhoff	+1-555-9999	CUSTOMER	\N	t	2026-11-22 09:27:11.646	2026-11-22 09:27:12.172
f652e135-854d-4680-9b11-2e96bdc6eda4	audit.userb.1795339631397@vbrs.local	$2b$12$3WDfTnAede7JkR3U.sCn6.FvlNwW9175S6siNV9mrlot8cr3teYS6	User B	\N	CUSTOMER	\N	t	2026-11-22 09:27:13.196	2026-11-22 09:27:13.196
99327fc9-e815-4c83-aeb3-6c3616c22e99	audit.customer.1795339631397@vbrs.local	$2b$12$Fapb/4KhVcvLm2Iv.pkssuihyFzy42/GgoeQccW5vhS3ILladfnCe	Audit Customer Updated	+1-555-7777	CUSTOMER	\N	t	2026-11-22 09:27:11.733	2026-11-22 09:27:13.695
baf36b48-83b6-4d2a-acaf-1145a539c456	m3.edge.custa.1795340650638@vbrs.local	$2b$12$7XnoeRj8rdBHK5jtK/sEN.ZFtQE9l91EJmfc9Ud/fn9k.RKFA5D2.	Edge Customer Alpha	+1-555-4001	CUSTOMER	\N	t	2026-11-22 09:44:11.157	2026-11-22 09:44:11.157
4ddd4a39-70fa-42ed-bfbb-f2c557e01ec5	m3.edge.custb.1795340650638@vbrs.local	$2b$12$kjeexcH4XPGcLAaPgew2nOlWZ1RtByJHoiSqBprHDvJi1nA//zpYW	Edge Customer Beta	+1-555-4002	CUSTOMER	\N	t	2026-11-22 09:44:11.571	2026-11-22 09:44:11.571
c7966587-138d-4fb6-a6d9-b638c3646f4c	m3.edge.mech.1795340650638@vbrs.local	$2b$12$2k07jN/sS/X6QSxCxqi2feai3gJT6dB0pz8nOHBkKxB3UxKdAbLpK	Edge Tech Master	+1-555-4003	MECHANIC	\N	t	2026-11-22 09:44:11.945	2026-11-22 09:44:11.945
19b6e30e-7ab8-4db5-87e5-443815e3d455	m3.edge.custa.1795340704618@vbrs.local	$2b$12$6RMCgJD/X57a/o5a7ciE2eB14ydUPkNnlpfxJWW5QHTbjIc4PP1xm	Edge Customer Alpha	+1-555-4001	CUSTOMER	\N	t	2026-11-22 09:45:05.137	2026-11-22 09:45:05.137
30d6feea-b385-4632-bdf1-274829eada18	m3.edge.custb.1795340704618@vbrs.local	$2b$12$g3qcbocDUq8A3p6ZgNl2u.sxgHNJpuRvc0WguMtz5LjUvDfpIzL66	Edge Customer Beta	+1-555-4002	CUSTOMER	\N	t	2026-11-22 09:45:05.51	2026-11-22 09:45:05.51
29b31365-442a-4af5-9665-541885e6c2ad	m3.edge.mech.1795340704618@vbrs.local	$2b$12$jMUZ33THpODpsymb29pXpOuuNXohicHKWg0xnxLPBbYyOqRkl0pke	Edge Tech Master	+1-555-4003	MECHANIC	\N	t	2026-11-22 09:45:05.863	2026-11-22 09:45:05.863
473401ce-0803-422f-8baa-a47de557f84e	mechanic.alex@vbrs.local	$2b$12$s1/hBYJ3t7F0VCdBi6W4XOfU0mhNbovRn1jqEh4Jmxz6apr7Qt/pu	Alex Vance (Apex Automotive)	+1-555-0201	MECHANIC	https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150	t	2026-11-22 06:59:47.732	2026-11-22 14:12:48.544
4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	m3.edge.custa.1795340739651@vbrs.local	$2b$12$6e.kXt8Z607uSLFfGWhW4.Sh7Iu2QJpr/lV4ioTGFXRUkXTpVTEmC	Edge Customer Alpha	+1-555-4001	CUSTOMER	\N	t	2026-11-22 09:45:40.237	2026-11-22 09:45:40.237
436d667c-cc9f-4294-b2c9-cc95e0cb3d7e	m3.customer.1795340739721@vbrs.local	$2b$12$WLkhokVWRoqeokobscIjXeR8dHIEXLbYNeWyM7NIgR1pmNNSOIlui	Roadside Driver A	+1-555-3001	CUSTOMER	\N	t	2026-11-22 09:45:40.275	2026-11-22 09:45:40.275
d76fafdd-5428-40c5-8632-142aab1c5539	m3.userb.1795340739721@vbrs.local	$2b$12$uiZlZBl8Eqzm70lUCYcJuelwujJ0jvGlKaMwOtPBaIFfEdDfRGmhe	Roadside Driver B	+1-555-3002	CUSTOMER	\N	t	2026-11-22 09:45:40.692	2026-11-22 09:45:40.692
86ac2e5d-4c47-4b60-900b-7d610ad1cdd0	m3.edge.custb.1795340739651@vbrs.local	$2b$12$ssT35w/UKkEp8JFUplA9/umwGkz2thJM3uoM5VoQ7N.kl2OQtYVeq	Edge Customer Beta	+1-555-4002	CUSTOMER	\N	t	2026-11-22 09:45:40.704	2026-11-22 09:45:40.704
2eca2933-96e6-4fa7-bda8-a1d0479de90c	audit.mechanic.1795340739717@vbrs.local	$2b$12$wYdQdH1sxZearictXbj8lOFEaMtvo54BfS4mM4RD8DZJxFyUAjJVi	Audit Mechanic	+1-555-2002	MECHANIC	\N	t	2026-11-22 09:45:40.718	2026-11-22 09:45:40.718
ebf4e83b-ea5a-4e92-bf15-8c58e0b49d3b	m3.edge.mech.1795340739651@vbrs.local	$2b$12$vF4tXqFbFE9lGmvBX3Kg4eWb2KSwbqY0LYrhi6XLhkeRI982tESU6	Edge Tech Master	+1-555-4003	MECHANIC	\N	t	2026-11-22 09:45:41.126	2026-11-22 09:45:41.126
277153e2-5d4b-4efb-8456-e5e9a3e56241	m2.customer.1795340739608@vbrs.local	$2b$12$0tTIsIJ0xmlO.VjY4KKCTewB12mAOSSXTIZJ1JX.tTHqRA3s4chm6	David Michael Hasselhoff	+1-555-9999	CUSTOMER	\N	t	2026-11-22 09:45:40.221	2026-11-22 09:45:41.134
8aa2fb1e-2ce9-4b57-b38c-e182c0320226	audit.userb.1795340739717@vbrs.local	$2b$12$vq6/LWWoPgaM/2ueY9/fEO7qfMqYrd0P2QfOcEtVCA4fW.h5WtVim	User B	\N	CUSTOMER	\N	t	2026-11-22 09:45:42.641	2026-11-22 09:45:42.641
d47dec16-a57d-46ee-b2e9-8e7b594fae34	audit.customer.1795340739717@vbrs.local	$2b$12$P2aJ8qh3RT89FaPn4Wie2OsR0L9acWAu5zDi4XxDy1K/zVEEAkT3e	Audit Customer Updated	+1-555-7777	CUSTOMER	\N	t	2026-11-22 09:45:40.291	2026-11-22 09:45:43.402
8b3cfcfc-79bc-4fc5-b337-656b2fec774d	m4.customer.1795341515927@vbrs.local	$2b$12$6mj8Cee/5M..wLqSwOwHpeob1Qb0wZzh8MrUmTEXmOxcX53qsj9ra	Stranded Motorist M4	+1-555-5001	CUSTOMER	\N	t	2026-11-22 09:58:36.511	2026-11-22 09:58:36.511
23dfa73c-7d5b-46cb-a1f1-cfe57a65b3db	m4.mech1.1795341515927@vbrs.local	$2b$12$02y27cAy0M83C7MqZz.My.nnMKUzOImu6ykiFIbyWg.r.oOEqgGMO	Downtown Tech Master	+1-555-5002	MECHANIC	\N	t	2026-11-22 09:58:36.886	2026-11-22 09:58:36.886
babb78bc-8995-47e3-873b-d77a0c81a425	m4.customer.1795341571967@vbrs.local	$2b$12$wDfIiWUnON73qW3nXpQd3.pPJxS4ERUpgl3CvezTAfAu0Dq2dhkhW	Stranded Motorist M4	+1-555-5001	CUSTOMER	\N	t	2026-11-22 09:59:32.575	2026-11-22 09:59:32.575
838cdf88-b812-44c0-a890-3e53d54aafe1	m4.mech1.1795341571967@vbrs.local	$2b$12$G.19gyCke.9oyV/FK8DhIuT9v14UXgxLFeZLf9O6p8gp4YCUptOFG	Downtown Tech Master	+1-555-5002	MECHANIC	\N	t	2026-11-22 09:59:32.948	2026-11-22 09:59:32.948
f69dd74f-2981-40af-9eea-5269a5fa8340	m4.mech2.1795341571967@vbrs.local	$2b$12$nPNp65IacyDGk2Xbplwy6.O3bGwphyQdq9VWp3WxM7rucXq1o41cK	Far Hills Auto Rescue	+1-555-5003	MECHANIC	\N	t	2026-11-22 09:59:33.326	2026-11-22 09:59:33.326
2dba2391-5f04-4a66-b103-d008daa1d7cb	m4.customer.1795341636004@vbrs.local	$2b$12$7YCuAA5BqBVIJj0LtuCwUe2hvgHPZymqqwZmkXA.fiD5pMA/jSIqO	Stranded Motorist M4	+1-555-5001	CUSTOMER	\N	t	2026-11-22 10:00:36.388	2026-11-22 10:00:36.388
8aeefd6a-535e-4b26-9fb5-74c9ac6e26c3	m4.mech1.1795341636004@vbrs.local	$2b$12$Mk19U5SFxxcVs9IdYhrexeFvDyCWKrO0ABAftT3pOKKoqrzuRt3iC	Downtown Tech Master	+1-555-5002	MECHANIC	\N	t	2026-11-22 10:00:36.64	2026-11-22 10:00:36.64
6d34d30f-9a1e-492c-9781-a28cf649ca03	m4.mech2.1795341636004@vbrs.local	$2b$12$fldVYZtCJ8sPvaDyhEt83.dFE69KVAbXOG6Egjvpyn.Z.gZF3BuPO	Far Hills Auto Rescue	+1-555-5003	MECHANIC	\N	t	2026-11-22 10:00:36.892	2026-11-22 10:00:36.892
65531d90-d509-44d8-8c50-189197b32adf	m4.customer.1795341861470@vbrs.local	$2b$12$3/dkvr4LUDFZJ7roW9OZAu6DJ3UF.hQc6CG/RyIeoOzDBf639bwG6	Stranded Motorist M4	+1-555-5001	CUSTOMER	\N	t	2026-11-22 10:04:22.157	2026-11-22 10:04:22.157
3508ead1-81a7-4452-a2f1-fd5599a1f576	m4.mech1.1795341861470@vbrs.local	$2b$12$0eCMx6wQtvH3P54p85hpduXpaLnbUyxz4WJGStH1lOGNxUuYT70Oy	Downtown Tech Master	+1-555-5002	MECHANIC	\N	t	2026-11-22 10:04:22.615	2026-11-22 10:04:22.615
71be654d-8646-43a1-985d-0f9757ec84b7	m4.mech2.1795341861470@vbrs.local	$2b$12$7cl.AHHTaPfCsc/v3La79eJ2nDw9AIJvhcGHG0gDNPzDtJ2PgBuri	Far Hills Auto Rescue	+1-555-5003	MECHANIC	\N	t	2026-11-22 10:04:23.062	2026-11-22 10:04:23.062
a9541389-845a-425d-9b38-1de039a56cdc	m3.customer.1795341863165@vbrs.local	$2b$12$nfytvI0qViiw5lHAC2ApaO42lmyB3LN6Q9E3laTOxnm.TTIqtvIYW	Roadside Driver A	+1-555-3001	CUSTOMER	\N	t	2026-11-22 10:04:23.876	2026-11-22 10:04:23.876
8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	m3.edge.custa.1795341863222@vbrs.local	$2b$12$pLXUaRFxWhDwr.mmTqveT.w29ob1AQkoovTJC902wPAgQgTCZ8LVy	Edge Customer Alpha	+1-555-4001	CUSTOMER	\N	t	2026-11-22 10:04:23.913	2026-11-22 10:04:23.913
be6ce21c-27af-4c83-838d-9252f2ed8b52	audit.mechanic.1795341863037@vbrs.local	$2b$12$hTZ.O4WXit6sKbtHkIrQeeBslCUfWwySQVxX9J6OySPZMRJKZsdQ2	Audit Mechanic	+1-555-2002	MECHANIC	\N	t	2026-11-22 10:04:24.262	2026-11-22 10:04:24.262
abe608a6-40c5-47bc-98f9-709af459f3a5	m3.userb.1795341863165@vbrs.local	$2b$12$jiaGXrcdksgUQ2cMHADzvuwkcXkyqFxX7DQUWmxLmVZ3B3oCq/qKu	Roadside Driver B	+1-555-3002	CUSTOMER	\N	t	2026-11-22 10:04:24.324	2026-11-22 10:04:24.324
6735a628-9f69-43e8-9647-4859b129ce73	m3.edge.custb.1795341863222@vbrs.local	$2b$12$pQozuqybKQ9PkMeCAey35O1pGNx/L4bmFdVDeC1esk3DtKx/mI6IK	Edge Customer Beta	+1-555-4002	CUSTOMER	\N	t	2026-11-22 10:04:24.349	2026-11-22 10:04:24.349
e7df7f99-0377-492f-baa6-1a71ef06d94b	m2.customer.1795341862987@vbrs.local	$2b$12$PZ3ZxkFjnrDYgsVViK.ovu9FctAJrFRP4Nh3RKyQinNzBQvxSy9de	David Michael Hasselhoff	+1-555-9999	CUSTOMER	\N	t	2026-11-22 10:04:23.716	2026-11-22 10:04:24.62
a40c3731-4a5e-4537-8dc4-3d81ed50c82e	m3.edge.mech.1795341863222@vbrs.local	$2b$12$Qm5MojJD3akW8wosSLf5i.3B.c13OSsDHgfvKg5LzkEFGtLRfNsYG	Edge Tech Master	+1-555-4003	MECHANIC	\N	t	2026-11-22 10:04:24.804	2026-11-22 10:04:24.804
002fc4a3-6450-4661-8aac-be73b003405b	audit.userb.1795341863037@vbrs.local	$2b$12$RyclQfC8KG3cvcOa3bZfneXgtXJtGXNWRlU9APMS7MCZMwwAZussG	User B	\N	CUSTOMER	\N	t	2026-11-22 10:04:26.225	2026-11-22 10:04:26.225
4d0a14bc-7faa-4a5d-b04d-3f0d657598d4	audit.customer.1795341863037@vbrs.local	$2b$12$GCwDpbv246NF1Uwm8yCqrOcsrshya49U7CVTpLltzpDwVPdXCYRam	Audit Customer Updated	+1-555-7777	CUSTOMER	\N	t	2026-11-22 10:04:23.794	2026-11-22 10:04:27.037
b492f8a7-29a4-4012-a173-bb1cf5135319	m5.cust1.1795343229953@vbrs.local	$2b$12$92P9ZinQWCbnWugIF0rVGePhv.X40QCI6Hz3b5J0lvc3Ise9waS2e	Marcus Vance (Customer 1)	+1-555-0191	CUSTOMER	\N	t	2026-11-22 10:27:10.324	2026-11-22 10:27:10.324
7ec8d5ac-2f2c-4bee-a45c-cbe4db28152f	m5.cust2.1795343229953@vbrs.local	$2b$12$VK3D5XOR8blRv9p96cfGheA/MbUtehNg7zfRwhzlASQR86wn5I87y	Diana Prince (Customer 2)	+1-555-0192	CUSTOMER	\N	t	2026-11-22 10:27:10.572	2026-11-22 10:27:10.572
9ad0fc29-8daf-4688-925e-9fa71d6a2e80	m5.cust1.1795343253901@vbrs.local	$2b$12$A2weqaI1qOFt4599bWTCTuNU6n26l4bBA3oKhzi3zxc/XmCZzojPy	Marcus Vance (Customer 1)	+1-555-0191	CUSTOMER	\N	t	2026-11-22 10:27:34.263	2026-11-22 10:27:34.263
7090b34f-dafd-4c68-965c-71bb401de60d	m5.cust2.1795343253901@vbrs.local	$2b$12$BEOdLwIFBL94F52AAk/vM.vdRs.2H89hrLZSDiapAu4HBEdQhPqze	Diana Prince (Customer 2)	+1-555-0192	CUSTOMER	\N	t	2026-11-22 10:27:34.508	2026-11-22 10:27:34.508
8ad6b40d-ab52-471f-b6dc-4dcc2d132efe	m5.mech1.1795343253901@vbrs.local	$2b$12$.Pb.wyyl4xr8HT/vhZOQregTMmU0ItKOcANLnIVYlkOoIC4ao3.me	Ethan Hunt (Lead Tech)	+1-555-0193	MECHANIC	\N	t	2026-11-22 10:27:34.746	2026-11-22 10:27:34.746
99cb03ac-7b72-4f0c-bb2f-b153c954e67b	m5.mech2.1795343253901@vbrs.local	$2b$12$NawYAd11c.o0GH2GjiLfSeNnGp.Vo1ok4132GjEZPv6MoUFFo0cLu	Lucas Grey (Tech 2)	+1-555-0194	MECHANIC	\N	t	2026-11-22 10:27:34.992	2026-11-22 10:27:34.992
07e2bb34-05fe-462f-9b45-1ac77a36ee96	m5.admin.1795343253901@vbrs.local	$2b$12$rSu1PyT2hey/AjF6LkKgb.EvlOWTYRGBw04c/sm8PT0ZyzoCmC1bm	Command Admin	+1-555-0195	ADMIN	\N	t	2026-11-22 10:27:35.226	2026-11-22 10:27:35.226
201144dc-4d12-4765-8873-8573ebc70566	m5.cust1.1795343269323@vbrs.local	$2b$12$k9mXqQ54KB/QrmxDHRDvCuDnp9I15bmqG0WL8PmRtX1Htm474QeUG	Marcus Vance (Customer 1)	+1-555-0191	CUSTOMER	\N	t	2026-11-22 10:27:49.754	2026-11-22 10:27:49.754
1b76c709-fd68-4cca-b699-3ce4793290d1	m5.cust2.1795343269323@vbrs.local	$2b$12$ywlNcwZedRTybpQV.787Oet.37xnpng746fou9j3mNHnQhqd0xMSS	Diana Prince (Customer 2)	+1-555-0192	CUSTOMER	\N	t	2026-11-22 10:27:50.04	2026-11-22 10:27:50.04
58ea9816-d0a5-42ae-92d8-55f32ab1135f	m5.mech1.1795343269323@vbrs.local	$2b$12$EH49IQhyYa0fA7FTKBXgF.NNUna8sORR6T2spJ1.XLmxTRxkS7mEC	Ethan Hunt (Lead Tech)	+1-555-0193	MECHANIC	\N	t	2026-11-22 10:27:50.325	2026-11-22 10:27:50.325
020de9be-8c9a-4232-a522-39dfbf87cf9c	m4.customer.1795343270142@vbrs.local	$2b$12$eUx0Ryhn4nQkUAhKOn8jIudg0cSc.6qiAsJ93ddrH.PUDfAi.C0mG	Stranded Motorist M4	+1-555-5001	CUSTOMER	\N	t	2026-11-22 10:27:50.593	2026-11-22 10:27:50.593
90810c7b-ed32-4e65-993f-2371c000eb9b	m5.mech2.1795343269323@vbrs.local	$2b$12$dPcQE/K/l77fOoZ7x8iDNewC7RFcE8F5nFreEGwlW2vkSVz1THpWC	Lucas Grey (Tech 2)	+1-555-0194	MECHANIC	\N	t	2026-11-22 10:27:50.598	2026-11-22 10:27:50.598
4fb4b922-a2e7-4d24-9e81-1bae59ab792b	m3.customer.1795343270266@vbrs.local	$2b$12$ikv6GZ7MWfnNKHjOZ.W./el9HUs/0PNRb0o.koB7Ul6KeUG8hQQv6	Roadside Driver A	+1-555-3001	CUSTOMER	\N	t	2026-11-22 10:27:50.697	2026-11-22 10:27:50.697
e05d0c61-e1ae-4921-8453-3dc06525dc08	m3.edge.custa.1795343270316@vbrs.local	$2b$12$WTKszcSwtXgNZKredXjN2OIRilrto1UCZDuoyUQL60jchq85munCi	Edge Customer Alpha	+1-555-4001	CUSTOMER	\N	t	2026-11-22 10:27:50.724	2026-11-22 10:27:50.724
d2a30eee-6528-4896-97ac-c1b16dbcd28b	m5.admin.1795343269323@vbrs.local	$2b$12$m8FeTcVhVigMSDbgNDOx6.g9FAmcpumWdW0OGXN2j9LWM1lTvdHEO	Command Admin	+1-555-0195	ADMIN	\N	t	2026-11-22 10:27:50.845	2026-11-22 10:27:50.845
ab64f7e0-5ae5-4282-826f-e08e48227f23	m4.mech1.1795343270142@vbrs.local	$2b$12$5ObA.l32Q79WCisvmi3jpe60V2YshLMT0nxrkChV1xq.eTRxv0LoS	Downtown Tech Master	+1-555-5002	MECHANIC	\N	t	2026-11-22 10:27:50.848	2026-11-22 10:27:50.848
abdc3f09-7dcb-4b9d-be66-455330a09529	m3.userb.1795343270266@vbrs.local	$2b$12$/f0lpguRSfstHRoq1pveDesqjKVNZfWIMxXXPQdQLYbvIQk1NPH1O	Roadside Driver B	+1-555-3002	CUSTOMER	\N	t	2026-11-22 10:27:50.962	2026-11-22 10:27:50.962
29c945b2-a680-4d39-9f8d-ee67d94c8272	audit.mechanic.1795343270278@vbrs.local	$2b$12$yaCMTOto.6TXd0KslarG5en64rIU.sW.c0fRrSkcY6UDruh96XMh2	Audit Mechanic	+1-555-2002	MECHANIC	\N	t	2026-11-22 10:27:50.978	2026-11-22 10:27:50.978
87f1f769-abfe-4f96-b595-46a1bc413388	m3.edge.custb.1795343270316@vbrs.local	$2b$12$6ERVWj7Rd7gKZAJbk.8E2.qhYmdc.y40B2LRITPxyhiIbj6lxG3Du	Edge Customer Beta	+1-555-4002	CUSTOMER	\N	t	2026-11-22 10:27:50.98	2026-11-22 10:27:50.98
92ec996c-90a3-4cd5-a1bf-0861cd595b15	m4.mech2.1795343270142@vbrs.local	$2b$12$8rxnmTAShs3oRXEB71X.WOunSUkkkpH522lgDq/CKEYe6Mmcvwys.	Far Hills Auto Rescue	+1-555-5003	MECHANIC	\N	t	2026-11-22 10:27:51.12	2026-11-22 10:27:51.12
3d1bfe42-4c49-425d-aa93-9f8e9c52b45f	m2.customer.1795343270129@vbrs.local	$2b$12$FAQ3Z2kGv2or31OWieSvTO8QLvabmdvmO41GJsjBIdllnkTHhv/lG	David Michael Hasselhoff	+1-555-9999	CUSTOMER	\N	t	2026-11-22 10:27:50.599	2026-11-22 10:27:51.16
7407b151-116c-44be-bd28-20d2ea8e9da2	m3.edge.mech.1795343270316@vbrs.local	$2b$12$/qU7vGE.zVUO5Lxy.k32N.0RQYyAGRZ1VqYXI6vO2.IxC/hyIifjq	Edge Tech Master	+1-555-4003	MECHANIC	\N	t	2026-11-22 10:27:51.237	2026-11-22 10:27:51.237
ecd14194-d465-4297-b876-4c714881b790	audit.userb.1795343270278@vbrs.local	$2b$12$GQyK/qjegxHSG510yt2wJOfgUbHWIS.6q16gdtfvje0NUENX7z/qm	User B	\N	CUSTOMER	\N	t	2026-11-22 10:27:52.201	2026-11-22 10:27:52.201
2453cf81-de2b-42e1-9cbd-394d92e735f6	audit.customer.1795343270278@vbrs.local	$2b$12$lSVWsnck8YugT2QCpjIEwe5K6nBzuYagsetvcl91eKcYzG6IuXFsO	Audit Customer Updated	+1-555-7777	CUSTOMER	\N	t	2026-11-22 10:27:50.717	2026-11-22 10:27:52.703
b347ca38-e44c-42ac-a846-63d4b6c28e3a	m3.edge.custa.1795344141577@vbrs.local	$2b$12$8fylGxt.TZzkqyq0eOZi8OipqI9LI3ekFtLp709L.LnoMyStIKbd2	Edge Customer Alpha	+1-555-4001	CUSTOMER	\N	t	2026-11-22 10:42:22.044	2026-11-22 10:42:22.044
a17cea7b-22a1-44e0-a813-5f16ce79bc69	m4.customer.1795344141614@vbrs.local	$2b$12$XMtA.BA0Enm58wt1LJYIyOj310PYukCLhdTDJ9DEVr49nyvqNA4Sq	Stranded Motorist M4	+1-555-5001	CUSTOMER	\N	t	2026-11-22 10:42:22.064	2026-11-22 10:42:22.064
e51a5048-6c2d-466a-ae62-613927b40269	m3.customer.1795344141625@vbrs.local	$2b$12$Wa8NgOWUVZrMH8ydqDXR3.D08GPz7LnA7WkI3s6Y2AAfJjV0ZCQGm	Roadside Driver A	+1-555-3001	CUSTOMER	\N	t	2026-11-22 10:42:22.077	2026-11-22 10:42:22.077
24d8704e-eebc-4c21-986b-d85a1ed5a92a	m5.cust1.1795344141649@vbrs.local	$2b$12$ckvI/bVB6.LJNoejl4u3l.gq8TUBhfFQ7NbgizuvLEUFMyXAqMy7q	Marcus Vance (Customer 1)	+1-555-0191	CUSTOMER	\N	t	2026-11-22 10:42:22.088	2026-11-22 10:42:22.088
87dac236-69b8-470f-b92f-efef6a6e2d67	m3.edge.custb.1795344141577@vbrs.local	$2b$12$mhHEfVUfRXbPM1XChQPu7.1zXDWjY9AF7FmXcWSyH2ZiVlByaYNnW	Edge Customer Beta	+1-555-4002	CUSTOMER	\N	t	2026-11-22 10:42:22.32	2026-11-22 10:42:22.32
17f8c042-b632-48cf-8e97-53a057ab03fd	audit.mechanic.1795344141549@vbrs.local	$2b$12$bUctJ434LUAQC0hmEk.c/OBHEkNjP7TaypLDPfpdF1P.Yvaj.1YS2	Audit Mechanic	+1-555-2002	MECHANIC	\N	t	2026-11-22 10:42:22.327	2026-11-22 10:42:22.327
7469c3f3-91d7-4857-ad8a-a6e99f73a521	m3.userb.1795344141625@vbrs.local	$2b$12$7wfLKzQqF3Y05GHMCOtVb.UjSD0cKgqlS4d8/FozGvh5NMDRjlm3G	Roadside Driver B	+1-555-3002	CUSTOMER	\N	t	2026-11-22 10:42:22.343	2026-11-22 10:42:22.343
6dffcd9a-0d48-4863-a865-8f96c2680bf5	m4.mech1.1795344141614@vbrs.local	$2b$12$XD/TjljX1arC0QIPPN8E5.WBYl/CaZ/vpuCB39oQU4Q1R9zINA/Sa	Downtown Tech Master	+1-555-5002	MECHANIC	\N	t	2026-11-22 10:42:22.347	2026-11-22 10:42:22.347
bfe64bf0-bb93-405b-a336-a1453240ac67	m5.cust2.1795344141649@vbrs.local	$2b$12$w2ALZHQH.bkU/1CxsQItCOaKJsuA.G6OqUhzK1f3qAcW6AzmwbWSu	Diana Prince (Customer 2)	+1-555-0192	CUSTOMER	\N	t	2026-11-22 10:42:22.37	2026-11-22 10:42:22.37
885f49f3-4df5-48f9-aeaf-9e7b29015b02	m3.edge.mech.1795344141577@vbrs.local	$2b$12$3Vc5.9FIyV.p93C.KJ5Q7OrZbq25.jAyTzJt6e5gwgcVhGZi92ioS	Edge Tech Master	+1-555-4003	MECHANIC	\N	t	2026-11-22 10:42:22.582	2026-11-22 10:42:22.582
568f1967-6055-40f4-bd07-97ee79559948	m4.mech2.1795344141614@vbrs.local	$2b$12$PqqUKOBMm.B9PIdjiJOxWegDiEQRHV1oueuqrbWiN3LTOU0o8ZfpC	Far Hills Auto Rescue	+1-555-5003	MECHANIC	\N	t	2026-11-22 10:42:22.616	2026-11-22 10:42:22.616
fd109b4c-5829-497b-8da6-252d426b4a4d	m5.mech1.1795344141649@vbrs.local	$2b$12$e52dQkO3CLEQb3V3sj5Kyu1KMwkHF2/RT3G8CzFC/ic5/SGF5sXHO	Ethan Hunt (Lead Tech)	+1-555-0193	MECHANIC	\N	t	2026-11-22 10:42:22.625	2026-11-22 10:42:22.625
eada0765-6f29-428a-9687-0f1bdf9aaacb	m2.customer.1795344141629@vbrs.local	$2b$12$5qWq9Z2HcW5X2gfRShVfUumS/a1Os1VU.MdMJKvadXH6W.yASEVFq	David Michael Hasselhoff	+1-555-9999	CUSTOMER	\N	t	2026-11-22 10:42:22.106	2026-11-22 10:42:22.701
754478bf-6a8e-4cc5-9aa9-f783e59d909a	m5.mech2.1795344141649@vbrs.local	$2b$12$yFfD8RsR0oki9CZ8lg5CnOtIiVUbvWuQUx/yPgRuzBmemNTfWDWjC	Lucas Grey (Tech 2)	+1-555-0194	MECHANIC	\N	t	2026-11-22 10:42:22.897	2026-11-22 10:42:22.897
cd86f585-75aa-49d3-ba65-a6fc616c5d70	m5.admin.1795344141649@vbrs.local	$2b$12$py8TGVCkjGvbdAqWHUJfQe/wM6tiEhLQ4glIK9/dJpVVaHc3NlY0.	Command Admin	+1-555-0195	ADMIN	\N	t	2026-11-22 10:42:23.135	2026-11-22 10:42:23.135
309fc985-8fee-44cf-8b3f-7c963665f95a	audit.userb.1795344141549@vbrs.local	$2b$12$cMfCGDpwhWOB05lOKDIEMuta3BKAhacaWUvH9bZWbeSBL1KfCbeqe	User B	\N	CUSTOMER	\N	t	2026-11-22 10:42:23.582	2026-11-22 10:42:23.582
9979cb67-e488-44d8-b0df-569a81cec64d	audit.customer.1795344141549@vbrs.local	$2b$12$IsGwl5oTWeCRhm3mzd4RX.BL4B.cDfmtyEjTDHYmTpjQYPzPAIl.S	Audit Customer Updated	+1-555-7777	CUSTOMER	\N	t	2026-11-22 10:42:22.047	2026-11-22 10:42:24.1
d8bcfbbb-5b9c-41f3-8c41-e601d5e105c3	m6.admin.1795345105502@vbrs.local	$2b$12$A.JGJy8KD9/v9MCQ.VcLsO.Qy2Ix/HnSeMawKCt6D9NGYbvDtK7am	Chief Inspector Kane	+1-555-0800	ADMIN	\N	t	2026-11-22 10:58:25.873	2026-11-22 10:58:25.873
20e961e5-4364-4013-ac83-b3cdac902909	m6.customer.1795345105502@vbrs.local	$2b$12$gYiZPppfP/1btI58eHqKmeFOObtRkqx4PK3RagVea3vH0hV9yTyme	Eleanor Sterling	+1-555-0801	CUSTOMER	\N	t	2026-11-22 10:58:26.12	2026-11-22 10:58:26.12
912d1cb2-475d-4b50-8a70-7c6efd34617e	m6.pending.mech.1795345105502@vbrs.local	$2b$12$Y/fZKi/z4I/jGE0aNL9LZ.VB6Us2d0psHcu7FNmpFKhA5B1OcpMDy	Derrick Moss	+1-555-0802	MECHANIC	\N	t	2026-11-22 10:58:26.355	2026-11-22 10:58:26.355
4c460def-df40-44ae-85e2-abc656c5c0da	m6.admin.1795345132328@vbrs.local	$2b$12$9/h4M02C6ajWa2V6jQbhXeN0gzJj/NpHhs.32mpxS8GrU6EhuGFnm	Chief Inspector Kane	+1-555-0800	ADMIN	\N	t	2026-11-22 10:58:52.693	2026-11-22 10:58:52.693
a180a88c-5a9a-4731-add7-99d767857c44	m6.customer.1795345132328@vbrs.local	$2b$12$zHdd5VLb7eFYl7AhpktMcOQNUyeh3X9rycMos4LCGIzC3GnFpmo/O	Eleanor Sterling	+1-555-0801	CUSTOMER	\N	t	2026-11-22 10:58:52.939	2026-11-22 10:58:52.939
6f799c5a-2d5d-417b-9baa-f7b0c803557a	m6.pending.mech.1795345132328@vbrs.local	$2b$12$Gf8FwAH16EAEoKycZHlXseIDagQ64fRtV7jtBBOcv0ZygW.nFBHnS	Derrick Moss	+1-555-0802	MECHANIC	\N	t	2026-11-22 10:58:53.175	2026-11-22 10:58:53.175
02768d0a-f84d-490d-9480-615e95224db6	m6.admin.1795345149818@vbrs.local	$2b$12$ke5dqE8sQI7F1/udZ640lONgOxRZsGkfpIrp.//pdxvAfBuRo9zT.	Chief Inspector Kane	+1-555-0800	ADMIN	\N	t	2026-11-22 10:59:10.278	2026-11-22 10:59:10.278
2ae75f04-e851-4d24-81dc-67588ba24232	m6.customer.1795345149818@vbrs.local	$2b$12$gM5JvNyXv9lMYGfJfDhmqeI3ElxwPWeMaef6F0c5fZPHsgeRgXMvy	Eleanor Sterling	+1-555-0801	CUSTOMER	\N	t	2026-11-22 10:59:10.58	2026-11-22 10:59:10.58
6f863f00-571b-44cc-a075-aa555329997f	m6.pending.mech.1795345149818@vbrs.local	$2b$12$JsS5ed77j3XeVuIAQaN9guVtmGMVS6F5GTQQms8HznoMDHSsROpqC	Derrick Moss	+1-555-0802	MECHANIC	\N	t	2026-11-22 10:59:10.87	2026-11-22 10:59:10.87
49c5925b-fda2-4bcc-b6b0-87b387231f58	m4.customer.1795345150708@vbrs.local	$2b$12$zxTydGVVN/iRLcajfKaslesHFoH/x9vxxtpot55JITL7LGxKNUJGi	Stranded Motorist M4	+1-555-5001	CUSTOMER	\N	t	2026-11-22 10:59:11.168	2026-11-22 10:59:11.168
23e55200-8e86-4e87-92e2-b55e228b92f3	m3.customer.1795345150749@vbrs.local	$2b$12$Qr0m.PqHb3e7y5LX.Cpl6.g3ktbQ6QF1r35RnVZXQbp60Ih8J.wPO	Roadside Driver A	+1-555-3001	CUSTOMER	\N	t	2026-11-22 10:59:11.21	2026-11-22 10:59:11.21
11947c9d-6f0f-425d-b26d-1cd07a25138a	m5.cust1.1795345150789@vbrs.local	$2b$12$HIyNDt/3KdYUc.ZbiJPCHOTzK.CXFpbXTn2qb7B5juYXNPG.JQyZy	Marcus Vance (Customer 1)	+1-555-0191	CUSTOMER	\N	t	2026-11-22 10:59:11.217	2026-11-22 10:59:11.217
245a9356-c816-4507-8269-0fc18dd346f9	m3.edge.custa.1795345150764@vbrs.local	$2b$12$ZsqjZRKnSzxLsMrhPYPZouJWd3yFdVT.urbPMZHm4rof8X19ebwdS	Edge Customer Alpha	+1-555-4001	CUSTOMER	\N	t	2026-11-22 10:59:11.223	2026-11-22 10:59:11.223
c1c59c54-9a85-4892-957a-65df00abe10f	audit.mechanic.1795345150583@vbrs.local	$2b$12$sIkS/BZts3/C9hM1IUD5sOTzaPMdW0TdsiFdE17L/TcLMXtxvEz3W	Audit Mechanic	+1-555-2002	MECHANIC	\N	t	2026-11-22 10:59:11.336	2026-11-22 10:59:11.336
459fd1f2-01ce-465d-b584-90ce7e7c8297	m4.mech1.1795345150708@vbrs.local	$2b$12$f3LjASbCwqvqKNhm2GyqPODiK0BrE99Yc0.9IkZLuIbY4mIEryR7m	Downtown Tech Master	+1-555-5002	MECHANIC	\N	t	2026-11-22 10:59:11.423	2026-11-22 10:59:11.423
0e56d598-d475-40e8-9e5e-8a18e9c9c26c	m3.userb.1795345150749@vbrs.local	$2b$12$dGO0kBXm4beTgM./rJQS0OQOdOQdV5hnITxvm9bmEDUtE1QL9wQ4u	Roadside Driver B	+1-555-3002	CUSTOMER	\N	t	2026-11-22 10:59:11.462	2026-11-22 10:59:11.462
a8f2696e-55dc-4a9b-97f3-8bffbcf18c45	m5.cust2.1795345150789@vbrs.local	$2b$12$/m6tCZDibY7kvgZPiHO6NO12V3lTRfqRbBBstcrRgk8zhi1WGyDaO	Diana Prince (Customer 2)	+1-555-0192	CUSTOMER	\N	t	2026-11-22 10:59:11.465	2026-11-22 10:59:11.465
e4414a47-df1f-4ad5-9049-bf14c3ed41cc	m3.edge.custb.1795345150764@vbrs.local	$2b$12$s7DE/wojkwzZEf5QsJVbyu4huuUMqzdd//U6kmrMObX8JIvcj0dsi	Edge Customer Beta	+1-555-4002	CUSTOMER	\N	t	2026-11-22 10:59:11.476	2026-11-22 10:59:11.476
b342c509-acd4-40e2-9a9e-a576fa6e5061	m2.customer.1795345150616@vbrs.local	$2b$12$uaJPcMmOsPqhGYeU8r1nTOC/qCQO.iqLrixfieisIMfN7uE6gqhmS	David Michael Hasselhoff	+1-555-9999	CUSTOMER	\N	t	2026-11-22 10:59:11.103	2026-11-22 10:59:11.664
14397d2c-11bd-4647-babe-a86165af58d4	m4.mech2.1795345150708@vbrs.local	$2b$12$BfRzsHc6EdW2qVz/3HzDxeZ/wT/wfZ.P6nFBJSzJI78Uop7EUeFLe	Far Hills Auto Rescue	+1-555-5003	MECHANIC	\N	t	2026-11-22 10:59:11.684	2026-11-22 10:59:11.684
04a4b6cb-3c82-45bb-acab-d78e0713971a	m5.mech1.1795345150789@vbrs.local	$2b$12$InTNurYIuNcFW1YV8C2S6.jPK7kLsqiqnE7jXdSaxPnc74UyQ.m.W	Ethan Hunt (Lead Tech)	+1-555-0193	MECHANIC	\N	t	2026-11-22 10:59:11.718	2026-11-22 10:59:11.718
e840f0bf-ae92-4006-aa6a-de7fc0c1873d	m3.edge.mech.1795345150764@vbrs.local	$2b$12$oHQD9VraBcvL.LkHr0Io0u7ONLrIjWfvjvjAlNYycHVewSPylcU82	Edge Tech Master	+1-555-4003	MECHANIC	\N	t	2026-11-22 10:59:11.723	2026-11-22 10:59:11.723
d3f75e7f-79cd-4f70-8bf5-d71a46c0c651	m5.mech2.1795345150789@vbrs.local	$2b$12$emV9X0lTtOipDfp6ryvLMOET0pX.2ct6/2JFDRv11Mx6MECdK6ETG	Lucas Grey (Tech 2)	+1-555-0194	MECHANIC	\N	t	2026-11-22 10:59:11.982	2026-11-22 10:59:11.982
35de3760-92fd-4769-9d8c-11acf299ce83	m5.admin.1795345150789@vbrs.local	$2b$12$dfFKIGdeVr3PhGfUP2y0m.pyzrmau2BCEsQu3o.scxD.7hTgkPMCi	Command Admin	+1-555-0195	ADMIN	\N	t	2026-11-22 10:59:12.225	2026-11-22 10:59:12.225
1e062702-c6de-4826-a848-4c15c3b0a27c	audit.userb.1795345150583@vbrs.local	$2b$12$TVb53F3KOhP.IcE8XPv0TevtLihuMC64UQJgBJlDjsDUU68h/n1xK	User B	\N	CUSTOMER	\N	t	2026-11-22 10:59:12.564	2026-11-22 10:59:12.564
c93c737a-04f0-431c-827c-5f260c78cf87	audit.customer.1795345150583@vbrs.local	$2b$12$fHr7cA5VAQwNUl3M3llTYuHLMhcMyfzMAlXvOLSPMtYfqAELQiYpu	Audit Customer Updated	+1-555-7777	CUSTOMER	\N	t	2026-11-22 10:59:11.065	2026-11-22 10:59:13.066
4bc6bd4b-da8e-4372-8bac-0333b1e85ab1	m4.customer.1795345590894@vbrs.local	$2b$12$FhzdGwY/ezrGYM7PZ4sWTeJggnw9sC1LuPx2f6J0n1qEqrUBwFLpK	Stranded Motorist M4	+1-555-5001	CUSTOMER	\N	t	2026-11-22 11:06:31.423	2026-11-22 11:06:31.423
1302fef8-4b27-4105-8596-a34489c6c8a0	m5.cust1.1795345590904@vbrs.local	$2b$12$xjS3rYuCAreRzjhYnvj2xOipsPUVbRMea5.1vtCcgtY2xbHgK1zSq	Marcus Vance (Customer 1)	+1-555-0191	CUSTOMER	\N	t	2026-11-22 11:06:31.427	2026-11-22 11:06:31.427
52982a88-12e7-4a4c-aafc-6534a8542ddb	m6.admin.1795345591025@vbrs.local	$2b$12$T15C1UigB1w9aJDk4qyG5.3QgGCBkU6gmzDnIBUTi3jPRTzdQDY4m	Chief Inspector Kane	+1-555-0800	ADMIN	\N	t	2026-11-22 11:06:31.501	2026-11-22 11:06:31.501
6f0c5a39-62c6-49b0-9305-3747a819cf83	m3.customer.1795345591025@vbrs.local	$2b$12$VXwDm.97uu9eyac/2u2n2ututYHoIFNCTqqivTkHWN0fYN650SG4O	Roadside Driver A	+1-555-3001	CUSTOMER	\N	t	2026-11-22 11:06:31.527	2026-11-22 11:06:31.527
cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	m3.edge.custa.1795345591031@vbrs.local	$2b$12$OAFT7wciTKJyyF72k6ctcuC6PxfMXRNbIFbPiDGBpxSW5ytyJfCsa	Edge Customer Alpha	+1-555-4001	CUSTOMER	\N	t	2026-11-22 11:06:31.552	2026-11-22 11:06:31.552
29db8df8-1b56-42f1-9da5-e687727e448e	m4.mech1.1795345590894@vbrs.local	$2b$12$WGXCt7fJrQQvokOHBa/3BePTaT3x/ufiDivfk8mCmfOjsC5/xDjeO	Downtown Tech Master	+1-555-5002	MECHANIC	\N	t	2026-11-22 11:06:31.721	2026-11-22 11:06:31.721
6eb0337a-0d67-46c4-8936-66203ebb5009	audit.customer.1795345591012@vbrs.local	$2b$12$djuP/b9tWVq/JDI6Y5qxke84fe1OnFbDAEXJXjh/IM9fbyOAPhaFa	Audit Customer Updated	+1-555-7777	CUSTOMER	\N	t	2026-11-22 11:06:31.538	2026-11-22 11:06:33.66
7b0dbcf4-d748-4a20-b6b8-1429d8471663	m5.cust2.1795345590904@vbrs.local	$2b$12$y0mUS.7kujZaz/V8lhVfTe/hc8yW5V00PsHVnInT6p86M033/7uqe	Diana Prince (Customer 2)	+1-555-0192	CUSTOMER	\N	t	2026-11-22 11:06:31.725	2026-11-22 11:06:31.725
91e6be61-ca06-4bb8-9843-38b5edc72e0b	m5.mech1.1795345590904@vbrs.local	$2b$12$0psHsdDYeWJotRTDKlB27u5kb4CYcW0BSEj8zUZzpuqCoyd7YY4cO	Ethan Hunt (Lead Tech)	+1-555-0193	MECHANIC	\N	t	2026-11-22 11:06:31.996	2026-11-22 11:06:31.996
af870543-67bd-4053-a056-9cb0328c528c	m5.mech2.1795345590904@vbrs.local	$2b$12$0R4k25g7aMgnePajWXg41OzbTJgAgi4Vy8F.x4rLoo4U4ykHrilMW	Lucas Grey (Tech 2)	+1-555-0194	MECHANIC	\N	t	2026-11-22 11:06:32.286	2026-11-22 11:06:32.286
707b69df-c296-4059-9aa2-b0b8882b3c97	m5.admin.1795345590904@vbrs.local	$2b$12$TRhVCCXbAlU7ybRqjzqxmeBfAcVJBbcUUMq4u/Qzade55VzRKla7i	Command Admin	+1-555-0195	ADMIN	\N	t	2026-11-22 11:06:32.551	2026-11-22 11:06:32.551
15372eae-1d2d-4d1b-af92-e71b76d3393e	m6.customer.1795345591025@vbrs.local	$2b$12$oz4wW1KnxtPYffuJjhCG/u7I/sb3LBgRuuZrVPSvyVd5PFWEUqDrW	Eleanor Sterling	+1-555-0801	CUSTOMER	\N	t	2026-11-22 11:06:31.805	2026-11-22 11:06:31.805
6b36993f-4add-41d2-aa57-89b13b0ed876	m6.pending.mech.1795345591025@vbrs.local	$2b$12$qD2fuIpbWnF1OwFQ/kO2gupTJewuF60Y8WijtVh4SKtg19eU52Wlq	Derrick Moss	+1-555-0802	MECHANIC	\N	t	2026-11-22 11:06:32.074	2026-11-22 11:06:32.074
7c98ba9a-4b3d-4780-8493-facdc9ec499f	m3.userb.1795345591025@vbrs.local	$2b$12$54ixJNI2tiIiy5bPsz4AzODJTbE8gHyq26hySBzdBokm9qRSKY74a	Roadside Driver B	+1-555-3002	CUSTOMER	\N	t	2026-11-22 11:06:31.834	2026-11-22 11:06:31.834
4d62bb62-77c2-48f9-8e07-3e9ea0a6a73d	audit.mechanic.1795345591012@vbrs.local	$2b$12$dZsvmPirzNqndPbYRvzKkOmBy5RfPI69OS8keYhrHWHYc7fpx1TDy	Audit Mechanic	+1-555-2002	MECHANIC	\N	t	2026-11-22 11:06:31.843	2026-11-22 11:06:31.843
c32cde07-3798-4427-9651-2e442500f687	audit.userb.1795345591012@vbrs.local	$2b$12$exxhcjwuwZ50JHjFl68g/O6wt6q.CPzXBa6HTbOl6wKDuNIwCgL.e	User B	\N	CUSTOMER	\N	t	2026-11-22 11:06:33.143	2026-11-22 11:06:33.143
ebdad843-b10b-492a-b5bb-4ae10b4e5340	m3.edge.custb.1795345591031@vbrs.local	$2b$12$PTwalk16YCzzSVkHjuh52uDunVVukRrtsq26lkSTqvPN7NWaa7is2	Edge Customer Beta	+1-555-4002	CUSTOMER	\N	t	2026-11-22 11:06:31.861	2026-11-22 11:06:31.861
44add884-dad8-4e5a-a51f-c16a642f3873	m3.edge.mech.1795345591031@vbrs.local	$2b$12$AY3jalPd8rRobC6xm8keo.JpOJevODjPDAounNYJtoWKo124Dkndq	Edge Tech Master	+1-555-4003	MECHANIC	\N	t	2026-11-22 11:06:32.147	2026-11-22 11:06:32.147
3ea42b7f-99a0-4120-991f-7047bbb58050	m4.mech2.1795345590894@vbrs.local	$2b$12$Q/UQUyH9Yfl3Z2qFvxQo6OdnloqLXsfSmCL0Elvwmj1kS7NZZz2nK	Far Hills Auto Rescue	+1-555-5003	MECHANIC	\N	t	2026-11-22 11:06:32.029	2026-11-22 11:06:32.029
3ef04ba8-1823-457e-bdf2-2741130aa339	m2.customer.1795345591034@vbrs.local	$2b$12$cTEQf42dY5CxFVJO8enjguDWX6m1OydHt0csQcOnhhtZdz6yhu6vy	David Michael Hasselhoff	+1-555-9999	CUSTOMER	\N	t	2026-11-22 11:06:31.548	2026-11-22 11:06:32.188
abb68e9a-9974-4371-868d-ef5a78bf6045	m7.customer1.1795346682390@vbrs.local	$2b$12$K8d7VisH6hetdb.3QDXZr.q1nYncda9cPzU8YVxPc4S/v4yI1JpVC	Marcus Vance	+1-555-0101	CUSTOMER	\N	t	2026-11-22 11:24:42.627	2026-11-22 11:24:42.627
1132af97-784d-403f-8439-ee32ce4c6295	m7.customer2.1795346682390@vbrs.local	$2b$12$Pme5dQCKOmG2CZqwwe5rROtMHdRaNtvTDlmDEr1C4XyyjOFDEuoUG	Elena Rostova	+1-555-0102	CUSTOMER	\N	t	2026-11-22 11:24:42.866	2026-11-22 11:24:42.866
f94f9477-bc05-46e6-b444-9bb14d4ce5da	m7.mechanic.1795346682390@vbrs.local	$2b$12$4KYPshIZ0LDM4Tu4rNTY3e315iLClhddlk4PtQGsMZqVOzdvw9MuO	David Sterling	+1-555-0199	MECHANIC	\N	t	2026-11-22 11:24:43.098	2026-11-22 11:24:43.098
6a3159ce-3ec1-46ee-8854-079b5cef5d0c	m7.customer1.1795346709879@vbrs.local	$2b$12$LEguqWMo2WwZIv.lT1epvuWXRDqXErxSDlKzzrQ1l0lFcTQrLTNHG	Marcus Vance	+1-555-0101	CUSTOMER	\N	t	2026-11-22 11:25:10.117	2026-11-22 11:25:10.117
efeb8cd7-f7cc-4dfd-8689-240f124ae2a4	m7.customer2.1795346709879@vbrs.local	$2b$12$n9A7z0lx7vy2M4hEt8hvg.nkmtq/aJUBP.tVXcjHTAMtK/LAPX16i	Elena Rostova	+1-555-0102	CUSTOMER	\N	t	2026-11-22 11:25:10.358	2026-11-22 11:25:10.358
5db3fe47-163f-4f45-82a3-256bc87a79b2	m7.mechanic.1795346709879@vbrs.local	$2b$12$4jewlYTXj8IQmUWUsJCzkOMlFgbOXk.6V.7RHhqQdATz5lq2hpOie	David Sterling	+1-555-0199	MECHANIC	\N	t	2026-11-22 11:25:10.591	2026-11-22 11:25:10.591
84ecd965-cf9b-4db3-92a0-2fb64a3e965f	m7.customer1.1795346731082@vbrs.local	$2b$12$HbVZ8TAhvO/ArF.ex.Kb1.SRlFzIrI6rBayhv.PAzfNVWeK2HxDf.	Marcus Vance	+1-555-0101	CUSTOMER	\N	t	2026-11-22 11:25:31.361	2026-11-22 11:25:31.361
3517d75c-d341-43ab-b318-7b13f2026e31	m7.customer2.1795346731082@vbrs.local	$2b$12$4CALdjh2EAh6uNP17iWJFu5PoG2n1BHlsQE1ID63GBK0m1On8Yxky	Elena Rostova	+1-555-0102	CUSTOMER	\N	t	2026-11-22 11:25:31.646	2026-11-22 11:25:31.646
b7cff01c-2936-4856-8de7-e2f1049987f0	m7.mechanic.1795346731082@vbrs.local	$2b$12$MYIflxI4M/A.DiZpGq7eTO07lhDEPi0shl63Aa1K3mNcNePL7LXhK	David Sterling	+1-555-0199	MECHANIC	\N	t	2026-11-22 11:25:31.94	2026-11-22 11:25:31.94
282be406-30b3-4a61-a470-484970fa2ef9	m3.customer.1795346731630@vbrs.local	$2b$12$ZzBlk7umhL1QeWlU.GfeReUqTckZSDmKbB/NiPy7YLSPRhMx0HTTi	Roadside Driver A	+1-555-3001	CUSTOMER	\N	t	2026-11-22 11:25:32.157	2026-11-22 11:25:32.157
f7dd7f6a-8e5b-4475-820e-8b796a13b4d0	m6.admin.1795346731699@vbrs.local	$2b$12$ZzeQ/iJ5/UUs6gjOjRtoQu87iYCIXS2HJ6x5LG9u1Hz.6sB.cJ/.6	Chief Inspector Kane	+1-555-0800	ADMIN	\N	t	2026-11-22 11:25:32.211	2026-11-22 11:25:32.211
cd78682e-cc1a-4cc1-b024-3222b9c5e339	m5.cust1.1795346731751@vbrs.local	$2b$12$9VXGeemzqqC8S0i8MLFlSudlh8FATqqNRfprOSVE8N33/S8GDtlkW	Marcus Vance (Customer 1)	+1-555-0191	CUSTOMER	\N	t	2026-11-22 11:25:32.246	2026-11-22 11:25:32.246
50ade227-7e8a-46fd-8685-2e2878c91b01	m3.edge.custa.1795346731779@vbrs.local	$2b$12$It7DoEQhHW7zSCPBedX/W.hmZpe43hho.oDYmCZMJtekUwd3lltqi	Edge Customer Alpha	+1-555-4001	CUSTOMER	\N	t	2026-11-22 11:25:32.285	2026-11-22 11:25:32.285
7a09bda9-bcb7-47db-9d6f-9cde4f8fe7cd	m4.customer.1795346731790@vbrs.local	$2b$12$8nmHnBxjlDx3dZuZ.2GRW.rJvzx2cBPKS5kFRY5jxniB8wzWLOZBa	Stranded Motorist M4	+1-555-5001	CUSTOMER	\N	t	2026-11-22 11:25:32.296	2026-11-22 11:25:32.296
d97f7a68-1e5b-4bbc-a2ae-efdb6e991a47	m3.userb.1795346731630@vbrs.local	$2b$12$epmw1iWfzNSmYAHnG9BztOeCKfXnbjuNBCHt/0aS0OF12DTuJr17y	Roadside Driver B	+1-555-3002	CUSTOMER	\N	t	2026-11-22 11:25:32.43	2026-11-22 11:25:32.43
8ce31ba5-bfb6-4062-8788-1d55d758fd08	m6.customer.1795346731699@vbrs.local	$2b$12$Pb9qltcn1hnHBfDwv9yxIuk4y/r8d9ZEk9C94Mma25XhbXNlgsAMy	Eleanor Sterling	+1-555-0801	CUSTOMER	\N	t	2026-11-22 11:25:32.498	2026-11-22 11:25:32.498
5b7a3daf-7b92-462f-9fa1-95928376fca2	m5.cust2.1795346731751@vbrs.local	$2b$12$5pDmyEkcipNSHAwsaTCfDeO7m5YnSGG6XK66gT/3F/nWNo32Vf0wy	Diana Prince (Customer 2)	+1-555-0192	CUSTOMER	\N	t	2026-11-22 11:25:32.513	2026-11-22 11:25:32.513
bc905c8b-feee-4610-8e4c-c09401916566	m3.edge.custb.1795346731779@vbrs.local	$2b$12$oNH29qtVGQ0fYU9TAiZIO.cn5KHJvp8MwmoCRRTz8pyX5NMD6.f5S	Edge Customer Beta	+1-555-4002	CUSTOMER	\N	t	2026-11-22 11:25:32.552	2026-11-22 11:25:32.552
f7687de7-1987-44af-85d9-9fcc9f286770	m4.mech1.1795346731790@vbrs.local	$2b$12$p0F3hRMo1YUIF8gpfLmFY.xz.QqB7cgen6iglJ8yjh9u3y6AK.jwG	Downtown Tech Master	+1-555-5002	MECHANIC	\N	t	2026-11-22 11:25:32.561	2026-11-22 11:25:32.561
7d5c1d7c-e190-4cd7-a73d-a3b2d317422c	audit.mechanic.1795346731909@vbrs.local	$2b$12$36eo3RvKHcJAyq5azMggmOgDpSdEWvR70W.UCY2uv7YHjURF5JwwO	Audit Mechanic	+1-555-2002	MECHANIC	\N	t	2026-11-22 11:25:32.676	2026-11-22 11:25:32.676
383ded7b-56cc-4419-8926-25fc9318ea0a	m6.pending.mech.1795346731699@vbrs.local	$2b$12$nA0/iM7VcexwagVkNetluOzhQLp4HfwmscRMpHDRlG7JrC3sWU1JW	Derrick Moss	+1-555-0802	MECHANIC	\N	t	2026-11-22 11:25:32.756	2026-11-22 11:25:32.756
b6225e12-d48c-4709-97d5-6be7b6ef360d	m5.mech1.1795346731751@vbrs.local	$2b$12$wX0W0fHLM7B/b8Dp/MRPAe1987p0kSVae8F.Q4BH55m9pG7.1LKSW	Ethan Hunt (Lead Tech)	+1-555-0193	MECHANIC	\N	t	2026-11-22 11:25:32.766	2026-11-22 11:25:32.766
8890fb8f-a65c-4c1e-90cd-cb9d063b7634	m3.edge.mech.1795346731779@vbrs.local	$2b$12$O3JgHiw3NGBImho1MNDPl.G1qCoqV.bpySd.cdkAEvh5MHAYmDGZy	Edge Tech Master	+1-555-4003	MECHANIC	\N	t	2026-11-22 11:25:32.801	2026-11-22 11:25:32.801
599a1a84-5e64-44df-acaa-8e4c4e40cae3	m4.mech2.1795346731790@vbrs.local	$2b$12$LtpWAWtfIv8UkywO8P.uFOtbZYTASSU9uk3WZ31aYhQiHyuM.cvaW	Far Hills Auto Rescue	+1-555-5003	MECHANIC	\N	t	2026-11-22 11:25:32.831	2026-11-22 11:25:32.831
fed47de1-aa48-4bd6-9c68-199068e2cf77	m2.customer.1795346731735@vbrs.local	$2b$12$o8a89WVlhvrsAaKMeIXX8.EM6JCqTJLCjS661CgQ8ATKQaLv/tyim	David Michael Hasselhoff	+1-555-9999	CUSTOMER	\N	t	2026-11-22 11:25:32.279	2026-11-22 11:25:32.871
32246199-32b0-4a1c-a009-c51b0345f9e5	m5.mech2.1795346731751@vbrs.local	$2b$12$xldqk7zPq.Jx.2QS8NHn.e6evrvPHrqRpGAASo/aol0nNw/aGekWW	Lucas Grey (Tech 2)	+1-555-0194	MECHANIC	\N	t	2026-11-22 11:25:33.048	2026-11-22 11:25:33.048
cf56a912-9c6f-4924-96f7-8c62662045cb	m5.admin.1795346731751@vbrs.local	$2b$12$5LVGWPa/rrbeDDAHaKXr7eb4TpFw0rZaPRTZRgAdZcV0N/yrMQ3/S	Command Admin	+1-555-0195	ADMIN	\N	t	2026-11-22 11:25:33.304	2026-11-22 11:25:33.304
e59b6392-d01c-4bd7-9fdb-786873430a38	audit.userb.1795346731909@vbrs.local	$2b$12$v2T5PcKPRtG1XrzelG/S5.9lelEfmQVf4IDt0bJ/cxCG1C1aPfbK6	User B	\N	CUSTOMER	\N	t	2026-11-22 11:25:33.922	2026-11-22 11:25:33.922
6ad0fc2b-8f80-4225-9bf7-bdfe63dcfcb2	audit.customer.1795346731909@vbrs.local	$2b$12$iEwnetTj8ZDQP1l8q87g4O5WmBXWifTVtWhwpSUw1ubee7GE4A5VK	Audit Customer Updated	+1-555-7777	CUSTOMER	\N	t	2026-11-22 11:25:32.41	2026-11-22 11:25:34.419
02d88990-b57a-4b82-a5b4-e44022b802f4	m6.admin.1795347397635@vbrs.local	$2b$12$2dbr4I92isn24TmcVYRGVeOy1jlD1d0ncng5wFwX9oIJzNJZrJGCC	Chief Inspector Kane	+1-555-0800	ADMIN	\N	t	2026-11-22 11:36:38.183	2026-11-22 11:36:38.183
4a059e43-c586-45be-b371-252f448bbdd8	m5.cust1.1795347397710@vbrs.local	$2b$12$od6zv2DX1szg4PA5kmPP4.p626FVoCogQ3QPsbTqA.0NBmCifgZwy	Marcus Vance (Customer 1)	+1-555-0191	CUSTOMER	\N	t	2026-11-22 11:36:38.215	2026-11-22 11:36:38.215
03049ccb-baf0-499d-aa2d-d5dce89114ad	m7.customer1.1795347398006@vbrs.local	$2b$12$WIwzMm79dk1kKu9/.r9VwudgUMWuXKgs1bdPudVW3rDB0rj92FWem	Marcus Vance	+1-555-0101	CUSTOMER	\N	t	2026-11-22 11:36:38.273	2026-11-22 11:36:38.273
147459dd-88dc-4f76-89cc-14a93c36d249	audit.customer.1795347397646@vbrs.local	$2b$12$OBKgGo1dsFKJbEKL1RfSxewufXmh.fAkeq/NLg.2qQGZx8T0CqqRW	Audit Customer Updated	+1-555-7777	CUSTOMER	\N	t	2026-11-22 11:36:38.198	2026-11-22 11:36:40.311
bbdc9439-1243-4dec-a18b-8b6512cede79	m3.edge.custa.1795347397757@vbrs.local	$2b$12$QHyNLVXN47jHLFGvrqVqNuxZ/jc9eB0629.lXzffDbYAswhUiJBoi	Edge Customer Alpha	+1-555-4001	CUSTOMER	\N	t	2026-11-22 11:36:38.287	2026-11-22 11:36:38.287
12a59ca0-ebce-49aa-b8c8-2d6021a4d980	m4.customer.1795347397802@vbrs.local	$2b$12$3sHUbMcKrNEJtk88yIcziuYte7FRYeWYmnZV.Fjsw78bCOCAp2eg.	Stranded Motorist M4	+1-555-5001	CUSTOMER	\N	t	2026-11-22 11:36:38.32	2026-11-22 11:36:38.32
487c98dd-e41e-417a-81df-6160ad2f08bd	m3.customer.1795347397822@vbrs.local	$2b$12$HpblckUObZ4idglZeAeEkutAACR4JSk6fRG.96clgKYZW.DbwayLS	Roadside Driver A	+1-555-3001	CUSTOMER	\N	t	2026-11-22 11:36:38.322	2026-11-22 11:36:38.322
c8830dc5-34eb-4c8c-a34d-e1ff3bc55773	m3.edge.custb.1795347397757@vbrs.local	$2b$12$8t2m76Uq744NlLP/bKrJJ.7/x0T4yYFZJOhmMVSDj5EOmXSEegSMa	Edge Customer Beta	+1-555-4002	CUSTOMER	\N	t	2026-11-22 11:36:38.58	2026-11-22 11:36:38.58
2efbe1ad-1413-4ae8-81ae-49e8b990d633	m3.userb.1795347397822@vbrs.local	$2b$12$XEwVJxU7nkU/c9GOQCRXie14TGwcJRh.UjOyoDOfDmZ2wuUm7DXFe	Roadside Driver B	+1-555-3002	CUSTOMER	\N	t	2026-11-22 11:36:38.611	2026-11-22 11:36:38.611
13608b64-3065-4aea-99b6-4633b454b56d	m4.mech1.1795347397802@vbrs.local	$2b$12$bx0ELvBC31Kqb4O.dsnVzeFLmkHFGID5esbOb1amjjE4vZiL8Vmcy	Downtown Tech Master	+1-555-5002	MECHANIC	\N	t	2026-11-22 11:36:38.628	2026-11-22 11:36:38.628
9d5010e7-020c-41ba-81ac-6b878a91889e	m3.edge.mech.1795347397757@vbrs.local	$2b$12$30/wfS1Ei3HzChnsy1VlmuVv692X13SpWpSN/IUFNPgCTCvuKUNrS	Edge Tech Master	+1-555-4003	MECHANIC	\N	t	2026-11-22 11:36:38.869	2026-11-22 11:36:38.869
b49fbfc0-75b1-4417-9a7b-b2b55bb451d6	m4.mech2.1795347397802@vbrs.local	$2b$12$ivNasZNTPddMmf9GTjSSh.UO4Jpv9PqieU7BrZNbQJQiQSj7geb3q	Far Hills Auto Rescue	+1-555-5003	MECHANIC	\N	t	2026-11-22 11:36:38.918	2026-11-22 11:36:38.918
6108dc7f-6c15-4ee6-8a47-92ff7487b689	m6.customer.1795347397635@vbrs.local	$2b$12$xdvE3kgPbUjsWS8XEQH/Se4I91jLTxCdZ/TI2AdD77XyEZexRsiOq	Eleanor Sterling	+1-555-0801	CUSTOMER	\N	t	2026-11-22 11:36:38.485	2026-11-22 11:36:38.485
b0bcbe4c-6c84-4113-a38b-62338ce06d8d	m6.pending.mech.1795347397635@vbrs.local	$2b$12$myQWsk8LYpCT9NEPbg1L7ee8LMWtUXNzO8aBmEPKUutGvrWUkB6j.	Derrick Moss	+1-555-0802	MECHANIC	\N	t	2026-11-22 11:36:38.754	2026-11-22 11:36:38.754
afe64e04-d47c-4aff-97a5-498252ffd13a	audit.mechanic.1795347397646@vbrs.local	$2b$12$.vukXjuRJ5i9YkSuOo5XkOCyvLHPBL.12GRvBVMi0xKFqhaVvhc7y	Audit Mechanic	+1-555-2002	MECHANIC	\N	t	2026-11-22 11:36:38.5	2026-11-22 11:36:38.5
7baddfaa-81ca-4ccc-83c2-2d0e94f4f82b	audit.userb.1795347397646@vbrs.local	$2b$12$3xpOcsQqlKohTzAzJwOFLOws99sOiVxzgOBwrIagFLZm4e9lwIa8C	User B	\N	CUSTOMER	\N	t	2026-11-22 11:36:39.799	2026-11-22 11:36:39.799
8b1e24ae-3d0f-45a1-a091-b99dbccc5094	m5.cust2.1795347397710@vbrs.local	$2b$12$ifRPwr1xzhE43Ici5UCe1OV9R5.3xViI1LKjmi1TjHEiq4lgn9Rqe	Diana Prince (Customer 2)	+1-555-0192	CUSTOMER	\N	t	2026-11-22 11:36:38.514	2026-11-22 11:36:38.514
6fce9f62-804c-480a-ba62-c337fa44ace7	m5.mech1.1795347397710@vbrs.local	$2b$12$4J5sGzKE/r49j3MdnfMXIOurZiF2doQctwe2izat5E4os1pOfooIG	Ethan Hunt (Lead Tech)	+1-555-0193	MECHANIC	\N	t	2026-11-22 11:36:38.801	2026-11-22 11:36:38.801
da494868-688f-4802-823a-432be9bc80b5	m5.mech2.1795347397710@vbrs.local	$2b$12$6Xa.TUxy9L2HoBJArTVWAu.m4Tz9ZlDQT2os8awRwvelghlDf7iJy	Lucas Grey (Tech 2)	+1-555-0194	MECHANIC	\N	t	2026-11-22 11:36:39.108	2026-11-22 11:36:39.108
67685e48-6314-4741-9f3e-7869f819b961	m5.admin.1795347397710@vbrs.local	$2b$12$33BW82oVFi/TG8rVzMFCSernt4/9LzZQAeR8LSX5c42m2s0ddHnKq	Command Admin	+1-555-0195	ADMIN	\N	t	2026-11-22 11:36:39.357	2026-11-22 11:36:39.357
4c50ae6c-ef63-4e39-a5b0-d01121d5eb64	m7.customer2.1795347398006@vbrs.local	$2b$12$AT1iU0b.t4fZUx9.d/s34.L0Js0oM6jEDP8X9Nqx0zEG080y2/bB6	Elena Rostova	+1-555-0102	CUSTOMER	\N	t	2026-11-22 11:36:38.578	2026-11-22 11:36:38.578
3fab570e-2937-4fe4-8e48-b6bc7ba4b2f0	m7.mechanic.1795347398006@vbrs.local	$2b$12$qtMS1bpOsCV/hWyz6Nt7aORAk//cHLL6tRce2RYpvBGKdeJTGEQp6	David Sterling	+1-555-0199	MECHANIC	\N	t	2026-11-22 11:36:38.847	2026-11-22 11:36:38.847
ae128b65-26b9-4aaf-aebe-80153c2e1b12	m2.customer.1795347397724@vbrs.local	$2b$12$pKH2uXSxGW8Sk1o9oDBGiOkVG791DAnB6hIYTNf4z9K/6TMX9ht2O	David Michael Hasselhoff	+1-555-9999	CUSTOMER	\N	t	2026-11-22 11:36:38.275	2026-11-22 11:36:38.904
a89d8a1e-ad80-4555-a258-0392941f695b	sec.cust1.1795348331140@vbrs.local	$2b$12$lo61Ip73krqvD.8.SSz6MOq8WcMPoZQN7r2SBldkRASwsDrSo87t6	Alice SecTest	\N	CUSTOMER	\N	t	2026-11-22 11:52:11.379	2026-11-22 11:52:11.379
3ed21b94-d1fe-4433-8464-75cf1d4fb9e4	sec.cust2.1795348331140@vbrs.local	$2b$12$luhj1il2XOOB5InPmysnUuVMbvcBv7gd/4gQDhCmf.WHVmENQnxyC	Bob SecTest	\N	CUSTOMER	\N	t	2026-11-22 11:52:11.621	2026-11-22 11:52:11.621
a62fc8d6-66ce-471b-b268-b23c2051f9f1	sec.mech.1795348331140@vbrs.local	$2b$12$seqRDtSB45CBCgQIY29bD.3AYcfJ4D/mwFrV/dgKWMBpn54ywWVgm	Charlie Mechanic	\N	MECHANIC	\N	t	2026-11-22 11:52:11.853	2026-11-22 11:52:11.853
028383ec-4ed0-4010-b4a2-c4cc161da698	sec.admin.1795348331140@vbrs.local	$2b$12$G1cMkGU2uBUgz3rHT0hTaeara5Cx4ZIhmQ9GNVgIS9lG0ZkEhrRFu	Admin Supervisor	\N	ADMIN	\N	t	2026-11-22 11:52:12.092	2026-11-22 11:52:12.092
766576f6-0959-4864-8a7e-649df595336b	sec.cust1.1795348371142@vbrs.local	$2b$12$q4aCK3dV5TLOxPWDFR9BjeEgYW.CuusIokmjJgoJ9QCmvZJVDmuaO	Alice SecTest	\N	CUSTOMER	\N	t	2026-11-22 11:52:51.378	2026-11-22 11:52:51.378
0c20acda-40da-4f0e-b42f-44bbbc0a1af1	sec.cust2.1795348371142@vbrs.local	$2b$12$eSQoa2uQ6OVVrhyKSpXfD.yCwTKdOQOD6cE.ZaK8eb/bP6SMwVWei	Bob SecTest	\N	CUSTOMER	\N	t	2026-11-22 11:52:51.616	2026-11-22 11:52:51.616
d8815573-617c-4a9f-a950-507542203e55	sec.mech.1795348371142@vbrs.local	$2b$12$FiLVQTUhAo7s1.IQUNYZauBKKgoUSOFTj8MhRTAKgauxMyirG/HJm	Charlie Mechanic	\N	MECHANIC	\N	t	2026-11-22 11:52:51.85	2026-11-22 11:52:51.85
a6b612af-845d-49fa-b456-67250cdb4014	sec.admin.1795348371142@vbrs.local	$2b$12$sK/sVC26HRRKspWgWlNNr.bySh4fV.EagqpmzukWuTGsnY3kI/NUq	Admin Supervisor	\N	ADMIN	\N	t	2026-11-22 11:52:52.084	2026-11-22 11:52:52.084
ff166c12-fa96-4a4d-8523-7e1801d01b3f	m5.cust1.1795348523391@vbrs.local	$2b$12$07Im3BDFPepvJSQwc3M4bODPmky2pkFX7G8jqxeF1KH1ChbCyqp26	Marcus Vance (Customer 1)	+1-555-0191	CUSTOMER	\N	t	2026-11-22 11:55:23.951	2026-11-22 11:55:23.951
eeec89bd-77f1-4b87-b039-63f9778b4621	m3.edge.custa.1795348523471@vbrs.local	$2b$12$R8XTGTvoOStAT.DmvvZoQOWG17b5M7LQAyF9TvGSJ0056nroRh5Ju	Edge Customer Alpha	+1-555-4001	CUSTOMER	\N	t	2026-11-22 11:55:24.019	2026-11-22 11:55:24.019
fe4fed22-b93a-4dfe-b237-66a079f96a50	m4.customer.1795348523552@vbrs.local	$2b$12$f093tkcNjh2Oi8knE11NZ.8hxVBOqRMh0D0Zmj5Ec61CuEkNhWZWu	Stranded Motorist M4	+1-555-5001	CUSTOMER	\N	t	2026-11-22 11:55:24.075	2026-11-22 11:55:24.075
e43779a3-03a2-4ed0-a27b-1c66d4ab40bf	sec.cust1.1795348523793@vbrs.local	$2b$12$Tt4wAbqpzWeTz5EH3gVjK.yVGerA/WuXlzYjd02jAXeEjfraAZCNi	Alice SecTest	\N	CUSTOMER	\N	t	2026-11-22 11:55:24.082	2026-11-22 11:55:24.082
c5be2c05-7982-46af-9db0-2f3f296f630b	m7.customer1.1795348523820@vbrs.local	$2b$12$J9Yce9YeP3mT5TU2nAyWvOr1aYsTTJPyPW8/kLlSzAimjtJE7BsNa	Marcus Vance	+1-555-0101	CUSTOMER	\N	t	2026-11-22 11:55:24.132	2026-11-22 11:55:24.132
9cf8cdc2-da2f-4b7a-ac59-c6b590ebed6a	m6.admin.1795348523689@vbrs.local	$2b$12$EOSaCUraBbzkrjjuyRZ5yOK1B1MpSBENAt8IEFRlP5A01C15P/6Wa	Chief Inspector Kane	+1-555-0800	ADMIN	\N	t	2026-11-22 11:55:24.137	2026-11-22 11:55:24.137
935f0c45-76f4-4be0-8fb0-95fb6009b2dd	m3.customer.1795348523653@vbrs.local	$2b$12$3S.Mkzvh9HdppzTHB6fMFe9YDpW1th76nZZrXJ/tBQgf9p/.KnjSy	Roadside Driver A	+1-555-3001	CUSTOMER	\N	t	2026-11-22 11:55:24.138	2026-11-22 11:55:24.138
a995ae67-343e-4363-bdf9-0375d0f33f4e	m5.cust2.1795348523391@vbrs.local	$2b$12$OPjPGkG1YpSsJdBKcMPaW.Sngnc3IavNaEAMSGXqQArnxMi6l095q	Diana Prince (Customer 2)	+1-555-0192	CUSTOMER	\N	t	2026-11-22 11:55:24.246	2026-11-22 11:55:24.246
cf2a50da-6587-4cf0-8fbf-fbbd1a6474a4	audit.mechanic.1795348523404@vbrs.local	$2b$12$UZJLr/1lVhNTgSBIBsJr3ODxMyJr1owKd7wFEhb0WRqjOdngHJBAW	Audit Mechanic	+1-555-2002	MECHANIC	\N	t	2026-11-22 11:55:24.266	2026-11-22 11:55:24.266
189ee5a7-5c5b-4120-a133-e29310c9dc2a	m3.edge.custb.1795348523471@vbrs.local	$2b$12$iKybdLaU7romVDrVdMhmzuUjzfWgQBcm0cQ06Cq/S/CghS.A2eLYu	Edge Customer Beta	+1-555-4002	CUSTOMER	\N	t	2026-11-22 11:55:24.302	2026-11-22 11:55:24.302
064a6840-01ae-4133-8933-d1d2fd6a3af5	sec.cust2.1795348523793@vbrs.local	$2b$12$eJ8BlxmpSV4AYvcqOdMePuaG6wjyzfYoHzgQQGLf7ZZOa6vTjId22	Bob SecTest	\N	CUSTOMER	\N	t	2026-11-22 11:55:24.352	2026-11-22 11:55:24.352
0c0768ce-b175-46fb-8444-26488c274cba	m4.mech1.1795348523552@vbrs.local	$2b$12$OYnvJyE27hT9uxZzJpNxweK60tUdOXuK9BC8MILntukMbsUR17nr2	Downtown Tech Master	+1-555-5002	MECHANIC	\N	t	2026-11-22 11:55:24.373	2026-11-22 11:55:24.373
863029a2-5a25-4be2-be07-0680e859f3f2	m7.customer2.1795348523820@vbrs.local	$2b$12$HTGfBffxGlmSM9FOWgdRZOix.dZXG3kue4Rr2hwl/s.yL920m3b9y	Elena Rostova	+1-555-0102	CUSTOMER	\N	t	2026-11-22 11:55:24.406	2026-11-22 11:55:24.406
958f62e7-0865-4490-a441-8d32eb95ef31	m3.userb.1795348523653@vbrs.local	$2b$12$gW69ixNkBq.V4Wd1mU/qYuDcEIczx8n9XsfyLCcWVDiGve./Clv5S	Roadside Driver B	+1-555-3002	CUSTOMER	\N	t	2026-11-22 11:55:24.415	2026-11-22 11:55:24.415
413f9c28-135a-41dc-9ae3-29f264612e2c	m6.customer.1795348523689@vbrs.local	$2b$12$jkDeguih2GBqkwV2LJaHm.Dqj2X8JedWo5TNaHgfkvYyHcm/UZMa.	Eleanor Sterling	+1-555-0801	CUSTOMER	\N	t	2026-11-22 11:55:24.43	2026-11-22 11:55:24.43
93379134-a271-44fa-bf5a-314fe8520bca	m5.mech1.1795348523391@vbrs.local	$2b$12$fzkSRtOTNWodzCcp4HgDxOxX.eT3KQXgwo6R1gYqNLMxuF/C9xgsS	Ethan Hunt (Lead Tech)	+1-555-0193	MECHANIC	\N	t	2026-11-22 11:55:24.514	2026-11-22 11:55:24.514
94ae7a86-4904-4f65-be33-bcd6730fcb95	m3.edge.mech.1795348523471@vbrs.local	$2b$12$TMr.LdBrA0h52voNL0ktEuaXK68NXU.6IFB5x1BGOlVkNYbknsysq	Edge Tech Master	+1-555-4003	MECHANIC	\N	t	2026-11-22 11:55:24.605	2026-11-22 11:55:24.605
62b2d075-5944-43e7-89a8-26146484ab12	sec.mech.1795348523793@vbrs.local	$2b$12$Oiah8GOSYhsEhCvqofKnLOo54yv2APUzUNyEa.EMoIhHfwfUr/xLO	Charlie Mechanic	\N	MECHANIC	\N	t	2026-11-22 11:55:24.622	2026-11-22 11:55:24.622
d3900c77-40a4-4e6e-8255-038d9aed2a21	m4.mech2.1795348523552@vbrs.local	$2b$12$FzIUHtANABN.B9FvrW0qa.KuhnqMcp8WxQRm850qxiHMwcGc0.7Am	Far Hills Auto Rescue	+1-555-5003	MECHANIC	\N	t	2026-11-22 11:55:24.671	2026-11-22 11:55:24.671
8bc999de-3d28-4b57-af72-a5c2e2ac6dab	m7.mechanic.1795348523820@vbrs.local	$2b$12$i4CG/TvKFYofHRR5nuDI1Ozi.jC4aVech2nEsv9IQJfRA/CLe8Bh.	David Sterling	+1-555-0199	MECHANIC	\N	t	2026-11-22 11:55:24.685	2026-11-22 11:55:24.685
4b4b0149-ece4-4281-9c87-ad93e8ccf2a8	m2.customer.1795348523467@vbrs.local	$2b$12$2pbZPHQL4wGe5MAOVXnsneyB4niMuKiBR8EjDuBrpZXkxUSBt/eQm	David Michael Hasselhoff	+1-555-9999	CUSTOMER	\N	t	2026-11-22 11:55:24.044	2026-11-22 11:55:24.687
e50326f1-92b0-4149-ab38-88e681b1037c	m6.pending.mech.1795348523689@vbrs.local	$2b$12$lJFDh0ZcoQ2whIW3EWFbFer3SfJI3QrDfQoKWyjcANkamCWLGRdUC	Derrick Moss	+1-555-0802	MECHANIC	\N	t	2026-11-22 11:55:24.713	2026-11-22 11:55:24.713
4469db4e-5fa2-4654-a406-28cdc4c47994	m5.mech2.1795348523391@vbrs.local	$2b$12$FMzqHgEq.sVK2Av6fvETGeZOGcbl3md4tk/g2ndSHNjbR3qknSI1S	Lucas Grey (Tech 2)	+1-555-0194	MECHANIC	\N	t	2026-11-22 11:55:24.811	2026-11-22 11:55:24.811
86063df1-5f0d-4cda-9d5c-5124c3c670d6	sec.admin.1795348523793@vbrs.local	$2b$12$MSrH1zO3gPvVn2WxTTBBSeqJP8rKce7e5BYOooE9LT2DBoCjkpVOS	Admin Supervisor	\N	ADMIN	\N	t	2026-11-22 11:55:24.905	2026-11-22 11:55:24.905
bbdeedcd-4da8-41f3-9c48-fda072eb1658	m5.admin.1795348523391@vbrs.local	$2b$12$uiE83.D1ZuJ8DKlbyMzlN.cGZiLGnOJbFWAwQm7S9urHOYycnuvZe	Command Admin	+1-555-0195	ADMIN	\N	t	2026-11-22 11:55:25.093	2026-11-22 11:55:25.093
bd268487-3f47-4226-9287-a6f28215b3ef	audit.userb.1795348523404@vbrs.local	$2b$12$gtMhDXRKg37PFudWWeDX3.8xe25zzrB9N8HByxoy0GPo6JkGVmTWi	User B	\N	CUSTOMER	\N	t	2026-11-22 11:55:25.597	2026-11-22 11:55:25.597
f2486095-f7f5-4923-8dd4-bbdfad681499	audit.customer.1795348523404@vbrs.local	$2b$12$qMqIrOobJ3rdiZU8QCQoi.FRNKVcAslkUch1LqVHTcUzkrYtGp1jy	Audit Customer Updated	+1-555-7777	CUSTOMER	\N	t	2026-11-22 11:55:23.982	2026-11-22 11:55:26.102
b058b251-3038-4f94-837d-98d390b907c9	m2.customer.1795352168743@vbrs.local	$2b$12$yvdjJITckI9TpdqKr.Jlue5qv7Vkv4.nh4DI6IJTbm8iqIQxMIOgS	David Michael Hasselhoff	+1-555-9999	CUSTOMER	\N	t	2026-11-22 12:56:09.118	2026-11-22 12:56:09.651
6a574d53-ad46-4c43-b3d2-054578f0fbbe	audit.mechanic.1795352182033@vbrs.local	$2b$12$QiInt9e0BZic/myJmOtj.uA8ps7Qezu7Cl68mQgyWkxj7MhxZh5Ke	Audit Mechanic	+1-555-2002	MECHANIC	\N	t	2026-11-22 12:56:22.645	2026-11-22 12:56:22.645
793e166b-ae9f-4eba-bdf4-3915924ac842	audit.userb.1795352182033@vbrs.local	$2b$12$nYOWLhdKvfmY08fgi3hX0.25XLDzgw2ELNB5w8g0JHCtdTDdOrqoK	User B	\N	CUSTOMER	\N	t	2026-11-22 12:56:23.836	2026-11-22 12:56:23.836
40e6fef7-48b0-4b4f-b5d1-643f8c4665d7	audit.customer.1795352182033@vbrs.local	$2b$12$HvJmoedvgol5WW.fUKR0eOzuEuBNTQ9pWg9lE.7jiRKlSYvjTO36K	Audit Customer Updated	+1-555-7777	CUSTOMER	\N	t	2026-11-22 12:56:22.397	2026-11-22 12:56:24.333
f34fa6c9-f73a-42c4-9160-85d695a71a2b	m5.cust1.1795352676131@vbrs.local	$2b$12$i2C8Hl8F.cccEJ32d.XsY.VEc/tJeAitRPkbNc10azR6JI/Hhrtxq	Marcus Vance (Customer 1)	+1-555-0191	CUSTOMER	\N	t	2026-11-22 13:04:36.501	2026-11-22 13:04:36.501
7728fd21-9b94-481c-b739-87c80836528a	m4.customer.1795352676147@vbrs.local	$2b$12$.MshxDWxLe19lJPjLCKmc.srMCpsGVPxuidLGVntX0sxwYkYMk1Wa	Stranded Motorist M4	+1-555-5001	CUSTOMER	\N	t	2026-11-22 13:04:36.537	2026-11-22 13:04:36.537
8b8e01b0-ced8-44e7-8ac3-11a5129be596	m5.cust2.1795352676131@vbrs.local	$2b$12$tnuLRcibKvFGNBKJNvrPaOlTs4OAMgrzmmj43xvK/WFI6nKdAzqia	Diana Prince (Customer 2)	+1-555-0192	CUSTOMER	\N	t	2026-11-22 13:04:36.749	2026-11-22 13:04:36.749
93c9a1ba-11fc-41ef-bc41-0bba5b0a0634	m4.mech1.1795352676147@vbrs.local	$2b$12$yP1XnWxscOSNetTuEWv6PuePLmfvRXFKBh6wNCjLxwyvuzA/.r7Jq	Downtown Tech Master	+1-555-5002	MECHANIC	\N	t	2026-11-22 13:04:36.784	2026-11-22 13:04:36.784
fc725f56-3a5d-4cfb-ae3a-285db185f44e	m5.mech1.1795352676131@vbrs.local	$2b$12$SM1nR8KFSsFSgtwlIkPW6uSCALrVRutla32F55VR1Of3nnGrpwFKi	Ethan Hunt (Lead Tech)	+1-555-0193	MECHANIC	\N	t	2026-11-22 13:04:36.984	2026-11-22 13:04:36.984
3b2178a5-100c-422e-96c5-992e3283239f	m4.mech2.1795352676147@vbrs.local	$2b$12$72CYsVFIp/535yH38BRrkejS5DWrL.gH089PF5nm96Nte4zcjmmHS	Far Hills Auto Rescue	+1-555-5003	MECHANIC	\N	t	2026-11-22 13:04:37.036	2026-11-22 13:04:37.036
4ffc6d3f-77f9-48e0-bbaa-e37af292b892	m2.customer.1795352676132@vbrs.local	$2b$12$0h.0Oh/gCyAzLTXWBAiFSOpBeZ5zXtyd97EX//lEmC6OJRJZEK6ny	David Michael Hasselhoff	+1-555-9999	CUSTOMER	\N	t	2026-11-22 13:04:36.514	2026-11-22 13:04:37.052
38d387dd-e06f-4ea0-9155-587eb1ec7a7c	m5.mech2.1795352676131@vbrs.local	$2b$12$467AhdDfz4h2e4aocA.J5uJ86IQTtdv4dbxjwegHdSX0R2aHixQGW	Lucas Grey (Tech 2)	+1-555-0194	MECHANIC	\N	t	2026-11-22 13:04:37.235	2026-11-22 13:04:37.235
e1f9196b-4bee-442b-903b-bf6bd88250e7	m5.admin.1795352676131@vbrs.local	$2b$12$r9CYQQvF5NhBDHX3rQLhN.bOlFnl44ZJYy96RT3eaEKl1S4tx1xGC	Command Admin	+1-555-0195	ADMIN	\N	t	2026-11-22 13:04:37.473	2026-11-22 13:04:37.473
e22478b0-00a4-44f8-b146-3649213c7a20	customer.john@vbrs.local	$2b$12$s1/hBYJ3t7F0VCdBi6W4XOfU0mhNbovRn1jqEh4Jmxz6apr7Qt/pu	Johnathan Doe Verified	+1-555-777-8899	CUSTOMER	https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=150	t	2026-11-22 06:59:47.761	2026-11-22 14:12:29.484
\.


--
-- Data for Name: Vehicle; Type: TABLE DATA; Schema: public; Owner: vbrs_admin
--

COPY public."Vehicle" (id, "userId", make, model, year, "licensePlate", vin, color, powertrain, "isDefault", "createdAt", "updatedAt") FROM stdin;
a260d478-71b9-4303-9ec5-c6fd70ab4c4a	e22478b0-00a4-44f8-b146-3649213c7a20	Toyota	Camry XSE	2022	NYC-7842	4T1B11HK5NU123456	Midnight Black	PETROL	t	2026-11-22 06:59:47.764	2026-11-22 06:59:47.764
1ee83daf-4d2e-4368-9ac8-04321a3acfb6	e22478b0-00a4-44f8-b146-3649213c7a20	Tesla	Model 3 Long Range	2023	EV-88219	5YJ3E1EB9PF654321	Pearl White	ELECTRIC	f	2026-11-22 06:59:47.764	2026-11-22 06:59:47.764
db9c709b-e628-4883-9901-da4c51566886	9f992f35-9e68-40b0-b4fa-390233d42ee2	Ford	F-150 Lariat	2021	TRK-9014	1FTFW1ED6MFC99887	Agate Black	PETROL	t	2026-11-22 06:59:47.769	2026-11-22 06:59:47.769
a82b0cca-e4c8-44b8-9e22-674f048ed5e0	e22478b0-00a4-44f8-b146-3649213c7a20	Audi	RS6 Avant	2024	E2E-5487			PETROL	f	2026-11-22 09:27:35.548	2026-11-22 09:27:35.548
ace1cb6e-1e74-4c0d-84df-622d529c8a5e	a1479806-db8e-432b-a61a-04b1494faf85	bmw	m4	2026	TS28 U0056	67799878978797943	black	PETROL	t	2026-11-22 09:33:51.492	2026-11-22 09:33:51.492
685d419d-2e68-4907-95d5-1bdec89b7325	baf36b48-83b6-4d2a-acaf-1145a539c456	Porsche	911 GT3	2023	EDGE-A-1961	\N	\N	PETROL	t	2026-11-22 09:44:11.979	2026-11-22 09:44:11.979
47edc19b-e82a-4bc5-8279-65bac299b3f0	4ddd4a39-70fa-42ed-bfbb-f2c557e01ec5	Tesla	Model S Plaid	2024	EDGE-B-1985	\N	\N	ELECTRIC	t	2026-11-22 09:44:11.995	2026-11-22 09:44:11.995
42b6160d-d5c3-499b-9f7a-54cc3b72dedb	19b6e30e-7ab8-4db5-87e5-443815e3d455	Porsche	911 GT3	2023	EDGE-A-5879	\N	\N	PETROL	t	2026-11-22 09:45:05.897	2026-11-22 09:45:05.897
ff595932-c126-4ad4-b710-54ac968b0da7	30d6feea-b385-4632-bdf1-274829eada18	Tesla	Model S Plaid	2024	EDGE-B-5902	\N	\N	ELECTRIC	t	2026-11-22 09:45:05.913	2026-11-22 09:45:05.913
3f0353ea-4192-4114-b623-1d63f46b7b14	4f5799c4-5ad3-40d7-9d81-4a3bb7264d2f	Porsche	911 GT3	2023	EDGE-A-1144	\N	\N	PETROL	t	2026-11-22 09:45:41.164	2026-11-22 09:45:41.164
569bba46-825f-46dc-b372-00fb0320fa05	86ac2e5d-4c47-4b60-900b-7d610ad1cdd0	Tesla	Model S Plaid	2024	EDGE-B-1171	\N	\N	ELECTRIC	t	2026-11-22 09:45:41.183	2026-11-22 09:45:41.183
798c9053-f133-400f-a625-0247195d69cf	e22478b0-00a4-44f8-b146-3649213c7a20	Audi	RS6 Avant	2024	E2E-1606			PETROL	f	2026-11-22 11:56:11.662	2026-11-22 11:56:11.662
5d48ecb5-70b7-4754-9871-f8a478e57b46	e22478b0-00a4-44f8-b146-3649213c7a20	Audi	RS6 Avant	2024	E2E-3961			PETROL	f	2026-11-22 09:10:54.022	2026-11-22 09:10:54.022
8531c076-c4eb-46e0-8f89-65d5dcc39895	e22478b0-00a4-44f8-b146-3649213c7a20	Audi	RS6 Avant	2024	E2E-6854			PETROL	f	2026-11-22 09:11:26.91	2026-11-22 09:11:26.91
8a02753f-d7f8-44a0-a530-d99461578aaf	e22478b0-00a4-44f8-b146-3649213c7a20	Audi	RS6 Avant	2024	E2E-1510			PETROL	f	2026-11-22 09:12:11.562	2026-11-22 09:12:11.562
dee7f69a-7c9e-4bcf-b223-f0108c3201f4	e22478b0-00a4-44f8-b146-3649213c7a20	Audi	RS6 Avant	2024	E2E-9729			PETROL	f	2026-11-22 10:39:09.8	2026-11-22 10:39:09.8
eb63566c-d19a-4aa5-b1bd-298754098342	e22478b0-00a4-44f8-b146-3649213c7a20	Audi	RS6 Avant	2024	E2E-6330			PETROL	f	2026-11-22 09:13:06.382	2026-11-22 09:13:06.382
8f8af963-f33f-4ef7-ab39-a9fb66446f50	b347ca38-e44c-42ac-a846-63d4b6c28e3a	Porsche	911 GT3	2023	EDGE-A-2593	\N	\N	PETROL	t	2026-11-22 10:42:22.607	2026-11-22 10:42:22.607
030f76d1-9136-446f-be98-73f088f19dbd	87dac236-69b8-470f-b92f-efef6a6e2d67	Tesla	Model S Plaid	2024	EDGE-B-2612	\N	\N	ELECTRIC	t	2026-11-22 10:42:22.623	2026-11-22 10:42:22.623
32c6134f-d4c0-4950-a441-63335b7673b6	8aa4095f-22c6-46bf-90c2-06cb7d51fdf7	Porsche	911 GT3	2023	EDGE-A-4817	\N	\N	PETROL	t	2026-11-22 10:04:24.833	2026-11-22 10:04:24.833
b731e180-9b03-4865-9bef-b3af744fc646	6735a628-9f69-43e8-9647-4859b129ce73	Tesla	Model S Plaid	2024	EDGE-B-4837	\N	\N	ELECTRIC	t	2026-11-22 10:04:24.848	2026-11-22 10:04:24.848
fe3f2481-0fd6-44af-9faf-2ea950606f85	cdc3ac5d-c08a-41d5-8da8-d5ae65adcc52	Porsche	911 GT3	2023	EDGE-A-2167	\N	\N	PETROL	t	2026-11-22 11:06:32.187	2026-11-22 11:06:32.187
ca62ec10-022d-4fa3-8897-11837507c603	e22478b0-00a4-44f8-b146-3649213c7a20	Audi	RS6 Avant	2024	E2E-4379			PETROL	f	2026-11-22 10:04:54.441	2026-11-22 10:04:54.441
68195c76-7a2f-4cef-9319-7a855f75455a	e22478b0-00a4-44f8-b146-3649213c7a20	Audi	RS6 Avant	2024	E2E-7797			PETROL	f	2026-11-22 10:06:57.859	2026-11-22 10:06:57.859
29b5fa80-b00c-49c8-8379-387453514cbf	ebdad843-b10b-492a-b5bb-4ae10b4e5340	Tesla	Model S Plaid	2024	EDGE-B-2194	\N	\N	ELECTRIC	t	2026-11-22 11:06:32.205	2026-11-22 11:06:32.205
51cd1921-76c9-4b82-9a67-5688ae2d6f31	e05d0c61-e1ae-4921-8453-3dc06525dc08	Porsche	911 GT3	2023	EDGE-A-1250	\N	\N	PETROL	t	2026-11-22 10:27:51.268	2026-11-22 10:27:51.268
b1cd0de9-5fde-4d7a-afd9-d4efd8bbf325	87f1f769-abfe-4f96-b595-46a1bc413388	Tesla	Model S Plaid	2024	EDGE-B-1273	\N	\N	ELECTRIC	t	2026-11-22 10:27:51.282	2026-11-22 10:27:51.282
f4f34e7f-632a-4c44-9dac-dd01760a638f	245a9356-c816-4507-8269-0fc18dd346f9	Porsche	911 GT3	2023	EDGE-A-1735	\N	\N	PETROL	t	2026-11-22 10:59:11.751	2026-11-22 10:59:11.751
68e94048-003e-44ef-9279-e9aea1e4871a	e4414a47-df1f-4ad5-9049-bf14c3ed41cc	Tesla	Model S Plaid	2024	EDGE-B-1756	\N	\N	ELECTRIC	t	2026-11-22 10:59:11.764	2026-11-22 10:59:11.764
26f2f846-36f2-4118-bf6f-283738a7ba33	e22478b0-00a4-44f8-b146-3649213c7a20	Audi	RS6 Avant	2024	E2E-0176			PETROL	f	2026-11-22 12:03:30.229	2026-11-22 12:03:30.229
d5446d27-687e-437d-ae1e-c32557d71210	e22478b0-00a4-44f8-b146-3649213c7a20	Audi	RS6 Avant	2024	E2E-3615			PETROL	f	2026-11-22 11:07:03.672	2026-11-22 11:07:03.672
42527336-e329-4b38-9fb3-5430e812ae29	50ade227-7e8a-46fd-8685-2e2878c91b01	Porsche	911 GT3	2023	EDGE-A-2815	\N	\N	PETROL	t	2026-11-22 11:25:32.833	2026-11-22 11:25:32.833
0a8a43db-8772-4d54-9f33-07a713bf8dc0	bc905c8b-feee-4610-8e4c-c09401916566	Tesla	Model S Plaid	2024	EDGE-B-2838	\N	\N	ELECTRIC	t	2026-11-22 11:25:32.848	2026-11-22 11:25:32.848
45b61161-5415-4ad2-ae34-c28f07ebb8e8	bbdc9439-1243-4dec-a18b-8b6512cede79	Porsche	911 GT3	2023	EDGE-A-8883	\N	\N	PETROL	t	2026-11-22 11:36:38.904	2026-11-22 11:36:38.904
cc63d73f-ba70-4dfe-96b6-c3a7dade93e6	c8830dc5-34eb-4c8c-a34d-e1ff3bc55773	Tesla	Model S Plaid	2024	EDGE-B-8909	\N	\N	ELECTRIC	t	2026-11-22 11:36:38.922	2026-11-22 11:36:38.922
a1f35bc6-bdfa-4770-ac93-26622cd77c2e	eeec89bd-77f1-4b87-b039-63f9778b4621	Porsche	911 GT3	2023	EDGE-A-4622	\N	\N	PETROL	t	2026-11-22 11:55:24.641	2026-11-22 11:55:24.641
384836fb-2ab2-4ce8-a79c-0dc2c8a27240	189ee5a7-5c5b-4120-a133-e29310c9dc2a	Tesla	Model S Plaid	2024	EDGE-B-4646	\N	\N	ELECTRIC	t	2026-11-22 11:55:24.656	2026-11-22 11:55:24.656
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: vbrs_admin
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
e9ff7246-f828-4098-8119-3f879ca7d262	2c2bebde3a50b629adf5f23168891055e7bd111735cebae96837681798585258	2026-11-22 12:28:30.13759+05:30	20261122065830_init	\N	\N	2026-11-22 12:28:30.049553+05:30	1
c642a4be-79de-4ea7-a002-7884101b765b	9c9cb055952c92f554f4819335cedd4657f6aa21fc90a689c344595306f0794c	2026-11-22 18:24:42.012449+05:30	20261122182500_add_saved_addresses_and_mechanic_fields	\N	\N	2026-11-22 18:24:41.98885+05:30	1
\.


--
-- Name: AuditLog AuditLog_pkey; Type: CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."AuditLog"
    ADD CONSTRAINT "AuditLog_pkey" PRIMARY KEY (id);


--
-- Name: BreakdownReport BreakdownReport_pkey; Type: CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."BreakdownReport"
    ADD CONSTRAINT "BreakdownReport_pkey" PRIMARY KEY (id);


--
-- Name: Complaint Complaint_pkey; Type: CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."Complaint"
    ADD CONSTRAINT "Complaint_pkey" PRIMARY KEY (id);


--
-- Name: MechanicLocation MechanicLocation_pkey; Type: CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."MechanicLocation"
    ADD CONSTRAINT "MechanicLocation_pkey" PRIMARY KEY (id);


--
-- Name: MechanicProfile MechanicProfile_pkey; Type: CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."MechanicProfile"
    ADD CONSTRAINT "MechanicProfile_pkey" PRIMARY KEY (id);


--
-- Name: MechanicService MechanicService_pkey; Type: CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."MechanicService"
    ADD CONSTRAINT "MechanicService_pkey" PRIMARY KEY (id);


--
-- Name: Notification Notification_pkey; Type: CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."Notification"
    ADD CONSTRAINT "Notification_pkey" PRIMARY KEY (id);


--
-- Name: RefreshToken RefreshToken_pkey; Type: CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."RefreshToken"
    ADD CONSTRAINT "RefreshToken_pkey" PRIMARY KEY (id);


--
-- Name: ReportImage ReportImage_pkey; Type: CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."ReportImage"
    ADD CONSTRAINT "ReportImage_pkey" PRIMARY KEY (id);


--
-- Name: Review Review_pkey; Type: CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."Review"
    ADD CONSTRAINT "Review_pkey" PRIMARY KEY (id);


--
-- Name: SavedAddress SavedAddress_pkey; Type: CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."SavedAddress"
    ADD CONSTRAINT "SavedAddress_pkey" PRIMARY KEY (id);


--
-- Name: ServiceRequest ServiceRequest_pkey; Type: CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."ServiceRequest"
    ADD CONSTRAINT "ServiceRequest_pkey" PRIMARY KEY (id);


--
-- Name: ServiceStatusHistory ServiceStatusHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."ServiceStatusHistory"
    ADD CONSTRAINT "ServiceStatusHistory_pkey" PRIMARY KEY (id);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: Vehicle Vehicle_pkey; Type: CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."Vehicle"
    ADD CONSTRAINT "Vehicle_pkey" PRIMARY KEY (id);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: AuditLog_action_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "AuditLog_action_idx" ON public."AuditLog" USING btree (action);


--
-- Name: AuditLog_entityName_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "AuditLog_entityName_idx" ON public."AuditLog" USING btree ("entityName");


--
-- Name: AuditLog_timestamp_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "AuditLog_timestamp_idx" ON public."AuditLog" USING btree ("timestamp");


--
-- Name: BreakdownReport_category_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "BreakdownReport_category_idx" ON public."BreakdownReport" USING btree (category);


--
-- Name: BreakdownReport_createdAt_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "BreakdownReport_createdAt_idx" ON public."BreakdownReport" USING btree ("createdAt");


--
-- Name: BreakdownReport_customerId_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "BreakdownReport_customerId_idx" ON public."BreakdownReport" USING btree ("customerId");


--
-- Name: BreakdownReport_latitude_longitude_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "BreakdownReport_latitude_longitude_idx" ON public."BreakdownReport" USING btree (latitude, longitude);


--
-- Name: Complaint_filedById_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "Complaint_filedById_idx" ON public."Complaint" USING btree ("filedById");


--
-- Name: Complaint_serviceRequestId_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "Complaint_serviceRequestId_idx" ON public."Complaint" USING btree ("serviceRequestId");


--
-- Name: Complaint_status_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "Complaint_status_idx" ON public."Complaint" USING btree (status);


--
-- Name: MechanicLocation_latitude_longitude_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "MechanicLocation_latitude_longitude_idx" ON public."MechanicLocation" USING btree (latitude, longitude);


--
-- Name: MechanicLocation_mechanicId_key; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE UNIQUE INDEX "MechanicLocation_mechanicId_key" ON public."MechanicLocation" USING btree ("mechanicId");


--
-- Name: MechanicProfile_availabilityStatus_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "MechanicProfile_availabilityStatus_idx" ON public."MechanicProfile" USING btree ("availabilityStatus");


--
-- Name: MechanicProfile_ratingAverage_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "MechanicProfile_ratingAverage_idx" ON public."MechanicProfile" USING btree ("ratingAverage");


--
-- Name: MechanicProfile_userId_key; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE UNIQUE INDEX "MechanicProfile_userId_key" ON public."MechanicProfile" USING btree ("userId");


--
-- Name: MechanicProfile_verificationStatus_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "MechanicProfile_verificationStatus_idx" ON public."MechanicProfile" USING btree ("verificationStatus");


--
-- Name: MechanicService_mechanicId_category_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "MechanicService_mechanicId_category_idx" ON public."MechanicService" USING btree ("mechanicId", category);


--
-- Name: Notification_createdAt_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "Notification_createdAt_idx" ON public."Notification" USING btree ("createdAt");


--
-- Name: Notification_userId_isRead_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "Notification_userId_isRead_idx" ON public."Notification" USING btree ("userId", "isRead");


--
-- Name: RefreshToken_tokenHash_key; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE UNIQUE INDEX "RefreshToken_tokenHash_key" ON public."RefreshToken" USING btree ("tokenHash");


--
-- Name: RefreshToken_userId_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "RefreshToken_userId_idx" ON public."RefreshToken" USING btree ("userId");


--
-- Name: ReportImage_reportId_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "ReportImage_reportId_idx" ON public."ReportImage" USING btree ("reportId");


--
-- Name: Review_mechanicId_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "Review_mechanicId_idx" ON public."Review" USING btree ("mechanicId");


--
-- Name: Review_rating_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "Review_rating_idx" ON public."Review" USING btree (rating);


--
-- Name: Review_serviceRequestId_key; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE UNIQUE INDEX "Review_serviceRequestId_key" ON public."Review" USING btree ("serviceRequestId");


--
-- Name: SavedAddress_userId_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "SavedAddress_userId_idx" ON public."SavedAddress" USING btree ("userId");


--
-- Name: ServiceRequest_breakdownReportId_key; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE UNIQUE INDEX "ServiceRequest_breakdownReportId_key" ON public."ServiceRequest" USING btree ("breakdownReportId");


--
-- Name: ServiceRequest_createdAt_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "ServiceRequest_createdAt_idx" ON public."ServiceRequest" USING btree ("createdAt");


--
-- Name: ServiceRequest_currentStatus_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "ServiceRequest_currentStatus_idx" ON public."ServiceRequest" USING btree ("currentStatus");


--
-- Name: ServiceRequest_customerId_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "ServiceRequest_customerId_idx" ON public."ServiceRequest" USING btree ("customerId");


--
-- Name: ServiceRequest_mechanicId_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "ServiceRequest_mechanicId_idx" ON public."ServiceRequest" USING btree ("mechanicId");


--
-- Name: ServiceStatusHistory_serviceRequestId_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "ServiceStatusHistory_serviceRequestId_idx" ON public."ServiceStatusHistory" USING btree ("serviceRequestId");


--
-- Name: ServiceStatusHistory_timestamp_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "ServiceStatusHistory_timestamp_idx" ON public."ServiceStatusHistory" USING btree ("timestamp");


--
-- Name: User_email_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "User_email_idx" ON public."User" USING btree (email);


--
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);


--
-- Name: User_role_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "User_role_idx" ON public."User" USING btree (role);


--
-- Name: Vehicle_licensePlate_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "Vehicle_licensePlate_idx" ON public."Vehicle" USING btree ("licensePlate");


--
-- Name: Vehicle_userId_idx; Type: INDEX; Schema: public; Owner: vbrs_admin
--

CREATE INDEX "Vehicle_userId_idx" ON public."Vehicle" USING btree ("userId");


--
-- Name: AuditLog AuditLog_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."AuditLog"
    ADD CONSTRAINT "AuditLog_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: BreakdownReport BreakdownReport_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."BreakdownReport"
    ADD CONSTRAINT "BreakdownReport_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: BreakdownReport BreakdownReport_vehicleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."BreakdownReport"
    ADD CONSTRAINT "BreakdownReport_vehicleId_fkey" FOREIGN KEY ("vehicleId") REFERENCES public."Vehicle"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Complaint Complaint_filedById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."Complaint"
    ADD CONSTRAINT "Complaint_filedById_fkey" FOREIGN KEY ("filedById") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Complaint Complaint_serviceRequestId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."Complaint"
    ADD CONSTRAINT "Complaint_serviceRequestId_fkey" FOREIGN KEY ("serviceRequestId") REFERENCES public."ServiceRequest"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Complaint Complaint_targetUserId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."Complaint"
    ADD CONSTRAINT "Complaint_targetUserId_fkey" FOREIGN KEY ("targetUserId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: MechanicLocation MechanicLocation_mechanicId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."MechanicLocation"
    ADD CONSTRAINT "MechanicLocation_mechanicId_fkey" FOREIGN KEY ("mechanicId") REFERENCES public."MechanicProfile"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: MechanicProfile MechanicProfile_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."MechanicProfile"
    ADD CONSTRAINT "MechanicProfile_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: MechanicService MechanicService_mechanicId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."MechanicService"
    ADD CONSTRAINT "MechanicService_mechanicId_fkey" FOREIGN KEY ("mechanicId") REFERENCES public."MechanicProfile"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Notification Notification_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."Notification"
    ADD CONSTRAINT "Notification_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: RefreshToken RefreshToken_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."RefreshToken"
    ADD CONSTRAINT "RefreshToken_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ReportImage ReportImage_reportId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."ReportImage"
    ADD CONSTRAINT "ReportImage_reportId_fkey" FOREIGN KEY ("reportId") REFERENCES public."BreakdownReport"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Review Review_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."Review"
    ADD CONSTRAINT "Review_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Review Review_mechanicId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."Review"
    ADD CONSTRAINT "Review_mechanicId_fkey" FOREIGN KEY ("mechanicId") REFERENCES public."MechanicProfile"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Review Review_serviceRequestId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."Review"
    ADD CONSTRAINT "Review_serviceRequestId_fkey" FOREIGN KEY ("serviceRequestId") REFERENCES public."ServiceRequest"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SavedAddress SavedAddress_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."SavedAddress"
    ADD CONSTRAINT "SavedAddress_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ServiceRequest ServiceRequest_breakdownReportId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."ServiceRequest"
    ADD CONSTRAINT "ServiceRequest_breakdownReportId_fkey" FOREIGN KEY ("breakdownReportId") REFERENCES public."BreakdownReport"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ServiceRequest ServiceRequest_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."ServiceRequest"
    ADD CONSTRAINT "ServiceRequest_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ServiceRequest ServiceRequest_mechanicId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."ServiceRequest"
    ADD CONSTRAINT "ServiceRequest_mechanicId_fkey" FOREIGN KEY ("mechanicId") REFERENCES public."MechanicProfile"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ServiceStatusHistory ServiceStatusHistory_changedById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."ServiceStatusHistory"
    ADD CONSTRAINT "ServiceStatusHistory_changedById_fkey" FOREIGN KEY ("changedById") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ServiceStatusHistory ServiceStatusHistory_serviceRequestId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."ServiceStatusHistory"
    ADD CONSTRAINT "ServiceStatusHistory_serviceRequestId_fkey" FOREIGN KEY ("serviceRequestId") REFERENCES public."ServiceRequest"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Vehicle Vehicle_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vbrs_admin
--

ALTER TABLE ONLY public."Vehicle"
    ADD CONSTRAINT "Vehicle_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict clSnZMTu7kVHKIIldZYIaCZ0doaeDIDc6x0DyRkBBmsUSFGCTPU2XlPDc0htNHj

