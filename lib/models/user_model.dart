// lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oceo/providers/posts_provider.dart'; // Ensure this path is correct

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoURL;
  final List<Post> posts;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoURL,
    required this.posts,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    final postsData = data['posts'] as List<dynamic>? ?? [];
    final userPosts = postsData.map((postData) {
      String postId =
          postData['postId'] ?? doc.id + postsData.indexOf(postData).toString();
      return Post.fromFirestore(MapDocumentSnapshot(postData, postId));
    }).toList();

    userPosts.sort((a, b) => b.postDate.compareTo(a.postDate));

    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'] ?? '',
      posts: userPosts,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'posts': posts.map((post) => post.toFirestore()).toList(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    List<Post>? posts,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      posts: posts ?? this.posts,
    );
  }
}

// Helper class to adapt a Map to the DocumentSnapshot interface
class MapDocumentSnapshot implements DocumentSnapshot {
  final Map<String, dynamic> _data;
  @override
  final String id;

  MapDocumentSnapshot(this._data, this.id);

  @override
  dynamic get(Object field) => _data[field as String];

  @override
  dynamic operator [](Object field) => _data[field as String];

  @override
  Map<String, dynamic>? data() => _data;

  @override
  bool get exists => true;

  @override
  SnapshotMetadata get metadata => throw UnimplementedError(
    'metadata is not implemented for MapDocumentSnapshot',
  );

  @override
  DocumentReference get reference => throw UnimplementedError(
    'reference is not implemented for MapDocumentSnapshot',
  );
}
