-- =========================================================
-- School Social Network - Schéma (PostgreSQL)
-- Fichier: sql/postgres/01_schema.sql
-- =========================================================

-- IMPORTANT:
-- Ce fichier est du SQL pur (compatible avec la plupart des outils).
-- Tu dois exécuter `00_create_db.sql` une fois, puis te CONNECTER à la DB `school_social`,
-- ensuite exécuter ce fichier.

SET client_encoding TO 'UTF8';

-- =========================================================
-- Drops (ordre dépendances)
-- =========================================================
DROP VIEW IF EXISTS v_inbox CASCADE;
DROP VIEW IF EXISTS v_dm_other_member CASCADE;
DROP VIEW IF EXISTS v_conversation_last_message CASCADE;
DROP VIEW IF EXISTS v_search_projects CASCADE;
DROP VIEW IF EXISTS v_search_students CASCADE;
DROP VIEW IF EXISTS v_profile_stats CASCADE;
DROP VIEW IF EXISTS v_post_like_counts CASCADE;
DROP VIEW IF EXISTS v_comment_like_counts CASCADE;

DROP TABLE IF EXISTS project_members CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS user_skills CASCADE;
DROP TABLE IF EXISTS skills CASCADE;

DROP TABLE IF EXISTS post_media CASCADE;
DROP TABLE IF EXISTS comment_likes CASCADE;
DROP TABLE IF EXISTS post_likes CASCADE;
DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS events_rsvps CASCADE;
DROP TABLE IF EXISTS events CASCADE;
DROP TABLE IF EXISTS messages CASCADE;
DROP TABLE IF EXISTS conversation_members CASCADE;
DROP TABLE IF EXISTS conversations CASCADE;
DROP TABLE IF EXISTS group_memberships CASCADE;
DROP TABLE IF EXISTS posts CASCADE;
DROP TABLE IF EXISTS groups CASCADE;
DROP TABLE IF EXISTS follows CASCADE;
DROP TABLE IF EXISTS user_profiles CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- =========================================================
-- Types (équivalents ENUM)
-- =========================================================
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'follow_role') THEN
    -- placeholder, rien ici
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'group_member_role') THEN
    CREATE TYPE group_member_role AS ENUM ('member','admin');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'group_member_status') THEN
    CREATE TYPE group_member_status AS ENUM ('active','banned','left');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'post_visibility') THEN
    CREATE TYPE post_visibility AS ENUM ('public','private','friends','group');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'media_type') THEN
    CREATE TYPE media_type AS ENUM ('image','video','link');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'event_rsvp_status') THEN
    CREATE TYPE event_rsvp_status AS ENUM ('going','interested','not_going');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'conversation_type') THEN
    CREATE TYPE conversation_type AS ENUM ('dm','group');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'conversation_member_role') THEN
    CREATE TYPE conversation_member_role AS ENUM ('member','admin');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'message_type') THEN
    CREATE TYPE message_type AS ENUM ('text','attachment');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'project_status') THEN
    CREATE TYPE project_status AS ENUM ('open','in_progress','done');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'skill_level') THEN
    CREATE TYPE skill_level AS ENUM ('beginner','intermediate','advanced');
  END IF;
END $$;

