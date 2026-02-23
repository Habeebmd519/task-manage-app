import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'models/task_model.dart';

class TaskService {
  final String baseUrl = "https://taskmanager.uat-lplusltd.com";

  Future<List<TaskModel>> fetchTasks({
    required String userId,
    required int skip,
    required int limit,
  }) async {
    final url = "$baseUrl/tasks/?user_id=$userId&skip=$skip&limit=$limit";
    debugPrint("TASK URL: $url");

    final response = await http.get(Uri.parse(url));
    debugPrint("STATUS CODE: ${response.statusCode}");
    debugPrint("RESPONSE BODY: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      final List data = decoded['data'];

      return data.map((e) => TaskModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed: ${response.statusCode} ${response.body}");
    }
  }

  /// delete task

  Future<void> deleteTask({
    required String taskId,
    required String userId,
  }) async {
    final url =
        "https://taskmanager.uat-lplusltd.com/tasks/$taskId?user_id=$userId";

    debugPrint("DELETE URL: $url");

    final response = await http.delete(Uri.parse(url));

    debugPrint("DELETE STATUS: ${response.statusCode}");
    debugPrint("DELETE BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to delete task");
    }
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
  }) async {
    final url = "$baseUrl/tasks/$taskId?user_id=$userId";

    final response = await http.put(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "title": title,
        "priority": priority,
        "category": category,
        "due_date": dueDate.toIso8601String(),
        "is_completed": isCompleted,
      }),
    );

    debugPrint("UPDATE STATUS: ${response.statusCode}");
    debugPrint("UPDATE BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Update failed");
    }
  }

  /// create task
  Future<void> createTask({
    required String userId,
    required String title,
    required String priority,
    required DateTime dueDate,
    required String category,
  }) async {
    final url = "$baseUrl/tasks/?user_id=$userId";

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "title": title,
        "priority": priority,
        "category": category,
        "due_date": dueDate.toIso8601String(),
      }),
    );
    debugPrint("Priority: $priority");
    debugPrint("Category: $category");

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception("Create task failed");
    }
  }
}
