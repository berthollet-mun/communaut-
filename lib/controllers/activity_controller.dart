import 'package:community/core/services/activity_service.dart';
import 'package:community/data/models/activity_model.dart';
import 'package:get/get.dart';

class ActivityController extends GetxController {
  final ActivityService _activityService = Get.find();

  final RxList<ActivityModel> activities = <ActivityModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxInt limit = 50.obs;

  Future<void> loadCommunityActivities({required int communityId}) async {
    try {
      isLoading.value = true;
      error.value = '';

      final activitiesList = await _activityService.getCommunityActivities(
        communityId: communityId,
        limit: limit.value,
      );

      activities.assignAll(activitiesList);
    } catch (e) {
      error.value = 'Erreur de chargement de l\'historique: $e';
      activities.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadProjectActivities({
    required int communityId,
    required int projectId,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final activitiesList = await _activityService.getProjectActivities(
        communityId: communityId,
        projectId: projectId,
        limit: limit.value,
      );

      activities.assignAll(activitiesList);
    } catch (e) {
      error.value = 'Erreur de chargement de l\'historique: $e';
      activities.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void addActivityLocally(ActivityModel activity) {
    activities.insert(0, activity);

    // Garder seulement les X dernières activités
    if (activities.length > limit.value) {
      activities.removeLast();
    }
  }

  void updateLimit(int newLimit) {
    if (newLimit >= 1 && newLimit <= 100) {
      limit.value = newLimit;
    }
  }

  void clearActivities() {
    activities.clear();
    error.value = '';
  }

  List<ActivityModel> get filteredActivities {
    // Pour l'instant, retourne toutes les activités
    // Pourrait être étendu pour ajouter des filtres
    return activities.toList();
  }

  String getActivityIcon(String activityType) {
    switch (activityType) {
      case 'task_created':
        return '📝';
      case 'task_updated':
        return '✏️';
      case 'task_status_changed':
        return '🔄';
      case 'task_deleted':
        return '🗑️';
      case 'comment_added':
        return '💬';
      case 'project_created':
        return '📁';
      case 'project_updated':
        return '📋';
      case 'member_joined':
        return '👤';
      case 'member_role_changed':
        return '👑';
      default:
        return '📌';
    }
  }
}
