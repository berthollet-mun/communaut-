import 'package:community/app/routes/app_routes.dart';
import 'package:community/app/themes/app_theme.dart';
import 'package:community/controllers/community_controller.dart';
import 'package:community/controllers/project_controller.dart';
import 'package:community/core/utils/responsive_helper.dart';
import 'package:community/data/models/community_model.dart';
import 'package:community/views/shared/widgets/button.dart';
import 'package:community/views/shared/widgets/loading_widget.dart';
import 'package:community/views/shared/widgets/role_badge.dart';
import 'package:community/controllers/auth_controller.dart';
import 'package:community/controllers/task_controller.dart';
import 'package:community/core/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';


class CommunityDashboardPage extends StatefulWidget {
  const CommunityDashboardPage({super.key});

  @override
  State<CommunityDashboardPage> createState() => _CommunityDashboardPageState();
}

class _CommunityDashboardPageState extends State<CommunityDashboardPage> {
  final CommunityController _communityController = Get.find();
  final ProjectController _projectController = Get.find();
  final AuthController _authController = Get.find();
  final TaskController _taskController = Get.find();

  late CommunityModel _community;

  @override
  void initState() {
    super.initState();
    _community = _communityController.currentCommunity.value!;
    _loadData();
  }

  Future<void> _loadData() async {
    final comm = _communityController.currentCommunity.value;
    if (comm == null) return;

    // 1. Rafraîchir les infos de la communauté en tâche de fond (non-bloquant)
    _communityController.refreshCurrentCommunity();

    // 2. Vérifier si on a déjà les projets en cache mémoire pour cette communauté
    final hasCache = _projectController.loadedCommunityId == comm.community_id && 
                    _projectController.projects.isNotEmpty;

    if (!hasCache) {
      // Pas de cache ou changement de communauté : on attend le premier chargement des projets
      await _projectController.loadProjects(comm.community_id);
    } else {
      // On a le cache : on rafraîchit la liste en tâche de fond (silencieusement)
      _projectController.loadProjects(comm.community_id);
    }

    // 3. À ce stade, on a forcément une liste de projets (via cache ou via await)
    final projects = _projectController.activeProjects;

    if (projects.isNotEmpty) {
      // ✅ Choisir un projet cible (le courant ou le premier)
      final targetProject = _projectController.currentProject.value ?? projects.first;
      
      // ✅ Définir comme projet courant (synchronise l'UI)
      _projectController.setCurrentProject(targetProject);
      
      // ✅ Lancer le chargement des tâches et rafraîchir TOUS les projets pour les stats globales
      Future.wait([
        _projectController.refreshAllProjectsStats(comm.community_id),
        _taskController.loadKanbanTasks(
          communityId: comm.community_id,
          projectId: targetProject.id,
        ),
      ]);
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return Scaffold(
      appBar: _buildAppBar(responsive),
      body: Obx(() {
        final community = _communityController.currentCommunity.value;
        if (community == null) {
          return Center(
            child: Text(
              'Communauté non trouvée',
              style: TextStyle(fontSize: responsive.fontSize(16)),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: _buildBody(community, responsive),
        );
      }),
      floatingActionButton: _buildFAB(responsive),
    );
  }

  /// AppBar responsive
  PreferredSizeWidget _buildAppBar(ResponsiveHelper responsive) {
    return AppBar(
      title: Obx(() {
        final community = _communityController.currentCommunity.value;
        return Text(
          community?.nom ?? 'Tableau de bord',
          style: TextStyle(fontSize: responsive.fontSize(18)),
        );
      }),
      toolbarHeight: responsive.value<double>(
        mobile: 56,
        tablet: 60,
        desktop: 64,
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, size: responsive.iconSize(24)),
          onPressed: _refreshData,
          tooltip: 'Actualiser',
        ),
        IconButton(
          icon: Icon(Icons.person_outline, size: responsive.iconSize(24)),
          onPressed: () => Get.toNamed(AppRoutes.profile),
          tooltip: 'Mon Profil',
        ),
        IconButton(
          icon: Icon(Icons.more_vert, size: responsive.iconSize(24)),
          onPressed: _showOptions,
          tooltip: 'Plus d\'options',
        ),
      ],
    );
  }

  /// Corps de la page - Layout adaptatif
  Widget _buildBody(CommunityModel community, ResponsiveHelper responsive) {
    // Sur desktop, utiliser un layout en 2 colonnes
    if (responsive.isDesktop) {
      return SingleChildScrollView(
        padding: EdgeInsets.all(responsive.contentPadding),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: responsive.value<double>(
                mobile: double.infinity,
                tablet: 900,
                desktop: 1200,
                largeDesktop: 1400,
              ),
            ),
            child: Column(
              children: [
                // Header pleine largeur
                _buildCommunityHeader(community, responsive),
                SizedBox(height: responsive.spacing(24)),

                // 2 colonnes : Stats + Quick Actions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildStatisticsSection(community, responsive),
                    ),
                    SizedBox(width: responsive.spacing(24)),
                    Expanded(
                      flex: 1,
                      child: _buildQuickActions(community, responsive),
                    ),
                  ],
                ),
                SizedBox(height: responsive.spacing(24)),

                // Projets récents pleine largeur
                _buildRecentProjects(community, responsive),
              ],
            ),
          ),
        ),
      );
    }

    // Sur mobile/tablette, layout en colonne
    return ListView(
      padding: EdgeInsets.all(responsive.contentPadding),
      children: [
        _buildCommunityHeader(community, responsive),
        SizedBox(height: responsive.spacing(24)),
        _buildStatisticsSection(community, responsive),
        SizedBox(height: responsive.spacing(24)),
        _buildQuickActions(community, responsive),
        SizedBox(height: responsive.spacing(24)),
        _buildRecentProjects(community, responsive),
        SizedBox(height: responsive.spacing(80)), // Espace pour le FAB
      ],
    );
  }

  /// FAB responsive
  Widget _buildFAB(ResponsiveHelper responsive) {
    // Sur mobile, afficher seulement l'icône si l'écran est petit
    if (responsive.isMobile && responsive.screenWidth < 360) {
      return FloatingActionButton(
        onPressed: () {
          _projectController.clearCurrentProject();
          Get.toNamed(AppRoutes.createEditProject);
        },
        heroTag: 'new_project',
        child: Icon(Icons.add, size: responsive.iconSize(24)),
      );
    }

    return FloatingActionButton.extended(
      onPressed: () {
        _projectController.clearCurrentProject();
        Get.toNamed(AppRoutes.createEditProject);
      },
      icon: Icon(Icons.add, size: responsive.iconSize(20)),
      label: Text(
        'Nouveau projet',
        style: TextStyle(fontSize: responsive.fontSize(14)),
      ),
      heroTag: 'new_project',
    );
  }

  /// Header de la communauté
  Widget _buildCommunityHeader(
    CommunityModel community,
    ResponsiveHelper responsive,
  ) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(20)),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec avatar et infos
          _buildHeaderTop(community, responsive),
          SizedBox(height: responsive.spacing(16)),
          const Divider(),
          SizedBox(height: responsive.spacing(16)),
          // Code d'invitation
          _buildInviteCodeSection(community, responsive),
        ],
      ),
    );
  }

  Widget _buildHeaderTop(
    CommunityModel community,
    ResponsiveHelper responsive,
  ) {
    final avatarSize = responsive.value<double>(
      mobile: 50,
      tablet: 60,
      desktop: 70,
    );

    return Row(
      children: [
        // Avatar
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            color: _getCommunityColor(community.community_id),
            borderRadius: BorderRadius.circular(responsive.spacing(12)),
          ),
          child: Center(
            child: Text(
              community.nom.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: responsive.fontSize(avatarSize * 0.45),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: responsive.spacing(16)),

        // Infos communauté
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      community.nom,
                      style: TextStyle(
                        fontSize: responsive.fontSize(20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  RoleBadge(role: community.role),
                ],
              ),
              if (community.description.isNotEmpty) ...[
                SizedBox(height: responsive.spacing(4)),
                Text(
                  Helpers.unescapeHtml(community.description),
                  style: AppTheme.bodyText2.copyWith(
                    fontSize: responsive.fontSize(14),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInviteCodeSection(
    CommunityModel community,
    ResponsiveHelper responsive,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Code d\'invitation',
              style: AppTheme.bodyText2.copyWith(
                fontSize: responsive.fontSize(12),
              ),
            ),
            SizedBox(height: responsive.spacing(4)),
            SelectableText(
              community.invite_code.toString(),
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: responsive.fontSize(18),
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () => _copyInviteCode(community),
          icon: Icon(Icons.content_copy, size: responsive.iconSize(20)),
          tooltip: 'Copier le code',
        ),
      ],
    );
  }

  /// Section statistiques
  Widget _buildStatisticsSection(
    CommunityModel community,
    ResponsiveHelper responsive,
  ) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(20)),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiques',
            style: AppTheme.headline2.copyWith(
              fontSize: responsive.fontSize(20),
            ),
          ),
          SizedBox(height: responsive.spacing(16)),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: responsive.value<int>(
              mobile: 2,
              tablet: 2,
              desktop: 2,
              largeDesktop: 4,
            ),
            crossAxisSpacing: responsive.spacing(12),
            mainAxisSpacing: responsive.spacing(12),
            childAspectRatio: responsive.value<double>(
              mobile: 1.2,
              tablet: 1.4,
              desktop: 1.5,
            ),
            children: [
              _buildStatCard(
                responsive,
                icon: Icons.people_outline,
                value: community.members_count.toString(),
                label: 'Membres',
                color: Colors.blue,
              ),
              _buildStatCard(
                responsive,
                icon: Icons.folder_outlined,
                value: community.projects_count.toString(),
                label: 'Projets',
                color: Colors.green,
              ),
              // ✅ Tâches (Priorité au CommunityModel, sinon aggregation)
              Obx(() {
                final comm = _communityController.currentCommunity.value;
                int totalTasks = comm?.tasks_count ?? 0;
                
                // Si le backend ne donne pas les stats au niveau communauté, on utilise l'aggrégation des projets
                if (totalTasks == 0) {
                  totalTasks = _projectController.communityTotalTasksCount;
                }

                return _buildStatCard(
                  responsive,
                  icon: Icons.task_outlined,
                  value: '$totalTasks',
                  label: 'Tâches',
                  color: Colors.orange,
                );
              }),
              // ✅ Achevées (Priorité au CommunityModel, sinon aggregation)
              Obx(() {
                final comm = _communityController.currentCommunity.value;
                int completed = comm?.completed_tasks ?? 0;
                int total = comm?.tasks_count ?? 0;
                double percent = 0;

                if (total > 0) {
                  percent = (completed / total) * 100;
                } else {
                  percent = _projectController.communityCompletionPercentage;
                }

                return _buildStatCard(
                  responsive,
                  icon: Icons.check_circle_outline,
                  value: '${percent.toStringAsFixed(0)}%',
                  label: 'Achevées',
                  color: Colors.purple,
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    ResponsiveHelper responsive, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(12)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: responsive.iconSize(28), color: color),
          SizedBox(height: responsive.spacing(4)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: responsive.fontSize(20),
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          SizedBox(height: responsive.spacing(2)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: AppTheme.bodyText2.copyWith(
                fontSize: responsive.fontSize(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section actions rapides
  Widget _buildQuickActions(
    CommunityModel community,
    ResponsiveHelper responsive,
  ) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(20)),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Navigation rapide',
            style: AppTheme.headline2.copyWith(
              fontSize: responsive.fontSize(20),
            ),
          ),
          SizedBox(height: responsive.spacing(16)),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: responsive.value<int>(
              mobile: 3,
              tablet: 3,
              desktop: 3,
              largeDesktop: 6,
            ),
            crossAxisSpacing: responsive.spacing(12),
            mainAxisSpacing: responsive.spacing(12),
            childAspectRatio: responsive.value<double>(
              mobile: 0.9,
              tablet: 1.0,
              desktop: 1.1,
            ),
            children: [
              _buildQuickActionButton(
                responsive,
                icon: Icons.folder_open,
                label: 'Projets',
                onTap: () => Get.toNamed(AppRoutes.projectsList),
                color: Colors.blue,
              ),
              _buildQuickActionButton(
                responsive,
                icon: Icons.people,
                label: 'Membres',
                onTap: () => Get.toNamed(AppRoutes.membersList),
                color: Colors.green,
                enabled: true,
              ),
              _buildQuickActionButton(
                responsive,
                icon: Icons.history,
                label: 'Historique',
                onTap: () => Get.toNamed(AppRoutes.activityLog),
                color: Colors.orange,
              ),
              _buildQuickActionButton(
                responsive,
                icon: Icons.person_add,
                label: 'Inviter',
                onTap: () => Get.toNamed(AppRoutes.inviteMember),
                color: Colors.purple,
                enabled: community.role == 'ADMIN',
              ),
              _buildQuickActionButton(
                responsive,
                icon: Icons.settings,
                label: 'Paramètres',
                onTap: () => _showSettings(community),
                color: Colors.teal,
                enabled: community.role == 'ADMIN',
              ),
              _buildQuickActionButton(
                responsive,
                icon: Icons.help_outline,
                label: 'Aide',
                onTap: () => _showHelp(),
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    ResponsiveHelper responsive, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    bool enabled = true,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(responsive.spacing(12)),
      color: enabled ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: EdgeInsets.all(responsive.spacing(8)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: responsive.iconSize(28),
                color: enabled ? color : Colors.grey,
              ),
              SizedBox(height: responsive.spacing(6)),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: responsive.fontSize(11),
                    fontWeight: FontWeight.w600,
                    color: enabled ? color : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Section projets récents
  Widget _buildRecentProjects(
    CommunityModel community,
    ResponsiveHelper responsive,
  ) {
    return Obx(() {
      final projects = _projectController.activeProjects.take(3).toList();
      final isLoading = _projectController.isLoading.value;

      return Container(
        padding: EdgeInsets.all(responsive.spacing(20)),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(responsive.spacing(16)),
          boxShadow: [AppTheme.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Projets récents',
                    style: AppTheme.headline2.copyWith(
                      fontSize: responsive.fontSize(20),
                    ),
                  ),
                ),
                if (projects.isNotEmpty)
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.projectsList),
                    child: Text(
                      'Voir tout',
                      style: TextStyle(fontSize: responsive.fontSize(14)),
                    ),
                  ),
              ],
            ),
            SizedBox(height: responsive.spacing(16)),
            if (isLoading && projects.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (projects.isEmpty)
              _buildEmptyProjects(responsive)
            else
              _buildProjectsList(projects, responsive),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyProjects(ResponsiveHelper responsive) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: responsive.spacing(40)),
      child: Column(
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: responsive.iconSize(60),
            color: Colors.grey[400],
          ),
          SizedBox(height: responsive.spacing(16)),
          Text(
            'Aucun projet pour le moment',
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              color: Colors.grey,
            ),
          ),
          SizedBox(height: responsive.spacing(16)),
          SecondaryButton(
            text: 'Créer un premier projet',
            onPressed: () {
              _projectController.clearCurrentProject();
              Get.toNamed(AppRoutes.createEditProject);
            },
            fullWidth: false,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList(
    List<dynamic> projects,
    ResponsiveHelper responsive,
  ) {
    // Sur desktop, afficher en grille
    if (responsive.isDesktop && projects.length > 1) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: responsive.value<int>(
            mobile: 1,
            tablet: 2,
            desktop: 3,
          ),
          crossAxisSpacing: responsive.spacing(12),
          mainAxisSpacing: responsive.spacing(12),
          childAspectRatio: 2.5,
        ),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          return _buildProjectItem(projects[index], responsive);
        },
      );
    }

    // Sur mobile/tablette, liste simple
    return Column(
      children: projects.map((project) {
        return Padding(
          padding: EdgeInsets.only(bottom: responsive.spacing(12)),
          child: _buildProjectItem(project, responsive),
        );
      }).toList(),
    );
  }

  Widget _buildProjectItem(dynamic project, ResponsiveHelper responsive) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: responsive.spacing(16),
          vertical: responsive.spacing(4),
        ),
        leading: Icon(
          Icons.folder_outlined,
          color: Colors.blue,
          size: responsive.iconSize(24),
        ),
        title: Text(
          project.nom,
          style: TextStyle(fontSize: responsive.fontSize(15)),
        ),
        subtitle: Text(
          project.description.isNotEmpty
              ? project.description
              : 'Aucune description',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: responsive.fontSize(13)),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: responsive.iconSize(16)),
        onTap: () {
          _projectController.setCurrentProject(project);
          Get.toNamed(AppRoutes.kanbanBoard);
        },
      ),
    );
  }

  /// Bottom sheet options
  void _showOptions() {
    final community = _communityController.currentCommunity.value;
    if (community == null) return;

    final responsive = ResponsiveHelper(context);

    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(responsive.spacing(20)),
            topRight: Radius.circular(responsive.spacing(20)),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: responsive.spacing(8)),
              // Indicateur de drag
              Container(
                width: responsive.spacing(40),
                height: responsive.spacing(4),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(responsive.spacing(2)),
                ),
              ),
              SizedBox(height: responsive.spacing(8)),
              _buildOptionTile(
                responsive,
                icon: Icons.refresh,
                title: 'Actualiser',
                onTap: () {
                  Get.back();
                  _refreshData();
                },
              ),
              _buildOptionTile(
                responsive,
                icon: Icons.swap_horiz,
                title: 'Changer de communauté',
                onTap: () {
                  Get.back();
                  Get.offAllNamed(AppRoutes.communitySelect);
                },
              ),
              _buildOptionTile(
                responsive,
                icon: Icons.person_outline,
                title: 'Mon Profil',
                onTap: () {
                  Get.back();
                  Get.toNamed(AppRoutes.profile);
                },
              ),
              _buildOptionTile(
                responsive,
                icon: Icons.info_outline,
                title: 'Détails de la communauté',
                onTap: () {
                  Get.back();
                  _showCommunityDetails(community);
                },
              ),
              if (community.role == 'ADMIN') ...[
                _buildOptionTile(
                  responsive,
                  icon: Icons.edit,
                  title: 'Modifier la communauté',
                  onTap: () {
                    Get.back();
                    _editCommunity(community);
                  },
                ),
                _buildOptionTile(
                  responsive,
                  icon: Icons.delete_outline,
                  title: 'Supprimer la communauté',
                  color: Colors.red,
                  onTap: () {
                    Get.back();
                    _confirmDeleteCommunity(community);
                  },
                ),
              ],
              Divider(height: responsive.spacing(1)),
              _buildOptionTile(
                responsive,
                icon: Icons.exit_to_app,
                title: 'Quitter cette communauté',
                onTap: () {
                  Get.back();
                  _confirmLeaveCommunity(community);
                },
              ),
              SizedBox(height: responsive.spacing(16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    ResponsiveHelper responsive, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, size: responsive.iconSize(24), color: color),
      title: Text(
        title,
        style: TextStyle(fontSize: responsive.fontSize(15), color: color),
      ),
      onTap: onTap,
    );
  }

  /// Dialog détails communauté
  void _showCommunityDetails(CommunityModel community) {
    final responsive = ResponsiveHelper(context);

    Get.dialog(
      AlertDialog(
        title: Text(
          'Détails de la communauté',
          style: TextStyle(fontSize: responsive.fontSize(18)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(responsive, 'Nom', community.nom),
              _buildDetailRow(
                responsive,
                'Description',
                community.description.isNotEmpty
                    ? community.description
                    : 'Aucune',
              ),
              _buildDetailRow(
                responsive,
                'Code d\'invitation',
                community.invite_code.toString(),
              ),
              _buildDetailRow(responsive, 'Votre rôle', community.role),
              _buildDetailRow(
                responsive,
                'Membres',
                community.members_count.toString(),
              ),
              _buildDetailRow(
                responsive,
                'Projets',
                community.projects_count.toString(),
              ),
              _buildDetailRow(
                responsive,
                'Créée le',
                community.created_at != null
                    ? _formatDate(community.created_at!)
                    : 'N/A',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Fermer',
              style: TextStyle(fontSize: responsive.fontSize(14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    ResponsiveHelper responsive,
    String label,
    String value,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: responsive.spacing(8)),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: responsive.fontSize(14),
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  /// Dialog édition communauté
  void _editCommunity(CommunityModel community) {
    final responsive = ResponsiveHelper(context);
    final nameController = TextEditingController(text: community.nom);
    final descriptionController = TextEditingController(
      text: community.description,
    );

    Get.dialog(
      AlertDialog(
        title: Text(
          'Modifier la communauté',
          style: TextStyle(fontSize: responsive.fontSize(18)),
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: responsive.value<double>(
              mobile: double.infinity,
              tablet: 400,
              desktop: 450,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom de la communauté',
                    border: const OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(responsive.spacing(12)),
                  ),
                  style: TextStyle(fontSize: responsive.fontSize(14)),
                ),
                SizedBox(height: responsive.spacing(16)),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: const OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(responsive.spacing(12)),
                  ),
                  style: TextStyle(fontSize: responsive.fontSize(14)),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Annuler',
              style: TextStyle(fontSize: responsive.fontSize(14)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );

              final success = await _communityController.updateCommunity(
                communityId: community.community_id,
                nom: nameController.text.trim(),
                description: descriptionController.text.trim(),
              );

              Get.back();
              Get.back();

              if (success) {
                await _refreshData();
                Get.snackbar(
                  'Succès',
                  'Communauté modifiée avec succès',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  'Erreur',
                  'Impossible de modifier la communauté',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: Text(
              'Enregistrer',
              style: TextStyle(fontSize: responsive.fontSize(14)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCommunity(CommunityModel community) {
    final responsive = ResponsiveHelper(context);

    Get.dialog(
      AlertDialog(
        title: Text(
          'Fonctionnalité en développement',
          style: TextStyle(fontSize: responsive.fontSize(18)),
        ),
        content: Text(
          'Nous attendons les informations du développeur backend pour activer cette fonctionnalité.',
          style: TextStyle(fontSize: responsive.fontSize(14)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'OK',
              style: TextStyle(fontSize: responsive.fontSize(14)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCommunity(CommunityModel community) async {
    print('=== DELETE COMMUNITY ===');
    print('Community ID: ${community.community_id}');

    final success = await _communityController.deleteCommunity(
      community.community_id,
    );

    print('Delete success: $success');
    print('Error: ${_communityController.error.value}');
    print('========================');

    if (success) {
      Get.offAllNamed(AppRoutes.communitySelect);
      Get.snackbar(
        'Succès',
        'La communauté "${community.nom}" a été supprimée',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Erreur',
        _communityController.error.value.isNotEmpty
            ? _communityController.error.value
            : 'Impossible de supprimer la communauté',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _confirmLeaveCommunity(CommunityModel community) {
    final responsive = ResponsiveHelper(context);

    Get.dialog(
      AlertDialog(
        title: Text(
          'Fonctionnalité en développement',
          style: TextStyle(fontSize: responsive.fontSize(18)),
        ),
        content: Text(
          'Nous attendons les informations du développeur backend pour activer cette fonctionnalité.',
          style: TextStyle(fontSize: responsive.fontSize(14)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'OK',
              style: TextStyle(fontSize: responsive.fontSize(14)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _leaveCommunity(CommunityModel community) async {
    // Récupérer l'ID de l'utilisateur connecté
    final userId = _authController.user.value?.user_id;

    if (userId == null) {
      Get.snackbar(
        'Erreur',
        'Utilisateur non connecté',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final success = await _communityController.leaveCommunity(
      communityId: community.community_id,
      userId: userId,
    );

    if (success) {
      Get.offAllNamed(AppRoutes.communitySelect);

      Get.snackbar(
        'Succès',
        'Vous avez quitté la communauté "${community.nom}"',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Erreur',
        'Impossible de quitter la communauté',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _copyInviteCode(CommunityModel community) async {
    final code = community.invite_code.toString();

    // ✅ Copier dans le presse-papiers
    await Clipboard.setData(ClipboardData(text: code));

    // ✅ Feedback à l’utilisateur
    Get.snackbar(
      'Code copié',
      'Le code d\'invitation "$code" a été copié dans le presse-papier.',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _showSettings(CommunityModel community) {
    Get.snackbar(
      'Paramètres',
      'Nous attendons les informations du développeur backend pour activer cette fonctionnalité.',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  //   void _showSettings(CommunityModel community) {
  //   Get.toNamed(AppRoutes.communitySettings);
  // }

  void _showHelp() {
    final responsive = ResponsiveHelper(context);

    Get.defaultDialog(
      title: 'Aide - Tableau de bord',
      titleStyle: TextStyle(fontSize: responsive.fontSize(18)),
      content: Padding(
        padding: EdgeInsets.all(responsive.spacing(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Le tableau de bord vous permet de :',
              style: TextStyle(fontSize: responsive.fontSize(14)),
            ),
            SizedBox(height: responsive.spacing(8)),
            ...[
              '• Voir les statistiques de votre communauté',
              '• Accéder rapidement aux différentes sections',
              '• Voir les projets récents',
              '• Gérer les paramètres (Admin uniquement)',
            ].map(
              (text) => Padding(
                padding: EdgeInsets.only(bottom: responsive.spacing(4)),
                child: Text(
                  text,
                  style: TextStyle(fontSize: responsive.fontSize(13)),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'Fermer',
            style: TextStyle(fontSize: responsive.fontSize(14)),
          ),
        ),
      ],
    );
  }

  Color _getCommunityColor(int id) {
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
    return colors[id % colors.length];
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
