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
          return EmptyStateWidget(
            title: 'Aucun projet',
            message: 'Créez votre premier projet !',
            icon: Icons.folder_open_outlined,
            onAction: () {
              _projectController.clearCurrentProject();
              Get.toNamed(AppRoutes.createEditProject);
            },
            actionLabel: 'Créer un projet',
          );
        }

        final responsive = ResponsiveHelper(context);

        return ResponsiveContainer(
          padding: EdgeInsets.zero,
          child: RefreshIndicator(
            onRefresh: _loadProjects,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: responsive.isMobile ? 1 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 200, // Fixed height for cards
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.folder_outlined,
                      color: Colors.blue,
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
                            style: AppTheme.bodyText2,
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
                    Icons.task_outlined,
                    '${project.tasks_count}',
                    'Tâches',
                  ),
                  _buildStat(
                    Icons.check_circle_outline,
                    '${project.completion_percentage.toStringAsFixed(0)}%',
                    'Terminé',
                  ),
                  _buildStat(
                    Icons.calendar_today,
                    _formatDate(project.created_at),
                    'Créé',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress bar
              LinearProgressIndicator(
                value: project.completion_percentage / 100,
                backgroundColor: Colors.grey[200],
                color: _getProgressColor(project.completion_percentage),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        Text(label, style: AppTheme.bodyText2.copyWith(fontSize: 11)),
      ],
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
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return "Aujourd'hui";
    if (diff == 1) return 'Hier';
    if (diff < 7) return 'Il y a $diff jours';
    return '${date.day}/${date.month}';
  }
}
