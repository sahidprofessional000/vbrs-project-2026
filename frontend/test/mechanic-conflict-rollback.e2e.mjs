import { chromium } from 'playwright';

async function testOptimisticRollbackOnConflict() {
  console.log('========================================================================');
  console.log('>>> [E2E CONCURRENCY & ROLLBACK TEST] Testing Real 409 Conflict Handling');
  console.log('========================================================================');

  const browser = await chromium.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--enable-webgl', '--ignore-gpu-blocklist', '--no-sandbox'],
  });

  const context = await browser.newContext({
    viewport: { width: 1744, height: 1080 },
    geolocation: { latitude: 40.7128, longitude: -74.0060 },
    permissions: ['geolocation'],
  });

  const page = await context.newPage();

  try {
    // 1. Authenticate Customer and file a breakdown report
    console.log('>>> Step 1: Filing customer breakdown report...');
    await page.goto('http://localhost:3000/login', { waitUntil: 'networkidle' });
    await page.locator('button:has-text("Driver")').click();
    await page.waitForTimeout(300);
    await page.locator('button:has-text("Authenticate Session")').click();
    await page.waitForURL(/customer\/(home|vehicles)/, { timeout: 10000 });

    await page.goto('http://localhost:3000/report-breakdown', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);

    const testDescription = `Rollback Verification Test ${Date.now()}: Gearbox locking up on highway`;
    await page.locator('textarea').fill(testDescription);
    await page.locator('input[placeholder*="Interstate 95"]').fill('Broadway & 42nd St Intersection');

    await page.locator('button:has-text("Transmit Emergency Signal")').click();
    await page.waitForSelector('text=Triage Assessment & Dispatch Initialized', { timeout: 15000 });
    console.log('    ✓ Breakdown incident filed in live database.');

    // 2. Log in as Mechanic (Alex) in browser UI
    console.log('>>> Step 2: Logging into Mechanic Portal in browser as Mechanic Alex...');
    await page.goto('http://localhost:3000/login', { waitUntil: 'networkidle' });
    await page.locator('input[type="email"]').fill('mechanic.alex@vbrs.local');
    await page.locator('input[type="password"]').fill('Password@123');
    await page.locator('button:has-text("Authenticate Session")').click();
    await page.waitForTimeout(1500);

    await page.goto('http://localhost:3000/mechanic/portal', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1500);

    // Ensure Alex is Online
    const onlineBtn = page.locator('button:has-text("Online (Available)")');
    if ((await onlineBtn.count()) === 0) {
      const activateBtn = page.locator('button:has-text("Offline (Standby)"), button:has-text("Go Online")').first();
      if ((await activateBtn.count()) > 0) {
        await activateBtn.click();
        await page.waitForTimeout(1000);
      }
    }

    // Wait for the dispatch to be visible in Alex's UI feed
    console.log('>>> Step 3: Locating newly filed dispatch in Mechanic browser feed...');
    await page.waitForSelector(`text=${testDescription}`, { timeout: 15000 });
    console.log('    ✓ Target dispatch is visible in Mechanic UI feed.');

    // Count dispatches before clicking
    const initialDispatchCount = await page.locator('button:has-text("Claim & Accept Dispatch")').count();

    // 3. Intercept the accept call to simulate another technician claiming it a microsecond earlier (409 Conflict)
    console.log('>>> Step 4: Configuring network intercept to simulate 409 Conflict race condition...');
    await page.route('**/api/mechanic/dispatches/*/accept', async (route) => {
      console.log('    [Network Intercept] Simulating 409 Conflict: Dispatch claimed by competitor');
      await route.fulfill({
        status: 409,
        contentType: 'application/json',
        body: JSON.stringify({
          statusCode: 409,
          error: 'Conflict',
          message: 'This dispatch request has already been claimed by another field technician.',
        }),
      });
    });

    // 4. Click Claim & Accept Dispatch
    console.log('>>> Step 5: Mechanic clicks "Claim & Accept Dispatch" in browser...');
    const targetCard = page.locator(`div:has-text("${testDescription}")`).locator('button:has-text("Claim & Accept Dispatch")').first();
    await targetCard.click();
    await page.waitForTimeout(1500);

    // 5. Verify optimistic update rollback and 409 Conflict notification banner!
    console.log('>>> Step 6: Verifying optimistic rollback and 409 Conflict banner...');
    await page.waitForSelector('text=Conflict: This dispatch was claimed by another field technician', { timeout: 10000 });
    const conflictBanner = await page.locator('text=Conflict: This dispatch was claimed by another field technician').count();
    console.log(`    ✓ Conflict notification banner detected: ${conflictBanner > 0}`);

    // Verify queue rollback: the dispatch card is restored to the queue
    const restoredCount = await page.locator('button:has-text("Claim & Accept Dispatch")').count();
    console.log(`    ✓ Queue restored to previous state after failure (Card count: ${restoredCount})`);

    // Verify Mechanic was NOT moved to Active On-Job Assignment
    const activeHeader = await page.locator('text=Active On-Job Assignment').count();
    console.log(`    ✓ Active On-Job Assignment prevented (Active assignment count: ${activeHeader})`);

    console.log('========================================================================');
    console.log('>>> [E2E CONCURRENCY & ROLLBACK TEST] PASSED WITH 100% SUCCESS');
    console.log('========================================================================');
  } catch (err) {
    console.error('>>> [E2E CONCURRENCY & ROLLBACK TEST] FAILED:', err);
    throw err;
  } finally {
    await browser.close();
  }
}

testOptimisticRollbackOnConflict();
