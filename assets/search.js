// Client-side search over /search.json (title, summary, full text). No dependencies.
(async () => {
  const script = document.currentScript || document.querySelector('script[data-index]');
  const status = document.getElementById('search-status');
  const out = document.getElementById('search-results');
  const q = (new URLSearchParams(location.search).get('q') || '').trim();
  document.getElementById('q').value = q;
  if (!q) { status.textContent = 'Type a word or phrase above to search all guides.'; return; }
  const esc = s => s.replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));
  let docs;
  try { docs = await (await fetch(script.dataset.index)).json(); }
  catch { status.textContent = 'Search is unavailable right now.'; return; }
  const terms = q.toLowerCase().split(/\s+/);
  const hits = docs
    .map(d => {
      const t = d.title.toLowerCase(), s = d.description.toLowerCase(), x = d.text.toLowerCase();
      if (!terms.every(w => t.includes(w) || s.includes(w) || x.includes(w))) return null;
      return { d, score: terms.reduce((n, w) => n + (t.includes(w) ? 5 : 0) + (s.includes(w) ? 2 : 0) + (x.includes(w) ? 1 : 0), 0) };
    })
    .filter(Boolean).sort((a, b) => b.score - a.score);
  status.textContent = hits.length ? `${hits.length} result${hits.length > 1 ? 's' : ''} for “${q}”` : `No results for “${q}”.`;
  out.innerHTML = hits.map(({ d }) => `<article class="story story--list"><p class="label">${esc(d.section || '')}</p>
    <h2 class="headline"><a href="${esc(d.url)}">${esc(d.title)}</a></h2><p class="dek">${esc(d.description)}</p>
    <p class="byline">${esc(d.date)}</p></article>`).join('');
})();
