import 'package:community/core/services/project_service.dart';
import 'package:community/data/models/project_model.dart';
import 'package:get/get.dart';

class ProjectController extends GetxController {
  final ProjectService _projectService = Get.find();

  final RxList<ProjectModel> projects = <ProjectModel>[].obs;
  final Rx<ProjectModel?> currentProject = Rx<ProjectModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool showArchived = false.obs;

  // ✅ Cache pour savoir quelle communauté est chargée
  int? _loadedCommunityId;
  int? get loadedCommunityId => _loadedCommunityId;

  void clearCurrentProject() {
    currentProject.value = null;
  }

  Future<void> loadProjects(int communityId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final projectsList = await _projectService.getProjects(
        communityId: communityId,
        includeArchived: showArchived.value,
      );

      projects.assignAll(projectsList);
      _loadedCommunityId = communityId; // ✅ Marquer comme chargé
    } catch (e) {
      error.value = 'Erreur de chargement des projets: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<ProjectModel?> createProject({
    required int communityId,
    required String nom,
    required String description,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final project = await _projectService.createProject(
        communityId: communityId,
        nom: nom,
        description: description,
      );

      if (project != null) {
        projects.add(project);
        currentProject.value = project;
        return project;
      }
      return null;
    } catch (e) {
      error.value = 'Erreur de création du projet: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setCurrentProject(ProjectModel project) async {
    currentProject.value = project;
    // ✅ Sync with list if needed
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      projects[index] = project;
    }
  }

  Future<void> refreshCurrentProject(int communityId) async {
    final existing = currentProject.value;
    if (existing != null) {
      await refreshProject(communityId, existing.id);
    }
  }

  Future<void> refreshProject(int communityId, int projectId) async {
    try {
      final project = await _projectService.getProjectDetails(
        communityId: communityId,
        projectId: projectId,
      );

      if (project != null) {
        if (currentProject.value?.id == projectId) {
          currentProject.value = project;
        }
        // ✅ Mettre à jour dans la liste globale
        final index = projects.indexWhere((p) => p.id == projectId);
        if (index != -1) {
          projects[index] = project;
        }
      }
    } catch (e) {
      print('Erreur refresh project $projectId: $e');
    }
  }

  /// ✅ Rafraîchir les statistiques de TOUS les projets en parallèle
  Future<void> refreshAllProjectsStats(int communityId) async {
    if (projects.isEmpty) return;
    final List<Future> futures = [];
    for (var project in projects) {
      futures.add(refreshProject(communityId, project.id));
    }
    await Future.wait(futures);
  }

  Future<bool> updateProject({
    required int communityId,
    required int projectId,
    String? nom,
    String? description,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final success = await _projectService.updateProject(
        communityId: communityId,
        projectId: projectId,
        nom: nom,
        description: description,
      );

      if (success && currentProject.value?.id == projectId) {
        await refreshCurrentProject(communityId);
      }

      return success;
    } catch (e) {
      error.value = 'Erreur de mise à jour: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> archiveProject({
    required int communityId,
    required int projectId,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final success = await _projectService.archiveProject(
        communityId: communityId,
        projectId: projectId,
      );

      if (success) {
        projects.removeWhere((project) => project.id == projectId);
        if (currentProject.value?.id == projectId) {
          currentProject.value = null;
        }
      }

      return success;
    } catch (e) {
      error.value = 'Erreur d\'archivage: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void toggleShowArchived() {
    showArchived.value = !showArchived.value;
  }

  List<ProjectModel> get activeProjects {
    return projects.where((project) => !project.isArchived).toList();
  }

  List<ProjectModel> get archivedProjects {
    return projects.where((project) => project.isArchived).toList();
  }

  // ✅ Statistiques globales de la communauté (basées sur les projets)
  int get communityTotalTasksCount {
    return projects.fold(0, (sum, project) => sum + project.tasks_count);
  }

  int get communityCompletedTasksCount {
    return projects.fold(0, (sum, project) => sum + project.completed_tasks);
  }

  double get communityCompletionPercentage {
    final total = communityTotalTasksCount;
    if (total == 0) return 0.0;
    return (communityCompletedTasksCount / total) * 100;
  }
}
