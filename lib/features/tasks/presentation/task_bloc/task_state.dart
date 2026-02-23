import 'package:task_manager/features/tasks/data/models/task_model.dart';

enum TaskStatus { initial, loading, success, error }

class TaskState {
  final TaskStatus status;
  final List<TaskModel> tasks;
  final List<TaskModel> allTasks;
  final bool hasReachedMax;
  final String filter;
  final String searchQuery;
  final String? userId;
  final String? sortBy;

  TaskState({
    this.status = TaskStatus.initial,
    this.tasks = const [],
    this.allTasks = const [],
    this.hasReachedMax = false,
    this.filter = "all",
    this.searchQuery = "",
    this.userId,
    this.sortBy,
  });

  TaskState copyWith({
    TaskStatus? status,
    List<TaskModel>? tasks,
    List<TaskModel>? allTasks,
    bool? hasReachedMax,
    String? filter,
    String? searchQuery,
    String? userId,
    String? sortBy,
  }) {
    return TaskState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      allTasks: allTasks ?? this.allTasks,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      userId: userId ?? this.userId,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}
