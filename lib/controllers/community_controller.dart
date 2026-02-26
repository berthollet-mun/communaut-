import 'package:community/core/services/Community_service.dart';
import 'package:community/core/services/storage_service.dart';
import 'package:community/data/models/community_model.dart';
import 'package:community/data/models/invite_model.dart';
import 'package:community/data/models/member_model.dart';
import 'package:get/get.dart';

class CommunityController extends GetxController {
  final CommunityService _communityService = Get.find();
  final StorageService _storageService = Get.find();

  final RxList<CommunityModel> communities = <CommunityModel>[].obs;
  final Rx<CommunityModel?> currentCommunity = Rx<CommunityModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxList<MemberModel> currentMembers = <MemberModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // On pourrait tenter de restaurer ici, mais le flux de l’app
    // semble préférer laisser Splash/Main gérer le boot.
  }

  Future<void> loadCommunities() async {
    try {
      isLoading.value = true;
      error.value = '';
      final list = await _communityService.getUserCommunities();
      communities.assignAll(list);
    } catch (e) {
      error.value = 'Erreur de chargement: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCommunitiesSilently() async {
    try {
      final list = await _communityService.getUserCommunities();
      communities.assignAll(list);
    } catch (_) {}
  }

  Future<CommunityModel?> createCommunity({
    required String nom,
    required String description,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final community = await _communityService.createCommunity(
        nom: nom,
        description: description,
      );
      if (community == null) return null;

      // ✅ si backend oublie de renvoyer role, on force ADMIN côté client après création
      final fixed = community.role.isNotEmpty
          ? community
          : community.copyWith(role: 'ADMIN');

      communities.add(fixed);
      await setCurrentCommunity(fixed);
      return fixed;
    } catch (e) {
      error.value = 'Erreur de création: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> joinCommunity(String inviteCode) async {
    try {
      isLoading.value = true;
      error.value = '';
      final success = await _communityService.joinCommunity(inviteCode);
      if (success) {
        await loadCommunities();
        // Si on vient de rejoindre, on pourrait auto-sélectionner la dernière
        if (communities.isNotEmpty) {
          await setCurrentCommunity(communities.last);
        }
      }
      return success;
    } catch (e) {
      error.value = 'Erreur de rejoindre: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setCurrentCommunity(CommunityModel community) async {
    if (community.community_id <= 0) {
      error.value = 'Communauté invalide (ID manquant).';
      return;
    }
    currentCommunity.value = community;
    // ✅ Persistance de la sélection
    await _storageService.setCurrentCommunityId(community.community_id);
  }

  Future<bool> restoreCommunitySelection() async {
    final savedId = await _storageService.getCurrentCommunityId();
    if (savedId == null || savedId <= 0) return false;

    try {
      // S'assurer qu'on a la liste
      if (communities.isEmpty) {
        await loadCommunitiesSilently();
      }

      final index = communities.indexWhere((c) => c.community_id == savedId);
      if (index != -1) {
        currentCommunity.value = communities[index];
        // Rafraîchir les détails (role, stats)
        await refreshCurrentCommunity();
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// ✅ IMPORTANT:
  /// - si l’endpoint details renvoie role vide => on conserve l’ancien role
  /// - si l’endpoint details renvoie id=0 => on ignore
  Future<void> refreshCurrentCommunity() async {
    final existing = currentCommunity.value;
    if (existing == null) return;

    if (existing.community_id <= 0) {
      error.value = 'Communauté invalide (ID manquant).';
      return;
    }

    try {
      final fetched = await _communityService.getCommunityDetails(
        existing.community_id,
      );
      if (fetched == null) return;

      if (fetched.community_id <= 0) {
        // ✅ on ignore toute "fausse" réponse
        return;
      }

      final merged = fetched.copyWith(
        role: fetched.role.isNotEmpty ? fetched.role : existing.role,
      );

      currentCommunity.value = merged;

      final index = communities.indexWhere(
        (c) => c.community_id == merged.community_id,
      );
      if (index != -1) {
        final old = communities[index];
        communities[index] = merged.copyWith(
          role: merged.role.isNotEmpty ? merged.role : old.role,
        );
      }
    } catch (e) {
      error.value = 'Erreur de rafraîchissement: $e';
    }
  }

  Future<List<MemberModel>> getCommunityMembers(int communityId) async {
    try {
      isLoading.value = true;
      error.value = '';
      final members = await _communityService.getCommunityMembers(communityId);
      currentMembers.assignAll(members);
      return members;
    } catch (e) {
      error.value = 'Erreur de chargement des membres: $e';
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<InviteModel?> generateInviteCode(int communityId) async {
    try {
      isLoading.value = true;
      error.value = '';
      final invite = await _communityService.generateInviteCode(communityId);

      if (invite != null &&
          currentCommunity.value?.community_id == communityId) {
        currentCommunity.value = currentCommunity.value!.copyWith(
          invite_code: invite.inviteCode,
        );
      }

      return invite;
    } catch (e) {
      error.value = 'Erreur de génération du code: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateMemberRole({
    required int communityId,
    required int memberId,
    required String role,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final success = await _communityService.updateMemberRole(
        communityId: communityId,
        memberId: memberId,
        role: role,
      );

      if (success) {
        final index = currentMembers.indexWhere((m) => m.id == memberId);
        if (index != -1) {
          final m = currentMembers[index];
          currentMembers[index] = MemberModel(
            id: m.id,
            email: m.email,
            nom: m.nom,
            prenom: m.prenom,
            role: role,
            joinedAt: m.joinedAt,
          );
        }
      }

      return success;
    } catch (e) {
      error.value = 'Erreur de modification du rôle: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> removeMember({
    required int communityId,
    required int memberId,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final success = await _communityService.removeMember(
        communityId: communityId,
        memberId: memberId,
      );

      if (success) {
        currentMembers.removeWhere((m) => m.id == memberId);

        final c = currentCommunity.value;
        if (c != null) {
          currentCommunity.value = c.copyWith(
            members_count: (c.members_count - 1).clamp(0, 999999),
          );
        }
      }

      return success;
    } catch (e) {
      error.value = 'Erreur de retrait du membre: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateCommunity({
    required int communityId,
    String? nom,
    String? description,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final success = await _communityService.updateCommunity(
        communityId: communityId,
        nom: nom,
        description: description,
      );

      if (success) {
        final c = currentCommunity.value;
        if (c != null && c.community_id == communityId) {
          currentCommunity.value = c.copyWith(
            nom: nom,
            description: description,
          );
        }

        final index = communities.indexWhere(
          (c) => c.community_id == communityId,
        );
        if (index != -1) {
          communities[index] = communities[index].copyWith(
            nom: nom,
            description: description,
          );
        }
      }

      return success;
    } catch (e) {
      error.value = 'Erreur de mise à jour: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteCommunity(int communityId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final success = await _communityService.deleteCommunity(communityId);

      if (success) {
        communities.removeWhere((c) => c.community_id == communityId);
        if (currentCommunity.value?.community_id == communityId) {
          currentCommunity.value = null;
        }
      }

      return success;
    } catch (e) {
      error.value = 'Erreur de suppression: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> leaveCommunity({
    required int communityId,
    required int userId,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final success = await _communityService.leaveCommunity(
        communityId: communityId,
        userId: userId,
      );

      if (success) {
        communities.removeWhere((c) => c.community_id == communityId);
        if (currentCommunity.value?.community_id == communityId) {
          currentCommunity.value = null;
        }
        currentMembers.clear();
      }

      return success;
    } catch (e) {
      error.value = 'Erreur: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void clearData() {
    communities.clear();
    currentCommunity.value = null;
    currentMembers.clear();
    error.value = '';
  }

  bool isCurrentUserAdmin() => currentCommunity.value?.role == 'ADMIN';
  bool canManageMembers() => currentCommunity.value?.role == 'ADMIN';
}
