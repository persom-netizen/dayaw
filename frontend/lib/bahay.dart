import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/create_post_screen.dart';
import 'providers/post_provider.dart';
import 'widgets/feed_post_card.dart';

/// Bahay (Home) - Community Feed Page
/// Displays posts from the community in a Facebook-like feed format
class BahayPage extends StatefulWidget {
  final String username;

  const BahayPage({super.key, required this.username});

  @override
  State<BahayPage> createState() => _BahayPageState();
}

class _BahayPageState extends State<BahayPage> {
  @override
  void initState() {
    super.initState();
    // Load posts when page initializes
    Future.microtask(
      () => Provider.of<PostProvider>(context, listen: false).loadPosts(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PostProvider>(
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
                    'May error sa pagkuha ng mga post',
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
                    label: const Text('Subukan Muli'),
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
                    'Walang mga post pa',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Maging una sa paglikha ng post!',
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
                              title: const Text('Tanggalin ang Post'),
                              content: const Text(
                                'Sigurado ka bang gusto mong tanggalin ang post na ito?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Kanselahin'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Tanggalin',
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
                                    content: Text(
                                      'Matagumpay na natanggal ang post',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'May error sa pagtanggal ng post: $e',
                                    ),
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
      ),
      floatingActionButton: FloatingActionButton(
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
        tooltip: 'Lumikha ng post',
        child: const Icon(Icons.add),
      ),
    );
  }
}
