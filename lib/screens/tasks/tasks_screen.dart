import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/common_widgets.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int _filter = 0;
  final filters = ['Toutes', 'En cours', 'Terminées', 'Marie', 'Lucas'];

  final _tasks = [
    _Task("Préparer le gâteau d'anniversaire 🎂", '24 Mars', 'A', kGradMain, _Priority.high, false),
    _Task('Réserver le restaurant pour 6 personnes', '22 Mars', 'M', kGradPink, _Priority.med, false),
    _Task('Acheter les décorations 🎈', '23 Mars', 'L', kGradCyan, _Priority.low, false),
    _Task('Faire les courses', null, 'S', kGradGreen, _Priority.low, true),
    _Task('Envoyer les invitations', null, 'M', kGradPink, _Priority.med, true),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tâches', style: TextStyle(fontFamily: 'Sora', fontSize: 22, fontWeight: FontWeight.w700, color: kText)),
                AppIconButton(isAccent: true, icon: const Icon(Icons.add, color: Colors.white, size: 18)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
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
                              value: 0.7,
                              strokeWidth: 5,
                              backgroundColor: kSurface2,
                              valueColor: const AlwaysStoppedAnimation<Color>(kPurple),
                            ),
                            const Text('70%', style: TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w800, color: kText)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Cette semaine', style: TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w700, color: kTextMuted)),
                          SizedBox(height: 4),
                          Text('7 / 10 tâches', style: TextStyle(fontFamily: 'Nunito', fontSize: 20, fontWeight: FontWeight.w900, color: kText)),
                          SizedBox(height: 2),
                          Text("↑ 3 terminées aujourd'hui", style: TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w700, color: kGreen)),
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
                const SectionHeader(title: 'En cours'),
                ..._tasks.where((t) => !t.done).map((t) => _taskTile(t)),
                const SizedBox(height: 8),
                const SectionHeader(title: 'Terminées'),
                ..._tasks.where((t) => t.done).map((t) => Opacity(opacity: 0.65, child: _taskTile(t))),
                const SizedBox(height: 20),
              ],
            ),
          ),
          AppBottomNavBar(currentIndex: 0, onTap: (i) {
            if (i == 0) Navigator.pop(context);
          }),
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
              onTap: () => setState(() => t.done = !t.done),
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

class _Task {
  final String title;
  final String? date;
  final String assignee;
  final LinearGradient assigneeGrad;
  final _Priority priority;
  bool done;
  _Task(this.title, this.date, this.assignee, this.assigneeGrad, this.priority, this.done);
}
