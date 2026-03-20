import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/common_widgets.dart';
import '../chat/chat_list_screen.dart';
import '../files/files_screen.dart';
import '../gallery/gallery_screen.dart';
import '../calendar/calendar_screen.dart';
import '../tasks/tasks_screen.dart';
import '../vault/vault_screen.dart';
import '../notes/notes_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
// ─── Model helpers ────────────────────────────────────────────────────────────
class _Member {
  final String initials;
  final LinearGradient gradient;
  final bool isOnline;
  final String name;
  const _Member(this.initials, this.gradient, this.isOnline, this.name);
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color tint;
  const _QuickAction(this.icon, this.label, this.tint);
}

// ─── Screen ──────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _db = FirestoreService();

  final List<_Member> _members = const [
    _Member('A', LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kPurple, kBlue]), true, 'Admin'),
    _Member('M', LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kPink, kPurple]), true, 'Marie'),
    _Member('L', LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kCyan, kBlue]), false, 'Lucas'),
    _Member('S', LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kGreen, kCyan]), false, 'Sophie'),
  ];

  final List<_QuickAction> _actions = const [
    _QuickAction(Icons.chat_bubble_outline, 'Chat', kPurple),
    _QuickAction(Icons.photo_library_outlined, 'Galerie', kPink),
    _QuickAction(Icons.calendar_month_outlined, 'Agenda', kCyan),
    _QuickAction(Icons.check_box_outlined, 'Tâches', kGreen),
    _QuickAction(Icons.lock_outline, 'Coffre', kOrange),
    _QuickAction(Icons.folder_outlined, 'Fichiers', kBlue),
    _QuickAction(Icons.note_outlined, 'Notes', kPurple),
    _QuickAction(Icons.location_on_outlined, 'Localisation', kPink),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg2,
      body: Column(
        children: [
          _buildStatusBar(),
          _buildTopBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildHeroCard(),
                const SizedBox(height: 20),
                SectionHeader(title: 'Membres', action: 'Gérer'),
                _buildMembersRow(),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Accès rapide'),
                _buildQuickGrid(),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Prochain événement'),
                _buildEventCard(),
                const SizedBox(height: 20),
                SectionHeader(title: 'Activité récente', action: 'Tout voir'),
                _buildActivityList(),
                const SizedBox(height: 20),
              ],
            ),
          ),
          AppBottomNavBar(currentIndex: 0, onTap: (i) => handleNavBarTap(context, i, 0)),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return const SafeArea(
      bottom: false,
      child: SizedBox.shrink(),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
      child: Row(
        children: [
          // Logo
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: kGradMain,
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(color: kPurple.withAlpha(100), blurRadius: 14, offset: const Offset(0, 4)),
              ],
            ),
            child: Image.asset('assets/images/logo.png', width: 22, height: 22),
          ),
          const SizedBox(width: 10),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontFamily: 'Sora', fontSize: 19, fontWeight: FontWeight.w700, color: kText),
              children: [
                TextSpan(text: 'Family'),
                TextSpan(text: 'OS', style: TextStyle(color: kCyan)),
              ],
            ),
          ),
          const Spacer(),
          AppIconButton(
            icon: const Icon(Icons.notifications_outlined, color: kTextMuted, size: 18),
            showDot: true,
          ),
          const SizedBox(width: 8),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: kGradMain,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withAlpha(38), width: 2),
            ),
            alignment: Alignment.center,
            child: const Text('A', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: kGradMain,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: kPurple.withAlpha(64), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          // Decorative orbs
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(20),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: 40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(12),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bonjour 👋',
                  style: TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white70)),
              const SizedBox(height: 4),
              const Text('Famille Dubois',
                  style: TextStyle(fontFamily: 'Sora', fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 14),
              Row(
                children: [
                  _HeroStat(value: '4', label: 'Membres'),
                  _heroDivider(),
                  _HeroStat(value: '3', label: 'Événements'),
                  _heroDivider(),
                  StreamBuilder<QuerySnapshot>(
                    stream: _db.getTasksStream(),
                    builder: (context, snap) {
                      final count = snap.hasData ? snap.data!.docs.length : 0;
                      return _HeroStat(value: count.toString(), label: 'Tâches');
                    },
                  ),
                  _heroDivider(),
                  StreamBuilder<QuerySnapshot>(
                    stream: _db.getGalleryStream(),
                    builder: (context, snap) {
                      final count = snap.hasData ? snap.data!.docs.length : 0;
                      return _HeroStat(value: count.toString(), label: 'Fichiers');
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroDivider() => Container(
        width: 1,
        height: 36,
        color: Colors.white.withAlpha(51),
        margin: const EdgeInsets.symmetric(horizontal: 14),
      );

  Widget _buildMembersRow() {
    return SizedBox(
      height: 84,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ..._members.map((m) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    MemberAvatar(
                      initials: m.initials,
                      gradient: m.gradient,
                      isOnline: m.isOnline,
                    ),
                    const SizedBox(height: 6),
                    Text(m.name,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: kTextMuted,
                        )),
                  ],
                ),
              )),
          // Add member
          Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withAlpha(30), width: 1.5),
                ),
                child: const Icon(Icons.add, color: kTextDim, size: 20),
              ),
              const SizedBox(height: 6),
              const Text('Ajouter',
                  style: TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w700, color: kTextMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, i) {
        final a = _actions[i];
        return GestureDetector(
          onTap: () {
            Widget? screen;
            switch (i) {
              case 0: screen = const ChatListScreen(); break;
              case 1: screen = const GalleryScreen(); break;
              case 2: screen = const CalendarScreen(); break;
              case 3: screen = const TasksScreen(); break;
              case 4: screen = const VaultScreen(); break;
              case 5: screen = const FilesScreen(); break;
              case 6: screen = const NotesScreen(); break;
              case 7: // Localisation not implemented
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bientôt disponible !')));
                break;
            }
            if (screen != null) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
            }
          },
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: a.tint.withAlpha(38),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: a.tint.withAlpha(51), width: 1),
                ),
                child: Icon(a.icon, color: a.tint, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                a.label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w700, color: kTextMuted),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventCard() {
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      radius: 16,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(gradient: kGradMain, borderRadius: BorderRadius.circular(12)),
            child: const Column(
              children: [
                Text('24', style: TextStyle(fontFamily: 'Nunito', fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, height: 1)),
                Text('MARS', style: TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Anniversaire de Sophie 🎂',
                    style: TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w800, color: kText)),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time_outlined, size: 12, color: kTextDim),
                    SizedBox(width: 4),
                    Text('18:00 • Restaurant',
                        style: TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w600, color: kTextMuted)),
                  ],
                ),
              ],
            ),
          ),
          _miniAvatars(),
        ],
      ),
    );
  }

  Widget _miniAvatars() {
    final gradients = [kGradMain, kGradPink, kGradCyan];
    final initials = ['A', 'M', 'L'];
    return SizedBox(
      width: 48,
      height: 26,
      child: Stack(
        children: List.generate(initials.length, (i) {
          return Positioned(
            left: i * 12.0,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                gradient: gradients[i],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kSurface, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(initials[i],
                  style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActivityList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.getFamilyChatStream(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Text('Aucune activité récente', style: TextStyle(fontFamily: 'Nunito', color: kTextMuted)),
          );
        }
        final docs = snap.data!.docs.take(3).toList();
        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final sender = data['senderName'] ?? 'Membre';
            final text = data['text'] ?? 'A partagé une photo';
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SurfaceCard(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: kPurple.withAlpha(38),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.chat_bubble_outline, color: kPurple, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$sender a envoyé un message',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w800, color: kText)),
                          Text(text,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w600, color: kTextMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontFamily: 'Nunito', fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
        Text(label,
            style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white60)),
      ],
    );
  }
}
