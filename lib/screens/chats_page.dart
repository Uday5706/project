import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oceo/providers/posts_provider.dart';
import 'package:oceo/providers/user_provider.dart';
import 'package:provider/provider.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});
  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  String _selectedFilter = 'Last 24 Hours';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Post> _filterPosts(List<Post> allPosts) {
    List<Post> posts = allPosts;
    final now = DateTime.now();
    if (_selectedFilter == 'Last 24 Hours') {
      posts = posts
          .where((p) => now.difference(p.postDate).inHours <= 24)
          .toList();
    } else if (_selectedFilter == 'Last Week') {
      posts = posts
          .where((p) => now.difference(p.postDate).inDays <= 7)
          .toList();
    }
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      posts = posts
          .where(
            (p) =>
                p.username.toLowerCase().contains(query) ||
                (p.text['en'] ?? '').toLowerCase().contains(query),
          )
          .toList();
    }
    return posts;
  }

  String _formatPostTime(DateTime postDate) {
    final now = DateTime.now();
    final difference = now.difference(postDate);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return DateFormat('MMM d').format(postDate);
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Filter Posts", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Last 24 Hours'),
              onTap: () => setState(() {
                _selectedFilter = 'Last 24 Hours';
                Navigator.pop(ctx);
              }),
            ),
            ListTile(
              title: const Text('Last Week'),
              onTap: () => setState(() {
                _selectedFilter = 'Last Week';
                Navigator.pop(ctx);
              }),
            ),
            ListTile(
              title: const Text('All Time'),
              onTap: () => setState(() {
                _selectedFilter = 'All Time';
                Navigator.pop(ctx);
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostsProvider>(
      builder: (context, postsProvider, child) {
        final filteredPosts = _filterPosts(postsProvider.posts);
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                color: Colors.blueAccent,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search posts...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.blueAccent,
                          ),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 20,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                      onPressed: () => _showFilterOptions(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: postsProvider.isLoading && filteredPosts.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : filteredPosts.isEmpty
                    ? const Center(child: Text('No posts found.'))
                    : RefreshIndicator(
                        onRefresh: () => postsProvider.refreshPosts(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: filteredPosts.length,
                          itemBuilder: (context, index) {
                            final post = filteredPosts[index];
                            return PostWidget(
                              post: post,
                              postTimeFormatter: _formatPostTime,
                              onUpvote: () => postsProvider.toggleUpvotePost(
                                post.postId,
                                post.userId,
                              ),
                              onComment: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) =>
                                      DiscussionScreen(post: post),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PostWidget extends StatefulWidget {
  final Post post;
  final Function(DateTime) postTimeFormatter;
  final VoidCallback onUpvote;
  final VoidCallback onComment;
  const PostWidget({
    super.key,
    required this.post,
    required this.postTimeFormatter,
    required this.onUpvote,
    required this.onComment,
  });
  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  PageController? _pageController;
  int _currentPage = 0;

  // NEW: State variables for toggleable translation
  String? _translatedText;
  bool _isTranslating = false;
  bool _showTranslation = false;

  @override
  void initState() {
    super.initState();
    if (widget.post.mediaUrls.length > 1) {
      _pageController = PageController();
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  // NEW: Handles toggling between original and translated text
  void _toggleTranslation() async {
    // If we are currently showing the translation, just toggle back to the original
    if (_showTranslation) {
      setState(() {
        _showTranslation = false;
      });
      return;
    }

    // If we are showing the original, check if we've already fetched the translation
    if (_translatedText != null) {
      // If yes, just show it instantly without another API call
      setState(() {
        _showTranslation = true;
      });
    } else {
      // If no, then call the API to get the translation for the first time
      setState(() => _isTranslating = true);
      final postsProvider = Provider.of<PostsProvider>(context, listen: false);
      const String targetLanguage = 'hi';
      final originalText = widget.post.text['en'];

      if (originalText != null) {
        final result = await postsProvider.translatePostText(
          widget.post.postId,
          originalText,
          targetLanguage,
        );
        if (mounted) {
          setState(() {
            _translatedText = result;
            _showTranslation = true; // Show the new translation
            _isTranslating = false;
          });
        }
      } else {
        if (mounted) setState(() => _isTranslating = false);
      }
    }
  }

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
            onPressed: () async {
              final postsProvider = Provider.of<PostsProvider>(
                context,
                listen: false,
              );
              final userProvider = Provider.of<UserProvider>(
                context,
                listen: false,
              );
              if (mounted) Navigator.of(dialogContext).pop();
              try {
                await postsProvider.deletePost(widget.post.postId);
                await userProvider.removePostFromProfile(widget.post);
              } catch (e) {
                if (mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete: $e')),
                  );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMediaIndicator() {
    if (widget.post.mediaUrls.length <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.post.mediaUrls.length, (index) {
        return Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? Colors.blueAccent : Colors.grey[400],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isUpvoted =
        currentUser != null && widget.post.upvotedBy.contains(currentUser.uid);
    final isAuthor =
        currentUser != null && currentUser.uid == widget.post.userId;

    final originalText = widget.post.text['en'] ?? "Content not available.";
    final displayText = _showTranslation
        ? (_translatedText ?? originalText)
        : originalText;
    final bool canBeTranslated = widget.post.text.containsKey('en');

    return GestureDetector(
      onTap: isAuthor ? _showDeleteConfirmationDialog : null,
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.post.userPic),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.postTimeFormatter(widget.post.postDate),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(displayText),
              if (widget.post.mediaUrls.isNotEmpty) ...[
                const SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.post.mediaUrls.length,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemBuilder: (context, index) {
                      final imageUrl = widget.post.mediaUrls[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) =>
                                FullScreenImageViewer(imageUrl: imageUrl),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) =>
                                progress == null
                                ? child
                                : const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                            errorBuilder: (context, error, stack) => const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                if (widget.post.mediaUrls.length > 1) _buildMediaIndicator(),
              ],
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: widget.onUpvote,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_upward,
                            color: isUpvoted ? Colors.blueAccent : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.post.upvotes}',
                            style: TextStyle(
                              color: isUpvoted
                                  ? Colors.blueAccent
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (canBeTranslated)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _isTranslating
                          ? const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : TextButton(
                              onPressed: _toggleTranslation,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.translate, size: 16),
                                  const SizedBox(width: 4),
                                  Text(_showTranslation ? 'HI' : 'EN'),
                                ],
                              ),
                            ),
                    ),
                  InkWell(
                    onTap: widget.onComment,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.comment_outlined,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.post.comments.length}',
                            style: const TextStyle(color: Colors.blueAccent),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DiscussionScreen extends StatefulWidget {
  final Post post;
  const DiscussionScreen({super.key, required this.post});
  @override
  State<DiscussionScreen> createState() => _DiscussionScreenState();
}

class _DiscussionScreenState extends State<DiscussionScreen> {
  final TextEditingController _commentController = TextEditingController();

  String _formatPostTime(DateTime postTime) {
    final now = DateTime.now();
    final difference = now.difference(postTime);
    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return DateFormat('MMM d').format(postTime);
  }

  Future<void> _addComment() async {
    final postsProvider = Provider.of<PostsProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.firebaseUser;
    if (user == null || _commentController.text.trim().isEmpty) return;
    final newComment = Comment(
      userId: user.uid,
      userName: user.displayName ?? 'Anonymous User',
      userPic: user.photoURL ?? 'https://via.placeholder.com/150',
      text: _commentController.text.trim(),
      timestamp: DateTime.now(),
    );
    try {
      await postsProvider.addCommentToPost(widget.post.postId, newComment);
      _commentController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add comment: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Discussion'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Consumer<PostsProvider>(
            builder: (context, postsProvider, child) {
              final updatedPost = postsProvider.posts.firstWhere(
                (p) => p.postId == widget.post.postId,
                orElse: () => widget.post,
              );
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: PostWidget(
                      post: updatedPost,
                      postTimeFormatter: _formatPostTime,
                      onUpvote: () => postsProvider.toggleUpvotePost(
                        updatedPost.postId,
                        updatedPost.userId,
                      ),
                      onComment: () {},
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: updatedPost.comments.isEmpty
                        ? const Center(
                            child: Text('No comments yet. Be the first!'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            itemCount: updatedPost.comments.length,
                            itemBuilder: (context, index) {
                              final comment = updatedPost.comments[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    comment.userPic,
                                  ),
                                ),
                                title: Text(
                                  comment.userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(comment.text),
                                trailing: Text(
                                  _formatPostTime(comment.timestamp),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                      left: 8.0,
                      right: 8.0,
                      top: 8.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: 'Add a comment...',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.blueAccent,
                          ),
                          onPressed: _addComment,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  const FullScreenImageViewer({super.key, required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: InteractiveViewer(
            panEnabled: true,
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 4,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
