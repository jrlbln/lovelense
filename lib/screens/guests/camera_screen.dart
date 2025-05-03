import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../services/google_drive_service.dart';
import 'package:lovelense/screens/guests/social_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isUploading = false; // Track upload state
  int _remainingShots = 0; // Track remaining shots
  final GoogleDriveService _driveService = GoogleDriveService();

  @override
  void initState() {
    super.initState();
    _setLandscapeMode();
    _initializeCamera();
    _loadRemainingShots(); // Load remaining shots on init
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

  Future<void> _loadRemainingShots() async {
    final shots = await _driveService.getRemainingShots();
    setState(() {
      _remainingShots = shots;
    });
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
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isUploading) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Pause the camera preview immediately
      await _controller!.pausePreview();

      final XFile photo = await _controller!.takePicture();
      final file = File(photo.path);

      // Upload to Google Drive
      final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // UPDATED: We're now passing a flag to prevent double decrement
      final fileId = await _driveService.uploadImage(
        file,
        fileName,
        shouldDecrementShots: false,
      );

      if (fileId != null) {
        await _driveService.decrementRemainingShots();
        await _loadRemainingShots();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo uploaded successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SocialScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });

      // Make sure this is called regardless of success or failure
      try {
        if (_controller?.value.isInitialized ?? false) {
          await _controller!.resumePreview();
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error resuming camera preview: $e');
        }
      }
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

    final screenSize = MediaQuery.of(context).size;
    final cameraWidth = _controller!.value.previewSize!.height;
    final cameraHeight = _controller!.value.previewSize!.width;
    final cameraAspectRatio = cameraWidth / cameraHeight;
    final overlayAspectRatio = 3900 / 2400;
    final overlayWidth = screenSize.height * overlayAspectRatio;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          SizedBox(
            width: overlayWidth,
            height: screenSize.height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: AspectRatio(
                    aspectRatio: cameraAspectRatio,
                    child: CameraPreview(_controller!),
                  ),
                ),
                // Positioned.fill(
                //   child: Image.asset(
                //     'assets/images/CameraOverlay.png',
                //     fit: BoxFit.cover,
                //   ),
                // ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
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
                          child: _isUploading
                              ? LoadingAnimationWidget.staggeredDotsWave(
                                  color: Colors.white,
                                  size: 40,
                                )
                              : Container(
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
                    const SizedBox(height: 20),
                    Text(
                      'Remaining Shots: $_remainingShots',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
