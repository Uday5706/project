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
  // In lib/main.dart

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // In your MaterialApp widget
      theme: ThemeData(
        // This applies the Poppins font to all default text styles in your app.
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),

        // Your other theme customizations remain the same
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.blue,
          selectionColor: Colors.blueAccent.shade100,
          selectionHandleColor: Colors.blueAccent,
        ),

        // You can also set primary colors, etc.
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Show a loading indicator while waiting for the auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Once the connection is active, check if the user is logged in
          if (snapshot.hasData && snapshot.data != null) {
            // User is logged in, show the HomeScreen.
            // The UserProvider has already updated itself in the background.
            // NO NEED to call setUser here.
            return const HomeScreen();
          } else {
            // User is logged out, show the AuthScreen.
            // The UserProvider has already cleared itself in the background.
            // NO NEED to call clearUser here.
            return const AuthScreen();
          }
        },
      ),
    );
  }
}
