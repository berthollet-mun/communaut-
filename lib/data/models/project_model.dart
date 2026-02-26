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
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: _parseInt(json['id'] ?? json['project_id'], defaultValue: 0),
      nom: json['nom'] ?? '',
      description: json['description'] ?? '',
      created_by: _parseInt(json['created_by'], defaultValue: 0),
      created_at: _parseDate(json['created_at']) ?? DateTime.now(),
      archived_at: _parseDate(json['archived_at']),
      creator_nom: json['creator_nom'],
      creator_prenom: json['creator_prenom'],
      tasks_count: _parseInt(json['tasks_count'] ?? json['total_tasks'] ?? json['tasksCount'], defaultValue: 0),
      completed_tasks: _parseInt(json['completed_tasks'] ?? json['done_tasks'] ?? json['completedTasks'], defaultValue: 0),
      completion_percentage: _parseDouble(json['completion_percentage'] ?? json['progress']),
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

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
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
    );
  }

  // Getters utiles
  bool get isArchived => archived_at != null;

  String get creatorFullName {
    if (creator_prenom == null && creator_nom == null) return 'Inconnu';
    return '${creator_prenom ?? ''} ${creator_nom ?? ''}'.trim();
  }
}
