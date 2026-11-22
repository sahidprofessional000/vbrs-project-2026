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

export interface MechanicProfile {
  id: string;
  userId: string;
  workshopName?: string;
  tradeLicenseNumber?: string;
  experienceYears: number;
  verificationStatus: 'PENDING' | 'APPROVED' | 'REJECTED';
  availabilityStatus: 'OFFLINE' | 'AVAILABLE' | 'ON_JOB';
  operatingRadiusKm: number;
  ratingAverage: number;
  totalReviews: number;
  totalJobsCompleted: number;
  latitude?: number;
  longitude?: number;
  distanceKm?: number;
}
