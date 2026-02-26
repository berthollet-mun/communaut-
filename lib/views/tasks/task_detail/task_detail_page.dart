import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:community/controllers/community_controller.dart';
import 'package:community/controllers/project_controller.dart';
import 'package:community/controllers/task_controller.dart';
import 'package:community/app/routes/app_routes.dart';
import 'package:community/app/themes/app_theme.dart';
import 'package:community/data/models/task_model.dart';
import 'package:community/views/shared/widgets/loading_widget.dart';
import 'package:community/views/shared/widgets/status_chip.dart';

class TaskDetailPage extends StatefulWidget {
  const TaskDetailPage({super.key});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final TaskController _taskController = Get.find();
  final ProjectController _projectController = Get.find();
  final CommunityController _communityController = Get.find();

  late int _communityId;
  late int _projectId;
  late int _taskId;

  final RxBool _firstLoad = true.obs;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments is Map ? (Get.arguments as Map) : {};
    final task = _taskController.currentTask.value;
    final project = _projectController.currentProject.value;
    final community = _communityController.currentCommunity.value;

    _taskId = (args['taskId'] ?? task?.id) ?? -1;
    _projectId = (args['projectId'] ?? project?.id) ?? -1;
    _communityId = (args['communityId'] ?? community?.community_id) ?? -1;

    // évite d’afficher une ancienne tâche avant fetch
    _taskController.currentTask.value = null;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_taskId > 0 && _projectId > 0 && _communityId > 0) {
        await _loadData();
      }
      _firstLoad.value = false;
    });
  }

  Future<void> _loadData() async {
    await _taskController.loadTaskDetails(
      communityId: _communityId,
      projectId: _projectId,
      taskId: _taskId,
    );
  }

  Future<void> _changeStatus(String newStatus) async {
    final success = await _taskController.updateTaskStatus(
      communityId: _communityId,
      projectId: _projectId,
      taskId: _taskId,
      status: newStatus,
    );

    if (success) {
      await _loadData();
      Get.snackbar(
        'Succès',
        'Statut: "$newStatus"',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Erreur',
        _taskController.error.value.isNotEmpty 
            ? _taskController.error.value 
            : 'Impossible de changer le statut',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _openComments(TaskModel task) async {
    final community = _communityController.currentCommunity.value;

    // ✅ on attend le retour, puis on refresh les détails (donc compteur)
    await Get.toNamed(
      AppRoutes.taskComments,
      arguments: {
        'communityId': _communityId,
        'projectId': _projectId,
        'taskId': _taskId,
        'taskTitle': task.titre,
        'userRole': community?.role ?? 'MEMBRE',
      },
    );

    // ✅ refresh au retour
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final community = _communityController.currentCommunity.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Get.toNamed(AppRoutes.createEditTask),
          ),
          Obx(() {
            final community = _communityController.currentCommunity.value;
            if (community?.role == 'MEMBRE') return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _confirmDelete,
              tooltip: 'Supprimer',
            );
          }),
        ],
      ),
      body: Obx(() {
        if (_firstLoad.value || _taskController.isLoading.value) {
          return const LoadingWidget(message: 'Chargement...');
        }

        final task = _taskController.currentTask.value;
        if (task == null || community == null) {
          return const Center(child: Text('Tâche non trouvée'));
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeader(task),
                const SizedBox(height: 16),
                _buildDetails(task, community),
                const SizedBox(height: 16),

                // ✅ mini section commentaires
                _buildCommentsMini(task),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader(TaskModel task) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.cardShadow],
        border: task.isOverdue ? Border.all(color: Colors.red, width: 2) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              task.titre,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          StatusChip(status: task.status),
        ],
      ),
    );
  }

  Widget _buildDetails(TaskModel task, dynamic community) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations',
            style: AppTheme.headline2.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),

          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Assigné à',
            value: task.assignedFullName,
          ),
          const Divider(height: 24),

          _buildInfoRow(
            icon: Icons.calendar_today,
            label: 'Échéance',
            value: task.due_date != null
                ? _formatDate(task.due_date!)
                : 'Non définie',
            valueColor: task.isOverdue ? Colors.red : null,
          ),
          const Divider(height: 24),

          _buildInfoRow(
            icon: Icons.folder_outlined,
            label: 'Projet',
            value: task.project_nom ?? 'N/A',
            maxLines: 2,
          ),
          const Divider(height: 24),

          _buildInfoRow(
            icon: Icons.person_add_outlined,
            label: 'Créé par',
            value: task.creatorFullName,
          ),
          const Divider(height: 24),

          _buildInfoRow(
            icon: Icons.access_time,
            label: 'Créée le',
            value: _formatDateTime(task.created_at),
          ),
          const Divider(height: 24),

          _buildDescriptionInline(task),
          const SizedBox(height: 16),

          if (community.role != 'MEMBRE') ...[
            Text('Changer statut', style: AppTheme.bodyText2),
            const SizedBox(height: 10),
            _buildStatusSelector(task),
          ],
        ],
      ),
    );
  }

  Widget _buildDescriptionInline(TaskModel task) {
    final desc = task.description.trim();
    final hasDesc = desc.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description_outlined, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Text('Description', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            hasDesc ? desc : 'Aucune description',
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 5,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w600, color: valueColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSelector(TaskModel task) {
    const statuses = ['À faire', 'En cours', 'Terminé'];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: statuses.map((status) {
        final isSelected = task.status == status;
        final color = _getStatusColor(status);

        return ChoiceChip(
          label: Text(status),
          selected: isSelected,
          onSelected: isSelected ? null : (_) => _changeStatus(status),
          selectedColor: color.withOpacity(0.18),
          backgroundColor: Colors.grey.withOpacity(0.08),
          labelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? color : Colors.black87,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isSelected ? color : Colors.transparent),
          ),
          avatar: isSelected ? Icon(Icons.check, size: 16, color: color) : null,
        );
      }).toList(),
    );
  }

  Widget _buildCommentsMini(TaskModel task) {
    final count = task.comments_count;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Commentaires',
                style: AppTheme.headline2.copyWith(fontSize: 18),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                tooltip: 'Rafraîchir',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Pour lire/écrire des commentaires, ouvre la page dédiée.",
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _openComments(task),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Ouvrir la page commentaires'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer la tâche'),
        content: const Text('Voulez-vous vraiment supprimer cette tâche ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await _taskController.deleteTask(
                communityId: _communityId,
                projectId: _projectId,
                taskId: _taskId,
              );

              if (success) {
                Get.back(); // Retour au Kanban
                Get.snackbar(
                  'Succès',
                  'Tâche supprimée',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  'Erreur',
                  _taskController.error.value.isNotEmpty 
                      ? _taskController.error.value 
                      : 'Impossible de supprimer la tâche',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 4),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'À faire':
        return Colors.grey;
      case 'En cours':
        return Colors.orange;
      case 'Terminé':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
