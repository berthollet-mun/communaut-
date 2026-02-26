// ignore_for_file: avoid_print

import 'package:community/core/services/api_service.dart';
import 'package:community/data/models/activity_model.dart';
import 'package:get/get.dart';

class ActivityService {
  final ApiService _apiService = Get.find();

  /// ✅ Extrait une liste depuis n'importe quelle forme (ou [])
  List<dynamic> _extractList(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw;

    if (raw is Map<String, dynamic>) {
      for (final key in ['activities', 'activitiesList', 'history', 'data', 'items', 'results']) {
        if (raw[key] != null) return _extractList(raw[key]);
      }

      // Pagination: { data:{ data:[...] } }
      if (raw['data'] is Map<String, dynamic>) {
        final inner = raw['data'] as Map<String, dynamic>;
        if (inner['data'] is List) return inner['data'] as List;
      }
    }

    return [];
  }

  Future<List<ActivityModel>> getCommunityActivities({
    required int communityId,
    int limit = 50,
  }) async {
    try {
      final response = await _apiService.get(
        '/communities/$communityId/activities?limit=$limit',
      );

      if (response.success) {
        final rawList = _extractList(response.data);
        return rawList
            .whereType<Map<String, dynamic>>()
            .map((item) => ActivityModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('Erreur ActivityService.getCommunityActivities: $e');
      return [];
    }
  }

  Future<List<ActivityModel>> getProjectActivities({
    required int communityId,
    required int projectId,
    int limit = 50,
  }) async {
    // Utilise l'endpoint général de la communauté pour l'instant
    return await getCommunityActivities(communityId: communityId, limit: limit);
  }
}
