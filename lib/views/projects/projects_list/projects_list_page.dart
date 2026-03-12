import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:community/controllers/community_controller.dart';
import 'package:community/controllers/project_controller.dart';
import 'package:community/app/routes/app_routes.dart';
import 'package:community/app/themes/app_theme.dart';
import 'package:community/data/models/community_model.dart';
import 'package:community/data/models/project_model.dart';
import 'package:community/core/utils/responsive_helper.dart';
import 'package:community/core/utils/widgets/responsive_builder.dart';
import 'package:community/core/utils/date_time_helper.dart';
import 'package:community/views/shared/widgets/empty_state.dart';
import 'package:community/views/shared/widgets/loading_widget.dart';

class ProjectsListPage extends StatefulWidget {
  const ProjectsListPage({super.key});

  @override
  State<ProjectsListPage> createState() => _ProjectsListPageState();
}

class _ProjectsListPageState extends State<ProjectsListPage> {
  final ProjectController _projectController = Get.find();
  final CommunityController _communityController = Get.find();

  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    // On ne charge plus ici, on laisse build décider quand tout est prêt
  }

  Future<void> _loadProjects() async {
    final community = _communityController.currentCommunity.value;
    if (community == null) return;

    await _projectController.loadProjects(community.community_id);
    await _projectController.refreshAllProjectsStats(community.community_id);
  }

  @override
  Widget build(BuildContext context) {
    final community = _communityController.currentCommunity.value;

    if (community == null) {
      return const Scaffold(
        body: Center(child: Text('Communauté non sélectionnée')),
      );
    }

    // 🔁 S'assurer qu'on charge une fois automatiquement à l'ouverture
    if (!_hasLoadedOnce) {
      _hasLoadedOnce = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadProjects();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Projets - ${community.nom}'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadProjects),
          if (_canCreateProject(community))
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _projectController.clearCurrentProject();
                Get.toNamed(AppRoutes.createEditProject);
              },
            ),
        ],
      ),
      body: Obx(() {
        if (_projectController.isLoading.value &&
            _projectController.projects.isEmpty) {
          return const LoadingWidget(message: 'Chargement des projets...');
        }

        if (_projectController.error.value.isNotEmpty) {
          return EmptyStateWidget(
            title: 'Erreur',
            message: _projectController.error.value,
            icon: Icons.error_outline,
            onAction: _loadProjects,
            actionLabel: 'Réessayer',
          );
        }

        final projects = _projectController.activeProjects;

        if (projects.isEmpty) {
          final canCreate = _canCreateProject(community);
          return EmptyStateWidget(
            title: 'Aucun projet',
            message: canCreate
                ? 'Créez votre premier projet !'
                : 'Aucun projet disponible pour le moment.',
            icon: Icons.folder_open_outlined,
            onAction: canCreate
                ? () {
                    _projectController.clearCurrentProject();
                    Get.toNamed(AppRoutes.createEditProject);
                  }
                : null,
            actionLabel: canCreate ? 'Créer un projet' : null,
          );
        }

        final responsive = ResponsiveHelper(context);

        return ResponsiveContainer(
          padding: EdgeInsets.zero,
          child: RefreshIndicator(
            onRefresh: _loadProjects,
            child: responsive.isMobile
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: projects.length,
                    itemBuilder: (context, index) =>
                        _buildProjectCard(projects[index], community),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 285, // Fixed height for desktop/tablet cards
                    ),
                    itemCount: projects.length,
                    itemBuilder: (context, index) =>
                        _buildProjectCard(projects[index], community),
                  ),
          ),
        );
      }),
      floatingActionButton: _canCreateProject(community)
          ? FloatingActionButton.extended(
              onPressed: () {
                _projectController.clearCurrentProject();
                Get.toNamed(AppRoutes.createEditProject);
              },
              icon: const Icon(Icons.add),
              label: const Text('Nouveau projet'),
            )
          : null,
    );
  }

  Widget _buildProjectCard(ProjectModel project, CommunityModel community) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final progress = project.completion_percentage.clamp(0.0, 100.0).toDouble();
    final completedTasks = project.completed_tasks;
    final totalTasks = project.tasks_count;
    final remainingTasks = (totalTasks - completedTasks).clamp(0, totalTasks);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: theme.cardColor,
      elevation: isDark ? 0 : 2,
      shadowColor: Colors.black.withOpacity(isDark ? 0.22 : 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.onSurface.withOpacity(isDark ? 0.10 : 0.05),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _projectController.setCurrentProject(project);
          Get.toNamed(AppRoutes.kanbanBoard);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(isDark ? 0.18 : 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.folder_outlined,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.nom,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (project.description.isNotEmpty)
                          Text(
                            project.description,
                            style: AppTheme.bodyText2.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.72),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (_canCreateProject(community))
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _projectController.setCurrentProject(project);
                          Get.toNamed(AppRoutes.createEditProject);
                        } else if (value == 'archive') {
                          _confirmArchive(project, community);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Modifier'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'archive',
                          child: Row(
                            children: [
                              Icon(Icons.archive_outlined, size: 18, color: Colors.orange),
                              SizedBox(width: 8),
                              Text('Archiver', style: TextStyle(color: Colors.orange)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStat(
                    context,
                    Icons.task_outlined,
                    '${project.tasks_count}',
                    'Tâches',
                  ),
                  _buildStat(
                    context,
                    Icons.check_circle_outline,
                    '${progress.toStringAsFixed(0)}%',
                    'Terminé',
                  ),
                  _buildStat(
                    context,
                    Icons.calendar_today,
                    _formatDate(project.created_at),
                    'Créé',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progression toujours lisible, même à 0%
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(isDark ? 0.05 : 0.03),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colorScheme.onSurface.withOpacity(isDark ? 0.10 : 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progression',
                          style: AppTheme.bodyText2.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${progress.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _getProgressColor(progress),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: colorScheme.onSurface.withOpacity(
                          isDark ? 0.12 : 0.14,
                        ),
                        color: _getProgressColor(progress),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      totalTasks > 0
                          ? '$completedTasks/$totalTasks tâches terminées'
                          : 'Aucune tâche pour le moment',
                      style: AppTheme.bodyText2.copyWith(fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMiniTaskStat(
                            context: context,
                            icon: Icons.pending_actions_outlined,
                            label: 'À faire',
                            value: '$remainingTasks',
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMiniTaskStat(
                            context: context,
                            icon: Icons.check_circle_outline,
                            label: 'Achevées',
                            value: '$completedTasks',
                            color: Colors.green,
                          ),
                        ),
                      ],
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

  Widget _buildStat(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: colorScheme.onSurface.withOpacity(0.66),
            ),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        Text(
          label,
          style: AppTheme.bodyText2.copyWith(
            fontSize: 11,
            color: colorScheme.onSurface.withOpacity(0.66),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniTaskStat({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(isDark ? 0.36 : 0.28)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$label: $value',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canCreateProject(CommunityModel community) {
    return community.role == 'ADMIN' || community.role == 'RESPONSABLE';
  }

  Color _getProgressColor(double percentage) {
    if (percentage < 30) return Colors.red;
    if (percentage < 70) return Colors.orange;
    return Colors.green;
  }

  void _confirmArchive(ProjectModel project, CommunityModel community) {
    Get.dialog(
      AlertDialog(
        title: const Text('Archiver le projet'),
        content: Text('Voulez-vous vraiment archiver le projet "${project.nom}" ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await _projectController.archiveProject(
                communityId: community.community_id,
                projectId: project.id,
              );

              if (success) {
                Get.snackbar(
                  'Succès',
                  'Projet archivé',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  'Erreur',
                  'Impossible d\'archiver le projet',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            child: const Text('Archiver'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateTimeHelper.formatRelativeDateTime(date);
  }
}
