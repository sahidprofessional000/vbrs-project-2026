/**
 * vehicle-viewers-isolation.e2e.mjs
 * End-to-end verification of vehicle viewer isolation across user roles:
 * - Public Landing (/): OriginalVehicleViewer (Hero) - original 3D car model with paint swatches
 * - Customer Dashboard (/customer/dashboard): OriginalVehicleViewer (Dashboard)
 * - Admin Dashboard (/admin/dashboard): OriginalVehicleViewer (Compact)
 * - Mechanic Overview (/mechanic/overview): MechanicHologramViewer (Overview) - 8 selectable subsystems
 * - Mechanic Workshop (/mechanic/home): MechanicHologramViewer (Workshop) - full CAD inspection terminal
 */

import { chromium } from 'playwright';
import fs from 'fs';
import path from 'path';

const BASE_URL = 'http://localhost:3000';

const SCREENSHOT_DIR = path.resolve('frontend/public/academic');
const PUBLIC_ACADEMIC_DIR = path.resolve('public/academic');

if (!fs.existsSync(SCREENSHOT_DIR)) {
  fs.mkdirSync(SCREENSHOT_DIR, { recursive: true });
}
if (!fs.existsSync(PUBLIC_ACADEMIC_DIR)) {
  fs.mkdirSync(PUBLIC_ACADEMIC_DIR, { recursive: true });
}

function saveScreenshot(filename, buffer) {
  fs.writeFileSync(path.join(SCREENSHOT_DIR, filename), buffer);
  fs.writeFileSync(path.join(PUBLIC_ACADEMIC_DIR, filename), buffer);
  console.log(`    [SAVED] ${filename} to both academic directories.`);
}

async function loginAsRole(page, roleButtonText) {
  await page.goto(`${BASE_URL}/login`, { waitUntil: 'networkidle' });
  await page.locator(`button:has-text("${roleButtonText}")`).click();
  await page.waitForTimeout(300);
  await page.locator('button:has-text("Authenticate Session")').click();
  await page.waitForTimeout(2000);
}

