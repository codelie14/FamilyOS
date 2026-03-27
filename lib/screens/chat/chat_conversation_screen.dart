import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../../core/theme.dart';
import '../../services/firestore_service.dart';
import '../../services/cloudinary_service.dart';

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
  final FocusNode _focusNode = FocusNode();

  bool _showEmoji = false;
  bool _isRecording = false;
  Map<String, dynamic>? _replyTo;
  final _record = AudioRecorder();

  @override
  void initState() {
    super.initState();
    _msgController.addListener(() => setState(() {}));
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _showEmoji) {
        setState(() => _showEmoji = false);
      }
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _record.dispose();
    super.dispose();
  }

  void _toggleEmoji() {
    setState(() {
      _showEmoji = !_showEmoji;
      if (_showEmoji) {
        _focusNode.unfocus();
      } else {
        _focusNode.requestFocus();
      }
    });
  }

  Future<void> _startRecording() async {
    if (await _record.hasPermission()) {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _record.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
      setState(() => _isRecording = true);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permission requise pour le micro.')));
    }
  }

  Future<void> _stopRecording() async {
    final path = await _record.stop();
    setState(() => _isRecording = false);
    if (path != null) {
      final file = File(path);
      final cloudinary = CloudinaryService();
      final url = await cloudinary.uploadImage(file, folder: 'familyos_audio');
      if (url != null) {
        _sendMsgPayload(audioUrl: url, type: 'audio');
      }
    }
  }

  Future<void> _pickMedia() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: ImageSource.gallery);
    if (xfile != null) {
      final file = File(xfile.path);
      final cloudinary = CloudinaryService();
      final url = await cloudinary.uploadImage(file, folder: 'familyos_media');
      if (url != null) {
        _sendMsgPayload(imageUrl: url, type: 'image');
      }
    }
  }

  Future<void> _sendMsgPayload({String? text, String? imageUrl, String? audioUrl, String type = 'text'}) async {
    final user = FirebaseAuth.instance.currentUser;
    final senderName = user?.displayName ?? user?.email?.split('@').first ?? 'Moi';
    
    if (widget.isFamily) {
      await _db.sendChatMessage(
        senderName: senderName, text: text, imageUrl: imageUrl, audioUrl: audioUrl,
        type: type, replyTo: _replyTo
      );
    } else {
      await _db.sendDirectMessage(
        dmId: widget.chatId, senderName: senderName, text: text, imageUrl: imageUrl, audioUrl: audioUrl,
        type: type, replyTo: _replyTo
      );
    }
    setState(() => _replyTo = null);
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    setState(() => _msgController.clear());
    await _sendMsgPayload(text: text, type: 'text');
  }

  Future<void> _deleteMessage(String msgId) async {
    if (widget.isFamily) {
      await _db.deleteFamilyChatMessage(msgId);
    } else {
      await _db.deleteDirectMessage(widget.chatId, msgId);
    }
  }

  void _showMessageOptions(String msgId, Map<String, dynamic> msg, bool isMe) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: kSurface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withAlpha(50), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            if (msg['type'] == 'text')
              ListTile(
                leading: const Icon(Icons.copy, color: kText),
                title: const Text('Copier', style: TextStyle(fontFamily: 'Nunito', color: kText, fontWeight: FontWeight.w600)),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: msg['text'] ?? ''));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message copié')));
                },
              ),
            ListTile(
              leading: const Icon(Icons.reply, color: kText),
              title: const Text('Répondre', style: TextStyle(fontFamily: 'Nunito', color: kText, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _replyTo = {
                  'id': msgId,
                  'senderName': msg['senderName'],
                  'text': msg['text'],
                  'type': msg['type']
                });
                _focusNode.requestFocus();
              },
            ),
            if (isMe)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: kRed),
                title: const Text('Supprimer', style: TextStyle(fontFamily: 'Nunito', color: kRed, fontWeight: FontWeight.w700)),
                onTap: () {
                  Navigator.pop(ctx);
                  _deleteMessage(msgId);
                },
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(Map<String, dynamic> msg, Color textColor) {
    final type = msg['type'] ?? 'text';
    if (type == 'image' && msg['imageUrl'] != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 250, maxWidth: 250),
          child: Image.network(msg['imageUrl'], fit: BoxFit.cover),
        ),
      );
    } else if (type == 'audio' && msg['audioUrl'] != null) {
      return SizedBox(
        width: 220,
        child: _AudioBubble(url: msg['audioUrl'], color: textColor),
      );
    }
    return Text(msg['text'] ?? '', style: TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w600, color: textColor, height: 1.5));
  }

  Widget _replyPreview(Map<String, dynamic>? reply, Color textColor) {
    if (reply == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.black.withAlpha(25), borderRadius: BorderRadius.circular(8), border: Border(left: BorderSide(color: textColor, width: 3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(reply['senderName'] ?? '', style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w800, fontFamily: 'Nunito')),
          const SizedBox(height: 2),
          Text(reply['text'] ?? (reply['type'] == 'image' ? '📷 Image' : '🎤 Audio'), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor.withAlpha(200), fontSize: 11, fontFamily: 'Nunito')),
        ],
      ),
    );
  }

  Widget _themBubble({required LinearGradient gradient, required String initial, required Map<String, dynamic> msg, required String time}) {
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
                if (msg['replyTo'] != null) _replyPreview(msg['replyTo'], kPurple),
                _buildMessageContent(msg, kText),
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

  Widget _meBubble({required Map<String, dynamic> msg, required String time}) {
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
                if (msg['replyTo'] != null) _replyPreview(msg['replyTo'], Colors.white),
                _buildMessageContent(msg, Colors.white),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white54)),
              ],
            ),
          ),
        ),
      ],
    );
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
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appel vocal (à venir)'))),
                  child: Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white.withAlpha(15), width: 1)),
                    child: const Icon(Icons.call_outlined, color: kTextMuted, size: 16),
                  ),
                ),
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
                      onLongPress: () => _showMessageOptions(snapshot.docs[index].id, msg, isMe),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: isMe
                          ? _meBubble(msg: msg, time: time)
                          : _themBubble(
                              gradient: kGradCyan,
                              initial: (msg['senderName'] as String?)?.substring(0, 1).toUpperCase() ?? '?',
                              msg: msg,
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
          Column(
            children: [
              if (_replyTo != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: kSurface2, border: Border(top: BorderSide(color: Colors.white.withAlpha(15), width: 1))),
                  child: Row(
                    children: [
                      const Icon(Icons.reply, color: kPurple, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Réponse à ${_replyTo!['senderName']}', style: const TextStyle(color: kPurple, fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.bold)),
                            Text(_replyTo!['text'] ?? (_replyTo!['type'] == 'image' ? '📷 Image' : '🎤 Audio'), overflow: TextOverflow.ellipsis, style: const TextStyle(color: kTextMuted, fontFamily: 'Nunito', fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.close, size: 16, color: kTextMuted), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => setState(() => _replyTo = null)),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                decoration: BoxDecoration(
                  color: kSurface,
                  border: Border(top: BorderSide(color: Colors.white.withAlpha(12), width: 1)),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _pickMedia,
                      child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withAlpha(15), width: 1)),
                        child: const Icon(Icons.attach_file, color: kTextMuted, size: 18),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withAlpha(15), width: 1)),
                        child: Row(
                          children: [
                            GestureDetector(onTap: _toggleEmoji, child: Icon(_showEmoji ? Icons.keyboard : Icons.emoji_emotions_outlined, color: kTextMuted, size: 20)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                focusNode: _focusNode,
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
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _msgController.text.isEmpty
                      ? GestureDetector(
                          onLongPress: _startRecording,
                          onLongPressEnd: (_) => _stopRecording(),
                          child: Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(color: _isRecording ? kRed : kPurple, shape: BoxShape.circle),
                            child: const Icon(Icons.mic, color: Colors.white, size: 20),
                          ),
                        )
                      : GestureDetector(
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
              if (_showEmoji)
                SizedBox(
                  height: 250,
                  child: EmojiPicker(
                    textEditingController: _msgController,
                    config: const Config(
                      emojiViewConfig: EmojiViewConfig(backgroundColor: kBg),
                      bottomActionBarConfig: BottomActionBarConfig(showBackspaceButton: false, showSearchViewButton: false),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AudioBubble extends StatefulWidget {
  final String url;
  final Color color;
  const _AudioBubble({required this.url, required this.color});

  @override
  State<_AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<_AudioBubble> {
  final _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.setSourceUrl(widget.url);
    _player.onDurationChanged.listen((d) { if (mounted) setState(() => _duration = d); });
    _player.onPositionChanged.listen((p) { if (mounted) setState(() => _position = p); });
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            if (_isPlaying) _player.pause();
            else _player.play(UrlSource(widget.url));
          },
          child: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, color: widget.color, size: 36),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Slider(
            activeColor: widget.color,
            inactiveColor: widget.color.withAlpha(80),
            value: _position.inMilliseconds.toDouble(),
            max: _duration.inMilliseconds.toDouble() > 0 ? _duration.inMilliseconds.toDouble() : 1.0,
            onChanged: (val) {
              _player.seek(Duration(milliseconds: val.toInt()));
            },
          ),
        ),
      ],
    );
  }
}
