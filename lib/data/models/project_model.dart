import 'package:community/core/utils/date_time_helper.dart';

class ProjectModel {
  final int id;
  final String nom;
  final String description;
  final int created_by;
  final DateTime created_at;
  final DateTime? archived_at;
  final String? creator_nom;
  final String? creator_prenom;
  final int tasks_count;
  final int completed_tasks;
  final double completion_percentage;
  final int? todo_tasks;
  final int? in_progress_tasks;
  final int? done_tasks;

  ProjectModel({
    required this.id,
    required this.nom,
    required this.description,
    required this.created_by,
    required this.created_at,
    this.archived_at,
    this.creator_nom,
    this.creator_prenom,
    this.tasks_count = 0,
    this.completed_tasks = 0,
    this.completion_percentage = 0.0,
    this.todo_tasks,
    this.in_progress_tasks,
    this.done_tasks,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: _parseInt(json['id'] ?? json['project_id'], defaultValue: 0),
      nom: json['nom'] ?? '',
      description: json['description'] ?? '',
      created_by: _parseInt(json['created_by'], defaultValue: 0),
      created_at: DateTimeHelper.parseApiDateTime(
            json['created_at'],
            assumeUtcForNaiveDateTimes: true,
          ) ??
          DateTime.now(),
      archived_at: DateTimeHelper.parseApiDateTime(
        json['archived_at'],
        assumeUtcForNaiveDateTimes: true,
      ),
      creator_nom: json['creator_nom'],
      creator_prenom: json['creator_prenom'],
      tasks_count: _parseInt(
        json['tasks_count'] ?? json['total_tasks'] ?? json['tasksCount'],
        defaultValue: 0,
      ),
      completed_tasks: _parseInt(
        json['completed_tasks'] ??
            json['done_tasks'] ??
            json['completedTasks'],
        defaultValue: 0,
      ),
      completion_percentage: _parseDouble(json['completion_percentage'] ?? json['progress']),
      todo_tasks: _parseNullableInt(
        json['todo_tasks'] ??
            json['todo_count'] ??
            json['a_faire_tasks'] ??
            json['a_faire_count'],
      ),
      in_progress_tasks: _parseNullableInt(
        json['in_progress_tasks'] ??
            json['in_progress_count'] ??
            json['en_cours_tasks'] ??
            json['en_cours_count'],
      ),
      done_tasks: _parseNullableInt(
        json['done_tasks'] ?? json['done_count'] ?? json['completed_tasks'],
      ),
    );
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    return _parseInt(value, defaultValue: 0);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'created_by': created_by,
      'created_at': created_at.toIso8601String(),
      'archived_at': archived_at?.toIso8601String(),
      'creator_nom': creator_nom,
      'creator_prenom': creator_prenom,
      'tasks_count': tasks_count,
      'completed_tasks': completed_tasks,
      'completion_percentage': completion_percentage,
      'todo_tasks': todo_tasks,
      'in_progress_tasks': in_progress_tasks,
      'done_tasks': done_tasks,
    };
  }

  ProjectModel copyWith({
    int? id,
    String? nom,
    String? description,
    int? created_by,
    DateTime? created_at,
    DateTime? archived_at,
    String? creator_nom,
    String? creator_prenom,
    int? tasks_count,
    int? completed_tasks,
    double? completion_percentage,
    int? todo_tasks,
    int? in_progress_tasks,
    int? done_tasks,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      created_by: created_by ?? this.created_by,
      created_at: created_at ?? this.created_at,
      archived_at: archived_at ?? this.archived_at,
      creator_nom: creator_nom ?? this.creator_nom,
      creator_prenom: creator_prenom ?? this.creator_prenom,
      tasks_count: tasks_count ?? this.tasks_count,
      completed_tasks: completed_tasks ?? this.completed_tasks,
      completion_percentage:
          completion_percentage ?? this.completion_percentage,
      todo_tasks: todo_tasks ?? this.todo_tasks,
      in_progress_tasks: in_progress_tasks ?? this.in_progress_tasks,
      done_tasks: done_tasks ?? this.done_tasks,
    );
  }

  // Getters utiles
  bool get isArchived => archived_at != null;

  String get creatorFullName {
    if (creator_prenom == null && creator_nom == null) return 'Inconnu';
    return '${creator_prenom ?? ''} ${creator_nom ?? ''}'.trim();
  }

  int get effectiveDoneTasks => done_tasks ?? completed_tasks;

  int get effectiveInProgressTasks => in_progress_tasks ?? 0;

  int get effectiveTodoTasks {
    if (todo_tasks != null) return todo_tasks!;
    final remaining = effectiveTotalTasks - effectiveDoneTasks - effectiveInProgressTasks;
    return remaining < 0 ? 0 : remaining;
  }

  int get effectiveTotalTasks {
    if (todo_tasks != null || in_progress_tasks != null || done_tasks != null) {
      return (todo_tasks ?? 0) + effectiveInProgressTasks + effectiveDoneTasks;
    }
    return tasks_count;
  }

  double get effectiveCompletionPercentage {
    final total = effectiveTotalTasks;
    if (total == 0) return 0.0;
    return (effectiveDoneTasks / total) * 100;
  }
}
