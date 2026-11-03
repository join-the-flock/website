(() => {
  const hero = document.querySelector('.flock-hero');
  if (!hero) return;

  const reduced = matchMedia('(prefers-reduced-motion: reduce)');
  // Fleek distances use the artwork's 1200 × 600 coordinate system, so they
  // shrink with the formation. Dash uses screen pixels and stays more distant.
  const birds = [
    ['.fleek-leader', 18, 2.5],
    ['.fleek-left', 11, 1.8],
    ['.fleek-right', 7, 1.3],
    ['.flight-dash', 1.1, 1],
  ].map(([selector, radius, bank]) => ({
    element: hero.querySelector(selector),
    radius,
    bank,
    phase: Array.from({length: 4}, () => Math.random() * Math.PI * 2),
    speed: .22 + Math.random() * .12,
  }));

  const bounds = hero.getBoundingClientRect();
  let nearby = bounds.bottom >= -200 && bounds.top <= innerHeight + 200;
  let frame, previous, elapsed = 0;

  function tick(now) {
    if (previous !== undefined) elapsed += Math.min((now - previous) / 1000, .05);
    previous = now;
    const entrance = Math.min(elapsed / 5, 1);
    const envelope = entrance * entrance * entrance * (entrance * (6 * entrance - 15) + 10);
    const envelopeRate = 6 * entrance * entrance * (1 - entrance) * (1 - entrance);
    for (const {element, radius, bank, phase, speed} of birds) {
      const time = elapsed * speed;
      // Weighted waves have different periods and random phases. Their sum is
      // always within [-1, 1], preventing a random walk away from the origin.
      const x = .65 * Math.sin(time + phase[0]) + .35 * Math.sin(time * 1.73 + phase[1]);
      const y = .65 * Math.sin(time * .83 + phase[2]) + .35 * Math.sin(time * 1.41 + phase[3]);
      // Bank with actual horizontal velocity, including the entrance easing.
      // Its continuous derivative eases through neutral at every reversal.
      const velocity = speed * (.65 * Math.cos(time + phase[0]) + .35 * 1.73 * Math.cos(time * 1.73 + phase[1])) * envelope + x * envelopeRate;
      const rotation = bank * Math.tanh(velocity / (speed * (.65 + .35 * 1.73)));
      element.style.setProperty('--drift-x', `${(x * radius * envelope).toFixed(3)}px`);
      element.style.setProperty('--drift-y', `${(y * radius * .65 * envelope).toFixed(3)}px`);
      element.style.setProperty('--drift-rotation', `${rotation.toFixed(4)}deg`);
    }
    frame = requestAnimationFrame(tick);
  }

  function sync() {
    cancelAnimationFrame(frame);
    previous = undefined;
    if (reduced.matches) {
      for (const {element} of birds) {
        element.style.removeProperty('--drift-x');
        element.style.removeProperty('--drift-y');
        element.style.removeProperty('--drift-rotation');
      }
      elapsed = 0;
    } else if (nearby && !document.hidden) {
      frame = requestAnimationFrame(tick);
    }
  }

  new IntersectionObserver(([entry]) => {
    nearby = entry.isIntersecting;
    sync();
  }, {rootMargin: '200px', threshold: 0}).observe(hero);
  document.addEventListener('visibilitychange', sync);
  reduced.addEventListener('change', sync);
  sync();
})();
