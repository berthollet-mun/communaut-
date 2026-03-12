import 'package:community/controllers/notification_controller.dart';
import 'package:community/controllers/project_controller.dart';
import 'package:community/core/services/task_service.dart';
import 'package:community/data/models/kanban_model.dart';
import 'package:community/data/models/task_model.dart';
import 'package:get/get.dart';

class TaskController extends GetxController {
  final TaskService _taskService = Get.find();

  final Rx<KanbanModel?> kanban = Rx<KanbanModel?>(null);
  final Rx<TaskModel?> currentTask = Rx<TaskModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  String _normalizeStatus(String raw) {
    final value = raw.trim().toLowerCase();
    if (value.contains('en cours') ||
        value.contains('en_cours') ||
        value.contains('in_progress') ||
        value.contains('in progress') ||
        value == 'doing' ||
        value == 'ongoing') {
      return 'En cours';
    }
    if (value.contains('termin') ||
        value == 'completed' ||
        value == 'done') {
      return 'Terminé';
    }
    if (value.contains('todo') ||
        value.contains('to_do') ||
        value.contains('a faire') ||
        value.contains('à faire') ||
        value == 'pending') {
      return 'À faire';
    }
    return 'À faire';
  }

  String normalizeStatus(String raw) => _normalizeStatus(raw);

