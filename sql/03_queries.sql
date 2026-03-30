-- =========================================================
-- School Social Network - Requetes utiles (MySQL 8)
-- Fichier: 03_queries.sql
-- =========================================================

USE school_social;

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
-- 1) Statistiques posts (likes)
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
SET @viewer_id = 1;

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
WHERE
  -- Public
  p.visibility = 'public'

  -- Private: visible uniquement par l'auteur
  OR (p.visibility = 'private' AND p.author_id = @viewer_id)

  -- Friends: mutual follows
  OR (
    p.visibility = 'friends'
    AND EXISTS (
      SELECT 1
      FROM follows f1
      WHERE f1.follower_id = @viewer_id
        AND f1.followee_id = p.author_id
    )
    AND EXISTS (
      SELECT 1
      FROM follows f2
      WHERE f2.follower_id = p.author_id
        AND f2.followee_id = @viewer_id
    )
  )

  -- Group: membership active
  OR (
    p.visibility = 'group'
    AND EXISTS (
      SELECT 1
      FROM group_memberships gm
      WHERE gm.group_id = p.group_id
        AND gm.user_id = @viewer_id
        AND gm.status = 'active'
    )
  )
ORDER BY p.created_at DESC;

-- =========================================================
-- 3) Commentaires d'un post + likes (threads simples)
-- =========================================================
SET @post_id = 1;

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
WHERE c.post_id = @post_id
ORDER BY c.created_at ASC;

-- =========================================================
-- 4) Discussions (conversations) auxquelles un utilisateur participe
-- =========================================================
SET @dm_user_id = 1;

SELECT
  c.id AS conversation_id,
  c.type,
  c.created_at,
  COUNT(m.id) AS message_count,
  MAX(m.sent_at) AS last_message_at
FROM conversations c
JOIN conversation_members cm
  ON cm.conversation_id = c.id
LEFT JOIN messages m
  ON m.conversation_id = c.id
WHERE cm.user_id = @dm_user_id
GROUP BY c.id, c.type, c.created_at
ORDER BY last_message_at DESC;

