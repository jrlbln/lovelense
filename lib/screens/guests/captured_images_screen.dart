import 'package:flutter/material.dart';
import 'package:lovelense/theme/app_colors.dart';
import 'package:lovelense/widgets/bottom_navigation_bar.dart';

class CapturedImagesScreen extends StatelessWidget {
  const CapturedImagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Captured Images'),
      ),
      body: Center(
        child: const Text('This is the Captured Images screen.'),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/social');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/camera');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/captured_images');
          }
        },
        backgroundColor: AppColors.secondary,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Theme.of(context).unselectedWidgetColor,
      ),
    );
  }
}