  // ✅ Helper pour envoyer des notifications
  void _notify(
    String type,
    String title,
    String message, {
    int? relatedId,
    String? relatedType,
  }) {
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().addLocalNotification(
        type: type,
        title: title,
        message: message,
        relatedId: relatedId,
        relatedType: relatedType,
      );
    }
  }

  Future<void> loadKanbanTasks({
    required int communityId,
    required int projectId,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final kanbanData = await _taskService.getKanbanTasks(
        communityId: communityId,
        projectId: projectId,
      );

      kanban.value = kanbanData;
    } catch (e) {
      error.value = 'Erreur de chargement des tâches: $e';
      kanban.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<TaskModel?> createTask({
    required int communityId,
    required int projectId,
    required String titre,
    required String description,
    int? assignedTo,
    String? dueDate,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final task = await _taskService.createTask(
        communityId: communityId,
        projectId: projectId,
        titre: titre,
        description: description,
        assignedTo: assignedTo,
        dueDate: dueDate,
      );

      if (task != null) {
        _addTaskToKanban(task);

        // ✅ NOTIFICATION : Tâche créée
        _notify(
          'task_created',
          'Tâche créée',
          'La tâche "${task.titre}" a été créée avec succès.',
          relatedId: task.id,
          relatedType: 'task',
        );

        return task;
      }

      return null;
    } catch (e) {
      error.value = 'Erreur de création de la tâche: $e';

      // ✅ NOTIFICATION : Erreur
      _notify('error', 'Erreur', 'Impossible de créer la tâche: $e');

      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTaskDetails({
    required int communityId,
    required int projectId,
    required int taskId,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final task = await _taskService.getTaskDetails(
        communityId: communityId,
        projectId: projectId,
        taskId: taskId,
      );

      currentTask.value = task;
    } catch (e) {
      error.value = 'Erreur de chargement des détails: $e';
      currentTask.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateTask({
    required int communityId,
    required int projectId,
    required int taskId,
    String? titre,
    String? description,
    int? assignedTo,
    String? dueDate,
    bool clearAssignment = false,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _taskService.updateTask(
        communityId: communityId,
        projectId: projectId,
        taskId: taskId,
        titre: titre,
        description: description,
        assignedTo: assignedTo,
        dueDate: dueDate,
        clearAssignment: clearAssignment,
      );

      if (response.success) {
        if (currentTask.value?.id == taskId) {
          await loadTaskDetails(
            communityId: communityId,
            projectId: projectId,
            taskId: taskId,
          );
        }

        // ✅ NOTIFICATION : Tâche modifiée
        _notify(
          'task_updated',
          'Tâche modifiée',
          'La tâche "${titre ?? 'Tâche'}" a été mise à jour.',
          relatedId: taskId,
          relatedType: 'task',
        );
        return true;
      } else {
        error.value = response.message ?? 'Erreur inconnue';
        return false;
      }
    } catch (e) {
      error.value = 'Erreur de mise à jour: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateTaskStatus({
    required int communityId,
    required int projectId,
    required int taskId,
    required String status,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      final normalizedStatus = _normalizeStatus(status);

      final response = await _taskService.updateTaskStatus(
        communityId: communityId,
        projectId: projectId,
        taskId: taskId,
        status: normalizedStatus,
      );

      if (response.success) {
        // On tente de récupérer la tâche mise à jour côté serveur,
        // mais on ne bloque plus l'utilisateur si le backend répond "succès"
        // avec un statut légèrement différent (par ex. normalisation côté API).
        TaskModel? updated;
        String? serverStatus;
        try {
          updated = await _taskService.getTaskDetails(
            communityId: communityId,
            projectId: projectId,
            taskId: taskId,
          );
          if (updated != null) {
            serverStatus = _normalizeStatus(updated.status);
          }
        } catch (_) {
          // En cas d'erreur réseau secondaire, on ne bloque pas le succès principal.
        }

        final finalStatus = serverStatus ?? normalizedStatus;

        _updateTaskStatusInKanban(taskId, finalStatus);

        if (currentTask.value?.id == taskId) {
          currentTask.value = (updated ?? currentTask.value)
              ?.copyWith(status: finalStatus);
        }

        // ✅ NOTIFICATION : Statut changé
        String icon = normalizedStatus == 'Terminé'
            ? '✅'
            : (normalizedStatus == 'En cours' ? '🔄' : '📋');
        _notify(
          'task_status_changed',
          'Statut modifié',
          '$icon La tâche est maintenant "$normalizedStatus".',
          relatedId: taskId,
          relatedType: 'task',
        );

        // ✅ Stats refresh (avec léger délai)
        Future.delayed(const Duration(milliseconds: 800), () {
          Get.find<ProjectController>().refreshAllProjectsStats(communityId);
        });

        return true;
      } else {
        error.value = response.message ?? 'Erreur inconnue';
        return false;
      }
    } catch (e) {
      error.value = 'Erreur de changement de statut: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteTask({
    required int communityId,
    required int projectId,
    required int taskId,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Sauvegarder le titre avant suppression
      String? taskTitle;
      final allTasksList = allTasks;
      final taskToDelete = allTasksList.firstWhereOrNull((t) => t.id == taskId);
      taskTitle = taskToDelete?.titre;

      final response = await _taskService.deleteTask(
        communityId: communityId,
        projectId: projectId,
        taskId: taskId,
      );

      if (response.success) {
        _removeTaskFromKanban(taskId);

        if (currentTask.value?.id == taskId) {
          currentTask.value = null;
        }

        // Force reload from backend to keep kanban strictly in sync.
        await loadKanbanTasks(
          communityId: communityId,
          projectId: projectId,
        );

        // ✅ NOTIFICATION : Tâche supprimée
        _notify(
          'task_deleted',
          'Tâche supprimée',
          'La tâche "${taskTitle ?? 'Tâche'}" a été supprimée.',
        );

        // ✅ Stats refresh (avec léger délai pour laisser le backend respirer)
        Future.delayed(const Duration(milliseconds: 800), () {
          Get.find<ProjectController>().refreshAllProjectsStats(communityId);
        });

        return true;
      } else {
        error.value = response.message ?? 'Erreur inconnue';
        return false;
      }
    } catch (e) {
      error.value = 'Erreur de suppression: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void setCurrentTask(TaskModel task) {
    currentTask.value = task;
  }

  void clearCurrentTask() {
    currentTask.value = null;
  }

  // Méthodes privées pour manipuler le kanban
  void _addTaskToKanban(TaskModel task) {
    if (kanban.value != null) {
      final status = _normalizeStatus(task.status);
      final newKanban = KanbanModel(
        todo: status == 'À faire'
            ? [...kanban.value!.todo, task]
            : kanban.value!.todo,
        inProgress: status == 'En cours'
            ? [...kanban.value!.inProgress, task]
            : kanban.value!.inProgress,
        done: status == 'Terminé'
            ? [...kanban.value!.done, task]
            : kanban.value!.done,
      );
      kanban.value = newKanban;
      kanban.refresh();
    }
  }

  void _updateTaskStatusInKanban(int taskId, String newStatusRaw) {
    if (kanban.value == null) return;
    final newStatus = _normalizeStatus(newStatusRaw);

    TaskModel? task;
    List<TaskModel> newTodo = [...kanban.value!.todo];
    List<TaskModel> newInProgress = [...kanban.value!.inProgress];
    List<TaskModel> newDone = [...kanban.value!.done];

    task = newTodo.firstWhereOrNull((t) => t.id == taskId);
    if (task != null) {
      newTodo.removeWhere((t) => t.id == taskId);
    } else {
      task = newInProgress.firstWhereOrNull((t) => t.id == taskId);
      if (task != null) {
        newInProgress.removeWhere((t) => t.id == taskId);
      } else {
        task = newDone.firstWhereOrNull((t) => t.id == taskId);
        if (task != null) {
          newDone.removeWhere((t) => t.id == taskId);
        }
      }
    }

    if (task != null) {
      final updatedTask = task.copyWith(status: newStatus);

      switch (newStatus) {
        case 'À faire':
          newTodo.add(updatedTask);
          break;
        case 'En cours':
          newInProgress.add(updatedTask);
          break;
        case 'Terminé':
          newDone.add(updatedTask);
          break;
        default:
          newTodo.add(updatedTask);
          break;
      }

      kanban.value = KanbanModel(
        todo: newTodo,
        inProgress: newInProgress,
        done: newDone,
      );
      kanban.refresh();
    }
  }

  void _removeTaskFromKanban(int taskId) {
    if (kanban.value == null) return;

    kanban.value = KanbanModel(
      todo: kanban.value!.todo.where((t) => t.id != taskId).toList(),
      inProgress: kanban.value!.inProgress
          .where((t) => t.id != taskId)
          .toList(),
      done: kanban.value!.done.where((t) => t.id != taskId).toList(),
    );
    kanban.refresh();
  }

  // Getters utiles
  List<TaskModel> get allTasks {
    if (kanban.value == null) return [];
    return [
      ...kanban.value!.todo,
      ...kanban.value!.inProgress,
      ...kanban.value!.done,
    ];
  }

  int get totalTasksCount => allTasks.length;
  int get completedTasksCount => kanban.value?.done.length ?? 0;

  double get completionPercentage {
    if (totalTasksCount == 0) return 0;
    return (completedTasksCount / totalTasksCount) * 100;
  }
}

