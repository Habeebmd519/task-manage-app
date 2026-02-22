import 'package:equatable/equatable.dart';
import '../../data/models/task_model.dart';

enum TaskStatus { initial, loading, success, error }

class TaskState extends Equatable {
  final TaskStatus status;
  final List<TaskModel> tasks;
  final String? errorMessage;

  const TaskState({
    this.status = TaskStatus.initial,
    this.tasks = const [],
    this.errorMessage,
  });

  TaskState copyWith({
    TaskStatus? status,
    List<TaskModel>? tasks,
    String? errorMessage,
  }) {
    return TaskState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tasks, errorMessage];
}
