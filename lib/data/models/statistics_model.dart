class StatisticsModel {
  final int totalProjects;
  final int activeProjects;
  final int totalTasks;
  final int completedTasks;
  final int totalMembers;
  final int adminsCount;
  final int responsablesCount;

  StatisticsModel({
    required this.totalProjects,
    required this.activeProjects,
    required this.totalTasks,
    required this.completedTasks,
    required this.totalMembers,
    required this.adminsCount,
    required this.responsablesCount,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      totalProjects: json['projects_count'] ?? 0,
      activeProjects: json['active_projects'] ?? 0,
      totalTasks: json['tasks_count'] ?? 0,
      completedTasks: json['completed_tasks'] ?? 0,
      totalMembers: json['members_count'] ?? 0,
      adminsCount: json['admins_count'] ?? 0,
      responsablesCount: json['responsables_count'] ?? 0,
    );
  }

  double get completionPercentage {
    if (totalTasks == 0) return 0;
    return (completedTasks / totalTasks) * 100;
  }
}
