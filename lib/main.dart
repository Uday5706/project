// lib/main.dart

// Add this import at the top of the file
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:oceo/l10n/app_localizations.dart';
import 'package:oceo/providers/alerts_provider.dart';
import 'package:oceo/providers/posts_provider.dart';
import 'package:oceo/providers/user_provider.dart';
import 'package:oceo/screens/auth_screen.dart';
import 'package:oceo/screens/home_screen.dart';
import 'package:provider/provider.dart';

// Your main() function is likely correct, the change is in the Oceo widget's build method.

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

class Oceo extends StatelessWidget {
  const Oceo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Your existing theme data is fine
      ),

      // --- ADD THESE LINES TO ENABLE LOCALIZATION ---
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      // ------------------------------------------------
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            return const HomeScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
