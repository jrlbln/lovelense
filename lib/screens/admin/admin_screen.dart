import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/google_drive_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final GoogleDriveService _driveService = GoogleDriveService();
  List<Map<String, dynamic>> _photos = [];
  bool _isLoading = true;
  bool _allowSocials = false;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
    _loadAllowSocials();
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _isLoading = true;
    });

    final photos = await _driveService.listAllPhotos();

    // Sort by upload date (newest first)
    photos.sort((a, b) =>
        (b['uploadedAt'] as DateTime).compareTo(a['uploadedAt'] as DateTime));

    setState(() {
      _photos = photos;
      _isLoading = false;
    });
  }

  Future<void> _loadAllowSocials() async {
    final doc = await FirebaseFirestore.instance
        .collection('utils')
        .doc('allowSocials')
        .get();
    setState(() {
      _allowSocials = doc.data()?['value'] ?? false;
    });
  }

  Widget _buildToggleScrollPermission() {
    return SwitchListTile(
      title: const Text('Allow Socials'),
      value: _allowSocials,
      onChanged: (value) async {
        await FirebaseFirestore.instance
            .collection('utils')
            .doc('allowSocials')
            .set({'value': value});
        setState(() {
          _allowSocials = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wedding Album'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPhotos,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildToggleScrollPermission(),
                Expanded(
                  child: _photos.isEmpty
                      ? const Center(child: Text('No photos uploaded yet'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _photos.length,
                          itemBuilder: (context, index) {
                            final photo = _photos[index];
                            return _buildPhotoItem(photo);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildPhotoItem(Map<String, dynamic> photo) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: photo['thumbnailLink'] != null
            ? Image.network(
                photo['thumbnailLink'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.error, color: Colors.red),
                  );
                },
              )
            : Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 1),
              ),
      ),
    );
  }

  void _showPhotoDetails(Map<String, dynamic> photo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Center(
            child: photo['thumbnailLink'] != null
                ? Image.network(
                    photo['thumbnailLink'],
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.error, color: Colors.red, size: 50),
                      );
                    },
                  )
                : const Text('Image not available'),
          ),
        );
      },
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }
}
