-- =========================================================
-- YConnect - Extensions "compat frontend" (PostgreSQL)
-- Fichier: sql/postgres/04_frontend_compat.sql
-- =========================================================
-- IMPORTANT: exécuter en étant connecté à la DB `school_social`

-- =========================================================
-- Skills / Compétences
-- =========================================================
CREATE TABLE IF NOT EXISTS skills (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS user_skills (
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  skill_id BIGINT NOT NULL REFERENCES skills(id) ON DELETE CASCADE ON UPDATE CASCADE,
  level skill_level NOT NULL DEFAULT 'intermediate',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, skill_id)
);
CREATE INDEX IF NOT EXISTS idx_user_skills_skill ON user_skills(skill_id);

-- =========================================================
-- Projects / Projets
-- =========================================================
CREATE TABLE IF NOT EXISTS projects (
  id BIGSERIAL PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  summary TEXT NULL,
  created_by BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  status project_status NOT NULL DEFAULT 'open',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_projects_created_by_created ON projects(created_by, created_at DESC);

CREATE TABLE IF NOT EXISTS project_members (
  project_id BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE ON UPDATE CASCADE,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  role VARCHAR(80) NULL,
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (project_id, user_id)
);
CREATE INDEX IF NOT EXISTS idx_project_members_user ON project_members(user_id);

-- =========================================================
-- Vues: Stats profil
-- Connexions = mutual follows
-- =========================================================
CREATE OR REPLACE VIEW v_profile_stats AS
SELECT
  u.id AS user_id,
  COUNT(DISTINCT p.id) AS post_count,
  COUNT(DISTINCT pm.project_id) AS project_count,
  COUNT(DISTINCT f1.followee_id) FILTER (WHERE f2.followee_id IS NOT NULL) AS connection_count
FROM users u
LEFT JOIN posts p
  ON p.author_id = u.id
LEFT JOIN project_members pm
  ON pm.user_id = u.id
LEFT JOIN follows f1
  ON f1.follower_id = u.id
LEFT JOIN follows f2
  ON f2.follower_id = f1.followee_id
 AND f2.followee_id = u.id
GROUP BY u.id;

-- =========================================================
-- Vues: Recherche
-- =========================================================
CREATE OR REPLACE VIEW v_search_students AS
SELECT
  u.id AS user_id,
  u.display_name,
  u.username,
  up.department,
  up.bio,
  up.avatar_url
FROM users u
LEFT JOIN user_profiles up ON up.user_id = u.id;

CREATE OR REPLACE VIEW v_search_projects AS
SELECT
  p.id AS project_id,
  p.title,
  p.summary,
  p.status,
  p.created_at,
  u.id AS created_by_user_id,
  u.display_name AS created_by_display_name
FROM projects p
JOIN users u ON u.id = p.created_by;

-- =========================================================
-- Vues: Messagerie (inbox)
-- =========================================================
CREATE OR REPLACE VIEW v_conversation_last_message AS
SELECT DISTINCT ON (m.conversation_id)
  m.conversation_id,
  m.id AS last_message_id,
  m.sender_id AS last_sender_id,
  m.content AS last_message_content,
  m.sent_at AS last_message_at
FROM messages m
ORDER BY m.conversation_id, m.sent_at DESC, m.id DESC;

CREATE OR REPLACE VIEW v_dm_other_member AS
SELECT
  cm1.conversation_id,
  cm1.user_id AS viewer_id,
  cm2.user_id AS other_user_id
FROM conversation_members cm1
JOIN conversation_members cm2
  ON cm2.conversation_id = cm1.conversation_id
 AND cm2.user_id <> cm1.user_id
JOIN conversations c
  ON c.id = cm1.conversation_id
 AND c.type = 'dm';

CREATE OR REPLACE VIEW v_inbox AS
SELECT
  d.viewer_id,
  d.conversation_id,
  u.display_name AS other_display_name,
  u.username AS other_username,
  up.avatar_url AS other_avatar_url,
  lm.last_message_content,
  lm.last_message_at
FROM v_dm_other_member d
JOIN users u ON u.id = d.other_user_id
LEFT JOIN user_profiles up ON up.user_id = u.id
LEFT JOIN v_conversation_last_message lm ON lm.conversation_id = d.conversation_id;

-- =========================================================
-- Données de démo (skills + projet)
-- =========================================================
INSERT INTO skills (name)
VALUES ('HTML'), ('CSS'), ('JavaScript'), ('UI Design'), ('Responsive'), ('GitHub'), ('React')
ON CONFLICT (name) DO NOTHING;

-- User 1 skills (upsert)
INSERT INTO user_skills (user_id, skill_id, level)
SELECT 1, s.id, 'advanced'::skill_level
FROM skills s
WHERE s.name IN ('HTML','CSS','JavaScript','UI Design','Responsive','GitHub')
ON CONFLICT (user_id, skill_id) DO UPDATE SET level = EXCLUDED.level;

INSERT INTO user_skills (user_id, skill_id, level)
SELECT 2, s.id, 'intermediate'::skill_level
FROM skills s
WHERE s.name IN ('JavaScript','GitHub')
ON CONFLICT (user_id, skill_id) DO UPDATE SET level = EXCLUDED.level;

INSERT INTO user_skills (user_id, skill_id, level)
SELECT 3, s.id, 'intermediate'::skill_level
FROM skills s
WHERE s.name IN ('Responsive','UI Design')
ON CONFLICT (user_id, skill_id) DO UPDATE SET level = EXCLUDED.level;

-- Projet de demo
INSERT INTO projects (id, title, summary, created_by, status, created_at)
VALUES (1, 'Projet Mobile App', 'Recherche développeur JS', 1, 'open', NOW())
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  summary = EXCLUDED.summary,
  status = EXCLUDED.status;

INSERT INTO project_members (project_id, user_id, role)
VALUES (1, 1, 'Owner')
ON CONFLICT (project_id, user_id) DO UPDATE SET role = EXCLUDED.role;

-- Fix séquences
SELECT setval(pg_get_serial_sequence('skills','id'), COALESCE((SELECT MAX(id) FROM skills), 1));
SELECT setval(pg_get_serial_sequence('projects','id'), COALESCE((SELECT MAX(id) FROM projects), 1));

