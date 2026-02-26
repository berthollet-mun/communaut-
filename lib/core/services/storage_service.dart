// ignore_for_file: avoid_print, unnecessary_null_comparison

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  // Initialisation asynchrone
  Future<StorageService> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      print('✅ StorageService initialized successfully');
      return this;
    } catch (e) {
      print('❌ Error initializing StorageService: $e');
      rethrow;
    }
  }

  // Vérifier si initialisé
  bool get isInitialized => _prefs != null;

  // Méthodes de base
  Future<void> setToken(String token) async {
    await _prefs.setString('token', token);
  }

  Future<String?> getToken() async {
    return _prefs.getString('token');
  }

  Future<void> removeToken() async {
    await _prefs.remove('token');
  }

  Future<void> setUserId(int userId) async {
    await _prefs.setInt('user_id', userId);
  }

  Future<int?> getUserId() async {
    return _prefs.getInt('user_id');
  }

  Future<void> setCurrentCommunityId(int communityId) async {
    await _prefs.setInt('current_community_id', communityId);
  }

  Future<int?> getCurrentCommunityId() async {
    return _prefs.getInt('current_community_id');
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}
