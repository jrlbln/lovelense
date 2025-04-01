import 'package:flutter/material.dart';
import '../../widgets/input_field.dart';
import '../../widgets/google_button.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';

class AuthScreenWeb extends StatelessWidget {
  const AuthScreenWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.gradient1, AppColors.gradient2],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            width: 600,
            height: 500,
            padding: const EdgeInsets.all(60),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.100),
                  blurRadius: 100,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Welcome Back\nFill out the information below to access your account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                InputField(
                  controller: emailController,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                InputField(
                  controller: passwordController,
                  labelText: 'Password',
                  obscureText: true,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.visibility_off),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Handle email/password sign-in
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: const Text('Sign In'),
                ),
                const SizedBox(height: 10),
                const Text('or sign up with',
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 10),
                GoogleButton(
                  text: 'Continue with Google',
                  onPressed: () async {
                    final user = await AuthService.signInWithGoogle();
                    if (user != null) {
                      print('Signed in as ${user.displayName}');
                    } else {
                      print('Sign-in failed');
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
