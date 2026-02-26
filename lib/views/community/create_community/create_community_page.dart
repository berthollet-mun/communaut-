import 'package:community/app/routes/app_routes.dart';
import 'package:community/app/themes/app_theme.dart';
import 'package:community/controllers/community_controller.dart';
import 'package:community/core/utils/responsive_helper.dart';
import 'package:community/core/utils/validators.dart';
import 'package:community/views/shared/widgets/form_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateCommunityPage extends StatefulWidget {
  const CreateCommunityPage({super.key});

  @override
  State<CreateCommunityPage> createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<CreateCommunityPage> {
  final CommunityController _communityController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return Scaffold(
      appBar: _buildAppBar(responsive),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: responsive.contentMaxWidth,
              padding: EdgeInsets.all(responsive.contentPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête
                    _buildHeader(responsive),

                    SizedBox(height: responsive.spacing(32)),

                    // Formulaire
                    _buildFormFields(responsive),

                    SizedBox(height: responsive.spacing(32)),

                    // Informations importantes
                    _buildInfoBox(responsive),

                    SizedBox(height: responsive.spacing(32)),

                    // Bouton de création
                    _buildCreateButton(responsive),

                    SizedBox(height: responsive.spacing(16)),

                    // Lien pour rejoindre
                    _buildJoinLink(responsive),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// AppBar responsive
  PreferredSizeWidget _buildAppBar(ResponsiveHelper responsive) {
    return AppBar(
      title: Text(
        'Créer une communauté',
        style: TextStyle(fontSize: responsive.fontSize(18)),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, size: responsive.iconSize(24)),
        onPressed: () => Get.back(),
      ),
      toolbarHeight: responsive.value<double>(
        mobile: 56,
        tablet: 60,
        desktop: 64,
      ),
    );
  }

  /// En-tête avec icône et textes
  Widget _buildHeader(ResponsiveHelper responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.groups,
          size: responsive.iconSize(60),
          color: Theme.of(context).primaryColor,
        ),
        SizedBox(height: responsive.spacing(16)),
        Text(
          'Créez votre espace de travail',
          style: AppTheme.headline2.copyWith(fontSize: responsive.fontSize(24)),
        ),
        SizedBox(height: responsive.spacing(8)),
        Text(
          'Une communauté est un espace où vous pouvez collaborer avec votre équipe sur des projets.',
          style: AppTheme.bodyText2.copyWith(fontSize: responsive.fontSize(14)),
        ),
      ],
    );
  }

  /// Champs du formulaire
  Widget _buildFormFields(ResponsiveHelper responsive) {
    return Column(
      children: [
        // Nom de la communauté
        CustomFormField(
          controller: _nameController,
          label: 'Nom de la communauté',
          hintText: 'Ex: Équipe Marketing',
          prefixIcon: Icons.people_outline,
          validator: (value) => Validators.validateRequired(value, 'Le nom'),
          isRequired: true,
        ),

        SizedBox(height: responsive.spacing(20)),

        // Description
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Description (optionnelle)',
            hintText: 'Décrivez l\'objectif de cette communauté...',
            prefixIcon: Icon(
              Icons.description_outlined,
              size: responsive.iconSize(20),
            ),
            border: const OutlineInputBorder(),
            alignLabelWithHint: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: responsive.spacing(16),
              vertical: responsive.spacing(16),
            ),
          ),
          style: TextStyle(fontSize: responsive.fontSize(14)),
          maxLines: 4,
          minLines: 3,
          keyboardType: TextInputType.multiline,
        ),
      ],
    );
  }

  /// Boîte d'informations importantes
  Widget _buildInfoBox(ResponsiveHelper responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(16)),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue[700],
                size: responsive.iconSize(20),
              ),
              SizedBox(width: responsive.spacing(8)),
              Text(
                'Informations importantes',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                  fontSize: responsive.fontSize(14),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(12)),

          // Liste des informations
          _buildInfoItem(
            responsive,
            '• Vous serez automatiquement nommé ADMIN de cette communauté',
          ),
          SizedBox(height: responsive.spacing(6)),
          _buildInfoItem(
            responsive,
            '• Vous pourrez inviter d\'autres membres après la création',
          ),
          SizedBox(height: responsive.spacing(6)),
          _buildInfoItem(
            responsive,
            '• Un code d\'invitation unique sera généré',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(ResponsiveHelper responsive, String text) {
    return Text(text, style: TextStyle(fontSize: responsive.fontSize(13)));
  }

  /// Bouton de création
  Widget _buildCreateButton(ResponsiveHelper responsive) {
    return Obx(() {
      if (_communityController.isLoading.value) {
        return SizedBox(
          height: responsive.value<double>(mobile: 50, tablet: 54, desktop: 56),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      return SizedBox(
        height: responsive.value<double>(mobile: 50, tablet: 54, desktop: 56),
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _createCommunity,
          icon: Icon(Icons.add_circle_outline, size: responsive.iconSize(20)),
          label: Text(
            'Créer la communauté',
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: responsive.spacing(14)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.spacing(12)),
            ),
          ),
        ),
      );
    });
  }

  /// Lien pour rejoindre une communauté
  Widget _buildJoinLink(ResponsiveHelper responsive) {
    return TextButton(
      onPressed: () => Get.toNamed(AppRoutes.joinCommunity),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Rejoindre une communauté existante',
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
    );
  }

  // === Logique conservée à l'identique ===

  Future<void> _createCommunity() async {
    if (_formKey.currentState!.validate()) {
      final community = await _communityController.createCommunity(
        nom: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (community != null) {
        Get.offNamed(AppRoutes.communityDashboard);

        Get.snackbar(
          'Succès !',
          'La communauté "${community.nom}" a été créée avec succès.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Erreur',
          'Impossible de créer la communauté. Veuillez réessayer.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
