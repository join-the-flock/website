(() => {
  const hero = document.querySelector('.hero');
  const bounds = hero.getBoundingClientRect();
  let nearViewport = bounds.bottom >= -200 && bounds.top <= innerHeight + 200;
  let visible = nearViewport && !document.hidden;

  window.FlockHero.isAnimationVisible = () => visible;

  function sync() {
    const next = nearViewport && !document.hidden;
    if (next !== visible) {
      visible = next;
      hero.dispatchEvent(new Event('hero-visibility'));
    }
  }

  // Start just before the hero enters view and pause once it is 200px away.
  new IntersectionObserver(([entry]) => {
    nearViewport = entry.isIntersecting;
    sync();
  }, {rootMargin: '200px', threshold: 0}).observe(hero);
  document.addEventListener('visibilitychange', sync);
})();
