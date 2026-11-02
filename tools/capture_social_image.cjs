// Run after building the site. Requires Playwright and Chromium (or FLOCK_CHROME_PATH).
const { chromium } = require('playwright');
const assert = require('node:assert/strict');
const fs = require('node:fs/promises');
const path = require('node:path');

const root = path.resolve(__dirname, '..');
const build = path.join(root, 'build');
const output = path.join(root, 'source/images/flock-social-hero.png');
const origin = 'http://flock-capture.local';

async function main() {
  const browser = await chromium.launch({
    headless: true,
    ...(process.env.FLOCK_CHROME_PATH ? { executablePath: process.env.FLOCK_CHROME_PATH } : {}),
  });
  try {
    const page = await browser.newPage({
      viewport: { width: 1200, height: 630 },
      deviceScaleFactor: 1,
      reducedMotion: 'reduce',
    });
    const errors = [];
    page.on('pageerror', error => errors.push(error.message));
    // Capture the local build without needing a server or fetching commit avatars.
    await page.route('**/*', async route => {
      const url = new URL(route.request().url());
      if (url.origin !== origin) {
        return route.abort();
      }
      let file = path.resolve(build, `.${decodeURIComponent(url.pathname)}`);
      if (file !== build && !file.startsWith(build + path.sep)) {
        return route.fulfill({ status: 404, body: '' });
      }
      if (!path.extname(file)) {
        file = path.join(file, 'index.html');
      }
      const types = {
        '.html': 'text/html', '.css': 'text/css', '.js': 'application/javascript',
        '.png': 'image/png', '.jpg': 'image/jpeg', '.webp': 'image/webp', '.svg': 'image/svg+xml',
      };
      try {
        return route.fulfill({ body: await fs.readFile(file), contentType: types[path.extname(file)] || 'application/octet-stream' });
      } catch {
        return route.fulfill({ status: 404, body: '' });
      }
    });
    await page.goto(origin + '/');
    await page.locator('.fleek').evaluate(image => image.decode());
    await page.evaluate(() => document.fonts.ready);
    await page.waitForFunction(() => document.querySelector('.stack.live') && document.querySelector('.flutter.live'));
    await page.evaluate(() => new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve))));

    const cardSizes = () => page.locator('.hero .commit').evaluateAll(cards => cards.map(card => ({
      width: card.offsetWidth,
      height: card.offsetHeight,
    })));
    const before = await cardSizes();
    // Visibility hides paint, while keeping text wrapping, padding, and card sizing.
    // These overrides exist only in this capture's browser, never on the live site.
    await page.addStyleTag({ content: `
      .hero > .site-header { visibility: hidden !important; }
      .hero .commit > * { visibility: hidden !important; }
      .hero .scene {
        top: 20px;
        bottom: auto;
        transform: translateX(-50%) scale(.82);
        transform-origin: center top;
      }
    ` });
    await page.evaluate(() => new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve))));
    // Transforms do not trigger ResizeObserver; refresh the glow silhouette explicitly.
    await page.locator('.hero').evaluate(hero => hero.dispatchEvent(new Event('stack-frame')));
    assert.deepEqual(await cardSizes(), before, 'Blank cards must retain their original dimensions');
    assert.deepEqual(errors, [], 'Hero must render without page errors');
    await page.locator('.hero').screenshot({ path: output, type: 'png', scale: 'css' });
    console.log(`Saved 1200×630 hero sharing image: ${output}`);
  } finally {
    await browser.close();
  }
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
