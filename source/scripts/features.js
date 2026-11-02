(() => {
  const example=document.querySelector('.switch-visual');
  if(!example)return;
  const code=example.querySelector('code');
  function show(sdk) {
    const flock=sdk==='flock';
    example.querySelectorAll('[data-sdk]').forEach(button=>button.setAttribute('aria-pressed',String(button.dataset.sdk===sdk)));
    // Keep this a complete, valid .fvmrc example in either state.
    code.replaceChildren(document.createTextNode('{\n  '));
    const key=document.createElement('span');key.className='code-key';key.textContent='"flutter"';
    const value=document.createElement('span');value.className='code-value';value.textContent='"master"';
    code.append(key,document.createTextNode(': '),value);
    if(flock) {
      const urlKey=document.createElement('span');urlKey.className='code-key';urlKey.textContent='"flutterUrl"';
      const url=document.createElement('span');url.className='code-value';url.textContent='"https://github.com/join-the-flock/flock.git"';
      code.append(document.createTextNode(',\n  '),urlKey,document.createTextNode(':\n    '),url);
    }
    code.append(document.createTextNode('\n}'));
  }
  example.querySelectorAll('[data-sdk]').forEach(button=>button.addEventListener('click',()=>show(button.dataset.sdk)));
  show('flock');
})();
