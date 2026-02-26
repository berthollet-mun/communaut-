import 'package:community/controllers/community_controller.dart';
import 'package:get/get.dart';

class CommunitySettingsController extends GetxController {
  final CommunityController _communityController = Get.find();

  // ✅ Paramètres de performance (Tâches & Projets)

  /// Afficher uniquement les tâches non terminées dans le Kanban
  RxBool onlyActiveTasks = true.obs;

  /// Nombre max de tâches par colonne du Kanban (pour éviter de tout charger)
  RxInt maxTasksPerColumn = 100.obs; // 100 par défaut

  /// Archiver (ou masquer) les tâches terminées depuis plus de N jours
  RxInt autoArchiveDays = 90.obs; // 90 jours par défaut

  /// Reset aux valeurs par défaut
  void resetToDefaults() {
    onlyActiveTasks.value = true;
    maxTasksPerColumn.value = 100;
    autoArchiveDays.value = 90;
  }

  /// Pour l'instant on ne sauvegarde rien en backend.
  /// Plus tard, quand l’API sera prête, on pourra appeler :
  /// /communities/{id}/settings (GET/PUT)
  void saveLocally() {
    // Ici tu peux plus tard connecter un StorageService si tu veux
    // garder ces préférences par appareil.
  }

  int get currentCommunityId =>
      _communityController.currentCommunity.value?.community_id ?? 0;
}