import { chromium } from 'playwright';
import path from 'path';

async function testHologram3D() {
  console.log('========================================================================');
  console.log('>>> [E2E TEST: 3D AUTOMOTIVE HOLOGRAM] Step 5 Verification Suite');
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
    // -------------------------------------------------------------
    // Step 1: Authenticate as Field Mechanic
    // -------------------------------------------------------------
    console.log('>>> Step 1: Navigating to http://localhost:3000/login...');
    await page.goto('http://localhost:3000/login', { waitUntil: 'networkidle' });

    console.log('>>> Step 2: Authenticating as Mechanic (Technician quick-fill)...');
    await page.locator('button:has-text("Technician")').click();
    await page.waitForTimeout(300);
    await page.locator('button:has-text("Authenticate Session")').click();
    await page.waitForTimeout(1500);

    // -------------------------------------------------------------
    // Step 2: Navigate to Mechanic Workspace
    // -------------------------------------------------------------
    console.log('>>> Step 3: Navigating to http://localhost:3000/mechanic/home...');
    await page.goto('http://localhost:3000/mechanic/home', { waitUntil: 'networkidle' });
    await page.waitForTimeout(2000);

    // -------------------------------------------------------------
    // Step 3: Verify 3D Inspection Terminal Container & Canvas
    // -------------------------------------------------------------
    console.log('>>> Step 4: Verifying 3D Inspection Terminal DOM & Canvas presence...');
    const terminalContainer = page.locator('#inspection-terminal');
    if ((await terminalContainer.count()) === 0) {
      throw new Error('#inspection-terminal container missing');
    }

    const terminalTitle = page.locator('h2:has-text("Interactive 3D Engineering Inspection Terminal")');
    if ((await terminalTitle.count()) === 0) {
      throw new Error('Inspection terminal header missing');
    }
    console.log('    ✓ 3D Inspection Terminal header verified.');

    // Wait for 3D Canvas
    const canvas = page.locator('#inspection-terminal canvas');
    await canvas.waitFor({ state: 'visible', timeout: 15000 });
    console.log('    ✓ WebGL Three.js 3D Canvas element rendered and visible.');

    // -------------------------------------------------------------
    // Step 4: Verify All 8 Selectable Subsystems
    // -------------------------------------------------------------
    console.log('>>> Step 5: Testing All 8 Subsystem Selections & Engineering Metadata...');
    
    const subsystemsToVerify = [
      {
        id: 'engine',
        chipLabel: '1. Engine Block',
        fullName: 'Internal Combustion Engine Assembly',
        expectedDtc: 'P0300',
        expectedSpec: '4,497 cc (4.5 L)',
      },
      {
        id: 'battery',
        chipLabel: '2. Battery Module',
        fullName: 'High-Output Auxiliary & 12V AGM Module',
        expectedDtc: 'P0562',
        expectedSpec: '850 CCA (SAE)',
      },
      {
        id: 'transmission',
        chipLabel: '3. Transmission',
        fullName: '7-Speed Dual-Clutch Transaxle (DCT)',
        expectedDtc: 'P0700',
        expectedSpec: '7-Speed Dual-Clutch (DCT) Transaxle',
      },
      {
        id: 'brakes',
        chipLabel: '4. Braking System',
        fullName: 'Carbon-Ceramic Braking Subsystem',
        expectedDtc: 'C0035',
        expectedSpec: '398 mm x 36 mm Carbon-Ceramic Matrix (CCM)',
      },
      {
        id: 'wheels',
        chipLabel: '5. Wheels & Tyres',
        fullName: 'Forged Alloy Wheels & Performance Tyres',
        expectedDtc: 'C0750',
        expectedSpec: '235/35 ZR20 (92Y) XL',
      },
      {
        id: 'suspension',
        chipLabel: '6. Suspension Struts',
        fullName: 'Magnetorheological Damper & Suspension Coilovers',
        expectedDtc: 'C1030',
        expectedSpec: 'BWI Magnetorheological Fluid Adaptive (SCM3)',
      },
      {
        id: 'cooling',
        chipLabel: '7. Radiator Cooling',
        fullName: 'Aluminum Crossflow Radiator & Thermal Cooling',
        expectedDtc: 'P0117',
        expectedSpec: 'Dual-Pass Aluminum Crossflow with High-Density Fins',
      },
      {
        id: 'electrical',
        chipLabel: '8. Electrical Harness',
        fullName: 'ECU Wiring Harness & Power Distribution Bus',
        expectedDtc: 'U0100',
        expectedSpec: 'Bosch Motronic MED 17.3.1 32-bit Tricore Processor',
      },
    ];

    for (const sub of subsystemsToVerify) {
      console.log(`    Testing subsystem selection: "${sub.chipLabel}"...`);
      const chip = page.locator(`button:has-text("${sub.chipLabel}")`);
      await chip.click({ force: true });
      await page.waitForTimeout(600);

      // Verify header in engineering panel
      const componentHeading = page.locator(`h3:has-text("${sub.fullName}")`);
      if ((await componentHeading.count()) === 0) {
        throw new Error(`Engineering panel did not update to "${sub.fullName}"`);
      }

      // Verify DTC code is displayed
      const dtcCode = page.locator(`text=${sub.expectedDtc}`);
      if ((await dtcCode.count()) === 0) {
        throw new Error(`Expected diagnostic code ${sub.expectedDtc} missing for ${sub.id}`);
      }

      // Verify specification value is rendered
      const spec = page.locator(`text=${sub.expectedSpec}`);
      if ((await spec.count()) === 0) {
        throw new Error(`Expected specification "${sub.expectedSpec}" missing for ${sub.id}`);
      }

      console.log(`    ✓ Verified ${sub.chipLabel}: DTC ${sub.expectedDtc} & OEM spec confirmed.`);
    }

    // -------------------------------------------------------------
    // Step 5: Test View Modes (Standard, X-Ray, Exploded, Isolated)
    // -------------------------------------------------------------
    console.log('>>> Step 6: Testing View Mode Segmented Controls...');

    // Select X-Ray Hologram mode
    console.log('    Testing X-Ray Hologram mode...');
    const xrayBtn = page.locator('button:has-text("X-Ray Hologram")');
    await xrayBtn.click({ force: true });
    await page.waitForTimeout(800);
    const xrayTelemetry = page.locator('text=MODE: XRAY');
    if ((await xrayTelemetry.count()) === 0) {
      throw new Error('Telemetry overlay did not reflect MODE: XRAY');
    }
    console.log('    ✓ X-Ray Hologram mode activated and confirmed in telemetry.');

    // Capture screenshot of X-Ray view
    const xRayScreenshotPath = path.resolve('./frontend/public/academic/screenshot-3d-hologram.png');
    await terminalContainer.screenshot({ path: xRayScreenshotPath });
    console.log(`    ✓ Captured 3D X-Ray Hologram screenshot: ${xRayScreenshotPath}`);

    // Select Exploded View mode
    console.log('    Testing Exploded View mode...');
    const explodedBtn = page.locator('button:has-text("Exploded View")');
    await explodedBtn.click({ force: true });
    await page.waitForTimeout(1000);
    const explodedTelemetry = page.locator('text=MODE: EXPLODED');
    if ((await explodedTelemetry.count()) === 0) {
      throw new Error('Telemetry overlay did not reflect MODE: EXPLODED');
    }
    console.log('    ✓ Exploded View mode activated and confirmed.');

    // Capture screenshot of Exploded view
    const explodedScreenshotPath = path.resolve('./frontend/public/academic/screenshot-3d-exploded.png');
    await terminalContainer.screenshot({ path: explodedScreenshotPath });
    console.log(`    ✓ Captured 3D Exploded View screenshot: ${explodedScreenshotPath}`);

    // Select Isolated mode
    console.log('    Testing Isolated Subsystem mode...');
    const isolatedBtn = page.locator('button:has-text("Isolated")');
    await isolatedBtn.click({ force: true });
    await page.waitForTimeout(600);
    const isolatedTelemetry = page.locator('text=MODE: ISOLATED');
    if ((await isolatedTelemetry.count()) === 0) {
      throw new Error('Telemetry overlay did not reflect MODE: ISOLATED');
    }
    console.log('    ✓ Isolated mode activated.');

    // -------------------------------------------------------------
    // Step 6: Test Reset View Controls
    // -------------------------------------------------------------
    console.log('>>> Step 7: Testing Reset View Controls...');
    const resetBtn = page.locator('button:has-text("Reset View")');
    await resetBtn.click({ force: true });
    await page.waitForTimeout(800);

    const standardTelemetry = page.locator('text=MODE: STANDARD');
    if ((await standardTelemetry.count()) === 0) {
      throw new Error('Reset View failed to revert to MODE: STANDARD');
    }
    console.log('    ✓ Reset View successfully reverted viewport to default CAD mode.');

    // -------------------------------------------------------------
    // Step 7: Test Interactive 3D Camera Orbit Controls (Mouse Drag)
    // -------------------------------------------------------------
    console.log('>>> Step 8: Simulating 360-Degree Camera Orbit Drag...');
    const canvasBox = await canvas.boundingBox();
    if (canvasBox) {
      const startX = canvasBox.x + canvasBox.width / 2;
      const startY = canvasBox.y + canvasBox.height / 2;
      await page.mouse.move(startX, startY);
      await page.mouse.down();
      await page.mouse.move(startX + 180, startY - 40, { steps: 10 });
      await page.mouse.up();
      await page.waitForTimeout(500);
      console.log('    ✓ 360-degree orbit drag simulation executed smoothly.');
    }

    console.log('========================================================================');
    console.log('>>> [E2E TEST: 3D AUTOMOTIVE HOLOGRAM] ALL CHECKS PASSED (100% SUCCESS)');
    console.log('========================================================================');
  } catch (err) {
    console.error('\n>>> [E2E TEST FAILED]:', err.message);
    process.exit(1);
  } finally {
    await browser.close();
  }
}

testHologram3D();
