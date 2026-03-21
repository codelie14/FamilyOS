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

  Future<void> updateTask(String taskId, Map<String, dynamic> data) async {
    await _db.collection('tasks').doc(taskId).update(data);
  }

  Future<void> deleteTask(String taskId) async {
    await _db.collection('tasks').doc(taskId).delete();
  }

  // -- Gallery Photos --
  Stream<QuerySnapshot> getGalleryStream() {
    return _db.collection('gallery').orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addPhoto(String url, {String? category, String? albumId}) async {
    await _db.collection('gallery').add({
      'url': url,
      'createdAt': FieldValue.serverTimestamp(),
      'category': category ?? 'general',
      'albumId': albumId,
    });
  }

  Future<void> deleteGalleryPhoto(String photoId) async {
    await _db.collection('gallery').doc(photoId).delete();
  }

  // -- Albums --
  Stream<QuerySnapshot> getAlbumsStream() {
    return _db.collection('albums').orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addAlbum(Map<String, dynamic> albumData) async {
    albumData['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection('albums').add(albumData);
  }

  Future<void> deleteAlbum(String albumId) async {
    await _db.collection('albums').doc(albumId).delete();
  }

  // -- Chat Messages (Family Group) --
  Stream<QuerySnapshot> getFamilyChatStream() {
    return _db.collection('family_chat').orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> sendChatMessage({
    required String senderName, 
    String? text, 
    String? imageUrl,
    String? audioUrl,
    String? videoUrl,
    String type = 'text',
    Map<String, dynamic>? replyTo,
  }) async {
    await _db.collection('family_chat').add({
      'senderName': senderName,
      'text': text,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
      'type': type,
      'replyTo': replyTo,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteFamilyChatMessage(String messageId) async {
    await _db.collection('family_chat').doc(messageId).delete();
  }

  // -- Vault Secrets --
  Stream<QuerySnapshot> getVaultSecretsStream() {
    return _db.collection('vault_secrets').orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addVaultSecret(Map<String, dynamic> secretData) async {
    secretData['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection('vault_secrets').add(secretData);
  }

  Future<void> deleteVaultSecret(String secretId) async {
    await _db.collection('vault_secrets').doc(secretId).delete();
  }

  // -- Vault PIN --
  Future<String?> getVaultPinHash(String uid) async {
    final doc = await _db.collection('members').doc(uid).get();
    if (doc.exists) {
      return (doc.data() as Map<String, dynamic>)['vaultPinHash'] as String?;
    }
    return null;
  }

  Future<void> setVaultPinHash(String uid, String hashedPin) async {
    await _db.collection('members').doc(uid).update({'vaultPinHash': hashedPin});
  }

  // -- Notes --
  Stream<QuerySnapshot> getNotesStream() {
    return _db.collection('notes').orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addNote(Map<String, dynamic> noteData) async {
    noteData['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection('notes').add(noteData);
  }

  Future<void> updateNote(String noteId, Map<String, dynamic> data) async {
    await _db.collection('notes').doc(noteId).update(data);
  }

  Future<void> deleteNote(String noteId) async {
    await _db.collection('notes').doc(noteId).delete();
  }

  // -- Events (Calendar) --
  Stream<QuerySnapshot> getEventsStream() {
    return _db.collection('events').orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addEvent(Map<String, dynamic> eventData) async {
    eventData['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection('events').add(eventData);
  }

  Future<void> updateEvent(String eventId, Map<String, dynamic> data) async {
    await _db.collection('events').doc(eventId).update(data);
  }

  Future<void> deleteEvent(String eventId) async {
    await _db.collection('events').doc(eventId).delete();
  }

  // -- Files --
  Stream<QuerySnapshot> getFilesStream() {
    return _db.collection('files').orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addFile(Map<String, dynamic> fileData) async {
    fileData['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection('files').add(fileData);
  }

  Future<void> deleteFile(String fileId) async {
    await _db.collection('files').doc(fileId).delete();
  }

  // -- Members (Online Strip) --
  Stream<QuerySnapshot> getMembersStream() {
    return _db.collection('members').orderBy('name').snapshots();
  }

  Future<void> addMember(Map<String, dynamic> memberData) async {
    await _db.collection('members').add(memberData);
  }

  Future<void> updateMemberPreferences(String uid, Map<String, dynamic> prefs) async {
    await _db.collection('members').doc(uid).update(prefs);
  }

  // -- Direct Chats --
  Stream<QuerySnapshot> getDirectChatsStream() {
    return _db.collection('direct_chats').orderBy('lastTime', descending: true).snapshots();
  }

  Future<void> addDirectChat(Map<String, dynamic> chatData) async {
    chatData['lastTime'] = FieldValue.serverTimestamp();
    await _db.collection('direct_chats').add(chatData);
  }

  Stream<QuerySnapshot> getDirectMessageStream(String dmId) {
    return _db.collection('direct_chats').doc(dmId).collection('messages').orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> sendDirectMessage({
    required String dmId, 
    required String senderName, 
    String? text, 
    String? imageUrl,
    String? audioUrl,
    String? videoUrl,
    String type = 'text',
    Map<String, dynamic>? replyTo,
  }) async {
    await _db.collection('direct_chats').doc(dmId).collection('messages').add({
      'senderName': senderName,
      'text': text,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
      'type': type,
      'replyTo': replyTo,
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    String previewText = text ?? '';
    if (type == 'image') previewText = '📷 Image jointe';
    if (type == 'audio') previewText = '🎤 Note vocale';
    if (type == 'video') previewText = '📹 Vidéo jointe';

    await _db.collection('direct_chats').doc(dmId).update({
      'lastTime': FieldValue.serverTimestamp(),
      'preview': previewText,
    });
  }

  Future<void> deleteDirectMessage(String dmId, String messageId) async {
    await _db.collection('direct_chats').doc(dmId).collection('messages').doc(messageId).delete();
  }
}
