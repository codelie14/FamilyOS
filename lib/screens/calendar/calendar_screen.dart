import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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

  late DateTime _currentMonth;
  int? _selectedDay;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _selectedDay = DateTime.now().day;
  }

  Color _getColor(int index) {
    const list = [kPink, kCyan, kGreen, kOrange, kPurple];
    return list[index % list.length];
  }

  void _prevMonth() => setState(() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    _selectedDay = null;
  });

  void _nextMonth() => setState(() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    _selectedDay = null;
  });

  /// Returns list of days in the current month grid (including leading/trailing nulls)
  List<int?> _buildDayGrid() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;

    // weekday: Mon=1 ... Sun=7
    final startOffset = (firstDay.weekday - 1); // 0-based, Mon=0
    final total = ((startOffset + daysInMonth + 6) ~/ 7) * 7;
    return List.generate(total, (i) {
      final d = i - startOffset + 1;
      return (d >= 1 && d <= daysInMonth) ? d : null;
    });
  }

  Future<void> _showAddEventDialog(BuildContext context) async {
    final titleCtrl = TextEditingController();
    TimeOfDay startTime = const TimeOfDay(hour: 10, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 11, minute: 0);
    final selectedDate = _selectedDay != null
        ? DateTime(_currentMonth.year, _currentMonth.month, _selectedDay!)
        : DateTime.now();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          backgroundColor: kSurface,
          title: const Text('Nouvel événement', style: TextStyle(fontFamily: 'Sora', color: kText)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: kText),
                decoration: InputDecoration(
                  hintText: 'Titre de l\'événement',
                  hintStyle: const TextStyle(color: kTextMuted),
                  filled: true,
                  fillColor: kSurface2,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(context: ctx, initialTime: startTime,
                            builder: (c, child) => Theme(data: ThemeData.dark(), child: child!));
                        if (picked != null) setStateDialog(() => startTime = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(10)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('DÉBUT', style: TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w800, color: kTextMuted)),
                          const SizedBox(height: 2),
                          Text(startTime.format(ctx), style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w700, color: kText)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(context: ctx, initialTime: endTime,
                            builder: (c, child) => Theme(data: ThemeData.dark(), child: child!));
                        if (picked != null) setStateDialog(() => endTime = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(10)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('FIN', style: TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w800, color: kTextMuted)),
                          const SizedBox(height: 2),
                          Text(endTime.format(ctx), style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w700, color: kText)),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            TextButton(
              onPressed: () {
                if (titleCtrl.text.isNotEmpty) {
                  final timeStr = '${startTime.format(ctx)} – ${endTime.format(ctx)}';
                  _db.addEvent({
                    'title': titleCtrl.text.trim(),
                    'time': timeStr,
                    'date': Timestamp.fromDate(selectedDate),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = _buildDayGrid();
    final monthLabel = DateFormat('MMMM yyyy', 'fr_FR').format(_currentMonth);

    return Scaffold(
      backgroundColor: kBg2,
      body: Column(
        children: [
          const SafeArea(bottom: false, child: SizedBox.shrink()),
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
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.getEventsStream(),
              builder: (context, snapshot) {
                final allDocs = snapshot.data?.docs ?? [];

                // Build set of days that have events in this month
                final eventDays = <int>{};
                for (final doc in allDocs) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (data['date'] != null) {
                    final dt = (data['date'] as Timestamp).toDate();
                    if (dt.year == _currentMonth.year && dt.month == _currentMonth.month) {
                      eventDays.add(dt.day);
                    }
                  }
                }

                // Filter events by selected day (or all if none selected)
                List<QueryDocumentSnapshot> filteredDocs;
                if (_selectedDay != null) {
                  filteredDocs = allDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (data['date'] == null) return false;
                    final dt = (data['date'] as Timestamp).toDate();
                    return dt.year == _currentMonth.year && dt.month == _currentMonth.month && dt.day == _selectedDay;
                  }).toList();
                } else {
                  filteredDocs = allDocs;
                }

                return ListView(
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
                              Text(
                                monthLabel[0].toUpperCase() + monthLabel.substring(1),
                                style: const TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w700, color: kText),
                              ),
                              Row(children: [
                                _calNavBtn(Icons.chevron_left, _prevMonth),
                                const SizedBox(width: 6),
                                _calNavBtn(Icons.chevron_right, _nextMonth),
                              ]),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // Day headers
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
                                .map((d) => Expanded(
                                    child: Center(
                                        child: Text(d,
                                            style: const TextStyle(
                                                fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w800, color: kTextDim)))))
                                .toList(),
                          ),
                          const SizedBox(height: 8),
                          // Calendar grid
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 7,
                            childAspectRatio: 0.9,
                            mainAxisSpacing: 2,
                            children: days.map((d) {
                              if (d == null) return const SizedBox();
                              final isToday = _currentMonth.year == today.year &&
                                  _currentMonth.month == today.month &&
                                  d == today.day;
                              final isSelected = d == _selectedDay;
                              final hasEvent = eventDays.contains(d);

                              return GestureDetector(
                                onTap: () => setState(() => _selectedDay = _selectedDay == d ? null : d),
                                child: Container(
                                  height: 34,
                                  margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 1),
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
                                  child: Stack(
                                    alignment: Alignment.center,
                                    clipBehavior: Clip.none,
                                    children: [
                                      Text(
                                        '$d',
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
                                            width: 4, height: 4,
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
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SectionHeader(
                      title: _selectedDay != null
                          ? 'Événements du ${_selectedDay} ${DateFormat('MMMM').format(_currentMonth)}'
                          : 'Tous les événements',
                      action: _selectedDay != null ? 'Tout voir' : null,
                      onActionTap: () => setState(() => _selectedDay = null),
                    ),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Center(child: CircularProgressIndicator(color: kPurple))
                    else if (filteredDocs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text('Aucun événement', style: TextStyle(color: kTextMuted, fontFamily: 'Nunito')),
                      )
                    else
                      ...filteredDocs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final color = _getColor(data['colorIndex'] ?? 0);
                        final title = data['title'] ?? 'Sans nom';
                        final time = data['time'] ?? 'Heure inconnue';
                        final tagsRaw = data['tags'] as List<dynamic>? ?? [];
                        final tags = tagsRaw.map((e) => e.toString()).toList();
                        final dateStr = data['date'] != null
                            ? DateFormat('EEE d MMM', 'fr_FR').format((data['date'] as Timestamp).toDate())
                            : '';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Dismissible(
                            key: Key(doc.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: kRed.withAlpha(51),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.delete_outline, color: kRed),
                            ),
                            confirmDismiss: (_) async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  backgroundColor: kSurface,
                                  title: const Text('Supprimer cet événement ?', style: TextStyle(fontFamily: 'Sora', color: kText)),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annuler')),
                                    TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Supprimer', style: TextStyle(color: kRed))),
                                  ],
                                ),
                              );
                              return confirm ?? false;
                            },
                            onDismissed: (_) => _db.deleteEvent(doc.id),
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
                                        Text(title, style: const TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w700, color: kText)),
                                        const SizedBox(height: 4),
                                        Row(children: [
                                          if (dateStr.isNotEmpty) ...[
                                            const Icon(Icons.calendar_today_outlined, size: 12, color: kTextDim),
                                            const SizedBox(width: 4),
                                            Text('$dateStr · ', style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, color: kTextMuted)),
                                          ],
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
                          ),
                        );
                      }),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
          AppBottomNavBar(currentIndex: 2, onTap: (i) => handleNavBarTap(context, i, 2)),
        ],
      ),
    );
  }

  Widget _calNavBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: kTextMuted, size: 14),
      ),
    );
  }
}
