import 'package:community/app/routes/app_routes.dart';
import 'package:community/controllers/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationBadge extends StatelessWidget {
  final double iconSize;
  final Color? iconColor;

  const NotificationBadge({super.key, this.iconSize = 24, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.notifications_outlined, size: iconSize, color: iconColor),
          Obx(() {
            final count = Get.find<NotificationController>().unreadCount.value;
            if (count > 0) {
              return Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      onPressed: () => Get.toNamed(AppRoutes.notifications),
      tooltip: 'Notifications',
    );
  }
}
