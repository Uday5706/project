import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final user = userCredential.user!;
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        // Copy user details to the UserProvider
        userProvider.setUser(
          UserModel(
            uid: user.uid,
            displayName: user.displayName,
            email: user.email,
            photoURL: user.photoURL,
          ),
        );

        // Navigate to the home screen on successful sign-in or sign-up
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      // Show a snackbar to the user on error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Google Sign-In failed. Please try again."),
          ),
        );
      }
    }
  }

  Widget _socialLoginTile(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueAccent, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 350,
          height: 450,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome to Oceo",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 32),
                _socialLoginTile(
                  context,
                  label: "Sign in with Google",
                  icon: FontAwesomeIcons.google,
                  iconColor: Colors.red,
                  onTap: () async {
                    await _signInWithGoogle(context);
                  },
                ),
                _socialLoginTile(
                  context,
                  label: "Sign in with Facebook",
                  icon: FontAwesomeIcons.facebook,
                  iconColor: Colors.blue.shade900,
                  onTap: () {
                    // TODO: Add Facebook auth
                  },
                ),
                _socialLoginTile(
                  context,
                  label: "Sign in with Instagram",
                  icon: FontAwesomeIcons.instagram,
                  iconColor: Colors.purple.shade700,
                  onTap: () {
                    // TODO: Add Instagram auth
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
