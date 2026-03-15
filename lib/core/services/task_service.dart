import 'package:community/data/models/kanban_model.dart';
import 'package:community/data/models/task_model.dart';
import 'package:community/data/responses/api_response.dart';
import 'package:get/get.dart';

import 'api_service.dart';

class TaskService extends GetxService {
  final ApiService _apiService = Get.find();

  Map<String, dynamic> _extractDataMap(dynamic raw) {
    if (raw == null) return {};
    if (raw is Map<String, dynamic>) {
      if (raw['data'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(raw['data']);
      }
      return raw;
    }
    return {};
  }

  Map<String, dynamic>? _extractKanbanPayload(dynamic raw) {
    final data = _extractDataMap(raw);
    if (data.isEmpty) return null;
    if (data['kanban'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data['kanban']);
    }
    return data;
  }

  Map<String, dynamic>? _extractTaskPayload(dynamic raw) {
    final data = _extractDataMap(raw);
    if (data.isEmpty) return null;
    if (data['task'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data['task']);
    }
    if (data.containsKey('id') || data.containsKey('task_id')) {
      return data;
    }
    return null;
  }

  String _normalizeStatusForApi(String raw) {
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
        value.contains('done') ||
        value == 'completed') {
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

  Future<KanbanModel?> getKanbanTasks({
    required int communityId,
    required int projectId,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final response = await _apiService.get(
      '/communities/$communityId/projects/$projectId/tasks?t=$timestamp',
    );

    if (response.success) {
      final payload = _extractKanbanPayload(response.data);
      if (payload != null) {
        return KanbanModel.fromJson(payload);
      }
    }

    return null;
  }

  Future<TaskModel?> createTask({
    required int communityId,
    required int projectId,
    required String titre,
    required String description,
    int? assignedTo,
    String? dueDate,
  }) async {
    final data = <String, dynamic>{'titre': titre, 'description': description};

    if (assignedTo != null) data['assigned_to'] = assignedTo;
    if (dueDate != null) data['due_date'] = dueDate;

    var response = await _apiService.post(
      '/communities/$communityId/projects/$projectId/tasks',
      data,
    );

    if (!response.success && dueDate != null) {
      final retryData = Map<String, dynamic>.from(data)..remove('due_date');
      response = await _apiService.post(
        '/communities/$communityId/projects/$projectId/tasks',
        retryData,
      );
    }

    if (response.success) {
      final payload = _extractTaskPayload(response.data);
      if (payload != null) return TaskModel.fromJson(payload);
    }

    throw Exception(
      response.displayMessage.isNotEmpty
          ? response.displayMessage
          : 'Erreur création tâche',
    );
  }

  Future<TaskModel?> getTaskDetails({
    required int communityId,
    required int projectId,
    required int taskId,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final response = await _apiService.get(
      '/communities/$communityId/projects/$projectId/tasks/$taskId?t=$timestamp',
    );

    if (response.success) {
      final payload = _extractTaskPayload(response.data);
      if (payload != null) return TaskModel.fromJson(payload);
    }

    return null;
  }

  Future<ApiResponse> updateTask({
    required int communityId,
    required int projectId,
    required int taskId,
    String? titre,
    String? description,
    int? assignedTo,
    String? dueDate,
    bool clearAssignment = false,
  }) async {
    final data = <String, dynamic>{};

    if (titre != null) data['titre'] = titre;
    if (description != null) data['description'] = description;
    if (assignedTo != null || clearAssignment) {
      data['assigned_to'] = assignedTo;
    }
    if (dueDate != null) data['due_date'] = dueDate;

    var response = await _apiService.put(
      '/communities/$communityId/projects/$projectId/tasks/$taskId',
      data,
    );

    if (!response.success && dueDate != null && data.containsKey('due_date')) {
      final retryData = Map<String, dynamic>.from(data)..remove('due_date');
      response = await _apiService.put(
        '/communities/$communityId/projects/$projectId/tasks/$taskId',
        retryData,
      );
    }

    return response;
  }

  Future<ApiResponse> updateTaskStatus({
    required int communityId,
    required int projectId,
    required int taskId,
    required String status,
  }) async {
    final endpoint =
        '/communities/$communityId/projects/$projectId/tasks/$taskId/status';

    final normalizedStatus = _normalizeStatusForApi(status);

    // ✅ vrai PATCH uniquement
    final response = await _apiService.patch(endpoint, {
      'status': normalizedStatus,
    });

    return response;
  }

  Future<ApiResponse> deleteTask({
    required int communityId,
    required int projectId,
    required int taskId,
  }) async {
    return _apiService.delete(
      '/communities/$communityId/projects/$projectId/tasks/$taskId',
    );
  }
}
