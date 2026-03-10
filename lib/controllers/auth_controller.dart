// ignore_for_file: avoid_print

import 'package:community/core/services/auth_service.dart';
import 'package:community/data/models/user_model.dart';
import 'package:get/get.dart';

class RegisterResult {
  final bool success;
  final bool isAuthenticated;
  final String message;

  const RegisterResult({
    required this.success,
    required this.isAuthenticated,
    required this.message,
  });
}

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
        error.value = 'Email ou mot de passe incorrect';
        return false;
      }

      final dynamic u =
          res['user'] ?? (res['data'] is Map ? (res['data']['user']) : null);

      if (u is Map<String, dynamic>) {
        user.value = UserModel.fromJson(u);
        return true;
      }

      final dynamic directData = res['data'];
      if (directData is Map<String, dynamic> &&
          (directData.containsKey('user_id') ||
              directData.containsKey('id') ||
              directData.containsKey('email'))) {
        user.value = UserModel.fromJson(directData);
        return true;
      }

      user.value = UserModel.fromJson(res);
      return true;
    } catch (e) {
      error.value = 'Erreur de connexion: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<RegisterResult> register({
    required String email,
    required String password,
    required String nom,
    required String prenom,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _authService.register(
        email: email,
        password: password,
        nom: nom,
        prenom: prenom,
      );

      if (!response.success) {
        final message = _normalizeRegisterError(response.displayMessage);
        error.value = message;
        return RegisterResult(
          success: false,
          isAuthenticated: false,
          message: message,
        );
      }

      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final token = _pick(data, 'token')?.toString().trim() ?? '';
      final isAuthenticated = token.isNotEmpty;
      final userPayload = _extractUserPayload(data);

      if (userPayload != null) {
        user.value = UserModel.fromJson(userPayload);
      } else if (_looksLikeUserPayload(data)) {
        user.value = UserModel.fromJson(data);
      } else if (!isAuthenticated) {
        user.value = null;
      }

      return RegisterResult(
        success: true,
        isAuthenticated: isAuthenticated,
        message: _normalizeRegisterSuccess(
          response.displayMessage,
          isAuthenticated: isAuthenticated,
        ),
      );
    } catch (e) {
      final message = _normalizeRegisterError('Erreur d\'inscription: $e');
      error.value = message;
      return RegisterResult(
        success: false,
        isAuthenticated: false,
        message: message,
      );
    } finally {
      isLoading.value = false;
    }
  }

  dynamic _pick(Map<String, dynamic> data, String key) {
    if (data.containsKey(key)) return data[key];

    final nestedData = data['data'];
    if (nestedData is Map<String, dynamic> && nestedData.containsKey(key)) {
      return nestedData[key];
    }

    final nestedUser = data['user'];
    if (nestedUser is Map<String, dynamic> && nestedUser.containsKey(key)) {
      return nestedUser[key];
    }

    return null;
  }

  Map<String, dynamic>? _extractUserPayload(Map<String, dynamic> data) {
    final nestedUser = data['user'];
    if (nestedUser is Map<String, dynamic>) {
      return nestedUser;
    }

    final nestedData = data['data'];
    if (nestedData is Map<String, dynamic>) {
      final userFromNestedData = nestedData['user'];
      if (userFromNestedData is Map<String, dynamic>) {
        return userFromNestedData;
      }

      if (_looksLikeUserPayload(nestedData)) {
        return nestedData;
      }
    }

    return null;
  }

  bool _looksLikeUserPayload(Map<String, dynamic> data) {
    return data.containsKey('email') ||
        data.containsKey('user_id') ||
        data.containsKey('id');
  }

  String _normalizeRegisterSuccess(
    String rawMessage, {
    required bool isAuthenticated,
  }) {
    final message = rawMessage.trim();
    if (message.isNotEmpty) {
      return message;
    }

    if (isAuthenticated) {
      return 'Votre compte a été créé avec succès.';
    }

    return 'Votre compte a été créé. Connectez-vous pour continuer.';
  }

  String _normalizeRegisterError(String rawMessage) {
    final message = rawMessage.trim();
    if (message.isEmpty) {
      return 'Inscription impossible pour le moment. Réessayez dans quelques instants.';
    }

    final lowered = message.toLowerCase();
    if (lowered.contains('failed to fetch') ||
        lowered.contains('clientexception') ||
        lowered.contains('network_error') ||
        lowered.contains('socketexception')) {
      return 'Impossible de contacter le serveur. Vérifiez votre connexion Internet puis réessayez.';
    }

    return message;
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
