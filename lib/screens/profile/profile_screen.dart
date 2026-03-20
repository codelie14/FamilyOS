import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/common_widgets.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = [
      // (icon, color, title, subtitle, type) type: arrow | toggle_on | toggle_off
      (Icons.person_outline, kPurple, 'Informations personnelles', 'Nom, email, photo', 'arrow'),
      (Icons.people_outline, kGreen, 'Gérer les membres', '4 membres actifs', 'arrow'),
    ];
    final security = [
      (Icons.lock_outline, kOrange, 'Mot de passe', 'Modifié il y a 30 jours', 'arrow'),
      (Icons.shield_outlined, kCyan, 'Authentification 2FA', 'Activée', 'toggle_on'),
    ];
    final prefs = [
      (Icons.dark_mode_outlined, kPurple, 'Mode sombre', 'Thème nuit activé', 'toggle_on'),
      (Icons.notifications_outlined, kPink, 'Notifications', 'Toutes activées', 'toggle_on'),
      (Icons.location_on_outlined, kGreen, 'Partage de position', 'Désactivé', 'toggle_off'),
    ];

    Widget settingItem(IconData icon, Color color, String title, String sub, String type) {
      return GestureDetector(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(13)),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: color.withAlpha(38), borderRadius: BorderRadius.circular(11)),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w800, color: kText)),
                      Text(sub, style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w600, color: kTextMuted)),
                    ],
                  ),
                ),
                if (type == 'arrow')
                  const Icon(Icons.chevron_right, color: kTextDim, size: 20)
                else
                  Container(
                    width: 38,
                    height: 22,
                    decoration: BoxDecoration(
                      gradient: type == 'toggle_on' ? kGradMain : null,
                      color: type == 'toggle_off' ? kSurface2 : null,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 200),
                          right: type == 'toggle_on' ? 3 : null,
                          left: type == 'toggle_off' ? 3 : null,
                          top: 3,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withAlpha(76), blurRadius: 6)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
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
                const Text('Profil', style: TextStyle(fontFamily: 'Sora', fontSize: 22, fontWeight: FontWeight.w700, color: kText)),
                AppIconButton(icon: const Icon(Icons.edit_outlined, color: kTextMuted, size: 18)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Profile hero
                Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: kGradMain,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: Colors.white.withAlpha(38), width: 3),
                            boxShadow: [BoxShadow(color: kPurple.withAlpha(100), blurRadius: 36, offset: const Offset(0, 12))],
                          ),
                          alignment: Alignment.center,
                          child: const Text('A', style: TextStyle(fontFamily: 'Nunito', fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white)),
                        ),
                        Positioned(
                          bottom: -4,
                          right: -4,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: kSurface,
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(color: kBg2, width: 2),
                            ),
                            child: const Icon(Icons.edit, color: kTextMuted, size: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text('Administrateur', style: TextStyle(fontFamily: 'Sora', fontSize: 22, fontWeight: FontWeight.w700, color: kText)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: kPurple.withAlpha(38),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: kPurple.withAlpha(64), width: 1),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_outlined, color: kPurpleLight, size: 12),
                          SizedBox(width: 6),
                          Text('Admin • Famille Dubois', style: TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w700, color: kPurpleLight)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
                // Stats
                SurfaceCard(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
                  radius: 18,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _pStat('4', 'Membres'),
                      Container(width: 1, height: 40, color: Colors.white.withAlpha(18)),
                      _pStat('128', 'Fichiers'),
                      Container(width: 1, height: 40, color: Colors.white.withAlpha(18)),
                      _pStat('47', 'Messages'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Compte'),
                ...settings.map((s) => settingItem(s.$1, s.$2, s.$3, s.$4, s.$5)),
                const SizedBox(height: 16),
                const SectionHeader(title: 'Sécurité'),
                ...security.map((s) => settingItem(s.$1, s.$2, s.$3, s.$4, s.$5)),
                const SizedBox(height: 16),
                const SectionHeader(title: 'Préférences'),
                ...prefs.map((s) => settingItem(s.$1, s.$2, s.$3, s.$4, s.$5)),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    await AuthService().signOut();
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: kRed.withAlpha(25),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kRed.withAlpha(51), width: 1),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: kRed, size: 17),
                        SizedBox(width: 8),
                        Text('Se déconnecter', style: TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w800, color: kRed)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          AppBottomNavBar(currentIndex: 4, onTap: (i) {
            if (i == 0) Navigator.pop(context);
          }),
        ],
      ),
    );
  }

  Widget _pStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontFamily: 'Nunito', fontSize: 20, fontWeight: FontWeight.w900, color: kText)),
        Text(label, style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w700, color: kTextMuted)),
      ],
    );
  }
}
