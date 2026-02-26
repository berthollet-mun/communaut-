class ProjectResponse {
  final int project_int;
  final String nom;
  final String description;
  final int created_by;
  final DateTime created_at;
  final DateTime? archived_at;
  final int? tasks_count;
  final int? completed_tasks;
  final double? completion_percentage;

  ProjectResponse({
    required this.project_int,
    required this.nom,
    required this.description,
    required this.created_by,
    required this.created_at,
    this.archived_at,
    this.tasks_count,
    this.completed_tasks,
    this.completion_percentage,
  });

  factory ProjectResponse.fromJson(Map<String, dynamic> json) {
    return ProjectResponse(
      project_int: json['project_id'] ?? json['id'],
      nom: json['nom'],
      description: json['description'],
      created_by: json['created_by'],
      created_at: DateTime.parse(json['created_at']),
      archived_at: json['archived_at'] != null
          ? DateTime.parse(json['archived_at'])
          : null,
      tasks_count: json['tasks_count'],
      completed_tasks: json['completed_tasks'],
      completion_percentage: json['completion_percentage']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': project_int,
      'nom': nom,
      'description': description,
      'created_by': created_by,
      'created_at': created_at.toIso8601String(),
      if (archived_at != null) 'archived_at': archived_at!.toIso8601String(),
      if (tasks_count != null) 'tasks_count': tasks_count,
      if (completed_tasks != null) 'completed_tasks': completed_tasks,
      if (completion_percentage != null)
        'completion_percentage': completion_percentage,
    };
  }
}
