import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // -- Tasks --
  Stream<QuerySnapshot> getTasksStream() {
    return _db.collection('tasks').orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addTask(Map<String, dynamic> taskData) async {
    taskData['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection('tasks').add(taskData);
  }

  Future<void> toggleTaskStatus(String taskId, bool isDone) async {
    await _db.collection('tasks').doc(taskId).update({'done': isDone});
  }

  Future<void> deleteTask(String taskId) async {
    await _db.collection('tasks').doc(taskId).delete();
  }

  // -- Gallery Photos --
  Stream<QuerySnapshot> getGalleryStream() {
    return _db.collection('gallery').orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addPhoto(String url, {String? category}) async {
    await _db.collection('gallery').add({
      'url': url,
      'createdAt': FieldValue.serverTimestamp(),
      'category': category ?? 'general',
    });
  }

  // -- Chat Messages (Family Group) --
  Stream<QuerySnapshot> getFamilyChatStream() {
    return _db.collection('family_chat').orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> sendChatMessage({required String senderName, String? text, String? imageUrl}) async {
    await _db.collection('family_chat').add({
      'senderName': senderName,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // -- Details for other features (Notes, Vault) will follow --
}
