class TaskModel {
  final int id;
  final String titre;
  final String description;
  final String? project_nom;
  final String status;
  final int? assigned_to;
  final String? assigned_nom;
  final String? assigned_prenom;
  final String? assigned_email;
  final String? creator_nom;
  final String? creator_prenom;
  final DateTime? due_date;
  final int comments_count;
  final DateTime created_at;

  TaskModel({
    required this.id,
    required this.titre,
    required this.description,
    this.project_nom,
    required this.status,
    this.assigned_to,
    this.assigned_nom,
    this.assigned_prenom,
    this.assigned_email,
    this.creator_nom,
    this.creator_prenom,
    this.due_date,
    this.comments_count = 0,
    required this.created_at,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: _parseInt(json['id'] ?? json['task_id'], defaultValue: 0),
      titre: json['titre'] ?? '',
      description: json['description'] ?? '',
      project_nom: json['project_nom'],
      status: json['status'] ?? 'À faire',
      assigned_to: _parseInt(json['assigned_to']),
      assigned_nom: json['assigned_nom'],
      assigned_prenom: json['assigned_prenom'],
      assigned_email: json['assigned_email'],
      creator_nom: json['creator_nom'],
      creator_prenom: json['creator_prenom'],
      due_date: _parseDate(json['due_date']),
      comments_count: _parseInt(json['comments_count'], defaultValue: 0),
      created_at: _parseDate(json['created_at']) ?? DateTime.now(),
    );
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
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
      'titre': titre,
      'description': description,
      'project_nom': project_nom,
      'status': status,
      'assigned_to': assigned_to,
      'assigned_nom': assigned_nom,
      'assigned_prenom': assigned_prenom,
      'assigned_email': assigned_email,
      'creator_nom': creator_nom,
      'creator_prenom': creator_prenom,
      'due_date': due_date?.toIso8601String(),
      'comments_count': comments_count,
      'created_at': created_at.toIso8601String(),
    };
  }

  TaskModel copyWith({
    int? id,
    String? titre,
    String? description,
    String? project_nom,
    String? status,
    int? assigned_to,
    String? assigned_nom,
    String? assigned_prenom,
    String? assigned_email,
    String? creator_nom,
    String? creator_prenom,
    DateTime? due_date,
    int? comments_count,
    DateTime? created_at,
  }) {
    return TaskModel(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      project_nom: project_nom ?? this.project_nom,
      status: status ?? this.status,
      assigned_to: assigned_to ?? this.assigned_to,
      assigned_nom: assigned_nom ?? this.assigned_nom,
      assigned_prenom: assigned_prenom ?? this.assigned_prenom,
      assigned_email: assigned_email ?? this.assigned_email,
      creator_nom: creator_nom ?? this.creator_nom,
      creator_prenom: creator_prenom ?? this.creator_prenom,
      due_date: due_date ?? this.due_date,
      comments_count: comments_count ?? this.comments_count,
      created_at: created_at ?? this.created_at,
    );
  }

  // Getters utiles
  String get assignedFullName {
    if (assigned_prenom == null && assigned_nom == null) return 'Non assigné';
    return '${assigned_prenom ?? ''} ${assigned_nom ?? ''}'.trim();
  }

  String get creatorFullName {
    if (creator_prenom == null && creator_nom == null) return 'Inconnu';
    return '${creator_prenom ?? ''} ${creator_nom ?? ''}'.trim();
  }

  bool get isOverdue {
    if (due_date == null) return false;
    return due_date!.isBefore(DateTime.now()) && status != 'Terminé';
  }

  bool get isAssigned => assigned_to != null;
}
