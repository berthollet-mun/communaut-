// ignore_for_file: avoid_print

import 'package:community/data/models/user_model.dart';
import 'package:community/core/services/auth_service.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      error.value = '';

      final res = await _authService.login(email: email, password: password);

      if (res == null) {
        // AuthService a déjà loggé
        error.value = 'Email ou mot de passe incorrect';
        return false;
      }

      // res contient la réponse complète (ou au moins user)
      // On tente plusieurs chemins
      final dynamic u =
          res['user'] ?? (res['data'] is Map ? (res['data']['user']) : null);

      if (u is Map<String, dynamic>) {
        user.value = UserModel.fromJson(u);
        return true;
      }

      // fallback: si res est déjà user
      user.value = UserModel.fromJson(res);
      return true;
    } catch (e) {
      error.value = 'Erreur de connexion: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String nom,
    required String prenom,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final res = await _authService.register(
        email: email,
        password: password,
        nom: nom,
        prenom: prenom,
      );

      if (res == null) {
        // ✅ Ici, l'erreur est déjà dans ApiService, mais comme AuthService retourne null
        // on met un message générique (au moins, ApiService loggue la vraie erreur)
        error.value =
            'Inscription échouée. Vérifie le message exact dans la console (API RESPONSE).';
        return false;
      }

      final dynamic u =
          res['user'] ?? (res['data'] is Map ? (res['data']['user']) : null);

      if (u is Map<String, dynamic>) {
        user.value = UserModel.fromJson(u);
      } else {
        user.value = UserModel.fromJson(res);
      }

      return true;
    } catch (e) {
      error.value = 'Erreur d\'inscription: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> loadProfile() async {
    try {
      isLoading.value = true;
      error.value = '';

      final data = await _authService.getProfile();

      if (data != null) {
        user.value = UserModel.fromJson(data);
        return true;
      } else {
        error.value = 'Impossible de charger le profil';
        return false;
      }
    } catch (e, stackTrace) {
      print('Load profile error: $e');
      print('Stack: $stackTrace');
      error.value = 'Erreur de chargement du profil: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    user.value = null;
    Get.offAllNamed('/welcome');
  }

  Future<bool> checkAuth() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      return isLoggedIn;
    } catch (e) {
      error.value = 'Erreur de vérification d\'authentification: $e';
      return false;
    }
  }

  Future<bool> updateProfile({
    String? nom,
    String? prenom,
    String? password,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final success = await _authService.updateProfile(
        nom: nom,
        prenom: prenom,
        password: password,
      );

      if (success) {
        await loadProfile();
        return true;
      } else {
        error.value = 'Impossible de mettre à jour le profil';
        return false;
      }
    } catch (e) {
      error.value = 'Erreur: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
