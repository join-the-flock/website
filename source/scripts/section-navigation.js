(() => {
  const nav = document.querySelector('.mobile-section-nav');
  if (!nav) return;
  const mobile = matchMedia('(max-width: 1199px)');
  const key = 'section-scroll';
  const pageKey = url => url.pathname.replace(/\/+$/, '') + url.search;
  const current = pageKey(new URL(location.href));

  nav.addEventListener('click', event => {
    const link = event.target.closest('a');
    if (!mobile.matches || !link || event.defaultPrevented || event.button !== 0 ||
        event.metaKey || event.ctrlKey || event.shiftKey || event.altKey ||
        link.hasAttribute('download') || (link.target && link.target !== '_self')) return;
    const destination = new URL(link.href);
    if (destination.origin !== location.origin || destination.hash) return;
    try {
      sessionStorage.setItem(key, JSON.stringify({
        destination: pageKey(destination), top: scrollY, at: Date.now(),
      }));
    } catch {
      // Navigation still works when browser storage is unavailable.
    }
  });

  let saved;
  try {
    saved = JSON.parse(sessionStorage.getItem(key));
    sessionStorage.removeItem(key);
  } catch { return; }
  const navigation = performance.getEntriesByType('navigation')[0];
  if (!mobile.matches || !saved || saved.destination !== current ||
      !Number.isFinite(saved.top) || saved.top < 0 ||
      !Number.isFinite(saved.at) || Date.now() - saved.at > 120000 ||
      (navigation && navigation.type !== 'navigate')) return;

  // The deferred script runs with the complete page and styles available.
  // Restore immediately, then once more when loading finishes in case images
  // or fonts changed the available page height. Never interrupt user input.
  let interacted = false;
  for (const type of ['touchstart', 'wheel', 'pointerdown', 'keydown']) {
    addEventListener(type, () => { interacted = true; }, {once: true, passive: true});
  }
  const restore = () => {
    if (!interacted) scrollTo({top: saved.top, left: 0, behavior: 'instant'});
  };
  restore();
  addEventListener('pageshow', event => { if (!event.persisted) restore(); }, {once: true});
})();
