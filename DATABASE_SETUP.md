# Database Setup Instructions

## Prerequisites
- MySQL 5.7+ or MariaDB 10.3+
- Python 3.9+
- Required Python packages (see backend/requirements.txt)

## Initial Setup

### 1. Create Database
```sql
CREATE DATABASE IF NOT EXISTS dayaw CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```
F
### 2. Initialize Tables
Run the Flask app with the `--init-db` flag to create all necessary tables:

```bash
cd backend
python app.py --init-db
```

This will create the following tables:
- `sign_up` - User registration data
- `login` - User login credentials
- `alaala` - Filipino trivia (24-hour rotation)
- `salita` - Word of the day (24-hour rotation)
- `chat_history` - AI chat conversations
- `chat_threads` - Conversation threads
- `posts` - Community feed posts
- `sulatin_samples` - Baybayin learning samples
- `sulatin_attempts` - User practice attempts

### 3. Apply Migrations (Optional)
If you're upgrading from an older version, apply migrations:

```bash
# Add likes and comments support to posts table
mysql -u root dayaw < backend/migrations/add_likes_comments_to_posts.sql

# Add post_likes and post_comments tables
mysql -u root dayaw < backend/migrations/add_post_likes_comments_tables.sql

# Add comment_replies table
mysql -u root dayaw < backend/migrations/add_comment_replies_table.sql
```

## Database Schema

### Posts Table
The `posts` table stores community feed posts with the following structure:

```sql
CREATE TABLE posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    profile_image VARCHAR(500),
    title VARCHAR(255),
    content TEXT NOT NULL,
    image_url VARCHAR(500),
    likes_count INT DEFAULT 0 NOT NULL,
    comments_count INT DEFAULT 0 NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_posts_likes_count (likes_count),
    INDEX idx_posts_comments_count (comments_count),
    INDEX idx_posts_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### Key Features
- **Content Field**: Supports >10,000 characters for long-form content (tula/poetry, stories)
- **Likes/Comments**: Tracking fields for community interaction
- **Timestamps**: Automatic created_at tracking
- **Indexes**: Optimized for sorting by date and interaction counts

## Configuration

### Database Connection
Update the connection string in `backend/app.py`:

```python
app.config["SQLALCHEMY_DATABASE_URI"] = "mysql+mysqlconnector://username:password@host/dayaw"
```

Default configuration:
- Host: localhost
- Database: dayaw
- User: root
- Password: (empty)

### Environment Variables
Create a `.env` file in the backend directory:

```env
DATABASE_URL=mysql+mysqlconnector://root:@localhost/dayaw
GOOGLE_API_KEY=your_gemini_api_key_here
```

## Testing Database Connection

Test the database connection:

```bash
curl http://localhost:5000/api/db-ping
```

Expected response:
```json
{
  "ok": true,
  "message": "Database connection successful"
}
```

## Seeding Sample Data (Optional)

### Add Sample Posts
```sql
INSERT INTO posts (username, title, content, likes_count, comments_count, created_at) VALUES
('juan', 'tula para kay manuela', 'Ang ganda ng iyong mga mata...', 5, 2, NOW()),
('maria', NULL, 'Magandang umaga sa lahat!', 10, 5, NOW()),
('pedro', 'Alamat ng Pilipinas', 'Noong unang panahon...', 15, 8, NOW());
```

### Add Sample Trivia (Alaala)
```sql
INSERT INTO alaala (alammoba, deskription) VALUES
('Mga Bayani ng Pilipinas', 'Ang mga bayaning Pilipino ay nagbuwis ng buhay para sa kalayaan ng bansa.'),
('Wikang Filipino', 'Ang wikang Filipino ay batay sa Tagalog at opisyal na wika ng Pilipinas.');
```

### Add Sample Words (Salita)
```sql
INSERT INTO salita (salita, depinisyon, bigkas, etimolohiya, gamit) VALUES
('Lakbay', 'Paglalakbay o paglalayag', 'lak-BAI', 'Mula sa Austronesian', 'Masayang lakbay ang aming pamilya sa probinsya.');
```

## Troubleshooting

### Connection Error
If you see "Can't connect to MySQL server":
1. Ensure MySQL is running: `sudo systemctl start mysql`
2. Check credentials in app.py
3. Verify database exists: `mysql -u root -e "SHOW DATABASES;"`

### Table Creation Failed
If tables don't create:
1. Check MySQL user has CREATE TABLE permissions
2. Verify database character set is utf8mb4
3. Review logs for specific SQL errors

### Migration Issues
If migration fails:
1. Check if columns already exist: `DESCRIBE posts;`
2. Manually add columns if needed (see migration SQL)
3. Ensure MySQL version supports `IF NOT EXISTS` syntax

## Backup and Restore

### Backup Database
```bash
mysqldump -u root dayaw > backup_dayaw_$(date +%Y%m%d).sql
```

### Restore Database
```bash
mysql -u root dayaw < backup_dayaw_20251124.sql
```

## Production Considerations

1. **Security**: Use strong passwords and limit database user permissions
2. **Performance**: Add indexes on frequently queried fields
3. **Backups**: Set up automated daily backups
4. **Connection Pooling**: Configure SQLAlchemy pool settings
5. **Monitoring**: Set up query performance monitoring

For more details, see the Flask-SQLAlchemy documentation: https://flask-sqlalchemy.palletsprojects.com/
