import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/common_widgets.dart';

class FilesScreen extends StatelessWidget {
  const FilesScreen({super.key});

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
                    AppIconButton(isAccent: true, icon: const Icon(Icons.upload, color: Colors.white, size: 18)),
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
                    _folderCard('Images', '84 fichiers', Icons.photo_library_outlined, kPurple),
                    _folderCard('Vidéos', '12 fichiers', Icons.videocam_outlined, kPink),
                    _folderCard('Documents', '27 fichiers', Icons.insert_drive_file_outlined, kCyan),
                    _folderCard('Coffre', '5 fichiers', Icons.lock_outline, kOrange),
                  ],
                ),
                const SizedBox(height: 20),
                SectionHeader(title: 'Récents', action: 'Tout voir'),
                ..._recentFiles(),
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

  List<Widget> _recentFiles() {
    final files = [
      ('Contrat_Maison.pdf', '2.4 MB · Hier · Marie', Icons.insert_drive_file_outlined, kPink),
      ('Planning_été_2025.docx', '340 KB · Lun · Admin', Icons.insert_drive_file_outlined, kCyan),
      ('Vacances_2025_001.jpg', '4.2 MB · Auj. · Lucas', Icons.photo_outlined, kOrange),
      ('Soirée_famille.mp4', '128 MB · Sam · Sophie', Icons.videocam_outlined, kPurple),
    ];
    return files.map((f) => Padding(
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
              decoration: BoxDecoration(color: f.$4.withAlpha(38), borderRadius: BorderRadius.circular(11)),
              child: Icon(f.$3, color: f.$4, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f.$1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w800, color: kText)),
                  Text(f.$2, style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w600, color: kTextMuted)),
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
    )).toList();
  }
}
