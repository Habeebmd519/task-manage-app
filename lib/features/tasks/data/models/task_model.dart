class TaskModel {
  final String id;
  final String title;
  final String priority;
  final String category;
  final DateTime dueDate;
  final DateTime createdAt;
  final bool isCompleted;

  TaskModel({
    required this.id,
    required this.title,
    required this.priority,
    required this.category,
    required this.dueDate,
    required this.createdAt,
    required this.isCompleted,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'].toString(),
      title: json['title'],
      priority: json['priority'],
      category: json['category'],
      dueDate: DateTime.parse(json['due_date']),
      createdAt: DateTime.parse(json['created_at']),
      isCompleted: json['is_completed'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority,
      'category': category,
      'due_date': dueDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'is_completed': isCompleted,
    };
  }
}
