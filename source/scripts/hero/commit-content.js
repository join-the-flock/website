(() => {
  const relative = new Intl.RelativeTimeFormat('en', {numeric:'auto'});
  function label(date) {
    const seconds = (Date.parse(date)-Date.now())/1000;
    if (!Number.isFinite(seconds)) return '';
    for (const [unit,size] of [['year',31536000],['month',2592000],['day',86400],['hour',3600],['minute',60]]) {
      if (Math.abs(seconds)>=size) return relative.format(Math.round(seconds/size),unit);
    }
    return 'just now';
  }
  function githubUrl(value) {
    try { const url=new URL(value); return url.protocol==='https:'&&url.hostname==='github.com'?url.href:null; }
    catch { return null; }
  }
  function normalize(data) {
    if(!data||typeof data.message!=='string')return null;
    const author=data.authorLogin||data.authorName||data.author;
    if(typeof author!=='string')return null;
    return {...data,author,url:githubUrl(data.url)};
  }
  function fillCard(card,data) {
    const heading=card.querySelector('h2');
    const link=document.createElement('a');link.textContent=data.message;
    if(data.url)link.href=data.url;
    heading.replaceChildren(link);
    const name=document.createElement('strong');name.textContent=data.author;
    const time=document.createElement('time');
    if(data.authoredAt){time.dateTime=data.authoredAt;time.textContent=label(data.authoredAt);}
    else time.textContent='just now';
    card.querySelector('p span:last-child').replaceChildren(name,document.createTextNode(' authored '),time);
    const avatar=card.querySelector('.avatar');
    avatar.textContent=data.author.split(/[\s-]+/).map(word=>word[0]).slice(0,2).join('').toUpperCase();
    try {
      const url=new URL(data.avatarUrl);
      if(url.protocol==='https:'&&url.hostname==='avatars.githubusercontent.com') {
        const image=document.createElement('img');image.src=url.href;image.alt='';avatar.replaceChildren(image);
      }
    } catch { /* Keep initials for unlinked authors. */ }
    if(data.sha)card.dataset.sha=data.sha;
  }
  window.FlockHero={normalize,fillCard};
  document.querySelectorAll('.hero time[datetime]').forEach(time=>{time.textContent=label(time.dateTime);});
  document.querySelectorAll('.hero a[aria-disabled="true"]').forEach(link=>link.addEventListener('click',event=>event.preventDefault()));
})();
