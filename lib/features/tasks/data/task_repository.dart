import 'models/task_model.dart';
import 'task_service.dart';

class TaskRepository {
  final TaskService _service;

  TaskRepository(this._service);

  Stream<List<TaskModel>> getTasks() {
    return _service.getTasks();
  }

  Future<void> addTask(String title) {
    return _service.addTask(title);
  }

  Future<void> deleteTask(String id) {
    return _service.deleteTask(id);
  }

  Future<void> toggleTask(String id, bool currentStatus) {
    return _service.toggleTask(id, currentStatus);
  }
}
