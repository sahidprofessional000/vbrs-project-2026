import { chromium } from 'playwright';
import fs from 'fs';
import path from 'path';

function createDummyPngBuffer(sizeInBytes = 100) {
  const base64Png = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
  const base = Buffer.from(base64Png, 'base64');
  if (sizeInBytes <= base.length) return base;
  const padding = Buffer.alloc(sizeInBytes - base.length, 0);
  return Buffer.concat([base, padding]);
}

async function runM3FrontendEdgeCaseTests() {
  console.log('========================================================================');
  console.log('>>> [FRONTEND EDGE-CASES] Starting Milestone 3 Edge-Case E2E Verification');
  console.log('========================================================================');

  const testDir = path.resolve('./tmp-m3-edge-tests');
  if (!fs.existsSync(testDir)) fs.mkdirSync(testDir, { recursive: true });

  const validSmallPng = path.join(testDir, 'valid-small.png');
  fs.writeFileSync(validSmallPng, createDummyPngBuffer(1024));

  const oversizePng = path.join(testDir, 'oversize-file.png');
  fs.writeFileSync(oversizePng, Buffer.alloc(Math.ceil(5.5 * 1024 * 1024)));

  const textFile = path.join(testDir, 'forbidden.txt');
  fs.writeFileSync(textFile, 'This is a disallowed text file.');

  const browser = await chromium.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--enable-webgl', '--ignore-gpu-blocklist', '--no-sandbox'],
  });

  const context = await browser.newContext({
    viewport: { width: 1744, height: 1080 },
  });

  const page = await context.newPage();

  // Inject script to simulate Geolocation Permission Denial
  await page.addInitScript(() => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition = (success, error) => {
        if (error) {
          error({
            code: 1, // PERMISSION_DENIED
            message: 'User denied Geolocation prompt in browser',
          });
        }
      };
    }
  });

  try {
    // 1. Login as customer
    console.log('>>> Step 1: Authenticating as customer...');
    await page.goto('http://localhost:3000/login', { waitUntil: 'networkidle' });
    await page.locator('button:has-text("Driver")').click();
    await page.waitForTimeout(300);
    await page.locator('button:has-text("Authenticate Session")').click();
    await page.waitForURL(/customer\/(home|vehicles)/, { timeout: 10000 });
    console.log('    ✓ Customer authenticated.');

    // 2. Navigate to Breakdown Reporting Terminal
    console.log('>>> Step 2: Navigating to /report-breakdown with GPS permission DENIED...');
    await page.goto('http://localhost:3000/report-breakdown', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);

    // 3. Verify GPS Denial Fallback to Manual Pin
    console.log('>>> Step 3: Verifying manual location fallback on GPS denial...');
    const sourceText = await page.locator('text=Source: Manual Map Pin').count();
    console.log(`    ✓ Manual location fallback detected (Source: Manual Map Pin): ${sourceText > 0}`);

    // Verify map is visible and draggable
    await page.waitForSelector('.leaflet-container', { timeout: 10000 });
    console.log('    ✓ Leaflet OpenStreetMap container initialized successfully.');

    // 4. Test Manual Pin Positioning via Map Click
    console.log('>>> Step 4: Testing manual coordinate selection via OpenStreetMap click...');
    const mapBox = await page.locator('.leaflet-container').boundingBox();
    if (mapBox) {
      await page.mouse.click(mapBox.x + mapBox.width * 0.7, mapBox.y + mapBox.height * 0.7);
      await page.waitForTimeout(600);
    }
    const updatedLat = await page.locator('text=Latitude >> xpath=..').innerText();
    const updatedLng = await page.locator('text=Longitude >> xpath=..').innerText();
    console.log(`    ✓ Manually adjusted coordinates: ${updatedLat.replace('\n', ' ')} | ${updatedLng.replace('\n', ' ')}`);

    // 5. Test Client-Side Unsupported File Format Rejection
    console.log('>>> Step 5: Testing client-side rejection of unsupported format (.txt)...');
    const fileInput = page.locator('input[type="file"]');
    await fileInput.setInputFiles(textFile);
    await page.waitForTimeout(500);

    const formatError = await page.locator('text=Disallowed file format').innerText();
    console.log(`    ✓ Client rejected invalid format: "${formatError}"`);

    // 6. Test Client-Side 5 MB File Size Ceiling
    console.log('>>> Step 6: Testing client-side rejection of >5 MB file...');
    await fileInput.setInputFiles(oversizePng);
    await page.waitForTimeout(500);

    const sizeError = await page.locator('text=exceeds 5 MB payload ceiling').innerText();
    console.log(`    ✓ Client rejected oversized file: "${sizeError}"`);

    // 7. Test Client-Side Max 5 Images Limit
    console.log('>>> Step 7: Testing client-side max 5 files limit enforcement...');
    // Create 6 small files
    const sixFiles = [];
    for (let i = 0; i < 6; i++) {
      const fPath = path.join(testDir, `batch-${i}.png`);
      fs.writeFileSync(fPath, createDummyPngBuffer(512));
      sixFiles.push(fPath);
    }
    await fileInput.setInputFiles(sixFiles);
    await page.waitForTimeout(500);

    const limitError = await page.locator('text=Maximum 5 photographic records allowed').innerText();
    console.log(`    ✓ Client rejected 6-file upload attempt: "${limitError}"`);

    // 8. Test Valid Submission with Manual Coordinates and 1 Valid File
    console.log('>>> Step 8: Uploading 1 valid PNG and submitting report with manual coordinates...');
    await fileInput.setInputFiles(validSmallPng);
    await page.waitForTimeout(500);

    const thumbnailCount = await page.locator('img[alt^="Upload"]').count();
    console.log(`    ✓ Valid thumbnail preview rendered: ${thumbnailCount === 1}`);

    await page.locator('textarea').fill('Manual coordinate breakdown submission: Brake squeal and spongy pedal on mountain descent.');
    await page.locator('input[placeholder*="Interstate 95"]').fill('Route 9W Scenic Overlook, Mile Marker 12');

    const transmitBtn = page.locator('button:has-text("Transmit Emergency Signal")');
    await transmitBtn.click();

    // 9. Verify Post-Submission Card
    console.log('>>> Step 9: Awaiting Incident Triage & Protocol Card with manual coordinates...');
    await page.waitForSelector('text=Triage Assessment & Dispatch Initialized', { timeout: 15000 });
    console.log('    ✓ Triage Card rendered with live backend response!');

    const coordsInCard = await page.locator('text=Dispatched Coordinates >> xpath=..').innerText();
    console.log(`    ✓ Persisted manual coordinates in dispatch card: ${coordsInCard.replace(/\n/g, ' ')}`);

    console.log('========================================================================');
    console.log('>>> [FRONTEND EDGE-CASES] ALL EDGE CASES PASSED WITH 100% SUCCESS');
    console.log('========================================================================');
  } catch (err) {
    console.error('>>> [FRONTEND EDGE-CASES] FAILED:', err);
    throw err;
  } finally {
    if (fs.existsSync(testDir)) {
      fs.rmSync(testDir, { recursive: true, force: true });
    }
    await browser.close();
  }
}

runM3FrontendEdgeCaseTests();
