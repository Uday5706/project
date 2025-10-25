import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_cloud_translation/google_cloud_translation.dart';
import 'package:image_picker/image_picker.dart';

// Note: In a real app, it's best to move these model classes to separate files.
class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() => {
    'latitude': latitude,
    'longitude': longitude,
  };
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
  final Map<String, String> text;
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
    Map<String, String> postText = {};
    if (data['text'] is String) {
      postText['en'] = data['text']; // Backwards compatibility
    } else if (data['text'] is Map) {
      postText = Map<String, String>.from(data['text']);
    }

    return Post(
      postId: doc.id,
      username: data['username'] ?? '',
      userPic: data['userPic'] ?? '',
      postDate: (data['postDate'] as Timestamp).toDate(),
      location: data['location'] != null
          ? Location.fromMap(data['location'])
          : null,
      upvotes: data['upvotes'] ?? 0,
      text: postText,
      comments: (data['comments'] as List<dynamic>? ?? [])
          .map((c) => Comment.fromMap(c))
          .toList(),
      mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
      userId: data['userId'] ?? '',
      upvotedBy: List<String>.from(data['upvotedBy'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'username': username,
      'userPic': userPic,
      'postDate': postDate,
      'location': location?.toMap(),
      'upvotes': upvotes,
      'text': text,
      'comments': comments.map((c) => c.toMap()).toList(),
      'mediaUrls': mediaUrls,
      'userId': userId,
      'upvotedBy': upvotedBy,
    };
  }

  Post copyWith({
    int? upvotes,
    List<Comment>? comments,
    List<String>? upvotedBy,
    Map<String, String>? text,
  }) {
    return Post(
      postId: postId,
      username: username,
      userPic: userPic,
      postDate: postDate,
      location: location,
      upvotes: upvotes ?? this.upvotes,
      text: text ?? this.text,
      comments: comments ?? this.comments,
      mediaUrls: mediaUrls,
      userId: userId,
      upvotedBy: upvotedBy ?? this.upvotedBy,
    );
  }
}

class PostsProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  List<Post> _posts = [];
  bool _isLoading = true;
  final Map<String, String> _translationCache = {};
  final Translation _translator = Translation(
    apiKey: 'AIzaSyDFO-ueHRWJeFl4mVfdbKq8_jMYvO4PBtU',
  );

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
          if (_isLoading) _isLoading = false;
          notifyListeners();
        });
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

  Future<String?> translatePostText(
    String postId,
    String text,
    String targetLanguage,
  ) async {
    final cacheKey = '$postId-$targetLanguage';
    if (_translationCache.containsKey(cacheKey)) {
      return _translationCache[cacheKey];
    }
    try {
      final translated = await _translator.translate(
        text: text,
        to: targetLanguage,
      );
      final result = translated.translatedText;
      _translationCache[cacheKey] = result;
      return result;
    } catch (e) {
      print("❌ Translation Error: $e");
      return "Translation failed.";
    }
  }

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
      _setLoading(false);
      return null;
    }
    try {
      final List<String> mediaUrls = await Future.wait(
        mediaFiles.map((file) async {
          final ref = _storage.ref().child(
            'post_media/$userId/${DateTime.now().millisecondsSinceEpoch}-${file.name}',
          );
          await ref.putFile(File(file.path));
          return await ref.getDownloadURL();
        }),
      );

      final newPostData = Post(
        postId: '',
        username: username,
        userPic: userPic,
        postDate: DateTime.now(),
        upvotes: 0,
        text: {'en': text},
        userId: userId,
        location: (latitude != null && longitude != null)
            ? Location(latitude: latitude, longitude: longitude)
            : null,
        mediaUrls: mediaUrls,
        comments: [],
        upvotedBy: [],
      );

      final docRef = await _firestore
          .collection('posts')
          .add(newPostData.toFirestore());

      final finalPost = newPostData.copyWith(
        // The copyWith method isn't set up to copy postId, so we'll construct manually
      );

      final finalPostWithId = Post(
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

      _setLoading(false);
      return finalPostWithId;
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> deletePost(String postId) async {
    final postIndex = _posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return;
    final postToRemove = _posts[postIndex];
    _posts.removeAt(postIndex);
    notifyListeners();

    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      _posts.insert(postIndex, postToRemove);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addCommentToPost(String postId, Comment comment) async {
    final postIndex = _posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return;
    final originalPost = _posts[postIndex];
    final updatedPost = originalPost.copyWith(
      comments: [comment, ...originalPost.comments],
    );
    _posts[postIndex] = updatedPost;
    notifyListeners();
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      await postRef.update({
        'comments': FieldValue.arrayUnion([comment.toMap()]),
      });
    } catch (e) {
      _posts[postIndex] = originalPost;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleUpvotePost(String postId, String postOwnerId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    final postIndex = _posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return;
    final originalPost = _posts[postIndex];
    final isAlreadyUpvoted = originalPost.upvotedBy.contains(userId);

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

    try {
      final postRef = _firestore.collection('posts').doc(postId);
      await postRef.update({
        'upvotes': FieldValue.increment(isAlreadyUpvoted ? -1 : 1),
        'upvotedBy': isAlreadyUpvoted
            ? FieldValue.arrayRemove([userId])
            : FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      _posts[postIndex] = originalPost;
      notifyListeners();
      rethrow;
    }
  }
}
