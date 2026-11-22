import { chromium } from 'playwright';
import path from 'path';

async function verifyImages() {
  console.log('>>> Launching Chrome to verify all images on VBRS platform...');

  const browser = await chromium.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--enable-webgl', '--ignore-gpu-blocklist', '--no-sandbox'],
  });

  const page = await browser.newPage({
    viewport: { width: 1744, height: 1080 },
  });

  const failedRequests = [];
  page.on('requestfailed', (req) => {
    failedRequests.push(`${req.method()} ${req.url()} - ${req.failure()?.errorText}`);
  });

  console.log('>>> Loading http://localhost:3000...');
  await page.goto('http://localhost:3000', { waitUntil: 'networkidle' });
  await page.waitForTimeout(2000);

  // Check every <img> element on the rendered page
  const imagesStatus = await page.evaluate(() => {
    const imgs = Array.from(document.querySelectorAll('img'));
    return imgs.map((img) => ({
      src: img.src,
      alt: img.alt,
      complete: img.complete,
      naturalWidth: img.naturalWidth,
      naturalHeight: img.naturalHeight,
      isBroken: img.naturalWidth === 0 || img.naturalHeight === 0 || !img.complete,
    }));
  });

  console.log(`>>> Found ${imagesStatus.length} rendered <img> element(s) on the page:`);
  let hasAnyBroken = false;
  for (const img of imagesStatus) {
    const status = img.isBroken ? 'FAIL (BROKEN)' : 'PASS (OK)';
    console.log(`    - [${status}] alt="${img.alt}" | naturalSize=${img.naturalWidth}x${img.naturalHeight} | src=${img.src}`);
    if (img.isBroken) hasAnyBroken = true;
  }

  // Scroll down to the "Engineered for Automotive Integrity" section
  const sectionHeader = page.locator('text=Engineered for Automotive Integrity');
  const sectionCount = await sectionHeader.count();
  console.log(`>>> Section "Engineered for Automotive Integrity" located: ${sectionCount > 0}`);

  if (sectionCount > 0) {
    await sectionHeader.scrollIntoViewIfNeeded();
    await page.waitForTimeout(1000);

    const screenshotPath = path.resolve('public/section-integrity-render.png');
    // Capture the section screenshot
    const sectionElement = page.locator('section:has-text("Engineered for Automotive Integrity")');
    if (await sectionElement.count() > 0) {
      await sectionElement.screenshot({ path: screenshotPath });
      console.log(`>>> Captured section screenshot at: ${screenshotPath}`);
    }
  }

  if (failedRequests.length > 0) {
    console.warn('>>> Warning: Failed network requests:', failedRequests);
  } else {
    console.log('    ✓ 0 network request failures.');
  }

  await browser.close();

  if (hasAnyBroken) {
    console.error('>>> Error: At least one image is broken on the page!');
    process.exit(1);
  } else {
    console.log('>>> All images passed verification with 100% success!');
  }
}

verifyImages().catch((err) => {
  console.error('Image verification failed:', err);
  process.exit(1);
});
