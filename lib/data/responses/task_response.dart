class TaskResponse {
  final int task_id;
  final String titre;
  final String description;
  final String status;
  final int? assigned_to;
  final String? assigned_nom;
  final String? assigned_prenom;
  final DateTime? due_date;
  final DateTime created_at;
  final int project_id;
  final String? project_nom;
  final int comments_count;

  TaskResponse({
    required this.task_id,
    required this.titre,
    required this.description,
    required this.status,
    this.assigned_to,
    this.assigned_nom,
    this.assigned_prenom,
    this.due_date,
    required this.created_at,
    required this.project_id,
    this.project_nom,
    required this.comments_count,
  });

  factory TaskResponse.fromJson(Map<String, dynamic> json) {
    return TaskResponse(
      task_id: json['task_id'] ?? json['id'],
      titre: json['titre'],
      description: json['description'],
      status: json['status'],
      assigned_to: json['assigned_to'],
      assigned_nom: json['assigned_nom'],
      assigned_prenom: json['assigned_prenom'],
      due_date: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : null,
      created_at: DateTime.parse(json['created_at']),
      project_id: json['project_id'],
      project_nom: json['project_nom'],
      comments_count: json['comments_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': task_id,
      'titre': titre,
      'description': description,
      'status': status,
      if (assigned_to != null) 'assigned_to': assigned_to,
      if (assigned_nom != null) 'assigned_nom': assigned_nom,
      if (assigned_prenom != null) 'assigned_prenom': assigned_prenom,
      if (due_date != null)
        'due_date': due_date!.toIso8601String().split('T')[0],
      'created_at': created_at.toIso8601String(),
      'project_id': project_id,
      if (project_nom != null) 'project_nom': project_nom,
      'comments_count': comments_count,
    };
  }

  String get assignedFullName {
    if (assigned_nom == null || assigned_prenom == null) {
      return 'Non assigné';
    }
    return '$assigned_prenom $assigned_nom';
  }
}
