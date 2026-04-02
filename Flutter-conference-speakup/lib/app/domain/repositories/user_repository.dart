import 'package:dio/dio.dart';
import 'package:video_confrence_app/core/network/api_client.dart';
import 'package:video_confrence_app/core/apis/endpoints.dart';
import 'package:video_confrence_app/app/domain/models/user_model.dart';

class UserRepository {
  final _api = ApiClient.instance;

  Future<UserModel> getProfile() async {
    final res = await _api.get(ApiEndpoints.userProfile);
    return UserModel.fromJson(res.data['data']);
  }

  Future<UserModel> updateProfile({
    String? fullName,
    String? bio,
  }) async {
    final res = await _api.put(ApiEndpoints.userProfile, data: {
      if (fullName != null) 'fullName': fullName,
      if (bio != null) 'bio': bio,
    });
    return UserModel.fromJson(res.data['data']);
  }

  Future<UserModel> updateAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath),
    });
    final res = await _api.upload(ApiEndpoints.userAvatar, formData: formData);
    return UserModel.fromJson(res.data['data']);
  }

  Future<List<DeviceModel>> getDevices() async {
    final res = await _api.get(ApiEndpoints.userDevices);
    final list = res.data['data'] as List;
    return list.map((e) => DeviceModel.fromJson(e)).toList();
  }

  Future<void> registerDevice({
    required String fcmToken,
    required String platform,
  }) async {
    await _api.post(ApiEndpoints.userDevices, data: {
      'fcmToken': fcmToken,
      'platform': platform,
    });
  }

  Future<void> removeDevice(String deviceId) =>
      _api.delete(ApiEndpoints.userDevice(deviceId));

  Future<void> updateOnlineStatus(bool isOnline) =>
      _api.put(ApiEndpoints.userOnlineStatus, data: {'isOnline': isOnline});
}
