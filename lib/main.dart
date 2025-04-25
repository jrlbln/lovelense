import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/admin/auth_screen_web.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/guests/auth_screen_mobile.dart';
import 'screens/guests/camera_screen.dart';
import 'screens/guests/captured_images_screen.dart';
import 'screens/guests/social_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: firebaseOptions);

  // Preload Google Fonts
  GoogleFonts.config.allowRuntimeFetching = true;

  runApp(const ProviderScope(child: MainApp()));
}

// Define a centralized route map
final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => kIsWeb ? const AuthScreenWeb() : const OnboardingScreen(),
  '/admin': (context) => const AdminScreen(),
  '/auth_mobile': (context) => const AuthScreenMobile(),
  '/camera': (context) => const CameraScreen(),
  '/captured_images': (context) => const CapturedImagesScreen(),
  '/social': (context) => const SocialScreen(),
  '/home': (context) => const HomeScreen(),
};

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoveLense',
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
        textTheme: GoogleFonts.portLligatSlabTextTheme(),
      ),
      initialRoute: '/',
      routes: appRoutes,
    );
  }
}
