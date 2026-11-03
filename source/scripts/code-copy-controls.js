// These shell examples are command invocations, not shell programs. Avoid
// treating arguments such as "add" or "install" as standalone Bash builtins.
Prism.languages.bash = {comment: Prism.languages.bash.comment};

Prism.hooks.add('complete', ({element}) => {
  const button = element.closest('.code-toolbar')?.querySelector('.copy-to-clipboard-button');
  if (!button) return;
  button.title = 'Copy code';
  button.querySelector('span').setAttribute('aria-live', 'polite');
  new MutationObserver(() => {
    button.title = button.dataset.copyState === 'copy' ? 'Copy code' : button.textContent;
  }).observe(button, {attributes: true, attributeFilter: ['data-copy-state']});
});
