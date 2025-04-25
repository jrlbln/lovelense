import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/google_drive_service.dart';
import '../../theme/app_gradient.dart';

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
  bool _isListView = true; // Toggle between List and Tile views

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
    return Switch(
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.primaryGradient,
        ),
        padding: const EdgeInsets.all(32),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _photos.isEmpty
                        ? const Center(child: Text('No photos uploaded yet'))
                        : _isListView
                            ? _buildListView()
                            : _buildGridView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const Text(
            'Images',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          if (_photos.any((photo) => photo['isSelected'] ?? false))
            Row(
              children: [
                Text(
                    '${_photos.where((photo) => photo['isSelected'] ?? false).length} Selected'),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteSelectedPhotos,
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: _downloadSelectedPhotos,
                ),
              ],
            ),
          IconButton(
            icon: Icon(_isListView ? Icons.grid_view : Icons.list),
            onPressed: () {
              setState(() {
                _isListView = !_isListView;
              });
            },
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              const Text('Allow Socials'),
              const SizedBox(width: 8),
              _buildToggleScrollPermission(),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {}, // Static for now
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        final photo = _photos[index];
        return ListTile(
          leading: photo['thumbnailLink'] != null
              ? Image.network(photo['thumbnailLink'], width: 50, height: 50)
              : const Icon(Icons.image),
          title: Text(photo['name']),
          subtitle: Text('Captured by: ${photo['owner']}'),
          onTap: () => _openPhotoDialog(photo),
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        // Setting childAspectRatio to 1 makes the tiles square
        childAspectRatio: 1.0,
      ),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        final photo = _photos[index];
        return GestureDetector(
          onTap: () => _openPhotoDialog(photo),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 3, // Give more space to the image
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                    child: photo['thumbnailLink'] != null
                        ? Image.network(
                            photo['thumbnailLink'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image),
                          ),
                  ),
                ),
                Expanded(
                  flex: 1, // Smaller space for the text
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      photo['name'],
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openPhotoDialog(Map<String, dynamic> photo) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          // Remove the default constraints to allow the dialog to resize based on content
          child: LayoutBuilder(
            builder: (context, constraints) {
              return FutureBuilder<Size>(
                future: _getImageDimensions(photo['thumbnailLink']),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      width: 300,
                      height: 300,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final imageSize = snapshot.data!;
                  final dialogWidth = constraints.maxWidth * 0.8;
                  final imageAspectRatio = imageSize.width / imageSize.height;

                  // Determine if image is landscape or portrait and adjust accordingly
                  double dialogContentWidth;

                  if (imageAspectRatio > 1) {
                    // Landscape image
                    dialogContentWidth = dialogWidth;
                    // Add space for buttons and text
                  } else {
                    // Portrait image
                    final maxHeight = constraints.maxHeight * 0.8;
                    dialogContentWidth = maxHeight * imageAspectRatio;
                  }

                  return Container(
                    width: dialogContentWidth.clamp(
                        300.0, constraints.maxWidth - 32),
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight - 32,
                      maxWidth: constraints.maxWidth - 32,
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 16, left: 16, right: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (photo['thumbnailLink'] != null)
                            Flexible(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  photo['thumbnailLink'],
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              photo['name'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          ButtonBar(
                            alignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  // Add edit functionality here
                                },
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.delete),
                                label: const Text('Delete'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _deletePhoto(photo);
                                },
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.download),
                                label: const Text('Download'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _downloadPhoto(photo);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  // Helper method to get image dimensions
  Future<Size> _getImageDimensions(String? imageUrl) async {
    if (imageUrl == null) {
      return const Size(300, 300); // Default size if no image
    }

    final completer = Completer<Size>();
    final image = NetworkImage(imageUrl);

    image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((info, _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );

    // If image loading takes too long, return a default size after timeout
    return await completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () => const Size(300, 300),
    );
  }

  void _deleteSelectedPhotos() {
    // Implement delete logic
  }

  void _downloadSelectedPhotos() {
    // Implement download logic
  }

  void _deletePhoto(Map<String, dynamic> photo) {
    // Implement delete logic
  }

  void _downloadPhoto(Map<String, dynamic> photo) {
    // Implement download logic
  }
}
