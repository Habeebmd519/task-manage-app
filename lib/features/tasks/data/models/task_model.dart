import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final bool isCompleted;
  final Timestamp createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'isCompleted': isCompleted, 'createdAt': createdAt};
  }
}
