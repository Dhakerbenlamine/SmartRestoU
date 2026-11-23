CREATE TABLE IF NOT EXISTS app_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nom TEXT NOT NULL,
  email TEXT NOT NULL,
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'etudiant'
    CHECK (role IN ('etudiant', 'admin')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS app_users_email_lower_unique
  ON app_users (LOWER(email));

CREATE TABLE IF NOT EXISTS menus (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nom TEXT NOT NULL,
  description TEXT NOT NULL,
  regime TEXT NOT NULL
    CHECK (regime IN ('Standard', 'Vegan', 'Sans gluten')),
  type TEXT NOT NULL
    CHECK (type IN ('Menu du jour', 'Menu semaine')),
  date DATE NOT NULL,
  disponible BOOLEAN NOT NULL DEFAULT TRUE,
  image TEXT
);

CREATE INDEX IF NOT EXISTS menus_date_idx ON menus (date);
