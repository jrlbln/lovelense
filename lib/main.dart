import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/guests/auth_screen_mobile.dart';
import 'screens/admin/auth_screen_web.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/guests/camera_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: firebaseOptions);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;

    return MaterialApp(
      title: 'Wedding Camera',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          primary: Colors.amber,
          secondary: Colors.amberAccent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            // Redirect authenticated users
            final user = snapshot.data!;
            if (user.email == 'admin@example.com') {
              // Redirect admin users
              return const AdminScreen();
            } else {
              // Redirect regular users
              return isWeb ? const AdminScreen() : const CameraScreen();
            }
          } else {
            // Show authentication screen
            return isWeb ? const AuthScreenWeb() : const AuthScreenMobile();
          }
        },
      ),
    );
  }
}
