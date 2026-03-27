import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
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

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    // Strip time for comparison
    final date = DateTime(day.year, day.month, day.day);
    return _events[date] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  DateTime? _parseDate(dynamic dateVal) {
    if (dateVal == null) return null;
    if (dateVal is Timestamp) return dateVal.toDate();
    if (dateVal is String) {
      try { return DateTime.parse(dateVal); } catch (_) { return null; }
    }
    return null;
  }

  Future<void> _showAddEventDialog(BuildContext context) async {
    final titleCtrl = TextEditingController();
    TimeOfDay startTime = const TimeOfDay(hour: 10, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 11, minute: 0);
    final selectedDate = _selectedDay ?? DateTime.now();

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
                GestureDetector(
                  onTap: () => _showAddEventDialog(context),
                  child: AppIconButton(isAccent: true, icon: const Icon(Icons.add, color: Colors.white, size: 18)),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.getEventsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final allDocs = snapshot.data!.docs;
                  _events = {};
                  for (var doc in allDocs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final date = _parseDate(data['date']);
                    if (date != null) {
                      final day = DateTime(date.year, date.month, date.day);
                      if (_events[day] == null) _events[day] = [];
                      _events[day]!.add(doc);
                    }
                  }
                }

                final selectedDayEvents = _getEventsForDay(_selectedDay ?? _focusedDay);

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    SurfaceCard(
                      padding: const EdgeInsets.all(10),
                      radius: 20,
                      child: TableCalendar(
                        locale: 'fr_FR',
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        onDaySelected: _onDaySelected,
                        onFormatChanged: (format) => setState(() => _calendarFormat = format),
                        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                        eventLoader: _getEventsForDay,
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        headerStyle: HeaderStyle(
                          formatButtonVisible: true,
                          titleCentered: true,
                          titleTextStyle: const TextStyle(fontFamily: 'Sora', color: kText, fontWeight: FontWeight.bold),
                          formatButtonDecoration: BoxDecoration(
                            color: kPurple.withAlpha(40),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          formatButtonTextStyle: const TextStyle(color: kPurpleLight, fontWeight: FontWeight.bold),
                          leftChevronIcon: const Icon(Icons.chevron_left, color: kTextMuted),
                          rightChevronIcon: const Icon(Icons.chevron_right, color: kTextMuted),
                        ),
                        calendarStyle: CalendarStyle(
                          defaultTextStyle: const TextStyle(color: kText),
                          weekendTextStyle: const TextStyle(color: kPink),
                          outsideTextStyle: const TextStyle(color: kTextDim),
                          selectedDecoration: const BoxDecoration(color: kPurple, shape: BoxShape.circle),
                          todayDecoration: BoxDecoration(color: kPurple.withAlpha(80), shape: BoxShape.circle),
                          markerDecoration: const BoxDecoration(color: kCyan, shape: BoxShape.circle),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SectionHeader(
                      title: 'Événements du ${DateFormat('dd MMMM', 'fr_FR').format(_selectedDay ?? _focusedDay)}',
                    ),
                    if (selectedDayEvents.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text('Aucun événement ce jour-là', style: TextStyle(fontFamily: 'Nunito', color: kTextMuted)),
                        ),
                      )
                    else
                      ...selectedDayEvents.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final title = data['title'] ?? 'Sans titre';
                        final time = data['time'] ?? '';
                        final colorIndex = data['colorIndex'] ?? 0;
                        final colors = [kPink, kCyan, kGreen, kOrange, kPurple];
                        final color = colors[colorIndex % colors.length];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: kSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: color.withAlpha(40), width: 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 40,
                                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title, style: const TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700, color: kText)),
                                    const SizedBox(height: 4),
                                    Text(time, style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w600, color: kTextMuted)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: kTextDim, size: 20),
                                onPressed: () => _db.deleteEvent(doc.id),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
