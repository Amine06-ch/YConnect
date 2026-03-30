-- =========================================================
-- YConnect - Auth / Login (PostgreSQL)
-- Fichier: sql/postgres/05_auth.sql
-- Objectif: login email+mot de passe, sessions, reset mdp, vérif email
-- =========================================================

-- IMPORTANT:
-- - Exécuter en étant connecté à la DB `school_social`
-- - Le mot de passe ne doit JAMAIS être stocké en clair.
--   Stocke un hash (bcrypt/argon2) dans `password_hash`.

-- Extensions utiles
-- - citext: email/username insensible à la casse
-- - pgcrypto: UUID + hash/token côté SQL si besoin
CREATE EXTENSION IF NOT EXISTS citext;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- =========================================================
-- Identité de connexion (email/username) liée à users
-- (On garde `users` pour les infos "profil")
-- =========================================================
CREATE TABLE IF NOT EXISTS auth_identities (
  user_id BIGINT PRIMARY KEY
    REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,

  -- login principal
  email CITEXT NULL,
  username CITEXT NULL,

  -- hash du mot de passe (bcrypt/argon2)
  password_hash TEXT NOT NULL,

  email_verified BOOLEAN NOT NULL DEFAULT FALSE,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT chk_auth_identity_login_present
    CHECK (email IS NOT NULL OR username IS NOT NULL)
);

-- Unicité (si non NULL)
CREATE UNIQUE INDEX IF NOT EXISTS uq_auth_identities_email
  ON auth_identities(email)
  WHERE email IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS uq_auth_identities_username
  ON auth_identities(username)
  WHERE username IS NOT NULL;

CREATE OR REPLACE FUNCTION auth_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_auth_identities_updated_at ON auth_identities;
CREATE TRIGGER trg_auth_identities_updated_at
BEFORE UPDATE ON auth_identities
FOR EACH ROW EXECUTE FUNCTION auth_set_updated_at();

-- =========================================================
-- Sessions (login persistant)
-- - stocke un hash du token, pas le token en clair
-- - le token "brut" est uniquement côté client
-- =========================================================
CREATE TABLE IF NOT EXISTS auth_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id BIGINT NOT NULL
    REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,

  token_hash BYTEA NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_seen_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  revoked_at TIMESTAMPTZ NULL,

  ip INET NULL,
  user_agent TEXT NULL,

  CONSTRAINT chk_auth_sessions_expires_after_created
    CHECK (expires_at > created_at)
);

-- Empêche 2 sessions avec le même token_hash
CREATE UNIQUE INDEX IF NOT EXISTS uq_auth_sessions_token_hash
  ON auth_sessions(token_hash);

CREATE INDEX IF NOT EXISTS idx_auth_sessions_user_active
  ON auth_sessions(user_id, expires_at DESC)
  WHERE revoked_at IS NULL;

-- =========================================================
-- Email verification tokens
-- - un token à usage unique
-- =========================================================
CREATE TABLE IF NOT EXISTS auth_email_verification_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id BIGINT NOT NULL
    REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,

  token_hash BYTEA NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  used_at TIMESTAMPTZ NULL,

  CONSTRAINT chk_email_verify_expires
    CHECK (expires_at > created_at)
);

CREATE INDEX IF NOT EXISTS idx_email_verify_user_active
  ON auth_email_verification_tokens(user_id, expires_at DESC)
  WHERE used_at IS NULL;

-- =========================================================
-- Password reset tokens
-- =========================================================
CREATE TABLE IF NOT EXISTS auth_password_reset_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id BIGINT NOT NULL
    REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,

  token_hash BYTEA NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  used_at TIMESTAMPTZ NULL,

  CONSTRAINT chk_pwd_reset_expires
    CHECK (expires_at > created_at)
);

CREATE INDEX IF NOT EXISTS idx_pwd_reset_user_active
  ON auth_password_reset_tokens(user_id, expires_at DESC)
  WHERE used_at IS NULL;

-- =========================================================
-- Login attempts (anti brute-force)
-- =========================================================
CREATE TABLE IF NOT EXISTS auth_login_attempts (
  id BIGSERIAL PRIMARY KEY,
  attempted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Ce que l’utilisateur a tapé (email/username), pour audit
  identifier TEXT NULL,

  user_id BIGINT NULL REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE,

  success BOOLEAN NOT NULL DEFAULT FALSE,
  ip INET NULL,
  user_agent TEXT NULL
);

CREATE INDEX IF NOT EXISTS idx_login_attempts_identifier_time
  ON auth_login_attempts(identifier, attempted_at DESC);
CREATE INDEX IF NOT EXISTS idx_login_attempts_user_time
  ON auth_login_attempts(user_id, attempted_at DESC);

-- =========================================================
-- (Optionnel) Seed minimal: copier les identifiants depuis users
-- Si tu utilises déjà users.email/username/password_hash côté app,
-- tu peux créer auth_identities à partir de users.
-- =========================================================
INSERT INTO auth_identities (user_id, email, username, password_hash, email_verified, is_active)
SELECT u.id, u.email::citext, u.username::citext, u.password_hash, FALSE, TRUE
FROM users u
WHERE NOT EXISTS (
  SELECT 1 FROM auth_identities ai WHERE ai.user_id = u.id
);

