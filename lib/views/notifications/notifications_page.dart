import 'package:community/controllers/notification_controller.dart';
import 'package:community/data/models/notification_model.dart';
import 'package:community/views/shared/widgets/empty_state.dart';
import 'package:community/views/shared/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationController _controller = Get.find();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    await _controller.loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Obx(() {
            if (_controller.hasUnread) {
              return IconButton(
                icon: const Icon(Icons.done_all),
                onPressed: _markAllAsRead,
                tooltip: 'Tout marquer comme lu',
              );
            }
            return const SizedBox.shrink();
          }),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.notifications.isEmpty) {
          return const LoadingWidget(message: 'Chargement...');
        }

        if (_controller.notifications.isEmpty) {
          return EmptyStateWidget(
            title: 'Aucune notification',
            message: 'Vous n\'avez pas encore de notification.',
            icon: Icons.notifications_off_outlined,
          );
        }

        return RefreshIndicator(
          onRefresh: _loadNotifications,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.notifications.length,
            itemBuilder: (context, index) {
              return _buildNotificationCard(_controller.notifications[index]);
            },
          ),
        );
      }),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) => _deleteNotification(notification),
      child: GestureDetector(
        onTap: () => _onNotificationTap(notification),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isUnread
                ? Colors.blue.withOpacity(0.05)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.isUnread
                  ? Colors.blue.withOpacity(0.3)
                  : Colors.grey[200]!,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getTypeColor(notification.type).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  notification.icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),

              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: notification.isUnread
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (notification.isUnread)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(notification.created_at),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onNotificationTap(NotificationModel notification) async {
    if (notification.isUnread) {
      await _controller.markAsRead(notification.id);
    }
  }

  void _markAllAsRead() async {
    final success = await _controller.markAllAsRead();

    Get.snackbar(
      success ? 'Succès' : 'Erreur',
      success
          ? 'Toutes les notifications ont été marquées comme lues'
          : 'Impossible de marquer comme lu',
      backgroundColor: success ? Colors.green : Colors.red,
      colorText: Colors.white,
    );
  }

  void _deleteNotification(NotificationModel notification) async {
    final success = await _controller.deleteNotification(notification.id);

    Get.snackbar(
      success ? 'Supprimé' : 'Erreur',
      success ? 'Notification supprimée' : 'Impossible de supprimer',
      backgroundColor: success ? Colors.green : Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'task_created':
      case 'task_assigned':
        return Colors.blue;
      case 'task_completed':
      case 'success':
        return Colors.green;
      case 'comment_added':
        return Colors.orange;
      case 'member_joined':
        return Colors.purple;
      case 'project_created':
        return Colors.teal;
      case 'community_created':
        return Colors.indigo;
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.amber;
      case 'login':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    return '${date.day}/${date.month}/${date.year}';
  }
}
