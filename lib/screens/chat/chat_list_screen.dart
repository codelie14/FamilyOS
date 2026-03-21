import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/common_widgets.dart';
import 'chat_conversation_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final FirestoreService _db = FirestoreService();
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  LinearGradient _getGrad(int index) {
    const list = [
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [kPink, kPurple],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [kCyan, kBlue],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [kGreen, kCyan],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [kOrange, kPink],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [kPurple, kPink],
      ),
    ];
    return list[index % list.length];
  }

  void _showAddDMDialog() {
    final nameCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text(
          'Nouveau message direct',
          style: TextStyle(fontFamily: 'Sora', color: kText),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: kText),
              decoration: const InputDecoration(
                hintText: 'Nom du contact...',
                hintStyle: TextStyle(color: kTextMuted),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: msgCtrl,
              style: const TextStyle(color: kText),
              decoration: const InputDecoration(
                hintText: 'Message...',
                hintStyle: TextStyle(color: kTextMuted),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                _db.addDirectChat({
                  'name': nameCtrl.text.trim(),
                  'initial': nameCtrl.text.trim()[0].toUpperCase(),
                  'preview': msgCtrl.text.trim(),
                  'unreadCount': 1,
                  'isOnline': DateTime.now().millisecond % 2 == 0,
                  'colorIndex': DateTime.now().millisecond % 5,
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Créer', style: TextStyle(color: kPurple)),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog() {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text(
          'Ajouter un membre',
          style: TextStyle(fontFamily: 'Sora', color: kText),
        ),
        content: TextField(
          controller: nameCtrl,
          style: const TextStyle(color: kText),
          decoration: const InputDecoration(
            hintText: 'Nom...',
            hintStyle: TextStyle(color: kTextMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                _db.addMember({
                  'name': nameCtrl.text.trim(),
                  'initial': nameCtrl.text.trim()[0].toUpperCase(),
                  'isOnline': true,
                  'colorIndex': DateTime.now().millisecond % 5,
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Ajouter', style: TextStyle(color: kPurple)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg2,
      body: Column(
        children: [
          const SafeArea(bottom: false, child: SizedBox.shrink()),
          // Title bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Messages',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: kText,
                  ),
                ),
                Row(
                  children: [
                    AppIconButton(
                      icon: const Icon(
                        Icons.search,
                        color: kTextMuted,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _showAddDMDialog,
                      onLongPress: _showAddMemberDialog,
                      child: AppIconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: kTextMuted,
                          size: 18,
                        ),
                        showDot: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, color: kText),
              decoration: InputDecoration(
                hintText: 'Rechercher un message…',
                hintStyle: const TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w600, color: kTextDim),
                prefixIcon: const Icon(Icons.search, color: kTextMuted, size: 18),
                filled: true,
                fillColor: kSurface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.white.withAlpha(15), width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.white.withAlpha(15), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: kPurple, width: 1),
                ),
              ),
            ),
          ),
          // Online strip
          SizedBox(
            height: 72,
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.getMembersStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucun membre en ligne',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        color: kTextMuted,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final name = data['name'] ?? '?';
                    final initial = data['initial'] ?? name[0].toUpperCase();
                    final isOnline = data['isOnline'] ?? false;
                    final grad = _getGrad(data['colorIndex'] ?? i);

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  gradient: grad,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withAlpha(20),
                                    width: 2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  width: 9,
                                  height: 9,
                                  decoration: BoxDecoration(
                                    color: isOnline ? kGreen : kTextDim,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: kBg2, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            name,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: kTextMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Conversation list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.getFamilyChatStream(),
              builder: (context, famSnap) {
                String lastFamMsg = 'Aucun message';
                String lastFamTime = '';
                if (famSnap.hasData && famSnap.data!.docs.isNotEmpty) {
                  final data =
                      famSnap.data!.docs.first.data() as Map<String, dynamic>;
                  final text = data['text'] ?? 'Média envoyé';
                  final sender = data['senderName'] ?? 'Inconnu';
                  lastFamMsg = '$sender : $text';
                  if (data['timestamp'] != null) {
                    lastFamTime = DateFormat(
                      'HH:mm',
                    ).format((data['timestamp'] as Timestamp).toDate());
                  }
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: _db.getDirectChatsStream(),
                  builder: (context, dmSnap) {
                    if (dmSnap.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: kPurple),
                      );
                    }
                    final dmDocs = dmSnap.data?.docs ?? [];
                    final dms = dmDocs.map((doc) {
                      final d = doc.data() as Map<String, dynamic>;
                      d['id'] = doc.id;
                      return d;
                    }).toList();

                      return StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance.collection('family_info').doc('details').snapshots(),
                        builder: (context, infoSnap) {
                          final familyName = infoSnap.hasData && infoSnap.data!.exists 
                              ? (infoSnap.data!.data() as Map<String, dynamic>)['familyName'] ?? 'Notre Famille'
                              : 'Notre Famille';
                              
                          final filteredDms = _searchQuery.isEmpty 
                              ? dms 
                              : dms.where((d) => (d['name']?.toString().toLowerCase() ?? '').contains(_searchQuery)).toList();
                              
                          final familyMatch = _searchQuery.isEmpty || 
                              familyName.toLowerCase().contains(_searchQuery) || 
                              'notre famille'.contains(_searchQuery);

                          return ListView(
                            children: [
                              if (familyMatch) ...[
                                _dateSep('Aujourd\'hui'),
                                _convTile(
                                  _Conv(
                                    null,
                                    '🏠',
                                    const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [kPurple, kBlue],
                                    ),
                                    '$familyName 👨‍👩‍👧‍👦',
                                    lastFamMsg,
                                    lastFamTime,
                                    0,
                                    true,
                                    isGroup: true,
                                  ),
                                ),
                              ],
                              if (filteredDms.isNotEmpty) _dateSep('Messages directs'),
                              ...filteredDms.map((data) {
                                final timeStr = data['lastTime'] != null
                                    ? DateFormat('dd MMM').format(
                                        (data['lastTime'] as Timestamp).toDate(),
                                      )
                                  : '';
                              return _convTile(
                                _Conv(
                                  data['id'],
                                  data['initial'] ?? '?',
                                  _getGrad(data['colorIndex'] ?? 0),
                                  data['name'] ?? 'Inconnu',
                                  data['preview'] ?? '',
                                  timeStr,
                                  data['unreadCount'] ?? 0,
                                  data['isOnline'] ?? false,
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      }
                    );
                  },
                );
              },
            ),
          ),
          AppBottomNavBar(
            currentIndex: 3,
            onTap: (i) => handleNavBarTap(context, i, 3),
          ),
        ],
      ),
    );
  }

  Widget _dateSep(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: kTextDim,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _convTile(_Conv c) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatConversationScreen(
            name: c.name,
            initial: c.initial,
            gradient: c.gradient,
            chatId: c.id ?? '',
            isFamily: c.isGroup,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: c.gradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    c.initial,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: c.isOnline ? kGreen : kTextDim,
                      shape: BoxShape.circle,
                      border: Border.all(color: kBg2, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        c.name,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: kText,
                        ),
                      ),
                      Text(
                        c.time,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: kTextDim,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    c.preview,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: c.unread > 0
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: c.unread > 0 ? kText : kTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (c.unread > 0) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                height: 20,
                decoration: BoxDecoration(
                  color: c.isGroup ? kPink : kPurple,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${c.unread}',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Conv {
  final String? id;
  final String initial;
  final LinearGradient gradient;
  final String name;
  final String preview;
  final String time;
  final int unread;
  final bool isOnline;
  final bool isGroup;
  const _Conv(
    this.id,
    this.initial,
    this.gradient,
    this.name,
    this.preview,
    this.time,
    this.unread,
    this.isOnline, {
    this.isGroup = false,
  });
}
