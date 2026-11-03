(() => {
  const hero = document.querySelector('.flock-hero');
  if (!hero) return;
  const storm = hero.querySelector('.flock-storm');
  const clouds = storm.querySelector('.storm-clouds');
  const canvas = storm.querySelector('canvas');
  const context = canvas.getContext('2d');
  if (!context) return;
  const reduced = matchMedia('(prefers-reduced-motion: reduce)');
  const random = (min, max) => min + Math.random() * (max - min);
  const winds = Array.from({length: 22}, () => ({
    phase: Math.random(), y: Math.random(), length: random(.06, .18), speed: random(.07, .14),
  }));
  let width = 0, height = 0, frame, previous, lastDraw = 0, elapsed = 0;
  let bolt, nextStrike = 1.8;
  const bounds = hero.getBoundingClientRect();
  let nearby = bounds.bottom >= -200 && bounds.top <= innerHeight + 200;

  function strike() {
    const start = {x: width * random(.25, .75), y: height * random(.04, .2)};
    const end = {x: start.x + width * random(-.16, .16), y: height * random(.65, .9)};
    const points = [start];
    for (let i = 1; i <= 12; i++) {
      const t = i / 12;
      points.push({x: start.x + (end.x - start.x) * t + random(-1, 1) * Math.min(width * .025, 24), y: start.y + (end.y - start.y) * t});
    }
    const branches = [4, 7, 9].map(index => {
      const origin = points[index];
      const side = Math.random() < .5 ? -1 : 1;
      return Array.from({length: 5}, (_, i) => ({
        x: origin.x + side * i * Math.min(width * .013, 14) + (i ? random(-5, 5) : 0),
        y: origin.y + i * height * .035,
      }));
    });
    bolt = {born: elapsed, points, branches};
    nextStrike = elapsed + random(4.5, 8);
  }

  function path(points) {
    context.beginPath();
    points.forEach(({x, y}, i) => i ? context.lineTo(x, y) : context.moveTo(x, y));
    context.stroke();
  }

  function draw() {
    context.clearRect(0, 0, width, height);
    if (reduced.matches) return;
    clouds.style.setProperty('--storm-x', `${Math.sin(elapsed * .12) * 7}px`);
    clouds.style.setProperty('--storm-y', `${Math.sin(elapsed * .09) * 3}px`);
    // Sparse, curved streaks suggest distant wind rather than foreground rain.
    context.lineWidth = .7;
    for (const wind of winds) {
      const progress = (wind.phase + elapsed * wind.speed) % 1;
      const x = (progress * 1.5 - .25) * width;
      const y = wind.y * height + Math.sin(elapsed * .4 + wind.phase * 20) * 5;
      const length = wind.length * width;
      const gradient = context.createLinearGradient(x, y, x + length, y - 12);
      gradient.addColorStop(0, '#f8217e00');
      gradient.addColorStop(.5, '#d96aff24');
      gradient.addColorStop(1, '#b12cd000');
      context.strokeStyle = gradient;
      context.beginPath();
      context.moveTo(x, y);
      context.quadraticCurveTo(x + length * .5, y - 15, x + length, y - 12);
      context.stroke();
    }
    if (elapsed >= nextStrike) strike();
    if (!bolt) return;
    const age = elapsed - bolt.born;
    if (age > 1.1) { bolt = undefined; return; }
    // One local pulse per strike, with a soft decay rather than strobing.
    const intensity = Math.min(age / .07, 1) * Math.exp(-age * 5);
    context.save();
    const origin = bolt.points[5];
    const glow = context.createRadialGradient(origin.x, origin.y, 0, origin.x, origin.y, Math.min(width * .22, 220));
    glow.addColorStop(0, `rgba(18, 167, 255, ${intensity * .22})`);
    glow.addColorStop(1, 'rgba(18, 167, 255, 0)');
    context.fillStyle = glow;
    context.fillRect(0, 0, width, height);
    context.globalAlpha = intensity;
    context.lineJoin = 'round';
    context.strokeStyle = '#16cfff';
    context.shadowColor = '#00baff';
    context.shadowBlur = 16;
    context.lineWidth = 2.2;
    path(bolt.points);
    context.lineWidth = 1;
    bolt.branches.forEach(path);
    context.shadowBlur = 4;
    context.strokeStyle = '#d2fbff';
    context.lineWidth = .8;
    path(bolt.points);
    context.restore();
  }

  function tick(now) {
    if (previous !== undefined) elapsed += Math.min((now - previous) / 1000, .05);
    previous = now;
    if (now - lastDraw >= 1000 / 30) { draw(); lastDraw = now; }
    frame = requestAnimationFrame(tick);
  }

  function resize() {
    const bounds = storm.getBoundingClientRect();
    width = bounds.width;
    height = bounds.height;
    const scale = Math.min(devicePixelRatio || 1, 1.5);
    canvas.width = Math.round(width * scale);
    canvas.height = Math.round(height * scale);
    context.setTransform(scale, 0, 0, scale, 0, 0);
    bolt = undefined;
    draw();
  }

  function sync() {
    cancelAnimationFrame(frame);
    previous = undefined;
    if (reduced.matches) {
      bolt = undefined;
      context.clearRect(0, 0, width, height);
      clouds.style.removeProperty('--storm-x');
      clouds.style.removeProperty('--storm-y');
    } else if (nearby && !document.hidden) {
      frame = requestAnimationFrame(tick);
    }
  }

  new ResizeObserver(resize).observe(storm);
  new IntersectionObserver(([entry]) => {
    nearby = entry.isIntersecting;
    sync();
  }, {rootMargin: '200px', threshold: 0}).observe(hero);
  reduced.addEventListener('change', sync);
  document.addEventListener('visibilitychange', sync);
  resize();
  sync();
})();
