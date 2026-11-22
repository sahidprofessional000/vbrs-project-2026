import { chromium } from 'playwright';
import fs from 'fs';
import path from 'path';

async function runTest() {
  console.log('>>> Launching Chrome via Playwright with WebGL enabled...');
  
  const browser = await chromium.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: [
      '--enable-webgl',
      '--ignore-gpu-blocklist',
      '--use-gl=angle',
      '--use-angle=default',
      '--no-sandbox',
    ],
  });

  const context = await browser.newContext({
    viewport: { width: 1744, height: 1080 },
  });

  const page = await context.newPage();

  const consoleMessages = [];
  page.on('console', (msg) => {
    consoleMessages.push(`[${msg.type()}] ${msg.text()}`);
  });

  const pageErrors = [];
  page.on('pageerror', (err) => {
    pageErrors.push(err.message);
  });

  console.log('>>> Navigating to http://localhost:3000...');
  await page.goto('http://localhost:3000', { waitUntil: 'networkidle' });

  // Wait for 3D canvas or fallback
  await page.waitForTimeout(3000);

  // Check for canvas
  const canvasCount = await page.locator('canvas').count();
  console.log(`>>> Detected <canvas> count on page: ${canvasCount}`);

  // Check controls
  const finishButtons = await page.locator('button[aria-label]').all();
  console.log(`>>> Detected paint finish buttons: ${finishButtons.length}`);
  for (let i = 0; i < finishButtons.length; i++) {
    const label = await finishButtons[i].getAttribute('aria-label');
    console.log(`    - Finish [${i}]: ${label}`);
  }

  // Click second finish: Safety Crimson
  if (finishButtons.length >= 2) {
    console.log('>>> Clicking "Safety Crimson" paint finish...');
    await finishButtons[1].click();
    await page.waitForTimeout(500);
  }

  // Check ORBIT button
  const orbitBtn = page.locator('button:has-text("ORBIT")');
  const orbitExists = await orbitBtn.count();
  console.log(`>>> ORBIT toggle button present: ${orbitExists > 0}`);
  if (orbitExists > 0) {
    console.log('>>> Toggling ORBIT button...');
    await orbitBtn.click();
    await page.waitForTimeout(300);
    await orbitBtn.click(); // turn back on
  }

  // Check RESET button
  const resetBtn = page.locator('button:has-text("RESET")');
  const resetExists = await resetBtn.count();
  console.log(`>>> RESET button present: ${resetExists > 0}`);
  if (resetExists > 0) {
    console.log('>>> Clicking RESET camera button...');
    await resetBtn.click();
  }

  // Test mouse drag on 3D canvas to verify orbit controls
  if (canvasCount > 0) {
    console.log('>>> Interacting with 3D canvas via mouse drag (orbit test)...');
    const canvas = page.locator('canvas').first();
    const box = await canvas.boundingBox();
    if (box) {
      const centerX = box.x + box.width / 2;
      const centerY = box.y + box.height / 2;
      await page.mouse.move(centerX, centerY);
      await page.mouse.down();
      await page.mouse.move(centerX + 80, centerY - 20, { steps: 5 });
      await page.mouse.up();
      console.log('    ✓ Orbit drag interaction completed successfully.');
    }
  }

  // Verify telemetry labels
  const pbrBadge = await page.locator('text=3D PBR REALTIME STUDIO').count();
  console.log(`>>> Telemetry badge "3D PBR REALTIME STUDIO" found: ${pbrBadge > 0}`);

  // Take screenshot
  const screenshotPath = path.resolve('public/3d-hero-render.png');
  await page.screenshot({ path: screenshotPath, fullPage: false });
  console.log(`>>> Screenshot captured at: ${screenshotPath}`);

  // Report console logs / errors
  console.log('>>> Console messages captured during test:', consoleMessages.length);
  if (pageErrors.length > 0) {
    console.error('>>> Page Errors:', pageErrors);
  } else {
    console.log('    ✓ 0 uncaught page errors detected.');
  }

  await browser.close();
  console.log('>>> Test suite execution finished.');
}

runTest().catch((err) => {
  console.error('Test execution failed:', err);
  process.exit(1);
});
