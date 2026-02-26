import 'package:community/core/utils/responsive_helper.dart';
import 'package:community/core/utils/widgets/responsive_builder.dart';
import 'package:community/views/shared/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:community/app/routes/app_routes.dart';
import 'package:community/app/themes/app_theme.dart';

class PricingInfoPage extends StatelessWidget {
  const PricingInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tarifs',
          style: TextStyle(fontSize: responsive.fontSize(18)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: responsive.iconSize(24)),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête
            _buildHeader(context, responsive),
            // Plans
            _buildPricingPlans(context, responsive),
            // Comparaison
            _buildComparisonSection(context, responsive),
            // FAQ
            _buildFAQSection(context, responsive),
            // Appel à l'action final
            _buildCTA(context, responsive),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ResponsiveHelper responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(32)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
      ),
      child: ResponsiveContainer(
        maxWidth: responsive.value<double>(
          mobile: double.infinity,
          tablet: 800,
          desktop: 1000,
          largeDesktop: 1200,
        ),
        child: Column(
          children: [
            Text(
              'Des tarifs adaptés à vos besoins',
              style: AppTheme.headline1.copyWith(
                fontSize: responsive.value<double>(
                  mobile: 24,
                  tablet: 28,
                  desktop: 32,
                  largeDesktop: 36,
                ),
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsive.spacing(16)),
            Text(
              'Commencez gratuitement, passez au premium quand vous êtes prêt',
              style: AppTheme.bodyText1.copyWith(
                fontSize: responsive.fontSize(16),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingPlans(BuildContext context, ResponsiveHelper responsive) {
    return ResponsiveContainer(
      maxWidth: 1200,
      padding: EdgeInsets.all(responsive.contentPadding),
      child: responsive.isDesktop
          ? _buildDesktopPlansLayout(context, responsive)
          : _buildMobilePlansLayout(context, responsive),
    );
  }

  Widget _buildDesktopPlansLayout(
    BuildContext context,
    ResponsiveHelper responsive,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildPlanCard(
            context,
            title: 'Gratuit',
            price: '0€',
            period: 'pour toujours',
            color: Colors.blue,
            icon: Icons.free_breakfast,
            features: [
              'Jusqu\'à 3 communautés',
              'Jusqu\'à 5 projets par communauté',
              'Jusqu\'à 10 membres par communauté',
              'Tableau Kanban basique',
              'Historique des 30 derniers jours',
              'Support par email',
            ],
            isPopular: false,
            buttonText: 'Commencer gratuitement',
            onPressed: () {
              Get.toNamed(AppRoutes.register);
            },
            responsive: responsive,
          ),
        ),
        SizedBox(width: responsive.spacing(24)),
        Expanded(
          child: _buildPlanCard(
            context,
            title: 'Premium',
            price: '9,99€',
            period: 'par mois',
            color: Colors.purple,
            icon: Icons.workspace_premium,
            features: [
              'Communautés illimitées',
              'Projets illimités',
              'Membres illimités',
              'Tableau Kanban avancé',
              'Historique complet',
              'Support prioritaire',
              'Export de données',
              'Statistiques détaillées',
              'Thèmes personnalisables',
              'Intégrations (bientôt)',
            ],
            isPopular: true,
            buttonText: 'Essayer Premium',
            onPressed: () {
              _showPremiumDialog(context, responsive);
            },
            responsive: responsive,
          ),
        ),
        SizedBox(width: responsive.spacing(24)),
        Expanded(
          child: _buildPlanCard(
            context,
            title: 'Entreprise',
            price: 'Personnalisé',
            period: 'sur devis',
            color: Colors.teal,
            icon: Icons.business,
            features: [
              'Toutes les fonctionnalités Premium',
              'SSO (Single Sign-On)',
              'API personnalisée',
              'Support dédié 24/7',
              'Formation de l\'équipe',
              'Déploiement sur site',
              'SLA 99.9%',
              'Audit de sécurité',
            ],
            isPopular: false,
            buttonText: 'Contactez-nous',
            onPressed: () {
              _showEnterpriseDialog(context, responsive);
            },
            responsive: responsive,
          ),
        ),
      ],
    );
  }

  Widget _buildMobilePlansLayout(
    BuildContext context,
    ResponsiveHelper responsive,
  ) {
    return Column(
      children: [
        _buildPlanCard(
          context,
          title: 'Gratuit',
          price: '0€',
          period: 'pour toujours',
          color: Colors.blue,
          icon: Icons.free_breakfast,
          features: [
            'Jusqu\'à 3 communautés',
            'Jusqu\'à 5 projets par communauté',
            'Jusqu\'à 10 membres par communauté',
            'Tableau Kanban basique',
            'Historique des 30 derniers jours',
            'Support par email',
          ],
          isPopular: false,
          buttonText: 'Commencer gratuitement',
          onPressed: () {
            Get.toNamed(AppRoutes.register);
          },
          responsive: responsive,
        ),
        SizedBox(height: responsive.spacing(32)),
        _buildPlanCard(
          context,
          title: 'Premium',
          price: '9,99€',
          period: 'par mois',
          color: Colors.purple,
          icon: Icons.workspace_premium,
          features: [
            'Communautés illimitées',
            'Projets illimités',
            'Membres illimités',
            'Tableau Kanban avancé',
            'Historique complet',
            'Support prioritaire',
            'Export de données',
            'Statistiques détaillées',
            'Thèmes personnalisables',
            'Intégrations (bientôt)',
          ],
          isPopular: true,
          buttonText: 'Essayer Premium',
          onPressed: () {
            _showPremiumDialog(context, responsive);
          },
          responsive: responsive,
        ),
        SizedBox(height: responsive.spacing(32)),
        _buildPlanCard(
          context,
          title: 'Entreprise',
          price: 'Personnalisé',
          period: 'sur devis',
          color: Colors.teal,
          icon: Icons.business,
          features: [
            'Toutes les fonctionnalités Premium',
            'SSO (Single Sign-On)',
            'API personnalisée',
            'Support dédié 24/7',
            'Formation de l\'équipe',
            'Déploiement sur site',
            'SLA 99.9%',
            'Audit de sécurité',
          ],
          isPopular: false,
          buttonText: 'Contactez-nous',
          onPressed: () {
            _showEnterpriseDialog(context, responsive);
          },
          responsive: responsive,
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    required Color color,
    required IconData icon,
    required List<String> features,
    required bool isPopular,
    required String buttonText,
    required VoidCallback onPressed,
    required ResponsiveHelper responsive,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(responsive.spacing(20)),
        boxShadow: [
          BoxShadow(
            color: isPopular ? color.withOpacity(0.3) : Colors.black12,
            blurRadius: responsive.value<double>(
              mobile: 15,
              tablet: 20,
              desktop: 25,
            ),
            offset: Offset(0, responsive.spacing(10)),
          ),
        ],
        border: Border.all(
          color: isPopular ? color : Colors.transparent,
          width: responsive.value<double>(mobile: 1.5, tablet: 2, desktop: 2.5),
        ),
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              padding: EdgeInsets.symmetric(vertical: responsive.spacing(8)),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(responsive.spacing(20)),
                  topRight: Radius.circular(responsive.spacing(20)),
                ),
              ),
              child: Center(
                child: Text(
                  'LE PLUS POPULAIRE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    fontSize: responsive.fontSize(12),
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(responsive.spacing(24)),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(responsive.spacing(12)),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: responsive.iconSize(32),
                      ),
                    ),
                    SizedBox(width: responsive.spacing(16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTheme.headline2.copyWith(
                              fontSize: responsive.fontSize(20),
                              color: color,
                            ),
                          ),
                          Text(
                            period,
                            style: AppTheme.bodyText2.copyWith(
                              fontSize: responsive.fontSize(13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: responsive.spacing(24)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          price,
                          style: TextStyle(
                            fontSize: responsive.value<double>(
                              mobile: 36,
                              tablet: 42,
                              desktop: 48,
                            ),
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    if (price != 'Personnalisé')
                      Padding(
                        padding: EdgeInsets.only(bottom: responsive.spacing(8)),
                        child: Text(
                          '/mois',
                          style: AppTheme.bodyText2.copyWith(
                            fontSize: responsive.fontSize(14),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: responsive.spacing(24)),
                // Limiter le nombre de features sur mobile si nécessaire
                ...features
                    .take(
                      responsive.isMobile
                          ? (isPopular ? features.length : 6)
                          : features.length,
                    )
                    .map((feature) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: responsive.spacing(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: color,
                              size: responsive.iconSize(20),
                            ),
                            SizedBox(width: responsive.spacing(12)),
                            Expanded(
                              child: Text(
                                feature,
                                style: AppTheme.bodyText1.copyWith(
                                  fontSize: responsive.fontSize(13),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                if (responsive.isMobile && !isPopular && features.length > 6)
                  Text(
                    '+ ${features.length - 6} autres',
                    style: TextStyle(
                      fontSize: responsive.fontSize(13),
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                SizedBox(height: responsive.spacing(32)),
                SizedBox(
                  height: responsive.value<double>(
                    mobile: 48,
                    tablet: 52,
                    desktop: 56,
                  ),
                  child: PrimaryButton(
                    text: buttonText,
                    onPressed: onPressed,
                    fullWidth: true,
                    backgroundColor: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSection(
    BuildContext context,
    ResponsiveHelper responsive,
  ) {
    return Container(
      padding: EdgeInsets.all(responsive.contentPadding),
      color: Theme.of(context).cardColor,
      child: ResponsiveContainer(
        maxWidth: 1200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comparaison des plans',
              style: AppTheme.headline2.copyWith(
                fontSize: responsive.fontSize(20),
              ),
            ),
            SizedBox(height: responsive.spacing(24)),
            _buildComparisonTable(context, responsive),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTable(
    BuildContext context,
    ResponsiveHelper responsive,
  ) {
    final features = [
      'Fonctionnalité',
      'Communautés',
      'Projets par communauté',
      'Membres par communauté',
      'Tableau Kanban',
      'Historique',
      'Support',
      'Export de données',
      'API',
    ];

    final freePlan = [
      'Gratuit',
      '3',
      '5',
      '10',
      'Basique',
      '30 jours',
      'Email',
      'Non',
      'Non',
    ];

    final premiumPlan = [
      'Premium',
      'Illimité',
      'Illimité',
      'Illimité',
      'Avancé',
      'Complet',
      'Prioritaire',
      'Oui',
      'Basique',
    ];

    final enterprisePlan = [
      'Entreprise',
      'Illimité',
      'Illimité',
      'Illimité',
      'Avancé',
      'Complet',
      'Dédié 24/7',
      'Oui',
      'Personnalisée',
    ];

    // Sur mobile, afficher un layout vertical
    if (responsive.isMobile) {
      return Column(
        children: [
          for (int i = 1; i < features.length; i++)
            Container(
              margin: EdgeInsets.only(bottom: responsive.spacing(16)),
              padding: EdgeInsets.all(responsive.spacing(16)),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(responsive.spacing(12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    features[i],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: responsive.fontSize(15),
                    ),
                  ),
                  SizedBox(height: responsive.spacing(12)),
                  _buildComparisonRow(
                    'Gratuit',
                    freePlan[i],
                    Colors.blue,
                    responsive,
                  ),
                  _buildComparisonRow(
                    'Premium',
                    premiumPlan[i],
                    Colors.purple,
                    responsive,
                  ),
                  _buildComparisonRow(
                    'Entreprise',
                    enterprisePlan[i],
                    Colors.teal,
                    responsive,
                  ),
                ],
              ),
            ),
        ],
      );
    }

    // Sur tablette/desktop, afficher le DataTable
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: responsive.spacing(24),
        dataRowHeight: responsive.value<double>(
          mobile: 48,
          tablet: 52,
          desktop: 56,
        ),
        headingTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: responsive.fontSize(14),
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        dataTextStyle: TextStyle(fontSize: responsive.fontSize(13)),
        columns: [
          DataColumn(label: Text(features[0])),
          DataColumn(label: Text(freePlan[0])),
          DataColumn(label: Text(premiumPlan[0])),
          DataColumn(label: Text(enterprisePlan[0])),
        ],
        rows: List.generate(features.length - 1, (index) {
          final i = index + 1;
          return DataRow(
            cells: [
              DataCell(Text(features[i])),
              DataCell(Text(freePlan[i])),
              DataCell(Text(premiumPlan[i])),
              DataCell(Text(enterprisePlan[i])),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildComparisonRow(
    String plan,
    String value,
    Color color,
    ResponsiveHelper responsive,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: responsive.spacing(4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                color: color,
                margin: EdgeInsets.only(right: responsive.spacing(8)),
              ),
              Text(
                plan,
                style: TextStyle(
                  fontSize: responsive.fontSize(13),
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: responsive.fontSize(13),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context, ResponsiveHelper responsive) {
    return ResponsiveContainer(
      maxWidth: 1200,
      padding: EdgeInsets.all(responsive.contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Questions fréquentes',
            style: AppTheme.headline2.copyWith(
              fontSize: responsive.fontSize(20),
            ),
          ),
          SizedBox(height: responsive.spacing(24)),
          // Sur desktop, afficher en 2 colonnes
          responsive.isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildFAQItem(
                            context,
                            question: 'Puis-je changer de plan à tout moment ?',
                            answer:
                                'Oui, vous pouvez passer du plan gratuit au plan premium à tout moment. Le changement est instantané.',
                            responsive: responsive,
                          ),
                          _buildFAQItem(
                            context,
                            question: 'Y a-t-il un engagement ?',
                            answer:
                                'Non, vous pouvez annuler votre abonnement premium à tout moment. Aucun engagement n\'est requis.',
                            responsive: responsive,
                          ),
                          _buildFAQItem(
                            context,
                            question: 'Les données sont-elles sauvegardées ?',
                            answer:
                                'Oui, nous sauvegardons vos données quotidiennement. Vos projets et tâches sont en sécurité.',
                            responsive: responsive,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: responsive.spacing(24)),
                    Expanded(
                      child: Column(
                        children: [
                          _buildFAQItem(
                            context,
                            question: 'Puis-je essayer Premium gratuitement ?',
                            answer:
                                'Oui, nous proposons un essai gratuit de 14 jours pour le plan Premium.',
                            responsive: responsive,
                          ),
                          _buildFAQItem(
                            context,
                            question:
                                'Quels moyens de paiement acceptez-vous ?',
                            answer:
                                'Nous acceptons les cartes de crédit (Visa, Mastercard), PayPal et virements bancaires pour les plans Entreprise.',
                            responsive: responsive,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildFAQItem(
                      context,
                      question: 'Puis-je changer de plan à tout moment ?',
                      answer:
                          'Oui, vous pouvez passer du plan gratuit au plan premium à tout moment. Le changement est instantané.',
                      responsive: responsive,
                    ),
                    _buildFAQItem(
                      context,
                      question: 'Y a-t-il un engagement ?',
                      answer:
                          'Non, vous pouvez annuler votre abonnement premium à tout moment. Aucun engagement n\'est requis.',
                      responsive: responsive,
                    ),
                    _buildFAQItem(
                      context,
                      question: 'Les données sont-elles sauvegardées ?',
                      answer:
                          'Oui, nous sauvegardons vos données quotidiennement. Vos projets et tâches sont en sécurité.',
                      responsive: responsive,
                    ),
                    _buildFAQItem(
                      context,
                      question: 'Puis-je essayer Premium gratuitement ?',
                      answer:
                          'Oui, nous proposons un essai gratuit de 14 jours pour le plan Premium.',
                      responsive: responsive,
                    ),
                    _buildFAQItem(
                      context,
                      question: 'Quels moyens de paiement acceptez-vous ?',
                      answer:
                          'Nous acceptons les cartes de crédit (Visa, Mastercard), PayPal et virements bancaires pour les plans Entreprise.',
                      responsive: responsive,
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(
    BuildContext context, {
    required String question,
    required String answer,
    required ResponsiveHelper responsive,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive.spacing(16)),
      padding: EdgeInsets.all(responsive.spacing(16)),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontSize: responsive.fontSize(15),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: responsive.spacing(8)),
          Text(
            answer,
            style: AppTheme.bodyText2.copyWith(
              fontSize: responsive.fontSize(13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTA(BuildContext context, ResponsiveHelper responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(32)),
      color: Theme.of(context).primaryColor.withOpacity(0.05),
      child: ResponsiveContainer(
        maxWidth: 800,
        child: Column(
          children: [
            Text(
              'Prêt à commencer ?',
              style: AppTheme.headline2.copyWith(
                fontSize: responsive.fontSize(24),
              ),
            ),
            SizedBox(height: responsive.spacing(16)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.value<double>(
                  mobile: 0,
                  tablet: 40,
                  desktop: 80,
                ),
              ),
              child: Text(
                'Rejoignez des milliers d\'équipes qui gèrent déjà leurs projets avec MarPro+',
                style: AppTheme.bodyText1.copyWith(
                  fontSize: responsive.fontSize(15),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: responsive.spacing(24)),
            SizedBox(
              width: responsive.value<double>(
                mobile: double.infinity,
                tablet: 400,
                desktop: 450,
              ),
              height: responsive.value<double>(
                mobile: 50,
                tablet: 54,
                desktop: 58,
              ),
              child: PrimaryButton(
                text: 'Commencer gratuitement',
                onPressed: () {
                  Get.toNamed(AppRoutes.register);
                },
                icon: Icons.rocket_launch,
                fullWidth: true,
              ),
            ),
            SizedBox(height: responsive.spacing(16)),
            TextButton(
              onPressed: () {
                Get.offAllNamed(AppRoutes.welcome);
              },
              child: Text(
                'Retour à l\'accueil',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: responsive.fontSize(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPremiumDialog(BuildContext context, ResponsiveHelper responsive) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Essai Premium',
          style: TextStyle(fontSize: responsive.fontSize(18)),
        ),
        content: Container(
          constraints: BoxConstraints(
            maxWidth: responsive.value<double>(
              mobile: 300,
              tablet: 400,
              desktop: 500,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Le plan Premium est actuellement en développement.',
                style: TextStyle(fontSize: responsive.fontSize(14)),
              ),
              SizedBox(height: responsive.spacing(16)),
              Text(
                'Pour l\'instant, profitez de toutes les fonctionnalités gratuitement !',
                style: TextStyle(fontSize: responsive.fontSize(14)),
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
          PrimaryButton(
            text: 'Commencer gratuitement',
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.register);
            },
            fullWidth: false,
          ),
        ],
      ),
    );
  }

  void _showEnterpriseDialog(
    BuildContext context,
    ResponsiveHelper responsive,
  ) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Plan Entreprise',
          style: TextStyle(fontSize: responsive.fontSize(18)),
        ),
        content: Container(
          constraints: BoxConstraints(
            maxWidth: responsive.value<double>(
              mobile: 300,
              tablet: 400,
              desktop: 500,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pour les entreprises ayant des besoins spécifiques :',
                style: TextStyle(fontSize: responsive.fontSize(14)),
              ),
              SizedBox(height: responsive.spacing(8)),
              Text(
                '• Support dédié',
                style: TextStyle(fontSize: responsive.fontSize(13)),
              ),
              Text(
                '• Déploiement personnalisé',
                style: TextStyle(fontSize: responsive.fontSize(13)),
              ),
              Text(
                '• Formation sur mesure',
                style: TextStyle(fontSize: responsive.fontSize(13)),
              ),
              Text(
                '• Intégrations spécifiques',
                style: TextStyle(fontSize: responsive.fontSize(13)),
              ),
              SizedBox(height: responsive.spacing(16)),
              Text(
                'Contactez-nous à : contact@marpro-plus.com',
                style: TextStyle(fontSize: responsive.fontSize(14)),
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
          SecondaryButton(
            text: 'Copier l\'email',
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Email copié',
                'contact@marpro-plus.com',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            fullWidth: false,
          ),
        ],
      ),
    );
  }
}
