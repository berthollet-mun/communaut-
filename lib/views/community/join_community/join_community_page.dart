import 'package:community/app/routes/app_routes.dart';
import 'package:community/app/themes/app_theme.dart';
import 'package:community/controllers/community_controller.dart';
import 'package:community/core/utils/responsive_helper.dart';
import 'package:community/core/utils/validators.dart';
import 'package:community/core/utils/widgets/responsive_builder.dart';
import 'package:community/views/shared/widgets/button.dart';
import 'package:community/views/shared/widgets/form_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class JoinCommunityPage extends StatefulWidget {
  const JoinCommunityPage({super.key});

  @override
  State<JoinCommunityPage> createState() => _JoinCommunityPageState();
}

class _JoinCommunityPageState extends State<JoinCommunityPage> {
  final CommunityController _communityController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _inviteCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Initialiser le ResponsiveHelper
    final responsive = ResponsiveHelper(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rejoindre une communauté',
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
        child: ResponsiveContainer(
          maxWidth: responsive.value<double>(
            mobile: double.infinity,
            tablet: 600,
            desktop: 700,
            largeDesktop: 800,
          ),
          padding: EdgeInsets.all(responsive.contentPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête responsive
                _buildHeader(responsive),

                SizedBox(height: responsive.spacing(32)),

                // Champ de code responsive
                _buildCodeField(responsive),

                SizedBox(height: responsive.spacing(16)),

                // Exemple de code responsive
                _buildCodeExample(responsive),

                SizedBox(height: responsive.spacing(32)),

                // Bouton de rejoindre responsive
                _buildJoinButton(responsive),

                SizedBox(height: responsive.spacing(16)),

                // Lien pour créer responsive
                _buildCreateLink(responsive),

                SizedBox(height: responsive.spacing(32)),

                // Section d'aide responsive
                _buildHelpSection(responsive),

                SizedBox(height: responsive.spacing(24)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// En-tête avec icône et texte responsive
  Widget _buildHeader(ResponsiveHelper responsive) {
    // Sur desktop, afficher en ligne
    if (responsive.isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.key,
            size: responsive.iconSize(60),
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(width: responsive.spacing(24)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rejoignez une équipe',
                  style: AppTheme.headline2.copyWith(
                    fontSize: responsive.fontSize(24),
                  ),
                ),
                SizedBox(height: responsive.spacing(8)),
                Text(
                  'Entrez le code d\'invitation fourni par l\'administrateur de la communauté.',
                  style: AppTheme.bodyText2.copyWith(
                    fontSize: responsive.fontSize(14),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Sur mobile/tablette, afficher en colonne
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Icon(
            Icons.key,
            size: responsive.iconSize(60),
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: responsive.spacing(16)),
        Text(
          'Rejoignez une équipe',
          style: AppTheme.headline2.copyWith(fontSize: responsive.fontSize(22)),
        ),
        SizedBox(height: responsive.spacing(8)),
        Text(
          'Entrez le code d\'invitation fourni par l\'administrateur de la communauté.',
          style: AppTheme.bodyText2.copyWith(fontSize: responsive.fontSize(14)),
        ),
      ],
    );
  }

  /// Champ de saisie du code responsive
  Widget _buildCodeField(ResponsiveHelper responsive) {
    return Column(
      children: [
        SizedBox(
          height: responsive.value<double>(mobile: 56, tablet: 60, desktop: 64),
          child: CustomFormField(
            controller: _inviteCodeController,
            label: 'Code d\'invitation',
            hintText: 'Ex: A1B2C3D4',
            prefixIcon: Icons.vpn_key_outlined,
            validator: Validators.validateInviteCode,
            isRequired: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _joinCommunity(),
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              letterSpacing: responsive.value<double>(
                mobile: 2,
                tablet: 2.5,
                desktop: 3,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Exemple de code responsive
  Widget _buildCodeExample(ResponsiveHelper responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(16)),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: responsive.value<double>(mobile: 1, tablet: 1.5, desktop: 2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.help_outline,
            color: Colors.grey[600],
            size: responsive.iconSize(20),
          ),
          SizedBox(width: responsive.spacing(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'À quoi ressemble un code d\'invitation ?',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: responsive.fontSize(14),
                  ),
                ),
                SizedBox(height: responsive.spacing(4)),
                Text(
                  'Exemple: A1B2C3D4 (8 caractères, lettres et chiffres)',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: responsive.fontSize(13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bouton pour rejoindre responsive
  Widget _buildJoinButton(ResponsiveHelper responsive) {
    return Obx(() {
      if (_communityController.isLoading.value) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: responsive.spacing(16)),
            child: CircularProgressIndicator(
              strokeWidth: responsive.value<double>(
                mobile: 2,
                tablet: 2.5,
                desktop: 3,
              ),
            ),
          ),
        );
      }

      return SizedBox(
        height: responsive.value<double>(mobile: 50, tablet: 54, desktop: 58),
        child: PrimaryButton(
          text: 'Rejoindre la communauté',
          onPressed: _joinCommunity,
          fullWidth: true,
          icon: Icons.login,
          style: TextStyle(fontSize: responsive.fontSize(16)),
        ),
      );
    });
  }

  /// Lien pour créer une communauté responsive
  Widget _buildCreateLink(ResponsiveHelper responsive) {
    return Center(
      child: TextButton(
        onPressed: () {
          Get.toNamed(AppRoutes.createCommunity);
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.spacing(16),
            vertical: responsive.spacing(8),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Créer une nouvelle communauté',
              style: TextStyle(fontSize: responsive.fontSize(14)),
            ),
            SizedBox(width: responsive.spacing(8)),
            Icon(
              Icons.arrow_forward,
              size: responsive.iconSize(18),
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  /// Section d'aide responsive
  Widget _buildHelpSection(ResponsiveHelper responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(20)),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        boxShadow: [AppTheme.cardShadow],
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          width: responsive.value<double>(mobile: 1, tablet: 1.5, desktop: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Besoin d\'aide ?',
            style: AppTheme.headline2.copyWith(
              fontSize: responsive.fontSize(18),
            ),
          ),
          SizedBox(height: responsive.spacing(12)),

          // Instructions pour rejoindre
          _buildHelpSubsection('Pour rejoindre une communauté :', [
            '1. Demandez le code d\'invitation à un administrateur',
            '2. Saisissez le code ci-dessus',
            '3. Cliquez sur "Rejoindre la communauté"',
          ], responsive),

          SizedBox(height: responsive.spacing(16)),

          // Avantages une fois accepté
          _buildHelpSubsection('Une fois accepté, vous pourrez :', [
            '• Participer aux projets existants',
            '• Créer de nouvelles tâches (selon votre rôle)',
            '• Collaborer avec les autres membres',
          ], responsive),

          // Sur desktop, ajouter une info supplémentaire
          if (responsive.isDesktop) ...[
            SizedBox(height: responsive.spacing(16)),
            Container(
              padding: EdgeInsets.all(responsive.spacing(12)),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(responsive.spacing(8)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: responsive.iconSize(16),
                    color: Colors.blue,
                  ),
                  SizedBox(width: responsive.spacing(8)),
                  Expanded(
                    child: Text(
                      'Les codes d\'invitation sont uniques à chaque communauté et peuvent être régénérés par les administrateurs.',
                      style: TextStyle(
                        fontSize: responsive.fontSize(12),
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Sous-section d'aide
  Widget _buildHelpSubsection(
    String title,
    List<String> items,
    ResponsiveHelper responsive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: responsive.fontSize(14),
          ),
        ),
        SizedBox(height: responsive.spacing(8)),
        ...items.map(
          (item) => Padding(
            padding: EdgeInsets.only(
              bottom: responsive.spacing(4),
              left: responsive.value<double>(mobile: 0, tablet: 8, desktop: 12),
            ),
            child: Text(
              item,
              style: TextStyle(fontSize: responsive.fontSize(13), height: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // === Méthode de logique métier inchangée ===

  Future<void> _joinCommunity() async {
    if (_formKey.currentState!.validate()) {
      final success = await _communityController.joinCommunity(
        _inviteCodeController.text.trim().toUpperCase(),
      );

      if (success) {
        Get.offNamed(AppRoutes.communitySelect);

        Get.snackbar(
          'Succès !',
          'Vous avez rejoint la communauté avec succès.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Erreur',
          'Code d\'invitation invalide ou expiré.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }
}
