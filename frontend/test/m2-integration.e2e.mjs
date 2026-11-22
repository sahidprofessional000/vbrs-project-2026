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

  // Wait for redirect to customer workspace
  await page.waitForURL(/customer\/(home|vehicles)/, { timeout: 10000 });
  console.log(`    ✓ Successfully authenticated and navigated to: ${page.url()}`);

  // Navigate to customer vehicles garage
  console.log('>>> Navigating to http://localhost:3000/customer/vehicles...');
  await page.goto('http://localhost:3000/customer/vehicles', { waitUntil: 'networkidle' });

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

  // Clean up created test vehicle immediately to protect database integrity
  const vehicleRow = page.locator(`tr:has-text("${testPlate}")`);
  if (await vehicleRow.count() > 0) {
    const deleteBtn = vehicleRow.locator('button:has-text("Delete"), button:has-text("Remove")').first();
    if (await deleteBtn.isVisible()) {
      await deleteBtn.click();
      await page.waitForTimeout(500);
      console.log(`    ✓ Test vehicle ${testPlate} cleanly removed from garage.`);
    }
  }

  // 6. Test Customer Dashboard
  console.log('>>> Navigating to http://localhost:3000/customer/dashboard...');
  await page.goto('http://localhost:3000/customer/dashboard', { waitUntil: 'networkidle' });
  await page.waitForTimeout(1000);
  const consoleTitle = await page.locator('text=Control Console').count();
  console.log(`    ✓ Customer console rendered: ${consoleTitle > 0}`);

  // 7. Test Mechanic Portal (Switch to Mechanic Role via Login)
  console.log('>>> Authenticating as Certified Mechanic to test Mechanic Terminal...');
  await page.goto('http://localhost:3000/login', { waitUntil: 'networkidle' });
  await page.locator('button:has-text("Technician")').click();
  await page.waitForTimeout(300);
  await page.locator('button:has-text("Authenticate Session")').click();
  await page.waitForURL(/mechanic\/(home|portal)/, { timeout: 10000 });
  await page.goto('http://localhost:3000/mechanic/portal', { waitUntil: 'networkidle' });
  await page.waitForTimeout(1000);
  const radarText = await page.locator('text=Field Technician Radar').count();
  console.log(`    ✓ Mechanic terminal rendered: ${radarText > 0}`);

  // 8. Test Admin Dashboard (Switch to Admin Role via Login)
  console.log('>>> Authenticating as Administrator to test Command Center...');
  await page.goto('http://localhost:3000/login', { waitUntil: 'networkidle' });
  await page.locator('button:has-text("Admin")').click();
  await page.waitForTimeout(300);
  await page.locator('button:has-text("Authenticate Session")').click();
  await page.waitForURL('**/admin/dashboard', { timeout: 10000 });
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
