(() => {
  const hero = document.querySelector('.hero');
  function useSimpleGlow() {
    hero.classList.add('hero--simple-glow');
  }
  // Touch-first devices use native group shadows instead of a transparent WebGL overlay.
  if (matchMedia('(pointer: coarse)').matches) {
    useSimpleGlow();
    return;
  }
  const bird = document.querySelector('.fleek');
  const reduced = matchMedia('(prefers-reduced-motion: reduce)');
  const canvas = document.createElement('canvas');
  canvas.className = 'edge-glow';
  canvas.setAttribute('aria-hidden', 'true');
  const gl = canvas.getContext('webgl', {alpha: true, premultipliedAlpha: true, depth: false, antialias: false});
  if (!gl) {
    useSimpleGlow();
    return;
  }
  const mask = document.createElement('canvas');
  const paint = mask.getContext('2d');
  function shader(type, source) {
    const result = gl.createShader(type);
    gl.shaderSource(result, source); gl.compileShader(result);
    if (!gl.getShaderParameter(result, gl.COMPILE_STATUS)) throw new Error(gl.getShaderInfoLog(result));
    return result;
  }
  const program = gl.createProgram();
  try {
  gl.attachShader(program, shader(gl.VERTEX_SHADER, `
    attribute vec2 position;
    varying vec2 uv;
    void main() { uv = position * .5 + .5; gl_Position = vec4(position, 0., 1.); }
  `));
  gl.attachShader(program, shader(gl.FRAGMENT_SHADER, `
    precision mediump float;
    varying vec2 uv;
    uniform sampler2D silhouette;
    uniform vec2 size;
    uniform float time;
    uniform float split;
    void main() {
      float body = texture2D(silhouette, uv).a;
      float nearEdge = 0.;
      float halo = 0.;
      for (int i = 0; i < 12; i++) {
        float angle = float(i) * 6.2831853 / 12.;
        vec2 direction = vec2(cos(angle), sin(angle)) / size;
        nearEdge += texture2D(silhouette, uv + direction * 2.).a / 12.;
        halo += texture2D(silhouette, uv + direction * 6.).a / 24.;
        halo += texture2D(silhouette, uv + direction * 12.).a / 24.;
      }
      // The mask is a union: no rim is drawn where Fleek meets a patch card.
      float edge = (nearEdge * 1.15 + halo * .52) * (1. - smoothstep(.03, .9, body));
      // Match the background's flicker and drifting plume, using its animation clock.
      float y = (1. - uv.y) * size.y;
      float x = uv.x * size.x;
      float drift = sin(y * .008 - time * .7) * 18.
                  + sin(y * .019 + time * .43) * 9.;
      float flicker = sin(y * .035 + x * .02 + time * 1.8);
      float risingLight = pow(.5 + .5 * sin(uv.y * 24. - time * 1.7 + sin(x * .012)), 3.);
      float wave = .85 + .13 * flicker + .20 * risingLight
                       + .07 * sin(x * .018 + drift * .045 + time * .73);
      float upper = smoothstep(split - .005, split + .015, uv.y);
      vec3 cyan = vec3(.13, .82, .95);
      vec3 violet = vec3(.62, .20, .95);
      vec3 pink = vec3(.98, .13, .49);
      vec3 warm = mix(violet, pink, .6 + .2 * sin(time * .45 + uv.y * 9.));
      vec3 color = mix(cyan, warm, upper);
      float strength = mix(1., 1.85, upper);
      float alpha = clamp(edge * wave * strength, 0., mix(.82, .96, upper));
      // WebKit can expose RGB from transparent pixels when straight-alpha compositing is used.
      // Premultiplication also guarantees that fully transparent pixels contain no color.
      gl_FragColor = vec4(color * alpha, alpha);
    }
  `));
  gl.linkProgram(program);
  if (!gl.getProgramParameter(program, gl.LINK_STATUS)) throw new Error(gl.getProgramInfoLog(program));
  } catch {
    gl.deleteProgram(program);
    useSimpleGlow();
    return;
  }
  hero.append(canvas);
  gl.useProgram(program);
  const buffer = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1,-1, 1,-1, -1,1, -1,1, 1,-1, 1,1]), gl.STATIC_DRAW);
  const position = gl.getAttribLocation(program, 'position');
  gl.enableVertexAttribArray(position); gl.vertexAttribPointer(position,2,gl.FLOAT,false,0,0);
  const texture = gl.createTexture();
  gl.bindTexture(gl.TEXTURE_2D,texture);
  gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.LINEAR);
  gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.LINEAR);
  gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_WRAP_S,gl.CLAMP_TO_EDGE);
  gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_WRAP_T,gl.CLAMP_TO_EDGE);
  gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL,true);
  const size = gl.getUniformLocation(program,'size');
  const time = gl.getUniformLocation(program,'time');
  const split = gl.getUniformLocation(program,'split');
  let ready = false, lost = false, frame, seconds = 0, drawn = 0;
  hero.addEventListener('plume-frame',event=>{seconds=event.detail.time;});
  function rebuild() {
    if (lost || !bird.complete || !bird.naturalWidth) return;
    const bounds = hero.getBoundingClientRect();
    const scale = Math.min(devicePixelRatio || 1, 1);
    const width = Math.round(bounds.width * scale), height = Math.round(bounds.height * scale);
    if(canvas.width!==width || canvas.height!==height) {
      canvas.width = mask.width = width;
      canvas.height = mask.height = height;
    }
    paint.setTransform(scale,0,0,scale,0,0);
    paint.clearRect(0,0,bounds.width,bounds.height);
    // Source-over merges the mascot alpha and every card into one silhouette.
    const rect = bird.getBoundingClientRect();
    paint.drawImage(bird,rect.left-bounds.left,rect.top-bounds.top,rect.width,rect.height);
    paint.fillStyle = '#fff';
    for (const card of hero.querySelectorAll('.commit, .back')) {
      if(card.classList.contains('patch-sizer') || card.classList.contains('flutter-sizer')) continue;
      paint.save();
      if(card.classList.contains('patch-card')) {
        const stack = hero.querySelector('.stack').getBoundingClientRect();
        paint.beginPath();paint.rect(0,stack.top-bounds.top,bounds.width,bounds.height);paint.clip();
      }
      paint.globalAlpha = parseFloat(getComputedStyle(card).opacity);
      const r = card.getBoundingClientRect();
      paint.beginPath();
      const radius = parseFloat(getComputedStyle(card).borderRadius) * r.width / card.offsetWidth;
      paint.roundRect(r.left-bounds.left,r.top-bounds.top,r.width,r.height,radius);
      paint.fill();
      paint.restore();
    }
    gl.viewport(0,0,canvas.width,canvas.height);
    gl.uniform2f(size,bounds.width,bounds.height);
    const patches = hero.querySelector('.stack').getBoundingClientRect();
    const flutter = hero.querySelector('.flutter').getBoundingClientRect();
    gl.uniform1f(split,1-((patches.bottom+flutter.top)/2-bounds.top)/bounds.height);
    gl.texImage2D(gl.TEXTURE_2D,0,gl.RGBA,gl.RGBA,gl.UNSIGNED_BYTE,mask);
    ready = true; render();
  }
  function render() {
    if (!ready || lost) return;
    gl.uniform1f(time,seconds);gl.drawArrays(gl.TRIANGLES,0,6);
  }
  function tick(now) {
    if (now-drawn > 32) { render(); drawn = now; }
    frame = requestAnimationFrame(tick);
  }
  function sync() {
    cancelAnimationFrame(frame);
    if (!lost && window.FlockHero.isAnimationVisible()) {
      if (!reduced.matches) { frame = requestAnimationFrame(tick); }
      else { render(); }
    }
  }
  reduced.addEventListener('change', sync);
  hero.addEventListener('hero-visibility',sync);
  canvas.addEventListener('webglcontextlost',event=>{event.preventDefault();lost=true;cancelAnimationFrame(frame);canvas.style.display='none';useSimpleGlow();});
  const observer = new ResizeObserver(rebuild);
  observer.observe(hero);observer.observe(document.querySelector('.scene'));
  bird.addEventListener('load',rebuild);
  hero.addEventListener('stack-frame',rebuild);
  rebuild();sync();
})();
