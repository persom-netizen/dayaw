# Quick Start Guide - Community Feed System

## For Developers

### 1. Clone and Setup
```bash
# Clone the repository
git clone https://github.com/persom-netizen/dayaw.git
cd dayaw

# Backend setup
cd backend
pip install -r requirements.txt
python app.py --init-db
python app.py

# Frontend setup (new terminal)
cd ../frontend
flutter pub get
flutter run
```

### 2. Database Migration
```bash
# If upgrading from older version, run migration
mysql -u root dayaw < backend/migrations/add_likes_comments_to_posts.sql
```

### 3. Test the Feed
1. Login or create account
2. Navigate to "Bahay" tab
3. Tap + button to create a post
4. Fill in title (optional) and content
5. Tap "Ilaganap" to post

## Key Files

### Frontend
- `lib/bahay.dart` - Main feed page
- `lib/screens/create_post_screen.dart` - Post creation
- `lib/models/post_model.dart` - Post data model
- `lib/services/post_service.dart` - API calls
- `lib/providers/post_provider.dart` - State management
- `lib/widgets/feed_post_card.dart` - Post card UI

### Backend
- `app.py` - Flask app with Post model and API endpoints
- `migrations/add_likes_comments_to_posts.sql` - Database migration

### Documentation
- `COMMUNITY_FEED_GUIDE.md` - User guide and technical docs
- `DATABASE_SETUP.md` - Database setup instructions
- `IMPLEMENTATION_SUMMARY.md` - Complete implementation details

## API Endpoints

```bash
# Get all posts
GET http://localhost:5000/api/posts

# Create a post
POST http://localhost:5000/api/posts
Content-Type: application/json
{
  "username": "juan",
  "title": "My Title",
  "content": "My content...",
  "image_url": "https://example.com/image.jpg"
}

# Delete a post
DELETE http://localhost:5000/api/posts/1
```

## Common Issues

### Issue: MySQL Connection Error
**Solution**: 
```bash
sudo systemctl start mysql
# Update credentials in backend/app.py
```

### Issue: Flutter Build Error
**Solution**:
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: Posts Not Loading
**Solution**:
1. Check backend is running (http://localhost:5000/api/db-ping)
2. Verify API URL in `frontend/lib/services/post_service.dart`
3. Check browser console for CORS errors

## Feature Checklist

### Feed Display ✅
- [x] Username format: otokesengkake_username
- [x] Timestamps (relative format)
- [x] Optional titles
- [x] Long-form content (10,000 chars)
- [x] Image support
- [x] Likes count
- [x] Comments count
- [x] Pull-to-refresh
- [x] Delete posts
- [x] Empty states
- [x] Error handling

### Create Post ✅
- [x] Title field (optional)
- [x] Content field (required, 10k chars)
- [x] Image URL field
- [x] Gallery picker (placeholder)
- [x] Form validation
- [x] Filipino labels
- [x] Success feedback

### Backend ✅
- [x] Post model with all fields
- [x] GET /api/posts
- [x] POST /api/posts
- [x] DELETE /api/posts/:id
- [x] Database migration
- [x] likes_count field
- [x] comments_count field

## Next Steps

1. Test the complete flow
2. Add sample data for demo
3. Deploy to production
4. Monitor performance
5. Gather user feedback

## Support

- See COMMUNITY_FEED_GUIDE.md for detailed documentation
- See DATABASE_SETUP.md for database help
- Check issues on GitHub for known problems
- Contact development team for assistance

---

**Last Updated**: November 24, 2025
**Status**: Ready for Testing ✅
