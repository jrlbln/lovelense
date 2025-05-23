import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lovelense/screens/guests/social_screen.dart';
import '../../widgets/google_button.dart';
import '../../services/auth_service.dart';
import 'package:flutter/foundation.dart';

class AuthScreenMobile extends StatefulWidget {
  const AuthScreenMobile({super.key});

  @override
  _AuthScreenMobileState createState() => _AuthScreenMobileState();
}

class _AuthScreenMobileState extends State<AuthScreenMobile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF87CEEB), Color(0xFF61ECD9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to',
                  style: GoogleFonts.portLligatSlab(
                    fontSize: 32,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Jimuel & Jaybei\'s',
                  style: GoogleFonts.greatVibes(
                    fontSize: 48,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'special day',
                  style: GoogleFonts.portLligatSlab(
                    fontSize: 32,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 300,
                  height: 400,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/couple_image.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GoogleButton(
                  text: 'Continue with Google',
                  onPressed: () async {
                    final user = await AuthService.signInWithGoogle();
                    if (user != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SocialScreen()),
                      );
                    } else {
                      if (kDebugMode) {
                        print('Sign-in failed');
                      }
                    }
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
