import 'package:community/app/routes/app_routes.dart';
import 'package:community/app/themes/app_theme.dart';
import 'package:community/controllers/auth_controller.dart';
import 'package:community/controllers/community_controller.dart';
import 'package:community/core/utils/responsive_helper.dart';
import 'package:community/core/utils/widgets/responsive_builder.dart';
import 'package:community/data/models/community_model.dart';
import 'package:community/views/shared/widgets/button.dart';
import 'package:community/views/shared/widgets/empty_state.dart';
import 'package:community/views/shared/widgets/loading_widget.dart';
import 'package:community/views/shared/widgets/role_badge.dart';
import 'package:community/core/utils/helpers.dart';
import 'package:community/controllers/project_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CommunitySelectPage extends StatefulWidget {
  const CommunitySelectPage({super.key});

  @override
  State<CommunitySelectPage> createState() => _CommunitySelectPageState();
}

class _CommunitySelectPageState extends State<CommunitySelectPage> {
  final CommunityController _communityController = Get.find();
  final AuthController _authController = Get.find();

  bool _isOpeningCommunity = false;
  int? _openingCommunityId;

  @override
  void initState() {
    super.initState();
    _loadCommunities();
  }

  Future<void> _loadCommunities() async {
    await _communityController.loadCommunities();
  }