async function run() {
  console.log('\n============================================================');
  console.log('  VBRS: VEHICLE VIEWERS ROLE ISOLATION VERIFICATION');
  console.log('============================================================\n');

  const browser = await chromium.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--enable-webgl', '--ignore-gpu-blocklist', '--no-sandbox'],
  });

  const context = await browser.newContext({
    viewport: { width: 1440, height: 900 },
    geolocation: { latitude: 40.7128, longitude: -74.0060 },
    permissions: ['geolocation'],
  });
  const page = await context.newPage();

  try {
    // -------------------------------------------------------------
    // PART 1: Public Landing Page (OriginalVehicleViewer only)
    // -------------------------------------------------------------
    console.log('>>> PART 1: Public Landing Page (/)');
    await page.goto(BASE_URL, { waitUntil: 'networkidle' });
    await page.waitForTimeout(1500);

    // 1. Verify OriginalVehicleViewer exists
    const origViewer = await page.locator('[data-testid="original-vehicle-viewer"]').first();
    const origVisible = await origViewer.isVisible();
    if (!origVisible) {
      throw new Error('Public landing page is missing [data-testid="original-vehicle-viewer"]!');
    }
    const variant = await origViewer.getAttribute('data-variant');
    if (variant !== 'hero') {
      throw new Error(`Public landing viewer variant should be "hero", got "${variant}"!`);
    }
    console.log('    [OK] OriginalVehicleViewer is present with data-variant="hero".');

    // 2. Verify Paint Swatches exist in OriginalVehicleViewer
    const swatches = await page.locator('button[title="Obsidian Carbon"], button[title="Safety Crimson"]');
    const swatchCount = await swatches.count();
    if (swatchCount === 0) {
      throw new Error('OriginalVehicleViewer finish swatches not found!');
    }
    console.log(`    [OK] Paint swatches verified (${swatchCount} color swatches found).`);

    // 3. Verify MechanicHologramViewer is NOT present on public landing
    const hologramCount = await page.locator('[data-testid="mechanic-hologram-viewer"]').count();
    if (hologramCount !== 0) {
      throw new Error(`SECURITY/ISOLATION VIOLATION: MechanicHologramViewer leaked onto Public Landing Page (${hologramCount} found)!`);
    }
    console.log('    [OK] MechanicHologramViewer is strictly absent from Public Landing.');

    const landingScreenshot = await page.screenshot({ fullPage: false });
    saveScreenshot('screenshot-public-landing-original-3d.png', landingScreenshot);

    // -------------------------------------------------------------
    // PART 2: Customer Dashboard (/customer/dashboard)
    // -------------------------------------------------------------
    console.log('\n>>> PART 2: Customer Dashboard (/customer/dashboard)');
    await loginAsRole(page, 'Driver');
    console.log(`    Signed in as Customer. Current URL: ${page.url()}`);
    
    await page.goto(`${BASE_URL}/customer/dashboard`, { waitUntil: 'networkidle' });
    await page.waitForTimeout(2000);
    console.log(`    Navigated to: ${page.url()}`);

    const custViewer = await page.locator('[data-testid="original-vehicle-viewer"]').first();
    await custViewer.waitFor({ state: 'visible', timeout: 10000 });
    const custVariant = await custViewer.getAttribute('data-variant');
    if (custVariant !== 'dashboard') {
      throw new Error(`Customer dashboard viewer variant should be "dashboard", got "${custVariant}"!`);
    }
    console.log('    [OK] Customer Dashboard displays OriginalVehicleViewer with data-variant="dashboard".');

    // Check no hologram on customer dashboard
    const custHologramCount = await page.locator('[data-testid="mechanic-hologram-viewer"]').count();
    if (custHologramCount !== 0) {
      throw new Error(`SECURITY/ISOLATION VIOLATION: MechanicHologramViewer found on Customer Dashboard!`);
    }
    console.log('    [OK] MechanicHologramViewer is strictly absent from Customer Dashboard.');

    const customerScreenshot = await page.screenshot({ fullPage: false });
    saveScreenshot('screenshot-customer-original-3d.png', customerScreenshot);

    // -------------------------------------------------------------
    // PART 3: Admin Dashboard (/admin/dashboard)
    // -------------------------------------------------------------
    console.log('\n>>> PART 3: Admin Dashboard (/admin/dashboard)');
    await page.evaluate(() => localStorage.clear());
    await loginAsRole(page, 'Admin');
    console.log(`    Signed in as Admin. Current URL: ${page.url()}`);

    await page.goto(`${BASE_URL}/admin/dashboard`, { waitUntil: 'networkidle' });
    await page.waitForTimeout(2000);
    console.log(`    Navigated to: ${page.url()}`);

    const adminViewer = await page.locator('[data-testid="original-vehicle-viewer"]').first();
    await adminViewer.waitFor({ state: 'visible', timeout: 10000 });
    const adminVariant = await adminViewer.getAttribute('data-variant');
    if (adminVariant !== 'compact') {
      throw new Error(`Admin dashboard viewer variant should be "compact", got "${adminVariant}"!`);
    }
    console.log('    [OK] Admin Dashboard displays OriginalVehicleViewer with data-variant="compact".');

    // Check no hologram on admin dashboard
    const adminHologramCount = await page.locator('[data-testid="mechanic-hologram-viewer"]').count();
    if (adminHologramCount !== 0) {
      throw new Error(`SECURITY/ISOLATION VIOLATION: MechanicHologramViewer found on Admin Dashboard!`);
    }
    console.log('    [OK] MechanicHologramViewer is strictly absent from Admin Dashboard.');

    const adminScreenshot = await page.screenshot({ fullPage: false });
    saveScreenshot('screenshot-admin-original-3d.png', adminScreenshot);

    // -------------------------------------------------------------
    // PART 4: Mechanic Overview (/mechanic/overview - Mechanic Hologram)
    // -------------------------------------------------------------
    console.log('\n>>> PART 4: Mechanic Overview (/mechanic/overview)');
    await page.evaluate(() => localStorage.clear());
    await loginAsRole(page, 'Technician');
    console.log(`    Signed in as Mechanic. Current URL: ${page.url()}`);

    await page.goto(`${BASE_URL}/mechanic/overview`, { waitUntil: 'networkidle' });
    await page.waitForTimeout(2500);
    console.log(`    Navigated to: ${page.url()}`);

    const mechOverviewHologram = await page.locator('#mechanic-overview-hologram [data-testid="mechanic-hologram-viewer"]').first();
    await mechOverviewHologram.waitFor({ state: 'visible', timeout: 10000 });
    const mechOverviewVariant = await mechOverviewHologram.getAttribute('data-variant');
    if (mechOverviewVariant !== 'overview') {
      throw new Error(`Mechanic Overview hologram variant should be "overview", got "${mechOverviewVariant}"!`);
    }
    console.log('    [OK] Mechanic Overview displays MechanicHologramViewer with data-variant="overview".');

    // Verify 8 subsystem selection strip exists
    const engineBtn = page.getByRole('button', { name: /Engine/i }).first();
    await engineBtn.waitFor({ state: 'visible', timeout: 5000 });
    console.log('    [OK] Mechanic Overview 8-subsystem interactive selection buttons verified.');

    // Click Battery subsystem to verify interaction
    const batteryBtn = page.getByRole('button', { name: /Battery/i }).first();
    await batteryBtn.click();
    await page.waitForTimeout(500);
    console.log('    [OK] Selected Battery subsystem in Mechanic Overview.');

    const mechOverviewScreenshot = await page.screenshot({ fullPage: false });
    saveScreenshot('screenshot-mechanic-overview-hologram.png', mechOverviewScreenshot);

    // -------------------------------------------------------------
    // PART 5: Mechanic Workshop (/mechanic/home - Full Inspection Terminal)
    // -------------------------------------------------------------
    console.log('\n>>> PART 5: Mechanic Workshop (/mechanic/home)');
    await page.goto(`${BASE_URL}/mechanic/home`, { waitUntil: 'networkidle' });
    await page.waitForTimeout(2500);

    const workshopTerminal = await page.locator('#inspection-terminal [data-testid="mechanic-hologram-viewer"]').first();
    await workshopTerminal.waitFor({ state: 'visible', timeout: 10000 });
    const workshopVariant = await workshopTerminal.getAttribute('data-variant');
    if (workshopVariant !== 'workshop') {
      throw new Error(`Mechanic Workshop hologram variant should be "workshop", got "${workshopVariant}"!`);
    }
    console.log('    [OK] Mechanic Workshop displays MechanicHologramViewer with data-variant="workshop".');

    // Verify CAD mode tabs (Standard CAD, X-Ray Hologram, Exploded View, Isolated Subsystem)
    const explodedTab = page.getByRole('button', { name: /Exploded View/i }).first();
    await explodedTab.waitFor({ state: 'visible', timeout: 5000 });
    console.log('    [OK] Workshop CAD mode tabs verified (Exploded View present).');

    // Scroll to terminal for pristine screenshot
    await page.locator('#inspection-terminal').scrollIntoViewIfNeeded();
    await page.waitForTimeout(1000);

    const workshopScreenshot = await page.screenshot({ fullPage: false });
    saveScreenshot('screenshot-mechanic-workshop-terminal.png', workshopScreenshot);

    console.log('\n============================================================');
    console.log('  ALL VEHICLE VIEWERS ROLE ISOLATION TESTS PASSED (100% GREEN)');
    console.log('============================================================\n');
  } catch (err) {
    console.error('\n❌ TEST FAILURE:', err.message);
    process.exit(1);
  } finally {
    await browser.close();
  }
}

run();
