-- =========================================================
-- School Social Network - Donnees de demo (MySQL 8)
-- Fichier: 02_demo.sql
-- =========================================================

USE school_social;

SET FOREIGN_KEY_CHECKS = 1;

START TRANSACTION;

-- Users (id explicites pour la demo)
INSERT INTO users (id, email, username, display_name, password_hash)
VALUES
  (1, 'alice@ecole.test', 'alice', 'Alice Martin', 'hash_alice'),
  (2, 'bob@ecole.test', 'bob', 'Bob Dubois', 'hash_bob'),
  (3, 'clara@ecole.test', 'clara', 'Clara Nguyen', 'hash_clara');

INSERT INTO user_profiles (user_id, bio, avatar_url, school, department)
VALUES
  (1, 'Passionnee de dev et de reseautage.', 'https://example.com/avatars/alice.png', 'Ecole Centrale', 'Informatique'),
  (2, 'Aime les projets de groupe et les events.', 'https://example.com/avatars/bob.png', 'Ecole Centrale', 'Gestion'),
  (3, 'Sport et dev: team mixte.', 'https://example.com/avatars/clara.png', 'Ecole Centrale', 'Sport & SI');

-- Follows
INSERT INTO follows (follower_id, followee_id)
VALUES
  (1, 2), -- Alice suit Bob
  (2, 1), -- Bob suit Alice (mutuel)
  (1, 3); -- Alice suit Clara

-- Groups
INSERT INTO groups (id, name, description, created_by, created_at)
VALUES
  (1, 'Club Dev', 'On construit des projets pour l ecole.', 1, NOW(6)),
  (2, 'Club Sport', 'Evenements sportifs et challenges.', 3, NOW(6));

INSERT INTO group_memberships (group_id, user_id, role, status, joined_at)
VALUES
  (1, 1, 'admin', 'active', NOW(6)),
  (1, 2, 'member', 'active', NOW(6)),
  (2, 3, 'admin', 'active', NOW(6));

-- Posts
INSERT INTO posts (id, author_id, visibility, group_id, content, created_at, updated_at)
VALUES
  (1, 1, 'public', NULL, 'Bonjour tout le monde ! Nouveau projet au Club Dev.', NOW(6), NOW(6)),
  (2, 2, 'friends', NULL, 'Qui est partant pour une session de dev ce week-end ?', NOW(6), NOW(6)),
  (3, 3, 'group', 2, 'Challenge sport du mois: objectifs et entrainement.', NOW(6), NOW(6));

INSERT INTO post_media (id, post_id, media_type, media_url, sort_order, created_at)
VALUES
  (1, 1, 'image', 'https://example.com/media/post1_img1.png', 0, NOW(6)),
  (2, 1, 'link', 'https://example.com/project/club-dev', 1, NOW(6));

-- Comments (sur post 1)
INSERT INTO comments (id, post_id, author_id, parent_comment_id, content, created_at)
VALUES
  (1, 1, 2, NULL, 'Super idee ! On peut partager des tickets ici.', NOW(6)),
  (2, 1, 1, 1, 'Oui ! Je creerai un board et on avancera.', NOW(6)),
  (3, 1, 3, NULL, 'Je peux aider pour l UI.', NOW(6));

-- Likes
INSERT INTO post_likes (user_id, post_id, created_at)
VALUES
  (2, 1, NOW(6)),
  (3, 1, NOW(6));

INSERT INTO comment_likes (user_id, comment_id, created_at)
VALUES
  (1, 1, NOW(6)), -- Alice like le commentaire de Bob
  (2, 3, NOW(6)); -- Bob like le commentaire de Clara

-- Events
INSERT INTO events (id, group_id, created_by, title, description, location, starts_at, ends_at, created_at)
VALUES
  (1, 1, 1, 'Hackathon mini', '2h pour prototyper une idee.', 'Salle B-12',
   '2026-04-05 14:00:00.000000', '2026-04-05 16:00:00.000000', NOW(6)),
  (2, 2, 3, 'Challenge footing', 'Course + etirements + brief objectifs.', 'Terrain nord',
   '2026-04-06 09:00:00.000000', NULL, NOW(6));

INSERT INTO events_rsvps (user_id, event_id, status, responded_at)
VALUES
  (1, 1, 'going', NOW(6)),
  (2, 1, 'interested', NOW(6)),
  (3, 2, 'going', NOW(6));

-- Messaging (DM: Alice <-> Bob)
INSERT INTO conversations (id, type, created_at)
VALUES
  (1, 'dm', NOW(6));

INSERT INTO conversation_members (conversation_id, user_id, role, joined_at)
VALUES
  (1, 1, 'admin', NOW(6)),
  (1, 2, 'member', NOW(6));

INSERT INTO messages (id, conversation_id, sender_id, message_type, content, attachment_url, sent_at)
VALUES
  (1, 1, 1, 'text', 'Salut Bob ! On se voit pour le hackathon ?', NULL, NOW(6)),
  (2, 1, 2, 'text', 'Yes ! Je suis chaud. Je prends un sujet en backend.', NULL, NOW(6));

COMMIT;

