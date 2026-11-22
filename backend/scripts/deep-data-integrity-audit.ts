import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

interface AuditCategory<T> {
  genuine: T[];
  seed: T[];
  testSynthetic: T[];
}

async function deepAudit() {
  console.log('========================================================================');
  console.log('>>> [DEEP DATA INTEGRITY AUDIT] Granular Analysis of PostgreSQL State');
  console.log('========================================================================\n');

  // --- 1. USERS CLASSIFICATION ---
  const allUsers = await prisma.user.findMany({
    include: {
      vehicles: true,
      mechanicProfile: {
        include: { services: true, currentLocation: true },
      },
      breakdownReports: true,
      customerRequests: true,
      reviewsGiven: true,
      complaintsFiled: true,
      savedAddresses: true,
      auditLogs: true,
    },
    orderBy: { createdAt: 'asc' },
  });

  const canonicalSeedEmails = new Set([
    'admin@vbrs.local',
    'mechanic.alex@vbrs.local',
    'mechanic.marcus@vbrs.local',
    'customer.john@vbrs.local',
    'customer.sarah@vbrs.local',
  ]);

  // Genuine non-test criteria:
  // Not starting with test prefixes (m2., m3., audit., sec., exp., test, etc.)
  // Has a real email domain or specific user registration
  const userAudit: AuditCategory<any> = {
    genuine: [],
    seed: [],
    testSynthetic: [],
  };

  const testEmailRegex = /^(m\d|audit|sec|exp|test|temp|dummy|fake|loadtest)\./i;

  for (const u of allUsers) {
    if (canonicalSeedEmails.has(u.email)) {
      userAudit.seed.push(u);
    } else if (testEmailRegex.test(u.email) || u.email.includes('.1795') || u.fullName.includes('Test') || u.fullName.includes('Hasselhoff')) {
      userAudit.testSynthetic.push(u);
    } else {
      userAudit.genuine.push(u);
    }
  }

  console.log('=== USERS AUDIT ===');
  console.log(`Total Users in DB: ${allUsers.length}`);
  console.log(`- Confirmed Genuine Users: ${userAudit.genuine.length}`);
  userAudit.genuine.forEach((u) =>
    console.log(`    • ${u.email} (${u.fullName}, Role: ${u.role}, Vehicles: ${u.vehicles.length}, Created: ${u.createdAt.toISOString()})`)
  );
  console.log(`- Canonical Demonstration Seed Accounts: ${userAudit.seed.length}`);
  userAudit.seed.forEach((u) =>
    console.log(`    • ${u.email} (${u.fullName}, Role: ${u.role})`)
  );
  console.log(`- Confirmed Test / E2E Automated Fixture Accounts: ${userAudit.testSynthetic.length}`);

  // --- 2. MECHANIC PROFILES AUDIT ---
  const allMechanics = await prisma.mechanicProfile.findMany({
    include: {
      user: true,
      services: true,
      currentLocation: true,
      reviews: true,
    },
  });

  const mechanicAudit: AuditCategory<any> = {
    genuine: [],
    seed: [],
    testSynthetic: [],
  };

  for (const m of allMechanics) {
    if (canonicalSeedEmails.has(m.user.email)) {
      mechanicAudit.seed.push(m);
    } else if (testEmailRegex.test(m.user.email) || m.user.email.includes('.1795') || m.tradeLicenseNumber.includes('TEST') || m.workshopName.includes('Audit')) {
      mechanicAudit.testSynthetic.push(m);
    } else {
      mechanicAudit.genuine.push(m);
    }
  }

  console.log('\n=== MECHANIC PROFILES AUDIT ===');
  console.log(`Total Mechanic Profiles in DB: ${allMechanics.length}`);
  console.log(`- Genuine Mechanic Profiles: ${mechanicAudit.genuine.length}`);
  mechanicAudit.genuine.forEach((m) =>
    console.log(`    • [${m.verificationStatus}] ${m.workshopName} (${m.user.email}, Lic: ${m.tradeLicenseNumber})`)
  );
  console.log(`- Canonical Seed Mechanics: ${mechanicAudit.seed.length}`);
  mechanicAudit.seed.forEach((m) =>
    console.log(`    • [${m.verificationStatus}] ${m.workshopName} (${m.user.email}, Lic: ${m.tradeLicenseNumber})`)
  );
  console.log(`- Test / E2E Fixture Mechanic Profiles: ${mechanicAudit.testSynthetic.length}`);

  // Duplicate Mechanic Trade Licenses Check
  const licenseMap: Record<string, string[]> = {};
  for (const m of allMechanics) {
    const lic = m.tradeLicenseNumber;
    if (!licenseMap[lic]) licenseMap[lic] = [];
    licenseMap[lic].push(`${m.user.email} (${m.workshopName})`);
  }
  const duplicateLicenses = Object.entries(licenseMap).filter(([_, list]) => list.length > 1);
  console.log(`\nDuplicate Trade Licenses Detected: ${duplicateLicenses.length}`);
  duplicateLicenses.forEach(([lic, list]) => {
    console.log(`  License: ${lic} shared across ${list.length} accounts:`, list.slice(0, 5));
  });

  // --- 3. VEHICLES AUDIT ---
  const allVehicles = await prisma.vehicle.findMany({
    include: { user: true },
  });

  const vehicleAudit: AuditCategory<any> = {
    genuine: [],
    seed: [],
    testSynthetic: [],
  };

  for (const v of allVehicles) {
    if (canonicalSeedEmails.has(v.user.email)) {
      vehicleAudit.seed.push(v);
    } else if (testEmailRegex.test(v.user.email) || v.user.email.includes('.1795')) {
      vehicleAudit.testSynthetic.push(v);
    } else {
      vehicleAudit.genuine.push(v);
    }
  }

  console.log('\n=== VEHICLES AUDIT ===');
  console.log(`Total Registered Vehicles: ${allVehicles.length}`);
  console.log(`- Genuine Vehicles: ${vehicleAudit.genuine.length}`);
  vehicleAudit.genuine.forEach((v) =>
    console.log(`    • ${v.year} ${v.make} ${v.model} (${v.licensePlate}, Owner: ${v.user.email})`)
  );
  console.log(`- Seed Demonstration Vehicles: ${vehicleAudit.seed.length}`);
  vehicleAudit.seed.forEach((v) =>
    console.log(`    • ${v.year} ${v.make} ${v.model} (${v.licensePlate}, Owner: ${v.user.email})`)
  );
  console.log(`- Synthetic / E2E Test Vehicles: ${vehicleAudit.testSynthetic.length}`);

  // --- 4. BREAKDOWN REPORTS & SERVICE REQUESTS AUDIT ---
  const allReports = await prisma.breakdownReport.findMany({
    include: {
      customer: true,
      serviceRequest: true,
    },
  });

  const reportAudit: AuditCategory<any> = {
    genuine: [],
    seed: [],
    testSynthetic: [],
  };

  for (const r of allReports) {
    if (canonicalSeedEmails.has(r.customer.email)) {
      reportAudit.seed.push(r);
    } else if (testEmailRegex.test(r.customer.email) || r.customer.email.includes('.1795')) {
      reportAudit.testSynthetic.push(r);
    } else {
      reportAudit.genuine.push(r);
    }
  }

  console.log('\n=== BREAKDOWN REPORTS AUDIT ===');
  console.log(`Total Breakdown Reports: ${allReports.length}`);
  console.log(`- Genuine Submissions: ${reportAudit.genuine.length}`);
  reportAudit.genuine.forEach((r) =>
    console.log(`    • ID: ${r.id.slice(0, 8)} | Category: ${r.category} | Customer: ${r.customer.email} | Address: ${r.addressText?.slice(0, 30)}`)
  );
  console.log(`- Seed Demonstration Reports: ${reportAudit.seed.length}`);
  reportAudit.seed.forEach((r) =>
    console.log(`    • ID: ${r.id.slice(0, 8)} | Category: ${r.category} | Customer: ${r.customer.email} | Status: ${r.serviceRequest?.currentStatus}`)
  );
  console.log(`- Synthetic / Automated Test Reports: ${reportAudit.testSynthetic.length}`);

  // --- 5. COMPLAINTS & DISPUTES AUDIT ---
  const allComplaints = await prisma.complaint.findMany({
    include: {
      filedBy: true,
      targetUser: true,
    },
  });

  const complaintAudit: AuditCategory<any> = {
    genuine: [],
    seed: [],
    testSynthetic: [],
  };

  for (const c of allComplaints) {
    if (canonicalSeedEmails.has(c.filedBy.email)) {
      complaintAudit.seed.push(c);
    } else if (testEmailRegex.test(c.filedBy.email) || c.filedBy.email.includes('.1795') || c.subject.includes('Test') || c.description.includes('E2E')) {
      complaintAudit.testSynthetic.push(c);
    } else {
      complaintAudit.genuine.push(c);
    }
  }

  console.log('\n=== COMPLAINTS AUDIT ===');
  console.log(`Total Complaints: ${allComplaints.length}`);
  console.log(`- Genuine Complaints: ${complaintAudit.genuine.length}`);
  complaintAudit.genuine.forEach((c) =>
    console.log(`    • [${c.status}] ${c.subject} (Filed by: ${c.filedBy.email})`)
  );
  console.log(`- Seed Complaints: ${complaintAudit.seed.length}`);
  console.log(`- Synthetic / Test Complaints: ${complaintAudit.testSynthetic.length}`);
  complaintAudit.testSynthetic.forEach((c) =>
    console.log(`    • [${c.status}] "${c.subject}" | Filed by: ${c.filedBy.email} | Target: ${c.targetUser?.email || 'N/A'}`)
  );

  // --- 6. REVIEWS & RATINGS AUDIT ---
  const allReviews = await prisma.review.findMany({
    include: {
      customer: true,
      mechanic: true,
    },
  });

  const reviewAudit: AuditCategory<any> = {
    genuine: [],
    seed: [],
    testSynthetic: [],
  };

  for (const rev of allReviews) {
    if (canonicalSeedEmails.has(rev.customer.email)) {
      reviewAudit.seed.push(rev);
    } else if (testEmailRegex.test(rev.customer.email) || rev.customer.email.includes('.1795')) {
      reviewAudit.testSynthetic.push(rev);
    } else {
      reviewAudit.genuine.push(rev);
    }
  }

  console.log('\n=== REVIEWS AUDIT ===');
  console.log(`Total Reviews: ${allReviews.length}`);
  console.log(`- Genuine Customer Reviews: ${reviewAudit.genuine.length}`);
  reviewAudit.genuine.forEach((r) =>
    console.log(`    • Rating: ${r.rating}★ | Comment: "${r.comment}" | Customer: ${r.customer.email}`)
  );
  console.log(`- Seed Reviews: ${reviewAudit.seed.length}`);
  reviewAudit.seed.forEach((r) =>
    console.log(`    • Rating: ${r.rating}★ | Comment: "${r.comment}" | Customer: ${r.customer.email}`)
  );
  console.log(`- Synthetic / Test Reviews: ${reviewAudit.testSynthetic.length}`);
  reviewAudit.testSynthetic.forEach((r) =>
    console.log(`    • Rating: ${r.rating}★ | "${r.comment?.slice(0, 30)}" | Customer: ${r.customer.email}`)
  );

  // --- 7. AUDIT LOGS AUDIT ---
  const totalAuditLogs = await prisma.auditLog.count();
  const testAuditLogs = await prisma.auditLog.count({
    where: {
      OR: [
        { user: { email: { contains: '.1795' } } },
        { user: { email: { startsWith: 'm2.' } } },
        { user: { email: { startsWith: 'm3.' } } },
        { user: { email: { startsWith: 'm4.' } } },
        { user: { email: { startsWith: 'm5.' } } },
        { user: { email: { startsWith: 'm6.' } } },
        { user: { email: { startsWith: 'm7.' } } },
        { user: { email: { startsWith: 'm8.' } } },
        { user: { email: { startsWith: 'audit.' } } },
        { user: { email: { startsWith: 'sec.' } } },
        { user: { email: { startsWith: 'exp.' } } },
      ],
    },
  });

  console.log('\n=== AUDIT LOGS ===');
  console.log(`Total Audit Logs: ${totalAuditLogs}`);
  console.log(`- Test / Automated Execution Logs: ${testAuditLogs}`);
  console.log(`- Seed / Organic Action Logs: ${totalAuditLogs - testAuditLogs}`);

  // Summary Table
  console.log('\n========================================================================');
  console.log('>>> SUMMARY PROPOSED CLEANUP LEDGER');
  console.log('========================================================================');

  const summary = [
    {
      Table: 'Users',
      Total: allUsers.length,
      Genuine: userAudit.genuine.length,
      SeedDemonstration: userAudit.seed.length,
      TestSynthetic: userAudit.testSynthetic.length,
      ProposedDelete: userAudit.testSynthetic.length,
    },
    {
      Table: 'MechanicProfiles',
      Total: allMechanics.length,
      Genuine: mechanicAudit.genuine.length,
      SeedDemonstration: mechanicAudit.seed.length,
      TestSynthetic: mechanicAudit.testSynthetic.length,
      ProposedDelete: mechanicAudit.testSynthetic.length,
    },
    {
      Table: 'Vehicles',
      Total: allVehicles.length,
      Genuine: vehicleAudit.genuine.length,
      SeedDemonstration: vehicleAudit.seed.length,
      TestSynthetic: vehicleAudit.testSynthetic.length,
      ProposedDelete: vehicleAudit.testSynthetic.length,
    },
    {
      Table: 'BreakdownReports',
      Total: allReports.length,
      Genuine: reportAudit.genuine.length,
      SeedDemonstration: reportAudit.seed.length,
      TestSynthetic: reportAudit.testSynthetic.length,
      ProposedDelete: reportAudit.testSynthetic.length,
    },
    {
      Table: 'ServiceRequests',
      Total: await prisma.serviceRequest.count(),
      Genuine: reportAudit.genuine.length,
      SeedDemonstration: reportAudit.seed.length,
      TestSynthetic: reportAudit.testSynthetic.length,
      ProposedDelete: reportAudit.testSynthetic.length,
    },
    {
      Table: 'Complaints',
      Total: allComplaints.length,
      Genuine: complaintAudit.genuine.length,
      SeedDemonstration: complaintAudit.seed.length,
      TestSynthetic: complaintAudit.testSynthetic.length,
      ProposedDelete: complaintAudit.testSynthetic.length,
    },
    {
      Table: 'Reviews',
      Total: allReviews.length,
      Genuine: reviewAudit.genuine.length,
      SeedDemonstration: reviewAudit.seed.length,
      TestSynthetic: reviewAudit.testSynthetic.length,
      ProposedDelete: reviewAudit.testSynthetic.length,
    },
    {
      Table: 'AuditLogs',
      Total: totalAuditLogs,
      Genuine: totalAuditLogs - testAuditLogs,
      SeedDemonstration: 'Included',
      TestSynthetic: testAuditLogs,
      ProposedDelete: testAuditLogs,
    },
  ];

  console.table(summary);
}

deepAudit()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
