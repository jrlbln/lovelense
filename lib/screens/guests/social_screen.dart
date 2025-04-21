import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lovelense/screens/guests/captured_images_screen.dart';
import 'package:lovelense/screens/guests/camera_screen.dart';
import 'package:lovelense/theme/app_colors.dart';
import 'package:lovelense/widgets/bottom_navigation_bar.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  _SocialScreenState createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  bool _allowScroll = false;

  @override
  void initState() {
    super.initState();
    _listenToScrollPermission();
  }

  void _listenToScrollPermission() {
    FirebaseFirestore.instance
        .collection('utils')
        .doc('allowSocials')
        .snapshots()
        .listen((snapshot) {
      final data = snapshot.data();
      setState(() {
        _allowScroll = data?['value'] ?? false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Socials'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              physics: _allowScroll
                  ? const AlwaysScrollableScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Event Schedule',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                ...List.generate(
                  5,
                  (index) => ListTile(
                    title: const Text('Special Day'),
                    trailing: const Text('10am'),
                  ),
                ),
                if (_allowScroll)
                  ...List.generate(
                    10,
                    (index) => ListTile(
                      title: Text('Guest Image $index'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SocialScreen()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CameraScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CapturedImagesScreen()),
            );
          }
        },
        backgroundColor: AppColors.secondary,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Theme.of(context).unselectedWidgetColor,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CameraScreen()),
          );
        },
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
