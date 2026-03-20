import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/common_widgets.dart';
import 'chat_conversation_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int _navIndex = 3;

  final List<_Conv> _conversations = const [
    _Conv('🏠', LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kPurple, kBlue]),
        'Famille Dubois 👨‍👩‍👧‍👦', 'Lucas : On se retrouve à 18h ?', '09:38', 3, true, isGroup: true),
    _Conv('M', LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kPink, kPurple]),
        'Marie', "J'ai partagé les photos des vacances 📸", '09:15', 1, true),
    _Conv('L', LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kCyan, kBlue]),
        'Lucas', 'Ok papa, à demain !', 'Hier', 0, false),
    _Conv('S', LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kGreen, kCyan]),
        'Sophie', 'Merci pour le gâteau 🎂❤️', 'Hier', 0, false),
    _Conv('👴', LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kOrange, kPink]),
        'Grand-père Robert', '📎 Contrat_Maison.pdf', 'Lun', 0, false),
  ];

  final List<_OnlinePerson> _online = const [
    _OnlinePerson('M', LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kPink, kPurple]), 'Marie', true),
    _OnlinePerson('A', LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kPurple, kBlue]), 'Admin', true),
    _OnlinePerson('L', LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kCyan, kBlue]), 'Lucas', false),
    _OnlinePerson('S', LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kGreen, kCyan]), 'Sophie', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg2,
      body: Column(
        children: [
          const SafeArea(
            bottom: false,
            child: SizedBox.shrink(),
          ),
          // Title bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Messages', style: TextStyle(fontFamily: 'Sora', fontSize: 22, fontWeight: FontWeight.w700, color: kText)),
                Row(
                  children: [
                    AppIconButton(icon: const Icon(Icons.search, color: kTextMuted, size: 18)),
                    const SizedBox(width: 8),
                    AppIconButton(icon: const Icon(Icons.edit_outlined, color: kTextMuted, size: 18), showDot: true),
                  ],
                ),
              ],
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withAlpha(15), width: 1),
              ),
              child: Row(
                children: const [
                  Icon(Icons.search, color: kTextMuted, size: 16),
                  SizedBox(width: 10),
                  Text('Rechercher un message…',
                      style: TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w600, color: kTextDim)),
                ],
              ),
            ),
          ),
          // Online strip
          SizedBox(
            height: 72,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              itemCount: _online.length,
              itemBuilder: (context, i) {
                final o = _online[i];
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
                              gradient: o.gradient,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withAlpha(20), width: 2),
                            ),
                            alignment: Alignment.center,
                            child: Text(o.initial, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                color: o.isOnline ? kGreen : kTextDim,
                                shape: BoxShape.circle,
                                border: Border.all(color: kBg2, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(o.name, style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w700, color: kTextMuted)),
                    ],
                  ),
                );
              },
            ),
          ),
          // Conversation list
          Expanded(
            child: ListView(
              children: [
                _dateSep('Aujourd\'hui'),
                ..._conversations.take(2).map((c) => _convTile(c)),
                _dateSep('Hier'),
                ..._conversations.skip(2).take(2).map((c) => _convTile(c)),
                _dateSep('Cette semaine'),
                ..._conversations.skip(4).map((c) => _convTile(c)),
              ],
            ),
          ),
          AppBottomNavBar(currentIndex: _navIndex, onTap: (i) {
            if (i == 0) Navigator.pop(context);
          }),
        ],
      ),
    );
  }

  Widget _dateSep(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Text(label,
          style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w800, color: kTextDim, letterSpacing: 1)),
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
                  child: Text(c.initial,
                      style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white)),
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
                      Text(c.name,
                          style: const TextStyle(fontFamily: 'Nunito', fontSize: 15, fontWeight: FontWeight.w800, color: kText)),
                      Text(c.time,
                          style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w600, color: kTextDim)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    c.preview,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: c.unread > 0 ? FontWeight.w700 : FontWeight.w600,
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
                child: Text('${c.unread}',
                    style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Conv {
  final String initial;
  final LinearGradient gradient;
  final String name;
  final String preview;
  final String time;
  final int unread;
  final bool isOnline;
  final bool isGroup;
  const _Conv(this.initial, this.gradient, this.name, this.preview, this.time, this.unread, this.isOnline, {this.isGroup = false});
}

class _OnlinePerson {
  final String initial;
  final LinearGradient gradient;
  final String name;
  final bool isOnline;
  const _OnlinePerson(this.initial, this.gradient, this.name, this.isOnline);
}
