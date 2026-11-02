(() => {
  const hero = document.querySelector('.hero');
  const list = document.querySelector('.flutter');
  const reduced = matchMedia('(prefers-reduced-motion: reduce)');
  let cards = [...list.children];
  const template = cards[0].cloneNode(true);
  let busy = false, animations = [], frame;
  const queue = [];
  list.classList.add('live');
  cards.forEach(card=>card.classList.add('flutter-card'));
  function pose(y,z=0,scale=1) { return `translateY(${y}px) perspective(900px) translateZ(${z}px) scale(${scale})`; }
  function layout(items) {
    const gap=parseFloat(getComputedStyle(list).rowGap);
    let top=0;
    const slots=items.map(card=>{
      const height=card.offsetHeight;
      const slot={top,height};top+=height+gap;return slot;
    });
    return {slots,height:top-gap,lastHeight:slots.at(-1).height};
  }
  function measure() {
    if(busy)return;
    const result=layout(cards);
    list.style.height=`${result.height}px`;
    hero.style.setProperty('--last-card-height',`${result.lastHeight}px`);
    cards.forEach((card,i)=>{
      list.append(card);
      card.style.top='0';card.style.transform=pose(result.slots[i].top);
      card.style.opacity='1';card.style.zIndex='1';card.removeAttribute('aria-hidden');
    });
    hero.dispatchEvent(new Event('stack-frame'));
  }
  const observer=new ResizeObserver(measure);
  cards.forEach(card=>observer.observe(card));
  measure();
  function track() {
    if (!busy || !window.FlockHero.isAnimationVisible() || reduced.matches) { return; }
    hero.dispatchEvent(new Event('stack-frame'));
    if (busy) { frame=requestAnimationFrame(track); }
  }
  async function insert(data) {
    data=window.FlockHero.normalize(data);
    if(!data)return;
    if(busy){if(queue.length<10)queue.push(data);return;}
    const before=layout(cards);
    busy=true;
    const incoming=template.cloneNode(true);
    incoming.classList.add('flutter-card');incoming.setAttribute('aria-hidden','true');
    window.FlockHero.fillCard(incoming, data);
    incoming.style.top='0';incoming.style.zIndex='0';incoming.style.opacity='0';
    list.append(incoming);
    const nextCards=[incoming,...cards.slice(0,-1)];
    const after=layout(nextCards);
    const gap=parseFloat(getComputedStyle(list).rowGap);
    const distance=incoming.offsetHeight+gap;
    const options={duration:reduced.matches?0:1250,easing:'cubic-bezier(.22,.7,.22,1)',fill:'forwards'};
    animations=cards.map((card,i)=>card.animate([
      {transform:pose(before.slots[i].top)},
      {transform:pose(before.slots[i].top+distance)}
    ],options));
    animations.push(incoming.animate([
      {transform:pose(0,-1800,.65),opacity:0},
      {transform:pose(0),opacity:1}
    ],options));
    // Animate the natural list height and bottom cutoff together as the content changes.
    animations.push(list.animate([{height:`${before.height}px`},{height:`${after.height}px`}],options));
    animations.push(hero.animate([{'--last-card-height':`${before.lastHeight}px`},{'--last-card-height':`${after.lastHeight}px`}],options));
    sync();
    await Promise.all(animations.map(a=>a.finished));
    const oldest=cards.at(-1);observer.unobserve(oldest);oldest.remove();
    cards=nextCards;busy=false;cancelAnimationFrame(frame);
    measure();animations.forEach(a=>a.cancel());animations=[];
    observer.observe(incoming);
    hero.dispatchEvent(new Event('stack-frame'));
    if(queue.length)insert(queue.shift());
  }
  function sync(){
    cancelAnimationFrame(frame);
    const paused=!window.FlockHero.isAnimationVisible()&&!reduced.matches;
    animations.forEach(a=>paused?a.pause():a.play());
    if (busy && !paused && !reduced.matches) { frame=requestAnimationFrame(track); }
  }
  hero.addEventListener('flutter-commit',event=>insert(event.detail));
  hero.addEventListener('hero-visibility',sync);
  reduced.addEventListener('change',()=>{if(reduced.matches)animations.forEach(a=>a.finish());sync();});
  sync();
})();
