(() => {
  const hero = document.querySelector('.hero');
  const stack = document.querySelector('.stack');
  const reduced = matchMedia('(prefers-reduced-motion: reduce)');
  const seeds = [...stack.querySelectorAll('.patch')];
  const original = seeds[0];
  const template = original.cloneNode(true);
  const sizer = original.cloneNode(true);
  sizer.classList.add('patch-sizer');
  sizer.setAttribute('aria-hidden','true');
  sizer.inert = true;
  original.replaceWith(sizer);
  stack.querySelectorAll('.back').forEach(card=>card.remove());
  stack.classList.add('live');
  let cards = [], busy = false, animations = [], frame;
  const queue = [];
  function create(data) {
    const card = template.cloneNode(true);
    card.classList.add('patch-card');
    card.setAttribute('aria-hidden','true');
    window.FlockHero.fillCard(card, data);
    stack.append(card);
    return card;
  }
  function pose(depth) {
    const step = parseFloat(getComputedStyle(stack).getPropertyValue('--depth-step'));
    return `translateY(${depth*step}px) scaleX(${1-depth*.04})`;
  }
  function settle() {
    cards.forEach((card,index)=>{
      card.style.transform = pose(index);
      card.style.opacity = '1';
      card.style.filter = `brightness(${1-index*.13})`;
      card.style.zIndex = String(10-index);
      card.setAttribute('aria-hidden',String(index!==0));
      card.inert = index !== 0;
    });
    hero.dispatchEvent(new Event('stack-frame'));
  }
  function measure() {
    stack.style.setProperty('--patch-height',getComputedStyle(sizer).height);
    if (!busy) settle();
  }
  for (const card of seeds) {
    card.hidden = false;
    card.classList.add('patch-card');
    stack.append(card);
    cards.push(card);
  }
  new ResizeObserver(measure).observe(sizer);
  measure();
  function tracking() {
    if (!busy || !window.FlockHero.isAnimationVisible() || reduced.matches) { return; }
    hero.dispatchEvent(new Event('stack-frame'));
    if(busy) frame=requestAnimationFrame(tracking);
  }
  async function insert(data) {
    data = window.FlockHero.normalize(data);
    if (!data) return;
    if(busy) { if(queue.length<10) queue.push(data); return; }
    busy=true;
    const incoming=create(data);
    incoming.style.zIndex='11';
    incoming.style.transform='translateY(-100%)';
    const options={duration:reduced.matches?0:1150,easing:'cubic-bezier(.22,.7,.22,1)',fill:'forwards'};
    animations=cards.map((card,index)=>card.animate([
      {transform:pose(index),opacity:1,filter:`brightness(${1-index*.13})`},
      {transform:pose(index+1),opacity:index===cards.length-1?0:1,filter:`brightness(${1-(index+1)*.13})`}
    ],options));
    animations.push(incoming.animate([{transform:'translateY(-100%)'},{transform:'translateY(0)'}],options));
    sync();
    await Promise.all(animations.map(animation=>animation.finished));
    cards.pop().remove();
    cards.unshift(incoming);
    busy=false;
    cancelAnimationFrame(frame);
    // Commit the final positions before clearing animation overrides.
    settle();
    animations.forEach(animation=>animation.cancel());animations=[];
    hero.dispatchEvent(new Event('stack-frame'));
    if(queue.length) insert(queue.shift());
  }
  function sync() {
    cancelAnimationFrame(frame);
    const paused = !window.FlockHero.isAnimationVisible() && !reduced.matches;
    animations.forEach(animation=>paused?animation.pause():animation.play());
    if (busy && !paused && !reduced.matches) { frame=requestAnimationFrame(tracking); }
  }
  hero.addEventListener('flock-commit',event=>insert(event.detail));
  hero.addEventListener('hero-visibility',sync);
  reduced.addEventListener('change',()=>{if(reduced.matches) animations.forEach(animation=>animation.finish());sync();});
  sync();
})();
