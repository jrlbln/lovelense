import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'guests/camera_screen.dart';
import 'admin/admin_screen.dart';
import '../services/google_drive_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GoogleDriveService _driveService = GoogleDriveService();
  int _remainingShots = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRemainingShots();
  }

  Future<void> _loadRemainingShots() async {
    setState(() {
      _isLoading = true;
    });

    final shots = await _driveService.getRemainingShots();

    setState(() {
      _remainingShots = shots;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wedding Disposable Camera'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome card
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.amber,
                            child: Icon(Icons.camera_alt,
                                size: 40, color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Welcome, ${user?.displayName ?? 'Guest'}!',
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Capture your special moments with our wedding disposable camera',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Camera stats
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.photo_camera_back,
                              color: Colors.amber, size: 30),
                          const SizedBox(width: 8),
                          Text(
                            'You have $_remainingShots shots remaining',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Camera button
                  ElevatedButton.icon(
                    onPressed: _remainingShots > 0
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CameraScreen(),
                              ),
                            ).then((_) => _loadRemainingShots());
                          }
                        : null,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photos'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // View album button
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('View Wedding Album'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),

                  const Spacer(),

                  // Info text
                  if (_remainingShots <= 0)
                    const Text(
                      'You\'ve used all your shots! You can still view the wedding album.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            ),
    );
  }
}
