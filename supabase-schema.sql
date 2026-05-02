-- ================================================================
--  MOTEL LE DESTIN LERO — Schéma Supabase v11
--  HABATECH © 2025
--  Exécutez ce script dans : Supabase > SQL Editor > New query
-- ================================================================

-- ──────────────────────────────────────────────────────────────
--  TABLE : products
-- ──────────────────────────────────────────────────────────────
create table if not exists products (
  id            text primary key,
  name          text not null,
  category      text default 'Autre',
  current_stock integer default 0,
  magasin_stock integer default 0,
  min_stock     integer default 5,
  unit          text default 'bouteille',
  price         integer default 0,
  created_at    timestamptz default now()
);

-- ──────────────────────────────────────────────────────────────
--  TABLE : mouvements (entrées/sorties stock)
-- ──────────────────────────────────────────────────────────────
create table if not exists mouvements (
  id         text primary key,
  ts         bigint,
  date_str   text,
  product    text,
  unit       text,
  type       text,   -- 'entree' | 'sortie' | 'transfer' | 'mag-entree' | 'achat-magasin' | 'achat-comptoir'
  qty        integer default 0,
  ca         integer default 0,
  cost       integer default 0,
  created_at timestamptz default now()
);

-- ──────────────────────────────────────────────────────────────
--  TABLE : achats (achats & dépenses)
-- ──────────────────────────────────────────────────────────────
create table if not exists achats (
  id          text primary key,
  ts          bigint,
  date_str    text,
  product_id  text references products(id) on delete set null,
  product     text,
  unit        text,
  qty         integer default 0,
  pu          integer default 0,
  total_cost  integer default 0,
  fournisseur text,
  destination text,   -- 'magasin' | 'comptoir'
  note        text,
  created_at  timestamptz default now()
);

-- ──────────────────────────────────────────────────────────────
--  TABLE : caisse_ops (opérations caisse)
-- ──────────────────────────────────────────────────────────────
create table if not exists caisse_ops (
  id         text primary key,
  ts         bigint,
  date_str   text,
  type       text check (type in ('entree', 'sortie')),
  montant    integer default 0,
  motif      text,
  source     text,   -- 'vente' | 'achat' | 'manuel' | 'hebergement' | 'fond'
  created_at timestamptz default now()
);

-- ──────────────────────────────────────────────────────────────
--  TABLE : caisse_config (fond de caisse — ligne unique)
-- ──────────────────────────────────────────────────────────────
create table if not exists caisse_config (
  id   integer primary key default 1,
  fond integer default 0,
  constraint single_row check (id = 1)
);
-- Ligne initiale
insert into caisse_config (id, fond) values (1, 0)
  on conflict (id) do nothing;

-- ──────────────────────────────────────────────────────────────
--  TABLE : depots (dépôt boisson / consignes)
-- ──────────────────────────────────────────────────────────────
create table if not exists depots (
  id          text primary key,
  ts          bigint,
  fournisseur text,
  produit     text,
  qty         integer default 0,
  pu          integer default 0,
  date_str    text,
  remarque    text,
  statut      text default 'en-cours',   -- 'en-cours' | 'rendu' | 'partiel'
  qty_rendue  integer default 0,
  date_retour text,
  created_at  timestamptz default now()
);

-- ──────────────────────────────────────────────────────────────
--  TABLE : chambres
-- ──────────────────────────────────────────────────────────────
create table if not exists chambres (
  id           text primary key,
  num          text,
  type         text,    -- 'simple' | 'double' | 'suite' | etc.
  tarif        integer default 0,
  description  text,
  statut       text default 'libre',   -- 'libre' | 'occupee' | 'maintenance'
  client       text,
  date_arrivee text,
  date_depart  text,
  note         text
);

-- ──────────────────────────────────────────────────────────────
--  TABLE : sejours (historique hébergement)
-- ──────────────────────────────────────────────────────────────
create table if not exists sejours (
  id             text primary key,
  ts             bigint,
  chambre_id     text references chambres(id) on delete set null,
  chambre_num    text,
  client         text,
  date_arrivee   text,
  date_depart    text,
  nuits          integer default 0,
  tarif          integer default 0,
  montant        integer default 0,
  mode_paiement  text,   -- 'especes' | 'mobile' | 'virement' | 'credit'
  note           text,
  created_at     timestamptz default now()
);

-- ──────────────────────────────────────────────────────────────
--  TABLE : pins (accès multi-rôles — ligne unique)
-- ──────────────────────────────────────────────────────────────
create table if not exists pins (
  id     integer primary key default 1,
  admin  text default '',
  gerant text default '',
  dg     text default '',
  constraint single_row check (id = 1)
);
-- Ligne initiale
insert into pins (id, admin, gerant, dg) values (1, '', '', '')
  on conflict (id) do nothing;

-- ================================================================
--  ROW LEVEL SECURITY (RLS)
--  Activez RLS et configurez selon vos besoins de sécurité.
--  Pour un usage interne (réseau local / personnel), vous pouvez
--  utiliser des policies permissives avec la clé anon.
-- ================================================================

-- Activer RLS sur toutes les tables
alter table products     enable row level security;
alter table mouvements   enable row level security;
alter table achats       enable row level security;
alter table caisse_ops   enable row level security;
alter table caisse_config enable row level security;
alter table depots       enable row level security;
alter table chambres     enable row level security;
alter table sejours      enable row level security;
alter table pins         enable row level security;

-- ── OPTION A : Accès total avec clé anon (usage interne / personnel) ──
-- Décommentez ce bloc si vous utilisez l'app en interne sans auth Supabase

create policy "anon_all_products"      on products      for all using (true) with check (true);
create policy "anon_all_mouvements"    on mouvements    for all using (true) with check (true);
create policy "anon_all_achats"        on achats        for all using (true) with check (true);
create policy "anon_all_caisse_ops"    on caisse_ops    for all using (true) with check (true);
create policy "anon_all_caisse_config" on caisse_config for all using (true) with check (true);
create policy "anon_all_depots"        on depots        for all using (true) with check (true);
create policy "anon_all_chambres"      on chambres      for all using (true) with check (true);
create policy "anon_all_sejours"       on sejours       for all using (true) with check (true);
create policy "anon_all_pins"          on pins          for all using (true) with check (true);

-- ================================================================
--  INDEX (performances)
-- ================================================================
create index if not exists idx_mouvements_ts   on mouvements   (ts desc);
create index if not exists idx_achats_ts        on achats        (ts desc);
create index if not exists idx_caisse_ops_ts    on caisse_ops    (ts desc);
create index if not exists idx_sejours_ts       on sejours       (ts desc);
create index if not exists idx_depots_ts        on depots        (ts desc);
create index if not exists idx_achats_product   on achats        (product_id);
create index if not exists idx_sejours_chambre  on sejours       (chambre_id);

-- ================================================================
--  FIN DU SCRIPT
--  Après exécution : vérifiez dans Table Editor que les 9 tables
--  sont créées avec leurs colonnes.
-- ================================================================
