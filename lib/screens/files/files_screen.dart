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
                  childAspectRatio: 1.6,
                  children: [
                    _folderCard('Images', 'Fichiers médias', Icons.photo_library_outlined, kPurple),
                    _folderCard('Vidéos', 'Souvenirs en vidéo', Icons.videocam_outlined, kPink),
                    _folderCard('Documents', 'Contrats & docs', Icons.insert_drive_file_outlined, kCyan),
                    _folderCard('Coffre', 'Accès sécurisé', Icons.lock_outline, kOrange),
                  ],
                ),
                const SizedBox(height: 20),
                SectionHeader(title: 'Récents', action: 'Tout voir'),
                StreamBuilder<QuerySnapshot>(
                  stream: _db.getFilesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: kPurple));
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('Aucun fichier', style: TextStyle(fontFamily: 'Nunito', color: kTextMuted)),
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

  Widget _storageType(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w700, color: kTextMuted)),
      ],
    );
  }

  Widget _folderCard(String name, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(12), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }
}
