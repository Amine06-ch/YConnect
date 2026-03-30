-- =========================================================
-- School Social Network - Schéma (MySQL 8)
-- Fichier: 01_schema.sql
-- =========================================================

SET NAMES utf8mb4;
SET sql_mode = 'STRICT_ALL_TABLES';

CREATE DATABASE IF NOT EXISTS school_social
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE school_social;

-- Permet la recreation sans erreurs de dependances
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS post_media;
DROP TABLE IF EXISTS comment_likes;
DROP TABLE IF EXISTS post_likes;
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS events_rsvps;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS conversation_members;
DROP TABLE IF EXISTS conversations;
DROP TABLE IF EXISTS group_memberships;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS groups;
DROP TABLE IF EXISTS follows;
DROP TABLE IF EXISTS user_profiles;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

-- =========================================================
-- Users
-- =========================================================
CREATE TABLE users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  email VARCHAR(255) NOT NULL,
  username VARCHAR(50) NOT NULL,
  display_name VARCHAR(100) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email),
  UNIQUE KEY uq_users_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Profil et infos supplementaires
CREATE TABLE user_profiles (
  user_id BIGINT UNSIGNED NOT NULL,
  bio TEXT NULL,
  avatar_url VARCHAR(500) NULL,
  school VARCHAR(150) NULL,
  department VARCHAR(150) NULL,

  created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (user_id),
  CONSTRAINT fk_profiles_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- Follows (abonnements)
-- =========================================================
CREATE TABLE follows (
  follower_id BIGINT UNSIGNED NOT NULL,
  followee_id BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (follower_id, followee_id),
  KEY idx_follows_followee (followee_id),
  KEY idx_follows_follower (follower_id),

  CONSTRAINT fk_follows_follower
    FOREIGN KEY (follower_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

  CONSTRAINT fk_follows_followee
    FOREIGN KEY (followee_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

  CONSTRAINT chk_no_self_follow
    CHECK (follower_id <> followee_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- Groups / Groupes
-- =========================================================
CREATE TABLE groups (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(150) NOT NULL,
  description TEXT NULL,
  created_by BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  UNIQUE KEY uq_groups_name (name),
  KEY idx_groups_created_by (created_by),

  CONSTRAINT fk_groups_created_by
    FOREIGN KEY (created_by) REFERENCES users(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE group_memberships (
  group_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  role ENUM('member','admin') NOT NULL DEFAULT 'member',
  status ENUM('active','banned','left') NOT NULL DEFAULT 'active',
  joined_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (group_id, user_id),
  KEY idx_group_memberships_user (user_id),

  CONSTRAINT fk_group_memberships_group
    FOREIGN KEY (group_id) REFERENCES groups(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

  CONSTRAINT fk_group_memberships_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- Posts (contenus) + media + visibilite
-- =========================================================
CREATE TABLE posts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  author_id BIGINT UNSIGNED NOT NULL,
  visibility ENUM('public','private','friends','group') NOT NULL DEFAULT 'public',

  -- Utilise si visibility = 'group'
  group_id BIGINT UNSIGNED NULL,

  content TEXT NOT NULL,
  created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  KEY idx_posts_author (author_id, created_at),
  KEY idx_posts_group (group_id),

  CONSTRAINT fk_posts_author
    FOREIGN KEY (author_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

  CONSTRAINT fk_posts_group
    FOREIGN KEY (group_id) REFERENCES groups(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE,

  CONSTRAINT chk_posts_visibility_group
    CHECK (visibility <> 'group' OR group_id IS NOT NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE post_media (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  post_id BIGINT UNSIGNED NOT NULL,
  media_type ENUM('image','video','link') NOT NULL DEFAULT 'image',
  media_url VARCHAR(500) NOT NULL,
  sort_order INT UNSIGNED NOT NULL DEFAULT 0,

  created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  KEY idx_post_media_post (post_id, sort_order),

  CONSTRAINT fk_post_media_post
    FOREIGN KEY (post_id) REFERENCES posts(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- Comments (commentaires) avec reponses
-- =========================================================
CREATE TABLE comments (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  post_id BIGINT UNSIGNED NOT NULL,
  author_id BIGINT UNSIGNED NOT NULL,
  parent_comment_id BIGINT UNSIGNED NULL, -- NULL = commentaire parent

  content TEXT NOT NULL,
  created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  KEY idx_comments_post (post_id, created_at),
  KEY idx_comments_author (author_id, created_at),

  CONSTRAINT fk_comments_post
    FOREIGN KEY (post_id) REFERENCES posts(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

  CONSTRAINT fk_comments_author
    FOREIGN KEY (author_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

  CONSTRAINT fk_comments_parent
    FOREIGN KEY (parent_comment_id) REFERENCES comments(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- Likes (likes sur posts et commentaires)
-- =========================================================
CREATE TABLE post_likes (
  user_id BIGINT UNSIGNED NOT NULL,
  post_id BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (user_id, post_id),
  KEY idx_post_likes_post (post_id),

  CONSTRAINT fk_post_likes_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

  CONSTRAINT fk_post_likes_post
    FOREIGN KEY (post_id) REFERENCES posts(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE comment_likes (
  user_id BIGINT UNSIGNED NOT NULL,
  comment_id BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (user_id, comment_id),
  KEY idx_comment_likes_comment (comment_id),

  CONSTRAINT fk_comment_likes_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

  CONSTRAINT fk_comment_likes_comment
    FOREIGN KEY (comment_id) REFERENCES comments(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- Events + RSVPs
-- =========================================================
CREATE TABLE events (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  group_id BIGINT UNSIGNED NULL,
  created_by BIGINT UNSIGNED NOT NULL,

  title VARCHAR(200) NOT NULL,
  description TEXT NULL,
  location VARCHAR(200) NULL,

  starts_at DATETIME(6) NOT NULL,
  ends_at DATETIME(6) NULL,

  created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  KEY idx_events_group (group_id, starts_at),
  KEY idx_events_created_by (created_by, starts_at),

  CONSTRAINT fk_events_group
    FOREIGN KEY (group_id) REFERENCES groups(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE,

  CONSTRAINT fk_events_created_by
    FOREIGN KEY (created_by) REFERENCES users(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE events_rsvps (
  user_id BIGINT UNSIGNED NOT NULL,
  event_id BIGINT UNSIGNED NOT NULL,
  status ENUM('going','interested','not_going') NOT NULL DEFAULT 'interested',
  responded_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (user_id, event_id),
  KEY idx_events_rsvps_event (event_id),

  CONSTRAINT fk_events_rsvps_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

  CONSTRAINT fk_events_rsvps_event
    FOREIGN KEY (event_id) REFERENCES events(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================
-- Messaging (DM) - Conversations + Messages
-- =========================================================
CREATE TABLE conversations (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  type ENUM('dm','group') NOT NULL DEFAULT 'dm',
  created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  KEY idx_conversations_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE conversation_members (
  conversation_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  role ENUM('member','admin') NOT NULL DEFAULT 'member',
  joined_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (conversation_id, user_id),
  KEY idx_conversation_members_user (user_id),

  CONSTRAINT fk_conversation_members_conversation
    FOREIGN KEY (conversation_id) REFERENCES conversations(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

  CONSTRAINT fk_conversation_members_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE messages (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  conversation_id BIGINT UNSIGNED NOT NULL,
  sender_id BIGINT UNSIGNED NOT NULL,

  message_type ENUM('text','attachment') NOT NULL DEFAULT 'text',
  content TEXT NULL,
  attachment_url VARCHAR(500) NULL,

  sent_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  KEY idx_messages_conversation_sent (conversation_id, sent_at),
  KEY idx_messages_sender_sent (sender_id, sent_at),

  CONSTRAINT fk_messages_conversation
    FOREIGN KEY (conversation_id) REFERENCES conversations(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

  CONSTRAINT fk_messages_sender
    FOREIGN KEY (sender_id) REFERENCES users(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Fin schéma
