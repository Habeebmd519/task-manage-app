import 'dart:io';
import 'package:task_manager/core/errors/auth_exception.dart';
import 'package:task_manager/core/errors/cache_exception.dart';
import 'package:task_manager/core/errors/network_exception.dart';
import 'package:task_manager/core/errors/server_exception.dart';

import 'package:task_manager/features/tasks/data/local_cache.dart';
import 'package:task_manager/features/tasks/data/models/task_model.dart';
import 'package:task_manager/features/tasks/data/task_service.dart';

class TaskRepository {
  final TaskService service;
  final TaskLocalCache cache;

  TaskRepository(this.service, this.cache);

  /// GET TASKS
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
    }
    // 🔌 No internet
    on SocketException {
      if (cache.getTasks().isNotEmpty) {
        return cache.getTasks();
      }
      throw NetworkException();
    }
    // 🔐 Auth error
    on AuthException {
      throw AuthException("Session expired. Please login again.");
    }
    // 🖥 Server error
    on ServerException catch (e) {
      throw ServerException(e.message, e.code);
    }
    // 💾 Cache failure
    catch (e) {
      throw CacheException("Failed to load tasks");
    }
  }

  /// DELETE TASK
  Future<void> deleteTask({
    required String taskId,
    required String userId,
  }) async {
    try {
      await service.deleteTask(taskId: taskId, userId: userId);
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      throw ServerException("Failed to delete task");
    }
  }

  /// UPDATE TASK
  Future<void> updateTask({
    required String taskId,
    required String userId,
    required String title,
    required String priority,
    required String category,
    required DateTime dueDate,
    required bool isCompleted,
  }) async {
    try {
      await service.updateTask(
        taskId: taskId,
        userId: userId,
        title: title,
        priority: priority,
        category: category,
        dueDate: dueDate,
        isCompleted: isCompleted,
      );
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      throw ServerException("Failed to update task");
    }
  }

  /// CREATE TASK
  Future<void> createTask({
    required String userId,
    required String title,
    required String priority,
    required DateTime dueDate,
    required String category,
  }) async {
    try {
      await service.createTask(
        userId: userId,
        title: title,
        priority: priority,
        dueDate: dueDate,
        category: category,
      );
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      throw ServerException("Failed to create task");
    }
  }
}
