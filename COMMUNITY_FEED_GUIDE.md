# Community Feed System - User Guide

## Overview
The Dayaw app features a Facebook-like community feed system called "Bahay" (Home) where users can share posts, interact with content, and build a community around Filipino language and culture.

## Features

### 1. Feed Display (Bahay)
The main feed displays posts in chronological order with the following information:

#### Post Header
- **Username**: Displayed as the actual username from login/registration
- **Profile Picture**: Avatar with first letter of username if no image is set
- **Timestamp**: Relative time (e.g., "5m ago", "2h ago", "3d ago") or full date for older posts, converted to user's local timezone

#### Post Content
- **Title** (Optional): Bold heading for the post (e.g., "tula para kay manuela")
- **Content**: Full text content supporting up to 10,000+ characters for long-form writing
  - Perfect for poetry (tula)
  - Stories and essays
  - Cultural discussions
- **Media**: Optional image display with error handling for broken links

#### Interaction Elements
- **Likes**: ❤️ icon with count - tap to like/unlike posts
- **Comments**: 💬 icon with count - tap to view and add comments

#### Post Actions
- **Delete**: Users can delete their own posts with confirmation dialog
- **Pull to Refresh**: Swipe down to reload the feed

### 2. Creating Posts

#### Access
- Tap the **floating action button (+)** at the bottom right of the Bahay screen
- This opens the "Lumikha ng Post" (Create Post) screen

#### Form Fields

**Pamagat (Opsyonal)** - Title (Optional)
- Optional field for post title
- Maximum 255 characters
- Good for headlines, poem titles, or topic summaries

**Ano ang iyong nais isulat?** - What do you want to write?
- Main content field (required)
- Maximum 10,000 characters
- Supports multi-line text for long-form content
- Perfect for:
  - Tula (Poetry)
  - Short stories
  - Cultural articles
  - Personal reflections
  - Language learning tips

**Nais mag dagdag ng larawan (opsyonal)** - Add image (optional)
- Optional field for image URL
- Gallery picker button available (upload feature requires backend implementation)
- Supports standard image formats (JPG, PNG, GIF)

#### Actions
- **Ilaganap** - Post/Publish
  - Submits the post to the community feed
  - Shows success message: "Matagumpay na nailagay ang post!"
  - Returns to feed automatically
  - New post appears at the top of the feed
- **Back Arrow** - Cancel and return to feed

### 3. Navigation

#### Bottom Navigation Bar
The app uses a bottom navigation bar with 5 sections:
1. **Bahay** (Home) - Community feed 🏠
2. **Analisa** - AI chat assistant 💬 **removed**
3. **Salita** - Word of the day 📖
4. **Alaala** - Filipino trivia 💡
5. **Sulatin** - Baybayin writing practice ✍️

The feed is accessible via the "Bahay" tab.

## User Flow Examples

### Example 1: Sharing a Poem
1. User logs in as "maria"
2. Navigates to Bahay tab
3. Taps the + button
4. Fills in:
   - Pamagat: "Tula para sa Inang Bayan"
   - Content: [Full poem text, up to 10,000 characters]
5. Taps "ilaganap"
6. Post appears in feed as "maria"
7. Other users can see and interact with the post

### Example 2: Sharing a Story
1. User logs in as "juan"
2. Taps + button from Bahay
3. Fills in:
   - Content: [Long-form story about Filipino folklore]
   - Image URL: [Link to relevant illustration]
4. Taps "ilaganap"
5. Story posts successfully with image

### Example 3: Deleting a Post
1. User sees their own post in the feed
2. Taps the delete icon (🗑️) on their post
3. Confirmation dialog appears: "Sigurado ka bang gusto mong tanggalin ang post na ito?"
4. Taps "Tanggalin" to confirm or "Kanselahin" to cancel
5. Post is removed from the feed
6. Success message: "Matagumpay na natanggal ang post"

## Design Features

