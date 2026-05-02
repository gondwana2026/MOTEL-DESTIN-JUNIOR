-- ══════════════════════════════════════════════════════
--  MOTEL DESTIN APP v10 — Schéma Supabase
--  Projet : hjnqcpwsyskrqybkjadr.supabase.co
--  Coller dans SQL Editor → Run ▶️
-- ══════════════════════════════════════════════════════

-- 1. PRODUITS (stock comptoir)
create table if not exists products (
  id            text primary key,
  name          text not null,
  category      text default 'Autre',
  current_stock integer default 0,
  magasin_stock integer default 0,
  min_stock     integer default 5,
  unit          text default 'bouteille',
  price         integer default 0
);

-- 2. MOUVEMENTS DE STOCK
create table if not exists mouvements (
  id       text primary key,
  ts       bigint default extract(epoch from now())*1000,
  date_str text,
  product  text,
  unit     text,
  type     text,
  qty      integer default 0,
  ca       integer default 0,
  cost     integer default 0
);

-- 3. ACHATS FOURNISSEURS
create table if not exists achats (
  id          text primary key,
  ts          bigint default extract(epoch from now())*1000,
  date_str    text,
  product_id  text,
  product     text,
  unit        text,
  qty         integer default 0,
  pu          integer default 0,
  total_cost  integer default 0,
  fournisseur text,
  destination text,
  note        text
);

-- 4. CAISSE — OPÉRATIONS
create table if not exists caisse_ops (
  id       text primary key,
  ts       bigint default extract(epoch from now())*1000,
  date_str text,
  type     text,
  montant  integer default 0,
  motif    text,
  source   text default 'manuel'
);

-- 5. CAISSE — CONFIGURATION (fond de caisse)
create table if not exists caisse_config (
  id   integer primary key default 1,
  fond integer default 0
);
insert into caisse_config (id, fond) values (1, 0)
on conflict (id) do nothing;

-- 6. DÉPÔTS BOISSON
create table if not exists depots (
  id          text primary key,
  ts          bigint default extract(epoch from now())*1000,
  fournisseur text,
  produit     text,
  qty         integer default 0,
  pu          integer default 0,
  date_str    text,
  remarque    text,
  statut      text default 'en-cours',
  qty_rendue  integer default 0,
  date_retour text
);

-- 7. CHAMBRES
create table if not exists chambres (
  id           text primary key,
  num          text,
  type         text default 'simple',
  tarif        integer default 0,
  description  text,
  statut       text default 'libre',
  client       text,
  date_arrivee text,
  date_depart  text,
  note         text
);

-- 8. SÉJOURS (historique hébergement)
create table if not exists sejours (
  id            text primary key,
  ts            bigint default extract(epoch from now())*1000,
  chambre_id    text,
  chambre_num   text,
  client        text,
  date_arrivee  text,
  date_depart   text,
  nuits         integer default 0,
  tarif         integer default 0,
  montant       integer default 0,
  mode_paiement text,
  note          text
);

-- 9. PINS (authentification rôles)
create table if not exists pins (
  id     integer primary key default 1,
  admin  text default '',
  gerant text default '',
  dg     text default ''
);
insert into pins (id) values (1)
on conflict (id) do nothing;

-- ══ Désactiver RLS (accès via anon key) ══
alter table products      disable row level security;
alter table mouvements    disable row level security;
alter table achats        disable row level security;
alter table caisse_ops    disable row level security;
alter table caisse_config disable row level security;
alter table depots        disable row level security;
alter table chambres      disable row level security;
alter table sejours       disable row level security;
alter table pins          disable row level security;

-- ══ Index pour performances ══
create index if not exists idx_mouvements_ts on mouvements(ts desc);
create index if not exists idx_achats_ts     on achats(ts desc);
create index if not exists idx_caisse_ts     on caisse_ops(ts desc);
create index if not exists idx_depots_ts     on depots(ts desc);
create index if not exists idx_sejours_ts    on sejours(ts desc);
