export type UserRole = 'CUSTOMER' | 'MECHANIC' | 'ADMIN';

export type PowertrainType = 'PETROL' | 'DIESEL' | 'ELECTRIC' | 'HYBRID' | 'CNG';

export type BreakdownCategory =
  | 'ENGINE_FAILURE'
  | 'TRANSMISSION_ISSUE'
  | 'FLAT_TIRE_WHEEL'
  | 'BATTERY_DEAD_ELECTRICAL'
  | 'BRAKE_SYSTEM_FAILURE'
  | 'OVERHEATING_COOLANT'
  | 'FUEL_EMPTY_OR_CONTAMINATED'
  | 'LOCKOUT_KEY_LOST'
  | 'COLLISION_ACCIDENT'
  | 'OTHER_UNKNOWN';

export type SeverityLevel = 'LOW' | 'MEDIUM' | 'CRITICAL';

export type ServiceRequestStatus =
  | 'SUBMITTED'
  | 'SEARCHING'
  | 'ASSIGNED'
  | 'ACCEPTED'
  | 'EN_ROUTE'
  | 'ARRIVED'
  | 'IN_PROGRESS'
  | 'COMPLETED'
  | 'CANCELLED';

export interface User {
  id: string;
  email: string;
  fullName: string;
  phone?: string;
  role: UserRole;
  avatarUrl?: string;
  createdAt: string;
}

export interface Vehicle {
  id: string;
  userId: string;
  make: string;
  model: string;
  year: number;
  licensePlate: string;
  vin?: string;
  color?: string;
  powertrain: PowertrainType;
  isDefault: boolean;
}

export interface SavedAddress {
  id: string;
  userId: string;
  label: string;
  address: string;
  latitude?: number | null;
  longitude?: number | null;
  isDefault: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface MechanicProfile {
  id: string;
  userId: string;
  workshopName?: string;
  workshopAddress?: string;
  tradeLicenseNumber?: string;
  experienceYears: number;
  verificationStatus: 'PENDING' | 'APPROVED' | 'REJECTED';
  availabilityStatus: 'OFFLINE' | 'AVAILABLE' | 'ON_JOB';
  operatingRadiusKm: number;
  ratingAverage: number;
  totalReviews: number;
  totalJobsCompleted: number;
  certifications?: string[];
  specializations?: string[];
  bio?: string;
  latitude?: number;
  longitude?: number;
  distanceKm?: number;
}

export interface ReportImage {
  id: string;
  reportId: string;
  filePath: string;
  fileName: string;
  fileSize: number;
  mimeType: string;
  createdAt: string;
}

export interface BreakdownReport {
  id: string;
  customerId: string;
  vehicleId?: string | null;
  category: BreakdownCategory;
  severity: SeverityLevel;
  description: string;
  latitude: number;
  longitude: number;
  addressText?: string | null;
  requiresTowing: boolean;
  ruleDiagnosis?: string | null;
  createdAt: string;
  updatedAt: string;
  images?: ReportImage[];
  vehicle?: Vehicle;
  customer?: {
    id: string;
    fullName: string;
    email: string;
    phone?: string;
  };
  serviceRequest?: {
    id: string;
    currentStatus: ServiceRequestStatus;
    mechanicId?: string | null;
    mechanic?: any;
    statusHistory?: Array<{
      id: string;
      fromStatus?: ServiceRequestStatus | null;
      toStatus: ServiceRequestStatus;
      timestamp: string;
      notes?: string;
    }>;
  };
}

export interface MechanicEarnings {
  totalRevenue: number;
  totalLabor: number;
  totalParts: number;
  totalDiagnostic: number;
  completedJobsCount: number;
  averageJobValue: number;
  recentPayoutRecords: Array<{
    requestId: string;
    completedAt: string;
    breakdownCategory: string;
    vehicle?: {
      make: string;
      model: string;
      year: number;
      licensePlate: string;
    } | null;
    diagnosticQuote: number;
    laborCost: number;
    partsCost: number;
    totalAmount: number;
  }>;
}
