import 'package:community/views/shared/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:community/app/routes/app_routes.dart';
import 'package:community/app/themes/app_theme.dart';

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fonctionnalités'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Titre principal
              Text(
                'Tout ce dont vous avez besoin pour gérer vos projets',
                style: AppTheme.headline1.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                'Découvrez comment MarPro+ peut transformer votre façon de travailler en équipe',
                style: AppTheme.bodyText2.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 40),
              // Section 1: Communautés
              _buildFeatureSection(
                context,
                title: '🏢 Communautés',
                description: 'Créez des espaces de travail collaboratifs',
                features: [
                  'Créez des communautés pour vos équipes',
                  'Invitez des membres avec des codes d\'accès',
                  'Gérez les rôles (Admin, Responsable, Membre)',
                  'Consultez les statistiques de participation',
                ],
                icon: Icons.groups,
                color: Colors.blue,
              ),
              const SizedBox(height: 32),
              // Section 2: Projets
              _buildFeatureSection(
                context,
                title: '📂 Gestion de Projets',
                description: 'Organisez vos projets efficacement',
                features: [
                  'Créez et archivez des projets',
                  'Suivez la progression avec des statistiques',
                  'Visualisez les projets actifs et archivés',
                  'Assignez des responsables de projet',
                ],
                icon: Icons.folder_special,
                color: Colors.green,
              ),
              const SizedBox(height: 32),
              // Section 3: Tableau Kanban
              _buildFeatureSection(
                context,
                title: '📋 Tableau Kanban',
                description: 'Visualisez vos tâches intuitivement',
                features: [
                  'Colonnes personnalisables (À faire, En cours, Terminé)',
                  'Drag & drop des tâches',
                  'Filtrage par statut et assignation',
                  'Dates limites et priorités',
                ],
                icon: Icons.view_kanban,
                color: Colors.orange,
              ),
              const SizedBox(height: 32),
              // Section 4: Tâches
              _buildFeatureSection(
                context,
                title: '✅ Gestion des Tâches',
                description: 'Créez et assignez des tâches facilement',
                features: [
                  'Tâches avec titres, descriptions et dates limites',
                  'Assignation à des membres spécifiques',
                  'Commentaires et discussions sur les tâches',
                  'Historique des modifications',
                ],
                icon: Icons.task_alt,
                color: Colors.purple,
              ),
              const SizedBox(height: 32),
              // Section 5: Collaboration
              _buildFeatureSection(
                context,
                title: '💬 Collaboration en Temps Réel',
                description: 'Travaillez ensemble efficacement',
                features: [
                  'Commentaires sur les tâches',
                  'Notifications des activités',
                  'Historique détaillé des actions',
                  'Partage de fichiers (bientôt disponible)',
                ],
                icon: Icons.chat_bubble_outline,
                color: Colors.teal,
              ),
              const SizedBox(height: 32),
              // Section 6: Rôles et Permissions
              _buildFeatureSection(
                context,
                title: '👑 Système de Rôles',
                description: 'Contrôlez les accès avec précision',
                features: [
                  'Admin: Accès complet à toutes les fonctionnalités',
                  'Responsable: Gestion des projets et tâches',
                  'Membre: Participation aux tâches assignées',
                  'Permissions granulaires selon les rôles',
                ],
                icon: Icons.security,
                color: Colors.red,
              ),
              const SizedBox(height: 48),
              // Appel à l'action
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Prêt à transformer votre gestion de projet ?',
                      style: AppTheme.headline2.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Rejoignez des milliers d\'équipes qui utilisent déjà MarPro+',
                      style: AppTheme.bodyText1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            text: 'Commencer gratuitement',
                            onPressed: () {
                              Get.toNamed(AppRoutes.register);
                            },
                            icon: Icons.rocket_launch,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.pricingInfo);
                      },
                      child: Text(
                        'Voir les tarifs premium',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).cardColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Retour'),
            ),
            TextButton(
              onPressed: () {
                Get.toNamed(AppRoutes.pricingInfo);
              },
              child: const Text('Tarifs →'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSection(
    BuildContext context, {
    required String title,
    required String description,
    required List<String> features,
    required IconData icon,
    required Color color,
  }) {
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.headline2.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(description, style: AppTheme.bodyText2),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...features.map((feature) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, color: color, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: AppTheme.bodyText1.copyWith(fontSize: 15),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
