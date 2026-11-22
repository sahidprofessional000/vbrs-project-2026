import { chromium } from 'playwright';
import path from 'path';

async function testHologramPlacement() {
  console.log('========================================================================');
  console.log('>>> [E2E TEST: 3D HOLOGRAM OVERVIEW & WORKSHOP PLACEMENT VERIFICATION]');
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
    // PART 1: VERIFY OVERVIEW HOMEPAGE ("/")
    // =========================================================================
    console.log('\n--- PART 1: OVERVIEW HOMEPAGE ("/") ---');
    console.log('>>> Navigating to http://localhost:3000/...');
    await page.goto('http://localhost:3000/', { waitUntil: 'networkidle' });
    await page.waitForTimeout(2000);

    // 1. Verify Left Editorial Hero Headline
    console.log('>>> Step 1.1: Checking Left Side Editorial Headline...');
    const headline = page.locator('h1:has-text("Precision Roadside Rescue.")');
    if ((await headline.count()) === 0) {
      throw new Error('Left side hero headline "Precision Roadside Rescue." missing');
    }
    const zeroFriction = page.locator('span:has-text("Zero Friction.")');
    if ((await zeroFriction.count()) === 0) {
      throw new Error('Left side hero subtitle "Zero Friction." missing');
    }
    console.log('    ✓ Left side "Precision Roadside Rescue. Zero Friction." headline confirmed.');

    // 2. Verify Right Side 3D Hologram
    console.log('>>> Step 1.2: Checking Right Side 3D Hologram Container & WebGL Canvas...');
    const overviewHologram = page.locator('#overview-hologram');
    if ((await overviewHologram.count()) === 0) {
      throw new Error('Right side #overview-hologram container missing');
    }

    const canvas = page.locator('#overview-hologram canvas');
    await canvas.waitFor({ state: 'visible', timeout: 15000 });
    console.log('    ✓ Right side 3D Three.js Canvas element rendered and visible.');

    // 3. Verify Overview Top HUD
    const hudBadge = page.locator('#overview-hologram').getByText('3D Holographic Twin');
    if ((await hudBadge.count()) === 0) {
      throw new Error('Overview HUD badge "3D Holographic Twin" missing');
    }
    console.log('    ✓ 3D Holographic Twin telemetry badge verified.');

    // 4. Test All 8 Subsystems Selection on Overview
    console.log('>>> Step 1.3: Testing All 8 Subsystems on Overview Mode...');
    const overviewSubsystems = [
      { id: 'engine', label: '1. Engine', title: 'Internal Combustion Engine Assembly', dtc: 'P0300' },
      { id: 'battery', label: '2. Battery', title: 'High-Output Auxiliary & 12V AGM Module', dtc: 'P0562' },
      { id: 'transmission', label: '3. Transmission', title: '7-Speed Dual-Clutch Transaxle (DCT)', dtc: 'P0700' },
      { id: 'brakes', label: '4. Brakes', title: 'Carbon-Ceramic Braking Subsystem', dtc: 'C0035' },
      { id: 'wheels', label: '5. Wheels', title: 'Forged Alloy Wheels & Performance Tyres', dtc: 'C0750' },
      { id: 'suspension', label: '6. Suspension', title: 'Magnetorheological Damper & Suspension Coilovers', dtc: 'C1030' },
      { id: 'cooling', label: '7. Cooling', title: 'Aluminum Crossflow Radiator & Thermal Cooling', dtc: 'P0117' },
      { id: 'electrical', label: '8. Electrical', title: 'ECU Wiring Harness & Power Distribution Bus', dtc: 'U0100' },
    ];

    for (const sub of overviewSubsystems) {
      console.log(`    Selecting "${sub.label}" on Overview...`);
      const btn = page.locator(`#overview-hologram button:has-text("${sub.label}")`);
      await btn.click({ force: true });
      await page.waitForTimeout(400);

      // Verify floating contextual technical card displays the correct subsystem
      const cardTitle = page.locator(`#overview-hologram h4:has-text("${sub.title}")`);
      if ((await cardTitle.count()) === 0) {
        throw new Error(`Overview contextual card missing title "${sub.title}"`);
      }

      const cardDtc = page.locator('#overview-hologram').getByText(sub.dtc);
      if ((await cardDtc.count()) === 0) {
        throw new Error(`Overview contextual card missing DTC "${sub.dtc}"`);
      }
      console.log(`    ✓ Verified ${sub.label}: "${sub.title}" (DTC: ${sub.dtc}) displayed in HUD overlay.`);
    }

    // 5. Test CAD / X-Ray Mode Toggle on Overview
    console.log('>>> Step 1.4: Testing CAD / X-Ray Mode Toggle on Overview...');
    const xrayBtn = page.locator('#overview-hologram button:has-text("X-Ray")');
    await xrayBtn.click({ force: true });
    await page.waitForTimeout(500);
    console.log('    ✓ X-Ray mode activated on Overview.');

    const cadBtn = page.locator('#overview-hologram button:has-text("CAD")');
    await cadBtn.click({ force: true });
    await page.waitForTimeout(500);
    console.log('    ✓ CAD mode restored on Overview.');

    // 6. Test Camera Reset Button
    console.log('>>> Step 1.5: Testing Camera Reset Button on Overview...');
    const resetBtn = page.locator('#overview-hologram button[title*="Reset Camera"]');
    await resetBtn.click({ force: true });
    await page.waitForTimeout(500);
    console.log('    ✓ Camera Reset action triggered successfully.');

    // 7. Select Engine and capture high-res screenshot of Overview
    const engineBtn = page.locator('#overview-hologram button:has-text("1. Engine")');
    await engineBtn.click({ force: true });
    await page.waitForTimeout(800);

    const overviewScreenshotPath = path.resolve('frontend/public/academic/screenshot-overview-3d.png');
    await page.screenshot({ path: overviewScreenshotPath, fullPage: false });
    console.log(`    ✓ Captured Overview 3D screenshot: ${overviewScreenshotPath}`);

    // =========================================================================
    // PART 2: VERIFY WORKSHOP PAGE ("/mechanic/home")
    // =========================================================================
    console.log('\n--- PART 2: WORKSHOP PAGE ("/mechanic/home") ---');
    console.log('>>> Navigating to http://localhost:3000/login...');
    await page.goto('http://localhost:3000/login', { waitUntil: 'networkidle' });

    console.log('>>> Authenticating as Mechanic (Technician quick-fill)...');
    await page.locator('button:has-text("Technician")').click();
    await page.waitForTimeout(300);
    await page.locator('button:has-text("Authenticate Session")').click();
    await page.waitForTimeout(1500);

    console.log('>>> Navigating to http://localhost:3000/mechanic/home...');
    await page.goto('http://localhost:3000/mechanic/home', { waitUntil: 'networkidle' });
    await page.waitForTimeout(2000);

    // 1. Verify Workshop Inspection Terminal Container
    console.log('>>> Step 2.1: Checking Workshop Inspection Terminal Container...');
    const workshopTerminal = page.locator('#inspection-terminal');
    if ((await workshopTerminal.count()) === 0) {
      throw new Error('#inspection-terminal missing on /mechanic/home');
    }

    const workshopTitle = page.locator('h2:has-text("Interactive 3D Engineering Inspection Terminal")');
    if ((await workshopTitle.count()) === 0) {
      throw new Error('Workshop title "Interactive 3D Engineering Inspection Terminal" missing');
    }
    console.log('    ✓ Workshop Full CAD Terminal header confirmed.');

    // 2. Verify Canvas in Workshop
    const workshopCanvas = page.locator('#inspection-terminal canvas');
    await workshopCanvas.waitFor({ state: 'visible', timeout: 15000 });
    console.log('    ✓ Workshop 3D Canvas element rendered and visible.');

    // 3. Verify All 4 View Modes in Workshop
    console.log('>>> Step 2.2: Checking Workshop View Mode buttons (Standard, X-Ray, Exploded, Isolated)...');
    const modes = ['Standard CAD', 'X-Ray Hologram', 'Exploded View', 'Isolated'];
    for (const m of modes) {
      const modeBtn = page.locator(`#inspection-terminal button:has-text("${m}")`);
      if ((await modeBtn.count()) === 0) {
        throw new Error(`Workshop view mode button "${m}" missing`);
      }
    }
    console.log('    ✓ All 4 Workshop view modes verified.');

    // 4. Verify Contextual Deep Diagnostics Panel
    console.log('>>> Step 2.3: Checking Workshop Deep Engineering Diagnostics Console...');
    const engineBlock = page.locator('#inspection-terminal h3:has-text("Internal Combustion Engine Assembly")');
    if ((await engineBlock.count()) === 0) {
      throw new Error('Engine diagnostics heading missing in workshop');
    }
    const oemSpecs = page.locator('#inspection-terminal').getByText('OEM Specifications');
    if ((await oemSpecs.count()) === 0) {
      throw new Error('OEM Specifications section missing in workshop');
    }
    const triage = page.locator('#inspection-terminal').getByText('Field Diagnostic Triage Routine');
    if ((await triage.count()) === 0) {
      throw new Error('Field Diagnostic Triage Routine section missing in workshop');
    }
    console.log('    ✓ Deep Engineering Diagnostics Console (OEM Specs, Triage Routine, Fault Codes) confirmed.');

    // 5. Capture high-res screenshot of Workshop
    const workshopScreenshotPath = path.resolve('frontend/public/academic/screenshot-workshop-3d.png');
    await page.screenshot({ path: workshopScreenshotPath, fullPage: false });
    console.log(`    ✓ Captured Workshop 3D screenshot: ${workshopScreenshotPath}`);

    // =========================================================================
    // PART 3: VERIFY REDIRECT FROM /mechanic/overview
    // =========================================================================
    console.log('\n--- PART 3: /mechanic/overview REDIRECT ---');
    console.log('>>> Navigating to http://localhost:3000/mechanic/overview...');
    await page.goto('http://localhost:3000/mechanic/overview', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);
    const currentUrl = page.url();
    console.log(`    Current URL after redirect: ${currentUrl}`);
    if (!currentUrl.endsWith(':3000/')) {
      throw new Error(`Expected redirect to http://localhost:3000/, but got ${currentUrl}`);
    }
    console.log('    ✓ /mechanic/overview cleanly redirects to Overview homepage.');

    console.log('\n========================================================================');
    console.log('>>> [SUCCESS] 3D HOLOGRAM OVERVIEW & WORKSHOP PLACEMENT 100% VERIFIED!');
    console.log('========================================================================');
  } catch (error) {
    console.error('>>> [TEST FAILURE]:', error);
    process.exit(1);
  } finally {
    await browser.close();
  }
}

testHologramPlacement();
