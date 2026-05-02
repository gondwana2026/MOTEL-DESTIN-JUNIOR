// ══════════════════════════════════════════════════════
//  SERVICE WORKER — Motel Destin PWA
//  Stratégie : Cache-First pour l'app shell
//              Network-First pour les données Supabase
// ══════════════════════════════════════════════════════

const CACHE_NAME   = 'motel-destin-v10';
const CACHE_ASSETS = [
  '/',
  '/index.html',
  '/manifest.json',
  'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&family=DM+Sans:wght@400;500;600;700;800;900&display=swap',
  'https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js',
  'https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.8.2/jspdf.plugin.autotable.min.js',
  'https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js',
  'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.js'
];

// ── INSTALL : mise en cache des assets ──
self.addEventListener('install', event => {
  console.log('[SW] Install');
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => {
      // Cache principal (index.html en priorité)
      return cache.addAll(['/', '/index.html', '/manifest.json'])
        .then(() => {
          // Cache des CDN en arrière-plan (échec ignoré)
          return Promise.allSettled(
            CACHE_ASSETS.slice(3).map(url =>
              cache.add(url).catch(e => console.warn('[SW] CDN cache skip:', url))
            )
          );
        });
    }).then(() => self.skipWaiting())
  );
});

// ── ACTIVATE : nettoyage des anciens caches ──
self.addEventListener('activate', event => {
  console.log('[SW] Activate');
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(
        keys.filter(k => k !== CACHE_NAME).map(k => {
          console.log('[SW] Suppression ancien cache:', k);
          return caches.delete(k);
        })
      )
    ).then(() => self.clients.claim())
  );
});

// ── FETCH : stratégie de réponse ──
self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);

  // 1. Requêtes Supabase → Network-only (pas de cache)
  if (url.hostname.includes('supabase.co')) {
    event.respondWith(fetch(event.request).catch(() => new Response(
      JSON.stringify({ data: null, error: { message: 'offline' } }),
      { headers: { 'Content-Type': 'application/json' } }
    )));
    return;
  }

  // 2. Google Fonts → Cache-first avec fallback
  if (url.hostname.includes('fonts.googleapis.com') || url.hostname.includes('fonts.gstatic.com')) {
    event.respondWith(
      caches.match(event.request).then(cached => cached || fetch(event.request).then(res => {
        const clone = res.clone();
        caches.open(CACHE_NAME).then(c => c.put(event.request, clone));
        return res;
      }).catch(() => new Response('', { status: 503 })))
    );
    return;
  }

  // 3. App shell (index.html, manifest.json) → Cache-first, réseau en fallback
  if (url.pathname === '/' || url.pathname.endsWith('.html') || url.pathname.endsWith('.json')) {
    event.respondWith(
      caches.match(event.request).then(cached => {
        const networkFetch = fetch(event.request).then(res => {
          if (res.ok) {
            const clone = res.clone();
            caches.open(CACHE_NAME).then(c => c.put(event.request, clone));
          }
          return res;
        }).catch(() => cached || new Response('App hors ligne', { status: 503 }));
        return cached || networkFetch;
      })
    );
    return;
  }

  // 4. CDN (jsPDF, Chart.js, Supabase JS) → Cache-first
  if (url.hostname.includes('cdnjs.cloudflare.com') || url.hostname.includes('cdn.jsdelivr.net')) {
    event.respondWith(
      caches.match(event.request).then(cached => cached || fetch(event.request).then(res => {
        if (res.ok) {
          const clone = res.clone();
          caches.open(CACHE_NAME).then(c => c.put(event.request, clone));
        }
        return res;
      }).catch(() => new Response('', { status: 503 })))
    );
    return;
  }

  // 5. Tout le reste → réseau avec fallback cache
  event.respondWith(
    fetch(event.request).catch(() => caches.match(event.request))
  );
});

// ── MESSAGE : mise à jour forcée ──
self.addEventListener('message', event => {
  if (event.data === 'skipWaiting') self.skipWaiting();
});