### Visual Design
- **Clean Card Layout**: Each post in a Material Design card
- **Responsive**: Works on various screen sizes
- **Color Scheme**: Blue accent colors (#2196F3) for consistency with app theme
- **Typography**: Clear hierarchy with bold usernames and titles

### User Experience
- **Pull-to-refresh**: Easy content updates
- **Smooth Scrolling**: ListView optimization for long feeds
- **Loading States**: Progress indicators while fetching data
- **Error Handling**: Friendly error messages in Filipino
- **Empty States**: Helpful messages when feed is empty

### Accessibility
- **High Contrast**: Clear text on backgrounds
- **Touch Targets**: Large enough buttons for easy tapping
- **Screen Reader Support**: Semantic HTML and ARIA labels
- **Tooltips**: Helpful hints on icon buttons

## Technical Details

### API Endpoints
- `GET /api/posts` - Fetch all posts for the feed (optional `username` query param for like status)
- `POST /api/posts` - Create a new post
- `DELETE /api/posts/:id` - Delete a specific post
- `POST /api/posts/:id/like` - Toggle like/unlike on a post
- `GET /api/posts/:id/like/status` - Check if user has liked a post
- `GET /api/posts/:id/comments` - Get all comments for a post
- `POST /api/posts/:id/comments` - Add a comment to a post
- `DELETE /api/posts/:id/comments/:comment_id` - Delete a comment

### Data Model
```dart
class Post {
  int? id;
  String username;
  String? profileImage;
  String? title;
  String content;
  String? imageUrl;
  DateTime createdAt;
  int likesCount;
  int commentsCount;
  bool isLiked;
}

class Comment {
  int id;
  int postId;
  String username;
  String content;
  DateTime createdAt;
}
```

### State Management
- Uses Provider pattern for reactive state updates
- PostProvider manages all post-related state
- Automatic feed refresh after creating/deleting posts
- Like and comment functionality with real-time updates

### Character Limits
- Title: 255 characters
- Content: 10,000 characters (supports long-form writing)
- Image URL: 500 characters
- Username: 50 characters

## Tips for Users

### Writing Posts
1. **Use titles for poems and articles** to help readers know what to expect
2. **Keep posts focused** on Filipino culture, language, or community topics
3. **Add images** to make posts more engaging
4. **Proofread** before posting - you can delete but can't edit posts

### Community Guidelines
1. **Be respectful** of other community members
2. **Stay on topic** - focus on Filipino language and culture
3. **Share quality content** - poetry, stories, cultural insights
4. **Engage positively** with others' posts
5. **Report inappropriate content** to moderators

### Content Ideas
- Share Filipino poems (tula)
- Post short stories or folklore (alamat)
- Write about Filipino traditions
- Share language learning tips
- Discuss historical events
- Post cultural recipes
- Share travel stories from the Philippines

## Troubleshooting

### Posts Not Loading
1. Check internet connection
2. Pull down to refresh the feed
3. Tap "Subukan Muli" (Try Again) button if error appears
4. Restart the app if issues persist

### Can't Create Post
1. Ensure content field is not empty
2. Check character limits
3. Verify image URL is valid (if provided)
4. Check internet connection

### Image Not Displaying
1. Verify the image URL is correct
2. Check if the image host allows hotlinking
3. Try a different image URL
4. Images from some sources may be blocked

### Post Deleted Accidentally
- Unfortunately, deleted posts cannot be recovered
- Always confirm carefully before deleting
- Consider copying important content before deleting

## Recent Updates

### Implemented Features
- ✅ Full like/unlike functionality - tap the heart icon to like/unlike posts
- ✅ Comment system - tap the comment icon to view and add comments
- ✅ Correct username display - shows actual username from login (removed prefix)
- ✅ Timezone-aware timestamps - posts show correct local time

## Future Enhancements

### Planned Features
- Comment replies and threading
- Edit post capability
- Video support
- User profiles
- Follow/unfollow users
- Post sharing
- Hashtags and search
- Notifications for interactions
- Post bookmarking
- Content moderation tools

### Long-term Vision
- Build a vibrant Filipino language learning community
- Support for Baybayin script in posts
- Integration with language learning modules
- Community challenges and events
- Cultural exchange features
- Multi-language support (Tagalog, English, regional languages)

## Support
For issues or questions about the community feed:
1. Check this guide first
2. Review the FAQ section
3. Contact support via the app
4. Report bugs on GitHub

---

**Maligayang pagbabahagi!** (Happy sharing!)
