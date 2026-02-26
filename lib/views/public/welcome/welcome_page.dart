import 'package:community/views/shared/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:community/app/routes/app_routes.dart';
import 'package:community/app/themes/app_theme.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo et titre
                Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.workspace_premium,
                        size: 60,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'MarPro+',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gestion Collaborative de Projets',
                      style: AppTheme.bodyText1.copyWith(
                        fontSize: 18,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.color?.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                // Points clés
                Column(
                  children: [
                    _buildFeatureItem(
                      context,
                      icon: Icons.groups_outlined,
                      title: 'Communautés',
                      description: 'Créez ou rejoignez des équipes de travail',
                    ),
                    const SizedBox(height: 20),
                    _buildFeatureItem(
                      context,
                      icon: Icons.assignment_outlined,
                      title: 'Projets',
                      description: 'Organisez vos projets efficacement',
                    ),
                    const SizedBox(height: 20),
                    _buildFeatureItem(
                      context,
                      icon: Icons.view_kanban_outlined,
                      title: 'Tableaux Kanban',
                      description: 'Visualisez vos tâches en un coup d\'œil',
                    ),
                    const SizedBox(height: 20),
                    _buildFeatureItem(
                      context,
                      icon: Icons.comment_outlined,
                      title: 'Collaboration',
                      description: 'Travaillez ensemble en temps réel',
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                // Boutons d'action
                Column(
                  children: [
                    PrimaryButton(
                      text: 'Se connecter',
                      onPressed: () {
                        Get.toNamed(AppRoutes.login);
                      },
                      icon: Icons.login,
                    ),
                    const SizedBox(height: 16),
                    SecondaryButton(
                      text: 'S\'inscrire',
                      onPressed: () {
                        Get.toNamed(AppRoutes.register);
                      },
                      icon: Icons.person_add,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.features);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Découvrir les fonctionnalités',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            size: 18,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Note de bas de page
                Text(
                  'Commencez gratuitement. Aucune carte de crédit requise.',
                  style: AppTheme.bodyText2.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.color?.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Lien vers les tarifs
                TextButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.pricingInfo);
                  },
                  child: Text(
                    'Voir les tarifs',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(description, style: AppTheme.bodyText2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
