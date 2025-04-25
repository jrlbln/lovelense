import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/google_drive_service.dart';

final googleDriveServiceProvider = Provider((ref) => GoogleDriveService());
