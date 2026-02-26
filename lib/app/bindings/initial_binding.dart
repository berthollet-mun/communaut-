import 'package:community/controllers/activity_controller.dart';
import 'package:community/controllers/auth_controller.dart';
import 'package:community/controllers/comment_controller.dart';
import 'package:community/controllers/community_controller.dart';
import 'package:community/controllers/community_settings_controller.dart';
import 'package:community/controllers/notification_controller.dart';
import 'package:community/controllers/project_controller.dart';
import 'package:community/controllers/task_controller.dart';
import 'package:community/controllers/theme_controller.dart';
import 'package:community/core/services/Community_service.dart';
import 'package:community/core/services/activity_service.dart';
import 'package:community/core/services/api_service.dart';
import 'package:community/core/services/auth_service.dart';
import 'package:community/core/services/comment_service.dart';
import 'package:community/core/services/notification_service.dart';
import 'package:community/core/services/project_service.dart';
import 'package:community/core/services/storage_service.dart';
import 'package:community/core/services/task_service.dart';
import 'package:get/get.dart';

class InitialBinding extends Bindings {
  @override
  Future<void> dependencies() async {
    // 1. Initialiser StorageService en PREMIER
    await Get.putAsync<StorageService>(() async {
      final service = StorageService();
      return await service.init();
    }, permanent: true);

    // 2. Initialiser ApiService
    Get.lazyPut(() => ApiService(), fenix: true);

    // 3. Initialiser les services
    Get.lazyPut(() => AuthService(), fenix: true);
    Get.lazyPut(() => CommunityService(), fenix: true);
    Get.lazyPut(() => ProjectService(), fenix: true);
    Get.lazyPut(() => TaskService(), fenix: true);
    Get.lazyPut(() => CommentService(), fenix: true);
    Get.lazyPut(() => ActivityService(), fenix: true);
    Get.lazyPut(() => NotificationService(), fenix: true);
    Get.lazyPut(() => CommunitySettingsController(), fenix: true); 

    // 4. Initialiser les controllers
    Get.lazyPut(() => AuthController(), fenix: true);
    Get.lazyPut(() => CommunityController(), fenix: true);
    Get.lazyPut(() => ProjectController(), fenix: true);
    Get.lazyPut(() => TaskController(), fenix: true);
    Get.lazyPut(() => CommentController(), fenix: true);
    Get.lazyPut(() => ActivityController(), fenix: true);
    Get.lazyPut(() => NotificationController(), fenix: true);
    Get.lazyPut(() => ThemeController(), fenix: true);
    
  }
}
