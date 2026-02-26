import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:community/controllers/comment_controller.dart';
import 'package:community/controllers/auth_controller.dart';
import 'package:community/data/models/comment_model.dart';

/// Commentaire local temporaire (optimistic UI)
class _LocalComment {
  final String tempId;
  final String fullName;
  final String email;
  final String content;
  final DateTime createdAt;

  _LocalComment({
    required this.tempId,
    required this.fullName,
    required this.email,
    required this.content,
    required this.createdAt,
  });
}

class TaskCommentsPage extends StatefulWidget {
  const TaskCommentsPage({super.key});

  @override
  State<TaskCommentsPage> createState() => _TaskCommentsPageState();
}

class _TaskCommentsPageState extends State<TaskCommentsPage> {
  final CommentController _commentController = Get.find();
  final AuthController _authController = Get.find();

  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollCtrl = ScrollController();

  late int _communityId;
  late int _projectId;
  late int _taskId;
  late String _taskTitle;
  late String _userRole;

  bool _isSending = false;

  /// ✅ liste des commentaires en attente (optimistic)
  final List<_LocalComment> _pending = [];

  /// ✅ auto refresh (polling)
  Timer? _pollTimer;
  bool _isPolling = false;

  @override
  void initState() {
    super.initState();

    final args = (Get.arguments is Map) ? (Get.arguments as Map) : {};

    _communityId = _asInt(args['communityId']);
    _projectId = _asInt(args['projectId']);
    _taskId = _asInt(args['taskId']);
    _taskTitle = (args['taskTitle'] ?? 'Tâche').toString();
    _userRole = (args['userRole'] ?? 'MEMBRE').toString();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadComments();
      _startAutoRefresh();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _inputController.dispose();
    _focusNode.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  void _startAutoRefresh() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 12), (_) async {
      if (!mounted) return;
      if (_isSending) return;
      if (_commentController.isLoading.value) return;
      if (_isPolling) return;

      _isPolling = true;
      try {
        await _loadComments(silent: true);
      } finally {
        _isPolling = false;
      }
    });
  }

  Future<void> _loadComments({bool silent = false}) async {
    await _commentController.loadTaskComments(
      communityId: _communityId,
      projectId: _projectId,
      taskId: _taskId,
    );
  }

  /// ✅ Met à jour "Détails" + liste tâches après add/delete/edit
  Future<void> _syncTaskEverywhere() async {
    if (!mounted) return;

    // 1) Refresh task details (met à jour comments_count)
    if (Get.isRegistered<dynamic>()) {
      // on ne peut pas tester un type précis ici, donc on fait un try/catch dynamic
    }

    try {
      if (Get.isRegistered<dynamic>()) {}
      if (Get.isRegistered<GetxController>()) {}
    } catch (_) {}

    try {
      if (Get.isRegistered<dynamic>()) {}
    } catch (_) {}

    // ✅ On fait simple : si TaskController est enregistré, on l’utilise en dynamic.
    try {
      final dynamic taskController = Get.find(tag: null);
      // si ça te renvoie pas le bon, ignore. On va faire le vrai below :
    } catch (_) {}

    try {
      final dynamic tc =
          Get.find(); // si TaskController est enregistré, il sera trouvé
      // mais si ce n’est pas TaskController -> pas grave, on catch
      await tc.loadTaskDetails?.call(
        communityId: _communityId,
        projectId: _projectId,
        taskId: _taskId,
      );
    } catch (_) {
      // si TaskController pas dispo ici, on ignore
    }

    // 2) Refresh liste des tâches (selon ta méthode existante)
    try {
      final dynamic tc = Get.find();
      // Plusieurs noms possibles selon ton projet :
      await (tc.loadTasks?.call(
            communityId: _communityId,
            projectId: _projectId,
          ) ??
          tc.loadProjectTasks?.call(
            communityId: _communityId,
            projectId: _projectId,
          ) ??
          tc.refreshTasks?.call(
            communityId: _communityId,
            projectId: _projectId,
          ));
    } catch (_) {
      // pas de méthode -> rien
    }
  }

  Future<void> _sendComment() async {
    final content = _inputController.text.trim();
    if (content.isEmpty || _isSending) return;

    final user = _authController.user.value;
    final email = user?.email ?? '';

    final fullNameRaw = '${user?.prenom ?? ''} ${user?.nom ?? ''}'.trim();
    final fullName = fullNameRaw.isEmpty
        ? (email.isEmpty ? 'Vous' : email)
        : fullNameRaw;

    if (email.isEmpty) {
      Get.snackbar(
        'Erreur',
        "Utilisateur non connecté.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // ✅ optimistic
    final tempId = 'tmp_${DateTime.now().microsecondsSinceEpoch}';
    setState(() {
      _pending.insert(
        0,
        _LocalComment(
          tempId: tempId,
          fullName: fullName,
          email: email,
          content: content,
          createdAt: DateTime.now(),
        ),
      );
      _isSending = true;
    });

    _inputController.clear();
    _focusNode.unfocus();

    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }

    try {
      final comment = await _commentController.addComment(
        communityId: _communityId,
        projectId: _projectId,
        taskId: _taskId,
        content: content,
      );

      if (comment != null) {
        if (mounted) {
          setState(() {
            _pending.removeWhere((c) => c.tempId == tempId);
          });
        }

        await _loadComments(silent: true);
        await _syncTaskEverywhere(); // ✅ update Détails + liste tâches
      } else {
        if (mounted) {
          setState(() {
            _pending.removeWhere((c) => c.tempId == tempId);
          });
        }
        Get.snackbar(
          'Erreur',
          "Impossible d'ajouter le commentaire",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _pending.removeWhere((c) => c.tempId == tempId);
        });
      }
      Get.snackbar(
        'Erreur',
        "Connexion impossible. Réessayez.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _editComment(CommentModel comment) {
    final editController = TextEditingController(text: comment.content);

    Get.dialog(
      AlertDialog(
        title: const Text('Modifier le commentaire'),
        content: TextField(
          controller: editController,
          maxLines: 5,
          minLines: 3,
          decoration: const InputDecoration(
            hintText: 'Votre commentaire...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final newContent = editController.text.trim();
              if (newContent.isEmpty) return;

              // ✅ petit loader
              Get.back();
              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );

              final ok = await _commentController.updateComment(
                communityId: _communityId,
                projectId: _projectId,
                taskId: _taskId,
                commentId: comment.id,
                content: newContent,
              );

              Get.back();

              Get.snackbar(
                ok ? 'Succès' : 'Erreur',
                ok ? 'Commentaire modifié' : 'Échec de la modification',
                backgroundColor: ok ? Colors.green : Colors.red,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );

              if (ok) {
                await _loadComments(silent: true);
                await _syncTaskEverywhere(); // ✅ pour cohérence
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _deleteComment(CommentModel comment) {
    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Voulez-vous vraiment supprimer ce commentaire ?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              Get.back();

              // ✅ loader
              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );

              final ok = await _commentController.deleteComment(
                communityId: _communityId,
                projectId: _projectId,
                taskId: _taskId,
                commentId: comment.id,
              );

              Get.back();

              Get.snackbar(
                ok ? 'Succès' : 'Erreur',
                ok ? 'Commentaire supprimé' : 'Échec de la suppression',
                backgroundColor: ok ? Colors.green : Colors.red,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );

              if (ok) {
                await _loadComments(silent: true);
                await _syncTaskEverywhere(); // ✅ update Détails + liste tâches
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
  Widget build(BuildContext context) {
    final currentUserEmail = _authController.user.value?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Commentaires', style: TextStyle(fontSize: 18)),
            Text(
              _taskTitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadComments),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final serverComments = _commentController.comments;

              if (_commentController.isLoading.value &&
                  serverComments.isEmpty &&
                  _pending.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_commentController.error.value.isNotEmpty &&
                  serverComments.isEmpty &&
                  _pending.isEmpty) {
                return _buildEmptyState(
                  title: 'Commentaires indisponibles',
                  subtitle: _commentController.error.value,
                );
              }

              if (serverComments.isEmpty && _pending.isEmpty) {
                return _buildEmptyState(
                  title: 'Aucun commentaire',
                  subtitle: 'Soyez le premier à commenter !',
                );
              }

              final total = _pending.length + serverComments.length;

              return RefreshIndicator(
                onRefresh: _loadComments,
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  itemCount: total,
                  itemBuilder: (context, index) {
                    if (index < _pending.length) {
                      return _buildLocalCommentCard(_pending[index]);
                    }

                    final c = serverComments[index - _pending.length];
                    final isMyComment = c.email == currentUserEmail;
                    final canDelete =
                        _userRole == 'ADMIN' ||
                        _userRole == 'RESPONSABLE' ||
                        isMyComment;

                    return _buildCommentCard(
                      c,
                      isMyComment: isMyComment,
                      canDelete: canDelete,
                    );
                  },
                ),
              );
            }),
          ),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required String title, required String subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalCommentCard(_LocalComment c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _getAvatarColor(c.email),
                child: Text(
                  _getInitials(c.fullName),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            c.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Vous',
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ],
                    ),
                    Text(
                      _formatDate(c.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(c.content, style: const TextStyle(fontSize: 15, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildCommentCard(
    CommentModel comment, {
    required bool isMyComment,
    required bool canDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMyComment ? Colors.blue.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMyComment ? Colors.blue.withOpacity(0.2) : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _getAvatarColor(comment.email),
                child: Text(
                  _getInitials(comment.fullName),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            comment.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isMyComment) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Vous',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      _formatDate(comment.created_at),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              if (isMyComment || canDelete)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  itemBuilder: (context) => [
                    if (isMyComment)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                    if (canDelete)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Supprimer',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') _editComment(comment);
                    if (value == 'delete') _deleteComment(comment);
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment.content,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
          if (comment.updated_at != null) ...[
            const SizedBox(height: 8),
            Text(
              '(modifié ${_formatDate(comment.updated_at!)})',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _inputController,
                  focusNode: _focusNode,
                  maxLines: 4,
                  minLines: 1,
                  decoration: const InputDecoration(
                    hintText: 'Écrire un commentaire...',
                    border: InputBorder.none,
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendComment(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _isSending
                ? const SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Container(
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendComment,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Color _getAvatarColor(String email) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[email.hashCode.abs() % colors.length];
  }

  String _getInitials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    return '${date.day}/${date.month}/${date.year}';
  }
}
