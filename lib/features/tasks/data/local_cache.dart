import 'package:hive/hive.dart';
import 'package:task_manager/features/tasks/data/models/task_model.dart';

class TaskLocalCache {
  final box = Hive.box('tasks');

  void saveTasks(List<TaskModel> tasks) {
    box.put('tasks', tasks.map((e) => e.toJson()).toList());
  }

  List<TaskModel> getTasks() {
    final data = box.get('tasks', defaultValue: []);
    return List<TaskModel>.from(
      data.map((e) => TaskModel.fromJson(Map<String, dynamic>.from(e))),
    );
  }

  void clear() {
    box.delete('tasks');
  }
}
