import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

// NOTE: In a larger app, it's best to move each of these model classes
// into their own files (e.g., lib/models/post_model.dart).

class Location {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  Location({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });
}

class Comment {
  final String userName;
  final String userId;
  final String userPic;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.userName,
    required this.userId,
    required this.userPic,
    required this.text,
    required this.timestamp,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      userName: map['userName'] ?? '',
      userId: map['userId'] ?? '',
      userPic: map['userPic'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'userId': userId,
      'userPic': userPic,
      'text': text,
      'timestamp': timestamp,
    };
  }
}

class Post {
  final String postId;
  final String username;
  final String userPic;
  final DateTime postDate;
  final Location? location;
  final int upvotes;
  final String text;
  final List<Comment> comments;
  final List<String> mediaUrls;
  final String userId;
  final List<String> upvotedBy;

  Post({
    required this.postId,
    required this.username,
    required this.userPic,
    required this.postDate,
    this.location,
    required this.upvotes,
    required this.text,
    required this.comments,
    required this.userId,
    this.mediaUrls = const [],
    required this.upvotedBy,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final locationData = data['location'] as Map<String, dynamic>?;
    final commentsData = data['comments'] as List<dynamic>? ?? [];
    final comments = commentsData
        .map((commentData) => Comment.fromMap(commentData))
        .toList();
    comments.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Post(
      postId: doc.id,
      username: data['username'] ?? '',
      userPic: data['userPic'] ?? '',
      postDate: (data['postDate'] as Timestamp).toDate(),
      location: locationData != null
          ? Location(
              latitude: locationData['latitude'],
              longitude: locationData['longitude'],
              timestamp: (locationData['timestamp'] as Timestamp).toDate(),
            )
          : null,
      upvotes: data['upvotes'] ?? 0,
      text: data['text'] ?? '',
      comments: comments,
      mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
      userId: data['userId'] ?? '',
      upvotedBy: List<String>.from(data['upvotedBy'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'userPic': userPic,
      'postDate': postDate,
      'location': location != null
          ? {
              'latitude': location!.latitude,
              'longitude': location!.longitude,
              'timestamp': location!.timestamp,
            }
          : null,
      'upvotes': upvotes,
      'text': text,
      'comments': comments.map((comment) => comment.toMap()).toList(),
      'mediaUrls': mediaUrls,
      'userId': userId,
      'upvotedBy': upvotedBy,
    };
  }

  Post copyWith({
    int? upvotes,
    List<Comment>? comments,
    List<String>? upvotedBy,
  }) {
    return Post(
      postId: this.postId,
      username: this.username,
      userPic: this.userPic,
      postDate: this.postDate,
      location: this.location,
      upvotes: upvotes ?? this.upvotes,
      text: this.text,
      comments: comments ?? this.comments,
      mediaUrls: this.mediaUrls,
      userId: this.userId,
      upvotedBy: upvotedBy ?? this.upvotedBy,
    );
  }
}

class PostsProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  List<Post> _posts = [];
  bool _isLoading = false;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;

  List<Post> get mostUpvotedPosts {
    final List<Post> sortedList = List.from(_posts);
    sortedList.sort((a, b) => b.upvotes.compareTo(a.upvotes));
    return sortedList;
  }

  PostsProvider() {
    _listenToPosts();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _listenToPosts() {
    _firestore
        .collection('posts')
        .orderBy('postDate', descending: true)
        .snapshots()
        .listen((snapshot) {
          _posts = snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
          notifyListeners();
        });
  }

  Future<void> addCommentToPost(String postId, Comment comment) async {
    final postIndex = _posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return;

    final originalPost = _posts[postIndex];

    // 1. Optimistically update local state
    final newComments = [comment, ...originalPost.comments];
    final updatedPost = originalPost.copyWith(comments: newComments);
    _posts[postIndex] = updatedPost;
    notifyListeners();

    // 2. Attempt to update the database
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      await postRef.update({
        'comments': FieldValue.arrayUnion([comment.toMap()]),
      });
    } catch (e) {
      // 3. If it fails, revert the local change and notify UI
      if (kDebugMode) print("❌ Failed to add comment, reverting. Error: $e");
      _posts[postIndex] = originalPost;
      notifyListeners();
      rethrow;
    }
  }

  // In lib/providers/posts_provider.dart

  Future<Post?> addPost({
    required String username,
    required String userPic,
    required String text,
    required List<XFile> mediaFiles,
    required double? latitude,
    required double? longitude,
  }) async {
    _setLoading(true);
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      if (kDebugMode) print("❌ No user logged in to add post");
      _setLoading(false);
      return null;
    }
    try {
      // Media upload logic (unchanged)
      final List<String> mediaUrls = await Future.wait(
        mediaFiles.map((file) async {
          final ref = _storage.ref().child('post_media/$userId/${file.name}');
          await ref.putFile(File(file.path));
          return await ref.getDownloadURL();
        }),
      );
      final Location? postLocation = (latitude != null && longitude != null)
          ? Location(
              latitude: latitude,
              longitude: longitude,
              timestamp: DateTime.now(),
            )
          : null;

      // Create a temporary post object with all the data
      final newPostData = Post(
        postId: '', // Temporary ID
        username: username,
        userPic: userPic,
        postDate: DateTime.now(),
        upvotes: 0,
        text: text,
        userId: userId,
        location: postLocation,
        mediaUrls: mediaUrls,
        comments: [],
        upvotedBy: [],
      );

      // Add it to Firestore
      final docRef = await _firestore
          .collection('posts')
          .add(newPostData.toFirestore());

      // Create the final Post object with the REAL postId from Firestore
      final finalPost = Post(
        postId: docRef.id,
        username: newPostData.username,
        userPic: newPostData.userPic,
        postDate: newPostData.postDate,
        location: newPostData.location,
        upvotes: newPostData.upvotes,
        text: newPostData.text,
        comments: newPostData.comments,
        mediaUrls: newPostData.mediaUrls,
        userId: newPostData.userId,
        upvotedBy: newPostData.upvotedBy,
      );

      if (kDebugMode) print("✅ Post successfully added!");
      _setLoading(false);
      return finalPost; // Return the complete Post object
    } catch (e, stack) {
      if (kDebugMode) {
        print("❌ Error adding post: $e");
        print(stack);
      }
      _setLoading(false);
      return null;
    }
  }

  // In PostsProvider class
  Future<void> deletePost(String postId) async {
    // 1. Optimistically remove from the local list for instant UI update
    final postIndex = _posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return;
    final postToRemove = _posts[postIndex];
    _posts.removeAt(postIndex);
    notifyListeners();

    // 2. Attempt to delete from the database
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      // 3. If it fails, add the post back to the local list and notify UI
      print("❌ Failed to delete post, reverting. Error: $e");
      _posts.insert(postIndex, postToRemove);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refreshPosts() async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .orderBy('postDate', descending: true)
          .get();
      _posts = snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      print("Error refreshing posts: $e");
      rethrow;
    }
  }

