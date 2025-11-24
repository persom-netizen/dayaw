import 'salita.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'ai.dart';
import 'alaala.dart';
import 'services/api_service.dart';
import 'screens/sulatin/sulatin_screen.dart';
import 'screens/create_post_screen.dart';
import 'providers/post_provider.dart';
import 'widgets/feed_post_card.dart';

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildFeedPage(),
      AiPage(username: widget.username),
      SalitaPage(username: widget.username),
      AlaalaPage(username: widget.username),
      const SulatinScreen(),
    ];
    // Load posts when home page initializes
    Future.microtask(
      () => Provider.of<PostProvider>(context, listen: false).loadPosts(),
    );
  }

  Widget _buildFeedPage() {
    return Consumer<PostProvider>(
      builder: (context, postProvider, child) {
        if (postProvider.isLoading && postProvider.posts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (postProvider.error != null && postProvider.posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Error loading posts',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  postProvider.error!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => postProvider.loadPosts(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (postProvider.posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.post_add, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No posts yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to create a post!',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => postProvider.loadPosts(),
          child: ListView.builder(
            itemCount: postProvider.posts.length,
            itemBuilder: (context, index) {
              final post = postProvider.posts[index];
              return FeedPostCard(
                post: post,
                onDelete: post.username == widget.username && post.id != null
                    ? () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Post'),
                            content: const Text(
                              'Are you sure you want to delete this post?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          try {
                            await postProvider.deletePost(post.id!);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Post deleted successfully'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error deleting post: $e'),
                                ),
                              );
                            }
                          }
                        }
                      }
                    : null,
              );
            },
          ),
        );
      },
    );
  }

  void _onNavBarTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DAYAW"),
        centerTitle: true,
        backgroundColor: Colors.blue[600],
        automaticallyImplyLeading: false, // ✅ REMOVES BACK ARROW
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreatePostScreen(username: widget.username),
                  ),
                );
                // Reload posts after returning from create screen
                if (context.mounted) {
                  Provider.of<PostProvider>(context, listen: false).loadPosts();
                }
              },
              backgroundColor: Colors.blue[600],
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavBarTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Bahay'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Juan'),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories),
            label: 'Salita',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Alaala'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Sulatin'),
        ],
      ),
    );
  }
}
