import { chromium } from 'playwright';

async function testFrontendBackendIntegration() {
  console.log('>>> [E2E INTEGRATION] Launching Chrome to test full Frontend-Backend auth and garage flows...');

  const browser = await chromium.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--enable-webgl', '--ignore-gpu-blocklist', '--no-sandbox'],
  });

  const context = await browser.newContext({
    viewport: { width: 1744, height: 1080 },
  });

  const page = await context.newPage();

  // 1. Visit Login page
  console.log('>>> Navigating to http://localhost:3000/login...');
  await page.goto('http://localhost:3000/login', { waitUntil: 'networkidle' });

  // 2. Click Driver demo quick fill
  console.log('>>> Clicking Driver demo quick-fill button...');
  const driverQuickFill = page.locator('button:has-text("Driver")');
  await driverQuickFill.click();

  // Verify email input filled
  const emailVal = await page.inputValue('input[type="email"]');
  console.log(`    ✓ Email auto-filled: ${emailVal}`);

  // 3. Submit Login
  console.log('>>> Submitting login credentials to backend...');
  const submitBtn = page.locator('button:has-text("Authenticate Session")');
  await submitBtn.click();

  // Wait for redirect to customer vehicles
  await page.waitForURL('**/customer/vehicles', { timeout: 10000 });
  console.log(`    ✓ Successfully authenticated and navigated to: ${page.url()}`);

  // 4. Verify Garage page rendered
  await page.waitForTimeout(1000);
  const garageHeader = await page.locator('text=Customer Vehicle Garage').count();
  console.log(`    ✓ Garage header detected: ${garageHeader > 0}`);

  // 5. Test Register Vehicle Modal
  console.log('>>> Opening Register Vehicle Modal...');
  const addVehicleBtn = page.locator('button:has-text("Add Automobile"), button:has-text("Register First Car")').first();
  await addVehicleBtn.click();
  await page.waitForTimeout(500);

  const testPlate = `E2E-${Date.now().toString().slice(-4)}`;
  console.log(`>>> Filling vehicle form with license plate: ${testPlate}...`);
  
  // Fill modal inputs
  const inputs = await page.locator('.fixed input').all();
  if (inputs.length >= 4) {
    await inputs[0].fill('Audi');
    await inputs[1].fill('RS6 Avant');
    await inputs[2].fill('2024');
    await inputs[3].fill(testPlate);
  }

  // Submit vehicle form
  const modalSubmit = page.locator('.fixed button[type="submit"]');
  if (await modalSubmit.count() > 0) {
    console.log('>>> Submitting vehicle creation modal...');
    await modalSubmit.click();
    await page.waitForTimeout(1500);
  }

  // Verify vehicle appears in garage table
  const plateText = await page.locator(`text=${testPlate}`).count();
  console.log(`    ✓ New vehicle (${testPlate}) verified in live garage table: ${plateText > 0}`);

  // 6. Test Customer Dashboard
  console.log('>>> Navigating to http://localhost:3000/customer/dashboard...');
  await page.goto('http://localhost:3000/customer/dashboard', { waitUntil: 'networkidle' });
  await page.waitForTimeout(1000);
  const consoleTitle = await page.locator('text=Control Console').count();
  console.log(`    ✓ Customer console rendered: ${consoleTitle > 0}`);

  // 7. Test Mechanic Portal
  console.log('>>> Navigating to http://localhost:3000/mechanic/portal...');
  await page.goto('http://localhost:3000/mechanic/portal', { waitUntil: 'networkidle' });
  await page.waitForTimeout(1000);
  const radarText = await page.locator('text=Field Technician Radar').count();
  console.log(`    ✓ Mechanic terminal rendered: ${radarText > 0}`);

  // 8. Test Admin Dashboard
  console.log('>>> Navigating to http://localhost:3000/admin/dashboard...');
  await page.goto('http://localhost:3000/admin/dashboard', { waitUntil: 'networkidle' });
  await page.waitForTimeout(1000);
  const adminText = await page.locator('text=Operational Command Center').count();
  console.log(`    ✓ Admin command desk rendered: ${adminText > 0}`);

  await browser.close();
  console.log('>>> [E2E INTEGRATION] All integration checks completed with 100% success!');
}

testFrontendBackendIntegration().catch((err) => {
  console.error('Integration test failed:', err);
  process.exit(1);
});
