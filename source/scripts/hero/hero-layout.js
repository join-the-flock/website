(() => {
  const hero = document.querySelector('.hero');
  const scene = document.querySelector('.scene');
  const header = document.querySelector('.site-header');
  function fitHeight() {
    const lastHeight = parseFloat(getComputedStyle(hero).getPropertyValue('--last-card-height')) || 0;
    // Width rules stay intact; height is an additional constraint on short screens.
    const available = Math.max(1, hero.clientHeight - header.offsetHeight - 20);
    const visibleHeight = Math.max(1, scene.offsetHeight - lastHeight / 4);
    const value = String(Math.min(1, available / visibleHeight));
    if (hero.style.getPropertyValue('--scene-scale') !== value) {
      hero.style.setProperty('--scene-scale', value);
      hero.dispatchEvent(new Event('stack-frame'));
    }
  }
  const observer = new ResizeObserver(fitHeight);
  observer.observe(scene);
  observer.observe(header);
  observer.observe(hero);
  new MutationObserver(fitHeight).observe(hero, {attributes:true, attributeFilter:['style']});
  fitHeight();
})();
