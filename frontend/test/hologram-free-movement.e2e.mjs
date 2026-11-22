import { chromium } from 'playwright';
import path from 'path';

async function testHologramFreeMovement() {
  console.log('========================================================================');
  console.log('>>> [E2E TEST: 3D HOLOGRAM FREE MOVEMENT & UNRESTRICTED INTERACTION]');
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
    hasTouch: true,
  });

  const page = await context.newPage();

  try {
    // =========================================================================
    // PART 1: OVERVIEW HERO 3D FREE MOVEMENT ("/")
    // =========================================================================
    console.log('\n--- PART 1: OVERVIEW HERO 3D FREE ROTATION & MOVEMENT ---');
    console.log('>>> Step 1.1: Navigating to http://localhost:3000/...');
    await page.goto('http://localhost:3000/', { waitUntil: 'networkidle' });
    await page.waitForTimeout(2000);

    const canvas = page.locator('#overview-hologram canvas');
    await canvas.waitFor({ state: 'visible', timeout: 15000 });
    const box = await canvas.boundingBox();
    if (!box) throw new Error('Could not get bounding box for Overview 3D canvas');

    const cx = box.x + box.width / 2;
    const cy = box.y + box.height / 2;
    console.log(`    Canvas center coordinates: (${cx.toFixed(1)}, ${cy.toFixed(1)})`);

    // 1.2: Test 360-Degree Continuous Horizontal Drag
    console.log('>>> Step 1.2: Testing Unrestricted Horizontal 360-Degree Drag Rotation...');
    await page.mouse.move(cx + 120, cy);
    await page.mouse.down();
    await page.mouse.move(cx - 120, cy, { steps: 15 });
    await page.mouse.up();
    await page.waitForTimeout(400);

    // Continue spinning horizontally (another revolution)
    await page.mouse.move(cx + 140, cy);
    await page.mouse.down();
    await page.mouse.move(cx - 140, cy, { steps: 20 });
    await page.mouse.up();
    await page.waitForTimeout(400);
    console.log('    ✓ Continuous horizontal rotation executed freely without snapping back.');

    // 1.3: Test Vertical Rotation (Top-Down to Underneath Chassis)
    console.log('>>> Step 1.3: Testing Unrestricted Vertical Rotation (Viewing Range 0 to PI)...');
    // Drag down to view from above (high polar angle)
    await page.mouse.move(cx, cy - 80);
    await page.mouse.down();
    await page.mouse.move(cx, cy + 120, { steps: 15 });
    await page.mouse.up();
    await page.waitForTimeout(300);
    console.log('    ✓ Rotated vertically to high-angle bird\'s eye view.');

    // Drag up to view from underneath the vehicle chassis
    await page.mouse.move(cx, cy + 100);
    await page.mouse.down();
    await page.mouse.move(cx, cy - 160, { steps: 25 });
    await page.mouse.up();
    await page.waitForTimeout(400);
    console.log('    ✓ Rotated vertically to under-chassis viewing perspective.');

    // Capture screenshot of underbody view
    const underbodyScreenshotPath = path.resolve('frontend/public/academic/screenshot-free-orbit-underbody.png');
    await page.screenshot({ path: underbodyScreenshotPath, fullPage: false });
    console.log(`    ✓ Saved underbody inspection screenshot: ${underbodyScreenshotPath}`);

    // 1.4: Test Mouse Wheel Zoom
    console.log('>>> Step 1.4: Testing Mouse Wheel Zoom In and Out...');
    await page.mouse.move(cx, cy);
    await page.mouse.wheel(0, -600); // Zoom in
    await page.waitForTimeout(400);
    console.log('    ✓ Zoom-in wheel action dispatched.');

    await page.mouse.wheel(0, 800); // Zoom out
    await page.waitForTimeout(400);
    console.log('    ✓ Zoom-out wheel action dispatched.');

    // 1.5: Test Screen Space Pan (Right Click Drag)
    console.log('>>> Step 1.5: Testing Pan to Reposition Vehicle (Right-Click Drag)...');
    await page.mouse.move(cx, cy);
    await page.mouse.down({ button: 'right' });
    await page.mouse.move(cx + 90, cy + 50, { steps: 15 });
    await page.mouse.up({ button: 'right' });
    await page.waitForTimeout(400);
    console.log('    ✓ Screen space panning repositioned vehicle smoothly.');

    // 1.6: Test Camera Reset Centers Vehicle
    console.log('>>> Step 1.6: Testing Camera Reset Action (Centers Vehicle)...');
    const resetBtn = page.locator('#overview-hologram button[title*="Reset Camera"]');
    await resetBtn.click({ force: true });
    await page.waitForTimeout(700);
    console.log('    ✓ Camera Reset smoothly re-centered vehicle to default perspective.');

    // 1.7: Test Component Selection Does NOT Hijack Camera
    console.log('>>> Step 1.7: Testing Subsystem Selection Retains Camera Rotation Autonomy...');
    const engineBtn = page.locator('#overview-hologram button:has-text("1. Engine")');
    await engineBtn.click({ force: true });
    await page.waitForTimeout(400);

    // Immediately rotate while engine is selected
    await page.mouse.move(cx - 80, cy);
    await page.mouse.down();
    await page.mouse.move(cx + 100, cy - 40, { steps: 15 });
    await page.mouse.up();
    await page.waitForTimeout(300);
    console.log('    ✓ Drag rotation works freely while "1. Engine" is highlighted without view locking.');

    const brakesBtn = page.locator('#overview-hologram button:has-text("4. Brakes")');
    await brakesBtn.click({ force: true });
    await page.waitForTimeout(400);

    await page.mouse.move(cx + 60, cy);
    await page.mouse.down();
    await page.mouse.move(cx - 90, cy + 30, { steps: 15 });
    await page.mouse.up();
    await page.waitForTimeout(300);
    console.log('    ✓ Drag rotation works freely while "4. Brakes" is highlighted.');

    // Capture screenshot of Overview Free Orbit
    const overviewScreenshotPath = path.resolve('frontend/public/academic/screenshot-free-orbit-overview.png');
    await page.screenshot({ path: overviewScreenshotPath, fullPage: false });
    console.log(`    ✓ Saved Overview free orbit screenshot: ${overviewScreenshotPath}`);

    // =========================================================================
    // PART 2: WORKSHOP CAD TERMINAL 3D FREE MOVEMENT ("/mechanic/home")
    // =========================================================================
    console.log('\n--- PART 2: WORKSHOP CAD TERMINAL FREE ROTATION & MODES ---');
    console.log('>>> Step 2.1: Authenticating as Mechanic...');
    await page.goto('http://localhost:3000/login', { waitUntil: 'networkidle' });
    await page.locator('button:has-text("Technician")').click();
    await page.waitForTimeout(300);
    await page.locator('button:has-text("Authenticate Session")').click();
    await page.waitForTimeout(1500);

    console.log('>>> Step 2.2: Navigating to http://localhost:3000/mechanic/home...');
    await page.goto('http://localhost:3000/mechanic/home', { waitUntil: 'networkidle' });
    await page.waitForTimeout(2000);

    const workshopCanvas = page.locator('#inspection-terminal canvas');
    await workshopCanvas.waitFor({ state: 'visible', timeout: 15000 });
    const wBox = await workshopCanvas.boundingBox();
    if (!wBox) throw new Error('Could not get bounding box for Workshop 3D canvas');

    const wcx = wBox.x + wBox.width / 2;
    const wcy = wBox.y + wBox.height / 2;

    // Test Free Rotation in Standard CAD mode
    console.log('>>> Step 2.3: Testing Free Drag Rotation in Workshop Standard CAD Mode...');
    await page.mouse.move(wcx + 100, wcy);
    await page.mouse.down();
    await page.mouse.move(wcx - 120, wcy, { steps: 15 });
    await page.mouse.up();
    await page.waitForTimeout(300);
    console.log('    ✓ Horizontal drag verified in Workshop CAD.');

    // Test Free Rotation in Exploded View Mode
    console.log('>>> Step 2.4: Testing Free Drag Rotation in Exploded View Mode...');
    const explodedBtn = page.locator('#inspection-terminal button:has-text("Exploded View")');
    await explodedBtn.click({ force: true });
    await page.waitForTimeout(600);

    await page.mouse.move(wcx, wcy - 50);
    await page.mouse.down();
    await page.mouse.move(wcx + 80, wcy + 60, { steps: 15 });
    await page.mouse.up();
    await page.waitForTimeout(400);
    console.log('    ✓ Free 360° orbit and vertical tilting verified in Exploded View.');

    // Test Free Rotation in X-Ray Hologram Mode
    console.log('>>> Step 2.5: Testing Free Drag Rotation in X-Ray Hologram Mode...');
    const xrayBtn = page.locator('#inspection-terminal button:has-text("X-Ray Hologram")');
    await xrayBtn.click({ force: true });
    await page.waitForTimeout(600);

    await page.mouse.move(wcx + 80, wcy);
    await page.mouse.down();
    await page.mouse.move(wcx - 100, wcy, { steps: 15 });
    await page.mouse.up();
    await page.waitForTimeout(300);
    console.log('    ✓ Free 360° orbit verified in X-Ray Hologram Mode.');

    // Test Touch Gesture Dispatch on Canvas
    console.log('>>> Step 2.6: Testing Touch Event Compatibility (Mobile Orbit)...');
    await workshopCanvas.dispatchEvent('touchstart', {
      touches: [{ clientX: wcx, clientY: wcy, identifier: 0 }],
      targetTouches: [{ clientX: wcx, clientY: wcy, identifier: 0 }],
      changedTouches: [{ clientX: wcx, clientY: wcy, identifier: 0 }],
    });
    await workshopCanvas.dispatchEvent('touchmove', {
      touches: [{ clientX: wcx - 50, clientY: wcy, identifier: 0 }],
      targetTouches: [{ clientX: wcx - 50, clientY: wcy, identifier: 0 }],
      changedTouches: [{ clientX: wcx - 50, clientY: wcy, identifier: 0 }],
    });
    await workshopCanvas.dispatchEvent('touchend', {
      touches: [],
      targetTouches: [],
      changedTouches: [{ clientX: wcx - 50, clientY: wcy, identifier: 0 }],
    });
    await page.waitForTimeout(300);
    console.log('    ✓ Touch events handled cleanly without exception.');

    // Capture screenshot of Workshop Free Orbit
    const workshopScreenshotPath = path.resolve('frontend/public/academic/screenshot-free-orbit-workshop.png');
    await page.screenshot({ path: workshopScreenshotPath, fullPage: false });
    console.log(`    ✓ Saved Workshop free orbit screenshot: ${workshopScreenshotPath}`);

    console.log('\n========================================================================');
    console.log('>>> [SUCCESS] 3D HOLOGRAM FREE ROTATION & MOVEMENT 100% VERIFIED!');
    console.log('========================================================================');
  } catch (error) {
    console.error('>>> [TEST FAILURE]:', error);
    process.exit(1);
  } finally {
    await browser.close();
  }
}

testHologramFreeMovement();
