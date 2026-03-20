import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/common_widgets.dart';
import '../../services/firestore_service.dart';
import '../../services/cloudinary_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  final FirestoreService _db = FirestoreService();

  final CloudinaryService _cloudinaryService = CloudinaryService();
  bool _isUploading = false;
  String _selectedFolder = 'Tous';

  Future<void> _pickAndUploadFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'mp4'],
    );
    
    if (result == null || result.files.single.path == null) return;
    
    setState(() => _isUploading = true);
    
    try {
      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final fileSizeKb = (await file.length()) / 1024;
      final sizeStr = fileSizeKb > 1024 ? '${(fileSizeKb / 1024).toStringAsFixed(1)} MB' : '${fileSizeKb.toStringAsFixed(0)} KB';
      
      final url = await _cloudinaryService.uploadImage(file, folder: 'familyos_files');
      
      if (url != null) {
        final ext = fileName.split('.').last.toLowerCase();
        final isImage = ['jpg', 'jpeg', 'png', 'gif'].contains(ext);
        final isVideo = ['mp4', 'mov', 'avi'].contains(ext);
        final user = FirebaseAuth.instance.currentUser;
        
        await _db.addFile({
          'name': fileName,
          'size': sizeStr,
          'url': url,
          'uploader': user?.displayName?.substring(0, 1) ?? 'A',
          'type': isImage ? 'image' : (isVideo ? 'video' : 'doc'),
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fichier importé avec succès')));
        }
      } else {
        throw Exception('Cloudinary upload return null URL');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
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
                const Text('Fichiers', style: TextStyle(fontFamily: 'Sora', fontSize: 22, fontWeight: FontWeight.w700, color: kText)),
                Row(
                  children: [
                    AppIconButton(icon: const Icon(Icons.search, color: kTextMuted, size: 18)),
                    const SizedBox(width: 8),
                    _isUploading
                      ? const Padding(padding: EdgeInsets.all(8), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: kCyan)))
                      : GestureDetector(
                          onTap: () => _pickAndUploadFile(context),
                          child: AppIconButton(isAccent: true, icon: const Icon(Icons.upload, color: Colors.white, size: 18)),
                        ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Storage bar
                SurfaceCard(
                  padding: const EdgeInsets.all(16),
                  radius: 16,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Stockage utilisé', style: TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w800, color: kText)),
                          Text('2.9 Go / 5 Go', style: TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w700, color: kTextMuted)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: 0.58,
                          minHeight: 6,
                          backgroundColor: kSurface2,
                          valueColor: const AlwaysStoppedAnimation<Color>(kPurple),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _storageType('Images', kPurple),
                          const SizedBox(width: 14),
                          _storageType('Vidéos', kCyan),
                          const SizedBox(width: 14),
                          _storageType('Docs', kPink),
                          const SizedBox(width: 14),
                          _storageType('Autres', kOrange),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Dossiers'),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.3,
                  children: [
                    _folderCard(context, 'Images', 'image', 'Fichiers médias', Icons.photo_library_outlined, kPurple),
                    _folderCard(context, 'Vidéos', 'video', 'Souvenirs en vidéo', Icons.videocam_outlined, kPink),
                    _folderCard(context, 'Documents', 'doc', 'Contrats & docs', Icons.insert_drive_file_outlined, kCyan),
                    _folderCard(context, 'Coffre', 'vault', 'Accès sécurisé', Icons.lock_outline, kOrange),
                  ],
                ),
                const SizedBox(height: 20),
                SectionHeader(
                  title: _selectedFolder == 'Tous' ? 'Récents' : 'Fichiers - ${_selectedFolder.toUpperCase()}', 
                  action: _selectedFolder == 'Tous' ? 'Tout voir' : 'Annuler',
                  onActionTap: () => setState(() => _selectedFolder = 'Tous'),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: _db.getFilesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: kPurple));
                    }
                    var docs = snapshot.data?.docs ?? [];

                    if (_selectedFolder != 'Tous') {
                      docs = docs.where((doc) {
                        final type = (doc.data() as Map<String, dynamic>)['type'] ?? 'doc';
                        return type == _selectedFolder;
                      }).toList();
                    }

                    if (docs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(_selectedFolder == 'Tous' ? 'Aucun fichier' : 'Aucun fichier dans ce dossier', style: const TextStyle(fontFamily: 'Nunito', color: kTextMuted)),
                      );
                    }
                    return Column(
                      children: docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final title = data['name'] ?? 'Inconnu';
                        final size = data['size'] ?? '0 KB';
                        final type = data['type'] ?? 'doc';
                        final uploader = data['uploader'] ?? '?';
                        final timeStr = data['createdAt'] != null
                            ? DateFormat('dd MMM').format((data['createdAt'] as Timestamp).toDate())
                            : '';
                        
                        final icon = type == 'image' ? Icons.photo_outlined : (type == 'video' ? Icons.videocam_outlined : Icons.insert_drive_file_outlined);
                        final color = type == 'image' ? kOrange : (type == 'video' ? kPurple : kCyan);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () => _showFileOptions(context, doc.id, title, size, timeStr, uploader, icon, color),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                              decoration: BoxDecoration(
                                color: kSurface,
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(color: Colors.white.withAlpha(12), width: 1),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(color: color.withAlpha(38), borderRadius: BorderRadius.circular(11)),
                                    child: Icon(icon, color: color, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(title, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w800, color: kText)),
                                        Text('$size · $timeStr · $uploader', style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w600, color: kTextMuted)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(9)),
                                    child: const Icon(Icons.more_horiz, color: kTextMuted, size: 14),
                                  ),
                                ],
                              ),
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
          AppBottomNavBar(currentIndex: 1, onTap: (i) => handleNavBarTap(context, i, 1)),
        ],
      ),
    );
  }

  void _showFileOptions(BuildContext context, String fileId, String title, String size, String timeStr, String uploader, IconData icon, Color color) {
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
            Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(color: color.withAlpha(38), borderRadius: BorderRadius.circular(14)),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
                      Text('$size • $timeStr • Par $uploader', style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, color: kTextMuted)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.remove_red_eye_outlined, color: kText),
              title: const Text('Ouvrir / Visualiser', style: TextStyle(fontFamily: 'Nunito', color: kText, fontWeight: FontWeight.w600)),
              onTap: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ouverture de $title...'))); },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined, color: kText),
              title: const Text('Partager', style: TextStyle(fontFamily: 'Nunito', color: kText, fontWeight: FontWeight.w600)),
              onTap: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lien de partage généré dans le presse-papiers'))); },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: kRed),
              title: const Text('Supprimer', style: TextStyle(fontFamily: 'Nunito', color: kRed, fontWeight: FontWeight.w700)),
              onTap: () async {
                Navigator.pop(ctx);
                await _db.deleteFile(fileId);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fichier supprimé')));
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _storageType(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w700, color: kTextMuted)),
      ],
    );
  }

  Widget _folderCard(BuildContext context, String name, String folderType, String count, IconData icon, Color color) {
    final isSelected = _selectedFolder == folderType;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedFolder == folderType) {
            _selectedFolder = 'Tous';
          } else {
            _selectedFolder = folderType;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(20) : kSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? color.withAlpha(100) : Colors.white.withAlpha(12), width: isSelected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: color.withAlpha(38), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(name, style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w800, color: kText)),
            Text(count, style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w600, color: kTextMuted)),
          ],
        ),
      ),
    );
  }
}
