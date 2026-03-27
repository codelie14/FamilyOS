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
import '../location/location_screen.dart';
import '../profile/members_management_screen.dart';
import '../../services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';

// ─── Model helpers ────────────────────────────────────────────────────────────
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
  String _userRole = 'member';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _updateFCMToken();
  }

  Future<void> _updateFCMToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await NotificationService.getToken();
      if (token != null) {
        await _db.updateFCMToken(user.uid, token);
      }
    }
  }

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final data = await _db.getUserData(user.uid);
      if (data != null && mounted) {
        setState(() {
          _userRole = data['role'] ?? 'member';
        });
      }
    }
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
        colors: [kPurple, kBlue],
      ),
    ];
    return list[index % list.length];
  }

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
                SectionHeader(
                  title: 'Membres',
                  action: _userRole == 'admin' ? 'Gérer' : null,
                  onActionTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MembersManagementScreen(),
                      ),
                    );
                  },
                ),
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
          AppBottomNavBar(
            currentIndex: 0,
            onTap: (i) => handleNavBarTap(context, i, 0),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return const SafeArea(bottom: false, child: SizedBox.shrink());
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
                BoxShadow(
                  color: kPurple.withAlpha(100),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset('assets/images/logo.png', width: 22, height: 22),
          ),
          const SizedBox(width: 10),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: kText,
              ),
              children: [
                TextSpan(text: 'Family'),
                TextSpan(
                  text: 'OS',
                  style: TextStyle(color: kCyan),
                ),
              ],
            ),
          ),
          const Spacer(),
          AppIconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: kTextMuted,
              size: 18,
            ),
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
            child: const Text(
              'A',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
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
          BoxShadow(
            color: kPurple.withAlpha(64),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
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
              const Text(
                'Bonjour 👋',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('family_info')
                    .doc('details')
                    .snapshots(),
                builder: (context, snap) {
                  final familyName = snap.hasData && snap.data!.exists
                      ? (snap.data!.data()
                                as Map<String, dynamic>)['familyName'] ??
                            'Notre Famille'
                      : 'Notre Famille';
                  return Text(
                    familyName,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: _db.getMembersStream(),
                    builder: (context, snap) {
                      final count = snap.hasData ? snap.data!.docs.length : 0;
                      return _HeroStat(
                        value: count.toString(),
                        label: 'Membres',
                      );
                    },
                  ),
                  _heroDivider(),
                  StreamBuilder<QuerySnapshot>(
                    stream: _db.getEventsStream(),
                    builder: (context, snap) {
                      final count = snap.hasData ? snap.data!.docs.length : 0;
                      return _HeroStat(
                        value: count.toString(),
                        label: 'Événements',
                      );
                    },
                  ),
                  _heroDivider(),
                  StreamBuilder<QuerySnapshot>(
                    stream: _db.getTasksStream(),
                    builder: (context, snap) {
                      final count = snap.hasData ? snap.data!.docs.length : 0;
                      return _HeroStat(
                        value: count.toString(),
                        label: 'Tâches',
                      );
                    },
                  ),
                  _heroDivider(),
                  StreamBuilder<QuerySnapshot>(
                    stream: _db.getGalleryStream(),
                    builder: (context, snap) {
                      final count = snap.hasData ? snap.data!.docs.length : 0;
                      return _HeroStat(
                        value: count.toString(),
                        label: 'Fichiers',
                      );
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
      child: StreamBuilder<QuerySnapshot>(
        stream: _db.getMembersStream(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          return ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = data['name'] ?? '?';
                final initial = data['initial'] ?? name[0].toUpperCase();
                final isOnline = data['isOnline'] ?? false;
                final grad = _getGrad(data['colorIndex'] ?? 0);

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      MemberAvatar(
                        initials: initial,
                        gradient: grad,
                        isOnline: isOnline,
                      ),
                      const SizedBox(height: 6),
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
              }),
              // Add member placeholder
              Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withAlpha(30),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(Icons.add, color: kTextDim, size: 20),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Ajouter',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: kTextMuted,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
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
              case 0:
                screen = const ChatListScreen();
                break;
              case 1:
                screen = const GalleryScreen();
                break;
              case 2:
                screen = const CalendarScreen();
                break;
              case 3:
                screen = const TasksScreen();
                break;
              case 4:
                screen = const VaultScreen();
                break;
              case 5:
                screen = const FilesScreen();
                break;
              case 6:
                screen = const NotesScreen();
                break;
              case 7:
                screen = const LocationScreen();
                break;
            }
            if (screen != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => screen!),
              );
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
  }

  Widget _buildEventCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.getEventsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "Aucun événement prévu",
              style: TextStyle(fontFamily: 'Nunito', color: kTextMuted),
            ),
          );
        }
        final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final title = data['title'] ?? 'Sans nom';
        final time = data['time'] ?? 'Heure non définie';
        final grad = _getGrad(data['colorIndex'] ?? 0);

        return SurfaceCard(
          padding: const EdgeInsets.all(16),
          radius: 16,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: grad,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Bientôt',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: kText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_outlined,
                          size: 12,
                          color: kTextDim,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: kTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _miniAvatars(),
            ],
          ),
        );
      },
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
              child: Text(
                initials[i],
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
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
            child: Text(
              'Aucune activité récente',
              style: TextStyle(fontFamily: 'Nunito', color: kTextMuted),
            ),
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
                      child: const Icon(
                        Icons.chat_bubble_outline,
                        color: kPurple,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$sender a envoyé un message',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: kText,
                            ),
                          ),
                          Text(
                            text,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: kTextMuted,
                            ),
                          ),
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
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }
}
