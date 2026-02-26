import 'package:community/core/services/api_service.dart';
import 'package:community/data/models/community_model.dart';
import 'package:community/data/models/invite_model.dart';
import 'package:community/data/models/member_model.dart';
import 'package:get/get.dart';

class CommunityService extends GetxService {
  final ApiService _apiService = Get.find();

  // Backend: tu as montré que /communities/0 renvoie la liste.
  // Si chez toi /communities marche aussi, tu peux revenir à '/communities'.
  static const String _communitiesEndpoint = '/communities';

  /// ✅ Retourne le "data" interne si la réponse est du type:
  /// { success:true, message:"", data:{...} }
  Map<String, dynamic> _extractDataMap(dynamic raw) {
    if (raw == null) return {};

    if (raw is Map<String, dynamic>) {
      // cas {success, message, data:{...}}
      if (raw['data'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(raw['data']);
      }
      return raw;
    }

    return {};
  }

  /// ✅ Extrait une liste depuis n'importe quelle forme (ou [])
  List<dynamic> _extractList(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw;

    if (raw is Map<String, dynamic>) {
      // Laravel/perso: { communities:[...] }
      for (final key in ['communities', 'members', 'activities', 'activitiesList', 'data', 'items', 'results']) {
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

  /// ✅ Extrait un map "communauté"
  /// - si data contient community => on renvoie data (pas juste community) pour garder your_role
  /// - sinon si data est déjà l'objet communauté => on renvoie data
  Map<String, dynamic>? _extractCommunityPayload(dynamic raw) {
    final data = _extractDataMap(raw);
    if (data.isEmpty) return null;

    // cas { community:{...}, your_role:"ADMIN" }
    if (data['community'] is Map<String, dynamic>) {
      return data; // on garde your_role avec
    }

    // cas { id:..., nom:... }
    if (data.containsKey('id') || data.containsKey('community_id')) {
      return data;
    }

    return null;
  }

  /// ✅ Liste des communautés de l'utilisateur
  Future<List<CommunityModel>> getUserCommunities() async {
    // D'après la documentation: GET /communities
    final response = await _apiService.get(_communitiesEndpoint);

    if (!response.success) {
      throw Exception(response.error ?? 'Erreur de chargement des communautés');
    }

    final data = _extractDataMap(response.data);
    final rawList = _extractList(data);

    return rawList
        .whereType<Map<String, dynamic>>()
        .map((e) => CommunityModel.fromJson(e))
        .toList();
  }

  /// ✅ Créer une communauté
  Future<CommunityModel?> createCommunity({
    required String nom,
    required String description,
  }) async {
    final response = await _apiService.post(_communitiesEndpoint, {
      'nom': nom,
      'description': description,
    });

    if (!response.success) {
      throw Exception(response.error ?? 'Erreur création communauté');
    }

    final payload = _extractCommunityPayload(response.data);
    if (payload == null) return null;

    return CommunityModel.fromJson(payload);
  }

  /// ✅ Rejoindre une communauté
  Future<bool> joinCommunity(String inviteCode) async {
    final response = await _apiService.post('$_communitiesEndpoint/join', {
      'invite_code': inviteCode,
    });

    if (!response.success) {
      throw Exception(response.error ?? 'Erreur rejoindre communauté');
    }
    return true;
  }

  /// ✅ Détails d'une communauté
  Future<CommunityModel?> getCommunityDetails(int communityId) async {
    final response = await _apiService.get(
      '$_communitiesEndpoint/$communityId',
    );

    if (!response.success) {
      throw Exception(response.error ?? 'Erreur détails communauté');
    }

    final payload = _extractCommunityPayload(response.data);
    if (payload == null) return null;

    return CommunityModel.fromJson(payload);
  }

  /// ✅ Membres d'une communauté
  Future<List<MemberModel>> getCommunityMembers(int communityId) async {
    final response = await _apiService.get(
      '$_communitiesEndpoint/$communityId/members',
    );

    if (!response.success) {
      throw Exception(response.error ?? 'Erreur chargement membres');
    }

    final data = _extractDataMap(response.data);
    final rawList = _extractList(data);

    return rawList
        .whereType<Map<String, dynamic>>()
        .map((e) => MemberModel.fromJson(e))
        .toList();
  }

  /// ✅ Générer un code d'invitation (Nouveau endpoint documentation : POST /communities/{id}/members)
  Future<InviteModel?> generateInviteCode(int communityId) async {
    final response = await _apiService.post(
      '$_communitiesEndpoint/$communityId/members',
      {},
    );

    if (!response.success) {
      throw Exception(response.error ?? 'Erreur génération code');
    }

    final data = _extractDataMap(response.data);
    if (data.isEmpty) return null;

    return InviteModel.fromJson(data);
  }

  /// ✅ Modifier rôle
  Future<bool> updateMemberRole({
    required int communityId,
    required int memberId,
    required String role,
  }) async {
    final response = await _apiService.patch(
      '$_communitiesEndpoint/$communityId/members/$memberId',
      {'role': role},
    );

    if (!response.success) {
      throw Exception(response.error ?? 'Erreur update role');
    }
    return true;
  }

  /// ✅ Retirer membre
  Future<bool> removeMember({
    required int communityId,
    required int memberId,
  }) async {
    final response = await _apiService.delete(
      '$_communitiesEndpoint/$communityId/members/$memberId',
    );

    if (!response.success) {
      throw Exception(response.error ?? 'Erreur suppression membre');
    }
    return true;
  }

  /// ✅ Modifier communauté
  Future<bool> updateCommunity({
    required int communityId,
    String? nom,
    String? description,
  }) async {
    final body = <String, dynamic>{};
    if (nom != null) body['nom'] = nom;
    if (description != null) body['description'] = description;

    final response = await _apiService.put(
      '$_communitiesEndpoint/$communityId',
      body,
    );

    if (!response.success) {
      throw Exception(response.error ?? 'Erreur update communauté');
    }
    return true;
  }

  /// ✅ Supprimer communauté
  Future<bool> deleteCommunity(int communityId) async {
    final response = await _apiService.delete(
      '$_communitiesEndpoint/$communityId',
    );

    if (!response.success) {
      throw Exception(response.error ?? 'Erreur suppression communauté');
    }
    return true;
  }

  /// ✅ Quitter communauté
  Future<bool> leaveCommunity({
    required int communityId,
    required int userId,
  }) async {
    final response = await _apiService.post(
      '$_communitiesEndpoint/$communityId/leave',
      {'user_id': userId},
    );

    if (!response.success) {
      throw Exception(response.error ?? 'Erreur quitter communauté');
    }
    return true;
  }
}