  Future<void> _refreshCommunities() async {
    if (_isOpeningCommunity) return;
    await _loadCommunities();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final count = _communityController.communities.length;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Mes Communautés',
                style: TextStyle(fontSize: responsive.fontSize(18)),
              ),
              SizedBox(width: responsive.spacing(10)),
              _CountChip(count: count, responsive: responsive),
            ],
          );
        }),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: responsive.iconSize(24)),
            onPressed: _isOpeningCommunity ? null : _refreshCommunities,
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: Icon(Icons.person, size: responsive.iconSize(24)),
            onPressed: _isOpeningCommunity
                ? null
                : () => Get.toNamed(AppRoutes.profile),
            tooltip: 'Profil',
          ),
        ],
      ),
      body: Stack(
        children: [
          Obx(() {
            if (_communityController.isLoading.value) {
              return const LoadingWidget(
                message: 'Chargement de vos communautés...',
              );
            }

            if (_communityController.error.value.isNotEmpty) {
              return EmptyStateWidget(
                title: 'Erreur de chargement',
                message: _communityController.error.value,
                icon: Icons.error_outline,
                onAction: _isOpeningCommunity ? null : _refreshCommunities,
                actionLabel: 'Réessayer',
              );
            }

            if (_communityController.communities.isEmpty) {
              return EmptyStateWidget(
                title: 'Aucune communauté',
                message:
                    'Vous n\'êtes pas encore membre d\'une communauté. Créez-en une ou rejoignez-en une !',
                icon: Icons.groups_outlined,
                onAction: _isOpeningCommunity
                    ? null
                    : () => Get.toNamed(AppRoutes.createCommunity),
                actionLabel: 'Créer une communauté',
              );
            }

            return RefreshIndicator(
              onRefresh: _refreshCommunities,
              child: _buildCommunityList(responsive),
            );
          }),

          // ✅ OVERLAY GLOBAL pendant l'ouverture
          if (_isOpeningCommunity)
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: true,
                child: Container(
                  color: Colors.black.withOpacity(0.20),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(responsive),
      bottomNavigationBar: null,
    );
  }

  Widget _buildCommunityList(ResponsiveHelper responsive) {
    if (responsive.isDesktop ||
        (responsive.isTablet && responsive.screenWidth > 700)) {
      return ResponsiveContainer(
        maxWidth: 1200,
        padding: EdgeInsets.all(responsive.contentPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(responsive),
            SizedBox(height: responsive.spacing(24)),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: responsive.value<int>(
                    mobile: 1,
                    tablet: 2,
                    desktop: 3,
                    largeDesktop: 4,
                  ),
                  crossAxisSpacing: responsive.spacing(16),
                  mainAxisSpacing: responsive.spacing(16),
                  childAspectRatio: responsive.value<double>(
                    mobile: 1.8,
                    tablet: 1.35,
                    desktop: 1.15,
                    largeDesktop: 1.2,
                  ),
                ),
                itemCount: _communityController.communities.length,
                itemBuilder: (context, index) {
                  return _buildCommunityCard(
                    _communityController.communities[index],
                    responsive,
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(
        responsive.spacing(16),
        responsive.spacing(16),
        responsive.spacing(16),
        responsive.isMobileSmall ? 180 : 140,
      ),
      children: [
        _buildHeader(responsive),
        SizedBox(height: responsive.spacing(16)),
        ..._communityController.communities.map((community) {
          return _buildCommunityCard(community, responsive);
        }),
      ],
    );
  }

  Widget _buildHeader(ResponsiveHelper responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bonjour, ${_authController.user.value?.prenom ?? 'Utilisateur'} !',
          style: AppTheme.headline2.copyWith(fontSize: responsive.fontSize(22)),
        ),
        SizedBox(height: responsive.spacing(4)),
        Text(
          'Sélectionnez une communauté pour commencer',
          style: AppTheme.bodyText2.copyWith(fontSize: responsive.fontSize(14)),
        ),
      ],
    );
  }

  Widget _buildCommunityCard(
    CommunityModel community,
    ResponsiveHelper responsive,
  ) {
    final members = _safeInt(getter: () => community.members_count);
    final projects = _safeInt(getter: () => community.projects_count);
    final createdAt = _safeDate(getter: () => community.created_at);

    // ✅ SAFE display name + initial (évite RangeError)
    final displayName = community.nom.trim();
    final safeName = displayName.isNotEmpty ? displayName : 'Communauté';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    final openingThis =
        _isOpeningCommunity && _openingCommunityId == community.community_id;

    return Card(
      margin: EdgeInsets.only(bottom: responsive.spacing(16)),
      elevation: responsive.value<double>(mobile: 2, tablet: 3, desktop: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
        onTap: () {
          if (_isOpeningCommunity) return;
          _selectCommunity(community);
        },
        child: Padding(
          padding: EdgeInsets.all(responsive.spacing(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: responsive.value<double>(
                      mobile: 45,
                      tablet: 50,
                      desktop: 55,
                    ),
                    height: responsive.value<double>(
                      mobile: 45,
                      tablet: 50,
                      desktop: 55,
                    ),
                    decoration: BoxDecoration(
                      color: _getCommunityColor(community.community_id),
                      borderRadius: BorderRadius.circular(
                        responsive.spacing(10),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: TextStyle(
                          fontSize: responsive.fontSize(20),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: responsive.spacing(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                safeName,
                                style: TextStyle(
                                  fontSize: responsive.fontSize(16),
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: responsive.isMobile ? 1 : 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            RoleBadge(role: community.role),
                          ],
                        ),
                        SizedBox(height: responsive.spacing(4)),
                        if (community.description.trim().isNotEmpty)
                          Text(
                            Helpers.unescapeHtml(community.description),
                            style: AppTheme.bodyText2.copyWith(
                              fontSize: responsive.fontSize(12),
                            ),
                            maxLines: responsive.isMobile ? 2 : 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: responsive.spacing(12)),

              // Stats
              Padding(
                padding: EdgeInsets.only(top: responsive.spacing(6)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: _StatMini(
                        icon: Icons.groups_outlined,
                        value: members == null ? '-' : '$members',
                        label: 'Membres',
                        responsive: responsive,
                      ),
                    ),
                    Expanded(
                      child: _StatMini(
                        icon: Icons.folder_outlined,
                        value: projects == null ? '-' : '$projects',
                        label: 'Projets',
                        responsive: responsive,
                      ),
                    ),
                    Expanded(
                      child: _StatMini(
                        icon: Icons.calendar_month_outlined,
                        value: createdAt == null ? '-' : _formatDate(createdAt),
                        label: 'Créée',
                        responsive: responsive,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: responsive.spacing(14)),

              // ✅ Bouton Ouvrir : on désactive sans null
              SizedBox(
                height: responsive.value<double>(
                  mobile: 40,
                  tablet: 44,
                  desktop: 48,
                ),
                child: IgnorePointer(
                  ignoring: _isOpeningCommunity,
                  child: Opacity(
                    opacity: _isOpeningCommunity ? 0.6 : 1.0,
                    child: PrimaryButton(
                      text: openingThis ? 'Ouverture...' : 'Ouvrir',
                      onPressed: () {
                        if (_isOpeningCommunity) return;
                        _selectCommunity(community);
                      },
                      fullWidth: true,
                      icon: openingThis
                          ? Icons.hourglass_top
                          : Icons.arrow_forward,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons(ResponsiveHelper responsive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          onPressed: _isOpeningCommunity
              ? null
              : () => Get.toNamed(AppRoutes.joinCommunity),
          icon: Icon(Icons.key, size: responsive.iconSize(20)),
          label: Text(
            'Rejoindre',
            style: TextStyle(fontSize: responsive.fontSize(13)),
          ),
          heroTag: 'join_community',
        ),
        SizedBox(height: responsive.spacing(12)),
        FloatingActionButton.extended(
          onPressed: _isOpeningCommunity
              ? null
              : () => Get.toNamed(AppRoutes.createCommunity),
          icon: Icon(Icons.add, size: responsive.iconSize(20)),
          label: Text(
            'Créer',
            style: TextStyle(fontSize: responsive.fontSize(13)),
          ),
          heroTag: 'create_community',
        ),
        SizedBox(height: responsive.spacing(12)),

        // ✅ AIDE centré (plus de Support)
        FloatingActionButton(
          mini: true,
          onPressed: _isOpeningCommunity ? null : _showHelpCentered,
          heroTag: 'help',
          tooltip: 'Aide',
          child: Icon(Icons.help_outline, size: responsive.iconSize(20)),
        ),
      ],
    );
  }

  // ✅ Dialog centré (au milieu) : meilleur design, pas d’animation depuis le bas
  void _showHelpCentered() {
    Get.dialog(
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              decoration: BoxDecoration(
                color: Get.theme.cardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.help_outline),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Aide',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close),
                          tooltip: 'Fermer',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "• Appuie sur **Créer** pour créer une nouvelle communauté.\n"
                      "• Appuie sur **Rejoindre** pour entrer avec un code d'invitation.\n"
                      "• Appuie sur **Ouvrir** pour entrer dans une communauté.\n"
                      "• Utilise **Actualiser** pour recharger la liste.\n"
                      "• Va sur **Profil** pour voir tes statistiques.",
                      style: TextStyle(color: Colors.grey[700], height: 1.35),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        child: const Text('Fermer'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Future<void> _selectCommunity(CommunityModel community) async {
    if (_isOpeningCommunity) return;

    // ✅ safe name pour snackbar
    final displayName = community.nom.trim();
    final safeName = displayName.isNotEmpty ? displayName : 'Communauté';

    try {
      HapticFeedback.lightImpact();

      setState(() {
        _isOpeningCommunity = true;
        _openingCommunityId = community.community_id;
      });

      _communityController.setCurrentCommunity(community);
      
      // ✅ PRE-FETCH: Lancer le chargement des projets immédiatement (non-bloquant)
      Get.find<ProjectController>().loadProjects(community.community_id);
      
      // ✅ Refresh détails communauté en arrière-plan
      _communityController.refreshCurrentCommunity();

      Get.toNamed(AppRoutes.communityDashboard);

      Get.snackbar(
        'Communauté sélectionnée',
        'Bienvenue dans $safeName',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (_) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'accéder à la communauté',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isOpeningCommunity = false;
        _openingCommunityId = null;
      });
    }
  }

  int? _safeInt({required int? Function() getter}) {
    try {
      return getter();
    } catch (_) {
      return null;
    }
  }

  DateTime? _safeDate({required DateTime? Function() getter}) {
    try {
      return getter();
    } catch (_) {
      return null;
    }
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
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return "Aujourd'hui";
    if (difference.inDays == 1) return 'Hier';
    if (difference.inDays < 7) return 'Il y a ${difference.inDays} jours';
    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Il y a $weeks semaine${weeks > 1 ? 's' : ''}';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _CountChip extends StatelessWidget {
  final int count;
  final ResponsiveHelper responsive;

  const _CountChip({required this.count, required this.responsive});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.spacing(8),
        vertical: responsive.spacing(4),
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: responsive.fontSize(12),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final ResponsiveHelper responsive;

  const _StatMini({
    required this.icon,
    required this.value,
    required this.label,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).iconTheme.color ?? Colors.grey;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: responsive.iconSize(18),
          color: color.withOpacity(0.9),
        ),
        SizedBox(height: responsive.spacing(6)),
        Text(
          value,
          style: TextStyle(
            fontSize: responsive.fontSize(14),
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: responsive.spacing(2)),
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.fontSize(11),
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withOpacity(0.75),
          ),
        ),
      ],
    );
  }
}
