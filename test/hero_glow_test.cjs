const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const { test } = require('node:test');

const source = fs.readFileSync(path.join(__dirname, '../source/scripts/hero/edge-glow.js'), 'utf8');

function loadGlow({ touch, context }) {
  const classes = new Set();
  let canvasCount = 0;
  let overlayCount = 0;
  const hero = { classList: { add: name => classes.add(name) }, append: () => overlayCount++ };
  vm.runInNewContext(source, {
    document: {
      querySelector: selector => selector === '.hero' ? hero : {},
      createElement: () => {
        canvasCount++;
        return { setAttribute() {}, getContext: type => type === 'webgl' ? context : null };
      },
    },
    matchMedia: query => ({ matches: query === '(pointer: coarse)' && touch }),
  });
  return { classes, canvasCount, overlayCount };
}

test('touch devices use native glow without creating a WebGL canvas', () => {
  const result = loadGlow({ touch: true });
  assert(result.classes.has('hero--simple-glow'));
  assert.equal(result.canvasCount, 0);
  assert.equal(result.overlayCount, 0);
});

test('desktop falls back to native glow when WebGL is unavailable', () => {
  const result = loadGlow({ touch: false, context: null });
  assert(result.classes.has('hero--simple-glow'));
  assert.equal(result.overlayCount, 0);
});

test('shader compilation failure falls back without attaching a broken overlay', () => {
  const context = {
    createProgram: () => ({}),
    createShader: () => ({}),
    shaderSource() {},
    compileShader() {},
    getShaderParameter: () => false,
    getShaderInfoLog: () => 'Unsupported shader',
    deleteProgram() {},
  };
  const result = loadGlow({ touch: false, context });
  assert(result.classes.has('hero--simple-glow'));
  assert.equal(result.overlayCount, 0);
});
