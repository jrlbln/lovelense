import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lovelense/theme/app_gradient.dart';
import 'package:lovelense/widgets/primary_button.dart';
import 'package:lovelense/screens/guests/auth_screen_mobile.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.primaryGradient,
        ),
        child: PageView(
          controller: pageController,
          children: [
            _buildOnboardingPage(
              context,
              heading: "Capture Moments Create Memories",
              body: "A unique way to document wedding memories",
              svgAsset: "assets/images/onboarding1.svg",
              buttonText: "Get Started!",
              onButtonPressed: () => pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
            ),
            _buildOnboardingPage(
              context,
              heading: "Disposable Camera Experience",
              body: "Capture Intentionally",
              svgAsset: "assets/images/onboarding2.svg",
              additionalContent: Column(
                children: const [
                  Text(
                    "Just like a classic disposable camera, you have LIMITED shots.",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "🎥 5 SHOTS TOTAL 🎥",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              buttonText: "Awesome",
              onButtonPressed: () => pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
            ),
            _buildOnboardingPage(
              context,
              heading: "How It Works",
              body: "Simple. Authentic. Memorable.",
              svgAsset: "assets/images/onboarding3.svg",
              additionalContent: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Center(
                      child: Text(
                        "📸 Capture Your Moments 📸",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text("1. Open the app at the wedding"),
                    Text("2. Login Via Google"),
                    Text("3. Take your 5 carefully chosen shots"),
                    Text("4. Watch them come to life in a digital album"),
                  ],
                ),
              ),
              buttonText: "I Understand",
              onButtonPressed: () => pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
            ),
            _buildOnboardingPage(
              context,
              heading: "Shared Images",
              body: "Your Images will be shared to everyone later",
              svgAsset: "assets/images/onboarding4.svg",
              buttonText: "Got it",
              onButtonPressed: () => pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
            ),
            _buildOnboardingPage(
              context,
              heading: "Ready to Create Memories?",
              body: "One Wedding. One Unique Perspective.",
              svgAsset: "assets/images/onboarding5.svg",
              buttonText: "Take your First Picture!",
              onButtonPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AuthScreenMobile()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(
    BuildContext context, {
    required String heading,
    required String body,
    required String svgAsset,
    Widget? additionalContent,
    required String buttonText,
    required VoidCallback onButtonPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            heading,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            body,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SvgPicture.asset(svgAsset, height: 400),
          if (additionalContent != null) ...[
            const SizedBox(height: 16),
            additionalContent,
          ],
          const SizedBox(height: 32),
          PrimaryButton(
            text: buttonText,
            onPressed: onButtonPressed,
          ),
        ],
      ),
    );
  }
}
