/* ============================================================
   Service Worker — Motel Le Destin Lero PWA
   HABATECH © 2025 — v10
   ============================================================ */

const CACHE_NAME   = 'motel-destin-v10';
const CACHE_STATIC = 'motel-destin-static-v10';

/* Ressources à mettre en cache immédiatement à l'installation */
const PRECACHE_URLS = [
  './index.html',
  './manifest.json',
  './icons/icon-192.png',
  './icons/icon-512.png',
  './icons/apple-touch-icon.png'
];

/* CDN — mis en cache lors du premier chargement (cache-then-network) */
const CDN_URLS = [
  'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&family=DM+Sans:wght@400;500;600;700;800;900&display=swap',
  'https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js',
  'https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.8.2/jspdf.plugin.autotable.min.js',
  'https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js'
];

/* ── INSTALL ── */
self.addEventListener('install', event => {
  console.log('[SW] Install — cache statique');
  event.waitUntil(
    caches.open(CACHE_STATIC)
      .then(cache => cache.addAll(PRECACHE_URLS))
      .then(() => self.skipWaiting())
  );
});

/* ── ACTIVATE ── Purge anciens caches */
self.addEventListener('activate', event => {
  console.log('[SW] Activate — nettoyage anciens caches');
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(
        keys
          .filter(k => k !== CACHE_STATIC && k !== CACHE_NAME)
          .map(k => {
            console.log('[SW] Suppression cache obsolète :', k);
            return caches.delete(k);
          })
      )
    ).then(() => self.clients.claim())
  );
});

/* ── FETCH ── Stratégie : Cache First pour ressources locales,
   Network First + cache fallback pour CDN                      */
self.addEventListener('fetch', event => {
  const url = event.request.url;

  /* Ignorer les requêtes non-GET */
  if (event.request.method !== 'GET') return;

  /* Ressources locales → Cache First */
  if (url.includes(self.location.origin) || isCDN(url) === false && url.startsWith('http')) {
    event.respondWith(cacheFirst(event.request));
    return;
  }

  /* CDN → Network First avec fallback cache */
  if (isCDN(url)) {
    event.respondWith(networkFirstWithCache(event.request));
    return;
  }
});

function isCDN(url) {
  return url.includes('cdnjs.cloudflare.com') ||
         url.includes('cdn.jsdelivr.net') ||
         url.includes('fonts.googleapis.com') ||
         url.includes('fonts.gstatic.com');
}

async function cacheFirst(request) {
  const cached = await caches.match(request);
  if (cached) return cached;
  try {
    const response = await fetch(request);
    if (response.ok) {
      const cache = await caches.open(CACHE_STATIC);
      cache.put(request, response.clone());
    }
    return response;
  } catch (err) {
    /* Offline et pas en cache → page d'erreur offline */
    return offlineFallback();
  }
}

async function networkFirstWithCache(request) {
  try {
    const response = await fetch(request);
    if (response.ok) {
      const cache = await caches.open(CACHE_NAME);
      cache.put(request, response.clone());
    }
    return response;
  } catch (err) {
    const cached = await caches.match(request);
    if (cached) return cached;
    return offlineFallback();
  }
}

function offlineFallback() {
  return new Response(
    `<!DOCTYPE html>
    <html lang="fr">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>Hors ligne — Motel Le Destin</title>
      <style>
        body { font-family: sans-serif; display:flex; flex-direction:column;
               align-items:center; justify-content:center; min-height:100vh;
               background:#1a237e; color:#fff; text-align:center; padding:24px; }
        .icon { font-size:64px; margin-bottom:16px; }
        h1 { font-size:22px; font-weight:800; margin-bottom:8px; }
        p  { font-size:14px; color:rgba(255,255,255,.7); max-width:280px; }
        button { margin-top:24px; padding:12px 28px; background:#f5c518; color:#1a237e;
                 border:none; border-radius:8px; font-weight:700; font-size:15px;
                 cursor:pointer; }
      </style>
    </head>
    <body>
      <div class="icon">📴</div>
      <h1>Vous êtes hors ligne</h1>
      <p>Connectez-vous à internet pour charger les ressources CDN manquantes.</p>
      <button onclick="location.reload()">Réessayer</button>
    </body>
    </html>`,
    { headers: { 'Content-Type': 'text/html; charset=utf-8' } }
  );
}
