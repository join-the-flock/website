(() => {
  const canvas = document.querySelector('#plume');
  const ctx = canvas.getContext('2d');
  const layer = document.createElement('canvas');
  const ink = layer.getContext('2d');
  const hero = document.querySelector('.hero');
  const preference = matchMedia('(prefers-reduced-motion: reduce)');
  let width, height, columns, paused = preference.matches, frame, elapsed = 0, previous;
  const glyphs = '01{}[]<>/;:=+FLUTTER';
  const colors = ['#22d0f2','#149fe8','#7453ed','#b12cd0','#f8217e'];
  function resize() {
    width = hero.clientWidth; height = hero.clientHeight;
    const scale = Math.min(devicePixelRatio || 1, 1.5);
    for (const surface of [canvas, layer]) { surface.width = width*scale; surface.height = height*scale; }
    ctx.setTransform(scale,0,0,scale,0,0); ink.setTransform(scale,0,0,scale,0,0);
    columns = Array.from({length: Math.ceil(width/19)},(_,i) => ({x:i*19, speed:25+(i*37%60), offset:i*73%height}));
    draw();
  }
  function draw() {
    ctx.clearRect(0,0,width,height); ink.clearRect(0,0,width,height);
    // A rising field with soft, time-varying edges controls both glyph visibility and glow.
    const top = height*.035, bottom = height*1.13;
    const spread = Math.min(width*.42,610) * 1.5;
    for(let y=top;y<height;y+=18) {
      const progress = (y-top)/(bottom-top);
      const half = spread*(.35+progress*.65);
      const drift = Math.sin(y*.008-elapsed*.7)*18 + Math.sin(y*.019+elapsed*.43)*9;
      const c = colors[Math.min(4,Math.floor((1-progress)*5))];
      const glow = ctx.createRadialGradient(width/2+drift,y,0,width/2+drift,y,half);
      glow.addColorStop(0,c+'28'); glow.addColorStop(.6,c+'15'); glow.addColorStop(1,c+'00');
      ctx.fillStyle=glow;ctx.fillRect(width/2+drift-half,y-15,half*2,35);
    }
    ink.font = '13px monospace';
    for (const col of columns) {
      const shift = ((col.offset-elapsed*col.speed)%24+24)%24;
      for(let y=-24;y<height+24;y+=24) {
        const yy = y+shift;
        const p = Math.max(0,Math.min(1,(yy-top)/(bottom-top)));
        const half = spread*(.35+p*.65);
        const drift = Math.sin(yy*.008-elapsed*.7)*18+Math.sin(yy*.019+elapsed*.43)*9;
        const edge = Math.abs(col.x-width/2-drift)/half;
        const flutter = .82+.18*Math.sin(yy*.035+col.x*.02+elapsed*1.8);
        const opacity = Math.pow(Math.max(0,1-edge),.8)*Math.min(1,Math.max(0,yy-top)/100)*flutter;
        if(opacity<.015) continue;
        ink.globalAlpha = opacity*(.35+.4*Math.abs(Math.sin(col.x*4+y*7)));
        ink.fillStyle = colors[Math.min(4,Math.floor((1-p)*5))];
        const n = Math.abs(Math.floor(col.x*7+y*13+elapsed*.7));
        ink.fillText(glyphs[n%glyphs.length],col.x,yy);
      }
    }
    ink.globalAlpha=1;
    ctx.drawImage(layer,0,0,width,height);
    hero.dispatchEvent(new CustomEvent('plume-frame', {detail: {time: elapsed}}));
  }
  function tick(now) {
    if(previous!==undefined) elapsed+=Math.min((now-previous)/1000,.05);
    previous=now;draw();frame=requestAnimationFrame(tick);
  }
  function sync() {
    cancelAnimationFrame(frame);previous=undefined;
    if (window.FlockHero.isAnimationVisible()) {
      if (!paused) { frame=requestAnimationFrame(tick); }
      else { draw(); }
    }
  }
  preference.addEventListener('change',e=>{paused=e.matches;sync();});
  hero.addEventListener('hero-visibility',sync);
  new ResizeObserver(resize).observe(hero);
  resize();sync();
})();
