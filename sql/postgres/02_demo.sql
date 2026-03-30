-- =========================================================
-- School Social Network - Données de demo (PostgreSQL)
-- Fichier: sql/postgres/02_demo.sql
-- =========================================================
-- IMPORTANT: exécuter en étant connecté à la DB `school_social`

BEGIN;

-- Users (IDs explicites pour la demo)
INSERT INTO users (id, email, username, display_name, password_hash)
VALUES
  (1, 'alice@ecole.test', 'alice', 'Alice Martin', 'hash_alice'),
  (2, 'bob@ecole.test', 'bob', 'Bob Dubois', 'hash_bob'),
  (3, 'clara@ecole.test', 'clara', 'Clara Nguyen', 'hash_clara')
ON CONFLICT (id) DO NOTHING;

INSERT INTO user_profiles (user_id, bio, avatar_url, school, department)
VALUES
  (1, 'Passionnee de dev et de reseautage.', 'https://example.com/avatars/alice.png', 'Ecole Centrale', 'Informatique'),
  (2, 'Aime les projets de groupe et les event.', 'https://example.com/avatars/bob.png', 'Ecole Centrale', 'Gestion'),
  (3, 'Sport et dev: team mixte.', 'https://example.com/avatars/clara.png', 'Ecole Centrale', 'Sport & SI')
ON CONFLICT (user_id) DO NOTHING;

-- Follows
INSERT INTO follows (follower_id, followee_id)
VALUES
  (1, 2),
  (2, 1),
  (1, 3)
ON CONFLICT DO NOTHING;

-- Groups
INSERT INTO groups (id, name, description, created_by, created_at)
VALUES
  (1, 'Club Dev', 'On construit des projets pour l ecole.', 1, NOW()),
  (2, 'Club Sport', 'Evenements sportifs et challenges.', 3, NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO group_memberships (group_id, user_id, role, status, joined_at)
VALUES
  (1, 1, 'admin', 'active', NOW()),
  (1, 2, 'member', 'active', NOW()),
  (2, 3, 'admin', 'active', NOW())
ON CONFLICT DO NOTHING;

-- Posts
INSERT INTO posts (id, author_id, visibility, group_id, content, created_at, updated_at)
VALUES
  (1, 1, 'public', NULL, 'Bonjour tout le monde ! Nouveau projet au Club Dev.', NOW(), NOW()),
  (2, 2, 'friends', NULL, 'Qui est partant pour une session de dev ce week-end ?', NOW(), NOW()),
  (3, 3, 'group', 2, 'Challenge sport du mois: objectifs et entrainement.', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO post_media (id, post_id, media_type, media_url, sort_order, created_at)
VALUES
  (1, 1, 'image', 'https://example.com/media/post1_img1.png', 0, NOW()),
  (2, 1, 'link', 'https://example.com/project/club-dev', 1, NOW())
ON CONFLICT (id) DO NOTHING;

-- Comments
INSERT INTO comments (id, post_id, author_id, parent_comment_id, content, created_at)
VALUES
  (1, 1, 2, NULL, 'Super idee ! On peut partager des tickets ici.', NOW()),
  (2, 1, 1, 1, 'Oui ! Je creerai un board et on avancera.', NOW()),
  (3, 1, 3, NULL, 'Je peux aider pour l UI.', NOW())
ON CONFLICT (id) DO NOTHING;

-- Likes
INSERT INTO post_likes (user_id, post_id, created_at)
VALUES
  (2, 1, NOW()),
  (3, 1, NOW())
ON CONFLICT DO NOTHING;

INSERT INTO comment_likes (user_id, comment_id, created_at)
VALUES
  (1, 1, NOW()),
  (2, 3, NOW())
ON CONFLICT DO NOTHING;

-- Events
INSERT INTO events (id, group_id, created_by, title, description, location, starts_at, ends_at, created_at)
VALUES
  (1, 1, 1, 'Hackathon mini', '2h pour prototyper une idee.', 'Salle B-12',
   '2026-04-05 14:00:00+02', '2026-04-05 16:00:00+02', NOW()),
  (2, 2, 3, 'Challenge footing', 'Course + etirements + brief objectifs.', 'Terrain nord',
   '2026-04-06 09:00:00+02', NULL, NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO events_rsvps (user_id, event_id, status, responded_at)
VALUES
  (1, 1, 'going', NOW()),
  (2, 1, 'interested', NOW()),
  (3, 2, 'going', NOW())
ON CONFLICT DO NOTHING;

-- Messaging
INSERT INTO conversations (id, type, created_at)
VALUES
  (1, 'dm', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO conversation_members (conversation_id, user_id, role, joined_at)
VALUES
  (1, 1, 'admin', NOW()),
  (1, 2, 'member', NOW())
ON CONFLICT DO NOTHING;

INSERT INTO messages (id, conversation_id, sender_id, message_type, content, attachment_url, sent_at)
VALUES
  (1, 1, 1, 'text', 'Salut Bob ! On se voit pour le hackathon ?', NULL, NOW()),
  (2, 1, 2, 'text', 'Yes ! Je suis chaud. Je prends un sujet en backend.', NULL, NOW())
ON CONFLICT (id) DO NOTHING;

-- Fix séquences (si on insère des IDs explicites)
SELECT setval(pg_get_serial_sequence('users','id'), COALESCE((SELECT MAX(id) FROM users), 1));
SELECT setval(pg_get_serial_sequence('groups','id'), COALESCE((SELECT MAX(id) FROM groups), 1));
SELECT setval(pg_get_serial_sequence('posts','id'), COALESCE((SELECT MAX(id) FROM posts), 1));
SELECT setval(pg_get_serial_sequence('post_media','id'), COALESCE((SELECT MAX(id) FROM post_media), 1));
SELECT setval(pg_get_serial_sequence('comments','id'), COALESCE((SELECT MAX(id) FROM comments), 1));
SELECT setval(pg_get_serial_sequence('events','id'), COALESCE((SELECT MAX(id) FROM events), 1));
SELECT setval(pg_get_serial_sequence('conversations','id'), COALESCE((SELECT MAX(id) FROM conversations), 1));
SELECT setval(pg_get_serial_sequence('messages','id'), COALESCE((SELECT MAX(id) FROM messages), 1));

COMMIT;

