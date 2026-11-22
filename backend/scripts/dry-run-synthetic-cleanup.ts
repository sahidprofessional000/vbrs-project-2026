import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function dryRunCleanup() {
  console.log('========================================================================');
  console.log('>>> [DRY-RUN SIMULATION] Synthetic Test Data Identification & Impact Ledger');
  console.log('========================================================================\n');

  // Canonical Seed emails
  const seedEmails = [
    'admin@vbrs.local',
    'mechanic.alex@vbrs.local',
    'mechanic.marcus@vbrs.local',
    'customer.john@vbrs.local',
    'customer.sarah@vbrs.local',
  ];

  // Genuine emails
  const genuineEmails = ['sahid.0777777@gmail.com'];

  // Test regex
  const testEmailRegex = /^(m\d|audit|sec|exp|test|temp|dummy|fake|loadtest)\./i;

  // 1. Identify users to delete
  const allUsers = await prisma.user.findMany({ select: { id: true, email: true, fullName: true, role: true } });
  const usersToDelete: string[] = [];
  const genuineUsersKept: string[] = [];
  const seedUsersKept: string[] = [];

  for (const u of allUsers) {
    if (genuineEmails.includes(u.email)) {
      genuineUsersKept.push(`${u.email} (${u.fullName})`);
    } else if (seedEmails.includes(u.email)) {
      seedUsersKept.push(`${u.email} (${u.fullName})`);
    } else if (testEmailRegex.test(u.email) || u.email.includes('.1795') || u.fullName.includes('Hasselhoff') || u.fullName.includes('SecTest')) {
      usersToDelete.push(u.id);
    } else {
      // Ambiguous: check if user has actual activity
      genuineUsersKept.push(`${u.email} (${u.fullName}) [AMBIGUOUS - PRESERVED]`);
    }
  }

  // 2. Identify duplicate/test vehicles to delete
  // On customer.john@vbrs.local, keep original 2 vehicles (Toyota Camry NYC-7842, Tesla Model 3 EV-88219), delete E2E-xxxx duplicates
  const testVehicles = await prisma.vehicle.findMany({
    where: {
      OR: [
        { userId: { in: usersToDelete } },
        { licensePlate: { startsWith: 'E2E-' } },
      ],
    },
    select: { id: true, make: true, model: true, licensePlate: true, userId: true },
  });

  // 3. Identify test breakdown reports
  const testReports = await prisma.breakdownReport.findMany({
    where: {
      OR: [
        { customerId: { in: usersToDelete } },
        { description: { contains: 'Test' } },
        { description: { contains: 'E2E' } },
        { description: { contains: 'Autonomous' } },
      ],
      AND: [
        { customerId: { notIn: allUsers.filter((u) => genuineEmails.includes(u.email)).map((u) => u.id) } },
      ],
    },
    select: { id: true, customerId: true, category: true },
  });

  const testReportIds = testReports.map((r) => r.id);

  // 4. Identify service requests to delete
  const testServiceRequests = await prisma.serviceRequest.findMany({
    where: {
      OR: [
        { breakdownReportId: { in: testReportIds } },
        { customerId: { in: usersToDelete } },
      ],
      AND: [
        { customerId: { notIn: allUsers.filter((u) => genuineEmails.includes(u.email)).map((u) => u.id) } },
      ],
    },
    select: { id: true },
  });
  const testServiceRequestIds = testServiceRequests.map((s) => s.id);

  // 5. Identify test complaints to delete
  const testComplaints = await prisma.complaint.findMany({
    where: {
      OR: [
        { filedById: { in: usersToDelete } },
        { subject: { contains: 'Late Arrival & Tow Rig Discrepancy' } },
      ],
    },
    select: { id: true, subject: true },
  });

  // 6. Identify test reviews to delete
  const testReviews = await prisma.review.findMany({
    where: {
      OR: [
        { customerId: { in: usersToDelete } },
        { comment: { contains: 'Alex arrived in 8 minutes' } },
        { comment: { contains: 'Service completed, but dispatch took longer' } },
      ],
    },
    select: { id: true, rating: true },
  });

  // 7. Audit logs from test entities
  const testAuditLogs = await prisma.auditLog.findMany({
    where: {
      userId: { in: usersToDelete },
    },
    select: { id: true },
  });

  console.log('--- DRY-RUN IDENTIFICATION SUMMARY ---');
  console.log(`Users total: ${allUsers.length}`);
  console.log(`  -> Genuine Kept (${genuineUsersKept.length}):`, genuineUsersKept);
  console.log(`  -> Seed Kept (${seedUsersKept.length}):`, seedUsersKept);
  console.log(`  -> Proposed Test Users to Delete: ${usersToDelete.length}`);
  console.log(`Vehicles proposed to delete: ${testVehicles.length}`);
  console.log(`Breakdown Reports proposed to delete: ${testReportIds.length}`);
  console.log(`Service Requests proposed to delete: ${testServiceRequestIds.length}`);
  console.log(`Complaints proposed to delete: ${testComplaints.length}`);
  console.log(`Reviews proposed to delete: ${testReviews.length}`);
  console.log(`Audit Logs proposed to delete: ${testAuditLogs.length}`);

  // Projected Post-Cleanup Database State
  const projectedState = {
    Users: allUsers.length - usersToDelete.length,
    MechanicProfiles: 2, // Only Alex & Marcus
    Vehicles: (await prisma.vehicle.count()) - testVehicles.length,
    BreakdownReports: (await prisma.breakdownReport.count()) - testReportIds.length,
    ServiceRequests: (await prisma.serviceRequest.count()) - testServiceRequestIds.length,
    Complaints: (await prisma.complaint.count()) - testComplaints.length,
    Reviews: (await prisma.review.count()) - testReviews.length,
    AuditLogs: (await prisma.auditLog.count()) - testAuditLogs.length,
  };

  console.log('\n--- PROJECTED DATABASE STATE AFTER CLEANUP ---');
  console.table(projectedState);
}

dryRunCleanup()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
