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
    bool clearAssignment = false,
  }) async {
    final Map<String, dynamic> data = {};
    if (titre != null) data['titre'] = titre;
    if (description != null) data['description'] = description;
    if (assignedTo != null || clearAssignment) data['assigned_to'] = assignedTo;
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
    final statusCandidates = _statusCandidates(status);
    final currentTask = await getTaskDetails(
      communityId: communityId,
      projectId: projectId,
      taskId: taskId,
    );

    ApiResponse? lastResponse;
    for (final candidate in statusCandidates) {
      final payloads = <Map<String, dynamic>>[
        {'status': candidate},
        {'statut': candidate},
        {'task_status': candidate},
        {'etat': candidate},
      ];
      final fullPayloads = _fullTaskPayloadCandidates(currentTask, candidate);

      for (final payload in payloads) {
        var response = await _apiService.patch(
          '/communities/$communityId/projects/$projectId/tasks/$taskId/status',
          payload,
        );
        if (response.success) return response;
        lastResponse = response;

        response = await _apiService.post(
          '/communities/$communityId/projects/$projectId/tasks/$taskId/status',
          payload,
        );
        if (response.success) return response;
        lastResponse = response;
      }

      for (final fullPayload in fullPayloads) {
        final response = await _apiService.put(
          '/communities/$communityId/projects/$projectId/tasks/$taskId',
          fullPayload,
        );
        if (response.success) return response;
        lastResponse = response;
      }
    }

    return lastResponse ??
        ApiResponse.error(
          'Impossible de changer le statut',
          code: 'STATUS_UPDATE_FAILED',
        );
  }

  List<String> _statusCandidates(String status) {
    final value = status.trim().toLowerCase();
    if (value.contains('termin') || value == 'done' || value == 'completed') {
      return ['Terminé', 'Terminée', 'termine', 'done', 'completed'];
    }
    if (value.contains('en cours') ||
        value.contains('in_progress') ||
        value.contains('in progress') ||
        value == 'doing') {
      return ['En cours', 'en cours', 'in_progress', 'in progress', 'doing'];
    }
    return ['À faire', 'A faire', 'a_faire', 'todo', 'to_do', 'pending'];
  }

  List<Map<String, dynamic>> _fullTaskPayloadCandidates(
    TaskModel? task,
    String status,
  ) {
    if (task == null) {
      return const [];
    }

    final dueDate = task.due_date != null
        ? '${task.due_date!.year.toString().padLeft(4, '0')}-${task.due_date!.month.toString().padLeft(2, '0')}-${task.due_date!.day.toString().padLeft(2, '0')}'
        : null;

    final base = <String, dynamic>{
      'titre': task.titre,
      'description': task.description,
      'assigned_to': task.assigned_to,
      'due_date': dueDate,
    };

    return [
      {...base, 'status': status},
      {...base, 'statut': status},
      {...base, 'task_status': status},
      {...base, 'etat': status},
    ];
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
