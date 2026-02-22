import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

/// Load tasks (listen to Firestore stream)
class LoadTasks extends TaskEvent {}

/// Add new task
class AddTask extends TaskEvent {
  final String title;

  const AddTask(this.title);

  @override
  List<Object?> get props => [title];
}

/// Delete task
class DeleteTask extends TaskEvent {
  final String id;

  const DeleteTask(this.id);

  @override
  List<Object?> get props => [id];
}

/// Toggle complete
class ToggleTask extends TaskEvent {
  final String id;
  final bool currentStatus;

  const ToggleTask(this.id, this.currentStatus);

  @override
  List<Object?> get props => [id, currentStatus];
}
