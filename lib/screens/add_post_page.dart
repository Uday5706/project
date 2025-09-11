import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oceo/providers/posts_provider.dart';
import 'package:oceo/providers/user_provider.dart';
import 'package:oceo/services/location.dart'
    as location_service; // <-- Add this prefix
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class AddPostPage extends StatefulWidget {
  final Function(int) onNavigateToTab;

  const AddPostPage({super.key, required this.onNavigateToTab});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedMedia = [];
  String? _currentLocation;
  bool _isFetchingLocation = false;
  bool _isPosting = false;

  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _addMedia() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedMedia.addAll(images);
        });
      }
    } catch (e) {
      print("❌ Error picking media: $e");
    }
  }

  Future<void> _fetchLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      final loc = location_service.Location();
      await loc.getCurrentLocation();
      if (mounted) {
        setState(() {
          _currentLocation = loc.locationName ?? "Location not found";
          _latitude = loc.latitude;
          _longitude = loc.longitude;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _currentLocation = "Location error");
      }
      print("❌ Error fetching location: $e");
    } finally {
      if (mounted) {
        setState(() => _isFetchingLocation = false);
      }
    }
  }

  Future<void> _handlePost() async {
    final postText = _textController.text.trim();
    if (postText.isEmpty && _selectedMedia.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add text or media.')),
        );
      }
      return;
    }

    setState(() => _isPosting = true);

    try {
      final postsProvider = Provider.of<PostsProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.firebaseUser; // Use firebaseUser for auth info

      if (user == null) throw Exception("User not logged in.");

      // UPDATED: Capture the returned post object
      final Post? newPost = await postsProvider.addPost(
        username: user.displayName ?? 'Current User',
        userPic: user.photoURL ?? 'https://via.placeholder.com/150',
        text: postText,
        mediaFiles: _selectedMedia,
        latitude: _latitude,
        longitude: _longitude,
      );

      // UPDATED: If post creation is successful, link it to the user's profile
      if (newPost != null) {
        await userProvider.addPostToUserProfile(newPost);
        print("✅ Post created and linked to user profile!");

        // Clear UI and navigate on success
        setState(() {
          _selectedMedia.clear();
          _textController.clear();
        });
        widget.onNavigateToTab(0);
      } else {
        throw Exception("Post creation failed and returned null.");
      }
    } catch (e, stack) {
      print("❌ Error while posting: $e");
      print(stack);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to post: $e')));
      }
    } finally {
      // UPDATED: Cleaner state management, this runs regardless of success or failure
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
    });
  }

  // ... (The rest of your build method and other helpers are great and don't need changes)
  @override
  Widget build(BuildContext context) {
    // Your entire build method is well-structured and doesn't need to be changed.
    // The logic fixes above are all that's needed.
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Post', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            widget.onNavigateToTab(0);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton(
              onPressed: _isPosting ? null : _handlePost,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isPosting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blueAccent,
                        ),
                      ),
                    )
                  : const Text(
                      'Post',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user =
              userProvider.firebaseUser; // Use firebaseUser for auth info
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : const AssetImage('assets/images/Luffy.jpg')
                                as ImageProvider,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'Current User',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (_isFetchingLocation)
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: 120,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                            )
                          else if (_currentLocation != null)
                            Text(
                              _currentLocation!,
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                        ],
                      ),
                    ),
                    _buildMiniIconButton(
                      icon: Icons.add_photo_alternate_outlined,
                      onTap: _addMedia,
                    ),
                    _buildMiniIconButton(
                      icon: Icons.pin_drop_outlined,
                      onTap: _fetchLocation,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      if (_selectedMedia.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SizedBox(
                            height: 150,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedMedia.length,
                              itemBuilder: (context, index) {
                                final file = _selectedMedia[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                        child: Image.file(
                                          File(file.path),
                                          fit: BoxFit.cover,
                                          width: 150,
                                          height: 150,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: InkWell(
                                          onTap: () => _removeMedia(index),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 100,
                          maxHeight: 200,
                        ),
                        child: TextField(
                          controller: _textController,
                          autofocus: true,
                          maxLines: null,
                          style: const TextStyle(fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: 'What do you want to talk about?',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: Icon(icon, color: Colors.blueAccent, size: 24),
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}
