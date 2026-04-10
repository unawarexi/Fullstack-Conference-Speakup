import 'dart:io';
import 'package:flutter/foundation.dart';
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

/// Comprehensive permission handler utility class
class PermissionManager {
  /// Request camera permission
  static Future<PermissionResult> requestCamera() async {
    debugPrint('[PermissionManager] requestCamera');
    return await _requestSinglePermission(
      Permission.camera,
      'Camera access is required to take photos and videos',
    );
  }

  /// Request microphone permission
  static Future<PermissionResult> requestMicrophone() async {
    debugPrint('[PermissionManager] requestMicrophone');
    return await _requestSinglePermission(
      Permission.microphone,
      'Microphone access is required to record audio',
    );
  }

  /// Request location permission
  static Future<PermissionResult> requestLocation() async {
    debugPrint('[PermissionManager] requestLocation');
    return await _requestSinglePermission(
      Permission.location,
      'Location access is required to provide location-based services',
    );
  }

  /// Request location when in use permission
  static Future<PermissionResult> requestLocationWhenInUse() async {
    debugPrint('[PermissionManager] requestLocationWhenInUse');
    return await _requestSinglePermission(
      Permission.locationWhenInUse,
      'Location access is required when using the app',
    );
  }

  /// Request always location permission
  static Future<PermissionResult> requestLocationAlways() async {
    debugPrint('[PermissionManager] requestLocationAlways');
    return await _requestSinglePermission(
      Permission.locationAlways,
      'Always location access is required for background location services',
    );
  }

  /// Request storage permission
  static Future<PermissionResult> requestStorage() async {
    debugPrint('[PermissionManager] requestStorage');
    return await _requestSinglePermission(
      Permission.storage,
      'Storage access is required to save and read files',
    );
  }

  /// Request photos permission (iOS)
  static Future<PermissionResult> requestPhotos() async {
    debugPrint('[PermissionManager] requestPhotos');
    return await _requestSinglePermission(
      Permission.photos,
      'Photos access is required to select images from gallery',
    );
  }

  /// Request contacts permission
  static Future<PermissionResult> requestContacts() async {
    debugPrint('[PermissionManager] requestContacts');
    return await _requestSinglePermission(
      Permission.contacts,
      'Contacts access is required to access your contacts',
    );
  }

  /// Request calendar permission
  static Future<PermissionResult> requestCalendar() async {
    debugPrint('[PermissionManager] requestCalendar');
    return await _requestSinglePermission(
      Permission.calendarFullAccess,
      'Calendar access is required to manage events',
    );
  }

  /// Request notification permission
  static Future<PermissionResult> requestNotification() async {
    debugPrint('[PermissionManager] requestNotification');
    return await _requestSinglePermission(
      Permission.notification,
      'Notification permission is required to send you updates',
    );
  }

  /// Request phone permission
  static Future<PermissionResult> requestPhone() async {
    debugPrint('[PermissionManager] requestPhone');
    return await _requestSinglePermission(
      Permission.phone,
      'Phone access is required to make calls',
    );
  }

  /// Request SMS permission
  static Future<PermissionResult> requestSms() async {
    debugPrint('[PermissionManager] requestSms');
    return await _requestSinglePermission(
      Permission.sms,
      'SMS access is required to send messages',
    );
  }

  /// Request speech recognition permission
  static Future<PermissionResult> requestSpeech() async {
    debugPrint('[PermissionManager] requestSpeech');
    return await _requestSinglePermission(
      Permission.speech,
      'Speech recognition access is required for voice features',
    );
  }

  /// Request bluetooth permission
  static Future<PermissionResult> requestBluetooth() async {
    debugPrint('[PermissionManager] requestBluetooth');
    return await _requestSinglePermission(
      Permission.bluetooth,
      'Bluetooth access is required to connect with devices',
    );
  }

  /// Request access media location permission (Android)
  static Future<PermissionResult> requestAccessMediaLocation() async {
    debugPrint('[PermissionManager] requestAccessMediaLocation');
    return await _requestSinglePermission(
      Permission.accessMediaLocation,
      'Media location access is required to access media files with location',
    );
  }

  /// Request manage external storage permission (Android)
  static Future<PermissionResult> requestManageExternalStorage() async {
    debugPrint('[PermissionManager] requestManageExternalStorage');
    return await _requestSinglePermission(
      Permission.manageExternalStorage,
      'External storage management access is required',
    );
  }

  /// Request multiple permissions at once
  static Future<Map<Permission, PermissionResult>> requestMultiple(
    List<Permission> permissions,
  ) async {
    debugPrint('[PermissionManager] requestMultiple: $permissions');
    final results = <Permission, PermissionResult>{};

    try {
      final statuses = await permissions.request();

      for (final permission in permissions) {
        final status = statuses[permission] ?? PermissionStatus.denied;
        results[permission] = PermissionResult(
          isGranted: status.isGranted,
          status: status,
          message: _getPermissionMessage(permission, status),
        );
      }
    } catch (e) {
      for (final permission in permissions) {
        results[permission] = PermissionResult(
          isGranted: false,
          status: PermissionStatus.denied,
          message: 'Error requesting ${permission.toString()}: $e',
        );
      }
    }

    return results;
  }

