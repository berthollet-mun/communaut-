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

  List<dynamic> _extractList(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw;
    if (raw is Map<String, dynamic>) {
      for (final key in ['tasks', 'data', 'items', 'results']) {
        if (raw[key] != null) return _extractList(raw[key]);
      }
    }
    return [];
  }

  Map<String, dynamic>? _extractKanbanPayload(dynamic raw) {
    final data = _extractDataMap(raw);
    if (data.isEmpty) return null;
    if (data['kanban'] is Map<String, dynamic>) return data['kanban'];
    return data;
  }

  Map<String, dynamic>? _extractTaskPayload(dynamic raw) {
    final data = _extractDataMap(raw);
    if (data.isEmpty) return null;
    if (data['task'] is Map<String, dynamic>) return data['task'];
    if (data.containsKey('id') || data.containsKey('task_id')) return data;
    return null;
  }

  Future<KanbanModel?> getKanbanTasks({
    required int communityId,
    required int projectId,
  }) async {
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
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

  // Dans task_service.dart - Remplacez createTask

  Future<TaskModel?> createTask({
    required int communityId,
    required int projectId,
    required String titre,
    required String description,
    int? assignedTo,
    String? dueDate,
  }) async {
    final Map<String, dynamic> data = {
      'titre': titre,
      'description': description,
    };

    if (assignedTo != null) data['assigned_to'] = assignedTo;
    if (dueDate != null) data['due_date'] = dueDate;

    // ✅ DEBUG
    print('=== CREATE TASK ===');
    print('URL: /communities/$communityId/projects/$projectId/tasks');
    print('DATA: $data');
    print('===================');

    var response = await _apiService.post(
      '/communities/$communityId/projects/$projectId/tasks',
      data,
    );

    // Backend workaround: some deployments crash when due_date is present.
    if (!response.success && dueDate != null) {
      final retryData = Map<String, dynamic>.from(data)..remove('due_date');
      response = await _apiService.post(
        '/communities/$communityId/projects/$projectId/tasks',
        retryData,
      );
    }

    if (response.success) {
      final payload = _extractTaskPayload(response.data);
      if (payload != null) {
        return TaskModel.fromJson(payload);
      }
    }
    if (!response.success) {
      throw Exception(
        response.displayMessage.isNotEmpty
            ? response.displayMessage
            : 'Erreur de création de tâche',
      );
    }
    return null;
  }

  Future<TaskModel?> getTaskDetails({
    required int communityId,
    required int projectId,
    required int taskId,
  }) async {
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    final response = await _apiService.get(
      '/communities/$communityId/projects/$projectId/tasks/$taskId?t=$timestamp',
    );

    if (response.success) {
      final payload = _extractTaskPayload(response.data);
      if (payload != null) {
        return TaskModel.fromJson(payload);
      }
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
  }) async {
    final Map<String, dynamic> data = {};
    if (titre != null) data['titre'] = titre;
    if (description != null) data['description'] = description;
    if (assignedTo != null) data['assigned_to'] = assignedTo;
    if (dueDate != null) data['due_date'] = dueDate;

    var response = await _apiService.put(
      '/communities/$communityId/projects/$projectId/tasks/$taskId',
      data,
    );

    // Same backend workaround for update flow.
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
    var response = await _apiService.patch(
      '/communities/$communityId/projects/$projectId/tasks/$taskId/status',
      {'status': status},
    );

    // Fallback for servers that block PATCH on web/CORS.
    if (!response.success) {
      response = await _apiService.post(
        '/communities/$communityId/projects/$projectId/tasks/$taskId/status',
        {'status': status},
      );
    }

    // Last fallback: generic task update endpoint.
    if (!response.success) {
      response = await _apiService.put(
        '/communities/$communityId/projects/$projectId/tasks/$taskId',
        {'status': status},
      );
    }

    return response;
  }

  Future<ApiResponse> deleteTask({
    required int communityId,
    required int projectId,
    required int taskId,
  }) async {
    return await _apiService.delete(
      '/communities/$communityId/projects/$projectId/tasks/$taskId',
    );
  }
}
