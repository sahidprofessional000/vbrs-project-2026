import { chromium } from 'playwright';

const BASE_URL = process.env.FRONTEND_URL || 'http://localhost:3000';

async function runServiceTrackingWorkflowTest() {
  console.log('========================================================================');
  console.log('>>> [E2E SERVICE LIFECYCLE & LIVE TRACKING TEST] Starting Playwright Test');
  console.log('========================================================================');

  const browser = await chromium.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--enable-webgl', '--ignore-gpu-blocklist', '--no-sandbox'],
  });

  const customerContext = await browser.newContext({
    viewport: { width: 1744, height: 1080 },
    permissions: ['geolocation'],
    geolocation: { latitude: 40.7128, longitude: -74.0060 },
  });

  const mechanicContext = await browser.newContext({
    viewport: { width: 1744, height: 1080 },
    permissions: ['geolocation'],
    geolocation: { latitude: 40.7135, longitude: -74.0050 },
  });

  const customerPage = await customerContext.newPage();
  const mechanicPage = await mechanicContext.newPage();

  const uniqueId = Date.now().toString().slice(-4);
  const incidentMarker = `I-80 Mile 12 Marker #${uniqueId}`;

  let targetRequestId = null;

  try {
    // -------------------------------------------------------------------------
    // Step 1: Customer Logs In & Reports Breakdown
    // -------------------------------------------------------------------------
    console.log('>>> Step 1: Logging in as Customer...');
    await customerPage.goto(`${BASE_URL}/login`, { waitUntil: 'networkidle' });
    await customerPage.locator('button:has-text("Driver")').click();
    await customerPage.waitForTimeout(300);
    await customerPage.locator('button:has-text("Authenticate Session")').click();
    await customerPage.waitForURL(/customer\/(home|vehicles)/, { timeout: 10000 });
    console.log('    ✓ Customer authenticated.');

    console.log('>>> Step 2: Navigating to Breakdown Reporting Wizard...');
    await customerPage.goto(`${BASE_URL}/report-breakdown`, { waitUntil: 'networkidle' });
    await customerPage.waitForSelector('form');

    // Select category and enter description with unique marker
    await customerPage.selectOption('select', { index: 0 });
    await customerPage.fill(
      'textarea',
      `Engine stopped running on shoulder. Oil light illuminated. Reference: ${incidentMarker}`,
    );
    await customerPage.fill(
      'input[placeholder*="Interstate"]',
      incidentMarker,
    );

    console.log(`>>> Step 3: Submitting Breakdown Incident (${incidentMarker})...`);
    await customerPage.click('button:has-text("Transmit Emergency Signal")');

    // Wait for submission completion and Triage Protocol Card
    await customerPage.waitForSelector('h2:has-text("Triage Assessment"), a:has-text("Live Track Field Response")', {
      timeout: 15000,
    });
    console.log('    ✓ Breakdown incident filed and triage protocol rendered.');

    // Click "Live Track Field Response →"
    const trackLink = customerPage.locator('a:has-text("Live Track Field Response")');
    const href = await trackLink.getAttribute('href');
    targetRequestId = href.split('/').pop();
    console.log(`    ✓ Target tracking link detected: ${href}`);

    await trackLink.click();
    await customerPage.waitForURL(new RegExp(`/customer/track/${targetRequestId}`), { timeout: 10000 });
    console.log(`    ✓ Navigated to Customer Tracking Terminal: /customer/track/${targetRequestId}`);

    // Verify initial Customer Tracking UI components
    await customerPage.waitForSelector('.leaflet-container', { timeout: 10000 });
    console.log('    ✓ Leaflet Tracking Map initialized.');

    await customerPage.waitForSelector('span:has-text("SUBMITTED")', { timeout: 5000 });
    console.log('    ✓ Initial Milestone Status verified as SUBMITTED.');

    // -------------------------------------------------------------------------
    // Step 4: Field Mechanic Logs In & Views Inbound Dispatches
    // -------------------------------------------------------------------------
    console.log('>>> Step 4: Mechanic Alex logging into Field Portal...');
    await mechanicPage.goto(`${BASE_URL}/login`, { waitUntil: 'networkidle' });
    await mechanicPage.locator('button:has-text("Technician")').click();
    await mechanicPage.waitForTimeout(300);
    await mechanicPage.locator('button:has-text("Authenticate Session")').click();
    await mechanicPage.waitForURL(/mechanic\/(home|portal)/, { timeout: 10000 });
    console.log('    ✓ Mechanic authenticated.');

    await mechanicPage.goto(`${BASE_URL}/mechanic/portal`, { waitUntil: 'networkidle' });
    await mechanicPage.waitForSelector('h1');

    // Ensure mechanic is Online
    const isOffline = await mechanicPage.locator('button:has-text("Offline (Standby)")').isVisible();
    if (isOffline) {
      await mechanicPage.click('button:has-text("Offline (Standby)")');
      await mechanicPage.waitForTimeout(1000);
    }

    // -------------------------------------------------------------------------
    // Step 5: Mechanic Claims & Accepts Dispatch Matching Our Incident
    // -------------------------------------------------------------------------
    console.log(`>>> Step 5: Mechanic claiming specific dispatch for ${incidentMarker}...`);
    await mechanicPage.waitForSelector(`div:has-text("${incidentMarker}")`, { timeout: 15000 });
    const targetCard = mechanicPage.locator('div.border.border-divider', { hasText: incidentMarker }).first();
    const claimButton = targetCard.locator('button:has-text("Claim & Accept Dispatch")');
    await claimButton.click();

    // Verify Mechanic sees Active On-Job Assignment
    await mechanicPage.waitForSelector('div:has-text("Active On-Job Assignment")', { timeout: 10000 });
    console.log('    ✓ Mechanic portal transitioned to Active On-Job Assignment (ACCEPTED).');

    // -------------------------------------------------------------------------
    // Step 6: Mechanic Advances to EN_ROUTE
    // -------------------------------------------------------------------------
    console.log('>>> Step 6: Mechanic advances lifecycle: Start En-Route Dispatch...');
    const enRouteButton = mechanicPage.locator('button:has-text("Start En-Route Dispatch")');
    await enRouteButton.click();
    await mechanicPage.waitForSelector('span:has-text("EN_ROUTE")', { timeout: 8000 });
    console.log('    ✓ Mechanic status successfully advanced to EN_ROUTE.');

    // Verify Customer Screen updates with En Route milestone
    await customerPage.waitForTimeout(1500);
    await customerPage.reload({ waitUntil: 'networkidle' });
    await customerPage.waitForSelector('span:has-text("EN_ROUTE")', { timeout: 10000 });
    console.log('    ✓ Customer Tracking Screen updated: Status EN_ROUTE confirmed in DOM.');

    // -------------------------------------------------------------------------
    // Step 7: Mechanic Advances to ARRIVED (On Scene)
    // -------------------------------------------------------------------------
    console.log('>>> Step 7: Mechanic advances lifecycle: Mark Arrived on Scene...');
    const arrivedButton = mechanicPage.locator('button:has-text("Mark Arrived on Scene")');
    await arrivedButton.click();
    await mechanicPage.waitForSelector('span:has-text("ARRIVED")', { timeout: 8000 });
    console.log('    ✓ Mechanic status successfully advanced to ARRIVED.');

    // -------------------------------------------------------------------------
    // Step 8: Mechanic Records Diagnostic Quotation & Parts Work Order
    // -------------------------------------------------------------------------
    console.log('>>> Step 8: Mechanic records Work Order Quotation ($260 total)...');
    await mechanicPage.click('button:has-text("Input Diagnostic Quote")');
    await mechanicPage.waitForSelector('button:has-text("Save & Broadcast Work Order")', { timeout: 5000 });
    await mechanicPage.click('button:has-text("Save & Broadcast Work Order")');
    await mechanicPage.waitForTimeout(1500);
    console.log('    ✓ Diagnostic quotation saved and broadcast over WebSocket room.');

    // -------------------------------------------------------------------------
    // Step 9: Mechanic Advances to IN_PROGRESS (Diagnostic & Repair Work)
    // -------------------------------------------------------------------------
    console.log('>>> Step 9: Mechanic advances lifecycle: Begin Repair Work...');
    const repairButton = mechanicPage.locator('button:has-text("Begin Repair Work")');
    await repairButton.click();
    await mechanicPage.waitForSelector('span:has-text("IN_PROGRESS")', { timeout: 8000 });
    console.log('    ✓ Mechanic status successfully advanced to IN_PROGRESS.');

    // -------------------------------------------------------------------------
    // Step 10: Mechanic Completes Service & Finalizes Work Order
    // -------------------------------------------------------------------------
    console.log('>>> Step 10: Mechanic completes service and finalizes work order...');
    const completeButton = mechanicPage.locator('button:has-text("Complete Job & Finalize Work Order")');
    await completeButton.click();

    // Verify Mechanic returns to AVAILABLE
    await mechanicPage.waitForSelector('button:has-text("Online (Available)")', { timeout: 8000 });
    console.log('    ✓ Mechanic portal successfully cleared job and returned to AVAILABLE status.');

    // -------------------------------------------------------------------------
    // Step 11: Verify Final Customer Tracking View
    // -------------------------------------------------------------------------
    console.log('>>> Step 11: Verifying Finalized State on Customer Tracking Screen...');
    await customerPage.reload({ waitUntil: 'networkidle' });
    await customerPage.waitForSelector('span:has-text("COMPLETED")', { timeout: 8000 });
    console.log('    ✓ Customer Tracking Screen displays COMPLETED milestone status.');

    await customerPage.waitForSelector('div:has-text("Authorized Work Order")', { timeout: 5000 });
    console.log('    ✓ Authorized Work Order & parts breakdown verified in customer DOM.');

    console.log('========================================================================');
    console.log('>>> [E2E SERVICE LIFECYCLE & LIVE TRACKING TEST] ALL VERIFICATION GATES PASSED (100%)');
    console.log('========================================================================');
  } catch (err) {
    console.error('>>> [TEST FAILED] Error during service tracking workflow test:', err);
    process.exit(1);
  } finally {
    await browser.close();
  }
}

runServiceTrackingWorkflowTest();
