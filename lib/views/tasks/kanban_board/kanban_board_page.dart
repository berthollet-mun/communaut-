import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:community/app/routes/app_routes.dart';
import 'package:community/controllers/task_controller.dart';
import 'package:community/controllers/project_controller.dart';
import 'package:community/controllers/community_controller.dart';
import 'package:community/controllers/auth_controller.dart';
import 'package:community/data/models/task_model.dart';
import 'package:community/data/models/member_model.dart';
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
  final AuthController _authController = Get.find();

  late int _communityId;
  late int _projectId;

  bool get _canManageTasks {
    final role = _communityController.currentCommunity.value?.role ?? 'MEMBRE';
    return role == 'ADMIN' || role == 'RESPONSABLE';
  }

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
    if (!_canManageTasks) {
      Get.snackbar(
        'Accès refusé',
        'Vous n\'avez pas les autorisations nécessaires pour modifier ou supprimer cette tâche. Veuillez contacter un administrateur si vous pensez qu\'il s\'agit d\'une erreur.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Changer l\'assignation'),
                  subtitle: Text(
                    task.assignedFullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () async {
                    Get.back();
                    await _showAssignmentSheet(task);
                  },
                ),
                const Divider(),
                _buildStatusTile(task, 'À faire', Colors.red),
                _buildStatusTile(task, 'En cours', Colors.orange),
                _buildStatusTile(task, 'Terminé', Colors.green),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Supprimer',
                    style: TextStyle(color: Colors.red),
                  ),
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

  Future<void> _showAssignmentSheet(TaskModel task) async {
    List<MemberModel> members = [];
    try {
      members = await _communityController.getCommunityMembers(_communityId);
    } catch (_) {}

    final currentUserId = _authController.user.value?.user_id;
    final assignableMembers = members.where((m) {
      final isCurrentUser = currentUserId != null && m.id == currentUserId;
      final isAdmin = m.role.toUpperCase() == 'ADMIN';
      return !isCurrentUser && !isAdmin;
    }).toList();

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.62,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Changer l\'assignation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_off_outlined),
                      title: const Text('Non assigné'),
                      trailing: task.assigned_to == null
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () async {
                        Navigator.of(context).pop();
                        await _updateTaskAssignment(task, null);
                      },
                    ),
                    const Divider(),
                    if (assignableMembers.isEmpty)
                      const ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text('Aucun membre assignable'),
                        subtitle: Text(
                          'Les administrateurs et votre compte sont exclus.',
                        ),
                      )
                    else
                      ...assignableMembers.map(
                        (member) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(
                              _initials(member),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          title: Text(member.fullName),
                          subtitle: Text(member.email),
                          trailing: task.assigned_to == member.id
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                          onTap: () async {
                            Navigator.of(context).pop();
                            await _updateTaskAssignment(task, member.id);
                          },
                        ),
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

  Future<void> _updateTaskAssignment(TaskModel task, int? assignedTo) async {
    final ok = await _taskController.updateTask(
      communityId: _communityId,
      projectId: _projectId,
      taskId: task.id,
      assignedTo: assignedTo,
      clearAssignment: assignedTo == null,
    );

    if (ok) {
      await _load();
      if (!mounted) return;
      Get.snackbar(
        'Succès',
        assignedTo == null
            ? 'La tâche a été désassignée'
            : 'Assignation mise à jour',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Erreur',
        _taskController.error.value.isNotEmpty
            ? _taskController.error.value
            : 'Impossible de changer l\'assignation',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String _initials(MemberModel member) {
    final p = member.prenom.trim();
    final n = member.nom.trim();
    final first = p.isNotEmpty ? p[0] : 'U';
    final second = n.isNotEmpty ? n[0] : 'U';
    return '$first$second'.toUpperCase();
  }

  Widget _buildStatusTile(TaskModel task, String status, Color color) {
    final isCurrent =
        _taskController.normalizeStatus(task.status) ==
        _taskController.normalizeStatus(status);
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
              await _changeTaskStatus(task, status);
            },
    );
  }

  Future<void> _changeTaskStatus(TaskModel task, String status) async {
    if (!_canManageTasks) {
      Get.snackbar(
        'Accès refusé',
        'Vous n\'avez pas les autorisations nécessaires pour modifier le statut de cette tâche. Veuillez contacter un administrateur si vous pensez qu\'il s\'agit d\'une erreur.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final ok = await _taskController.updateTaskStatus(
      communityId: _communityId,
      projectId: _projectId,
      taskId: task.id,
      status: status,
    );
    if (ok) {
      // Do not immediately reload from server: the local Kanban state has
      // already been updated and an immediate fetch can reintroduce stale data.
      Future.delayed(const Duration(milliseconds: 900), () {
        _taskController.loadKanbanTasks(
          communityId: _communityId,
          projectId: _projectId,
        );
      });
      Get.snackbar(
        'Succès',
        'Statut changé vers "$status".',
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

  void _confirmDelete(TaskModel task) {
    if (!_canManageTasks) {
      Get.snackbar(
        'Accès refusé',
        'Vous n\'avez pas les autorisations nécessaires pour supprimer cette tâche. Veuillez contacter un administrateur si vous pensez qu\'il s\'agit d\'une erreur.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

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
                await _load();
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

        if (_taskController.error.value.isNotEmpty &&
            _taskController.kanban.value == null) {
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
        final todoTasks = k.todo.where((t) => !t.isDeleted).toList();
        final inProgressTasks = k.inProgress
            .where((t) => !t.isDeleted)
            .toList();
        final doneTasks = k.done.where((t) => !t.isDeleted).toList();
        final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    count: todoTasks.length,
                    headerColor: Colors.red.withOpacity(isDark ? 0.20 : 0.12),
                    titleColor: Colors.red,
                    tasks: todoTasks,
                    onOpen: _openTask,
                    onOpenComments: _openComments,
                    onLongPress: _showTaskActions,
                    canManageTasks: _canManageTasks,
                    onChangeStatus: _changeTaskStatus,
                  ),
                  const SizedBox(width: 12),
                  _KanbanColumn(
                    title: 'En cours',
                    count: inProgressTasks.length,
                    headerColor: Colors.orange.withOpacity(
                      isDark ? 0.20 : 0.12,
                    ),
                    titleColor: Colors.orange,
                    tasks: inProgressTasks,
                    onOpen: _openTask,
                    onOpenComments: _openComments,
                    onLongPress: _showTaskActions,
                    canManageTasks: _canManageTasks,
                    onChangeStatus: _changeTaskStatus,
                  ),
                  const SizedBox(width: 12),
                  _KanbanColumn(
                    title: 'Terminé',
                    count: doneTasks.length,
                    headerColor: Colors.green.withOpacity(isDark ? 0.20 : 0.12),
                    titleColor: Colors.green,
                    tasks: doneTasks,
                    onOpen: _openTask,
                    onOpenComments: _openComments,
                    onLongPress: _showTaskActions,
                    canManageTasks: _canManageTasks,
                    onChangeStatus: _changeTaskStatus,
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
  final bool canManageTasks;
  final Future<void> Function(TaskModel task, String status) onChangeStatus;

  const _KanbanColumn({
    required this.title,
    required this.count,
    required this.headerColor,
    required this.titleColor,
    required this.tasks,
    required this.onOpen,
    required this.onOpenComments,
    required this.onLongPress,
    required this.canManageTasks,
    required this.onChangeStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onSurface.withOpacity(isDark ? 0.10 : 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.04),
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
                    color: titleColor.withOpacity(isDark ? 0.20 : 0.14),
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
                        canManageTasks: canManageTasks,
                        onChangeStatus: (status) =>
                            onChangeStatus(task, status),
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
  final bool canManageTasks;
  final Future<void> Function(String status) onChangeStatus;

  const _TaskCard({
    required this.task,
    required this.onTap,
    required this.onCommentsTap,
    required this.onLongPress,
    required this.canManageTasks,
    required this.onChangeStatus,
  });

  @override
  Widget build(BuildContext context) {
    final due = task.due_date;
    final overdue = task.isOverdue;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final taskSurface = isDark
        ? colorScheme.onSurface.withOpacity(0.04)
        : theme.scaffoldBackgroundColor;
    final metaColor = colorScheme.onSurface.withOpacity(isDark ? 0.78 : 0.70);
    final metaBackground = colorScheme.onSurface.withOpacity(
      isDark ? 0.08 : 0.06,
    );

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: taskSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.onSurface.withOpacity(isDark ? 0.10 : 0.06),
          ),
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (task.isAssigned)
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: colorScheme.primary.withOpacity(
                      isDark ? 0.24 : 0.18,
                    ),
                    child: Text(
                      (task.assigned_prenom ?? 'U')
                          .substring(0, 1)
                          .toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                PopupMenuButton<String>(
                  tooltip: 'Changer le statut',
                  onSelected: (status) => onChangeStatus(status),
                  enabled: canManageTasks,
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'À faire', child: Text('À faire')),
                    PopupMenuItem(value: 'En cours', child: Text('En cours')),
                    PopupMenuItem(value: 'Terminé', child: Text('Terminé')),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(
                        task.status,
                      ).withOpacity(isDark ? 0.18 : 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          task.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _statusColor(task.status),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 14,
                          color: _statusColor(task.status),
                        ),
                      ],
                    ),
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
                style: TextStyle(color: metaColor),
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
                      color: metaBackground,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 16,
                          color: metaColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${task.comments_count > 0 ? task.comments_count : ""}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: metaColor,
                            fontSize: 12,
                          ),
                        ),
                        if (task.comments_count > 0) const SizedBox(width: 4),
                        Text(
                          'Commentaires',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: metaColor,
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

  Color _statusColor(String status) {
    switch (taskStatus(status)) {
      case 'En cours':
        return Colors.orange;
      case 'Terminé':
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  String taskStatus(String status) =>
      Get.find<TaskController>().normalizeStatus(status);
}
