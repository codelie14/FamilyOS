
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import '../../widgets/common_widgets.dart';
import '../../services/firestore_service.dart';

class MembersManagementScreen extends StatefulWidget {
  const MembersManagementScreen({super.key});

  @override
  State<MembersManagementScreen> createState() => _MembersManagementScreenState();
}

class _MembersManagementScreenState extends State<MembersManagementScreen> {
  final FirestoreService _db = FirestoreService();

  void _showEditRoleDialog(String docId, String currentRole, String name) {
    String selectedRole = currentRole;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          backgroundColor: kSurface,
          title: Text('Rôle de $name', style: const TextStyle(fontFamily: 'Sora', color: kText)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Membre', style: TextStyle(color: kText)),
                value: 'member',
                groupValue: selectedRole,
                activeColor: kPurple,
                onChanged: (v) => setStateDialog(() => selectedRole = v!),
              ),
              RadioListTile<String>(
                title: const Text('Administrateur', style: TextStyle(color: kText)),
                value: 'admin',
                groupValue: selectedRole,
                activeColor: kPurple,
                onChanged: (v) => setStateDialog(() => selectedRole = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('members').doc(docId).update({'role': selectedRole});
                if (!mounted) return;
                Navigator.pop(ctx);
              },
              child: const Text('Enregistrer', style: TextStyle(color: kPurple)),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteMember(String docId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text('Supprimer le membre', style: TextStyle(fontFamily: 'Sora', color: kText)),
        content: Text('Voulez-vous vraiment retirer $name de la famille ?', style: const TextStyle(color: kTextMuted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('members').doc(docId).delete();
              if (!mounted) return;
              Navigator.pop(ctx);
            },
            child: const Text('Supprimer', style: TextStyle(color: kRed)),
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
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: Colors.white.withAlpha(15), width: 1),
                    ),
                    child: const Icon(Icons.chevron_left, color: kTextMuted, size: 22),
                  ),
                ),
                const SizedBox(width: 14),
                const Text('Gérer la famille', style: TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w700, color: kText)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.getMembersStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: kPurple));
                final docs = snapshot.data!.docs;
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['name'] ?? 'Inconnu';
                    final role = data['role'] ?? 'member';
                    final initial = data['initial'] ?? name[0].toUpperCase();
                    final colorIndex = data['colorIndex'] ?? 0;
                    
                    final colors = [
                      [kPink, kPurple],
                      [kCyan, kBlue],
                      [kGreen, kCyan],
                      [kOrange, kPink],
                      [kPurple, kBlue],
                    ];
                    final grad = LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: colors[colorIndex % colors.length],
                    );

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withAlpha(10)),
                      ),
                      child: Row(
                        children: [
                          MemberAvatar(initials: initial, gradient: grad, size: 44),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w600, color: kText)),
                                Text(role == 'admin' ? 'Administrateur' : 'Membre', style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, color: kTextMuted)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.shield_outlined, color: kPurpleLight, size: 20),
                            onPressed: () => _showEditRoleDialog(doc.id, role, name),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: kRed, size: 20),
                            onPressed: () => _deleteMember(doc.id, name),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
