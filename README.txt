═══════════════════════════════════════════════════════════════
  MOTEL LE DESTIN LERO — PWA v10
  HABATECH © 2025
═══════════════════════════════════════════════════════════════

CONTENU DU DOSSIER
──────────────────
  index.html              → Application principale (modifiée PWA)
  manifest.json           → Manifest PWA (nom, icônes, thème)
  sw.js                   → Service Worker (cache offline)
  icons/
    icon-192.png          → Icône PWA Android / Chrome
    icon-512.png          → Icône PWA haute résolution
    apple-touch-icon.png  → Icône iOS (Safari)
  README.txt              → Ce fichier

DÉPLOIEMENT RECOMMANDÉ
────────────────────────
La PWA nécessite HTTPS pour fonctionner (requis par les navigateurs
pour les Service Workers). Voici les options gratuites :

┌─────────────────────────────────────────────────────────────┐
│ OPTION 1 — Netlify (recommandé, le plus simple)             │
│                                                             │
│  1. Créez un compte sur https://netlify.com                 │
│  2. Glissez-déposez ce dossier entier sur Netlify Drop :    │
│     https://app.netlify.com/drop                            │
│  3. Votre URL HTTPS est générée instantanément              │
│     Ex: https://motel-destin.netlify.app                    │
│                                                             │
│ ✅ HTTPS automatique · ✅ CDN mondial · ✅ Gratuit          │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ OPTION 2 — GitHub Pages                                     │
│                                                             │
│  1. Créez un repo GitHub (public ou privé avec Pages Pro)   │
│  2. Uploadez tous les fichiers dans le repo                 │
│  3. Settings → Pages → Source: main branch / root           │
│  4. URL: https://[votre-pseudo].github.io/[repo-name]/      │
│                                                             │
│ ✅ HTTPS automatique · ✅ Gratuit · ⚙️ Nécessite un compte  │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ OPTION 3 — Serveur VPS / Hébergement local                  │
│                                                             │
│  1. Uploadez les fichiers dans le dossier public du serveur │
│  2. Activez HTTPS (Let's Encrypt / Certbot)                 │
│  3. Vérifiez que le serveur sert les .json en              │
│     application/json (pour le manifest)                     │
└─────────────────────────────────────────────────────────────┘

INSTALLATION SUR MOBILE
────────────────────────
  Android (Chrome) :
    → Ouvrir l'URL dans Chrome
    → Menu ⋮ → "Ajouter à l'écran d'accueil"
    → OU cliquer sur le bouton 📲 dans le header de l'app

  iOS (Safari) :
    → Ouvrir l'URL dans Safari
    → Bouton Partager → "Sur l'écran d'accueil"

FONCTIONNEMENT OFFLINE
────────────────────────
  ✅ Application disponible sans connexion après le 1er chargement
  ✅ Données stockées localement (localStorage)
  ⚠️  Les polices Google Fonts et libs CDN (jsPDF, Chart.js)
      sont mises en cache au 1er chargement.
      Connectez-vous au moins une fois pour activer le mode offline complet.

VÉRIFICATION PWA
────────────────
  Dans Chrome DevTools :
    → F12 → Application → Manifest  (vérifier l'icône et le nom)
    → F12 → Application → Service Workers (vérifier "activated")
    → Lighthouse → PWA (score cible : 100)

═══════════════════════════════════════════════════════════════
  Développé par HABATECH — Honoris Haba
  habatech2026@gmail.com · +224 627 541 925
═══════════════════════════════════════════════════════════════
