import 'package:flutter/material.dart';

class UserModel {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoURL;

  UserModel({required this.uid, this.displayName, this.email, this.photoURL});
}

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
