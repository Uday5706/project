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
    final userProvider = Provider.of<UserProvider>(context);
    final postsProvider = Provider.of<PostsProvider>(context);
    final currentUser = userProvider.firebaseUser;

    if (currentUser == null) {
      return const Center(child: Text("Please log in to see your posts."));
    }

    final myPosts = postsProvider.posts
        .where((post) => post.userId == currentUser.uid)
        .toList();

    if (myPosts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            "You haven't posted anything yet. Your posts will appear here.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posts', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: myPosts.length,
        itemBuilder: (context, index) {
          final post = myPosts[index];
          return PostWidget(
            post: post,
            postTimeFormatter: _formatPostTime,
            onUpvote: () {
              // UPDATED: Pass both postId and the post owner's userId
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
