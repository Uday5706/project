import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';

class Post {
  final String postId;
  final String username;
  final String userPic;
  final DateTime postDate;
  final Location location;
  final int upvotes;
  final String text;
  final List<String> mediaUrls;
  final String userId;

  Post({
    required this.postId,
    required this.username,
    required this.userPic,
    required this.postDate,
    required this.location,
    required this.upvotes,
    required this.text,
    required this.userId,
    this.mediaUrls = const [],
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      postId: doc.id,
      username: data['username'] ?? '',
      userPic: data['userPic'] ?? '',
      postDate: (data['postDate'] as Timestamp).toDate(),
      location: Location(
        latitude: data['location']['latitude'],
        longitude: data['location']['longitude'],
        timestamp: (data['location']['timestamp'] as Timestamp).toDate(),
      ),
      upvotes: data['upvotes'] ?? 0,
      text: data['text'] ?? '',
      mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'userPic': userPic,
      'postDate': postDate,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
        'timestamp': location.timestamp,
      },
      'upvotes': upvotes,
      'text': text,
      'mediaUrls': mediaUrls,
      'userId': userId,
    };
  }
}

class PostsProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  List<Post> _posts = [];
  bool _isLoading = false;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;

  // New getter to provide the list sorted by upvotes
  List<Post> get mostUpvotedPosts {
    // Create a copy to avoid modifying the original list
    final List<Post> sortedList = List.from(_posts);
    sortedList.sort((a, b) => b.upvotes.compareTo(a.upvotes));
    return sortedList;
  }

  PostsProvider() {
    _posts = [];
    _listenToPosts();
  }

  void _listenToPosts() {
    _firestore.collection('posts').snapshots().listen((snapshot) {
      _posts = snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
      _posts.sort((a, b) => b.postDate.compareTo(a.postDate));
      notifyListeners();
    });
  }

  Future<void> addPost({
    required String username,
    required String userPic,
    required String text,
    required List<XFile> mediaFiles,
    required double? latitude,
    required double? longitude,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("❌ No user logged in in PostsProvider");
      return;
    }

    List<String> mediaUrls = [];

    try {
      for (var file in mediaFiles) {
        print("⬆️ Uploading file: ${file.path}");
        final ref = _storage.ref().child('post_media/$userId/${file.name}');
        final uploadTask = await ref.putFile(File(file.path));
        final url = await ref.getDownloadURL();
        mediaUrls.add(url);
        print("✅ Uploaded file: ${file.name}, URL: $url");
      }
    } catch (e, stack) {
      print("❌ Error uploading media: $e");
      print(stack);
      rethrow;
    }

    final postLocation = Location(
      latitude: latitude ?? 0,
      longitude: longitude ?? 0,
      timestamp: DateTime.now(),
    );

    final newPost = Post(
      postId: '',
      username: username,
      userPic: userPic,
      postDate: DateTime.now(),
      upvotes: 0,
      text: text,
      userId: userId,
      location: postLocation,
      mediaUrls: mediaUrls,
    );

    try {
      print("⬆️ Adding post to Firestore...");
      await _firestore.collection('posts').add(newPost.toFirestore());
      print("✅ Post successfully added to Firestore!");
    } catch (e, stack) {
      print("❌ Error adding post to Firestore: $e");
      print(stack);
      rethrow;
    }
  }

  Future<void> upvotePost(String postId) async {
    final postRef = _firestore.collection('posts').doc(postId);
    await _firestore.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postRef);
      if (postSnapshot.exists) {
        final newUpvotes = (postSnapshot.data()?['upvotes'] ?? 0) + 1;
        transaction.update(postRef, {'upvotes': newUpvotes});
      }
    });
  }
}
