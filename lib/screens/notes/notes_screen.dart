import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/common_widgets.dart';
import '../../services/firestore_service.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final FirestoreService _db = FirestoreService();

  void _showAddNoteDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text('Nouvelle note', style: TextStyle(fontFamily: 'Sora', color: kText)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              style: const TextStyle(color: kText),
              decoration: const InputDecoration(hintText: 'Titre', hintStyle: TextStyle(color: kTextMuted)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contentCtrl,
              style: const TextStyle(color: kText),
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Contenu...', hintStyle: TextStyle(color: kTextMuted)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                _db.addNote({
                  'title': titleCtrl.text.trim(),
                  'content': contentCtrl.text.trim(),
                  'pinned': false,
                  'colorIndex': DateTime.now().millisecond % 4, // random color
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

  Widget _noteCard(String date, String title, String preview, List<Color> colors, bool wide) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.white10,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(date, style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white54)),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 6),
              Text(preview, maxLines: wide ? 2 : 3, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70, height: 1.5)),
            ],
          ),
        ],
      ),
    );
  }

  List<Color> _getColor(int index) {
    const palettes = [
      [kPurple, kBlue],
      [kPink, kPurple],
      [kCyan, kBlue],
      [kGreen, kCyan],
      [kOrange, kPink],
    ];
    return palettes[index % palettes.length];
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
                const Text('Notes', style: TextStyle(fontFamily: 'Sora', fontSize: 22, fontWeight: FontWeight.w700, color: kText)),
                Row(children: [
                  AppIconButton(icon: const Icon(Icons.search, color: kTextMuted, size: 18)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showAddNoteDialog(context),
                    child: AppIconButton(isAccent: true, icon: const Icon(Icons.add, color: Colors.white, size: 18)),
                  ),
                ]),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.getNotesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: kPurple));
                }
                
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('Aucune note', style: TextStyle(color: kTextMuted)));
                }

                // Simple pinned/recent split (if we had pinned logic)
                final pinned = docs.where((d) => (d.data() as Map<String, dynamic>)['pinned'] == true).toList();
                final recent = docs.where((d) => (d.data() as Map<String, dynamic>)['pinned'] != true).toList();

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    if (pinned.isNotEmpty) ...[
                      const SectionHeader(title: 'Épinglées'),
                      ...pinned.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final timeStr = data['createdAt'] != null 
                            ? DateFormat('dd MMM, HH:mm').format((data['createdAt'] as Timestamp).toDate())
                            : '';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _noteCard('📌 $timeStr', data['title'] ?? '', data['content'] ?? '', _getColor(data['colorIndex'] ?? 0), true),
                        );
                      }),
                      const SizedBox(height: 20),
                    ],
                    const SectionHeader(title: 'Récentes'),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recent.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.1,
                      ),
                      itemBuilder: (ctx, i) {
                        final data = recent[i].data() as Map<String, dynamic>;
                        final timeStr = data['createdAt'] != null 
                            ? DateFormat('dd MMM').format((data['createdAt'] as Timestamp).toDate())
                            : '';
                        return _noteCard(timeStr, data['title'] ?? '', data['content'] ?? '', _getColor(data['colorIndex'] ?? i), false);
                      },
                    ),
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
}
