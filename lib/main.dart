import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart'; // Import firebase_core
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oceo/providers/alerts_provider.dart';
import 'package:oceo/providers/posts_provider.dart';
import 'package:oceo/providers/user_provider.dart';
import 'package:provider/provider.dart';

import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PostsProvider()),
        ChangeNotifierProvider(create: (context) => AlertsProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: Oceo(),
    ),
  );
}

class Oceo extends StatefulWidget {
  @override
  State<Oceo> createState() => _OceoState();
}

class _OceoState extends State<Oceo> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.blue,
          selectionColor: Colors.blueAccent.shade100,
          selectionHandleColor: Colors.blueAccent,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final user = snapshot.data;
            final userProvider = Provider.of<UserProvider>(
              context,
              listen: false,
            );

            if (user != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                userProvider.setUser(
                  UserModel(
                    uid: user.uid,
                    displayName: user.displayName,
                    email: user.email,
                    photoURL: user.photoURL,
                  ),
                );
              });
              return HomeScreen();
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                userProvider.clearUser();
              });
              return AuthScreen();
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
