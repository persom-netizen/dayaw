-- Migration: Add comment_replies table for nested comments
-- Date: 2025-11-28
-- Description: Adds support for replies to comments on community feed posts

USE dayaw;

-- Create comment_replies table
CREATE TABLE IF NOT EXISTS comment_replies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    comment_id INT NOT NULL,
    username VARCHAR(50) NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (comment_id) REFERENCES post_comments(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Add index for better query performance
CREATE INDEX IF NOT EXISTS idx_comment_replies_comment_id ON comment_replies(comment_id);

-- Verify the table was created
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    COLUMN_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dayaw'
  AND TABLE_NAME = 'comment_replies';
