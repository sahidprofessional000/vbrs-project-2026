# APPENDIX A: VBRS REST & WEBSOCKET API SPECIFICATION

## 1. Authentication & Identity Management
| Method | Endpoint | Access Level | Request Body | Response Status | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `POST` | `/api/auth/register` | Public | `{ email, password, fullName, phone, role }` | 201 Created | Registers a new user (Customer or Mechanic). Hashes password with bcrypt (12 rounds). |
| `POST` | `/api/auth/login` | Public | `{ email, password }` | 200 OK | Authenticates user; returns `{ accessToken, refreshToken, user }`. |
| `POST` | `/api/auth/refresh` | Bearer Refresh | `{ refreshToken }` | 200 OK | Validates hashed refresh token in PostgreSQL; rotates and issues new token pair. |
| `POST` | `/api/auth/logout` | Authenticated | None | 200 OK | Clears refresh token hash in database and terminates session. |
| `GET` | `/api/auth/me` | Authenticated | None | 200 OK | Returns currently authenticated user record and profile details. |

## 2. Vehicle Garage Management
| Method | Endpoint | Access Level | Request Body | Response Status | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/vehicles` | Customer | None | 200 OK | Lists all registered vehicles belonging to the authenticated customer. |
| `POST` | `/api/vehicles` | Customer | `{ make, model, year, plateNumber, color }` | 201 Created | Registers a new vehicle in the customer's garage. |
| `GET` | `/api/vehicles/:id` | Customer | None | 200 OK | Retrieves single vehicle details with incident history. |
| `PUT` | `/api/vehicles/:id` | Customer | `{ make?, model?, year?, color? }` | 200 OK | Updates existing vehicle details. |
| `DELETE` | `/api/vehicles/:id` | Customer | None | 200 OK | Removes vehicle from customer garage if no active incidents exist. |

## 3. Breakdown Incident & Emergency Dispatch
| Method | Endpoint | Access Level | Request Body | Response Status | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `POST` | `/api/breakdowns` | Customer | `{ vehicleId, latitude, longitude, address, issueDescription, subsystem }` | 201 Created | Initiates roadside emergency ticket and starts proximity discovery. |
| `GET` | `/api/breakdowns/:id` | Authenticated | None | 200 OK | Retrieves breakdown report status, location coordinates, and dispatch status. |
| `POST` | `/api/breakdowns/:id/photos` | Customer | `multipart/form-data (image)` | 201 Created | Attaches photographic evidence to breakdown incident. |
| `GET` | `/api/breakdowns/nearby` | Authenticated | Query: `lat`, `lng`, `radiusKm` | 200 OK | Haversine proximity query returning available mechanics within radius. |

## 4. Mechanic Operations & Service Requests
| Method | Endpoint | Access Level | Request Body | Response Status | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/mechanic/profile` | Mechanic | None | 200 OK | Retrieves mechanic operational profile, workshop info, and metrics. |
| `PUT` | `/api/mechanic/profile` | Mechanic | `{ workshopName, serviceRadiusKm, latitude, longitude, specialties }` | 200 OK | Updates mechanic workshop parameters and service range. |
| `POST` | `/api/mechanic/beacon` | Mechanic | `{ isAvailable: boolean }` | 200 OK | Toggles live availability beacon on/off for incoming dispatches. |
| `GET` | `/api/service-requests/active` | Mechanic | None | 200 OK | Lists active emergency assignments for current technician. |
| `POST` | `/api/service-requests/:id/accept` | Mechanic | `{ etaMinutes: number }` | 200 OK | Accepts incoming emergency dispatch and updates status to `ACCEPTED`. |
| `POST` | `/api/service-requests/:id/decline` | Mechanic | `{ reason?: string }` | 200 OK | Rejects dispatch and re-routes incident to next available technician. |
| `PATCH` | `/api/service-requests/:id/status`| Mechanic | `{ status: 'IN_PROGRESS' | 'COMPLETED' }` | 200 OK | Advances service lifecycle and finalizes repair. |

## 5. Administrative Control & Auditing
| Method | Endpoint | Access Level | Request Body | Response Status | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/admin/metrics` | Admin | None | 200 OK | Calculates real-time PostgreSQL database aggregates (users, tickets, uptime). |
| `GET` | `/api/admin/technicians` | Admin | Query: `status` | 200 OK | Lists technician accounts with pending/approved credential status. |
| `PATCH` | `/api/admin/technicians/:id/verify` | Admin | `{ isVerified: boolean }` | 200 OK | Approves or revokes mechanic operating license in system. |
| `GET` | `/api/admin/disputes` | Admin | None | 200 OK | Fetches open complaints and disputes filed by users. |
| `PATCH` | `/api/admin/disputes/:id` | Admin | `{ status, resolution }` | 200 OK | Resolves customer dispute ticket and records audit history. |
| `GET` | `/api/admin/audit-logs` | Admin | Query: `limit`, `offset`, `entity` | 200 OK | Queries tamper-evident security audit logs with IP and user metadata. |

## 6. WebSocket Real-Time Events (`/events`)
- `join_room`: Joins private incident channel using JWT authentication (`room: incident_<id>`).
- `mechanic_location_update`: Emits live GPS coordinate pings from mobile technician (`{ lat, lng, speed, heading }`).
- `dispatch_status_changed`: Broadcasts status transitions (`PENDING`, `ACCEPTED`, `EN_ROUTE`, `ON_SITE`, `COMPLETED`).
- `emergency_alert`: Server-sent push alert to nearby mechanics within the Haversine circular boundary.
