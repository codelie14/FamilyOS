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

  void _showAddNoteDialog() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    _showNoteDialog(titleCtrl, contentCtrl, null);
  }

  void _showEditNoteDialog(String docId, Map<String, dynamic> data) {
    final titleCtrl = TextEditingController(text: data['title'] ?? '');
    final contentCtrl = TextEditingController(text: data['content'] ?? '');
    _showNoteDialog(titleCtrl, contentCtrl, docId);
  }

  void _showNoteDialog(TextEditingController titleCtrl, TextEditingController contentCtrl, String? docId) {
    final isEdit = docId != null;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurface,
        title: Text(isEdit ? 'Modifier la note' : 'Nouvelle note',
            style: const TextStyle(fontFamily: 'Sora', color: kText)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              style: const TextStyle(color: kText),
              decoration: InputDecoration(
                hintText: 'Titre',
                hintStyle: const TextStyle(color: kTextMuted),
                filled: true,
                fillColor: kSurface2,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contentCtrl,
              style: const TextStyle(color: kText),
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Contenu...',
                hintStyle: const TextStyle(color: kTextMuted),
                filled: true,
                fillColor: kSurface2,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                if (isEdit) {
                  _db.updateNote(docId!, {
                    'title': titleCtrl.text.trim(),
                    'content': contentCtrl.text.trim(),
                  });
                } else {
                  _db.addNote({
                    'title': titleCtrl.text.trim(),
                    'content': contentCtrl.text.trim(),
                    'pinned': false,
                    'colorIndex': DateTime.now().millisecond % 5,
                  });
                }
                Navigator.pop(ctx);
              }
            },
            child: Text(isEdit ? 'Enregistrer' : 'Ajouter', style: const TextStyle(color: kPurple)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteNote(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text('Supprimer cette note ?', style: TextStyle(fontFamily: 'Sora', color: kText)),
        content: const Text('Cette action est irréversible.', style: TextStyle(fontFamily: 'Nunito', color: kTextMuted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Supprimer', style: TextStyle(color: kRed))),
        ],
      ),
    );
    if (confirm == true) await _db.deleteNote(docId);
  }

  Future<void> _togglePin(String docId, bool pinned) async {
    await _db.updateNote(docId, {'pinned': !pinned});
  }

  void _showNoteOptions(String docId, Map<String, dynamic> data) {
    final pinned = data['pinned'] == true;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withAlpha(50), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(pinned ? Icons.push_pin : Icons.push_pin_outlined, color: kPurple),
              title: Text(pinned ? 'Désépingler' : 'Épingler', style: const TextStyle(fontFamily: 'Nunito', color: kText, fontWeight: FontWeight.w700)),
              onTap: () { Navigator.pop(ctx); _togglePin(docId, pinned); },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: kCyan),
              title: const Text('Modifier', style: TextStyle(fontFamily: 'Nunito', color: kText, fontWeight: FontWeight.w700)),
              onTap: () { Navigator.pop(ctx); _showEditNoteDialog(docId, data); },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: kRed),
              title: const Text('Supprimer', style: TextStyle(fontFamily: 'Nunito', color: kRed, fontWeight: FontWeight.w700)),
              onTap: () { Navigator.pop(ctx); _deleteNote(docId); },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _noteCard(String date, String title, String preview, List<Color> colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(top: -20, right: -20, child: Container(width: 80, height: 80, decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(date, style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white54)),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 6),
              Text(preview, maxLines: 3, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70, height: 1.5)),
            ],
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
                    onTap: _showAddNoteDialog,
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
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.note_outlined, color: kTextDim, size: 48),
                        const SizedBox(height: 12),
                        const Text('Aucune note', style: TextStyle(color: kTextMuted, fontFamily: 'Nunito', fontSize: 14)),
                        const SizedBox(height: 6),
                        const Text('Appuyez sur + pour créer votre première note', style: TextStyle(color: kTextDim, fontFamily: 'Nunito', fontSize: 12)),
                      ],
                    ),
                  );
                }

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
                          child: GestureDetector(
                            onLongPress: () => _showNoteOptions(doc.id, data),
                            onTap: () => _showEditNoteDialog(doc.id, data),
                            child: _noteCard('📌 $timeStr', data['title'] ?? '', data['content'] ?? '',
                                _getColor(data['colorIndex'] ?? 0)),
                          ),
                        );
                      }),
                      const SizedBox(height: 14),
                    ],
                    if (recent.isNotEmpty) ...[
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
                          return GestureDetector(
                            onLongPress: () => _showNoteOptions(recent[i].id, data),
                            onTap: () => _showEditNoteDialog(recent[i].id, data),
                            child: _noteCard(timeStr, data['title'] ?? '', data['content'] ?? '',
                                _getColor(data['colorIndex'] ?? i)),
                          );
                        },
                      ),
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
}
