import 'package:community/controllers/notification_controller.dart';
import 'package:community/core/services/comment_service.dart';
import 'package:community/data/models/comment_model.dart';
import 'package:get/get.dart';

class CommentController extends GetxController {
  final CommentService _commentService = Get.find();
  final RxList<CommentModel> comments = <CommentModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // ✅ Helper pour envoyer des notifications
  void _notify(
    String type,
    String title,
    String message, {
    int? relatedId,
    String? relatedType,
  }) {
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().addLocalNotification(
        type: type,
        title: title,
        message: message,
        relatedId: relatedId,
        relatedType: relatedType,
      );
    }
  }

  Future<void> loadTaskComments({
    required int communityId,
    required int projectId,
    required int taskId,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final commentsList = await _commentService.getTaskComments(
        communityId: communityId,
        projectId: projectId,
        taskId: taskId,
      );

      comments.assignAll(commentsList);
    } catch (e) {
      error.value = 'Erreur de chargement des commentaires: $e';
      comments.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<CommentModel?> addComment({
    required int communityId,
    required int projectId,
    required int taskId,
    required String content,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final comment = await _commentService.addComment(
        communityId: communityId,
        projectId: projectId,
        taskId: taskId,
        content: content,
      );

      if (comment != null) {
        comments.insert(0, comment);

        // ✅ NOTIFICATION : Commentaire ajouté
        _notify(
          'comment_added',
          'Commentaire ajouté',
          'Votre commentaire a été publié avec succès.',
          relatedId: taskId,
          relatedType: 'task',
        );
      }

      return comment;
    } catch (e) {
      error.value = 'Erreur d\'ajout de commentaire: $e';

      // ✅ NOTIFICATION : Erreur
      _notify('error', 'Erreur', 'Impossible d\'ajouter le commentaire.');

      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateComment({
    required int communityId,
    required int projectId,
    required int taskId,
    required int commentId,
    required String content,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final success = await _commentService.updateComment(
        communityId: communityId,
        projectId: projectId,
        taskId: taskId,
        commentId: commentId,
        content: content,
      );

      if (success) {
        final index = comments.indexWhere((c) => c.id == commentId);
        if (index != -1) {
          comments[index] = comments[index].copyWith(
            content: content,
            updated_at: DateTime.now(),
          );
        }

        // ✅ NOTIFICATION : Commentaire modifié
        _notify(
          'comment_updated',
          'Commentaire modifié',
          'Votre commentaire a été mis à jour.',
          relatedId: taskId,
          relatedType: 'task',
        );
      }

      return success;
    } catch (e) {
      error.value = 'Erreur de mise à jour: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteComment({
    required int communityId,
    required int projectId,
    required int taskId,
    required int commentId,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final success = await _commentService.deleteComment(
        communityId: communityId,
        projectId: projectId,
        taskId: taskId,
        commentId: commentId,
      );

      if (success) {
        comments.removeWhere((c) => c.id == commentId);

        // ✅ NOTIFICATION : Commentaire supprimé
        _notify(
          'comment_deleted',
          'Commentaire supprimé',
          'Le commentaire a été supprimé.',
          relatedId: taskId,
          relatedType: 'task',
        );
      }

      return success;
    } catch (e) {
      error.value = 'Erreur de suppression: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void clearComments() {
    comments.clear();
    error.value = '';
  }

  bool canEditComment(CommentModel comment, int currentUserId) {
    return comment.email == 'current_user@example.com';
  }

  bool canDeleteComment(CommentModel comment, String userRole) {
    return userRole == 'ADMIN' || userRole == 'RESPONSABLE';
  }
}
