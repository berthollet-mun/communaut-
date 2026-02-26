import 'package:community/app/themes/app_theme.dart';
import 'package:community/controllers/activity_controller.dart';
import 'package:community/controllers/community_controller.dart';
import 'package:community/data/models/activity_model.dart';
import 'package:community/core/utils/widgets/responsive_builder.dart';
import 'package:community/views/shared/widgets/empty_state.dart';
import 'package:community/views/shared/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActivityLogPage extends StatefulWidget {
  const ActivityLogPage({super.key});

  @override
  State<ActivityLogPage> createState() => _ActivityLogPageState();
}

class _ActivityLogPageState extends State<ActivityLogPage> {
  final ActivityController _activityController = Get.find();
  final CommunityController _communityController = Get.find();

  late int _communityId;

  @override
  void initState() {
    super.initState();
    final community = _communityController.currentCommunity.value;
    if (community != null) {
      _communityId = community.community_id;
      _loadActivities();
    }
  }

  Future<void> _loadActivities() async {
    await _activityController.loadCommunityActivities(
      communityId: _communityId,
    );
  }

  Future<void> _refreshActivities() async {
    await _loadActivities();
  }

  void _filterActivities() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtrer les activités',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              const Text('Type d\'activité :'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Toutes'),
                    selected: true,
                    onSelected: (_) {},
                  ),
                  FilterChip(
                    label: const Text('Tâches'),
                    selected: false,
                    onSelected: (_) {},
                  ),
                  FilterChip(
                    label: const Text('Commentaires'),
                    selected: false,
                    onSelected: (_) {},
                  ),
                  FilterChip(
                    label: const Text('Projets'),
                    selected: false,
                    onSelected: (_) {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Période :'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('7 derniers jours'),
                    selected: true,
                    onSelected: (_) {},
                  ),
                  FilterChip(
                    label: const Text('30 derniers jours'),
                    selected: false,
                    onSelected: (_) {},
                  ),
                  FilterChip(
                    label: const Text('Tout'),
                    selected: false,
                    onSelected: (_) {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.snackbar(
                    'Filtres appliqués',
                    'Nous attendons les informations du développeur backend pour activer cette fonctionnalité.',
                    backgroundColor: Colors.blue,
                    colorText: Colors.white,
                  );
                },
                child: const Text('Appliquer les filtres'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final community = _communityController.currentCommunity.value;
    if (community == null) {
      return const Center(child: Text('Communauté non sélectionnée'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des activités'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshActivities,
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _filterActivities,
            tooltip: 'Filtrer',
          ),
        ],
      ),
      body: Obx(() {
        if (_activityController.isLoading.value) {
          return const LoadingWidget(message: 'Chargement de l\'historique...');
        }

        if (_activityController.error.value.isNotEmpty) {
          return EmptyStateWidget(
            title: 'Erreur de chargement',
            message: _activityController.error.value,
            icon: Icons.error_outline,
            onAction: _refreshActivities,
            actionLabel: 'Réessayer',
          );
        }

        final activities = _activityController.filteredActivities;

        if (activities.isEmpty) {
          return EmptyStateWidget(
            title: 'Aucune activité',
            message: 'Aucune activité enregistrée pour le moment.',
            icon: Icons.history_outlined,
          );
        }

        return ResponsiveContainer(
          child: RefreshIndicator(
            onRefresh: _refreshActivities,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return _buildActivityItem(activity, index);
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildActivityItem(ActivityModel activity, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getActivityColor(
                  activity.activity_type,
                ).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                _activityController.getActivityIcon(activity.activity_type),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 12),
            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _getUserColor(activity.email),
                        radius: 10,
                        child: Text(
                          _getUserInitials(activity.fullName),
                          style: const TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        activity.fullName,
                        style: AppTheme.bodyText2.copyWith(fontSize: 12),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(activity.created_at),
                        style: AppTheme.bodyText2.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getActivityColor(String activityType) {
    if (activityType.contains('task')) return Colors.blue;
    if (activityType.contains('comment')) return Colors.green;
    if (activityType.contains('project')) return Colors.orange;
    if (activityType.contains('member')) return Colors.purple;
    return Colors.grey;
  }

  Color _getUserColor(String email) {
    final hash = email.hashCode;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
    ];
    return colors[hash.abs() % colors.length];
  }

  String _getUserInitials(String fullName) {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
