import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'task_event.dart';
import 'task_state.dart';
import '../../data/task_repository.dart';
import '../../data/models/task_model.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;
  StreamSubscription<List<TaskModel>>? _taskSubscription;

  TaskBloc(this.repository) : super(const TaskState()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTask>(_onToggleTask);
    on<_TasksUpdated>(_onTasksUpdated);
  }

  /// 🔹 LOAD TASKS (Realtime)
  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(state.copyWith(status: TaskStatus.loading));

    await _taskSubscription?.cancel();

    _taskSubscription = repository.getTasks().listen(
      (tasks) {
        add(_TasksUpdated(tasks));
      },
      onError: (error) {
        emit(
          state.copyWith(
            status: TaskStatus.error,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  /// 🔹 INTERNAL EVENT (For Stream Update)
  void _onTasksUpdated(_TasksUpdated event, Emitter<TaskState> emit) {
    emit(state.copyWith(status: TaskStatus.success, tasks: event.tasks));
  }

  /// 🔹 ADD TASK
  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      await repository.addTask(event.title);
    } catch (e) {
      emit(
        state.copyWith(status: TaskStatus.error, errorMessage: e.toString()),
      );
    }
  }

  /// 🔹 DELETE TASK
  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await repository.deleteTask(event.id);
    } catch (e) {
      emit(
        state.copyWith(status: TaskStatus.error, errorMessage: e.toString()),
      );
    }
  }

  /// 🔹 TOGGLE TASK
  Future<void> _onToggleTask(ToggleTask event, Emitter<TaskState> emit) async {
    try {
      await repository.toggleTask(event.id, event.currentStatus);
    } catch (e) {
      emit(
        state.copyWith(status: TaskStatus.error, errorMessage: e.toString()),
      );
    }
  }

  @override
  Future<void> close() {
    _taskSubscription?.cancel();
    return super.close();
  }
}

/// 🔒 Private Internal Event (Used For Stream)
class _TasksUpdated extends TaskEvent {
  final List<TaskModel> tasks;

  const _TasksUpdated(this.tasks);

  @override
  List<Object?> get props => [tasks];
}
