import 'package:flutter/material.dart';

import 'home_screen.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized(); //This ensures Flutter’s binding is set up before running any async/native code (like Firebase).
  // await Firebase.initializeApp(); //This initializes Firebase in your app.
  runApp(Oceo());
}

class Oceo extends StatefulWidget {
  @override
  State<Oceo> createState() => _OceoState();
}

class _OceoState extends State<Oceo> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, // to remove the trial app sign on top right
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android:
                CupertinoPageTransitionsBuilder(), // iOS-style side transition
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        // textTheme: GoogleFonts.poppinsTextTheme(),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.blue, // blinking cursor color
          selectionColor: Colors.blueAccent.shade100, // highlight color
          selectionHandleColor:
              Colors.blueAccent, // <--- this changes the blob color
        ), // Apply Poppins globally
      ),
      home: HomeScreen(),
    );
  }
}
