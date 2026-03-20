import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/common_widgets.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final albums = [
      ('🏖️', 'Vacances 2025', '48 photos', const [kPurple, kCyan]),
      ('🎄', 'Noël 2024', '32 photos', [kPink, kPurple]),
      ('🎂', 'Anniversaires', '24 photos', [kGreen, kCyan]),
    ];
    final photoColors = [
      [kPurple, kCyan], [kPink, kPurple], [kGreen, kCyan],
      [kOrange, kPink], [kCyan, kBlue], [kPurple, kPink], [kBlue, kGreen],
    ];
    final photoEmojis = ['🌅', '🏄', '🌊', '🍦', '🌴', '🎡', '🐠'];

    return Scaffold(
      backgroundColor: kBg2,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
                Text('09:41', style: TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w700, color: kText)),
                Icon(Icons.battery_full, size: 14, color: kText),
              ]),
            ),
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
                  AppIconButton(isAccent: true, icon: const Icon(Icons.add, color: Colors.white, size: 18)),
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
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: photoColors.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 3,
                    crossAxisSpacing: 3,
                  ),
                  itemBuilder: (ctx, i) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: (photoColors[i] as List<Color>).map((c) => c.withAlpha(90)).toList(),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(photoEmojis[i], style: TextStyle(fontSize: i == 0 ? 48 : 28)),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          AppBottomNavBar(currentIndex: 1, onTap: (i) {
            if (i == 0) Navigator.pop(context);
          }),
        ],
      ),
    );
  }
}
