import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Result of permission request operation
class PermissionResult {
  final bool isGranted;
  final PermissionStatus status;
  final String message;

  PermissionResult({
    required this.isGranted,
    required this.status,
    required this.message,
  });
}

/// Enhanced file picker with permission handling
class FilePickerWithPermissions {
  /// Request storage permission based on platform and Android version
  static Future<PermissionResult> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), we need different permissions
      final storageResult = await Permission.storage.request();
      if (storageResult.isGranted) {
        return PermissionResult(
          isGranted: true,
          status: storageResult,
          message: 'Storage permission granted',
        );
      }

      // Try manage external storage for older Android versions
      final manageResult = await Permission.manageExternalStorage.request();
      return PermissionResult(
        isGranted: manageResult.isGranted,
        status: manageResult,
        message: manageResult.isGranted
            ? 'Storage permission granted'
            : 'Storage permission denied',
      );
    } else {
      // iOS - request photos permission
      final photosResult = await Permission.photos.request();
      return PermissionResult(
        isGranted: photosResult.isGranted,
        status: photosResult,
        message: photosResult.isGranted
            ? 'Photos permission granted'
            : 'Photos permission denied',
      );
    }
  }

  /// Request camera permission
  static Future<PermissionResult> _requestCameraPermission() async {
    final cameraResult = await Permission.camera.request();
    return PermissionResult(
      isGranted: cameraResult.isGranted,
      status: cameraResult,
      message: cameraResult.isGranted
          ? 'Camera permission granted'
          : 'Camera permission denied',
    );
  }

  /// Picks an image from gallery with permission check
  static Future<File?> pickImageFromGallery({int imageQuality = 80}) async {
    // Request appropriate permissions
    final storagePermission = await _requestStoragePermission();

    if (!storagePermission.isGranted) {
      print('Storage/Photos permission denied: ${storagePermission.message}');
      if (storagePermission.status == PermissionStatus.permanentlyDenied) {
        await openAppSettings();
      }
      return null;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: imageQuality,
    );

    if (picked != null) {
      return File(picked.path);
    }
    return null;
  }

  /// Picks an image from camera with permission check
  static Future<File?> pickImageFromCamera({int imageQuality = 80}) async {
    // Request camera permission
    final cameraPermission = await _requestCameraPermission();

    if (!cameraPermission.isGranted) {
      print('Camera permission denied: ${cameraPermission.message}');
      if (cameraPermission.status == PermissionStatus.permanentlyDenied) {
        await openAppSettings();
      }
      return null;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: imageQuality,
    );

    if (picked != null) {
      return File(picked.path);
    }
    return null;
  }

  /// Picks a document with permission check
  static Future<File?> pickDocument() async {
    final storagePermission = await _requestStoragePermission();

    if (!storagePermission.isGranted) {
      print('Storage permission denied: ${storagePermission.message}');
      if (storagePermission.status == PermissionStatus.permanentlyDenied) {
        await openAppSettings();
      }
      return null;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'txt',
        'rtf',
        'xls',
        'xlsx',
        'ppt',
        'pptx',
        'odt',
        'ods'
      ],
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  /// Picks a video file with permission check
  static Future<File?> pickVideo() async {
    final storagePermission = await _requestStoragePermission();

    if (!storagePermission.isGranted) {
      print('Storage permission denied: ${storagePermission.message}');
      if (storagePermission.status == PermissionStatus.permanentlyDenied) {
        await openAppSettings();
      }
      return null;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  /// Picks a video from camera with permission check
  static Future<File?> pickVideoFromCamera() async {
    final cameraPermission = await _requestCameraPermission();

    if (!cameraPermission.isGranted) {
      print('Camera permission denied: ${cameraPermission.message}');
      if (cameraPermission.status == PermissionStatus.permanentlyDenied) {
        await openAppSettings();
      }
      return null;
    }

    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.camera);

    if (picked != null) {
      return File(picked.path);
    }
    return null;
  }

  /// Picks an audio/music file with permission check
  static Future<File?> pickAudio() async {
    final storagePermission = await _requestStoragePermission();

    if (!storagePermission.isGranted) {
      print('Storage permission denied: ${storagePermission.message}');
      if (storagePermission.status == PermissionStatus.permanentlyDenied) {
        await openAppSettings();
      }
      return null;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  /// Picks any type of media file with permission check
  static Future<File?> pickMedia() async {
    final storagePermission = await _requestStoragePermission();

    if (!storagePermission.isGranted) {
      print('Storage permission denied: ${storagePermission.message}');
      if (storagePermission.status == PermissionStatus.permanentlyDenied) {
        await openAppSettings();
      }
      return null;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.media,
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  /// Picks any file type with permission check
  static Future<File?> pickAnyFile() async {
    final storagePermission = await _requestStoragePermission();

    if (!storagePermission.isGranted) {
      print('Storage permission denied: ${storagePermission.message}');
      if (storagePermission.status == PermissionStatus.permanentlyDenied) {
        await openAppSettings();
      }
      return null;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  /// Picks multiple files with permission check
  static Future<List<File>> pickMultipleFiles() async {
    final storagePermission = await _requestStoragePermission();

    if (!storagePermission.isGranted) {
      print('Storage permission denied: ${storagePermission.message}');
      if (storagePermission.status == PermissionStatus.permanentlyDenied) {
        await openAppSettings();
      }
      return [];
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      return result.files
          .where((file) => file.path != null)
          .map((file) => File(file.path!))
          .toList();
    }
    return [];
  }

  /// Picks multiple media files with permission check
  static Future<List<File>> pickMultipleMedia() async {
    final storagePermission = await _requestStoragePermission();

    if (!storagePermission.isGranted) {
      print('Storage permission denied: ${storagePermission.message}');
      if (storagePermission.status == PermissionStatus.permanentlyDenied) {
        await openAppSettings();
      }
      return [];
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.media,
    );

    if (result != null) {
      return result.files
          .where((file) => file.path != null)
          .map((file) => File(file.path!))
          .toList();
    }
    return [];
  }

  /// Picks files with custom extensions and permission check
  static Future<File?> pickCustomFile(List<String> allowedExtensions) async {
    final storagePermission = await _requestStoragePermission();

    if (!storagePermission.isGranted) {
      print('Storage permission denied: ${storagePermission.message}');
      if (storagePermission.status == PermissionStatus.permanentlyDenied) {
        await openAppSettings();
      }
      return null;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  /// Gets file information with permission check
  static Future<Map<String, dynamic>?> getFileInfo() async {
    final storagePermission = await _requestStoragePermission();

    if (!storagePermission.isGranted) {
      print('Storage permission denied: ${storagePermission.message}');
      if (storagePermission.status == PermissionStatus.permanentlyDenied) {
        await openAppSettings();
      }
      return null;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      final file = result.files.single;
      return {
        'name': file.name,
        'path': file.path,
        'size': file.size,
        'extension': file.extension,
      };
    }
    return null;
  }

  /// Picks a compressed/archive file with permission check
  static Future<File?> pickArchive() async {
    final storagePermission = await _requestStoragePermission();

    if (!storagePermission.isGranted) {
      print('Storage permission denied: ${storagePermission.message}');
      if (storagePermission.status == PermissionStatus.permanentlyDenied) {
        await openAppSettings();
      }
      return null;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip', 'rar', '7z', 'tar', 'gz'],
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  /// Check if required permissions are granted
  static Future<bool> checkPermissions() async {
    if (Platform.isAndroid) {
      final storageStatus = await Permission.storage.status;
      final manageStorageStatus = await Permission.manageExternalStorage.status;
      return storageStatus.isGranted || manageStorageStatus.isGranted;
    } else {
      final photosStatus = await Permission.photos.status;
      return photosStatus.isGranted;
    }
  }

  /// Request all essential permissions at once
  static Future<Map<String, PermissionResult>>
      requestEssentialPermissions() async {
    final results = <String, PermissionResult>{};

    // Request storage/photos permission
    results['storage'] = await _requestStoragePermission();

    // Request camera permission
    results['camera'] = await _requestCameraPermission();

    return results;
  }
}

/// Legacy functions for backward compatibility (now with permissions)
Future<File?> pickImageFromGallery({int imageQuality = 80}) async {
  return await FilePickerWithPermissions.pickImageFromGallery(
      imageQuality: imageQuality);
}

Future<File?> pickDocument() async {
  return await FilePickerWithPermissions.pickDocument();
}

Future<File?> pickVideo() async {
  return await FilePickerWithPermissions.pickVideo();
}

Future<File?> pickAudio() async {
  return await FilePickerWithPermissions.pickAudio();
}

Future<File?> pickMedia() async {
  return await FilePickerWithPermissions.pickMedia();
}

Future<File?> pickAnyFile() async {
  return await FilePickerWithPermissions.pickAnyFile();
}

Future<List<File>> pickMultipleFiles() async {
  return await FilePickerWithPermissions.pickMultipleFiles();
}

Future<List<File>> pickMultipleMedia() async {
  return await FilePickerWithPermissions.pickMultipleMedia();
}

Future<File?> pickCustomFile(List<String> allowedExtensions) async {
  return await FilePickerWithPermissions.pickCustomFile(allowedExtensions);
}

Future<Map<String, dynamic>?> getFileInfo() async {
  return await FilePickerWithPermissions.getFileInfo();
}

Future<File?> pickArchive() async {
  return await FilePickerWithPermissions.pickArchive();
}