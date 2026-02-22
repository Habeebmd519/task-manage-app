import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _taskRef =>
      _firestore.collection('users').doc(_uid).collection('tasks');

  Stream<List<TaskModel>> getTasks() {
    return _taskRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addTask(String title) async {
    await _taskRef.add({
      'title': title,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTask(String id) async {
    await _taskRef.doc(id).delete();
  }

  Future<void> toggleTask(String id, bool currentStatus) async {
    await _taskRef.doc(id).update({'isCompleted': !currentStatus});
  }
}
