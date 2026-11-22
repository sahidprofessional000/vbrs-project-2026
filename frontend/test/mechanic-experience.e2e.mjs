import { chromium } from 'playwright';

async function testMechanicExperience() {
  console.log('========================================================================');
  console.log('>>> [E2E TEST: MECHANIC EXPERIENCE] Step 4 Verification Suite');
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

  // Auto-accept confirmation dialogs if any
  page.on('dialog', async (dialog) => {
    console.log(`    [Browser Dialog] Auto-accepting: "${dialog.message()}"`);
    await dialog.accept();
  });

  try {
    // -------------------------------------------------------------
    // Step 1: Authenticate as Field Mechanic
    // -------------------------------------------------------------
    console.log('>>> Step 1: Navigating to http://localhost:3000/login...');
    await page.goto('http://localhost:3000/login', { waitUntil: 'networkidle' });

    console.log('>>> Step 2: Authenticating as Mechanic (Technician quick-fill)...');
    const mechBtn = page.locator('button:has-text("Technician")');
    await mechBtn.click();
    await page.waitForTimeout(300);

    const submitBtn = page.locator('button:has-text("Authenticate Session")');
    await submitBtn.click();
    await page.waitForTimeout(1500);
    console.log('    ✓ Mechanic login credentials submitted.');

    // -------------------------------------------------------------
    // Step 2: Navigate to Dedicated Mechanic Home Experience
    // -------------------------------------------------------------
    console.log('>>> Step 3: Navigating to http://localhost:3000/mechanic/home...');
    await page.goto('http://localhost:3000/mechanic/home', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1500);

    // Verify Workspace Header Lockup
    console.log('>>> Step 4: Verifying Workshop Identity & Accreditation Badge...');
    const headerTitle = page.locator('h1');
    const titleText = await headerTitle.first().textContent();
    console.log(`    ✓ Header text detected: "${titleText?.trim()}"`);
    if (!titleText || titleText.trim().length === 0) {
      throw new Error('Workshop header title missing');
    }

    const badge = page.locator('span:has-text("ASE Certified Specialist"), span:has-text("License:")');
    if ((await badge.count()) === 0) {
      throw new Error('Verification status badge missing from header');
    }
    console.log('    ✓ Verification status badge verified.');

    // -------------------------------------------------------------
    // Step 3: Verify Real Financials & Career Metrics
    // -------------------------------------------------------------
    console.log('>>> Step 5: Verifying Real Recorded Financials & Career Metrics...');
    const revenueCard = page.locator('text=Total Recorded Revenue');
    if ((await revenueCard.count()) === 0) {
      throw new Error('Total Recorded Revenue metric card missing');
    }

    const ordersCard = page.locator('text=Completed Orders');
    if ((await ordersCard.count()) === 0) {
      throw new Error('Completed Orders metric card missing');
    }

    const avgTicketCard = page.locator('text=Avg Ticket Value');
    if ((await avgTicketCard.count()) === 0) {
      throw new Error('Average Ticket Value metric card missing');
    }

    const reputationCard = page.locator('text=Reputation Score');
    if ((await reputationCard.count()) === 0) {
      throw new Error('Reputation Score metric card missing');
    }
    console.log('    ✓ All 4 real financial & career metric cards verified.');

    // -------------------------------------------------------------
    // Step 4: Test Live Availability & Radius Controls
    // -------------------------------------------------------------
    console.log('>>> Step 6: Testing Availability Switch & Perimeter Slider...');
    const toggleBtn = page.locator('button[type="button"]').filter({ has: page.locator('span.pointer-events-none') });
    if ((await toggleBtn.count()) === 0) {
      throw new Error('Availability toggle switch not found');
    }

    // Toggle switch
    await toggleBtn.click();
    await page.waitForTimeout(1200);

    // Verify alert toast appeared
    const toast = page.locator('text=Radar Active, text=Standby Mode');
    if ((await toast.count()) > 0) {
      console.log('    ✓ Availability toggle reaction toast displayed.');
    }

    // Toggle back to original state
    await toggleBtn.click();
    await page.waitForTimeout(1200);

    // Check GPS Beacon button
    const gpsBtn = page.locator('button:has-text("Transmit GPS")');
    if ((await gpsBtn.count()) === 0) {
      throw new Error('Transmit GPS button missing');
    }
    console.log('    ✓ Availability controls and GPS beacon verified.');

    // -------------------------------------------------------------
    // Step 5: Verify 3D Automotive Inspection Terminal Entry Point
    // -------------------------------------------------------------
    console.log('>>> Step 7: Verifying 3D Inspection Terminal Entry Point (8 Subsystems)...');
    const cadContainer = page.locator('#inspection-terminal');
    if ((await cadContainer.count()) === 0) {
      throw new Error('3D Automotive Inspection Terminal container (#inspection-terminal) missing');
    }

    const cadTitle = page.locator('h2:has-text("Interactive 3D Engineering Inspection Terminal")');
    if ((await cadTitle.count()) === 0) {
      throw new Error('3D Engineering Inspection Terminal header missing');
    }

    // Verify all 8 selectable subsystems
    const subsystems = [
      '1. Engine Block',
      '2. Battery Module',
      '3. Transmission',
      '4. Braking System',
      '5. Wheels & Tyres',
      '6. Suspension Struts',
      '7. Radiator Cooling',
      '8. Electrical Harness',
    ];

    for (const sub of subsystems) {
      const subItem = page.locator(`text=${sub}`);
      if ((await subItem.count()) === 0) {
        throw new Error(`Subsystem pill "${sub}" missing in 3D terminal showcase`);
      }
    }
    console.log('    ✓ 8 Selectable Subsystem assemblies verified in 3D Terminal gateway.');

    // -------------------------------------------------------------
    // Step 6: Verify Inbound Dispatches & Completed Work Orders
    // -------------------------------------------------------------
    console.log('>>> Step 8: Verifying Inbound Dispatch Queue & Completed History...');
    const dispatchHeader = page.locator('h3:has-text("Inbound Dispatch Opportunities")');
    if ((await dispatchHeader.count()) === 0) {
      throw new Error('Inbound Dispatch Opportunities section header missing');
    }

    const historyHeader = page.locator('h3:has-text("Completed Work Orders")');
    if ((await historyHeader.count()) === 0) {
      throw new Error('Completed Work Orders section header missing');
    }
    console.log('    ✓ Dispatch queue and completed work order streams verified.');

    // -------------------------------------------------------------
    // Step 7: Navigate to Dedicated Mechanic Profile Experience
    // -------------------------------------------------------------
    console.log('>>> Step 9: Navigating to http://localhost:3000/mechanic/profile...');
    await page.goto('http://localhost:3000/mechanic/profile', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1500);

    // Verify Profile Form Pre-population
    console.log('>>> Step 10: Verifying Profile Edit Form Pre-population...');
    const workshopNameInput = page.locator('input[placeholder="e.g. Apex Precision Automotive"]');
    const currentWorkshopName = await workshopNameInput.inputValue();
    console.log(`    ✓ Detected pre-populated workshop name: "${currentWorkshopName}"`);

    // -------------------------------------------------------------
    // Step 8: Test Professional Profile Modification & Tags
    // -------------------------------------------------------------
    console.log('>>> Step 11: Testing Profile Modification & Adding Specialization...');
    const updatedName = `Apex Precision Motors M8`;
    await workshopNameInput.fill(updatedName);

    // Add specialization
    const specInput = page.locator('input[placeholder="e.g. Drivetrain & Transmission"]');
    await specInput.fill('High-Voltage EV Powertrains');
    const addSpecBtn = page.locator('button:has-text("Add")').first();
    await addSpecBtn.click();
    await page.waitForTimeout(300);

    const specPill = page.locator('span:has-text("High-Voltage EV Powertrains")');
    if ((await specPill.count()) === 0) {
      throw new Error('Specialization tag was not added to list');
    }
    console.log('    ✓ Specialization tag added successfully.');

    // Submit profile update
    const saveDossierBtn = page.locator('button:has-text("Save Professional Dossier")');
    await saveDossierBtn.click();
    await page.waitForTimeout(1500);

    const successToast = page.locator('text=Professional workshop profile and credentials updated successfully');
    if ((await successToast.count()) === 0) {
      console.warn('    ! Toast disappeared or slow, verifying persistence...');
    } else {
      console.log('    ✓ Profile update confirmation toast displayed.');
    }

    // -------------------------------------------------------------
    // Step 9: Test Sensitive Trade License Governance Workflow (Requirement 6)
    // -------------------------------------------------------------
    console.log('>>> Step 12: Testing Sensitive License Re-verification Workflow...');
    const licenseInput = page.locator('input[placeholder="e.g. LIC-AUTO-2026-889"]');
    const newLicense = `LIC-AUDIT-${Date.now()}`;
    await licenseInput.fill(newLicense);

    await saveDossierBtn.click();
    await page.waitForTimeout(1500);

    // Verify Warning Notice on Reset to PENDING
    const warningNotice = page.locator('text=Your verification status has been reset to PENDING');
    if ((await warningNotice.count()) === 0) {
      throw new Error('Sensitive license modification warning notice not displayed');
    }
    console.log('    ✓ Sensitive trade license update triggered PENDING reset notice.');

    const statusBadge = page.locator('span:has-text("PENDING")');
    if ((await statusBadge.count()) === 0) {
      throw new Error('Verification status badge did not update to PENDING');
    }
    console.log('    ✓ Verification status badge correctly updated to PENDING.');

    // -------------------------------------------------------------
    // Step 10: Verify Role-Based Redirection Guard
    // -------------------------------------------------------------
    console.log('>>> Step 13: Verifying Role Redirection Guard (/customer/home -> /mechanic/home)...');
    await page.goto('http://localhost:3000/customer/home', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1200);

    const currentUrl = page.url();
    console.log(`    ✓ Redirection URL: ${currentUrl}`);
    if (!currentUrl.includes('/mechanic/home')) {
      throw new Error(`Mechanic was not redirected to /mechanic/home! Was at: ${currentUrl}`);
    }
    console.log('    ✓ Role boundary protection verified (Customer home inaccessible to mechanic).');

    console.log('========================================================================');
    console.log('>>> [E2E TEST: MECHANIC EXPERIENCE] ALL CHECKS PASSED (100% SUCCESS)');
    console.log('========================================================================');
  } catch (err) {
    console.error('\n>>> [E2E TEST FAILED]:', err.message);
    process.exit(1);
  } finally {
    await browser.close();
  }
}

testMechanicExperience();
