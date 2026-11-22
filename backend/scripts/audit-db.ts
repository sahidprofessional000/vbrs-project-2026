import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function runAudit() {
  console.log('========================================================================');
  console.log('>>> [DATABASE AUDIT REPORT] Comprehensive Entity & Data Analysis');
  console.log('========================================================================\n');

  // 1. Table Counts
  const counts = {
    users: await prisma.user.count(),
    customers: await prisma.user.count({ where: { role: 'CUSTOMER' } }),
    mechanics: await prisma.user.count({ where: { role: 'MECHANIC' } }),
    admins: await prisma.user.count({ where: { role: 'ADMIN' } }),
    vehicles: await prisma.vehicle.count(),
    mechanicProfiles: await prisma.mechanicProfile.count(),
    mechanicServices: await prisma.mechanicService.count(),
    mechanicLocations: await prisma.mechanicLocation.count(),
    breakdownReports: await prisma.breakdownReport.count(),
    reportImages: await prisma.reportImage.count(),
    serviceRequests: await prisma.serviceRequest.count(),
    serviceStatusHistory: await prisma.serviceStatusHistory.count(),
    complaints: await prisma.complaint.count(),
    reviews: await prisma.review.count(),
    notifications: await prisma.notification.count(),
    savedAddresses: await prisma.savedAddress.count(),
    auditLogs: await prisma.auditLog.count(),
    refreshTokens: await prisma.refreshToken.count(),
  };

  console.log('--- 1. TABLE TOTALS ---');
  console.table(counts);

  // 2. Users Breakdown
  const allUsers = await prisma.user.findMany({
    select: {
      id: true,
      email: true,
      fullName: true,
      role: true,
      phone: true,
      createdAt: true,
    },
    orderBy: { createdAt: 'asc' },
  });

  console.log('\n--- 2. USERS AUDIT (Total: ' + allUsers.length + ') ---');
  // Categorize users
  const testEmailPatterns = [
    /@example\.com/i,
    /test/i,
    /dummy/i,
    /fake/i,
    /mock/i,
    /e2e/i,
    /loadtest/i,
    /temp/i,
    /m2-/i,
    /m3-/i,
    /m4-/i,
    /m5-/i,
    /m6-/i,
    /m7-/i,
    /m8-/i,
  ];

  const seedEmails = [
    'admin@vbrs.local',
    'mechanic.alex@vbrs.local',
    'mechanic.marcus@vbrs.local',
    'customer.john@vbrs.local',
    'customer.sarah@vbrs.local',
  ];

  let testUsers = 0;
  let seedUsers = 0;
  let organicUsers = 0;

  const usersByDomain: Record<string, number> = {};
  const sampleTestEmails: string[] = [];
  const sampleOrganicEmails: string[] = [];

  for (const u of allUsers) {
    const domain = u.email.split('@')[1] || 'unknown';
    usersByDomain[domain] = (usersByDomain[domain] || 0) + 1;

    if (seedEmails.includes(u.email)) {
      seedUsers++;
    } else if (testEmailPatterns.some((p) => p.test(u.email) || p.test(u.fullName))) {
      testUsers++;
      if (sampleTestEmails.length < 20) sampleTestEmails.push(`${u.email} (${u.fullName}, role: ${u.role})`);
    } else {
      organicUsers++;
      if (sampleOrganicEmails.length < 20) sampleOrganicEmails.push(`${u.email} (${u.fullName}, role: ${u.role})`);
    }
  }

  console.log('User Classifications:');
  console.log(`- Seed Demonstation Users: ${seedUsers}`);
  console.log(`- Synthetic / Test Users (matching test/e2e patterns): ${testUsers}`);
  console.log(`- Potential Organic / User Created: ${organicUsers}`);
  console.log('User Domain Distribution:', usersByDomain);
  console.log('Sample Synthetic User Emails:', sampleTestEmails.slice(0, 10));
  console.log('Sample Organic / Other Emails:', sampleOrganicEmails.slice(0, 10));

  // 3. Mechanic Profiles
  const allMechanics = await prisma.mechanicProfile.findMany({
    include: {
      user: { select: { email: true, fullName: true } },
      _count: { select: { services: true, reviews: true } },
    },
    orderBy: { createdAt: 'asc' },
  });

  console.log('\n--- 3. MECHANIC PROFILES AUDIT (Total: ' + allMechanics.length + ') ---');
  let seedMechanics = 0;
  let testMechanics = 0;
  let organicMechanics = 0;
  const sampleMechanicsList: any[] = [];

  for (const m of allMechanics) {
    const isSeed = seedEmails.includes(m.user.email);
    const isTest = testEmailPatterns.some(
      (p) => p.test(m.user.email) || p.test(m.workshopName) || p.test(m.tradeLicenseNumber)
    );

    if (isSeed) seedMechanics++;
    else if (isTest) testMechanics++;
    else organicMechanics++;

    if (sampleMechanicsList.length < 15) {
      sampleMechanicsList.push({
        id: m.id,
        userEmail: m.user.email,
        workshopName: m.workshopName,
        tradeLicense: m.tradeLicenseNumber,
        status: m.verificationStatus,
        servicesCount: m._count.services,
        rating: m.ratingAverage,
        reviewsCount: m._count.reviews,
        isSeed,
        isTest,
      });
    }
  }

  console.log(`- Seed Mechanics: ${seedMechanics}`);
  console.log(`- Synthetic / Test Mechanics: ${testMechanics}`);
  console.log(`- Other / Organic Mechanics: ${organicMechanics}`);
  console.table(sampleMechanicsList);

  // 4. Breakdown Reports & Service Requests
  const allReports = await prisma.breakdownReport.findMany({
    include: {
      customer: { select: { email: true, fullName: true } },
      serviceRequest: { select: { id: true, currentStatus: true, mechanicId: true } },
    },
    orderBy: { createdAt: 'desc' },
  });

  console.log('\n--- 4. BREAKDOWN REPORTS (Total: ' + allReports.length + ') ---');
  let testReports = 0;
  let nonTestReports = 0;
  const sampleReports: any[] = [];

  for (const r of allReports) {
    const isTestCustomer = testEmailPatterns.some((p) => p.test(r.customer.email) || p.test(r.description));
    if (isTestCustomer) testReports++;
    else nonTestReports++;

    if (sampleReports.length < 10) {
      sampleReports.push({
        id: r.id,
        category: r.category,
        customerEmail: r.customer.email,
        serviceStatus: r.serviceRequest?.currentStatus,
        createdAt: r.createdAt.toISOString(),
      });
    }
  }

  console.log(`- Reports from Test/Synthetic Accounts: ${testReports}`);
  console.log(`- Reports from Non-Test/Seed/Organic Accounts: ${nonTestReports}`);
  console.table(sampleReports);

  // 5. Complaints
  const allComplaints = await prisma.complaint.findMany({
    include: {
      filedBy: { select: { email: true, fullName: true } },
      targetUser: { select: { email: true, fullName: true } },
    },
  });

  console.log('\n--- 5. COMPLAINTS (Total: ' + allComplaints.length + ') ---');
  console.table(
    allComplaints.map((c) => ({
      id: c.id,
      subject: c.subject,
      status: c.status,
      filedBy: c.filedBy.email,
      targetUser: c.targetUser?.email,
      createdAt: c.createdAt.toISOString(),
    }))
  );

  // 6. Reviews
  const allReviews = await prisma.review.findMany({
    include: {
      customer: { select: { email: true } },
      mechanic: { select: { workshopName: true } },
    },
  });

  console.log('\n--- 6. REVIEWS (Total: ' + allReviews.length + ') ---');
  console.table(
    allReviews.slice(0, 15).map((rev) => ({
      id: rev.id,
      rating: rev.rating,
      comment: rev.comment?.slice(0, 40),
      customer: rev.customer.email,
      mechanic: rev.mechanic.workshopName,
      createdAt: rev.createdAt.toISOString(),
    }))
  );

  // 7. Audit Logs
  const auditActions = await prisma.auditLog.groupBy({
    by: ['action'],
    _count: { action: true },
  });

  console.log('\n--- 7. AUDIT LOGS BY ACTION (Total: ' + counts.auditLogs + ') ---');
  console.table(auditActions.map((a) => ({ action: a.action, count: a._count.action })));

  console.log('\n========================================================================');
  console.log('>>> [AUDIT COMPLETE]');
  console.log('========================================================================');
}

runAudit()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
