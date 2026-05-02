═══════════════════════════════════════════════════════════════
  MOTEL LE DESTIN LERO — Migration Supabase v11
  HABATECH © 2025
═══════════════════════════════════════════════════════════════

CONTENU DU PACKAGE
──────────────────
  motel-destin-v11-supabase.html  → Application migrée vers Supabase
  supabase-schema.sql             → Script SQL à exécuter dans Supabase
  README.txt                      → Ce guide

CE QUI A CHANGÉ (v10 → v11)
──────────────────────────────
  ✅ Plus de localStorage — toutes les données sont dans Supabase
  ✅ Données persistantes sur tous les appareils simultanément
  ✅ Sauvegarde automatique en arrière-plan (fire & forget)
  ✅ 9 tables créées : products, mouvements, achats, caisse_ops,
     caisse_config, depots, chambres, sejours, pins
  ✅ Mappers camelCase (JS) ↔ snake_case (DB)
  ✅ Message d'erreur clair si credentials non configurés
  ✅ Compatibilité totale avec tous les modules existants

ÉTAPE 1 — CRÉER LE PROJET SUPABASE
────────────────────────────────────
  1. Allez sur https://supabase.com → "Start your project"
  2. Créez un nouveau projet (choisissez la région la plus proche,
     ex: Europe West pour la Guinée)
  3. Notez votre mot de passe DB — gardez-le précieusement
  4. Attendez la création (~2 minutes)

ÉTAPE 2 — CRÉER LES TABLES
────────────────────────────
  1. Dans votre projet Supabase, allez dans SQL Editor
  2. Cliquez "New query"
  3. Copiez-collez TOUT le contenu de supabase-schema.sql
  4. Cliquez "Run" (▶️)
  5. Vérifiez dans "Table Editor" que les 9 tables sont créées :
     products, mouvements, achats, caisse_ops, caisse_config,
     depots, chambres, sejours, pins

ÉTAPE 3 — RÉCUPÉRER VOS CREDENTIALS
──────────────────────────────────────
  Dans votre projet Supabase :
  → Settings (⚙️) > API

  Vous avez besoin de :
  ┌────────────────────────────────────────────────────────────┐
  │  Project URL        → ex: https://abcxyz.supabase.co       │
  │  anon / public key  → longue chaîne commençant par eyJ...  │
  └────────────────────────────────────────────────────────────┘
  ⚠️  N'utilisez PAS la clé service_role — elle est dangereuse
     dans un fichier HTML public.

ÉTAPE 4 — CONFIGURER L'APPLICATION
──────────────────────────────────────
  Ouvrez motel-destin-v11-supabase.html dans un éditeur texte
  (Notepad++, VS Code, Bloc-notes...)

  Cherchez ces deux lignes (vers la ligne 2550) :
  ┌────────────────────────────────────────────────────────────┐
  │  const SUPABASE_URL = 'https://VOTRE_PROJECT_ID.supabase.co'; │
  │  const SUPABASE_KEY = 'VOTRE_ANON_PUBLIC_KEY';             │
  └────────────────────────────────────────────────────────────┘

  Remplacez par vos vraies valeurs. Exemple :
  ┌────────────────────────────────────────────────────────────┐
  │  const SUPABASE_URL = 'https://abcdefgh.supabase.co';      │
  │  const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6Ikp…'; │
  └────────────────────────────────────────────────────────────┘

  Sauvegardez le fichier.

ÉTAPE 5 — DÉPLOIEMENT (OBLIGATOIRE — HTTPS requis)
────────────────────────────────────────────────────
  Supabase ne fonctionne PAS si vous ouvrez le fichier
  directement (file://). Il faut un serveur HTTPS.

  OPTION A — Netlify (recommandé, gratuit)
    1. Allez sur https://app.netlify.com/drop
    2. Glissez-déposez UNIQUEMENT le fichier HTML
    3. Votre URL HTTPS est prête en 30 secondes

  OPTION B — GitHub Pages
    1. Créez un repo GitHub
    2. Uploadez le HTML (renommez-le index.html)
    3. Settings → Pages → Source: main

  OPTION C — Votre propre serveur
    Placez le fichier dans le dossier public de votre serveur
    web (Apache/Nginx) avec HTTPS activé.

MIGRATION DES DONNÉES EXISTANTES (v10 → v11)
──────────────────────────────────────────────
  Si vous avez déjà des données dans la version localStorage (v10),
  vous pouvez les migrer manuellement :

  1. Ouvrez la v10 dans Chrome
  2. F12 → Console → tapez :
     console.log(JSON.stringify({
       products:   JSON.parse(localStorage.getItem('motel_destin_products')||'[]'),
       mouvements: JSON.parse(localStorage.getItem('motel_destin_mouvements')||'[]'),
       achats:     JSON.parse(localStorage.getItem('motel_destin_achats')||'[]'),
       caisse:     JSON.parse(localStorage.getItem('motel_destin_caisse')||'{}'),
       depots:     JSON.parse(localStorage.getItem('motel_destin_depots')||'[]'),
       chambres:   JSON.parse(localStorage.getItem('motel_destin_chambres')||'[]'),
       sejours:    JSON.parse(localStorage.getItem('motel_destin_sejours')||'[]'),
     }))
  3. Copiez le JSON affiché
  4. Contactez HABATECH pour un script d'import automatique

ARCHITECTURE TECHNIQUE
────────────────────────
  ┌────────────────────────────────────────────────────────────┐
  │  Navigateur (HTML/CSS/JS)                                  │
  │    ├── Arrays en mémoire (products, mouvements, etc.)      │
  │    ├── Rendu UI (inchangé vs v10)                          │
  │    └── saveAll() → fire & forget                           │
  │                         │                                  │
  │                   (async, background)                      │
  │                         │                                  │
  │  Supabase (PostgreSQL)                                     │
  │    ├── upsert() sur chaque table                           │
  │    ├── RLS activé (policies permissives anon)              │
  │    └── Index sur colonnes ts, product_id, chambre_id       │
  └────────────────────────────────────────────────────────────┘

  Stratégie : "Memory-first + Background Sync"
  → L'UI reste instantanée (pas d'await bloquant)
  → Supabase reçoit les données en arrière-plan
  → En cas d'erreur Supabase : toast d'avertissement + retry

DÉPANNAGE
──────────
  ❌ "Configuration requise" au démarrage
     → Vous n'avez pas remplacé SUPABASE_URL et SUPABASE_KEY

  ❌ "Erreur backend (upsert products)"
     → Vérifiez que le schéma SQL a bien été exécuté
     → Vérifiez les policies RLS dans Supabase > Auth > Policies

  ❌ Tables vides après saisie
     → Ouvrez F12 > Console pour voir les erreurs Supabase
     → Vérifiez que la clé anon est correcte

  ❌ CORS / réseau bloqué
     → L'app doit être servie en HTTPS (pas en file://)

═══════════════════════════════════════════════════════════════
  Développé par HABATECH — Honoris Haba
  habatech2026@gmail.com · +224 627 541 925
═══════════════════════════════════════════════════════════════
