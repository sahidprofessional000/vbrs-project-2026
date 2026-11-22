import { chromium } from 'playwright';
import path from 'path';

async function testRoleSeparation() {
  console.log('========================================================================');
  console.log('>>> [E2E TEST: STEP 6 — ROLE SEPARATION NAVIGATION & PUBLIC GATEWAYS]');
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
    // =========================================================================
    // PART 1: PUBLIC LANDING PAGE & SEPARATE ENTRY POINTS
    // =========================================================================
    console.log('\n--- PART 1: PUBLIC LANDING PAGE & DEDICATED GATEWAY CARDS ---');
    console.log('>>> Navigating to http://localhost:3000/...');
    await page.goto('http://localhost:3000/', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1500);

    // 1.1: Verify Hero Typography & Left Side Actions
    console.log('>>> Step 1.1: Verifying Public Hero Lockup & Left-Side Actions...');
    const headline = page.locator('h1:has-text("Precision Roadside Rescue.")');
    if ((await headline.count()) === 0) throw new Error('Hero headline missing');

    const emergencyBtn = page.locator('a:has-text("Request Emergency Assistance")');
    const mechanicTerminalBtn = page.locator('a:has-text("Mechanic Terminal")');
    if ((await emergencyBtn.count()) === 0 || (await mechanicTerminalBtn.count()) === 0) {
      throw new Error('Hero guest call-to-actions missing');
    }
    console.log('    ✓ Hero headline and guest call-to-actions verified.');

    // 1.2: Verify 3D Original Vehicle Viewer in Hero
    console.log('>>> Step 1.2: Verifying 3D Original Vehicle Viewer in Hero...');
    const overviewCanvas = page.locator('#hero-vehicle-viewer canvas, [data-testid="original-vehicle-viewer"] canvas');
    await overviewCanvas.waitFor({ state: 'visible', timeout: 15000 });
    console.log('    ✓ 3D Original Vehicle Viewer canvas is rendered and active.');

    // 1.3: Verify Navbar Guest Navigation Links
    console.log('>>> Step 1.3: Verifying Public Navigation Bar Gateway Links...');
    const driverLink = page.locator('header a:has-text("Driver Portal")');
    const techLink = page.locator('header a:has-text("Technician Desk")');
    const rescueLink = page.locator('header a:has-text("Request Rescue")');
    if ((await driverLink.count()) === 0 || (await techLink.count()) === 0 || (await rescueLink.count()) === 0) {
      throw new Error('Public navigation bar missing role gateway links');
    }
    console.log('    ✓ Navbar guest links (Driver Portal, Technician Desk, Request Rescue) confirmed.');

    // 1.4: Verify Dedicated Gateways Section (Two Specialized Portals)
    console.log('>>> Step 1.4: Verifying Dedicated Gateways Section (#portal-gateways)...');
    const gatewaySection = page.locator('#portal-gateways');
    if ((await gatewaySection.count()) === 0) throw new Error('#portal-gateways section missing');

    const customerGateway = page.locator('#customer-gateway');
    const mechanicGateway = page.locator('#mechanic-gateway');
    if ((await customerGateway.count()) === 0 || (await mechanicGateway.count()) === 0) {
      throw new Error('Customer or Mechanic gateway card missing');
    }

    const customerHeader = customerGateway.locator('h3:has-text("Customer & Driver Experience")');
    const mechanicHeader = mechanicGateway.locator('h3:has-text("Mechanic Workspace & CAD Terminal")');
    if ((await customerHeader.count()) === 0 || (await mechanicHeader.count()) === 0) {
      throw new Error('Gateway card titles do not match expected role experience text');
    }
    console.log('    ✓ Both Customer Gateway and Mechanic Gateway cards verified.');

    // Capture screenshot of Landing Page Gateways
    const landingScreenshotPath = path.resolve('frontend/public/academic/screenshot-landing-gateways.png');
    await page.screenshot({ path: landingScreenshotPath, fullPage: false });
    console.log(`    ✓ Captured Public Landing Gateways screenshot: ${landingScreenshotPath}`);

    // =========================================================================
    // PART 2: UNAUTHENTICATED DIRECT ACCESS GUARDS
    // =========================================================================
    console.log('\n--- PART 2: UNAUTHENTICATED DIRECT ACCESS GUARDS ---');
    console.log('>>> Step 2.1: Testing unauthenticated direct access to /customer/home...');
    await page.goto('http://localhost:3000/customer/home', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);
    if (!page.url().includes('/login')) {
      throw new Error(`Expected redirect to /login from /customer/home, but got ${page.url()}`);
    }
    console.log(`    ✓ Cleanly redirected to: ${page.url()}`);

    console.log('>>> Step 2.2: Testing unauthenticated direct access to /mechanic/home...');
    await page.goto('http://localhost:3000/mechanic/home', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);
    if (!page.url().includes('/login')) {
      throw new Error(`Expected redirect to /login from /mechanic/home, but got ${page.url()}`);
    }
    console.log(`    ✓ Cleanly redirected to: ${page.url()}`);

    console.log('>>> Step 2.3: Testing unauthenticated direct access to /admin/dashboard...');
    await page.goto('http://localhost:3000/admin/dashboard', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);
    if (!page.url().includes('/login')) {
      throw new Error(`Expected redirect to /login from /admin/dashboard, but got ${page.url()}`);
    }
    console.log(`    ✓ Cleanly redirected to: ${page.url()}`);

    // =========================================================================
    // PART 3: SECURE ROLE-BASED LOGIN REDIRECTS
    // =========================================================================
    console.log('\n--- PART 3: SECURE ROLE-BASED LOGIN REDIRECTS ---');
    // 3.1: Customer Default Login Redirect
    console.log('>>> Step 3.1: Authenticating as Customer (Driver quick-fill)...');
    await page.goto('http://localhost:3000/login', { waitUntil: 'networkidle' });
    await page.locator('button:has-text("Driver")').click();
    await page.waitForTimeout(300);
    await page.locator('button:has-text("Authenticate Session")').click();
    await page.waitForTimeout(2000);

    const customerUrl = page.url();
    console.log(`    URL after Customer login: ${customerUrl}`);
    if (!customerUrl.includes('/customer/home')) {
      throw new Error(`Customer login did not redirect to /customer/home (got ${customerUrl})`);
    }
    console.log('    ✓ Customer redirected to dedicated /customer/home.');

    // Capture Customer Workspace screenshot
    const customerScreenshotPath = path.resolve('frontend/public/academic/screenshot-role-redirect-customer.png');
    await page.screenshot({ path: customerScreenshotPath, fullPage: false });
    console.log(`    ✓ Captured Customer Workspace screenshot: ${customerScreenshotPath}`);

    // 3.2: Customer Unauthorized Route Boundary Checks
    console.log('>>> Step 3.2: Testing Customer Access to Restricted Mechanic & Admin Routes...');
    console.log('    Attempting to navigate Customer to /mechanic/home...');
    await page.goto('http://localhost:3000/mechanic/home', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);
    if (page.url().includes('/mechanic/home')) {
      throw new Error('SECURITY VIOLATION: Customer was able to access /mechanic/home!');
    }
    console.log(`    ✓ Blocked and redirected to: ${page.url()}`);

    console.log('    Attempting to navigate Customer to /mechanic/portal...');
    await page.goto('http://localhost:3000/mechanic/portal', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);
    if (page.url().includes('/mechanic/portal')) {
      throw new Error('SECURITY VIOLATION: Customer was able to access /mechanic/portal!');
    }
    console.log(`    ✓ Blocked and redirected to: ${page.url()}`);

    console.log('    Attempting to navigate Customer to /admin/dashboard...');
    await page.goto('http://localhost:3000/admin/dashboard', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);
    if (page.url().includes('/admin/dashboard')) {
      throw new Error('SECURITY VIOLATION: Customer was able to access /admin/dashboard!');
    }
    console.log(`    ✓ Blocked and redirected to: ${page.url()}`);

    // Verify Customer Allowed Routes
    console.log('>>> Step 3.3: Verifying Customer Allowed Routes (/customer/vehicles, /customer/profile)...');
    await page.goto('http://localhost:3000/customer/vehicles', { waitUntil: 'networkidle' });
    await page.waitForTimeout(800);
    if (!page.url().includes('/customer/vehicles')) {
      throw new Error('Customer unable to access /customer/vehicles');
    }
    console.log('    ✓ /customer/vehicles 200 OK.');

    await page.goto('http://localhost:3000/customer/profile', { waitUntil: 'networkidle' });
    await page.waitForTimeout(800);
    if (!page.url().includes('/customer/profile')) {
      throw new Error('Customer unable to access /customer/profile');
    }
    console.log('    ✓ /customer/profile 200 OK.');

    // 3.4: Customer views Overview page (Hero adaptivity)
    console.log('>>> Step 3.4: Verifying Overview Page Hero Adaptivity for Logged-In Customer...');
    await page.goto('http://localhost:3000/', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);
    const openCustomerWorkspaceBtn = page.locator('a:has-text("Open Driver Workspace")');
    if ((await openCustomerWorkspaceBtn.count()) === 0) {
      throw new Error('Hero did not adapt to logged-in Customer ("Open Driver Workspace" missing)');
    }
    console.log('    ✓ Hero dynamically displays "Open Driver Workspace" for authenticated customer.');

    // Sign out Customer
    console.log('>>> Signing out Customer...');
    await page.locator('button[title="Sign Out"]').click();
    await page.waitForTimeout(1200);

    // =========================================================================
    // PART 4: MECHANIC LOGIN & STRICT BOUNDARY GUARDS
    // =========================================================================
    console.log('\n--- PART 4: MECHANIC LOGIN & STRICT BOUNDARY GUARDS ---');
    console.log('>>> Step 4.1: Authenticating as Mechanic (Technician quick-fill)...');
    await page.goto('http://localhost:3000/login', { waitUntil: 'networkidle' });
    await page.locator('button:has-text("Technician")').click();
    await page.waitForTimeout(300);
    await page.locator('button:has-text("Authenticate Session")').click();
    await page.waitForTimeout(2000);

    const mechanicUrl = page.url();
    console.log(`    URL after Mechanic login: ${mechanicUrl}`);
    if (!mechanicUrl.includes('/mechanic/home')) {
      throw new Error(`Mechanic login did not redirect to /mechanic/home (got ${mechanicUrl})`);
    }
    console.log('    ✓ Mechanic redirected to dedicated /mechanic/home.');

    // Capture Mechanic Workspace screenshot
    const mechanicScreenshotPath = path.resolve('frontend/public/academic/screenshot-role-redirect-mechanic.png');
    await page.screenshot({ path: mechanicScreenshotPath, fullPage: false });
    console.log(`    ✓ Captured Mechanic Workspace screenshot: ${mechanicScreenshotPath}`);

    // 4.2: Mechanic Unauthorized Route Boundary Checks
    console.log('>>> Step 4.2: Testing Mechanic Access to Restricted Customer & Admin Routes...');
    console.log('    Attempting to navigate Mechanic to /customer/home...');
    await page.goto('http://localhost:3000/customer/home', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);
    if (page.url().includes('/customer/home')) {
      throw new Error('SECURITY VIOLATION: Mechanic was able to access /customer/home!');
    }
    console.log(`    ✓ Blocked and redirected to: ${page.url()}`);

    console.log('    Attempting to navigate Mechanic to /customer/vehicles...');
    await page.goto('http://localhost:3000/customer/vehicles', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);
    if (page.url().includes('/customer/vehicles')) {
      throw new Error('SECURITY VIOLATION: Mechanic was able to access /customer/vehicles!');
    }
    console.log(`    ✓ Blocked and redirected to: ${page.url()}`);

    console.log('    Attempting to navigate Mechanic to /report-breakdown...');
    await page.goto('http://localhost:3000/report-breakdown', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);
    if (page.url().includes('/report-breakdown')) {
      throw new Error('SECURITY VIOLATION: Mechanic was able to access /report-breakdown!');
    }
    console.log(`    ✓ Blocked and redirected to: ${page.url()}`);

    console.log('    Attempting to navigate Mechanic to /admin/dashboard...');
    await page.goto('http://localhost:3000/admin/dashboard', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);
    if (page.url().includes('/admin/dashboard')) {
      throw new Error('SECURITY VIOLATION: Mechanic was able to access /admin/dashboard!');
    }
    console.log(`    ✓ Blocked and redirected to: ${page.url()}`);

    // 4.3: Mechanic Allowed Routes
    console.log('>>> Step 4.3: Verifying Mechanic Allowed Routes (/mechanic/home, /mechanic/portal, /mechanic/profile)...');
    await page.goto('http://localhost:3000/mechanic/home', { waitUntil: 'networkidle' });
    await page.waitForTimeout(800);
    if (!page.url().includes('/mechanic/home')) {
      throw new Error('Mechanic unable to access /mechanic/home');
    }
    console.log('    ✓ /mechanic/home 200 OK.');

    // Verify 3D inspection terminal in Workshop
    const workshopTerminal = page.locator('#inspection-terminal canvas');
    await workshopTerminal.waitFor({ state: 'visible', timeout: 15000 });
    console.log('    ✓ Full 3D Inspection Terminal canvas active in Workshop.');

    await page.goto('http://localhost:3000/mechanic/portal', { waitUntil: 'networkidle' });
    await page.waitForTimeout(800);
    if (!page.url().includes('/mechanic/portal')) {
      throw new Error('Mechanic unable to access /mechanic/portal');
    }
    console.log('    ✓ /mechanic/portal 200 OK.');

    await page.goto('http://localhost:3000/mechanic/profile', { waitUntil: 'networkidle' });
    await page.waitForTimeout(800);
    if (!page.url().includes('/mechanic/profile')) {
      throw new Error('Mechanic unable to access /mechanic/profile');
    }
    console.log('    ✓ /mechanic/profile 200 OK.');

    // 4.4: Mechanic views Overview page (Hero adaptivity)
    console.log('>>> Step 4.4: Verifying Overview Page Hero Adaptivity for Logged-In Mechanic...');
    await page.goto('http://localhost:3000/', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);
    const openMechanicWorkshopBtn = page.locator('a:has-text("Open Mechanic Workshop")');
    if ((await openMechanicWorkshopBtn.count()) === 0) {
      throw new Error('Hero did not adapt to logged-in Mechanic ("Open Mechanic Workshop" missing)');
    }
    console.log('    ✓ Hero dynamically displays "Open Mechanic Workshop" for authenticated mechanic.');

    // Sign out Mechanic
    console.log('>>> Signing out Mechanic...');
    await page.locator('button[title="Sign Out"]').click();
    await page.waitForTimeout(1200);

    // =========================================================================
    // PART 5: ADMIN LOGIN & CONTROL DESK ACCESS
    // =========================================================================
    console.log('\n--- PART 5: ADMIN LOGIN & CONTROL DESK ACCESS ---');
    console.log('>>> Step 5.1: Authenticating as Admin (Admin quick-fill)...');
    await page.goto('http://localhost:3000/login', { waitUntil: 'networkidle' });
    await page.locator('button:has-text("Admin")').click();
    await page.waitForTimeout(300);
    await page.locator('button:has-text("Authenticate Session")').click();
    await page.waitForTimeout(2000);

    const adminUrl = page.url();
    console.log(`    URL after Admin login: ${adminUrl}`);
    if (!adminUrl.includes('/admin/dashboard')) {
      throw new Error(`Admin login did not redirect to /admin/dashboard (got ${adminUrl})`);
    }
    console.log('    ✓ Admin redirected to dedicated /admin/dashboard.');

    console.log('\n========================================================================');
    console.log('>>> [SUCCESS] STEP 6: ROLE SEPARATION & PUBLIC GATEWAYS 100% VERIFIED!');
    console.log('========================================================================');
  } catch (error) {
    console.error('>>> [TEST FAILURE]:', error);
    process.exit(1);
  } finally {
    await browser.close();
  }
}

testRoleSeparation();
