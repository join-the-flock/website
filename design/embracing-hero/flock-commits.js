(() => {
  const hero = document.querySelector('.hero');
  const stack = document.querySelector('.stack');
  const motion = document.querySelector('#motion');
  const trigger = document.querySelector('#new-commit');
  const reduced = matchMedia('(prefers-reduced-motion: reduce)');
  const original = stack.querySelector('.patch');
  const template = original.cloneNode(true);
  const sizer = original.cloneNode(true);
  sizer.classList.add('patch-sizer');
  sizer.setAttribute('aria-hidden','true');
  sizer.inert = true;
  original.replaceWith(sizer);
  stack.querySelectorAll('.back').forEach(card=>card.remove());
  stack.classList.add('live');
  let cards = [], busy = false, animations = [], timer, frame, sampleIndex = 0;
  const queue = [];
  // Deliberate demo data. A real feed can dispatch a `flock-commit` event on the hero.
  const samples = [
    {message:'Improve patch compatibility with Flutter master',author:'matthew-carroll'},
    {message:'Preserve community fixes during upstream sync',author:'Flock contributor'},
    {message:'Update Flock patches for the latest engine roll',author:'Flock contributor'},
    {message:'Repair patches for current Flutter master',author:'matthew-carroll'}
  ];
  function create(data) {
    const card = template.cloneNode(true);
    card.classList.add('patch-card');
    card.setAttribute('aria-hidden','true');
    card.querySelector('h1').textContent = data.message;
    const author = card.querySelector('p span:last-child');
    const name = document.createElement('strong'); name.textContent = data.author;
    author.replaceChildren(name, document.createTextNode(` ${data.when || 'authored just now'}`));
    card.querySelector('.avatar').textContent = data.author.split(/[\s-]+/).map(word=>word[0]).slice(0,2).join('').toUpperCase();
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
    });
    hero.dispatchEvent(new Event('stack-frame'));
  }
  function measure() {
    stack.style.setProperty('--patch-height',getComputedStyle(sizer).height);
    if (!busy) settle();
  }
  for(let i=0;i<4;i++) cards.push(create({message:original.querySelector('h1').textContent,author:'matthew-carroll',when:'authored yesterday'}));
  new ResizeObserver(measure).observe(sizer);
  measure();
  function tracking() {
    hero.dispatchEvent(new Event('stack-frame'));
    if(busy) frame=requestAnimationFrame(tracking);
  }
  async function insert(data) {
    if(!data || typeof data.message!=='string' || typeof data.author!=='string') return;
    if(busy) { if(queue.length<10) queue.push(data); return; }
    busy=true;
    const incoming=create(data);
    incoming.style.zIndex='11';
    incoming.style.transform='translateY(-100%)';
    const options={duration:reduced.matches?0:1150,easing:'cubic-bezier(.22,.7,.22,1)',fill:'forwards'};
    animations=cards.map((card,index)=>card.animate([
      {transform:pose(index),opacity:1,filter:`brightness(${1-index*.13})`},
      {transform:pose(index+1),opacity:index===3?0:1,filter:`brightness(${1-(index+1)*.13})`}
    ],options));
    animations.push(incoming.animate([{transform:'translateY(-100%)'},{transform:'translateY(0)'}],options));
    if(motion.getAttribute('aria-pressed')==='true'&&!reduced.matches) animations.forEach(animation=>animation.pause());
    tracking();
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
  function demo() { insert(samples[sampleIndex++%samples.length]); }
  function sync() {
    clearInterval(timer);
    const paused = motion.getAttribute('aria-pressed')==='true'||document.hidden;
    animations.forEach(animation=>paused?animation.pause():animation.play());
    if(!paused&&!reduced.matches) timer=setInterval(demo,10000);
  }
  trigger.addEventListener('click',demo);
  hero.addEventListener('flock-commit',event=>insert(event.detail));
  new MutationObserver(sync).observe(motion,{attributes:true,attributeFilter:['aria-pressed']});
  document.addEventListener('visibilitychange',sync);
  reduced.addEventListener('change',()=>{if(reduced.matches) animations.forEach(animation=>animation.finish());sync();});
  sync();
})();
