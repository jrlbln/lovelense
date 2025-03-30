import 'dart:io';
import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleDriveService {
  // Replace with your actual folder ID and ensure the account is authenticated
  static const String _weddingFolderId = '1kjxzKUMCmwq1YMj1TlaMxM4VtBWIdL2B';
  static const String _imageMimeType = 'image/jpeg';

  // Load the service account credentials from assets
  Future<String> _loadServiceAccountJson() async {
    return await rootBundle.loadString('assets/service_account.json');
  }

  // Get authenticated HTTP client with service account
  Future<http.Client> _getAuthenticatedClient() async {
    final serviceAccountJson = await _loadServiceAccountJson();
    final credentials = ServiceAccountCredentials.fromJson(serviceAccountJson);

    return await clientViaServiceAccount(
        credentials, [drive.DriveApi.driveFileScope]);
  }

  // Upload an image to Google Drive
  Future<String?> uploadImage(File imageFile, String fileName) async {
    try {
      final client = await _getAuthenticatedClient();
      final driveApi = drive.DriveApi(client);

      // Create a drive file
      var driveFile = drive.File();
      driveFile.name = fileName;
      driveFile.parents = [_weddingFolderId];

      // Upload file to drive
      final response = await driveApi.files.create(
        driveFile,
        uploadMedia: drive.Media(
          imageFile.openRead(),
          await imageFile.length(),
          contentType: _imageMimeType,
        ),
      );

      // Store metadata in Firestore
      await _storePhotoMetadata(response.id!, fileName);

      // Decrement remaining shots
      await _decrementRemainingShots();

      return response.id;
    } catch (e) {
      print('Error uploading to Google Drive: $e');
      return null;
    }
  }

  // Store photo metadata in Firestore
  Future<void> _storePhotoMetadata(String fileId, String fileName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('photos').add({
      'userId': user.uid,
      'userName': user.displayName ?? 'Anonymous',
      'driveFileId': fileId,
      'fileName': fileName,
      'uploadedAt': FieldValue.serverTimestamp(),
      'isProcessed': true
    });
  }

  // Get remaining shots for current user
  Future<int> getRemainingShots() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      // First time user, create entry with default 5 shots
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'displayName': user.displayName ?? 'Anonymous',
        'email': user.email,
        'remainingShots': 5,
        'createdAt': FieldValue.serverTimestamp()
      });
      return 5;
    }

    return doc.data()?['remainingShots'] ?? 0;
  }

  // Decrement remaining shots
  Future<void> _decrementRemainingShots() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'remainingShots': FieldValue.increment(-1)});
  }

  // List all wedding photos (for admin)
  Future<List<Map<String, dynamic>>> listAllPhotos() async {
    try {
      final client = await _getAuthenticatedClient();
      final driveApi = drive.DriveApi(client);

      // Get files from wedding folder
      final fileList = await driveApi.files.list(
          q: "'$_weddingFolderId' in parents and mimeType contains 'image/'",
          $fields: 'files(id, name, thumbnailLink, webViewLink)');

      final List<Map<String, dynamic>> photos = [];

      if (fileList.files != null) {
        // Get metadata from Firestore
        final snapshot =
            await FirebaseFirestore.instance.collection('photos').get();

        final metadataMap = {};
        for (var doc in snapshot.docs) {
          metadataMap[doc.data()['driveFileId']] = doc.data();
        }

        // Combine Drive and Firestore data
        for (var file in fileList.files!) {
          final metadata = metadataMap[file.id] ?? {};
          photos.add({
            'id': file.id,
            'name': file.name,
            'thumbnailLink': file.thumbnailLink,
            'webViewLink': file.webViewLink,
            'uploadedBy': metadata['userName'] ?? 'Unknown',
            'uploadedAt': metadata['uploadedAt']?.toDate() ?? DateTime.now(),
          });
        }
      }

      return photos;
    } catch (e) {
      print('Error listing Google Drive files: $e');
      return [];
    }
  }
}
