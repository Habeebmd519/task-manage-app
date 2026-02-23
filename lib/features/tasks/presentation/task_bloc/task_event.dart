abstract class TaskEvent {}

class LoadTasks extends TaskEvent {
  final String userId;

  LoadTasks(this.userId);
}

class LoadMoreTasks extends TaskEvent {}

class RefreshTasks extends TaskEvent {}

class ApplyFilter extends TaskEvent {
  final String filter; // all, completed, pending
  ApplyFilter(this.filter);
}

class SearchTask extends TaskEvent {
  final String query;
  SearchTask(this.query);
}

class SortTasks extends TaskEvent {
  final String sortBy; // dueDate, priority, createdAt
  SortTasks(this.sortBy);
}

/// delete task

class DeleteTask extends TaskEvent {
  final String taskId;

  DeleteTask(this.taskId);
}

/// update task
class ToggleTaskStatus extends TaskEvent {
  final String taskId;
  final bool isCompleted;

  ToggleTaskStatus({required this.taskId, required this.isCompleted});
}

/// create task
class CreateTask extends TaskEvent {
  final String title;
  final String priority;
  final DateTime dueDate;
  final String category;

  CreateTask({
    required this.title,
    required this.priority,
    required this.dueDate,
    required this.category,
  });
}
