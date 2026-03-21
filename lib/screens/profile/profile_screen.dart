import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/common_widgets.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService db = FirestoreService();
  bool _darkMode = true;
  bool _notifications = true;
  bool _locationSharing = false;

  void _showEditProfileDialog(User user) {
    final nameCtrl = TextEditingController(text: user.displayName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text('Modifier le profil', style: TextStyle(fontFamily: 'Sora', color: kText)),
        content: TextField(controller: nameCtrl, style: const TextStyle(color: kText), decoration: const InputDecoration(hintText: 'Nom d\'affichage', hintStyle: TextStyle(color: kTextMuted))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                await user.updateDisplayName(nameCtrl.text.trim());
                if (mounted) {
                  setState(() {});
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil mis à jour')));
                }
              }
            },
            child: const Text('Enregistrer', style: TextStyle(color: kPurple)),
          ),
        ],
      ),
    );
  }

  void _showPasswordResetDialog(User user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text('Réinitialiser le mot de passe', style: TextStyle(fontFamily: 'Sora', color: kText)),
        content: const Text('Un email de réinitialisation sera envoyé à votre adresse.', style: TextStyle(fontFamily: 'Nunito', color: kText)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              if (user.email != null) {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Email envoyé à ${user.email}')));
                }
              }
            },
            child: const Text('Envoyer', style: TextStyle(color: kPurple)),
          ),
        ],
      ),
    );
  }

  void _showInviteDialog() async {
    // Generate a random 6-char alphanumeric code
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    final code = 'FAM-${List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join()}';

    // Save to Firestore with 24h expiry
    final expiry = DateTime.now().add(const Duration(hours: 24));
    await FirebaseFirestore.instance.collection('invitations').doc(code).set({
      'code': code,
      'createdBy': FirebaseAuth.instance.currentUser?.uid,
      'expiresAt': Timestamp.fromDate(expiry),
      'used': false,
    });

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text('Inviter un membre', style: TextStyle(fontFamily: 'Sora', color: kText)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Partagez ce code à votre proche. Il expire dans 24h.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', color: kTextMuted, fontSize: 13)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(color: kBg2, borderRadius: BorderRadius.circular(12)),
              child: Text(code, style: const TextStyle(fontFamily: 'Sora', color: kCyan, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer')),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copié dans le presse-papiers')));
            },
            child: const Text('Copier', style: TextStyle(color: kPurple)),
          ),
        ],
      ),
    );
  }

  void _showRolesDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text('Rôles et permissions', style: TextStyle(fontFamily: 'Sora', color: kText)),
        content: const Text('Gérez qui peut modifier les fichiers, ajouter des événements, ou inviter de nouveaux membres. (Fonctionnalité à venir)', style: TextStyle(fontFamily: 'Nunito', color: kText)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ok', style: TextStyle(color: kPurple))),
        ],
      ),
    );
  }

  void _showFamilySettingsDialog() {
    final nameCtrl = TextEditingController(text: 'Notre Famille');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text('Paramètres familiaux', style: TextStyle(fontFamily: 'Sora', color: kText)),
        content: TextField(controller: nameCtrl, style: const TextStyle(color: kText), decoration: const InputDecoration(hintText: 'Nom de la famille', hintStyle: TextStyle(color: kTextMuted))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('family_info').doc('details').set({'familyName': nameCtrl.text.trim()}, SetOptions(merge: true));
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nom de famille mis à jour')));
                }
              }
            },
            child: const Text('Enregistrer', style: TextStyle(color: kPurple)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'Administrateur';
    final userEmail = user?.email ?? 'Nom, email, photo';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'A';

    Widget settingItem(IconData icon, Color color, String title, String sub, String type, {VoidCallback? onTap}) {
      return GestureDetector(
        onTap: onTap,
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
            child: StreamBuilder<QuerySnapshot>(
              stream: db.getMembersStream(),
              builder: (context, memberSnap) {
                final mCount = memberSnap.hasData ? memberSnap.data!.docs.length : 0;
                
                final settings = [
                  [Icons.person_outline, kPurple, 'Informations personnelles', userEmail, 'arrow', () => _showEditProfileDialog(user!)],
                  [Icons.group_add_outlined, kBlue, 'Ajouter un membre', 'Inviter dans la famille', 'arrow', () => _showInviteDialog()],
                  [Icons.admin_panel_settings_outlined, kOrange, 'Rôles et permissions', 'Gérer les accès', 'arrow', () => _showRolesDialog()],
                  [Icons.home_outlined, kPink, 'Paramètres familiaux', 'Nom et préférences', 'arrow', () => _showFamilySettingsDialog()],
                ];
                final security = [
                  [Icons.lock_outline, kOrange, 'Mot de passe', 'Dernière modification récente', 'arrow', () => _showPasswordResetDialog(user!)],
                ];
                final prefs = [
                  [Icons.dark_mode_outlined, kPurple, 'Mode sombre', _darkMode ? 'Activé' : 'Désactivé', _darkMode ? 'toggle_on' : 'toggle_off', () => setState(() => _darkMode = !_darkMode)],
                  [Icons.notifications_outlined, kPink, 'Notifications', _notifications ? 'Toutes activées' : 'Désactivées', _notifications ? 'toggle_on' : 'toggle_off', () => setState(() => _notifications = !_notifications)],
                  [Icons.location_on_outlined, kGreen, 'Partage de position', _locationSharing ? 'Activé' : 'Désactivé', _locationSharing ? 'toggle_on' : 'toggle_off', () => setState(() => _locationSharing = !_locationSharing)],
                ];

                return ListView(
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
                              child: Text(userInitial, style: const TextStyle(fontFamily: 'Nunito', fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white)),
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
                        Text(userName, style: const TextStyle(fontFamily: 'Sora', fontSize: 22, fontWeight: FontWeight.w700, color: kText)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: kPurple.withAlpha(38),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: kPurple.withAlpha(64), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.shield_outlined, color: kPurpleLight, size: 12),
                              const SizedBox(width: 6),
                              Text('$userName • Famille', style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w700, color: kPurpleLight)),
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
                          _pStat(mCount.toString(), 'Membres'),
                          Container(width: 1, height: 40, color: Colors.white.withAlpha(18)),
                          StreamBuilder<QuerySnapshot>(
                            stream: db.getFilesStream(),
                            builder: (ctx, fileSnap) => _pStat(fileSnap.hasData ? fileSnap.data!.docs.length.toString() : '0', 'Fichiers'),
                          ),
                          Container(width: 1, height: 40, color: Colors.white.withAlpha(18)),
                          StreamBuilder<QuerySnapshot>(
                            stream: db.getFamilyChatStream(),
                            builder: (ctx, msgSnap) => _pStat(msgSnap.hasData ? msgSnap.data!.docs.length.toString() : '0', 'Messages'),
                          ),
                        ],
                      ),
                    ),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Compte'),
                ...settings.map((s) => settingItem(s[0] as IconData, s[1] as Color, s[2] as String, s[3] as String, s[4] as String, onTap: s[5] as VoidCallback?)),
                const SizedBox(height: 16),
                const SectionHeader(title: 'Sécurité'),
                ...security.map((s) => settingItem(s[0] as IconData, s[1] as Color, s[2] as String, s[3] as String, s[4] as String, onTap: s[5] as VoidCallback?)),
                const SizedBox(height: 16),
                const SectionHeader(title: 'Préférences'),
                ...prefs.map((s) => settingItem(s[0] as IconData, s[1] as Color, s[2] as String, s[3] as String, s[4] as String, onTap: s[5] as VoidCallback?)),
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
            );
          },
        ),
      ),
      AppBottomNavBar(currentIndex: 4, onTap: (i) => handleNavBarTap(context, i, 4)),
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