-- =========================================================
-- Users / Profiles
-- =========================================================
CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  username VARCHAR(50) NOT NULL UNIQUE,
  display_name VARCHAR(100) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE user_profiles (
  user_id BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  bio TEXT NULL,
  avatar_url VARCHAR(500) NULL,
  school VARCHAR(150) NULL,
  department VARCHAR(150) NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- updated_at auto
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_user_profiles_updated_at
BEFORE UPDATE ON user_profiles
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =========================================================
-- Follows
-- =========================================================
CREATE TABLE follows (
  follower_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  followee_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (follower_id, followee_id),
  CONSTRAINT chk_no_self_follow CHECK (follower_id <> followee_id)
);
CREATE INDEX idx_follows_followee ON follows(followee_id);
CREATE INDEX idx_follows_follower ON follows(follower_id);

-- =========================================================
-- Groups
-- =========================================================
CREATE TABLE groups (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE,
  description TEXT NULL,
  created_by BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_groups_created_by ON groups(created_by);

CREATE TABLE group_memberships (
  group_id BIGINT NOT NULL REFERENCES groups(id) ON DELETE CASCADE ON UPDATE CASCADE,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  role group_member_role NOT NULL DEFAULT 'member',
  status group_member_status NOT NULL DEFAULT 'active',
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (group_id, user_id)
);
CREATE INDEX idx_group_memberships_user ON group_memberships(user_id);

-- =========================================================
-- Posts + Media
-- =========================================================
CREATE TABLE posts (
  id BIGSERIAL PRIMARY KEY,
  author_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  visibility post_visibility NOT NULL DEFAULT 'public',
  group_id BIGINT NULL REFERENCES groups(id) ON DELETE SET NULL ON UPDATE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT chk_posts_visibility_group CHECK (visibility <> 'group' OR group_id IS NOT NULL)
);
CREATE INDEX idx_posts_author_created ON posts(author_id, created_at DESC);
CREATE INDEX idx_posts_group ON posts(group_id);

CREATE TRIGGER trg_posts_updated_at
BEFORE UPDATE ON posts
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE post_media (
  id BIGSERIAL PRIMARY KEY,
  post_id BIGINT NOT NULL REFERENCES posts(id) ON DELETE CASCADE ON UPDATE CASCADE,
  media_type media_type NOT NULL DEFAULT 'image',
  media_url VARCHAR(500) NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_post_media_post ON post_media(post_id, sort_order);

-- =========================================================
-- Comments
-- =========================================================
CREATE TABLE comments (
  id BIGSERIAL PRIMARY KEY,
  post_id BIGINT NOT NULL REFERENCES posts(id) ON DELETE CASCADE ON UPDATE CASCADE,
  author_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  parent_comment_id BIGINT NULL REFERENCES comments(id) ON DELETE SET NULL ON UPDATE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_comments_post_created ON comments(post_id, created_at);
CREATE INDEX idx_comments_author_created ON comments(author_id, created_at);

-- =========================================================
-- Likes
-- =========================================================
CREATE TABLE post_likes (
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  post_id BIGINT NOT NULL REFERENCES posts(id) ON DELETE CASCADE ON UPDATE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, post_id)
);
CREATE INDEX idx_post_likes_post ON post_likes(post_id);

CREATE TABLE comment_likes (
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  comment_id BIGINT NOT NULL REFERENCES comments(id) ON DELETE CASCADE ON UPDATE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, comment_id)
);
CREATE INDEX idx_comment_likes_comment ON comment_likes(comment_id);

-- =========================================================
-- Events + RSVPs
-- =========================================================
CREATE TABLE events (
  id BIGSERIAL PRIMARY KEY,
  group_id BIGINT NULL REFERENCES groups(id) ON DELETE SET NULL ON UPDATE CASCADE,
  created_by BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  title VARCHAR(200) NOT NULL,
  description TEXT NULL,
  location VARCHAR(200) NULL,
  starts_at TIMESTAMPTZ NOT NULL,
  ends_at TIMESTAMPTZ NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_events_group_starts ON events(group_id, starts_at);
CREATE INDEX idx_events_created_by_starts ON events(created_by, starts_at);

CREATE TABLE events_rsvps (
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  event_id BIGINT NOT NULL REFERENCES events(id) ON DELETE CASCADE ON UPDATE CASCADE,
  status event_rsvp_status NOT NULL DEFAULT 'interested',
  responded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, event_id)
);
CREATE INDEX idx_events_rsvps_event ON events_rsvps(event_id);

-- =========================================================
-- Messaging
-- =========================================================
CREATE TABLE conversations (
  id BIGSERIAL PRIMARY KEY,
  type conversation_type NOT NULL DEFAULT 'dm',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_conversations_type ON conversations(type);

CREATE TABLE conversation_members (
  conversation_id BIGINT NOT NULL REFERENCES conversations(id) ON DELETE CASCADE ON UPDATE CASCADE,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  role conversation_member_role NOT NULL DEFAULT 'member',
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (conversation_id, user_id)
);
CREATE INDEX idx_conversation_members_user ON conversation_members(user_id);

CREATE TABLE messages (
  id BIGSERIAL PRIMARY KEY,
  conversation_id BIGINT NOT NULL REFERENCES conversations(id) ON DELETE CASCADE ON UPDATE CASCADE,
  sender_id BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  message_type message_type NOT NULL DEFAULT 'text',
  content TEXT NULL,
  attachment_url VARCHAR(500) NULL,
  sent_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_messages_conversation_sent ON messages(conversation_id, sent_at);
CREATE INDEX idx_messages_sender_sent ON messages(sender_id, sent_at);

-- Fin schéma

