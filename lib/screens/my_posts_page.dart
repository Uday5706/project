import 'package:flutter/material.dart';
import 'package:oceo/providers/posts_provider.dart';
import 'package:oceo/providers/user_provider.dart';
import 'package:oceo/screens/chats_page.dart'; // We need PostWidget and DiscussionScreen
import 'package:provider/provider.dart';

class MyPostsPage extends StatelessWidget {
  const MyPostsPage({super.key});

  // Helper to format time, you can move this to a shared utils file later
  String _formatPostTime(DateTime postDate) {
    final now = DateTime.now();
    final difference = now.difference(postDate);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    final weeks = (difference.inDays / 7).floor();
    return '$weeks week${weeks > 1 ? 's' : ''} ago';
  }

  @override
  Widget build(BuildContext context) {
    // Listen to both providers to get the user's ID and the full post list
    final userProvider = Provider.of<UserProvider>(context);
    final postsProvider = Provider.of<PostsProvider>(context);

    final currentUser = userProvider.firebaseUser;

    if (currentUser == null) {
      return const Center(child: Text("Please log in to see your posts."));
    }

    // Filter the main post list to get only the current user's posts
    final myPosts = postsProvider.posts
        .where((post) => post.userId == currentUser.uid)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posts', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: myPosts.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "No Posts Yet",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Your created posts will appear here.",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: myPosts.length,
              itemBuilder: (context, index) {
                final post = myPosts[index];
                return PostWidget(
                  post: post,
                  postTimeFormatter: _formatPostTime,
                  onUpvote: () {
                    postsProvider.toggleUpvotePost(post.postId, post.userId);
                  },
                  onComment: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiscussionScreen(post: post),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
