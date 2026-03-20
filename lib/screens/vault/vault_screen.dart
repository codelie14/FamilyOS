import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/common_widgets.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  bool _unlocked = false;
  String _pin = '';

  void _addDigit(String d) {
    if (_pin.length < 4) {
      setState(() => _pin += d);
      if (_pin.length == 4) {
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() => _unlocked = true);
        });
      }
    }
  }

  void _deleteDigit() {
    if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
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
                const Text('Coffre', style: TextStyle(fontFamily: 'Sora', fontSize: 22, fontWeight: FontWeight.w700, color: kText)),
                AppIconButton(isAccent: true, icon: const Icon(Icons.add, color: Colors.white, size: 18)),
              ],
            ),
          ),
          Expanded(
            child: _unlocked ? _buildContent() : _buildLock(),
          ),
          AppBottomNavBar(currentIndex: 0, onTap: (i) => handleNavBarTap(context, i, 0)),
        ],
      ),
    );
  }

  Widget _buildLock() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: kOrange.withAlpha(51),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: kOrange.withAlpha(64), width: 1),
            ),
            child: const Icon(Icons.lock_outline, color: kOrange, size: 38),
          ),
          const SizedBox(height: 16),
          const Text('Coffre Familial 🔐', style: TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w700, color: kText)),
          const SizedBox(height: 6),
          const Text(
            'Vos données sont chiffrées et protégées par votre code PIN',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w600, color: kTextMuted, height: 1.5),
          ),
          const SizedBox(height: 28),
          const Text('CODE PIN', style: TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w800, color: kTextMuted, letterSpacing: 1)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: i < _pin.length ? kPurple : Colors.transparent,
                  shape: BoxShape.circle,
                  border: i < _pin.length ? null : Border.all(color: Colors.white.withAlpha(38), width: 2),
                  boxShadow: i < _pin.length ? [BoxShadow(color: kPurple.withAlpha(127), blurRadius: 12)] : null,
                ),
              ),
            )),
          ),
          const SizedBox(height: 20),
          // PIN pad
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: [
              ...'123456789'.split('').map((d) => _pinBtn(d, () => _addDigit(d))),
              Container(),
              _pinBtn('0', () => _addDigit('0')),
              _pinBtn('⌫', _deleteDigit, accent: false, isDelete: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pinBtn(String label, VoidCallback onTap, {bool accent = false, bool isDelete = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withAlpha(15), width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(fontFamily: 'Nunito', fontSize: isDelete ? 18 : 20, fontWeight: FontWeight.w700, color: isDelete ? kTextMuted : kText),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final categories = [
      ('Documents', '5 fichiers', Icons.insert_drive_file_outlined, kOrange),
      ('Cartes', '3 fichiers', Icons.credit_card_outlined, kPurple),
      ('Mots de passe', '8 entrées', Icons.shield_outlined, kCyan),
      ('Santé', '2 fichiers', Icons.favorite_border, kGreen),
    ];
    final secrets = [
      ('Netflix Famille', Icons.desktop_windows_outlined, kOrange),
      ('Freebox Admin', Icons.language, kCyan),
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SectionHeader(title: 'Catégories'),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.6,
          children: categories.map((c) => Container(
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
                  decoration: BoxDecoration(color: c.$4.withAlpha(38), borderRadius: BorderRadius.circular(12)),
                  child: Icon(c.$3, color: c.$4, size: 20),
                ),
                const SizedBox(height: 10),
                Text(c.$1, style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w800, color: kText)),
                Text(c.$2, style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w600, color: kTextMuted)),
              ],
            ),
          )).toList(),
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Mots de passe récents'),
        ...secrets.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SurfaceCard(
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: s.$3.withAlpha(38), borderRadius: BorderRadius.circular(10)),
                  child: Icon(s.$2, color: s.$3, size: 17),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.$1, style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w800, color: kText)),
                      const Text('••••••••••', style: TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w600, color: kTextMuted, letterSpacing: 2)),
                    ],
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(9)),
                  child: const Icon(Icons.copy, color: kTextMuted, size: 13),
                ),
              ],
            ),
          ),
        )),
        const SizedBox(height: 20),
      ],
    );
  }
}
