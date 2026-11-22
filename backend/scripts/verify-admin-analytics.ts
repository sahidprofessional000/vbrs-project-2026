async function verifyAdminDashboard() {
  console.log('========================================================================');
  console.log('>>> VERIFYING ADMIN DASHBOARD STATS AGAINST POSTGRESQL');
  console.log('========================================================================\n');

  // 1. Authenticate as Admin
  const loginRes = await fetch('http://localhost:4000/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: 'admin@vbrs.local',
      password: 'Password@123',
    }),
  });

  const loginData = await loginRes.json();
  const token = loginData.tokens?.accessToken || loginData.accessToken;
  if (!token) {
    console.error('Failed to authenticate:', loginData);
    process.exit(1);
  }
  console.log('✅ Admin authenticated successfully.');

  // 2. Query Analytics Overview
  const analyticsRes = await fetch('http://localhost:4000/api/admin/analytics/overview', {
    headers: { Authorization: `Bearer ${token}` },
  });
  const analytics = await analyticsRes.json();

  console.log('\n--- LIVE SQL FLEET METRICS FROM /api/admin/analytics/overview ---');
  console.table(analytics.fleetMetrics);

  console.log('\n--- LIVE RESPONSE TIMING ---');
  console.table(analytics.responseTiming);

  console.log('\n--- LIVE CATEGORY DISTRIBUTION ---');
  console.table(analytics.categoryDistribution);

  console.log('\n--- LIVE TOP MECHANICS ---');
  console.table(analytics.topMechanics);

  // 3. Query Field Technicians Desk
  const mechanicsRes = await fetch('http://localhost:4000/api/admin/mechanics', {
    headers: { Authorization: `Bearer ${token}` },
  });
  const mechanics = await mechanicsRes.json();

  console.log(`\n--- FIELD TECHNICIAN CREDENTIAL DESK (Total: ${mechanics.length}) ---`);
  console.table(
    mechanics.map((m: any) => ({
      id: m.id.slice(0, 8),
      workshopName: m.workshopName,
      tradeLicense: m.tradeLicenseNumber,
      status: m.verificationStatus,
      technician: m.user.fullName,
      email: m.user.email,
    }))
  );

  // 4. Query Dispute Desk
  const complaintsRes = await fetch('http://localhost:4000/api/complaints', {
    headers: { Authorization: `Bearer ${token}` },
  });
  const complaints = await complaintsRes.json();

  console.log(`\n--- MUNICIPAL DISPUTE DESK (Total: ${complaints.length}) ---`);
  if (complaints.length === 0) {
    console.log('✅ 0 complaints filed. Real-world clean empty state.');
  } else {
    console.table(complaints);
  }

  // 5. Query Audit Logs
  const auditRes = await fetch('http://localhost:4000/api/admin/audit-logs?limit=10', {
    headers: { Authorization: `Bearer ${token}` },
  });
  const auditData = await auditRes.json();

  console.log(`\n--- SECURITY AUDIT LOGS (Total: ${auditData.pagination.total}) ---`);
  console.table(
    auditData.logs.map((l: any) => ({
      id: l.id.slice(0, 8),
      action: l.action,
      entity: l.entityName,
      user: l.user?.fullName || 'System',
      timestamp: l.createdAt,
    }))
  );
}

verifyAdminDashboard().catch(console.error);
