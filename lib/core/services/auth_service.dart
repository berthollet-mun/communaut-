// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService extends GetxService {
  final ApiService _apiService = Get.find();
  final StorageService _storageService = Get.find();

  int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is String) {
      final parsed = int.tryParse(v);
      if (parsed != null) return parsed;
    }
    throw Exception('user_id invalide: $v');
  }

  /// ✅ Helper: récupère une valeur dans:
  /// - data[key]
  /// - data['data'][key]
  /// - data['user'][key]
  dynamic _pick(Map<String, dynamic> data, String key) {
    if (data.containsKey(key)) return data[key];
    final d = data['data'];
    if (d is Map && d.containsKey(key)) return d[key];
    final u = data['user'];
    if (u is Map && u.containsKey(key)) return u[key];
    return null;
  }

  Future<Map<String, dynamic>?> register({
    required String email,
    required String password,
    required String nom,
    required String prenom,
  }) async {
    final response = await _apiService.post('/auth/register', {
      'email': email,
      'password': password,
      'password_confirmation': password, // ✅ important si backend l'exige
      'nom': nom,
      'prenom': prenom,
    });

    print('Register response success: ${response.success}');
    print('Register response data: ${response.data}');
    print('Register response message: ${response.message}');

    if (response.success && response.data != null) {
      final data = response.data!;

      final token = _pick(data, 'token')?.toString();
      final userIdRaw = _pick(data, 'user_id');

      if (token != null && token.isNotEmpty) {
        await _storageService.setToken(token);
      }

      if (userIdRaw != null) {
        final int uid = _toInt(userIdRaw);
        await _storageService.setUserId(uid);
      }

      return data;
    }

    // ✅ IMPORTANT: on laisse le controller afficher response.message
    return null;
  }

  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post('/auth/login', {
      'email': email,
      'password': password,
    });

    print('Login response success: ${response.success}');
    print('Login response data: ${response.data}');
    print('Login response message: ${response.message}');

    if (response.success && response.data != null) {
      final data = response.data!;

      final token = _pick(data, 'token')?.toString();
      final userIdRaw = _pick(data, 'user_id');

      if (token != null && token.isNotEmpty) {
        await _storageService.setToken(token);
      }

      if (userIdRaw != null) {
        final int uid = _toInt(userIdRaw);
        await _storageService.setUserId(uid);
      }

      return data;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getProfile() async {
    print('=== GET PROFILE ===');

    final response = await _apiService.get('/auth/profile');

    print('Profile Response success: ${response.success}');
    print('Profile Response data: ${response.data}');
    print('Profile Response message: ${response.message}');
    print('===================');

    if (response.success && response.data != null) {
      final data = response.data!;

      // L'API renvoie { success: true, data: { id, email, nom, prenom, created_at } }
      if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
        return data['data'];
      }

      // Fallback si jamais c'est direct
      return data;
    }
    return null;
  }

  Future<bool> updateProfile({
    String? nom,
    String? prenom,
    String? password,
  }) async {
    final Map<String, dynamic> data = {};
    if (nom != null) data['nom'] = nom;
    if (prenom != null) data['prenom'] = prenom;
    if (password != null) data['password'] = password;

    final response = await _apiService.put('/auth/profile', data);
    return response.success;
  }

  Future<void> logout() async {
    await _storageService.clear();
  }

  Future<bool> isLoggedIn() async {
    try {
      final token = await _storageService.getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('Error in isLoggedIn: $e');
      return false;
    }
  }
}
