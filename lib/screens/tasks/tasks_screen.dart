import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/common_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final FirestoreService _db = FirestoreService();
  int _filter = 0;
  final filters = ['Toutes', 'En cours', 'Terminées'];

  void _showAddTaskDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text('Nouvelle tâche', style: TextStyle(fontFamily: 'Sora', color: kText)),
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
                _db.addTask({
                  'title': titleCtrl.text.trim(),
                  'done': false,
                  'priority': 'med',
                  'assignee': 'A',
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
          const SafeArea(
            bottom: false,
            child: SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tâches', style: TextStyle(fontFamily: 'Sora', fontSize: 22, fontWeight: FontWeight.w700, color: kText)),
                GestureDetector(
                  onTap: () => _showAddTaskDialog(context),
                  child: AppIconButton(isAccent: true, icon: const Icon(Icons.add, color: Colors.white, size: 18))
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.getTasksStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: kPurple));
                }
                final docs = snapshot.data?.docs ?? [];
                final tasks = docs.map((d) {
                  final data = d.data() as Map<String, dynamic>;
                  return _Task(
                    d.id,
                    data['title'] ?? 'Sans nom',
                    data['date'],
                    data['assignee'] ?? '?',
                    _getGrad(data['assignee']),
                    data['priority'] == 'high' ? _Priority.high : (data['priority'] == 'low' ? _Priority.low : _Priority.med),
                    data['done'] ?? false,
                  );
                }).toList();

                // Apply filter
                var filtered = tasks;
                if (_filter == 1) filtered = tasks.where((t) => !t.done).toList();
                if (_filter == 2) filtered = tasks.where((t) => t.done).toList();

                final total = tasks.length;
                final completed = tasks.where((t) => t.done).length;
                final progress = total == 0 ? 0.0 : completed / total;
                final percent = (progress * 100).toInt();

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Progress card
                    SurfaceCard(
                      padding: const EdgeInsets.all(18),
                      radius: 18,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 5,
                                  backgroundColor: kSurface2,
                                  valueColor: const AlwaysStoppedAnimation<Color>(kPurple),
                                ),
                                Text('$percent%', style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w800, color: kText)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Aperçu global', style: TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w700, color: kTextMuted)),
                              const SizedBox(height: 4),
                              Text('$completed / $total tâches', style: const TextStyle(fontFamily: 'Nunito', fontSize: 20, fontWeight: FontWeight.w900, color: kText)),
                              const SizedBox(height: 2),
                              if (completed > 0)
                                const Text("En bonne voie !", style: TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w700, color: kGreen)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Filter tabs
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: filters.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (ctx, i) => GestureDetector(
                          onTap: () => setState(() => _filter = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                            decoration: i == _filter
                                ? BoxDecoration(gradient: kGradMain, borderRadius: BorderRadius.circular(20))
                                : BoxDecoration(
                                    color: kSurface,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withAlpha(12), width: 1),
                                  ),
                            child: Text(filters[i],
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: i == _filter ? Colors.white : kTextMuted,
                                )),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (filtered.where((t) => !t.done).isNotEmpty) ...[
                      const SectionHeader(title: 'En cours'),
                      ...filtered.where((t) => !t.done).map((t) => _taskTile(t)),
                    ],
                    const SizedBox(height: 8),
                    if (filtered.where((t) => t.done).isNotEmpty) ...[
                      const SectionHeader(title: 'Terminées'),
                      ...filtered.where((t) => t.done).map((t) => Opacity(opacity: 0.65, child: _taskTile(t))),
                    ],
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
          AppBottomNavBar(currentIndex: 0, onTap: (i) => handleNavBarTap(context, i, 0)),
        ],
      ),
    );
  }

  Widget _taskTile(_Task t) {
    final (color, label) = switch (t.priority) {
      _Priority.high => (kRed, 'Urgent'),
      _Priority.med => (kOrange, 'Moyen'),
      _Priority.low => (kGreen, 'Normal'),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SurfaceCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _db.toggleTaskStatus(t.id, !t.done),
              child: Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(top: 1),
                decoration: t.done
                    ? BoxDecoration(gradient: kGradGreen, borderRadius: BorderRadius.circular(7))
                    : BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: Colors.white.withAlpha(38), width: 2),
                      ),
                alignment: Alignment.center,
                child: t.done ? const Icon(Icons.check, color: Colors.white, size: 12) : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.title,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: t.done ? kTextDim : kText,
                      decoration: t.done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (t.date != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 11, color: kTextDim),
                            const SizedBox(width: 4),
                            Text(t.date!, style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w600, color: kTextMuted)),
                          ],
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(gradient: t.assigneeGrad, borderRadius: BorderRadius.circular(5)),
                            alignment: Alignment.center,
                            child: Text(t.assignee, style: const TextStyle(fontFamily: 'Nunito', fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: color.withAlpha(38), borderRadius: BorderRadius.circular(20)),
                        child: Text(label, style: TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w800, color: color)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _Priority { high, med, low }

LinearGradient _getGrad(String? assignee) {
  if (assignee == 'M') return kGradPink;
  if (assignee == 'L') return kGradCyan;
  if (assignee == 'S') return kGradGreen;
  return kGradMain;
}

class _Task {
  final String id;
  final String title;
  final String? date;
  final String assignee;
  final LinearGradient assigneeGrad;
  final _Priority priority;
  final bool done;
  _Task(this.id, this.title, this.date, this.assignee, this.assigneeGrad, this.priority, this.done);
}
