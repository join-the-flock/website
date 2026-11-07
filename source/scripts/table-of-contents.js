(() => {
  const content = document.querySelector('#contentColumn');
  const column = document.querySelector('#pageContentsColumn');
  const title = content?.querySelector('h1');
  if (!content || !column || !title) return;

  const headings = [...content.querySelectorAll('h2, h3')];
  if (!headings.length) return;
  const usedIds = new Set([...document.querySelectorAll('[id]')].map(el => el.id));
  const nav = document.createElement('nav');
  nav.className = 'page-contents';
  nav.setAttribute('aria-label', 'Table of contents');
  const list = document.createElement('ul');
  nav.append(list);
  let parentItem;
  const links = headings.map(heading => {
    if (!heading.id) {
      const base = heading.textContent.trim().toLowerCase()
        .replace(/[^\p{L}\p{N}]+/gu, '-').replace(/^-|-$/g, '') || 'section';
      let id = base;
      for (let suffix = 2; usedIds.has(id); suffix++) id = `${base}-${suffix}`;
      heading.id = id;
      usedIds.add(id);
    }
    const item = document.createElement('li');
    const link = document.createElement('a');
    link.textContent = heading.textContent.trim();
    link.href = `#${encodeURIComponent(heading.id)}`;
    item.append(link);
    if (heading.tagName === 'H3' && parentItem) {
      let children = parentItem.querySelector('ul');
      if (!children) {
        children = document.createElement('ul');
        parentItem.append(children);
      }
      children.append(item);
    } else {
      list.append(item);
      parentItem = item;
    }
    return link;
  });

  const wide = matchMedia('(min-width: 1200px)');
  const place = () => {
    if (wide.matches) column.append(nav);
    else title.after(nav);
  };
  place();
  wide.addEventListener('change', place);

  let scheduled = false;
  const update = () => {
    scheduled = false;
    let current = -1;
    headings.forEach((heading, index) => {
      if (heading.getBoundingClientRect().top <= 120) current = index;
    });
    links.forEach((link, index) => {
      if (index === current) link.setAttribute('aria-current', 'location');
      else link.removeAttribute('aria-current');
    });
  };
  const schedule = () => {
    if (scheduled) return;
    scheduled = true;
    requestAnimationFrame(update);
  };
  addEventListener('scroll', schedule, {passive: true});
  addEventListener('resize', schedule);
  update();
})();
