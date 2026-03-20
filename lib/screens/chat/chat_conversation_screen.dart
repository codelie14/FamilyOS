import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';

class ChatConversationScreen extends StatefulWidget {
  const ChatConversationScreen({
    super.key,
    required this.name,
    required this.initial,
    required this.gradient,
  });

  final String name;
  final String initial;
  final LinearGradient gradient;

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final email = _authService.currentUser?.email ?? 'Unknown';
    _textController.clear();
    
    await _firestoreService.sendChatMessage(
      senderName: email,
      text: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = _authService.currentUser?.email;

    return Scaffold(
      backgroundColor: kBg2,
      body: Column(
        children: [
          const SafeArea(
            bottom: false,
            child: SizedBox.shrink(),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: Colors.white.withAlpha(15), width: 1),
                    ),
                    child: const Icon(Icons.chevron_left, color: kTextMuted, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: widget.gradient,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  alignment: Alignment.center,
                  child: Text(widget.initial, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.name, style: const TextStyle(fontFamily: 'Nunito', fontSize: 15, fontWeight: FontWeight.w800, color: kText)),
                      const Text('Connecté(e)', style: TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w600, color: kGreen)),
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
              stream: _firestoreService.getFamilyChatStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: kPurple));
                }
                
                final docs = snapshot.data?.docs ?? [];
                
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  reverse: true, // Show newest at the bottom
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isMe = data['senderName'] == currentUserEmail;
                    final text = data['text'] ?? '';
                    
                    // Format timestamp
                    String timeStr = '';
                    if (data['timestamp'] != null) {
                      final timestamp = data['timestamp'] as Timestamp;
                      final date = timestamp.toDate();
                      timeStr = DateFormat('HH:mm').format(date);
                    }
                    
                    if (isMe) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _meBubble(text: text, time: timeStr),
                      );
                    } else {
                      final initial = (data['senderName'] as String?)?.substring(0, 1).toUpperCase() ?? '?';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _themBubble(
                          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kCyan, kBlue]),
                          initial: initial,
                          text: text,
                          time: timeStr,
                        ),
                      );
                    }
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
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: kSurface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withAlpha(15), width: 1),
                  ),
                  child: const Icon(Icons.attach_file, color: kTextMuted, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: kSurface2,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withAlpha(15), width: 1),
                    ),
                    child: TextField(
                      controller: _textController,
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
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: kGradMain,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: kPurple.withAlpha(90), blurRadius: 16, offset: const Offset(0, 6))],
                    ),
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
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withAlpha(15), width: 1),
      ),
      child: Icon(icon, color: kTextMuted, size: 16),
    );
  }

  Widget _themBubble({required LinearGradient gradient, required String initial, required String text, required String time}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(9)),
          alignment: Alignment.center,
          child: Text(initial, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 11, color: Colors.white)),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kSurface2,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
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
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(4),
              ),
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
