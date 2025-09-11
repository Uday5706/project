import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oceo/providers/posts_provider.dart';
import 'package:oceo/providers/user_provider.dart';
import 'package:oceo/services/location.dart';
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
      if (images.isEmpty) {
        print("⚠️ No media selected");
      } else {
        print("📸 Selected ${images.length} images");
      }
      setState(() {
        _selectedMedia.addAll(images);
      });
    } catch (e) {
      print("❌ Error picking media: $e");
    }
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _isFetchingLocation = true;
      _currentLocation = null;
    });

    try {
      final loc = Location();
      await loc.getCurrentLocation();
      setState(() {
        _currentLocation = loc.locationName ?? "Location not found";
        _isFetchingLocation = false;
        _latitude = loc.latitude;
        _longitude = loc.longitude;
      });
      print("📍 Location fetched: $_currentLocation ($_latitude, $_longitude)");
    } catch (e) {
      print("❌ Error fetching location: $e");
      setState(() {
        _isFetchingLocation = false;
        _currentLocation = "Location error";
      });
    }
  }

  Future<void> _handlePost() async {
    final postText = _textController.text.trim();
    if (postText.isEmpty && _selectedMedia.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add some text or media to your post.'),
          ),
        );
      }
      print("⚠️ Tried posting with no text and no media");
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      final postsProvider = Provider.of<PostsProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;

      if (user == null) {
        print("❌ No logged in user");
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('User not logged in.')));
        }
        return;
      }

      print("🚀 Starting post upload...");
      print("📝 Text: $postText");
      print("🖼️ Media files: ${_selectedMedia.length}");
      print("👤 User: ${user.displayName}, UID: ${user.uid}");

      await postsProvider.addPost(
        username: user.displayName ?? 'Current User',
        userPic:
            user.photoURL ??
            'https://via.placeholder.com/150/FFC107/000000?text=CU',
        text: postText,
        mediaFiles: _selectedMedia,
        latitude: _latitude,
        longitude: _longitude,
      );

      print("✅ Post successfully uploaded!");

      setState(() {
        _isPosting = false;
        _selectedMedia.clear();
        _textController.clear();
      });

      widget.onNavigateToTab(0);
    } catch (e, stack) {
      print("❌ Error while posting: $e");
      print(stack);
      if (context.mounted) {
        setState(() {
          _isPosting = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to post: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  void _removeMedia(int index) {
    print("🗑️ Removed media at index $index");
    setState(() {
      _selectedMedia.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
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
          final user = userProvider.user;
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
                        SizedBox(
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
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.file(
                                        File(file.path),
                                        fit: BoxFit.cover,
                                        width: 150,
                                        height: 150,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey.shade300,
                                                width: 150,
                                                height: 150,
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    size: 75,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: InkWell(
                                        onTap: () => _removeMedia(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
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
                        const SizedBox(height: 16),
                      ],
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 150),
                        child: TextField(
                          controller: _textController,
                          autofocus: true,
                          maxLines: null,
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.chat,
                              color: Colors.blueAccent,
                            ),
                            hintText: 'What do you want to talk about?',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(12.0),
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
