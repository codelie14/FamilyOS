import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatConversationScreen extends StatefulWidget {
  const ChatConversationScreen({
    super.key,
    required this.name,
    required this.initial,
    required this.gradient,
    required this.chatId,
    required this.isFamily,
  });

  final String name;
  final String initial;
  final LinearGradient gradient;
  final String chatId;
  final bool isFamily;

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final FirestoreService _db = FirestoreService();
  final _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    final senderName = user?.displayName ?? user?.email?.split('@').first ?? 'Moi';

    setState(() => _msgController.clear());

    if (widget.isFamily) {
      await _db.sendChatMessage(senderName: senderName, text: text);
    } else {
      await _db.sendDirectMessage(dmId: widget.chatId, senderName: senderName, text: text);
    }
  }

  Future<void> _deleteMessage(String msgId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text('Supprimer le message ?', style: TextStyle(fontFamily: 'Sora', color: kText)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Supprimer', style: TextStyle(color: kRed))),
        ],
      ),
    );
    if (confirm == true) {
      if (widget.isFamily) {
        await _db.deleteFamilyChatMessage(msgId);
      } else {
        await _db.deleteDirectMessage(widget.chatId, msgId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg2,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 10, 20, 16),
            decoration: BoxDecoration(
              color: kSurface,
              border: Border(bottom: BorderSide(color: Colors.white.withAlpha(12), width: 1)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withAlpha(15), width: 1)),
                    alignment: Alignment.center,
                    child: const Icon(Icons.arrow_back, color: kText, size: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(gradient: widget.gradient, borderRadius: BorderRadius.circular(14)),
                  alignment: Alignment.center,
                  child: Text(widget.initial, style: const TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.name, style: const TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
                      const SizedBox(height: 2),
                      const Text('En ligne', style: TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w700, color: kGreen)),
                    ],
                  ),
                ),
                _hBtn(Icons.call_outlined),
                const SizedBox(width: 6),
                _hBtn(Icons.more_horiz),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: widget.isFamily
                  ? _db.getFamilyChatStream()
                  : _db.getDirectMessageStream(widget.chatId),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: kPurple));
                }
                
                final snapshot = snap.data as QuerySnapshot;
                if (snapshot.docs.isEmpty) {
                  return const Center(child: Text('Aucun message', style: TextStyle(color: kTextMuted, fontFamily: 'Nunito')));
                }
                
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  itemCount: snapshot.docs.length,
                  itemBuilder: (context, index) {
                    final msg = snapshot.docs[index].data() as Map<String, dynamic>;
                    final user = FirebaseAuth.instance.currentUser;
                    final isMe = msg['senderName'] == (user?.displayName ?? user?.email?.split('@').first ?? 'Moi');
                    final time = msg['timestamp'] != null 
                        ? DateFormat('HH:mm').format((msg['timestamp'] as Timestamp).toDate())
                        : '...';
                        
                    return GestureDetector(
                      onLongPress: isMe ? () => _deleteMessage(snapshot.docs[index].id) : null,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: isMe
                          ? _meBubble(text: msg['text'] ?? '', time: time)
                          : _themBubble(
                              gradient: kGradCyan,
                              initial: (msg['senderName'] as String?)?.substring(0, 1).toUpperCase() ?? '?',
                              text: msg['text'] ?? '',
                              time: time,
                            ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            decoration: BoxDecoration(
              color: kSurface,
              border: Border(top: BorderSide(color: Colors.white.withAlpha(12), width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withAlpha(15), width: 1)),
                  child: const Icon(Icons.attach_file, color: kTextMuted, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withAlpha(15), width: 1)),
                    child: TextField(
                      controller: _msgController,
                      style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w600, color: kText),
                      decoration: const InputDecoration(
                        hintText: 'Message…',
                        hintStyle: TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w600, color: kTextDim),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(gradient: kGradMain, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: kPurple.withAlpha(90), blurRadius: 16, offset: const Offset(0, 6))]),
                    child: const Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hBtn(IconData icon) {
    return Container(
      width: 34, height: 34,
      decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white.withAlpha(15), width: 1)),
      child: Icon(icon, color: kTextMuted, size: 16),
    );
  }

  Widget _themBubble({required LinearGradient gradient, required String initial, required String text, required String time}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(9)),
          alignment: Alignment.center,
          child: Text(initial, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 11, color: Colors.white)),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: kSurface2,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomRight: Radius.circular(16), bottomLeft: Radius.circular(4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w600, color: kText, height: 1.5)),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w600, color: kTextDim)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _meBubble({required String text, required String time}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(width: 40),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              gradient: kGradMain,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white, height: 1.5)),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white54)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
