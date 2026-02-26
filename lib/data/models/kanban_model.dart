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
    return KanbanModel(
      todo: (json['todo'] as List)
          .map((item) => TaskModel.fromJson(item))
          .toList(),
      inProgress: (json['in_progress'] as List)
          .map((item) => TaskModel.fromJson(item))
          .toList(),
      done: (json['done'] as List)
          .map((item) => TaskModel.fromJson(item))
          .toList(),
    );
  }

  int get totalTasks => todo.length + inProgress.length + done.length;
}
