import 'package:community/data/models/project_model.dart';
import 'package:get/get.dart';
import 'api_service.dart';

class ProjectService extends GetxService {
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
      for (final key in ['projects', 'data', 'items', 'results']) {
        if (raw[key] != null) return _extractList(raw[key]);
      }
    }
    return [];
  }

  Map<String, dynamic>? _extractProjectPayload(dynamic raw) {
    final data = _extractDataMap(raw);
    if (data.isEmpty) return null;
    if (data['project'] is Map<String, dynamic>) return data['project'];
    if (data.containsKey('id') || data.containsKey('project_id')) return data;
    return null;
  }

  Future<List<ProjectModel>> getProjects({
    required int communityId,
    bool includeArchived = false,
  }) async {
    final response = await _apiService.get(
      '/communities/$communityId/projects?include_archived=$includeArchived',
    );

    if (response.success) {
      final data = _extractDataMap(response.data);
      final rawList = _extractList(data);
      return rawList
          .whereType<Map<String, dynamic>>()
          .map((item) => ProjectModel.fromJson(item))
          .toList();
    }
    return [];
  }

  Future<ProjectModel?> createProject({
    required int communityId,
    required String nom,
    required String description,
  }) async {
    final response = await _apiService.post(
      '/communities/$communityId/projects',
      {'nom': nom, 'description': description},
    );

    if (response.success) {
      final payload = _extractProjectPayload(response.data);
      if (payload != null) {
        return ProjectModel.fromJson(payload);
      }
    }
    return null;
  }

  Future<ProjectModel?> getProjectDetails({
    required int communityId,
    required int projectId,
  }) async {
    final response = await _apiService.get(
      '/communities/$communityId/projects/$projectId',
    );

    if (response.success) {
      final payload = _extractProjectPayload(response.data);
      if (payload != null) {
        return ProjectModel.fromJson(payload);
      }
    }
    return null;
  }

  Future<bool> updateProject({
    required int communityId,
    required int projectId,
    String? nom,
    String? description,
  }) async {
    final Map<String, dynamic> data = {};
    if (nom != null) data['nom'] = nom;
    if (description != null) data['description'] = description;

    final response = await _apiService.put(
      '/communities/$communityId/projects/$projectId',
      data,
    );
    return response.success;
  }

  Future<bool> archiveProject({
    required int communityId,
    required int projectId,
  }) async {
    final response = await _apiService.delete(
      '/communities/$communityId/projects/$projectId',
    );
    return response.success;
  }
}
