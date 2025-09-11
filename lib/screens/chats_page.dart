import 'package:flutter/material.dart';
import 'package:oceo/providers/posts_provider.dart';
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
    _searchController.addListener(() {
      setState(() {});
    });
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
      posts = posts.where((post) {
        return now.difference(post.postDate).inHours <= 24;
      }).toList();
    } else if (_selectedFilter == 'Last Week') {
      posts = posts.where((post) {
        return now.difference(post.postDate).inDays <= 7;
      }).toList();
    } else if (_selectedFilter == 'All Time') {
      posts = allPosts;
    }

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      posts = posts.where((post) {
        return post.username.toLowerCase().contains(query) ||
            post.text.toLowerCase().contains(query);
      }).toList();
    }

    return posts;
  }

  String _formatPostTime(DateTime postDate) {
    final now = DateTime.now();
    final difference = now.difference(postDate);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks weeks ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months months ago';
    }
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Filter Posts",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Last 24 Hours'),
                onTap: () {
                  setState(() {
                    _selectedFilter = 'Last 24 Hours';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Last Week'),
                onTap: () {
                  setState(() {
                    _selectedFilter = 'Last Week';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('All Time'),
                onTap: () {
                  setState(() {
                    _selectedFilter = 'All Time';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostsProvider>(
      builder: (context, postsProvider, child) {
        final filteredPosts = _filterPosts(postsProvider.posts);
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                color: Colors.blueAccent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            hintText: 'Search posts or users...',
                            hintStyle: TextStyle(color: Colors.black54),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.blueAccent,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                      onPressed: () => _showFilterOptions(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: filteredPosts
                        .map(
                          (post) => PostWidget(
                            post: post,
                            postTimeFormatter: _formatPostTime,
                            onUpvote: () {
                              postsProvider.upvotePost(post.postId);
                            },
                          ),
                        )
                        .toList(),
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

  const PostWidget({
    super.key,
    required this.post,
    required this.postTimeFormatter,
    required this.onUpvote,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  PageController? _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    if (widget.post.mediaUrls.isNotEmpty) {
      _pageController = PageController();
      _pageController!.addListener(() {
        if (_pageController!.page != null) {
          setState(() {
            _currentPage = _pageController!.page!.round();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  Widget _buildMediaIndicator() {
    if (widget.post.mediaUrls.length <= 1) {
      return const SizedBox.shrink();
    }
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
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.post.userPic),
                radius: 20,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blueAccent,
                    ),
                  ),
                  Text(
                    widget.postTimeFormatter(widget.post.postDate),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              InkWell(
                onTap: widget.onUpvote,
                child: Row(
                  children: [
                    const Icon(
                      Icons.thumb_up_alt_outlined,
                      color: Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.post.upvotes}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(widget.post.text, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 10),
          if (widget.post.mediaUrls.isNotEmpty)
            Column(
              children: [
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: widget.post.mediaUrls.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade100,
                              borderRadius: BorderRadius.circular(8.0),
                              image: DecorationImage(
                                image: NetworkImage(
                                  widget.post.mediaUrls[index],
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                      // if (widget.post.mediaUrls.length > 1 && _currentPage > 0)
                      //   Positioned(
                      //     left: 10,
                      //     top: 0,
                      //     bottom: 0,
                      //     child: Align(
                      //       alignment: Alignment.centerLeft,
                      //       child: Container(
                      //         decoration: BoxDecoration(
                      //           color: Colors.black.withAlpha(30),
                      //           shape: BoxShape.circle,
                      //         ),
                      //         child: IconButton(
                      //           icon: const Icon(
                      //             Icons.arrow_back_ios_new,
                      //             color: Colors.white,
                      //             size: 20,
                      //           ),
                      //           onPressed: () {
                      //             _pageController?.previousPage(
                      //               duration: const Duration(milliseconds: 300),
                      //               curve: Curves.easeInOut,
                      //             );
                      //           },
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // if (widget.post.mediaUrls.length > 1 &&
                      //     _currentPage < widget.post.mediaUrls.length - 1)
                      //   Positioned(
                      //     right: 10,
                      //     top: 0,
                      //     bottom: 0,
                      //     child: Align(
                      //       alignment: Alignment.centerRight,
                      //       child: Container(
                      //         decoration: BoxDecoration(
                      //           color: Colors.black.withAlpha(30),
                      //           shape: BoxShape.circle,
                      //         ),
                      //         child: IconButton(
                      //           icon: const Icon(
                      //             Icons.arrow_forward_ios,
                      //             color: Colors.white,
                      //             size: 20,
                      //           ),
                      //           onPressed: () {
                      //             _pageController?.nextPage(
                      //               duration: const Duration(milliseconds: 300),
                      //               curve: Curves.easeInOut,
                      //             );
                      //           },
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _buildMediaIndicator(),
              ],
            ),
        ],
      ),
    );
  }
}
