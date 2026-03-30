-- =========================================================
-- School Social Network - Requêtes utiles (PostgreSQL)
-- Fichier: sql/postgres/03_queries.sql
-- =========================================================
-- IMPORTANT: exécuter en étant connecté à la DB `school_social`

-- =========================================================
-- Vues: compte de likes
-- =========================================================
CREATE OR REPLACE VIEW v_post_like_counts AS
SELECT
  post_id,
  COUNT(*) AS like_count
FROM post_likes
GROUP BY post_id;

CREATE OR REPLACE VIEW v_comment_like_counts AS
SELECT
  comment_id,
  COUNT(*) AS like_count
FROM comment_likes
GROUP BY comment_id;

-- =========================================================
-- 1) Posts + likes
-- =========================================================
SELECT
  p.id,
  u.username,
  p.visibility,
  p.created_at,
  p.content,
  COALESCE(plc.like_count, 0) AS like_count
FROM posts p
JOIN users u ON u.id = p.author_id
LEFT JOIN v_post_like_counts plc ON plc.post_id = p.id
ORDER BY p.created_at DESC;

-- =========================================================
-- 2) Feed d'un utilisateur (amis = mutual follows)
-- =========================================================
-- Remplace 1 par l'id du viewer
WITH params AS (SELECT 1::bigint AS viewer_id)
SELECT
  p.id,
  u.username AS author_username,
  p.visibility,
  g.name AS group_name,
  p.created_at,
  p.content,
  COALESCE(plc.like_count, 0) AS like_count
FROM posts p
JOIN users u ON u.id = p.author_id
LEFT JOIN groups g ON g.id = p.group_id
LEFT JOIN v_post_like_counts plc ON plc.post_id = p.id
CROSS JOIN params
WHERE
  p.visibility = 'public'
  OR (p.visibility = 'private' AND p.author_id = params.viewer_id)
  OR (
    p.visibility = 'friends'
    AND EXISTS (
      SELECT 1
      FROM follows f1
      WHERE f1.follower_id = params.viewer_id
        AND f1.followee_id = p.author_id
    )
    AND EXISTS (
      SELECT 1
      FROM follows f2
      WHERE f2.follower_id = p.author_id
        AND f2.followee_id = params.viewer_id
    )
  )
  OR (
    p.visibility = 'group'
    AND EXISTS (
      SELECT 1
      FROM group_memberships gm
      WHERE gm.group_id = p.group_id
        AND gm.user_id = params.viewer_id
        AND gm.status = 'active'
    )
  )
ORDER BY p.created_at DESC;

-- =========================================================
-- 3) Commentaires d'un post
-- =========================================================
-- Remplace 1 par l'id du post
WITH params AS (SELECT 1::bigint AS post_id)
SELECT
  c.id,
  u.username AS author_username,
  c.parent_comment_id,
  c.created_at,
  c.content,
  COALESCE(clc.like_count, 0) AS like_count
FROM comments c
JOIN users u ON u.id = c.author_id
LEFT JOIN v_comment_like_counts clc ON clc.comment_id = c.id
CROSS JOIN params
WHERE c.post_id = params.post_id
ORDER BY c.created_at ASC;

-- =========================================================
-- 4) Inbox via vue (si 04_frontend_compat.sql est exécuté)
-- =========================================================
-- Cette partie nécessite la vue `v_inbox` créée dans:
--   sql/postgres/04_frontend_compat.sql
--
-- Si tu n’as pas encore exécuté `04_frontend_compat.sql`, commente ce bloc.
-- Remplace 1 par l'id du viewer.
--
-- SELECT *
-- FROM v_inbox
-- WHERE viewer_id = 1
-- ORDER BY last_message_at DESC NULLS LAST;

