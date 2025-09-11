// lib/providers/user_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oceo/models/user_model.dart'; // <-- Import the new model file
import 'package:oceo/providers/posts_provider.dart'; // <-- Import Post for the method argument

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _userModel;
  User? _firebaseUser;

  UserModel? get userModel => _userModel;
  User? get firebaseUser => _firebaseUser;

  UserProvider() {
    _listenToAuthStateChanges();
  }

  void _listenToAuthStateChanges() {
    _auth.authStateChanges().listen((User? user) {
      _firebaseUser = user;
      if (user != null) {
        _listenToUserData(user);
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  void _listenToUserData(User user) {
    _firestore.collection('users').doc(user.uid).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        _userModel = UserModel.fromFirestore(snapshot);
      } else {
        _createNewUserDocument(user);
      }
      notifyListeners();
    });
  }

  Future<void> _createNewUserDocument(User user) async {
    final newUser = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'New User',
      photoURL: user.photoURL ?? '',
      posts: [],
    );
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(newUser.toFirestore());
    _userModel = newUser;
    notifyListeners();
  }

  // In UserProvider class
  Future<void> removePostFromProfile(Post postToRemove) async {
    if (_userModel == null) return;

    // 1. Optimistically update local state
    final originalUserModel = _userModel!;
    final updatedPosts = List<Post>.from(originalUserModel.posts)
      ..removeWhere((p) => p.postId == postToRemove.postId);
    _userModel = originalUserModel.copyWith(posts: updatedPosts);
    notifyListeners();

    // 2. Update the database
    try {
      await _firestore.collection('users').doc(_userModel!.uid).update({
        'posts': FieldValue.arrayRemove([postToRemove.toFirestore()]),
      });
    } catch (e) {
      // 3. If it fails, revert the local change
      print("Error removing post from user profile, reverting: $e");
      _userModel = originalUserModel;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addPostToUserProfile(Post newPost) async {
    if (_userModel == null) return;

    final originalUserModel = _userModel!;
    final updatedPosts = [newPost, ...originalUserModel.posts];
    _userModel = originalUserModel.copyWith(posts: updatedPosts);
    notifyListeners();

    try {
      await _firestore.collection('users').doc(_userModel!.uid).update({
        'posts': FieldValue.arrayUnion([newPost.toFirestore()]),
      });
    } catch (e) {
      print("Error adding post to user profile, reverting: $e");
      _userModel = originalUserModel;
      notifyListeners();
      rethrow;
    }
  }
}
