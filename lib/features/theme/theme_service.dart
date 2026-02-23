import 'package:cloud_firestore/cloud_firestore.dart';

class ThemeService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> saveTheme(String userId, String theme) async {
    await _firestore.collection('users').doc(userId).set({
      "theme": theme,
    }, SetOptions(merge: true));
  }

  Future<String> getTheme(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();

    if (doc.exists && doc.data()?['theme'] != null) {
      return doc.data()!['theme'];
    }

    return "light";
  }
}
