import 'package:community/data/models/task_model.dart';

class KanbanModel {
  final List<TaskModel> todo;
  final List<TaskModel> inProgress;
  final List<TaskModel> done;

  KanbanModel({
    required this.todo,
    required this.inProgress,
    required this.done,
  });

  factory KanbanModel.fromJson(Map<String, dynamic> json) {
    List<TaskModel> parseTasks(dynamic raw) {
      if (raw is! List) return <TaskModel>[];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(TaskModel.fromJson)
          .where((task) => !task.isDeleted)
          .toList();
    }

    return KanbanModel(
      todo: parseTasks(json['todo']),
      inProgress: parseTasks(json['in_progress']),
      done: parseTasks(json['done']),
    );
  }

  int get totalTasks => todo.length + inProgress.length + done.length;
}
