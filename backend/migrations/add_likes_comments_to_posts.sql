-- Migration: Add likes_count and comments_count columns to posts table
-- Date: 2025-11-24
-- Description: Adds interaction tracking fields for community feed posts

USE dayaw;

-- Add likes_count column if it doesn't exist
ALTER TABLE posts 
ADD COLUMN IF NOT EXISTS likes_count INT DEFAULT 0 NOT NULL;

-- Add comments_count column if it doesn't exist
ALTER TABLE posts 
ADD COLUMN IF NOT EXISTS comments_count INT DEFAULT 0 NOT NULL;

-- Update existing posts to have default values
UPDATE posts SET likes_count = 0 WHERE likes_count IS NULL;
UPDATE posts SET comments_count = 0 WHERE comments_count IS NULL;

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_posts_likes_count ON posts(likes_count);
CREATE INDEX IF NOT EXISTS idx_posts_comments_count ON posts(comments_count);

-- Verify the changes
SELECT 
    COLUMN_NAME,
    COLUMN_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dayaw'
  AND TABLE_NAME = 'posts'
  AND COLUMN_NAME IN ('likes_count', 'comments_count');
