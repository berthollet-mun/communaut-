import 'package:community/core/services/notification_service.dart';
import 'package:community/data/models/notification_model.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  // ✅ Initialisation différée
  NotificationService? _notificationService;

  NotificationService get notificationService {
    _notificationService ??= Get.find<NotificationService>();
    return _notificationService!;
  }

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxInt unreadCount = 0.obs;

  static const int _maxLocalNotifications = 100;

  /// Charger les notifications depuis l'API
  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      error.value = '';

      final notificationsList = await notificationService.getNotifications();
      notifications.assignAll(notificationsList);

      _updateUnreadCount();
    } catch (e) {
      error.value = 'Erreur de chargement des notifications: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Charger seulement le compteur (plus léger)
  Future<void> loadUnreadCount() async {
    try {
      final count = await notificationService.getUnreadCount();
      unreadCount.value = count;
    } catch (e) {
      _updateUnreadCount();
    }
  }

  /// Marquer une notification comme lue
  Future<bool> markAsRead(int notificationId) async {
    try {
      final success = await notificationService.markAsRead(notificationId);

      if (success) {
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index] = notifications[index].copyWith(is_read: true);
        }
        _updateUnreadCount();
      }

      return success;
    } catch (e) {
      error.value = 'Erreur: $e';
      return false;
    }
  }

  /// Marquer toutes comme lues
  Future<bool> markAllAsRead() async {
    try {
      final success = await notificationService.markAllAsRead();

      if (success) {
        notifications.value = notifications
            .map((n) => n.copyWith(is_read: true))
            .toList();
        unreadCount.value = 0;
      }

      return success;
    } catch (e) {
      error.value = 'Erreur: $e';
      return false;
    }
  }

  /// Supprimer une notification
  Future<bool> deleteNotification(int notificationId) async {
    try {
      final success = await notificationService.deleteNotification(
        notificationId,
      );

      if (success) {
        notifications.removeWhere((n) => n.id == notificationId);
        _updateUnreadCount();
      }

      return success;
    } catch (e) {
      error.value = 'Erreur: $e';
      return false;
    }
  }

  // ============================================================
  // NOTIFICATIONS LOCALES (pour les réponses API)
  // ============================================================

  /// Ajouter une notification locale (sans API)
  void addLocalNotification({
    required String type,
    required String title,
    required String message,
    int? relatedId,
    String? relatedType,
  }) {
    final notification = NotificationModel.local(
      type: type,
      title: title,
      message: message,
      relatedId: relatedId,
      relatedType: relatedType,
    );

    notifications.insert(0, notification);

    if (notifications.length > _maxLocalNotifications) {
      notifications.removeLast();
    }

    _updateUnreadCount();
  }

  /// Ajouter notification de succès
  void notifySuccess(String title, String message) {
    addLocalNotification(type: 'success', title: title, message: message);
  }

  /// Ajouter notification d'erreur
  void notifyError(String title, String message) {
    addLocalNotification(type: 'error', title: title, message: message);
  }

  /// Ajouter notification d'info
  void notifyInfo(String title, String message) {
    addLocalNotification(type: 'info', title: title, message: message);
  }

  /// Ajouter notification de tâche créée
  void notifyTaskCreated(String taskTitle, int taskId) {
    addLocalNotification(
      type: 'task_created',
      title: 'Tâche créée',
      message: 'La tâche "$taskTitle" a été créée avec succès.',
      relatedId: taskId,
      relatedType: 'task',
    );
  }

  /// Ajouter notification de tâche assignée
  void notifyTaskAssigned(String taskTitle, String assigneeName, int taskId) {
    addLocalNotification(
      type: 'task_assigned',
      title: 'Tâche assignée',
      message: 'La tâche "$taskTitle" a été assignée à $assigneeName.',
      relatedId: taskId,
      relatedType: 'task',
    );
  }

  /// Ajouter notification de commentaire
  void notifyCommentAdded(String taskTitle, int taskId) {
    addLocalNotification(
      type: 'comment_added',
      title: 'Nouveau commentaire',
      message: 'Un commentaire a été ajouté sur "$taskTitle".',
      relatedId: taskId,
      relatedType: 'task',
    );
  }

  /// Ajouter notification de projet créé
  void notifyProjectCreated(String projectName, int projectId) {
    addLocalNotification(
      type: 'project_created',
      title: 'Projet créé',
      message: 'Le projet "$projectName" a été créé avec succès.',
      relatedId: projectId,
      relatedType: 'project',
    );
  }

  /// Ajouter notification de communauté créée
  void notifyCommunityCreated(String communityName, int communityId) {
    addLocalNotification(
      type: 'community_created',
      title: 'Communauté créée',
      message: 'La communauté "$communityName" a été créée avec succès.',
      relatedId: communityId,
      relatedType: 'community',
    );
  }

  /// Ajouter notification de connexion
  void notifyLogin(String userName) {
    addLocalNotification(
      type: 'login',
      title: 'Connexion réussie',
      message: 'Bienvenue $userName ! Vous êtes maintenant connecté.',
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => n.isUnread).length;
  }

  void clearAll() {
    notifications.clear();
    unreadCount.value = 0;
  }

  List<NotificationModel> get unreadNotifications =>
      notifications.where((n) => n.isUnread).toList();

  List<NotificationModel> get readNotifications =>
      notifications.where((n) => n.is_read).toList();

  bool get hasUnread => unreadCount.value > 0;
}
