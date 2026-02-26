import 'package:community/app/routes/app_routes.dart';
import 'package:community/app/themes/app_theme.dart';
import 'package:community/controllers/auth_controller.dart';
import 'package:community/controllers/community_controller.dart';
import 'package:community/controllers/notification_controller.dart';
import 'package:community/controllers/theme_controller.dart';
import 'package:community/core/utils/responsive_helper.dart';
import 'package:community/core/utils/widgets/responsive_builder.dart';
import 'package:community/data/models/user_model.dart';
import 'package:community/views/shared/widgets/button.dart';
import 'package:community/views/shared/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthController _authController = Get.find();
  final ThemeController _themeController = Get.find();
  final CommunityController _communityController = Get.find();

  late final NotificationController _notificationController;

  // ✅ Stats Profil
  final RxBool _statsLoading = false.obs;
  final RxInt _communitiesCount = 0.obs;
  final RxInt _projectsCount = 0.obs;

  @override
  void initState() {
    super.initState();

    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController());
    }
    _notificationController = Get.find<NotificationController>();

    // ✅ Profil: ne force pas un loader si l'utilisateur est déjà en cache
    if (_authController.user.value == null) {
      _loadProfile();
    } else {
      // refresh doux en arrière-plan
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
    }

    // ✅ Stats: cache d'abord, refresh ensuite
    _bootstrapStats();
  }

  Future<void> _loadProfile() async {
    await _authController.loadProfile();
  }

  void _bootstrapStats() {
    // 1) immédiatement (cache)
    _recomputeStatsFromCache();

    // 2) refresh en arrière-plan (sans bloquer l’UI)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadStatsFromApi();
    });
  }

  void _recomputeStatsFromCache() {
    final communities = _communityController.communities;

    _communitiesCount.value = communities.length;

    int totalProjects = 0;
    for (final c in communities) {
      totalProjects += c.projects_count; // ✅ int non-null chez toi
    }
    _projectsCount.value = totalProjects;
  }

  Future<void> _loadStatsFromApi() async {
    try {
      _statsLoading.value = true;

      // ✅ refresh silencieux: ne perturbe pas d'autres pages
      await _communityController.loadCommunitiesSilently();

      _recomputeStatsFromCache();
    } catch (_) {
      _recomputeStatsFromCache();
    } finally {
      _statsLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil',
          style: TextStyle(fontSize: responsive.fontSize(18)),
        ),
        actions: [
          // Badge notifications
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  size: responsive.iconSize(24),
                ),
                onPressed: () => Get.toNamed(AppRoutes.notifications),
                tooltip: 'Notifications',
              ),
              Obx(() {
                final count = _notificationController.unreadCount.value;
                if (count <= 0) return const SizedBox.shrink();

                return Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }),
            ],
          ),
          IconButton(
            icon: Icon(Icons.settings, size: responsive.iconSize(24)),
            onPressed: () => _showSettings(responsive),
            tooltip: 'Paramètres',
          ),
        ],
      ),
      body: Obx(() {
        final user = _authController.user.value;

        // ✅ On ne bloque que si user est null
        if (_authController.isLoading.value && user == null) {
          return const LoadingWidget(message: 'Chargement du profil...');
        }

        if (user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: responsive.iconSize(64),
                  color: Colors.red,
                ),
                SizedBox(height: responsive.spacing(16)),
                Text(
                  'Impossible de charger le profil',
                  style: TextStyle(fontSize: responsive.fontSize(18)),
                ),
                SizedBox(height: responsive.spacing(16)),
                PrimaryButton(
                  text: 'Réessayer',
                  onPressed: _loadProfile,
                  fullWidth: false,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: ResponsiveContainer(
            maxWidth: responsive.value<double>(
              mobile: double.infinity,
              tablet: 700,
              desktop: 900,
              largeDesktop: 1000,
            ),
            padding: EdgeInsets.all(responsive.contentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(user, responsive),
                SizedBox(height: responsive.spacing(32)),

                if (responsive.isDesktop) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildPersonalInfo(user, responsive),
                            SizedBox(height: responsive.spacing(24)),
                            _buildPreferences(responsive),
                          ],
                        ),
                      ),
                      SizedBox(width: responsive.spacing(24)),
                      Expanded(
                        child: Column(
                          children: [
                            _buildStatistics(responsive),
                            SizedBox(height: responsive.spacing(24)),
                            _buildActions(responsive),
                          ],
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  _buildPersonalInfo(user, responsive),
                  SizedBox(height: responsive.spacing(32)),
                  _buildStatistics(responsive),
                  SizedBox(height: responsive.spacing(32)),
                  _buildPreferences(responsive),
                  SizedBox(height: responsive.spacing(32)),
                  _buildActions(responsive),
                ],

                SizedBox(height: responsive.spacing(32)),
                _buildVersionInfo(responsive),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(UserModel user, ResponsiveHelper responsive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Theme.of(context).cardColor,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.15),
        borderRadius: BorderRadius.circular(responsive.spacing(20)),
        child: Padding(
          padding: EdgeInsets.all(responsive.spacing(24)),
          child: responsive.isDesktop
              ? Row(
                  children: [
                    _buildAvatar(user, responsive),
                    SizedBox(width: responsive.spacing(32)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: AppTheme.headline1.copyWith(
                              fontSize: responsive.fontSize(24),
                            ),
                          ),
                          SizedBox(height: responsive.spacing(4)),
                          Text(
                            user.email,
                            style: AppTheme.bodyText2.copyWith(
                              fontSize: responsive.fontSize(16),
                            ),
                          ),
                          SizedBox(height: responsive.spacing(16)),
                          _memberSinceChip(user, responsive, isDark),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Actualiser stats',
                      onPressed: _loadStatsFromApi,
                      icon: Obx(() {
                        if (_statsLoading.value) {
                          return SizedBox(
                            width: responsive.iconSize(20),
                            height: responsive.iconSize(20),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          );
                        }
                        return const Icon(Icons.refresh);
                      }),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildAvatar(user, responsive),
                    SizedBox(height: responsive.spacing(16)),
                    Text(
                      user.fullName,
                      style: AppTheme.headline1.copyWith(
                        fontSize: responsive.fontSize(22),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: responsive.spacing(4)),
                    Text(
                      user.email,
                      style: AppTheme.bodyText2.copyWith(
                        fontSize: responsive.fontSize(15),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: responsive.spacing(16)),
                    _memberSinceChip(user, responsive, isDark),
                    SizedBox(height: responsive.spacing(8)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        tooltip: 'Actualiser stats',
                        onPressed: _loadStatsFromApi,
                        icon: Obx(() {
                          if (_statsLoading.value) {
                            return SizedBox(
                              width: responsive.iconSize(20),
                              height: responsive.iconSize(20),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            );
                          }
                          return const Icon(Icons.refresh);
                        }),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _memberSinceChip(
    UserModel user,
    ResponsiveHelper responsive,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.spacing(12),
        vertical: responsive.spacing(6),
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey[100],
        borderRadius: BorderRadius.circular(responsive.spacing(20)),
        border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
      ),
      child: Text(
        'Membre depuis ${_formatDate(user.created_at)}',
        style: AppTheme.bodyText2.copyWith(fontSize: responsive.fontSize(13)),
      ),
    );
  }

  Widget _buildAvatar(UserModel user, ResponsiveHelper responsive) {
    final size = responsive.value<double>(
      mobile: 80,
      tablet: 90,
      desktop: 100,
      largeDesktop: 110,
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getUserColor(user),
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: responsive.value<double>(mobile: 2.5, tablet: 3, desktop: 3.5),
        ),
      ),
      child: Center(
        child: Text(
          _getUserInitials(user),
          style: TextStyle(
            fontSize: responsive.fontSize(32),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfo(UserModel user, ResponsiveHelper responsive) {
    return Container(
      width: double.infinity,
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
            'Informations personnelles',
            style: AppTheme.headline2.copyWith(
              fontSize: responsive.fontSize(18),
            ),
          ),
          SizedBox(height: responsive.spacing(16)),
          _buildInfoItem(
            icon: Icons.person_outline,
            label: 'Prénom',
            value: user.prenom,
            responsive: responsive,
          ),
          const Divider(),
          _buildInfoItem(
            icon: Icons.person_outline,
            label: 'Nom',
            value: user.nom,
            responsive: responsive,
          ),
          const Divider(),
          _buildInfoItem(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user.email,
            responsive: responsive,
          ),
          SizedBox(height: responsive.spacing(16)),
          SecondaryButton(
            text: 'Modifier le profil',
            onPressed: () => _editProfile(user, responsive),
            fullWidth: true,
            icon: Icons.edit,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required ResponsiveHelper responsive,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: responsive.spacing(12)),
      child: Row(
        children: [
          Icon(icon, size: responsive.iconSize(20), color: Colors.grey[600]),
          SizedBox(width: responsive.spacing(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.bodyText2.copyWith(
                    fontSize: responsive.fontSize(12),
                  ),
                ),
                SizedBox(height: responsive.spacing(4)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: responsive.fontSize(15),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: responsive.isMobile ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(ResponsiveHelper responsive) {
    return Container(
      width: double.infinity,
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
              Text(
                'Statistiques',
                style: AppTheme.headline2.copyWith(
                  fontSize: responsive.fontSize(18),
                ),
              ),
              const Spacer(),
              Obx(() {
                if (!_statsLoading.value) return const SizedBox.shrink();
                return SizedBox(
                  width: responsive.iconSize(18),
                  height: responsive.iconSize(18),
                  child: const CircularProgressIndicator(strokeWidth: 2),
                );
              }),
            ],
          ),
          SizedBox(height: responsive.spacing(12)),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: responsive.spacing(10),
            mainAxisSpacing: responsive.spacing(10),
            childAspectRatio: responsive.value<double>(
              mobile: 0.9,
              tablet: 1.4,
              desktop: 1.5,
              largeDesktop: 1.6,
            ),
            children: [
              Obx(() {
                final value = _statsLoading.value
                    ? '…'
                    : '${_communitiesCount.value}';
                return _buildStatCard(
                  icon: Icons.groups_outlined,
                  value: value,
                  label: 'Communautés',
                  color: Colors.blue,
                  responsive: responsive,
                );
              }),
              Obx(() {
                final value = _statsLoading.value
                    ? '…'
                    : '${_projectsCount.value}';
                return _buildStatCard(
                  icon: Icons.folder_outlined,
                  value: value,
                  label: 'Projets',
                  color: Colors.green,
                  responsive: responsive,
                );
              }),
              _buildStatCard(
                icon: Icons.task_outlined,
                value: '—',
                label: 'Tâches créées',
                subtitle:
                    'Nous attendons les informations du développeur backend pour activer cette fonctionnalité.',
                color: Colors.orange,
                responsive: responsive,
              ),
              _buildStatCard(
                icon: Icons.check_circle_outline,
                value: '—',
                label: 'Tâches terminées',
                subtitle:
                    'Nous attendons les informations du développeur backend pour activer cette fonctionnalité.',
                color: Colors.purple,
                responsive: responsive,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    String? subtitle,
    required Color color,
    required ResponsiveHelper responsive,
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
        children: [
          Icon(icon, size: responsive.iconSize(24), color: color),
          SizedBox(height: responsive.spacing(8)),
          Text(
            value,
            style: TextStyle(
              fontSize: responsive.fontSize(18),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: responsive.spacing(4)),
          Text(
            label,
            style: AppTheme.bodyText2.copyWith(
              fontSize: responsive.fontSize(11),
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Expanded(
              child: Center(
                child: Text(
                  subtitle,
                  style: AppTheme.bodyText2.copyWith(
                    fontSize: responsive.fontSize(9),
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withOpacity(0.60),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreferences(ResponsiveHelper responsive) {
    return Container(
      width: double.infinity,
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
            'Préférences',
            style: AppTheme.headline2.copyWith(
              fontSize: responsive.fontSize(18),
            ),
          ),
          SizedBox(height: responsive.spacing(16)),
          Obx(() {
            return SwitchListTile(
              title: Text(
                'Mode sombre',
                style: TextStyle(fontSize: responsive.fontSize(15)),
              ),
              subtitle: Text(
                'Activer le thème sombre',
                style: TextStyle(fontSize: responsive.fontSize(13)),
              ),
              value: _themeController.isDarkMode.value,
              onChanged: (_) => _themeController.switchTheme(),
              secondary: Icon(
                _themeController.isDarkMode.value
                    ? Icons.dark_mode
                    : Icons.light_mode,
                size: responsive.iconSize(24),
              ),
            );
          }),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.notifications_outlined,
              size: responsive.iconSize(24),
            ),
            title: Text(
              'Notifications',
              style: TextStyle(fontSize: responsive.fontSize(15)),
            ),
            subtitle: Obx(() {
              final count = _notificationController.unreadCount.value;
              return Text(
                count > 0
                    ? '$count non lue${count > 1 ? 's' : ''}'
                    : 'Toutes lues',
                style: TextStyle(fontSize: responsive.fontSize(13)),
              );
            }),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: responsive.iconSize(16),
            ),
            onTap: () => Get.toNamed(AppRoutes.notifications),
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.language_outlined,
              size: responsive.iconSize(24),
            ),
            title: Text(
              'Langue',
              style: TextStyle(fontSize: responsive.fontSize(15)),
            ),
            subtitle: Text(
              'Français',
              style: TextStyle(fontSize: responsive.fontSize(13)),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: responsive.iconSize(16),
            ),
            onTap: () {
              Get.snackbar(
                'Langue',
                'Nous attendons les informations du développeur backend pour activer cette fonctionnalité.',
                backgroundColor: Colors.blue,
                colorText: Colors.white,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActions(ResponsiveHelper responsive) {
    return Container(
      width: double.infinity,
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
            'Actions',
            style: AppTheme.headline2.copyWith(
              fontSize: responsive.fontSize(18),
            ),
          ),
          SizedBox(height: responsive.spacing(16)),
          _buildActionTile(
            icon: Icons.help_outline,
            title: 'Centre d\'aide',
            color: Colors.blue,
            onTap: () {
              Get.snackbar(
                'Centre d\'aide',
                'Nous attendons les informations du développeur backend pour activer cette fonctionnalité.',
                backgroundColor: Colors.blue,
                colorText: Colors.white,
              );
            },
            responsive: responsive,
          ),
          const Divider(),
          _buildActionTile(
            icon: Icons.description_outlined,
            title: 'Conditions d\'utilisation',
            color: Colors.green,
            onTap: () => _showDialog(
              'Conditions d\'utilisation',
              'En utilisant MarPro+, vous acceptez nos conditions d\'utilisation.',
              responsive,
            ),
            responsive: responsive,
          ),
          const Divider(),
          _buildActionTile(
            icon: Icons.security_outlined,
            title: 'Politique de confidentialité',
            color: Colors.purple,
            onTap: () => _showDialog(
              'Politique de confidentialité',
              'Nous respectons votre vie privée. Vos données sont sécurisées.',
              responsive,
            ),
            responsive: responsive,
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Colors.red,
              size: responsive.iconSize(24),
            ),
            title: Text(
              'Déconnexion',
              style: TextStyle(
                color: Colors.red,
                fontSize: responsive.fontSize(15),
              ),
            ),
            onTap: () => _confirmLogout(responsive),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required ResponsiveHelper responsive,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: responsive.iconSize(24)),
      title: Text(title, style: TextStyle(fontSize: responsive.fontSize(15))),
      trailing: Icon(Icons.arrow_forward_ios, size: responsive.iconSize(16)),
      onTap: onTap,
    );
  }

  Widget _buildVersionInfo(ResponsiveHelper responsive) {
    return Center(
      child: Column(
        children: [
          Text(
            'MarPro+ v1.0.0',
            style: AppTheme.bodyText2.copyWith(
              fontSize: responsive.fontSize(14),
            ),
          ),
          SizedBox(height: responsive.spacing(4)),
          Text(
            '© 2024 MarPro+. Tous droits réservés.',
            style: AppTheme.bodyText2.copyWith(
              fontSize: responsive.fontSize(12),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettings(ResponsiveHelper responsive) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(responsive.spacing(20)),
            topRight: Radius.circular(responsive.spacing(20)),
          ),
        ),
        padding: EdgeInsets.only(bottom: responsive.spacing(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: responsive.spacing(12)),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier le profil'),
              onTap: () {
                Get.back();
                _editProfile(_authController.user.value!, responsive);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.notifications);
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Sécurité'),
              onTap: () {
                Get.back();
                _showSecuritySettings(responsive);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('À propos'),
              onTap: () {
                Get.back();
                _showAbout(responsive);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog(String title, String content, ResponsiveHelper responsive) {
    Get.defaultDialog(title: title, content: Text(content));
  }

  void _editProfile(UserModel user, ResponsiveHelper responsive) {
    final prenomController = TextEditingController(text: user.prenom);
    final nomController = TextEditingController(text: user.nom);

    Get.dialog(
      AlertDialog(
        title: const Text('Modifier le profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: prenomController,
              decoration: const InputDecoration(
                labelText: 'Prénom',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nomController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );

              final success = await _authController.updateProfile(
                prenom: prenomController.text.trim(),
                nom: nomController.text.trim(),
              );

              Get.back(); // loader
              Get.back(); // dialog

              Get.snackbar(
                success ? 'Succès' : 'Erreur',
                success ? 'Profil mis à jour' : 'Impossible de mettre à jour',
                backgroundColor: success ? Colors.green : Colors.red,
                colorText: Colors.white,
              );
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showSecuritySettings(ResponsiveHelper responsive) {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Changer le mot de passe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nouveau mot de passe',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmer le mot de passe',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text.length < 6) {
                Get.snackbar(
                  'Erreur',
                  'Minimum 6 caractères',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                Get.snackbar(
                  'Erreur',
                  'Les mots de passe ne correspondent pas',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );

              final success = await _authController.updateProfile(
                password: newPasswordController.text,
              );

              Get.back(); // loader
              Get.back(); // dialog

              Get.snackbar(
                success ? 'Succès' : 'Erreur',
                success ? 'Mot de passe changé' : 'Impossible de changer',
                backgroundColor: success ? Colors.green : Colors.red,
                colorText: Colors.white,
              );
            },
            child: const Text('Changer'),
          ),
        ],
      ),
    );
  }

  void _showAbout(ResponsiveHelper responsive) {
    Get.dialog(
      AlertDialog(
        title: const Text('À propos de MarPro+'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MarPro+ est une application de gestion collaborative.'),
            SizedBox(height: 16),
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Développé avec ❤️'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Fermer')),
        ],
      ),
    );
  }

  void _confirmLogout(ResponsiveHelper responsive) {
    Get.dialog(
      AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Get.back();
              _logout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    await _authController.logout();
    Get.offAllNamed(AppRoutes.welcome);
    Get.snackbar(
      'Déconnecté',
      'Vous avez été déconnecté avec succès.',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  String _getUserInitials(UserModel user) {
    final p = user.prenom.trim();
    final n = user.nom.trim();
    final p1 = p.isNotEmpty ? p[0] : 'U';
    final n1 = n.isNotEmpty ? n[0] : 'U';
    return '$p1$n1'.toUpperCase();
  }

  Color _getUserColor(UserModel user) {
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
    return colors[user.email.hashCode.abs() % colors.length];
  }

  String _formatDate(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays < 30) return '${difference.inDays} jours';
    if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} mois';
    }
    return '${(difference.inDays / 365).floor()} an(s)';
  }
}