  /// Check if permission is granted
  static Future<bool> isPermissionGranted(Permission permission) async {
    debugPrint('[PermissionManager] isPermissionGranted: $permission');
    final status = await permission.status;
    debugPrint('[PermissionManager] $permission status: $status');
    return status.isGranted;
  }

  /// Check multiple permissions status
  static Future<Map<Permission, bool>> checkMultiplePermissions(
    List<Permission> permissions,
  ) async {
    debugPrint('[PermissionManager] checkMultiplePermissions: $permissions');
    final results = <Permission, bool>{};

    for (final permission in permissions) {
      results[permission] = await isPermissionGranted(permission);
    }

    return results;
  }

  /// Open app settings if permission is permanently denied
  static Future<bool> openAppSettings() async {
    debugPrint('[PermissionManager] openAppSettings');
    return await openAppSettings();
  }

  /// Request essential app permissions (camera, microphone, storage)
  static Future<Map<Permission, PermissionResult>>
      requestEssentialPermissions() async {
    debugPrint('[PermissionManager] requestEssentialPermissions');
    return await requestMultiple([
      Permission.camera,
      Permission.microphone,
      Permission.storage,
      Permission.photos,
    ]);
  }

  /// Request location-related permissions
  static Future<Map<Permission, PermissionResult>>
      requestLocationPermissions() async {
    debugPrint('[PermissionManager] requestLocationPermissions');
    return await requestMultiple([
      Permission.location,
      Permission.locationWhenInUse,
    ]);
  }

  /// Request communication permissions
  static Future<Map<Permission, PermissionResult>>
      requestCommunicationPermissions() async {
    debugPrint('[PermissionManager] requestCommunicationPermissions');
    return await requestMultiple([
      Permission.contacts,
      Permission.phone,
      Permission.sms,
    ]);
  }

  /// Request storage permission (handles Android 11+ manage external storage)
  static Future<PermissionResult> requestStorageSmart() async {
    debugPrint('[PermissionManager] requestStorageSmart');
    if (Platform.isAndroid) {
      final androidVersion = int.tryParse(
        (await _getAndroidSdkInt()) ?? '0',
      );
      if (androidVersion != null && androidVersion >= 30) {
        // Android 11+ needs manageExternalStorage
        final manageResult = await _requestSinglePermission(
          Permission.manageExternalStorage,
          'Manage external storage access is required to pick files',
        );
        if (!manageResult.isGranted) return manageResult;
        // Also check storage for completeness
        final storageResult = await _requestSinglePermission(
          Permission.storage,
          'Storage access is required to pick files',
        );
        if (!storageResult.isGranted) return storageResult;
        return PermissionResult(
          isGranted: true,
          status: PermissionStatus.granted,
          message: 'Storage permission granted',
        );
      }
    }
    // iOS or Android < 11
    return await _requestSinglePermission(
      Platform.isIOS ? Permission.photos : Permission.storage,
      Platform.isIOS
          ? 'Photos access is required to select images from gallery'
          : 'Storage access is required to pick files',
    );
  }

  /// Helper to get Android SDK version
  static Future<String?> _getAndroidSdkInt() async {
    debugPrint('[PermissionManager] _getAndroidSdkInt');
    try {
      // Only works if you add 'device_info_plus' or similar package.
      // For now, just return null to fallback.
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Private helper method to request single permission
  static Future<PermissionResult> _requestSinglePermission(
    Permission permission,
    String description,
  ) async {
    debugPrint('[PermissionManager] _requestSinglePermission: $permission');
    try {
      final status = await permission.request();

      return PermissionResult(
        isGranted: status.isGranted,
        status: status,
        message: _getPermissionMessage(permission, status),
      );
    } catch (e) {
      return PermissionResult(
        isGranted: false,
        status: PermissionStatus.denied,
        message: 'Error requesting permission: $e',
      );
    }
  }

  /// Get user-friendly message based on permission status
  static String _getPermissionMessage(
      Permission permission, PermissionStatus status) {
    debugPrint('[PermissionManager] _getPermissionMessage: $permission, $status');
    final permissionName = permission.toString().split('.').last;

    switch (status) {
      case PermissionStatus.granted:
        return '$permissionName permission granted successfully';
      case PermissionStatus.denied:
        return '$permissionName permission denied';
      case PermissionStatus.permanentlyDenied:
        return '$permissionName permission permanently denied. Please enable it in app settings';
      case PermissionStatus.restricted:
        return '$permissionName permission is restricted';
      case PermissionStatus.limited:
        return '$permissionName permission granted with limitations';
      case PermissionStatus.provisional:
        return '$permissionName permission granted provisionally';
    }
  }

  /// Handle permission result and show appropriate action
  static Future<void> handlePermissionResult(
    PermissionResult result, {
    Function? onGranted,
    Function? onDenied,
    Function? onPermanentlyDenied,
  }) async {
    debugPrint('[PermissionManager] handlePermissionResult: $result');
    if (result.isGranted) {
      onGranted?.call();
    } else if (result.status == PermissionStatus.permanentlyDenied) {
      onPermanentlyDenied?.call();
    } else {
      onDenied?.call();
    }
  }

  /// Check if device supports permission
  static Future<bool> isPermissionSupported(Permission permission) async {
    debugPrint('[PermissionManager] isPermissionSupported: $permission');
    try {
      await permission.status;
      return true;
    } catch (e) {
      return false;
    }
  }
}