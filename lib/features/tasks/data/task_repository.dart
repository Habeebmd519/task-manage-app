import 'package:task_manager/features/tasks/data/local_cache.dart';
import 'package:task_manager/features/tasks/data/models/task_model.dart';
import 'package:task_manager/features/tasks/data/task_service.dart';

class TaskRepository {
  final TaskService service;
  final TaskLocalCache cache;

  TaskRepository(this.service, this.cache);

  Future<List<TaskModel>> getTasks({
    required String userId,
    required int skip,
    required int limit,
  }) async {
    try {
      final tasks = await service.fetchTasks(
        userId: userId,
        skip: skip,
        limit: limit,
      );

      if (skip == 0) {
        cache.saveTasks(tasks);
      } else {
        cache.saveTasks([...cache.getTasks(), ...tasks]);
      }

      return cache.getTasks();
    } catch (e) {
      return cache.getTasks();
    }
  }

  /// delete task

  Future<void> deleteTask({required String taskId, required String userId}) {
    return service.deleteTask(taskId: taskId, userId: userId);
  }

  /// update task
  Future<void> updateTask({
    required String taskId,
    required String userId,
    required String title,
    required String priority,
    required String category,
    required DateTime dueDate,
    required bool isCompleted,
  }) {
    return service.updateTask(
      taskId: taskId,
      userId: userId,
      title: title,
      priority: priority,
      category: category,
      dueDate: dueDate,
      isCompleted: isCompleted,
    );
  }

  ///create task
  Future<void> createTask({
    required String userId,
    required String title,
    required String priority,
    required DateTime dueDate,
    required String category,
  }) {
    return service.createTask(
      userId: userId,
      title: title,
      priority: priority,
      dueDate: dueDate,
      category: category,
    );
  }
}
