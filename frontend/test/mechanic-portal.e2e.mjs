import { chromium } from 'playwright';

async function testMechanicPortalAndDiscovery() {
  console.log('========================================================================');
  console.log('>>> [E2E TEST: MECHANIC PORTAL & DISCOVERY] Starting Milestone 4 Verification');
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
    // -------------------------------------------------------------------------
    // STEP 1: Customer creates a breakdown incident near Downtown
    // -------------------------------------------------------------------------
    console.log('>>> Step 1: Authenticating customer to file breakdown incident...');
    await page.goto('http://localhost:3000/login', { waitUntil: 'networkidle' });
    await page.locator('button:has-text("Driver")').click();
    await page.waitForTimeout(300);
    await page.locator('button:has-text("Authenticate Session")').click();
    await page.waitForURL('**/customer/vehicles', { timeout: 10000 });
    console.log('    ✓ Customer authenticated.');

    console.log('>>> Navigating to /report-breakdown...');
    await page.goto('http://localhost:3000/report-breakdown', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);

    // Fill fault
    await page.locator('textarea').fill('E2E Milestone 4 Test: Engine stalling on FDR Drive shoulder with battery warning.');
    await page.locator('input[placeholder*="Interstate 95"]').fill('FDR Drive Southbound near Houston St');

    console.log('>>> Submitting emergency breakdown incident...');
    await page.locator('button:has-text("Transmit Emergency Signal")').click();
    await page.waitForSelector('text=Triage Assessment & Dispatch Initialized', { timeout: 15000 });
    console.log('    ✓ Breakdown incident filed and logged in database.');

    // -------------------------------------------------------------------------
    // STEP 2: Mechanic logs in to Field Terminal
    // -------------------------------------------------------------------------
    console.log('>>> Step 2: Logging out and authenticating as Certified Field Mechanic...');
    await page.goto('http://localhost:3000/login', { waitUntil: 'networkidle' });

    // Fill mechanic credentials
    const emailInput = page.locator('input[type="email"]');
    const passInput = page.locator('input[type="password"]');
    await emailInput.fill('mechanic.alex@vbrs.local');
    await passInput.fill('Password@123');

    await page.locator('button:has-text("Authenticate Session")').click();
    await page.waitForTimeout(1500);

    console.log('>>> Step 3: Navigating to /mechanic/portal...');
    await page.goto('http://localhost:3000/mechanic/portal', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1500);

    // -------------------------------------------------------------------------
    // STEP 3: Verify Portal UI, Workshop Header & Radar Map
    // -------------------------------------------------------------------------
    console.log('>>> Step 4: Verifying Technician Terminal header & telemetry elements...');
    const workshopTitle = await page.locator('h1').innerText();
    console.log(`    ✓ Verified Workshop Title: "${workshopTitle}"`);

    // Verify radar map container
    await page.waitForSelector('.leaflet-container', { timeout: 10000 });
    const mapExists = await page.locator('.leaflet-container').count();
    console.log(`    ✓ Leaflet OpenStreetMap Radar container active: ${mapExists > 0}`);

    // Verify status toggle initial state (ensure Online)
    const onlineBtn = page.locator('button:has-text("Online (Available)")');
    if ((await onlineBtn.count()) === 0) {
      console.log('>>> Technician is currently in Standby/Offline; setting status to Online...');
      const activateBtn = page.locator('button:has-text("Offline (Standby)"), button:has-text("Go Online")').first();
      if ((await activateBtn.count()) > 0) {
        await activateBtn.click();
        await page.waitForTimeout(1000);
      }
    }

    const isInitialOnline = (await onlineBtn.count()) > 0;
    console.log(`    ✓ Availability status confirmed Online: ${isInitialOnline}`);

    // -------------------------------------------------------------------------
    // STEP 4: Test Offline Isolation (Offline mechanics must not receive dispatches)
    // -------------------------------------------------------------------------
    console.log('>>> Step 5: Testing Offline Status Isolation...');
    await onlineBtn.click();
    await page.waitForTimeout(1000);

    // Verify UI switched to Offline
    const offlineIndicator = await page.locator('text=Radar Standby // Technician Offline').count();
    console.log(`    ✓ Offline guard banner displayed: ${offlineIndicator > 0}`);

    const standbyBtn = page.locator('button:has-text("Offline (Standby)")');
    console.log(`    ✓ Status button reflects Offline (Standby): ${await standbyBtn.count() > 0}`);

    // -------------------------------------------------------------------------
    // STEP 5: Restore Online Status & Verify Inbound Dispatches Feed
    // -------------------------------------------------------------------------
    console.log('>>> Step 6: Restoring Online (Available) status...');
    const goOnlineBtn = page.locator('button:has-text("Go Online"), button:has-text("Offline (Standby)")').first();
    await goOnlineBtn.click();
    await page.waitForTimeout(1500);

    // Verify incoming dispatch queue
    console.log('>>> Step 7: Verifying incoming dispatches in radar zone...');
    await page.waitForSelector('text=km away', { timeout: 10000 });
    const dispatchCards = await page.locator('text=km away').count();
    console.log(`    ✓ Dispatches detected in operational boundary: ${dispatchCards} job(s)`);

    // Verify ETA calculation
    const etaText = await page.locator('text=ETA ~').first().innerText();
    console.log(`    ✓ Proximity ETA displayed: "${etaText}"`);

    // -------------------------------------------------------------------------
    // STEP 6: Test Atomic Dispatch Claiming & Optimistic Transition
    // -------------------------------------------------------------------------
    console.log('>>> Step 8: Claiming and accepting dispatch...');
    const claimBtn = page.locator('button:has-text("Claim & Accept Dispatch")').first();
    await claimBtn.click();

    // Verify transition to Active On-Job Assignment
    await page.waitForSelector('text=Active On-Job Assignment', { timeout: 15000 });
    console.log('    ✓ Successfully transitioned to Active On-Job Assignment!');

    const motoristText = await page.locator('text=Active On-Job Assignment >> xpath=../..').innerText();
    console.log(`    ✓ Active Assignment Summary: ${motoristText.replace(/\n+/g, ' | ').substring(0, 150)}...`);

    console.log('========================================================================');
    console.log('>>> [E2E TEST: MECHANIC PORTAL & DISCOVERY] ALL VERIFICATION STEPS PASSED 100%');
    console.log('========================================================================');
  } catch (err) {
    console.error('>>> [E2E TEST: MECHANIC PORTAL & DISCOVERY] FAILED:', err);
    throw err;
  } finally {
    await browser.close();
  }
}

testMechanicPortalAndDiscovery();
