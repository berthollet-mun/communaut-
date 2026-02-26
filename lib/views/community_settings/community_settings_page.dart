
import 'package:community/app/themes/app_theme.dart';
import 'package:community/controllers/community_controller.dart';
import 'package:community/controllers/community_settings_controller.dart';
import 'package:community/core/utils/responsive_helper.dart';
import 'package:community/core/utils/widgets/responsive_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunitySettingsPage extends StatefulWidget {
  const CommunitySettingsPage({super.key});

  @override
  State<CommunitySettingsPage> createState() => _CommunitySettingsPageState();
}

class _CommunitySettingsPageState extends State<CommunitySettingsPage> {
  final CommunityController _communityController = Get.find();
  final CommunitySettingsController _settingsController = Get.find();

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final community = _communityController.currentCommunity.value;

    if (community == null) {
      return const Scaffold(
        body: Center(child: Text('Communauté non sélectionnée')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Paramètres - ${community.nom}',
          style: TextStyle(fontSize: responsive.fontSize(18)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _settingsController.resetToDefaults();
              Get.snackbar(
                'Réinitialisé',
                'Les paramètres ont été réinitialisés aux valeurs par défaut.',
                backgroundColor: Colors.blue,
                colorText: Colors.white,
              );
            },
            child: Text(
              'Réinitialiser',
              style: TextStyle(
                fontSize: responsive.fontSize(13),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
              _buildInfoBanner(responsive),
              SizedBox(height: responsive.spacing(24)),
              _buildTasksAndProjectsSection(responsive),
              SizedBox(height: responsive.spacing(24)),
              _buildSaveInfo(responsive),
            ],
          ),
        ),
      ),
    );
  }

  /// Petit bandeau d’info en haut
  Widget _buildInfoBanner(ResponsiveHelper responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(16)),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Text(
        'Ces paramètres vous aident à garder votre tableau Kanban rapide et lisible. '
        'Ils sont pour l’instant stockés localement sur votre appareil.',
        style: AppTheme.bodyText2.copyWith(
          fontSize: responsive.fontSize(13),
        ),
      ),
    );
  }

  /// Section Tâches & projets (performance)
  Widget _buildTasksAndProjectsSection(ResponsiveHelper responsive) {
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
            'Tâches & Projets',
            style: AppTheme.headline2.copyWith(
              fontSize: responsive.fontSize(18),
            ),
          ),
          SizedBox(height: responsive.spacing(4)),
          Text(
            'Ajustez ces options pour améliorer les performances et la lisibilité de votre Kanban.',
            style: AppTheme.bodyText2.copyWith(
              fontSize: responsive.fontSize(13),
            ),
          ),
          SizedBox(height: responsive.spacing(16)),

          // Afficher uniquement les tâches non terminées
          Obx(() {
            return SwitchListTile(
              title: Text(
                'Afficher uniquement les tâches non terminées',
                style: TextStyle(fontSize: responsive.fontSize(15)),
              ),
              subtitle: Text(
                'Les tâches "Terminées" seront masquées par défaut dans le Kanban.',
                style: TextStyle(fontSize: responsive.fontSize(12)),
              ),
              value: _settingsController.onlyActiveTasks.value,
              onChanged: (value) {
                _settingsController.onlyActiveTasks.value = value;
              },
            );
          }),
          const Divider(),

          // Nombre max de tâches par colonne
          Obx(() {
            final value = _settingsController.maxTasksPerColumn.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nombre max de tâches par colonne',
                  style: TextStyle(
                    fontSize: responsive.fontSize(15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: responsive.spacing(4)),
                Text(
                  '$value tâches maximum par colonne du Kanban.',
                  style: TextStyle(fontSize: responsive.fontSize(12)),
                ),
                Slider(
                  min: 20,
                  max: 200,
                  divisions: 9,
                  value: value.toDouble(),
                  label: '$value',
                  onChanged: (v) {
                    _settingsController.maxTasksPerColumn.value = v.round();
                  },
                ),
              ],
            );
          }),
          const Divider(),

          // Archiver automatiquement
          Obx(() {
            final days = _settingsController.autoArchiveDays.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Archiver les tâches terminées',
                  style: TextStyle(
                    fontSize: responsive.fontSize(15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: responsive.spacing(4)),
                Text(
                  'Masquer / archiver les tâches "Terminées" depuis plus de $days jours.',
                  style: TextStyle(fontSize: responsive.fontSize(12)),
                ),
                Slider(
                  min: 7,
                  max: 365,
                  divisions: 10,
                  value: days.toDouble(),
                  label: '$days jours',
                  onChanged: (v) {
                    _settingsController.autoArchiveDays.value = v.round();
                  },
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// Info sur la sauvegarde des paramètres
  Widget _buildSaveInfo(ResponsiveHelper responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(16)),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: responsive.iconSize(18)),
          SizedBox(width: responsive.spacing(8)),
          Expanded(
            child: Text(
              'Les paramètres sont pour l’instant appliqués localement. '
              'Une synchronisation avec le serveur sera ajoutée dans une prochaine mise à jour.',
              style: TextStyle(fontSize: responsive.fontSize(12)),
            ),
          ),
        ],
      ),
    );
  }
}