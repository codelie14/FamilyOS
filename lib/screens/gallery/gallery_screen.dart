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

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    try {
      final file = File(pickedFile.path);
      final url = await _cloudinaryService.uploadImage(file);
      
      if (url != null) {
        await _firestoreService.addPhoto(url);
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

  @override
  Widget build(BuildContext context) {
    final albums = [
      ('🏖️', 'Vacances 2025', '48 photos', const [kPurple, kCyan]),
      ('🎄', 'Noël 2024', '32 photos', [kPink, kPurple]),
      ('🎂', 'Anniversaires', '24 photos', [kGreen, kCyan]),
    ];

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
                SectionHeader(title: 'Albums', action: 'Créer'),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: albums.length,
                    itemBuilder: (ctx, i) {
                      final a = albums[i];
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              Container(
                                width: 130,
                                height: 120,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: (a.$4 as List<Color>).map((c) => c.withAlpha(100)).toList(),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(a.$1, style: const TextStyle(fontSize: 36)),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  color: Colors.black.withAlpha(127),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(a.$2, style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                                      Text(a.$3, style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, color: Colors.white60, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SectionHeader(title: 'Récentes', action: 'Tout voir'),
                StreamBuilder<QuerySnapshot>(
                  stream: _firestoreService.getGalleryStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator(color: kPurple)));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const SizedBox(
                        height: 150,
                        child: Center(
                          child: Text("Aucune photo récente", style: TextStyle(color: kTextMuted, fontFamily: 'Nunito')),
                        ),
                      );
                    }
                    
                    final docs = snapshot.data!.docs;
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
                        
                        return Container(
                          decoration: BoxDecoration(
                            color: kSurface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: url != null 
                             ? Image.network(url, fit: BoxFit.cover)
                             : const Icon(Icons.broken_image, color: kTextMuted),
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
