import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/common_widgets.dart';
import '../../services/firestore_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final FirestoreService _db = FirestoreService();

  void _showAddEventDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text('Nouvel événement', style: TextStyle(fontFamily: 'Sora', color: kText)),
        content: TextField(
          controller: titleCtrl,
          style: const TextStyle(color: kText),
          decoration: const InputDecoration(hintText: 'Titre...', hintStyle: TextStyle(color: kTextMuted)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                _db.addEvent({
                  'title': titleCtrl.text.trim(),
                  'time': '10:00 – 11:00', // mocked for now
                  'tags': ['Famille'],
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

  Color _getColor(int index) {
    const list = [kPink, kCyan, kGreen, kOrange, kPurple];
    return list[index % list.length];
  }

  @override
  Widget build(BuildContext context) {
    final days = [
      ('L', null), ('M', null), ('M', null), ('J', null), ('V', null), ('S', null), ('D', null),
    ];
    const rows = [
      ['', '', '', '', '', '1', '2'],
      ['3', '4', '5', '6', '7', '8*', '9'],
      ['10', '11', '12', '13', '14*', '15', '16'],
      ['17', '18', '19', '20T*', '21', '22', '23'],
      ['24S*', '25', '26', '27', '28*', '29', '30'],
      ['31', '', '', '', '', '', ''],
    ];

    return Scaffold(
      backgroundColor: kBg2,
      body: Column(
        children: [
          const SafeArea(
            bottom: false,
            child: SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Agenda', style: TextStyle(fontFamily: 'Sora', fontSize: 22, fontWeight: FontWeight.w700, color: kText)),
                Row(children: [
                  AppIconButton(icon: const Icon(Icons.calendar_month_outlined, color: kTextMuted, size: 18)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showAddEventDialog(context),
                    child: AppIconButton(isAccent: true, icon: const Icon(Icons.add, color: Colors.white, size: 18)),
                  ),
                ]),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Mini calendar
                SurfaceCard(
                  padding: const EdgeInsets.all(16),
                  radius: 18,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Mars 2026', style: TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
                          Row(children: [
                            _calNavBtn(Icons.chevron_left),
                            const SizedBox(width: 6),
                            _calNavBtn(Icons.chevron_right),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Day headers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
                            .map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w800, color: kTextDim)))))
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      // Calendar grid
                      ...rows.map((row) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: row.map((d) {
                          final isToday = d.contains('T');
                          final isSelected = d.contains('S') && !d.contains('T');
                          final hasEvent = d.contains('*');
                          final label = d.replaceAll(RegExp(r'[TS*]'), '');
                          return Expanded(
                            child: Container(
                              height: 34,
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              decoration: isToday
                                  ? BoxDecoration(gradient: kGradMain, borderRadius: BorderRadius.circular(10))
                                  : isSelected
                                      ? BoxDecoration(
                                          color: kPurple.withAlpha(38),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: kPurple.withAlpha(64), width: 1),
                                        )
                                      : null,
                              alignment: Alignment.center,
                              child: label.isEmpty
                                  ? const SizedBox()
                                  : Stack(
                                      alignment: Alignment.center,
                                      clipBehavior: Clip.none,
                                      children: [
                                        Text(
                                          label,
                                          style: TextStyle(
                                            fontFamily: 'Nunito',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: isToday ? Colors.white : isSelected ? kPurpleLight : kTextMuted,
                                          ),
                                        ),
                                        if (hasEvent)
                                          Positioned(
                                            bottom: -4,
                                            child: Container(
                                              width: 4,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color: isToday ? Colors.white60 : kPink,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                            ),
                          );
                        }).toList(),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Prochains événements'),
                StreamBuilder<QuerySnapshot>(
                  stream: _db.getEventsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: kPurple));
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text('Aucun événement', style: TextStyle(color: kTextMuted, fontFamily: 'Nunito')),
                      );
                    }
                    return Column(
                      children: docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final color = _getColor(data['colorIndex'] ?? 0);
                        final title = data['title'] ?? 'Sans nom';
                        final time = data['time'] ?? 'Heure inconnue';
                        final tagsRaw = data['tags'] as List<dynamic>? ?? [];
                        final tags = tagsRaw.map((e) => e.toString()).toList();
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SurfaceCard(
                            padding: const EdgeInsets.all(14),
                            radius: 14,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: 4, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10))),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(title, style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w800, color: kText)),
                                      const SizedBox(height: 4),
                                      Row(children: [
                                        const Icon(Icons.access_time_outlined, size: 12, color: kTextDim),
                                        const SizedBox(width: 4),
                                        Text(time, style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w600, color: kTextMuted)),
                                      ]),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        children: tags.map((tag) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: color.withAlpha(38),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(tag, style: TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w700, color: color)),
                                        )).toList(),
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
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          AppBottomNavBar(currentIndex: 2, onTap: (i) => handleNavBarTap(context, i, 2)),
        ],
      ),
    );
  }

  static Widget _calNavBtn(IconData icon) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: kTextMuted, size: 14),
    );
  }
}
