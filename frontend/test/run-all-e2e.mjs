import { execSync } from 'child_process';

const suites = [
  { name: 'Milestone 1: 3D Canvas & WebGL Performance', script: 'test/hero-3d.e2e.mjs' },
  { name: 'Milestone 1: WebP Asset Pipeline & Responsive Media', script: 'test/images-verify.e2e.mjs' },
  { name: 'Milestone 2: Auth, Roles & Vehicle Garage CRUD', script: 'test/m2-integration.e2e.mjs' },
  { name: 'Milestone 3: Breakdown Intake, GPS & OpenStreetMap', script: 'test/breakdown-reporting.e2e.mjs' },
  { name: 'Milestone 3: 5MB Upload Security & Edge Case Suite', script: 'test/m3-edge-cases.e2e.mjs' },
  { name: 'Milestone 4: Mechanic Beacon & Proximity Engine', script: 'test/mechanic-portal.e2e.mjs' },
  { name: 'Milestone 4: 409 Conflict & Optimistic Rollback', script: 'test/mechanic-conflict-rollback.e2e.mjs' },
  { name: 'Milestone 5: Service Lifecycle & Tracking Terminal', script: 'test/service-tracking.e2e.mjs' },
  { name: 'Milestone 6: Verification Desk & Admin Audit Logs', script: 'test/admin-portal.e2e.mjs' },
  { name: 'Milestone 7: Diagnostics Matrix & Bayesian Reviews', script: 'test/reviews-reputation.e2e.mjs' },
  { name: 'Milestone 8: Responsive Layout (4 Viewports) Audit', script: 'test/responsive-layout.e2e.mjs' },
];

console.log('========================================================================');
console.log('>>> [FULL E2E REGRESSION] Executing All 11 Frontend Playwright Suites');
console.log('========================================================================\n');

try {
  execSync('node ../scripts/reset-test-fixtures.js', { cwd: '../backend', stdio: 'inherit' });
} catch (e) {
  console.warn('Warning: fixture reset step skipped or non-fatal:', e.message);
}

const results = [];
let allPassed = true;

for (let i = 0; i < suites.length; i++) {
  const suite = suites[i];
  console.log(`\n[${i + 1}/${suites.length}] RUNNING: ${suite.name} (${suite.script})...`);
  const startTime = Date.now();
  try {
    const output = execSync(`node ${suite.script}`, {
      encoding: 'utf-8',
      stdio: 'pipe',
      timeout: 180000,
    });
    const duration = ((Date.now() - startTime) / 1000).toFixed(2);
    console.log(`    ✓ PASSED in ${duration}s`);
    results.push({ name: suite.name, status: 'PASS', duration: `${duration}s` });
  } catch (err) {
    const duration = ((Date.now() - startTime) / 1000).toFixed(2);
    console.error(`    ❌ FAILED in ${duration}s:`, err.message);
    if (err.stdout) console.log(err.stdout);
    if (err.stderr) console.error(err.stderr);
    results.push({ name: suite.name, status: 'FAIL', duration: `${duration}s` });
    allPassed = false;
    break;
  }
}

console.log('\n========================================================================');
console.log('>>> [FULL E2E REGRESSION SCORECARD]');
console.log('========================================================================');
console.table(results);

if (!allPassed) {
  console.error('\n❌ FULL E2E REGRESSION FAILED');
  process.exit(1);
} else {
  console.log('\n🎉 ALL 11 PLAYWRIGHT E2E SUITES PASSED CLEANLY (100% GREEN)');
  process.exit(0);
}
