import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../services/user_service.dart';
import '../widgets/feed_post_card.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  final String currentUsername;

  const ProfileScreen({
    super.key,
    required this.username,
    required this.currentUsername,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  User? _user;
  List<Post> _posts = [];
  int _postCount = 0;
  bool _isLoading = true;
  String? _error;
  late AnimationController _animationController;
  
  // Design color constants
  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color textColor = Color(0xFF554141);
  static const Color backgroundColor = Color(0xFFFFF9F4);

  bool get _isOwnProfile => widget.username == widget.currentUsername;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
    _loadProfile();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await UserService.getUserProfile(widget.username);
      if (result['success'] == true) {
        setState(() {
          _user = result['user'] as User;
          _posts = result['posts'] as List<Post>;
          _postCount = result['postCount'] as int;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showEditProfileDialog() {
    if (_user == null) return;

    final pangalanController = TextEditingController(text: _user!.pangalan);
    final mongkaheController = TextEditingController(text: _user!.mongkahe);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mag-edit ng Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pangalanController,
                decoration: const InputDecoration(
                  labelText: 'Pangalan (Full Name)',
                  hintText: 'Ilagay ang iyong buong pangalan',
                ),
                maxLength: 100,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: mongkaheController,
                decoration: const InputDecoration(
                  labelText: 'Mongkahe (Bio)',
                  hintText: 'Magsulat tungkol sa sarili mo',
                ),
                maxLines: 3,
                maxLength: 500,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kanselahin'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateProfile(
                pangalanController.text.trim(),
                mongkaheController.text.trim(),
              );
            },
            child: const Text('I-save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile(String pangalan, String mongkahe) async {
    try {
      final updatedUser = await UserService.updateUserProfile(
        username: widget.username,
        pangalan: pangalan,
        mongkahe: mongkahe,
      );
      setState(() {
        _user = updatedUser;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Matagumpay na na-update ang profile')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lumabas'),
        content: const Text('Sigurado ka bang gusto mong lumabas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kanselahin'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate back to main/login page, clearing all routes
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Lumabas'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(_isOwnProfile ? 'Aking Profile' : '@${widget.username}'),
        backgroundColor: primaryYellow,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                color: primaryYellow,
                strokeWidth: 4,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Kinukuha ang profile...',
              style: TextStyle(
                fontSize: 16,
                color: textColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: primaryYellow),
            const SizedBox(height: 16),
            Text(
              'May error sa pagkuha ng profile',
              style: TextStyle(fontSize: 18, color: textColor),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('Subukan Muli'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryYellow,
                foregroundColor: textColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_user == null) {
      return const Center(child: Text('User not found'));
    }

    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: primaryYellow,
      backgroundColor: Colors.white,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildProfileHeader(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Mga Post ($_postCount)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (_posts.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.post_add, size: 64, color: primaryYellow),
                    SizedBox(height: 16),
                    Text(
                      'Walang mga post pa',
                      style: TextStyle(fontSize: 16, color: textColor),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = _posts[index];
                  return FeedPostCard(
                    post: post,
                    onUserTap: post.username != widget.username
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProfileScreen(
                                  username: post.username,
                                  currentUsername: widget.currentUsername,
                                ),
                              ),
                            );
                          }
                        : null,
                    onLike: null, // Disable like in profile view for now
                    onComment: null, // Disable comment in profile view for now
                    onDelete: null, // Disable delete in profile view
                  );
                },
                childCount: _posts.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Avatar
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: CircleAvatar(
                radius: 50,
                backgroundColor: primaryYellow,
                child: Text(
                  _user!.username.isNotEmpty ? _user!.username[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Name (pangalan)
          if (_user!.pangalan.isNotEmpty) ...[
            Text(
              _user!.pangalan,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
          ],

          // Username (palayaw)
          Text(
            '@${_user!.username}',
            style: TextStyle(
              fontSize: 16,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),

          // Email
          Text(
            _user!.email,
            style: TextStyle(
              fontSize: 14,
              color: textColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),

          // Bio (mongkahe)
          if (_user!.mongkahe.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _user!.mongkahe,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Post count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: primaryYellow,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryYellow.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.article, color: textColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$_postCount na post',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),

          // Edit and Logout buttons (only for own profile)
          if (_isOwnProfile) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _showEditProfileDialog,
                  icon: const Icon(Icons.edit),
                  label: const Text('Mag-edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryYellow,
                    foregroundColor: textColor,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Lumabas'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      ),
    );
  }
}
