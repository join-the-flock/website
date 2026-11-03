(() => {
  const hero = document.querySelector('.nest-hero');
  const canvas = hero.querySelector('.nest-atmosphere');
  const context = canvas.getContext('2d');
  if (!context) { return; }
  const artwork = hero.querySelector('.nest-centerpiece');
  const reduced = matchMedia('(prefers-reduced-motion: reduce)');
  const palette = ['#22d0f2', '#b12cd0', '#f8217e', '#ffb342'];
  const glyphs = ['0', '1', '{', '}', '<', '>', '/', '+'];
  let width = 0, height = 0, origin = 0, artWidth = 0;
  let frame, previous, lastDraw = 0, elapsed = 0;
  let nearby = hero.getBoundingClientRect().top <= innerHeight + 200;

  function curve(side, lane, progress) {
    const spread = Math.min(width * .48, 620);
    const startX = width / 2 + side * artWidth * (.16 + lane * .018);
    const controlX = width / 2 + side * spread * (.3 + lane * .1);
    const endX = width / 2 + side * spread * (1.12 + lane * .04);
    const endY = height * (.14 + lane * .075);
    const inverse = 1 - progress;
    return {
      x: inverse * inverse * startX + 2 * inverse * progress * controlX + progress * progress * endX,
      y: inverse * inverse * origin + 2 * inverse * progress * (height * (-.28 + lane * .06)) + progress * progress * endY,
    };
  }

  function draw() {
    context.clearRect(0, 0, width, height);
    context.font = '11px monospace';
    context.textAlign = 'center';
    context.textBaseline = 'middle';
    // Curving streams fan out from the nest, with code flowing along their paths.
    for (const side of [-1, 1]) {
      for (let lane = 0; lane < 7; lane++) {
        const color = palette[(lane + (side > 0 ? 1 : 0)) % palette.length];
        const start = curve(side, lane, 0);
        const end = curve(side, lane, 1);
        const trail = context.createLinearGradient(start.x, start.y, end.x, end.y);
        trail.addColorStop(0, color + '00');
        trail.addColorStop(.35, color + '36');
        trail.addColorStop(.75, color + '22');
        trail.addColorStop(1, color + '00');
        context.globalAlpha = 1;
        context.strokeStyle = trail;
        context.lineWidth = .7;
        context.beginPath();
        for (let step = 0; step <= 40; step++) {
          const point = curve(side, lane, step / 40);
          if (step === 0) { context.moveTo(point.x, point.y); }
          else { context.lineTo(point.x, point.y); }
        }
        context.stroke();
        for (let bit = 0; bit < 6; bit++) {
          const progress = (bit / 6 + lane * .137 + elapsed * (.035 + lane * .003)) % 1;
          const point = curve(side, lane, progress);
          context.globalAlpha = Math.sin(progress * Math.PI) * .5;
          context.fillStyle = color;
          context.fillText(glyphs[(lane * 3 + bit) % glyphs.length], point.x, point.y);
        }
      }
    }
    // A few embers rise above the eggs, without a rectangular particle field.
    for (let index = 0; index < 50; index++) {
      const progress = (index * .137 + elapsed * (.04 + index % 4 * .009)) % 1;
      const side = index % 2 ? 1 : -1;
      const drift = Math.sin(index * 2.3 + elapsed * .3) * 12;
      const x = width / 2 + side * (artWidth * .1 + progress * Math.min(width * .42, 460)) + drift;
      const y = origin - progress * height * (.65 + index % 3 * .13);
      context.globalAlpha = Math.sin(progress * Math.PI) * (.3 + index % 3 * .09);
      context.fillStyle = palette[index % palette.length];
      context.beginPath();
      context.arc(x, y, index % 7 === 0 ? 1.8 : .9, 0, Math.PI * 2);
      context.fill();
    }
    context.globalAlpha = 1;
  }

  function resize() {
    const bounds = hero.getBoundingClientRect();
    const image = artwork.getBoundingClientRect();
    width = bounds.width;
    height = bounds.height;
    origin = image.bottom - bounds.top - image.height * .1;
    artWidth = image.width;
    const scale = Math.min(devicePixelRatio || 1, 1.5);
    canvas.width = Math.round(width * scale);
    canvas.height = Math.round(height * scale);
    context.setTransform(scale, 0, 0, scale, 0, 0);
    draw();
  }

  function tick(now) {
    if (previous !== undefined) { elapsed += Math.min((now - previous) / 1000, .05); }
    previous = now;
    if (now - lastDraw >= 33) { draw(); lastDraw = now; }
    frame = requestAnimationFrame(tick);
  }

  function sync() {
    cancelAnimationFrame(frame);
    previous = undefined;
    if (nearby && !document.hidden) {
      if (reduced.matches) { draw(); }
      else { frame = requestAnimationFrame(tick); }
    }
  }

  new IntersectionObserver(([entry]) => {
    nearby = entry.isIntersecting;
    sync();
  }, {rootMargin: '200px'}).observe(hero);
  new ResizeObserver(resize).observe(hero);
  artwork.addEventListener('load', resize);
  reduced.addEventListener('change', sync);
  document.addEventListener('visibilitychange', sync);
  resize();
  sync();
})();
