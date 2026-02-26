import 'package:community/views/shared/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:community/controllers/community_controller.dart';
import 'package:community/controllers/project_controller.dart';
import 'package:community/controllers/task_controller.dart';
import 'package:community/app/themes/app_theme.dart';
import 'package:community/core/utils/validators.dart';
import 'package:community/data/models/member_model.dart';
import 'package:community/data/models/task_model.dart';
import 'package:community/views/shared/widgets/form_field.dart';

class CreateEditTaskPage extends StatefulWidget {
  const CreateEditTaskPage({super.key});

  @override
  State<CreateEditTaskPage> createState() => _CreateEditTaskPageState();
}

class _CreateEditTaskPageState extends State<CreateEditTaskPage> {
  final TaskController _taskController = Get.find();
  final ProjectController _projectController = Get.find();
  final CommunityController _communityController = Get.find();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _dueDate;
  MemberModel? _assignedTo;
  List<MemberModel> _members = [];

  bool _isEditMode = false;
  TaskModel? _currentTask;
  bool _isLoadingMembers = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final community = _communityController.currentCommunity.value;
    final project = _projectController.currentProject.value;

    if (community == null || project == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
      });
      return;
    }

    _currentTask = _taskController.currentTask.value;
    _isEditMode = _currentTask != null;

    if (_isEditMode && _currentTask != null) {
      _titleController.text = _currentTask!.titre;
      _descriptionController.text = _currentTask!.description;
      _dueDate = _currentTask!.due_date;
    }

    // Charger les membres après le premier frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadMembers(community.community_id);
    });
  }

  Future<void> _loadMembers(int communityId) async {
    if (!mounted) return;

    setState(() => _isLoadingMembers = true);

    try {
      final members = await _communityController.getCommunityMembers(
        communityId,
      );

      if (!mounted) return;

      setState(() {
        _members = members;
        _isLoadingMembers = false;
      });

      if (_isEditMode && _currentTask?.assigned_to != null) {
        _assignedTo = _members.firstWhereOrNull(
          (m) => m.id == _currentTask?.assigned_to,
        );
      }
    } catch (e) {
      debugPrint('Erreur chargement membres: $e');
      if (mounted) {
        setState(() => _isLoadingMembers = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _showMemberSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Assigner à',
                style: AppTheme.headline2.copyWith(fontSize: 18),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_off_outlined),
                    title: const Text('Non assigné'),
                    trailing: _assignedTo == null
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      setState(() => _assignedTo = null);
                      Get.back();
                    },
                  ),
                  const Divider(),
                  ..._members.map(
                    (member) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          '${member.prenom[0]}${member.nom[0]}'.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(member.fullName),
                      subtitle: Text(member.email),
                      trailing: _assignedTo?.id == member.id
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () {
                        setState(() => _assignedTo = member);
                        Get.back();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final community = _communityController.currentCommunity.value;
    final project = _projectController.currentProject.value;

    // DEBUG
    print('=== SAVE TASK DEBUG ===');
    print('Community: ${community?.community_id}');
    print('Project ID: ${project?.id}');
    print('Project nom: ${project?.nom}');
    print('=======================');

    if (community == null || project == null || project.id == 0) {
      Get.snackbar(
        'Erreur',
        'Projet non sélectionné. Veuillez retourner au projet.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final dueDateStr = _dueDate != null
        ? '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}'
        : null;

    if (_isEditMode && _currentTask != null) {
      // MODE ÉDITION
      final success = await _taskController.updateTask(
        communityId: community.community_id,
        projectId: project.id,
        taskId: _currentTask!.id,
        titre: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        assignedTo: _assignedTo?.id,
        dueDate: dueDateStr,
      );

      if (success) {
        // _taskController.clearCurrentTask(); // ❌ SUPPRIMÉ : sinon la page de détails devient vide au retour
        Get.back();
        Get.snackbar(
          'Succès',
          'Tâche mise à jour',
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
      // MODE CRÉATION
      final task = await _taskController.createTask(
        communityId: community.community_id,
        projectId: project.id,
        titre: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        assignedTo: _assignedTo?.id,
        dueDate: dueDateStr,
      );

      if (task != null) {
        Get.back();
        Get.snackbar(
          'Succès',
          'Tâche créée',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Erreur',
          'Impossible de créer la tâche',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = _projectController.currentProject.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Modifier la tâche' : 'Nouvelle tâche'),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: _isLoadingMembers
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _isEditMode ? Icons.edit : Icons.add_task,
                      size: 60,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isEditMode ? 'Modifier la tâche' : 'Nouvelle tâche',
                      style: AppTheme.headline2,
                    ),
                    if (project != null)
                      Text('Projet: ${project.nom}', style: AppTheme.bodyText2),
                    const SizedBox(height: 32),

                    // Titre
                    CustomFormField(
                      controller: _titleController,
                      label: 'Titre',
                      hintText: 'Ex: Créer la maquette UI',
                      prefixIcon: Icons.title,
                      validator: (v) =>
                          Validators.validateRequired(v, 'Le titre'),
                      isRequired: true,
                    ),
                    const SizedBox(height: 20),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Décrivez la tâche...',
                        prefixIcon: Icon(Icons.description_outlined),
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      minLines: 3,
                    ),
                    const SizedBox(height: 20),

                    // Assignation
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Assigner à'),
                      subtitle: Text(
                        _assignedTo?.fullName ?? 'Non assigné',
                        style: TextStyle(
                          color: _assignedTo != null
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _showMemberSelection,
                    ),
                    const Divider(),

                    // Date d'échéance
                    ListTile(
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: const Text('Date d\'échéance'),
                      subtitle: Text(
                        _dueDate != null
                            ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                            : 'Non définie',
                        style: TextStyle(
                          color: _dueDate != null
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_dueDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => setState(() => _dueDate = null),
                            ),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                      onTap: _selectDate,
                    ),
                    const SizedBox(height: 32),

                    // Bouton
                    Obx(() {
                      if (_taskController.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return PrimaryButton(
                        text: _isEditMode ? 'Mettre à jour' : 'Créer',
                        onPressed: _saveTask,
                        fullWidth: true,
                        icon: _isEditMode ? Icons.save : Icons.add_task,
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

  void _confirmDelete() {
    final community = _communityController.currentCommunity.value!;
    final project = _projectController.currentProject.value!;

    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Supprimer cette tâche ?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              Get.back();
              final success = await _taskController.deleteTask(
                communityId: community.community_id,
                projectId: project.id,
                taskId: _currentTask!.id,
              );
              if (success) {
                _taskController.clearCurrentTask();
                Get.back();
                Get.snackbar(
                  'Succès',
                  'Tâche supprimée',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
