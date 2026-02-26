// ignore_for_file: avoid_print

import 'package:community/controllers/activity_controller.dart';
import 'package:community/controllers/auth_controller.dart';
import 'package:community/controllers/comment_controller.dart';
import 'package:community/controllers/community_controller.dart';
import 'package:community/controllers/project_controller.dart';
import 'package:community/controllers/task_controller.dart';
import 'package:community/controllers/theme_controller.dart';
import 'package:community/core/services/Community_service.dart';
import 'package:community/core/services/activity_service.dart';
import 'package:community/core/services/api_service.dart';
import 'package:community/core/services/auth_service.dart';
import 'package:community/core/services/comment_service.dart';
import 'package:community/core/services/project_service.dart';
import 'package:community/core/services/storage_service.dart';
import 'package:community/core/services/task_service.dart';
import 'package:get/get.dart';

class AppInitialization {
  static Future<void> initialize() async {
    print('🚀 Démarrage de l\'initialisation de l\'application...');

    try {
      // Étape 1: Services de base (doivent être initiés en premier)
      await _initializeCoreServices();

      // Étape 2: Services métier
      _initializeBusinessServices();

      // Étape 3: Controllers
      _initializeControllers();

      print('🎉 Initialisation de l\'application terminée avec succès !');
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation: $e');
      rethrow;
    }
  }

  static Future<void> _initializeCoreServices() async {
    print('🔧 Initialisation des services de base...');

    // 1. StorageService (doit être le premier)
    final storageService = StorageService();
    await Get.putAsync<StorageService>(() async {
      return await storageService.init();
    }, permanent: true);
    print('   ✅ StorageService initialisé');

    // 2. ApiService (dépend de StorageService)
    Get.put(ApiService(), permanent: true);
    print('   ✅ ApiService initialisé');
  }

  static void _initializeBusinessServices() {
    print('🔧 Initialisation des services métier...');

    Get.put(AuthService(), permanent: true);
    print('   ✅ AuthService initialisé');

    Get.put(CommunityService(), permanent: true);
    print('   ✅ CommunityService initialisé');

    Get.put(ProjectService(), permanent: true);
    print('   ✅ ProjectService initialisé');

    Get.put(TaskService(), permanent: true);
    print('   ✅ TaskService initialisé');

    Get.put(CommentService(), permanent: true);
    print('   ✅ CommentService initialisé');

    Get.put(ActivityService(), permanent: true);
    print('   ✅ ActivityService initialisé');
  }

  static void _initializeControllers() {
    print('🔧 Initialisation des controllers...');

    Get.put(AuthController(), permanent: true);
    print('   ✅ AuthController initialisé');

    Get.put(CommunityController(), permanent: true);
    print('   ✅ CommunityController initialisé');

    Get.put(ProjectController(), permanent: true);
    print('   ✅ ProjectController initialisé');

    Get.put(TaskController(), permanent: true);
    print('   ✅ TaskController initialisé');

    Get.put(CommentController(), permanent: true);
    print('   ✅ CommentController initialisé');

    Get.put(ActivityController(), permanent: true);
    print('   ✅ ActivityController initialisé');

    Get.put(ThemeController(), permanent: true);
    print('   ✅ ThemeController initialisé');
  }
}
