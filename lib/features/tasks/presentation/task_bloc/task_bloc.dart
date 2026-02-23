// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/task_repository.dart';
import '../../data/models/task_model.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;

  // int _skip = 0;
  // final int _limit = 10;

  TaskBloc(this.repository) : super(TaskState()) {
    on<LoadTasks>(_onLoadTasks);
    on<LoadMoreTasks>(_onLoadMoreTasks);
    on<RefreshTasks>(_onRefreshTasks);
    on<ApplyFilter>(_onApplyFilter);
    on<SearchTask>(_onSearchTask);
    on<SortTasks>(_onSortTasks);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskStatus>(_onToggleTaskStatus);
    on<CreateTask>(_onCreateTask);
  }

  ///  FIRST LOAD
  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    try {
      debugPrint("LOAD TASKS EVENT");
      debugPrint("UserId from event: ${event.userId}");

      emit(state.copyWith(status: TaskStatus.loading, userId: event.userId));

      final tasks = await repository.getTasks(
        userId: event.userId,
        skip: 0,
        limit: 10,
      );

      debugPrint("Tasks received: ${tasks.length}");

      emit(
        state.copyWith(
          status: TaskStatus.success,
          allTasks: tasks,
          tasks: tasks,
          hasReachedMax: tasks.length < 10,
        ),
      );
    } catch (e) {
      debugPrint("LOAD TASK ERROR: $e");
      emit(state.copyWith(status: TaskStatus.error));
    }
  }

  ///  LOAD MORE (Infinite Scroll)
  Future<void> _onLoadMoreTasks(
    LoadMoreTasks event,
    Emitter<TaskState> emit,
  ) async {
    if (state.hasReachedMax || state.userId == null) return;

    try {
      final newTasks = await repository.getTasks(
        userId: state.userId!,
        skip: state.allTasks.length,
        limit: 10,
      );

      if (newTasks.isEmpty) {
        emit(state.copyWith(hasReachedMax: true));
        return;
      }

      final updatedAll = List.of(state.allTasks)..addAll(newTasks);

      emit(
        state.copyWith(
          allTasks: updatedAll,
          tasks: updatedAll, // later you can apply filter again
          hasReachedMax: newTasks.length < 10,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: TaskStatus.error));
    }
  }

  ///  REFRESH
  Future<void> _onRefreshTasks(
    RefreshTasks event,
    Emitter<TaskState> emit,
  ) async {
    if (state.userId == null) return;

    final tasks = await repository.getTasks(
      userId: state.userId!,
      skip: 0,
      limit: 10,
    );

    final updated = _applyViewState(tasks);

    emit(
      state.copyWith(
        allTasks: tasks,
        tasks: updated,
        status: TaskStatus.success,
        hasReachedMax: tasks.length < 10,
      ),
    );
  }

  ///  FILTER
  void _onApplyFilter(ApplyFilter event, Emitter<TaskState> emit) {
    emit(state.copyWith(filter: event.filter));

    final updated = _applyViewState(state.allTasks);

    emit(state.copyWith(tasks: updated));
  }

  /// apply view state
  List<TaskModel> _applyViewState(List<TaskModel> tasks) {
    List<TaskModel> result = List.from(tasks);

    /// FILTER
    if (state.filter == "completed") {
      result = result.where((t) => t.isCompleted).toList();
    } else if (state.filter == "pending") {
      result = result.where((t) => !t.isCompleted).toList();
    }

    /// SEARCH
    if (state.searchQuery.isNotEmpty) {
      result = result
          .where(
            (t) =>
                t.title.toLowerCase().contains(state.searchQuery.toLowerCase()),
          )
          .toList();
    }

    /// SORT
    if (state.sortBy == "dueDate") {
      result.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    }

    if (state.sortBy == "priority") {
      const order = {"High": 1, "Medium": 2, "Low": 3};
      result.sort((a, b) => order[a.priority]!.compareTo(order[b.priority]!));
    }

    if (state.sortBy == "createdAt") {
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return result;
  }

  /// SEARCH
  void _onSearchTask(SearchTask event, Emitter<TaskState> emit) {
    emit(state.copyWith(searchQuery: event.query));

    final updated = _applyViewState(state.allTasks);

    emit(state.copyWith(tasks: updated));
  }

  ///  SORT
  void _onSortTasks(SortTasks event, Emitter<TaskState> emit) {
    emit(state.copyWith(sortBy: event.sortBy));

    final updated = _applyViewState(state.allTasks);

    emit(state.copyWith(tasks: updated));
  }

  /// delete user
  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    if (state.userId == null) return;

    final updatedAll = state.allTasks
        .where((task) => task.id != event.taskId)
        .toList();

    emit(
      state.copyWith(allTasks: updatedAll, tasks: _applyViewState(updatedAll)),
    );

    try {
      await repository.deleteTask(taskId: event.taskId, userId: state.userId!);
    } catch (e) {
      debugPrint("Delete failed: $e");
      add(RefreshTasks());
    }
  }

  /// update task
  Future<void> _onToggleTaskStatus(
    ToggleTaskStatus event,
    Emitter<TaskState> emit,
  ) async {
    if (state.userId == null) return;

    try {
      final task = state.allTasks.firstWhere((t) => t.id == event.taskId);

      await repository.updateTask(
        taskId: task.id,
        userId: state.userId!,
        title: task.title,
        priority: task.priority,
        category: task.category,
        dueDate: task.dueDate,
        isCompleted: event.isCompleted,
      );

      add(RefreshTasks());
    } catch (e) {
      debugPrint("Update failed: $e");
    }
  }

  /// create task
  Future<void> _onCreateTask(CreateTask event, Emitter<TaskState> emit) async {
    if (state.userId == null) return;

    await repository.createTask(
      userId: state.userId!,
      title: event.title,
      priority: event.priority,
      dueDate: event.dueDate,
      category: event.category,
    );

    add(RefreshTasks());
  }
}
