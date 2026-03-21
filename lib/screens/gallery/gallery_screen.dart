import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/common_widgets.dart';
import '../../services/cloudinary_service.dart';
import '../../services/firestore_service.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final _cloudinaryService = CloudinaryService();
  final _firestoreService = FirestoreService();
  bool _isUploading = false;
  String? _selectedAlbumId;
  String _selectedAlbumName = 'Récentes';

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    try {
      final file = File(pickedFile.path);
      final url = await _cloudinaryService.uploadImage(file);

      if (url != null) {
        await _firestoreService.addPhoto(url, albumId: _selectedAlbumId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo ajoutée avec succès !')),
          );
        }
      } else {
        throw Exception("Failed to upload image");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'envoi : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showCreateAlbumDialog() {
    final nameCtrl = TextEditingController();
    final emojis = ['🏖️', '🎄', '🎂', '🎉', '🏡', '🌿', '❤️', '🌟', '🚗', '🍕'];
    String selectedEmoji = emojis[0];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          backgroundColor: kSurface,
          title: const Text('Créer un album', style: TextStyle(fontFamily: 'Sora', color: kText)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emoji picker
              Wrap(
                spacing: 8,
                children: emojis.map((e) => GestureDetector(
                  onTap: () => setStateDialog(() => selectedEmoji = e),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: selectedEmoji == e ? kPurple.withAlpha(51) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selectedEmoji == e ? kPurple : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Text(e, style: const TextStyle(fontSize: 20)),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: kText),
                decoration: InputDecoration(
                  hintText: 'Nom de l\'album',
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
                if (nameCtrl.text.isNotEmpty) {
                  _firestoreService.addAlbum({
                    'name': nameCtrl.text.trim(),
                    'emoji': selectedEmoji,
                    'photoCount': 0,
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Créer', style: TextStyle(color: kPurple)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePhoto(String photoId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text('Supprimer cette photo ?', style: TextStyle(fontFamily: 'Sora', color: kText)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Supprimer', style: TextStyle(color: kRed))),
        ],
      ),
    );
    if (confirm == true) await _firestoreService.deleteGalleryPhoto(photoId);
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
                const Text('Galerie', style: TextStyle(fontFamily: 'Sora', fontSize: 22, fontWeight: FontWeight.w700, color: kText)),
                Row(children: [
                  AppIconButton(icon: const Icon(Icons.search, color: kTextMuted, size: 18)),
                  const SizedBox(width: 8),
                  _isUploading
                    ? const Padding(padding: EdgeInsets.all(8), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: kCyan)))
                    : GestureDetector(
                        onTap: _pickAndUploadImage,
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
                SectionHeader(title: 'Albums', action: 'Créer', onActionTap: _showCreateAlbumDialog),
                StreamBuilder<QuerySnapshot>(
                  stream: _firestoreService.getAlbumsStream(),
                  builder: (context, albumSnap) {
                    final albumDocs = albumSnap.data?.docs ?? [];
                    final allAlbums = [
                      {'id': null, 'emoji': '📷', 'name': 'Toutes'},
                      ...albumDocs.map((d) {
                        final data = d.data() as Map<String, dynamic>;
                        return {'id': d.id, 'emoji': data['emoji'] ?? '📁', 'name': data['name'] ?? 'Album'};
                      }),
                    ];

                    return SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: allAlbums.length,
                        itemBuilder: (ctx, i) {
                          final album = allAlbums[i];
                          final isSelected = _selectedAlbumId == album['id'];
                          final gradients = [
                            [kPurple, kCyan], [kPink, kPurple], [kGreen, kCyan], [kOrange, kPink], [kBlue, kCyan],
                          ];
                          final grad = gradients[i % gradients.length];
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _selectedAlbumId = album['id'] as String?;
                                _selectedAlbumName = album['name'] as String;
                              }),
                              onLongPress: album['id'] != null ? () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                    backgroundColor: kSurface,
                                    title: const Text('Supprimer l\'album ?', style: TextStyle(fontFamily: 'Sora', color: kText)),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annuler')),
                                      TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Supprimer', style: TextStyle(color: kRed))),
                                    ],
                                  ),
                                );
                                if (confirm == true) await _firestoreService.deleteAlbum(album['id'] as String);
                              } : null,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 130, height: 120,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: grad.map((c) => c.withAlpha(isSelected ? 160 : 100)).toList(),
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(album['emoji'] as String, style: const TextStyle(fontSize: 36)),
                                    ),
                                    if (isSelected)
                                      Positioned.fill(child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.white, width: 2.5),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      )),
                                    Positioned(
                                      bottom: 0, left: 0, right: 0,
                                      child: Container(
                                        color: Colors.black.withAlpha(127),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        child: Text(album['name'] as String,
                                            style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                SectionHeader(title: _selectedAlbumName, action: 'Tout voir'),
                StreamBuilder<QuerySnapshot>(
                  stream: _firestoreService.getGalleryStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator(color: kPurple)));
                    }
                    var docs = snapshot.data?.docs ?? [];

                    // Filter by album
                    if (_selectedAlbumId != null) {
                      docs = docs.where((d) {
                        final data = d.data() as Map<String, dynamic>;
                        return data['albumId'] == _selectedAlbumId;
                      }).toList();
                    }

                    if (docs.isEmpty) {
                      return const SizedBox(
                        height: 150,
                        child: Center(child: Text("Aucune photo", style: TextStyle(color: kTextMuted, fontFamily: 'Nunito'))),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 3,
                        crossAxisSpacing: 3,
                      ),
                      itemBuilder: (ctx, i) {
                        final data = docs[i].data() as Map<String, dynamic>;
                        final url = data['url'] as String?;

                        return GestureDetector(
                          onLongPress: () => _deletePhoto(docs[i].id),
                          child: Container(
                            decoration: BoxDecoration(
                              color: kSurface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: url != null
                               ? Image.network(url, fit: BoxFit.cover)
                               : const Icon(Icons.broken_image, color: kTextMuted),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          AppBottomNavBar(currentIndex: 1, onTap: (i) => handleNavBarTap(context, i, 1)),
        ],
      ),
    );
  }
}
