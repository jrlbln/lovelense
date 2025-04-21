import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../services/google_drive_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  final GoogleDriveService _driveService = GoogleDriveService();

  @override
  void initState() {
    super.initState();
    _setLandscapeMode();
    _initializeCamera();
  }

  Future<void> _setLandscapeMode() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      _controller = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing camera: $e');
      }
    }
  }

  @override
  void dispose() {
    _resetOrientation();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _resetOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final XFile photo = await _controller!.takePicture();
      final file = File(photo.path);

      // Upload to Google Drive
      final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final fileId = await _driveService.uploadImage(file, fileName);

      if (fileId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo uploaded successfully!')),
        );
      }
      Navigator.pushReplacementNamed(context, '/social');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Calculate aspect ratio of the screen
    final screenSize = MediaQuery.of(context).size;

    // Calculate aspect ratio of the camera
    final cameraWidth = _controller!.value.previewSize!.height;
    final cameraHeight = _controller!.value.previewSize!.width;
    final cameraAspectRatio = cameraWidth / cameraHeight;

    // Determine the overlay width based on the aspect ratio of your overlay image (3900x2400)
    final overlayAspectRatio = 3900 / 2400;
    final overlayWidth = screenSize.height * overlayAspectRatio;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          // Camera preview and overlay container
          SizedBox(
            width: overlayWidth,
            height: screenSize.height,
            child: Stack(
              children: [
                // Camera Preview
                Positioned.fill(
                  child: AspectRatio(
                    aspectRatio: cameraAspectRatio,
                    child: CameraPreview(_controller!),
                  ),
                ),
                // Overlay Image
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/CameraOverlay.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          // Right side black space with centered shutter button
          Expanded(
            child: Container(
              color: Colors.black,
              child: Center(
                child: GestureDetector(
                  onTap: _takePhoto,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: Colors.transparent,
                    ),
                    child: Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
