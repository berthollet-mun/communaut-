import 'package:community/views/shared/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:community/controllers/community_controller.dart';
import 'package:community/controllers/project_controller.dart';
import 'package:community/app/routes/app_routes.dart';
import 'package:community/app/themes/app_theme.dart';
import 'package:community/core/utils/validators.dart';
import 'package:community/data/models/project_model.dart';
import 'package:community/views/shared/widgets/form_field.dart';

class CreateEditProjectPage extends StatefulWidget {
  const CreateEditProjectPage({super.key});

  @override
  State<CreateEditProjectPage> createState() => _CreateEditProjectPageState();
}

class _CreateEditProjectPageState extends State<CreateEditProjectPage> {
  final ProjectController _projectController = Get.find();
  final CommunityController _communityController = Get.find();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isEditMode = false;
  ProjectModel? _currentProject;

  @override
  void initState() {
    super.initState();
    _currentProject = _projectController.currentProject.value;
    _isEditMode = _currentProject != null;

    if (_isEditMode && _currentProject != null) {
      _nameController.text = _currentProject!.nom;
      _descriptionController.text = _currentProject!.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    final community = _communityController.currentCommunity.value;
    if (community == null) {
      return const Scaffold(
        body: Center(child: Text('Communauté non sélectionnée')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Modifier le projet' : 'Nouveau projet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Icon(
                Icons.folder_special,
                size: 60,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                _isEditMode ? 'Modifier le projet' : 'Créez un nouveau projet',
                style: AppTheme.headline2,
              ),
              const SizedBox(height: 8),
              Text(
                _isEditMode
                    ? 'Modifiez les informations de votre projet'
                    : 'Organisez votre travail en créant un projet',
                style: AppTheme.bodyText2,
              ),
              const SizedBox(height: 32),

              // Info communauté
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.groups,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            community.nom,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ce projet sera créé dans cette communauté',
                            style: AppTheme.bodyText2.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Formulaire
              CustomFormField(
                controller: _nameController,
                label: 'Nom du projet',
                hintText: 'Ex: Application mobile',
                prefixIcon: Icons.title,
                validator: (value) =>
                    Validators.validateRequired(value, 'Le nom'),
                isRequired: true,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnelle)',
                  hintText: 'Décrivez l\'objectif de ce projet...',
                  prefixIcon: Icon(Icons.description_outlined),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                minLines: 3,
              ),
              const SizedBox(height: 32),

              // Bouton
              Obx(() {
                if (_projectController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return PrimaryButton(
                  text: _isEditMode ? 'Mettre à jour' : 'Créer le projet',
                  onPressed: _saveProject,
                  fullWidth: true,
                  icon: _isEditMode ? Icons.save : Icons.add_circle_outline,
                );
              }),
              const SizedBox(height: 16),

              Center(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Annuler'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    final community = _communityController.currentCommunity.value!;

    if (_isEditMode && _currentProject != null) {
      final success = await _projectController.updateProject(
        communityId: community.community_id,
        projectId: _currentProject!.id,
        nom: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (success) {
        Get.back();
        Get.snackbar(
          'Succès',
          'Projet mis à jour',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Erreur',
          'Impossible de mettre à jour',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      final project = await _projectController.createProject(
        communityId: community.community_id,
        nom: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (project != null) {
        print('✅ Projet créé avec ID: ${project.id}');
        // ✅ IMPORTANT: Définir le projet courant AVANT de naviguer
        _projectController.setCurrentProject(project);

        // Puis naviguer
        Get.offNamed(AppRoutes.kanbanBoard);
        Get.snackbar(
          'Succès',
          'Projet "${project.nom}" créé',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Erreur',
          'Impossible de créer le projet',
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
