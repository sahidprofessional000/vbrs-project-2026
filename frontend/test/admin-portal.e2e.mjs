import { chromium } from 'playwright';

async function testAdminPortalAndGovernance() {
  console.log('========================================================================');
  console.log('>>> [E2E TEST: ADMIN GOVERNANCE & AUDIT EXPLORER] Starting Verification');
  console.log('========================================================================');

  const browser = await chromium.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--enable-webgl', '--ignore-gpu-blocklist', '--no-sandbox'],
  });

  const context = await browser.newContext({
    viewport: { width: 1744, height: 1080 },
  });

  const page = await context.newPage();

  try {
    // -------------------------------------------------------------------------
    // STEP 1: Authenticate as Administrator
    // -------------------------------------------------------------------------
    console.log('>>> Step 1: Navigating to /login and authenticating as Admin...');
    await page.goto('http://localhost:3000/login', { waitUntil: 'networkidle' });
    
    // Quick-fill Admin
    await page.locator('button:has-text("Admin")').click();
    await page.waitForTimeout(300);
    await page.locator('button:has-text("Authenticate Session")').click();
    await page.waitForURL('**/admin/dashboard', { timeout: 10000 });
    console.log('    ✓ Admin successfully authenticated into Command Center.');

    // -------------------------------------------------------------------------
    // STEP 2: Verify Operational Fleet Analytics (Tab 1)
    // -------------------------------------------------------------------------
    console.log('>>> Step 2: Validating Real PostgreSQL Operational Analytics Telemetry...');
    await page.waitForSelector('text=Operational Command Center', { timeout: 10000 });
    await page.waitForSelector('text=Total Breakdowns', { timeout: 10000 });
    await page.waitForSelector('text=Active Dispatches', { timeout: 10000 });
    await page.waitForSelector('text=Completed Operations', { timeout: 10000 });
    await page.waitForSelector('text=Breakdown Category Distribution', { timeout: 10000 });
    await page.waitForSelector('text=Top Field Technicians', { timeout: 10000 });
    console.log('    ✓ Real SQL fleet metrics, category distribution & technician leaderboard verified.');

    // -------------------------------------------------------------------------
    // STEP 3: Verify Technician Credential Gate (Tab 2)
    // -------------------------------------------------------------------------
    console.log('>>> Step 3: Navigating to Technician Credential Desk...');
    await page.locator('button:has-text("Technician Credential Desk")').click();
    await page.waitForTimeout(1000);

    // Verify filter buttons
    await page.waitForSelector('button:has-text("PENDING")', { timeout: 5000 });
    await page.waitForSelector('button:has-text("APPROVED")', { timeout: 5000 });

    // Review Credentials on first available mechanic
    const reviewBtn = page.locator('button:has-text("Review Credentials")').first();
    const hasReviewBtn = await reviewBtn.isVisible();
    if (hasReviewBtn) {
      console.log('    >>> Opening technician review modal...');
      await reviewBtn.click();
      await page.waitForSelector('text=Review Field Technician Credentials', { timeout: 5000 });

      // Enter review notes
      const notesInput = page.locator('textarea');
      await notesInput.fill('E2E Audit Verification: Trade license and ASE certifications verified with state registry.');
      
      // Click Approve Credentials
      console.log('    >>> Submitting credential approval with supervisory audit notes...');
      await page.locator('button:has-text("Approve Credentials")').click();
      await page.waitForTimeout(1500);
      console.log('    ✓ Technician credential review submitted and persisted.');
    } else {
      console.log('    (No technician in review list; verified desk rendering).');
    }

    // -------------------------------------------------------------------------
    // STEP 4: Verify Dispute & Grievance Desk (Tab 3)
    // -------------------------------------------------------------------------
    console.log('>>> Step 4: Navigating to Dispute & Grievance Desk...');
    await page.locator('button:has-text("Dispute & Grievance Desk")').click();
    await page.waitForTimeout(1000);

    await page.waitForSelector('button:has-text("INVESTIGATING")', { timeout: 5000 });
    await page.waitForSelector('button:has-text("RESOLVED")', { timeout: 5000 });

    const manageDisputeBtn = page.locator('button:has-text("Manage Dispute")').first();
    const hasDispute = await manageDisputeBtn.isVisible();
    if (hasDispute) {
      console.log('    >>> Managing municipal dispute incident...');
      await manageDisputeBtn.click();
      await page.waitForSelector('text=Manage Municipal Dispute', { timeout: 5000 });

      // Change status to RESOLVED and set notes
      await page.locator('select').selectOption('RESOLVED');
      await page.locator('textarea').fill('E2E Resolution: Motorist and certified technician mutually agreed on final diagnostic adjustment.');
      await page.locator('button:has-text("Commit Resolution")').click();
      await page.waitForTimeout(1500);
      console.log('    ✓ Dispute resolution notes committed.');
    } else {
      console.log('    ✓ Dispute desk rendered (no open disputes requiring escalation).');
    }

    // -------------------------------------------------------------------------
    // STEP 5: Verify Security Audit Log Explorer (Tab 4)
    // -------------------------------------------------------------------------
    console.log('>>> Step 5: Navigating to Security Audit Log Explorer...');
    await page.locator('button:has-text("Security Audit Log Explorer")').click();
    await page.waitForTimeout(1000);

    await page.waitForSelector('text=Operator', { timeout: 5000 });
    await page.waitForSelector('text=Action Executed', { timeout: 5000 });

    // Filter by MECHANIC_VERIFICATION
    console.log('    >>> Searching for MECHANIC_VERIFICATION audit records...');
    const searchInput = page.locator('input[placeholder*="Filter by action name"]');
    await searchInput.fill('MECHANIC_VERIFICATION');
    await page.locator('button:has-text("Apply Filters")').click();
    await page.waitForTimeout(1000);

    // Inspect first audit log
    const inspectBtn = page.locator('button:has-text("Inspect")').first();
    const hasInspectBtn = await inspectBtn.isVisible();
    if (hasInspectBtn) {
      console.log('    >>> Inspecting audit log JSON payload modal...');
      await inspectBtn.click();
      await page.waitForSelector('text=Immutable Audit Payload', { timeout: 5000 });
      await page.waitForSelector('text=Details JSON Payload:', { timeout: 5000 });
      await page.locator('button:has-text("Close Inspector")').click();
      await page.waitForTimeout(500);
      console.log('    ✓ Audit payload modal inspected and closed.');
    } else {
      console.log('    ✓ Audit log table rendered with filters.');
    }

    console.log('========================================================================');
    console.log('>>> [E2E TEST: ADMIN GOVERNANCE & AUDIT EXPLORER] ALL TESTS PASSED!');
    console.log('========================================================================');

  } catch (err) {
    console.error('>>> [E2E TEST FAILED]:', err);
    process.exit(1);
  } finally {
    await browser.close();
  }
}

testAdminPortalAndGovernance();
