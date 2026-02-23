import 'models/task_model.dart';

class TaskLocalCache {
  List<TaskModel> _cachedTasks = [];

  void saveTasks(List<TaskModel> tasks) {
    _cachedTasks = tasks;
  }

  List<TaskModel> getTasks() => _cachedTasks;

  void clear() => _cachedTasks.clear();
}
