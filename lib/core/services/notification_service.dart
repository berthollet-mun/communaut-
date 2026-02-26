// ignore_for_file: avoid_print

import 'package:community/core/services/api_service.dart';
import 'package:community/data/models/notification_model.dart';
import 'package:get/get.dart';

class NotificationService extends GetxService {
  final ApiService _apiService = Get.find();

  /// Récupérer toutes les notifications de l'utilisateur
  Future<List<NotificationModel>> getNotifications({int limit = 50}) async {
    try {
      final response = await _apiService.get('/notifications?limit=$limit');

      if (response.success && response.data != null) {
        final List<dynamic> notificationsList =
            response.data['notifications'] ?? response.data ?? [];

        return notificationsList
            .map((item) => NotificationModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('Erreur NotificationService.getNotifications: $e');
      return [];
    }
  }

  /// Marquer une notification comme lue
  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await _apiService.post(
        '/notifications/$notificationId/read',
        {},
      );
      return response.success;
    } catch (e) {
      print('Erreur NotificationService.markAsRead: $e');
      return false;
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiService.post('/notifications/read-all', {});
      return response.success;
    } catch (e) {
      print('Erreur NotificationService.markAllAsRead: $e');
      return false;
    }
  }

  /// Supprimer une notification
  Future<bool> deleteNotification(int notificationId) async {
    try {
      final response = await _apiService.delete(
        '/notifications/$notificationId',
      );
      return response.success;
    } catch (e) {
      print('Erreur NotificationService.deleteNotification: $e');
      return false;
    }
  }

  /// Compter les notifications non lues
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get('/notifications/unread-count');

      if (response.success && response.data != null) {
        return response.data['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Erreur NotificationService.getUnreadCount: $e');
      return 0;
    }
  }
}
