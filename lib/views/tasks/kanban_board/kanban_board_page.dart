import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:community/app/routes/app_routes.dart';
import 'package:community/controllers/task_controller.dart';
import 'package:community/controllers/project_controller.dart';
import 'package:community/controllers/community_controller.dart';
import 'package:community/core/utils/responsive_helper.dart';
import 'package:community/core/utils/widgets/responsive_builder.dart';
import 'package:community/data/models/task_model.dart';
import 'package:community/views/shared/widgets/loading_widget.dart';

class KanbanBoardPage extends StatefulWidget {
  const KanbanBoardPage({super.key});

  @override
  State<KanbanBoardPage> createState() => _KanbanBoardPageState();
}

class _KanbanBoardPageState extends State<KanbanBoardPage> {
  final TaskController _taskController = Get.find();
  final ProjectController _projectController = Get.find();
  final CommunityController _communityController = Get.find();

  late int _communityId;
  late int _projectId;

  @override
  void initState() {
    super.initState();
    _updateIds();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _load();
    });
  }

  void _updateIds() {
    final community = _communityController.currentCommunity.value;
    final project = _projectController.currentProject.value;

    _communityId = community?.community_id ?? -1;
    _projectId = project?.id ?? -1;
  }

  Future<void> _load() async {
    // Si IDs invalides, tenter de les récupérer à nouveau des controllers
    if (_communityId <= 0 || _projectId <= 0) {
      _updateIds();
    }

    if (_communityId <= 0 || _projectId <= 0) {
      print('❌ Kanban: IDs invalides (C:$_communityId, P:$_projectId)');
      return;
    }

    await _taskController.loadKanbanTasks(
      communityId: _communityId,
      projectId: _projectId,
    );
  }

  Future<void> _openTask(TaskModel task) async {
    // important : set current task
    _taskController.setCurrentTask(task);

    // ouvre détails
    await Get.toNamed(
      AppRoutes.taskDetail,
      arguments: {
        'communityId': _communityId,
        'projectId': _projectId,
        'taskId': task.id,
      },
    );

    // au retour, refresh
    await _load();
  }

  Future<void> _editTask(TaskModel task) async {
    _taskController.setCurrentTask(task);
    await Get.toNamed(AppRoutes.createEditTask);
    await _load();
  }

  // ✅ Ouvrir la page commentaires (sans utiliser comments_count dans l’UI)
  Future<void> _openComments(TaskModel task) async {
    final community = _communityController.currentCommunity.value;
    final role = (community?.role ?? 'MEMBRE').toString();

    await Get.toNamed(
      AppRoutes.taskComments,
      arguments: {
        'communityId': _communityId,
        'projectId': _projectId,
        'taskId': task.id,
        'taskTitle': task.titre,
        'userRole': role,
      },
    );

    // au retour, refresh (au cas où backend change quelque chose)
    await _load();
  }

  void _showTaskActions(TaskModel task) {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    task.titre,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Modifier la tâche'),
                  onTap: () async {
                    Get.back();
                    await _editTask(task);
                  },
                ),
                const Divider(),
                _buildStatusTile(task, 'À faire', Colors.red),
                _buildStatusTile(task, 'En cours', Colors.orange),
                _buildStatusTile(task, 'Terminé', Colors.green),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Get.back();
                    _confirmDelete(task);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildStatusTile(TaskModel task, String status, Color color) {
    final isCurrent = task.status == status;
    return ListTile(
      leading: Icon(
        isCurrent ? Icons.check_circle : Icons.circle_outlined,
        color: color,
      ),
      title: Text('Passer à "$status"'),
      onTap: isCurrent
          ? null
          : () async {
              Get.back();
              final ok = await _taskController.updateTaskStatus(
                communityId: _communityId,
                projectId: _projectId,
                taskId: task.id,
                status: status,
              );
              if (ok) {
                // await _load(); // Retiré : le contrôleur met à jour l'UI localement
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
            },
    );
  }

  void _confirmDelete(TaskModel task) {
    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer la tâche'),
        content: Text('Voulez-vous vraiment supprimer "${task.titre}" ?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              Get.back();
              final ok = await _taskController.deleteTask(
                communityId: _communityId,
                projectId: _projectId,
                taskId: task.id,
              );
                if (ok) {
                  Get.snackbar(
                    'Succès',
                    'Tâche supprimée',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                  // await _load(); // Retiré : le contrôleur met à jour l'UI localement
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final project = _projectController.currentProject.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(project?.nom ?? 'Tableau Kanban'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          _taskController.clearCurrentTask(); // Reset state for creation mode
          await Get.toNamed(AppRoutes.createEditTask);
          await _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle tâche'),
      ),
      body: Obx(() {
        if (_taskController.isLoading.value) {
          return const LoadingWidget(message: 'Chargement des tâches...');
        }

        if (_taskController.error.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 42),
                  const SizedBox(height: 10),
                  Text(
                    _taskController.error.value,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _load,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        final k = _taskController.kanban.value;
        if (k == null) {
          return const Center(child: Text('Aucune donnée'));
        }

        return RefreshIndicator(
          onRefresh: _load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _KanbanColumn(
                    title: 'À faire',
                    count: k.todo.length,
                     headerColor: Colors.red.withOpacity(0.12),
                    titleColor: Colors.red,
                    tasks: k.todo,
                    onOpen: _openTask,
                    onOpenComments: _openComments,
                    onLongPress: _showTaskActions,
                  ),
                  const SizedBox(width: 12),
                  _KanbanColumn(
                    title: 'En cours',
                    count: k.inProgress.length,
                    headerColor: Colors.orange.withOpacity(0.12),
                    titleColor: Colors.orange,
                    tasks: k.inProgress,
                    onOpen: _openTask,
                    onOpenComments: _openComments,
                    onLongPress: _showTaskActions,
                  ),
                  const SizedBox(width: 12),
                  _KanbanColumn(
                    title: 'Terminé',
                    count: k.done.length,
                    headerColor: Colors.green.withOpacity(0.12),
                    titleColor: Colors.green,
                    tasks: k.done,
                    onOpen: _openTask,
                    onOpenComments: _openComments,
                    onLongPress: _showTaskActions,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final String title;
  final int count;
  final Color headerColor;
  final Color titleColor;
  final List<TaskModel> tasks;
  final Future<void> Function(TaskModel task) onOpen;

  // ✅ ajouté uniquement pour le bouton Commentaires
  final Future<void> Function(TaskModel task) onOpenComments;
  final void Function(TaskModel task) onLongPress;

  const _KanbanColumn({
    required this.title,
    required this.count,
    required this.headerColor,
    required this.titleColor,
    required this.tasks,
    required this.onOpen,
    required this.onOpenComments,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: titleColor.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Aucune tâche'),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return _TaskCard(
                        task: task,
                        onTap: () => onOpen(task),
                        onLongPress: () => onLongPress(task),
                        onCommentsTap: () => onOpenComments(task),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;

  // ✅ ajouté uniquement pour le bouton Commentaires
  final VoidCallback onCommentsTap;
  final VoidCallback onLongPress;

  const _TaskCard({
    required this.task,
    required this.onTap,
    required this.onCommentsTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final due = task.due_date;
    final overdue = task.isOverdue;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.titre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
                if (task.isAssigned)
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    child: Text(
                      (task.assigned_prenom ?? 'U').substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            if (task.description.trim().isNotEmpty)
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
            const SizedBox(height: 10),

            Row(
              children: [
                // ✅ ✅ ✅ PARTIE MODIFIÉE : on affiche seulement "Commentaires"
                InkWell(
                  onTap: onCommentsTap,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 16,
                          color: Colors.grey[800],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${task.comments_count > 0 ? task.comments_count : ""}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[900],
                            fontSize: 12,
                          ),
                        ),
                        if (task.comments_count > 0) const SizedBox(width: 4),
                        Text(
                          'Commentaires',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[900],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ✅ ✅ ✅ FIN MODIF
                const Spacer(),

                if (due != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: (overdue ? Colors.red : Colors.orange).withOpacity(
                        0.12,
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: 16,
                          color: overdue ? Colors.red : Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${due.day}/${due.month}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: overdue ? Colors.red : Colors.orange,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
