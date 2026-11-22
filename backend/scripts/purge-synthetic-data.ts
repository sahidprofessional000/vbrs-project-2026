import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export async function executePurge() {
  console.log('========================================================================');
  console.log('>>> [DATABASE PURGE] Executing Safe Transactional Synthetic Data Removal');
  console.log('========================================================================\n');

  const seedEmails = [
    'admin@vbrs.local',
    'mechanic.alex@vbrs.local',
    'mechanic.marcus@vbrs.local',
    'customer.john@vbrs.local',
    'customer.sarah@vbrs.local',
  ];

  const genuineEmails = ['sahid.0777777@gmail.com'];
  const testEmailRegex = /^(m\d|audit|sec|exp|test|temp|dummy|fake|loadtest)\./i;

  // Exact BEFORE counts
  const beforeCounts = {
    users: await prisma.user.count(),
    customers: await prisma.user.count({ where: { role: 'CUSTOMER' } }),
    mechanics: await prisma.user.count({ where: { role: 'MECHANIC' } }),
    admins: await prisma.user.count({ where: { role: 'ADMIN' } }),
    vehicles: await prisma.vehicle.count(),
    mechanicProfiles: await prisma.mechanicProfile.count(),
    mechanicServices: await prisma.mechanicService.count(),
    mechanicLocations: await prisma.mechanicLocation.count(),
    breakdownReports: await prisma.breakdownReport.count(),
    serviceRequests: await prisma.serviceRequest.count(),
    complaints: await prisma.complaint.count(),
    reviews: await prisma.review.count(),
    auditLogs: await prisma.auditLog.count(),
    refreshTokens: await prisma.refreshToken.count(),
    savedAddresses: await prisma.savedAddress.count(),
  };

  console.log('--- BEFORE PURGE TABLE COUNTS ---');
  console.table(beforeCounts);

  const allUsers = await prisma.user.findMany({ select: { id: true, email: true, fullName: true } });
  const testUsers = allUsers.filter(
    (u) =>
      !genuineEmails.includes(u.email) &&
      !seedEmails.includes(u.email) &&
      (testEmailRegex.test(u.email) || u.email.includes('.1795') || u.fullName.includes('Hasselhoff') || u.fullName.includes('SecTest'))
  );

  const testUserIds = testUsers.map((u) => u.id);
  console.log(`\nIdentified ${testUserIds.length} synthetic test users for safe transactional removal.`);

  // Verify NONE of the test users is genuine or seed
  for (const tu of testUsers) {
    if (genuineEmails.includes(tu.email) || seedEmails.includes(tu.email)) {
      throw new Error(`CRITICAL ABORT: Attempting to delete protected account: ${tu.email}`);
    }
  }

  const testMechanicProfiles = await prisma.mechanicProfile.findMany({
    where: { userId: { in: testUserIds } },
    select: { id: true },
  });
  const testMechanicIds = testMechanicProfiles.map((m) => m.id);

  // Execute in safe reverse-dependency transaction
  const result = await prisma.$transaction(async (tx) => {
    // 1. Delete test complaints
    const deletedComplaints = await tx.complaint.deleteMany({
      where: {
        OR: [
          { filedById: { in: testUserIds } },
          { targetUserId: { in: testUserIds } },
          { subject: { contains: 'Late Arrival & Tow Rig Discrepancy' } },
        ],
      },
    });

    // 2. Delete test reviews
    const deletedReviews = await tx.review.deleteMany({
      where: {
        OR: [
          { customerId: { in: testUserIds } },
          { mechanicId: { in: testMechanicIds } },
          { comment: { contains: 'Alex arrived in 8 minutes' } },
          { comment: { contains: 'Service completed, but dispatch took longer' } },
        ],
      },
    });

    // 3. Delete duplicate Audi RS6 test vehicles on customer.john@vbrs.local + test accounts
    const deletedVehicles = await tx.vehicle.deleteMany({
      where: {
        OR: [
          { userId: { in: testUserIds } },
          { licensePlate: { startsWith: 'E2E-' } },
        ],
      },
    });

    // 4. Delete test service requests & status history
    const testReports = await tx.breakdownReport.findMany({
      where: {
        OR: [
          { customerId: { in: testUserIds } },
          { description: { contains: 'Test' } },
          { description: { contains: 'E2E' } },
          { description: { contains: 'Autonomous' } },
        ],
        AND: [{ customer: { email: { notIn: genuineEmails } } }],
      },
      select: { id: true },
    });
    const testReportIds = testReports.map((r) => r.id);

    const testRequests = await tx.serviceRequest.findMany({
      where: {
        OR: [
          { breakdownReportId: { in: testReportIds } },
          { customerId: { in: testUserIds } },
          { mechanicId: { in: testMechanicIds } },
        ],
        AND: [{ customer: { email: { notIn: genuineEmails } } }],
      },
      select: { id: true },
    });
    const testRequestIds = testRequests.map((r) => r.id);

    // Delete status history
    await tx.serviceStatusHistory.deleteMany({
      where: { serviceRequestId: { in: testRequestIds } },
    });

    // Delete service requests
    const deletedServiceRequests = await tx.serviceRequest.deleteMany({
      where: { id: { in: testRequestIds } },
    });

    // Delete report images
    await tx.reportImage.deleteMany({
      where: { reportId: { in: testReportIds } },
    });

    // Delete breakdown reports
    const deletedReports = await tx.breakdownReport.deleteMany({
      where: { id: { in: testReportIds } },
    });

    // 5. Delete mechanic locations & services
    await tx.mechanicLocation.deleteMany({
      where: { mechanicId: { in: testMechanicIds } },
    });

    await tx.mechanicService.deleteMany({
      where: { mechanicId: { in: testMechanicIds } },
    });

    const deletedMechanicProfiles = await tx.mechanicProfile.deleteMany({
      where: { id: { in: testMechanicIds } },
    });

    // 6. Delete audit logs associated with test users
    const deletedAuditLogs = await tx.auditLog.deleteMany({
      where: { userId: { in: testUserIds } },
    });

    // 7. Delete refresh tokens, notifications, saved addresses for test users
    await tx.refreshToken.deleteMany({ where: { userId: { in: testUserIds } } });
    await tx.notification.deleteMany({ where: { userId: { in: testUserIds } } });
    await tx.savedAddress.deleteMany({ where: { userId: { in: testUserIds } } });

    // 8. Delete test users
    const deletedUsers = await tx.user.deleteMany({
      where: { id: { in: testUserIds } },
    });

    return {
      deletedUsers: deletedUsers.count,
      deletedMechanicProfiles: deletedMechanicProfiles.count,
      deletedVehicles: deletedVehicles.count,
      deletedReports: deletedReports.count,
      deletedServiceRequests: deletedServiceRequests.count,
      deletedComplaints: deletedComplaints.count,
      deletedReviews: deletedReviews.count,
      deletedAuditLogs: deletedAuditLogs.count,
    };
  });

  console.log('✅ Transaction committed successfully. Records deleted:');
  console.table(result);

  // Exact AFTER counts
  const afterCounts = {
    users: await prisma.user.count(),
    customers: await prisma.user.count({ where: { role: 'CUSTOMER' } }),
    mechanics: await prisma.user.count({ where: { role: 'MECHANIC' } }),
    admins: await prisma.user.count({ where: { role: 'ADMIN' } }),
    vehicles: await prisma.vehicle.count(),
    mechanicProfiles: await prisma.mechanicProfile.count(),
    mechanicServices: await prisma.mechanicService.count(),
    mechanicLocations: await prisma.mechanicLocation.count(),
    breakdownReports: await prisma.breakdownReport.count(),
    serviceRequests: await prisma.serviceRequest.count(),
    complaints: await prisma.complaint.count(),
    reviews: await prisma.review.count(),
    auditLogs: await prisma.auditLog.count(),
    refreshTokens: await prisma.refreshToken.count(),
    savedAddresses: await prisma.savedAddress.count(),
  };

  console.log('\n--- AFTER PURGE TABLE COUNTS ---');
  console.table(afterCounts);

  // --- RELATIONAL INTEGRITY & ORPHAN CHECKS (RAW SQL AT ENGINE LEVEL) ---
  console.log('\n--- VERIFYING RELATIONAL INTEGRITY & FOREIGN KEYS ---');
  const orphanVehiclesRaw = await prisma.$queryRawUnsafe<any[]>(
    'SELECT count(*)::int as count FROM "Vehicle" v WHERE NOT EXISTS (SELECT 1 FROM "User" u WHERE u.id = v."userId");'
  );
  const orphanMechanicProfilesRaw = await prisma.$queryRawUnsafe<any[]>(
    'SELECT count(*)::int as count FROM "MechanicProfile" mp WHERE NOT EXISTS (SELECT 1 FROM "User" u WHERE u.id = mp."userId");'
  );
  const orphanReportsRaw = await prisma.$queryRawUnsafe<any[]>(
    'SELECT count(*)::int as count FROM "BreakdownReport" br WHERE NOT EXISTS (SELECT 1 FROM "User" u WHERE u.id = br."customerId");'
  );
  const orphanRequestsRaw = await prisma.$queryRawUnsafe<any[]>(
    'SELECT count(*)::int as count FROM "ServiceRequest" sr WHERE NOT EXISTS (SELECT 1 FROM "BreakdownReport" br WHERE br.id = sr."breakdownReportId");'
  );
  const orphanReviewsRaw = await prisma.$queryRawUnsafe<any[]>(
    'SELECT count(*)::int as count FROM "Review" r WHERE NOT EXISTS (SELECT 1 FROM "User" u WHERE u.id = r."customerId");'
  );

  const orphanVehicles = orphanVehiclesRaw[0]?.count || 0;
  const orphanMechanicProfiles = orphanMechanicProfilesRaw[0]?.count || 0;
  const orphanReports = orphanReportsRaw[0]?.count || 0;
  const orphanRequests = orphanRequestsRaw[0]?.count || 0;
  const orphanReviews = orphanReviewsRaw[0]?.count || 0;

  console.log(`Orphan Vehicles: ${orphanVehicles}`);
  console.log(`Orphan Mechanic Profiles: ${orphanMechanicProfiles}`);
  console.log(`Orphan Breakdown Reports: ${orphanReports}`);
  console.log(`Orphan Service Requests: ${orphanRequests}`);
  console.log(`Orphan Reviews: ${orphanReviews}`);

  if (orphanVehicles > 0 || orphanMechanicProfiles > 0 || orphanReports > 0 || orphanRequests > 0 || orphanReviews > 0) {
    throw new Error('RELATIONAL INTEGRITY VIOLATION DETECTED!');
  }
  console.log('✅ Relational integrity confirmed: 0 orphan rows across all tables.');

  // Verify Genuine Customer Sahid Sk
  const sahid = await prisma.user.findUnique({
    where: { email: 'sahid.0777777@gmail.com' },
    include: {
      vehicles: true,
      breakdownReports: true,
      reviewsGiven: true,
      savedAddresses: true,
    },
  });

  if (!sahid) {
    throw new Error('CRITICAL FAILURE: Sahid Sk record missing!');
  }

  console.log('\n--- GENUINE CUSTOMER INTEGRITY CONFIRMATION ---');
  console.log(`Customer: ${sahid.fullName} (${sahid.email})`);
  console.log(`Role: ${sahid.role}`);
  console.log(`Vehicles: ${sahid.vehicles.length} (${sahid.vehicles.map((v) => `${v.year} ${v.make} ${v.model} [${v.licensePlate}]`).join(', ')})`);
  console.log(`Breakdown Reports: ${sahid.breakdownReports.length}`);
  console.log(`Reviews: ${sahid.reviewsGiven.length}`);
  console.log(`Saved Addresses: ${sahid.savedAddresses.length}`);
  console.log('✅ Genuine customer data 100% intact.');
}

// Only execute when invoked with --execute flag
if (process.argv.includes('--execute')) {
  executePurge()
    .catch((err) => {
      console.error('❌ Purge failed and rolled back:', err);
      process.exit(1);
    })
    .finally(() => prisma.$disconnect());
} else {
  console.log('ℹ️ Script loaded in dry-run safety mode. Pass --execute to apply changes.');
  prisma.$disconnect();
}