  // In lib/providers/posts_provider.dart

  Future<void> toggleUpvotePost(String postId, String postOwnerId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final postIndex = _posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return;

    final originalPost = _posts[postIndex];
    final isAlreadyUpvoted = originalPost.upvotedBy.contains(userId);

    // 1. Optimistic local update (this part is correct)
    final updatedPost = originalPost.copyWith(
      upvotes: isAlreadyUpvoted
          ? originalPost.upvotes - 1
          : originalPost.upvotes + 1,
      upvotedBy: isAlreadyUpvoted
          ? (List<String>.from(originalPost.upvotedBy)..remove(userId))
          : (List<String>.from(originalPost.upvotedBy)..add(userId)),
    );
    _posts[postIndex] = updatedPost;
    notifyListeners();

    // 2. Attempt to update the database
    try {
      final postRef = _firestore.collection('posts').doc(postId);

      final transactionUpdate = {
        'upvotes': FieldValue.increment(isAlreadyUpvoted ? -1 : 1),
        'upvotedBy': isAlreadyUpvoted
            ? FieldValue.arrayRemove([userId])
            : FieldValue.arrayUnion([userId]),
      };

      // CORRECTED: We only need to update the main post document.
      // The batch and the userPostRef update have been removed.
      await postRef.update(transactionUpdate);
    } catch (e) {
      // 3. If it fails, revert the local change
      if (kDebugMode) {
        print("❌ Failed to toggle upvote, reverting. Error: $e");
      }
      _posts[postIndex] = originalPost;
      notifyListeners();
      rethrow;
    }
  }
}
