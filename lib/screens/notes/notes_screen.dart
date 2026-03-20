import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/common_widgets.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pinned = [
      ('📌 Aujourd\'hui, 09:20', 'Liste de courses', '🥛 Lait, 🥚 Œufs, 🍞 Pain, 🧀 Fromage, 🍗 Poulet, 🥦 Brocolis…', const [kPurple, kBlue], true),
    ];
    final recent = [
      ('Hier', 'Idées vacances été 2026', 'Portugal, Grèce, Bretagne…', const [kPink, kPurple], false),
      ('Lun', 'Rdv médecin Lucas', 'Dr. Martin – 14h30 mardi', const [kCyan, kBlue], false),
      ('Sam', 'Recette Tarte Tatin', '6 pommes, beurre, sucre…', const [kGreen, kCyan], false),
      ('Ven', 'Mot de passe WiFi', 'Maison_Dubois_2026', const [kOrange, kPink], false),
    ];

    Widget noteCard(String date, String title, String preview, List<Color> colors, bool wide) {
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
                Text(preview, style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70, height: 1.5)),
              ],
            ),
          ],
        ),
      );
    }

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
                  AppIconButton(isAccent: true, icon: const Icon(Icons.add, color: Colors.white, size: 18)),
                ]),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SectionHeader(title: 'Épinglées'),
                noteCard(pinned[0].$1, pinned[0].$2, pinned[0].$3, pinned[0].$4 as List<Color>, true),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Récentes'),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.1,
                  children: recent.map((n) => noteCard(n.$1, n.$2, n.$3, n.$4 as List<Color>, false)).toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          AppBottomNavBar(currentIndex: 0, onTap: (i) => handleNavBarTap(context, i, 0)),
        ],
      ),
    );
  }
}
