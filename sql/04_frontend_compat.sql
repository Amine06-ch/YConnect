-- =========================================================
-- YConnect - Extensions "compat frontend" (MySQL 8)
-- Fichier: 04_frontend_compat.sql
-- Ajoute: skills, projets, vues pratiques (messagerie, stats profil)
-- =========================================================

USE school_social;

-- =========================================================
-- Skills / Compétences
-- =========================================================
CREATE TABLE IF NOT EXISTS skills (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_skills_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS user_skills (
  user_id BIGINT UNSIGNED NOT NULL,
  skill_id BIGINT UNSIGNED NOT NULL,
  level ENUM('beginner','intermediate','advanced') NOT NULL DEFAULT 'intermediate',
  created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (user_id, skill_id),
  KEY idx_user_skills_skill (skill_id),

  CONSTRAINT fk_user_skills_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

  CONSTRAINT fk_user_skills_skill
    FOREIGN KEY (skill_id) REFERENCES skills(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- Projects / Projets (pour la page search + stats "Projets")
-- =========================================================
CREATE TABLE IF NOT EXISTS projects (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  title VARCHAR(200) NOT NULL,
  summary TEXT NULL,
  created_by BIGINT UNSIGNED NOT NULL,
  status ENUM('open','in_progress','done') NOT NULL DEFAULT 'open',
  created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  KEY idx_projects_created_by (created_by, created_at),

  CONSTRAINT fk_projects_created_by
    FOREIGN KEY (created_by) REFERENCES users(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS project_members (
  project_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  role VARCHAR(80) NULL,
  joined_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (project_id, user_id),
  KEY idx_project_members_user (user_id),

  CONSTRAINT fk_project_members_project
    FOREIGN KEY (project_id) REFERENCES projects(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

  CONSTRAINT fk_project_members_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- Vues: Stats "Profil" (posts / connexions / projets)
-- Connexions = mutual follows
-- =========================================================
CREATE OR REPLACE VIEW v_profile_stats AS
SELECT
  u.id AS user_id,
  COUNT(DISTINCT p.id) AS post_count,
  COUNT(DISTINCT pm.project_id) AS project_count,
  COUNT(DISTINCT f1.followee_id) AS connection_count
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
WHERE
  -- compte uniquement les connexions mutuelles
  (f1.followee_id IS NULL OR f2.followee_id IS NOT NULL)
GROUP BY u.id;

-- =========================================================
-- Vue: Recherche "Étudiants" (nom + tagline)
-- (tagline = department + bio courte)
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

-- =========================================================
-- Vue: Recherche "Projets"
-- =========================================================
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
-- Vues: Messagerie (liste conversations + dernier message)
-- Pour afficher la liste comme dans messages.html:
-- - nom de l'autre personne (DM)
-- - dernier message
-- - heure du dernier message
-- =========================================================

-- Dernier message par conversation
CREATE OR REPLACE VIEW v_conversation_last_message AS
SELECT
  m.conversation_id,
  m.id AS last_message_id,
  m.sender_id AS last_sender_id,
  m.content AS last_message_content,
  m.sent_at AS last_message_at
FROM messages m
JOIN (
  SELECT conversation_id, MAX(sent_at) AS max_sent_at
  FROM messages
  GROUP BY conversation_id
) x
  ON x.conversation_id = m.conversation_id
 AND x.max_sent_at = m.sent_at;

-- “Autre membre” pour une DM (1-1)
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

-- Vue finale: liste des conversations pour un utilisateur
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
-- Données de démo complémentaires (skills + projets)
-- (idempotent via INSERT IGNORE / ON DUPLICATE)
-- =========================================================
INSERT IGNORE INTO skills (name) VALUES
  ('HTML'), ('CSS'), ('JavaScript'), ('UI Design'), ('Responsive'), ('GitHub'), ('React');

-- Associer quelques skills aux users (demo)
INSERT INTO user_skills (user_id, skill_id, level)
SELECT 1, s.id, 'advanced' FROM skills s WHERE s.name IN ('HTML','CSS','JavaScript','UI Design','Responsive','GitHub')
ON DUPLICATE KEY UPDATE level = VALUES(level);

INSERT INTO user_skills (user_id, skill_id, level)
SELECT 2, s.id, 'intermediate' FROM skills s WHERE s.name IN ('JavaScript','GitHub')
ON DUPLICATE KEY UPDATE level = VALUES(level);

INSERT INTO user_skills (user_id, skill_id, level)
SELECT 3, s.id, 'intermediate' FROM skills s WHERE s.name IN ('Responsive','UI Design')
ON DUPLICATE KEY UPDATE level = VALUES(level);

-- Projets de demo
INSERT INTO projects (id, title, summary, created_by, status, created_at)
VALUES
  (1, 'Projet Mobile App', 'Recherche développeur JS', 1, 'open', NOW(6))
ON DUPLICATE KEY UPDATE title = VALUES(title), summary = VALUES(summary), status = VALUES(status);

INSERT INTO project_members (project_id, user_id, role)
VALUES
  (1, 1, 'Owner')
ON DUPLICATE KEY UPDATE role = VALUES(role);

