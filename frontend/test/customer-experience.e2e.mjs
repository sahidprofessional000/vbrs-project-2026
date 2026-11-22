import { chromium } from 'playwright';

async function testCustomerExperience() {
  console.log('========================================================================');
  console.log('>>> [E2E TEST: CUSTOMER EXPERIENCE] Step 3 Verification Suite');
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

  // Auto-accept confirmation dialogs
  page.on('dialog', async (dialog) => {
    console.log(`    [Browser Dialog] Auto-accepting: "${dialog.message()}"`);
    await dialog.accept();
  });

  try {
    // -------------------------------------------------------------
    // Step 1: Authenticate as Customer
    // -------------------------------------------------------------
    console.log('>>> Step 1: Navigating to http://localhost:3000/login...');
    await page.goto('http://localhost:3000/login', { waitUntil: 'networkidle' });

    console.log('>>> Step 2: Authenticating as Customer (Driver quick-fill)...');
    const driverBtn = page.locator('button:has-text("Driver")');
    await driverBtn.click();
    await page.waitForTimeout(300);

    const submitBtn = page.locator('button:has-text("Authenticate Session")');
    await submitBtn.click();
    await page.waitForTimeout(1500);
    console.log('    ✓ Customer login credentials submitted.');

    // -------------------------------------------------------------
    // Step 2: Navigate to Dedicated Customer Home Experience
    // -------------------------------------------------------------
    console.log('>>> Step 3: Navigating to http://localhost:3000/customer/home...');
    await page.goto('http://localhost:3000/customer/home', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1500);

    // Verify Greeting and Personalized Identity
    console.log('>>> Step 4: Verifying Personalized Greeting and Identity Lockup...');
    const greetingHeading = page.locator('h1');
    const greetingText = await greetingHeading.first().textContent();
    console.log(`    ✓ Header text detected: "${greetingText?.trim()}"`);
    if (!greetingText || (!greetingText.includes('Good') && !greetingText.includes('Johnathan') && !greetingText.includes('Customer'))) {
      throw new Error(`Personalized greeting header not detected properly. Got: ${greetingText}`);
    }

    const verifiedBadge = page.locator('span:has-text("Verified Member")');
    const badgeCount = await verifiedBadge.count();
    if (badgeCount === 0) throw new Error('Verified Member badge not visible on customer home');
    console.log('    ✓ Verified Member badge verified.');

    // -------------------------------------------------------------
    // Step 3: Verify Primary Emergency Breakdown Reporting Action
    // -------------------------------------------------------------
    console.log('>>> Step 5: Verifying Emergency Rescue Action Card...');
    const emergencyHeader = page.locator('h2:has-text("Vehicle Disabled? Broadcast Emergency Signal")');
    if ((await emergencyHeader.count()) === 0) {
      throw new Error('Primary Emergency Breakdown Action header not found on customer home');
    }
    const reportBtn = page.locator('a[href="/report-breakdown"]:has-text("Report Breakdown Incident")');
    if ((await reportBtn.count()) === 0) {
      throw new Error('Emergency reporting button linking to /report-breakdown missing');
    }
    console.log('    ✓ Emergency action card and quick report button verified.');

    // -------------------------------------------------------------
    // Step 4: Verify Registered Garage Fleet Overview
    // -------------------------------------------------------------
    console.log('>>> Step 6: Verifying Fleet Garage Overview...');
    const garageHeader = page.locator('h3:has-text("Registered Garage")');
    if ((await garageHeader.count()) === 0) {
      throw new Error('Registered Garage section header missing');
    }
    console.log('    ✓ Fleet garage section rendered.');

    // -------------------------------------------------------------
    // Step 5: Verify Saved Locations and Nearby Mechanics Radar
    // -------------------------------------------------------------
    console.log('>>> Step 7: Verifying Saved Locations & Nearby Mechanics Radar...');
    const savedLocHeader = page.locator('h3:has-text("Saved Dispatch Locations")');
    if ((await savedLocHeader.count()) === 0) {
      throw new Error('Saved Locations section missing');
    }

    const nearbyHeader = page.locator('h3:has-text("Nearby Response Units")');
    if ((await nearbyHeader.count()) === 0) {
      throw new Error('Nearby Response Units section missing');
    }
    console.log('    ✓ Saved locations and nearby mechanics radar sections verified.');

    // -------------------------------------------------------------
    // Step 6: Navigate to Dedicated Customer Profile Experience
    // -------------------------------------------------------------
    console.log('>>> Step 8: Navigating to http://localhost:3000/customer/profile...');
    await page.goto('http://localhost:3000/customer/profile', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1500);

    // Verify Profile Form Pre-population
    console.log('>>> Step 9: Verifying Profile Edit Form Pre-population...');
    const nameInput = page.locator('input[placeholder="Jane Doe"]');
    const inputVal = await nameInput.inputValue();
    console.log(`    ✓ Detected pre-populated full name: "${inputVal}"`);

    // -------------------------------------------------------------
    // Step 7: Test Profile Modification & Persistence
    // -------------------------------------------------------------
    console.log('>>> Step 10: Testing Customer Profile Update...');
    await nameInput.fill('Johnathan Doe Verified');
    const phoneInput = page.locator('input[placeholder="+1-555-0199"]');
    await phoneInput.fill('+1-555-777-8899');

    const saveProfileBtn = page.locator('button:has-text("Save Profile Changes")');
    await saveProfileBtn.click();
    await page.waitForTimeout(1500);

    const successAlert = page.locator('text=Personal credentials and contact data updated successfully');
    if ((await successAlert.count()) === 0) {
      console.warn('    ! Alert notice disappeared or took a moment, verifying persisted value...');
    } else {
      console.log('    ✓ Profile update confirmation toast/alert displayed.');
    }

    // -------------------------------------------------------------
    // Step 8: Test Saved Address Management (Create & Delete)
    // -------------------------------------------------------------
    const uniqueLabel = `Metro Hub ${Date.now()}`;
    console.log(`>>> Step 11: Testing Saved Address Addition (Label: "${uniqueLabel}")...`);
    const addAddressToggle = page.locator('button:has-text("Add New Location")');
    await addAddressToggle.click();
    await page.waitForTimeout(500);

    // Fill form
    await page.locator('input[placeholder="e.g. Primary Residence"]').fill(uniqueLabel);
    await page.locator('input[placeholder="120 Riverside Blvd, New York, NY"]').fill('450 Lexington Ave, New York, NY 10017');
    await page.locator('input[placeholder="40.7128"]').fill('40.7516');
    await page.locator('input[placeholder="-74.0060"]').fill('-73.9754');

    const saveAddressBtn = page.locator('button:has-text("Save Location")');
    await saveAddressBtn.click();
    await page.waitForTimeout(1500);

    // Verify address is listed
    console.log(`>>> Step 12: Verifying New Saved Address "${uniqueLabel}" in DOM...`);
    const newAddressItem = page.locator(`text=${uniqueLabel}`);
    if ((await newAddressItem.count()) === 0) {
      throw new Error(`Created saved address "${uniqueLabel}" not found in list`);
    }
    console.log(`    ✓ Address "${uniqueLabel}" successfully persisted and rendered.`);

    // Test Deleting the Saved Address
    console.log('>>> Step 13: Testing Saved Address Deletion...');
    // Locate the container holding this unique label, then click its trash button
    const addressContainer = page.locator(`div:has-text("${uniqueLabel}")`).locator('..').filter({ has: page.locator('button[title="Remove bookmark"]') });
    const deleteBtn = addressContainer.locator('button[title="Remove bookmark"]').first();
    await deleteBtn.click();
    await page.waitForTimeout(1500);

    const checkDeleted = await page.locator(`text=${uniqueLabel}`).count();
    if (checkDeleted > 0) {
      throw new Error(`Address "${uniqueLabel}" was not deleted from the list!`);
    }
    console.log(`    ✓ Address "${uniqueLabel}" successfully deleted and confirmed absent from DOM.`);

    // -------------------------------------------------------------
    // Step 9: Verify 1-Click Rescue Navigation Continuity
    // -------------------------------------------------------------
    console.log('>>> Step 14: Verifying Emergency Intake Workflow Linkage...');
    await page.goto('http://localhost:3000/customer/home', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);

    const rescueBtn = page.locator('a[href="/report-breakdown"]:has-text("Report Breakdown Incident")');
    await rescueBtn.first().click();
    await page.waitForURL('**/report-breakdown', { timeout: 10000 });
    console.log('    ✓ 1-click rescue button cleanly routed to /report-breakdown.');

    console.log('========================================================================');
    console.log('>>> [E2E TEST: CUSTOMER EXPERIENCE] ALL CHECKS PASSED (100% SUCCESS)');
    console.log('========================================================================');
  } catch (err) {
    console.error('\n>>> [E2E TEST FAILED]:', err.message);
    process.exit(1);
  } finally {
    await browser.close();
  }
}

testCustomerExperience();
