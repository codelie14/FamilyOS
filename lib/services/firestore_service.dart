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

  // -- Vault Secrets --
  Stream<QuerySnapshot> getVaultSecretsStream() {
    return _db.collection('vault_secrets').orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addVaultSecret(Map<String, dynamic> secretData) async {
    secretData['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection('vault_secrets').add(secretData);
  }

  // -- Notes --
  Stream<QuerySnapshot> getNotesStream() {
    return _db.collection('notes').orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addNote(Map<String, dynamic> noteData) async {
    noteData['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection('notes').add(noteData);
  }

  // -- Events (Calendar) --
  Stream<QuerySnapshot> getEventsStream() {
    return _db.collection('events').orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addEvent(Map<String, dynamic> eventData) async {
    eventData['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection('events').add(eventData);
  }

  // -- Files --
  Stream<QuerySnapshot> getFilesStream() {
    return _db.collection('files').orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addFile(Map<String, dynamic> fileData) async {
    fileData['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection('files').add(fileData);
  }

  // -- Members (Online Strip) --
  Stream<QuerySnapshot> getMembersStream() {
    return _db.collection('members').orderBy('name').snapshots();
  }

  Future<void> addMember(Map<String, dynamic> memberData) async {
    await _db.collection('members').add(memberData);
  }

  // -- Direct Chats --
  Stream<QuerySnapshot> getDirectChatsStream() {
    return _db.collection('direct_chats').orderBy('lastTime', descending: true).snapshots();
  }

  Future<void> addDirectChat(Map<String, dynamic> chatData) async {
    chatData['lastTime'] = FieldValue.serverTimestamp();
    await _db.collection('direct_chats').add(chatData);
  }
}
