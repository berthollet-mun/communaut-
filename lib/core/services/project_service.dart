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
    for (final key in ['project', 'projet', 'item', 'created_project']) {
      if (data[key] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(data[key]);
      }
    }
    if (data.containsKey('id') || data.containsKey('project_id')) return data;
    return null;
  }

  ProjectModel? _pickLikelyCreatedProject(
    List<ProjectModel> projects, {
    required String nom,
    required String description,
  }) {
    if (projects.isEmpty) return null;

    final byExactMatch = projects.where(
      (p) => p.nom.trim() == nom.trim() && p.description.trim() == description.trim(),
    );
    if (byExactMatch.isNotEmpty) {
      final sorted = byExactMatch.toList()
        ..sort((a, b) => b.created_at.compareTo(a.created_at));
      return sorted.first;
    }

    final byName = projects.where((p) => p.nom.trim() == nom.trim());
    if (byName.isNotEmpty) {
      final sorted = byName.toList()
        ..sort((a, b) => b.created_at.compareTo(a.created_at));
      return sorted.first;
    }

    final sorted = projects.toList()
      ..sort((a, b) => b.created_at.compareTo(a.created_at));
    return sorted.first;
  }

  Future<List<ProjectModel>> getProjects({
    required int communityId,
    bool includeArchived = false,
  }) async {
    final endpoint = includeArchived
        ? '/communities/$communityId/projects?include_archived=1'
        : '/communities/$communityId/projects';
    final response = await _apiService.get(endpoint);

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
    final attempts = <({String endpoint, Map<String, dynamic> payload})>[
      (
        endpoint: '/communities/$communityId/projects',
        payload: {'nom': nom, 'description': description},
      ),
      (
        endpoint: '/communities/$communityId/projects',
        payload: {'name': nom, 'description': description},
      ),
      (
        endpoint: '/communities/$communityId/projects',
        payload: {
          'nom': nom,
          'description': description,
          'community_id': communityId,
        },
      ),
      (
        endpoint: '/projects',
        payload: {
          'community_id': communityId,
          'nom': nom,
          'description': description,
        },
      ),
    ];

    String? lastError;
    for (final attempt in attempts) {
      final response = await _apiService.post(
        attempt.endpoint,
        attempt.payload,
      );

      if (!response.success) {
        lastError = response.error ?? 'Erreur de création du projet';
        continue;
      }

      final payload = _extractProjectPayload(response.data);
      if (payload != null) {
        final project = ProjectModel.fromJson(payload);
        if (project.id > 0) {
          return project;
        }
      }

      // Succès sans payload exploitable: tenter une récupération par listing.
      final projects = await getProjects(communityId: communityId);
      final candidate = _pickLikelyCreatedProject(
        projects,
        nom: nom,
        description: description,
      );
      if (candidate != null) {
        return candidate;
      }
    }
    throw Exception(lastError ?? 'Erreur de création du projet');
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
