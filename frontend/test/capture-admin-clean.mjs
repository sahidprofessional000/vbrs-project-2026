import { chromium } from 'playwright';
import path from 'path';
import fs from 'fs';

async function captureAdminClean() {
  const browser = await chromium.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--enable-webgl', '--ignore-gpu-blocklist', '--no-sandbox'],
  });

  const context = await browser.newContext({
    viewport: { width: 1744, height: 1080 },
  });

  const page = await context.newPage();

  try {
    console.log('Navigating to login...');
    await page.goto('http://localhost:3000/login', { waitUntil: 'networkidle' });
    
    // Quick-fill Admin
    await page.locator('button:has-text("Admin")').click();
    await page.waitForTimeout(300);
    await page.locator('button:has-text("Authenticate Session")').click();
    await page.waitForURL('**/admin/dashboard', { timeout: 10000 });
    console.log('Admin authenticated.');

    await page.waitForSelector('text=Operational Command Center', { timeout: 10000 });
    await page.waitForTimeout(2000);

    const outDir1 = path.resolve('frontend/public/academic');
    const outDir2 = path.resolve('docs/academic');
    fs.mkdirSync(outDir1, { recursive: true });
    fs.mkdirSync(outDir2, { recursive: true });

    // Capture Fleet Analytics Overview
    const file1 = path.join(outDir1, 'screenshot-admin-clean-fleet-metrics.png');
    const file1_docs = path.join(outDir2, 'screenshot-admin-clean-fleet-metrics.png');
    await page.screenshot({ path: file1, fullPage: false });
    fs.copyFileSync(file1, file1_docs);
    console.log(`Saved: ${file1}`);

    // Navigate to Dispute Desk to capture authentic clean empty state
    console.log('Switching to Dispute & Grievance Desk...');
    await page.locator('button:has-text("Dispute & Grievance Desk")').click();
    await page.waitForTimeout(1000);
    
    const file2 = path.join(outDir1, 'screenshot-admin-clean-dispute-empty-state.png');
    const file2_docs = path.join(outDir2, 'screenshot-admin-clean-dispute-empty-state.png');
    await page.screenshot({ path: file2, fullPage: false });
    fs.copyFileSync(file2, file2_docs);
    console.log(`Saved: ${file2}`);

    // Switch to Field Technician Desk
    console.log('Switching to Technician Credential Desk...');
    await page.locator('button:has-text("Technician Credential Desk")').click();
    await page.waitForTimeout(1000);

    const file3 = path.join(outDir1, 'screenshot-admin-clean-technicians.png');
    const file3_docs = path.join(outDir2, 'screenshot-admin-clean-technicians.png');
    await page.screenshot({ path: file3, fullPage: false });
    fs.copyFileSync(file3, file3_docs);
    console.log(`Saved: ${file3}`);

    console.log('All screenshots captured successfully.');
  } finally {
    await browser.close();
  }
}

captureAdminClean().catch(err => {
  console.error(err);
  process.exit(1);
});
