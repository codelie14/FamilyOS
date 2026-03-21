import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/common_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../../core/encryption_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Hashes a 4-digit PIN with SHA-256
String _hashPin(String pin) {
  final bytes = utf8.encode('familyos_salt_$pin');
  return sha256.convert(bytes).toString();
}

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final FirestoreService _db = FirestoreService();

  // PIN state
  bool _unlocked = false;
  String _pin = '';
  String? _storedPinHash;
  bool _isCreatingPin = false; // true when first-time setup
  String _firstPin = ''; // stores first-time entry for confirmation
  bool _confirming = false; // true when confirming first-time PIN
  bool _pinError = false;
  bool _loadingPin = true;

  @override
  void initState() {
    super.initState();
    _loadPinHash();
  }

  Future<void> _loadPinHash() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) { setState(() => _loadingPin = false); return; }
    final hash = await _db.getVaultPinHash(uid);
    setState(() {
      _storedPinHash = hash;
      _isCreatingPin = hash == null;
      _loadingPin = false;
    });
  }

  void _addDigit(String d) {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += d;
      _pinError = false;
    });

    if (_pin.length == 4) {
      Future.delayed(const Duration(milliseconds: 200), _processPin);
    }
  }

  void _deleteDigit() {
    if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _processPin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    // --- First-time PIN creation ---
    if (_isCreatingPin) {
      if (!_confirming) {
        // Save first entry, ask to confirm
        setState(() {
          _firstPin = _pin;
          _pin = '';
          _confirming = true;
        });
        return;
      }
      // Confirming PIN
      if (_pin == _firstPin) {
        // PINs match → save hash
        if (uid != null) {
          await _db.setVaultPinHash(uid, _hashPin(_pin));
        }
        setState(() {
          _storedPinHash = _hashPin(_pin);
          _isCreatingPin = false;
          _confirming = false;
          _firstPin = '';
          _unlocked = true;
          _pin = '';
        });
      } else {
        setState(() {
          _pin = '';
          _firstPin = '';
          _confirming = false;
          _pinError = true;
        });
      }
      return;
    }

    // --- Normal unlock ---
    if (_hashPin(_pin) == _storedPinHash) {
      setState(() { _unlocked = true; _pin = ''; });
    } else {
      setState(() {
        _pin = '';
        _pinError = true;
      });
    }
  }

  void _showAddSecretDialog() {
    final titleCtrl = TextEditingController();
    final secretCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text('Nouveau secret', style: TextStyle(fontFamily: 'Sora', color: kText)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              style: const TextStyle(color: kText),
              decoration: InputDecoration(
                hintText: 'Titre (ex: Netflix)',
                hintStyle: const TextStyle(color: kTextMuted),
                filled: true,
                fillColor: kSurface2,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: secretCtrl,
              obscureText: true,
              style: const TextStyle(color: kText),
              decoration: InputDecoration(
                hintText: 'Mot de passe / Secret...',
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
              if (titleCtrl.text.isNotEmpty && secretCtrl.text.isNotEmpty) {
                final encryptedSecret = EncryptionService.encrypt(secretCtrl.text.trim());
                _db.addVaultSecret({
                  'title': titleCtrl.text.trim(),
                  'secret': encryptedSecret,
                  'type': 'password',
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Créer', style: TextStyle(color: kPurple)),
          ),
        ],
      ),
    );
  }

  void _showSecretDetailsDialog(Map<String, dynamic> data, String docId) {
    final rawSecret = data['secret'] ?? '';
    final plainSecret = EncryptionService.decrypt(rawSecret);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurface,
        title: Text(data['title'] ?? 'Secret', style: const TextStyle(fontFamily: 'Sora', color: kText)),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: kBg2, borderRadius: BorderRadius.circular(12)),
          child: SelectableText(
            plainSecret,
            style: const TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.w700, color: kCyan, letterSpacing: 1),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  backgroundColor: kSurface,
                  title: const Text('Supprimer ce secret ?', style: TextStyle(fontFamily: 'Sora', color: kText)),
                  content: const Text('Cette action est irréversible.', style: TextStyle(fontFamily: 'Nunito', color: kTextMuted)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annuler')),
                    TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Supprimer', style: TextStyle(color: kRed))),
                  ],
                ),
              );
              if (confirm == true && mounted) {
                await _db.deleteVaultSecret(docId);
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: kRed)),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingPin) {
      return const Scaffold(
        backgroundColor: kBg2,
        body: Center(child: CircularProgressIndicator(color: kPurple)),
      );
    }

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
                const Text('Coffre', style: TextStyle(fontFamily: 'Sora', fontSize: 22, fontWeight: FontWeight.w700, color: kText)),
                if (_unlocked)
                  GestureDetector(
                    onTap: _showAddSecretDialog,
                    child: AppIconButton(isAccent: true, icon: const Icon(Icons.add, color: Colors.white, size: 18)),
                  ),
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
    String title = _isCreatingPin
        ? (_confirming ? 'Confirmer le PIN' : 'Créer votre PIN')
        : 'Coffre Familial 🔐';
    String subtitle = _isCreatingPin
        ? (_confirming
            ? 'Saisissez à nouveau votre code pour confirmer.'
            : 'Choisissez un code PIN à 4 chiffres pour protéger votre coffre.')
        : 'Vos données sont chiffrées et protégées par votre code PIN';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _isCreatingPin ? kPurple.withAlpha(51) : kOrange.withAlpha(51),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: (_isCreatingPin ? kPurple : kOrange).withAlpha(64), width: 1),
            ),
            child: Icon(
              _isCreatingPin ? Icons.lock_open_outlined : Icons.lock_outline,
              color: _isCreatingPin ? kPurple : kOrange,
              size: 38,
            ),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w700, color: kText)),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w600, color: kTextMuted, height: 1.5),
          ),
          if (_pinError) ...[
            const SizedBox(height: 10),
            Text(
              _isCreatingPin ? 'Les codes ne correspondent pas. Recommencez.' : 'Code incorrect. Réessayez.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w700, color: kRed),
            ),
          ],
          const SizedBox(height: 28),
          const Text('CODE PIN', style: TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w800, color: kTextMuted, letterSpacing: 1)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
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
              _pinBtn('⌫', _deleteDigit, isDelete: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pinBtn(String label, VoidCallback onTap, {bool isDelete = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withAlpha(15), width: 1),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: TextStyle(fontFamily: 'Nunito', fontSize: isDelete ? 18 : 20, fontWeight: FontWeight.w700, color: isDelete ? kTextMuted : kText)),
      ),
    );
  }

  Widget _buildContent() {
    final categories = [
      ('Documents', Icons.insert_drive_file_outlined, kOrange),
      ('Cartes', Icons.credit_card_outlined, kPurple),
      ('Mots de passe', Icons.shield_outlined, kCyan),
      ('Santé', Icons.favorite_border, kGreen),
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
          childAspectRatio: 1.35,
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
                  width: 42, height: 42,
                  decoration: BoxDecoration(color: c.$3.withAlpha(38), borderRadius: BorderRadius.circular(12)),
                  child: Icon(c.$2, color: c.$3, size: 20),
                ),
                const SizedBox(height: 10),
                Text(c.$1, style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w800, color: kText)),
              ],
            ),
          )).toList(),
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Secrets récents'),
        StreamBuilder<QuerySnapshot>(
          stream: _db.getVaultSecretsStream(),
          builder: (context, snap) {
            if (!snap.hasData || snap.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Text('Aucun secret enregistré', style: TextStyle(fontFamily: 'Nunito', color: kTextMuted)),
              );
            }
            return Column(
              children: snap.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final title = data['title'] ?? 'Secret sans nom';
                final isPassword = data['type'] == 'password';
                final icon = isPassword ? Icons.language : Icons.desktop_windows_outlined;
                final color = isPassword ? kCyan : kOrange;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => _showSecretDetailsDialog(data, doc.id),
                    child: SurfaceCard(
                      child: Row(
                        children: [
                          Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(color: color.withAlpha(38), borderRadius: BorderRadius.circular(10)),
                            child: Icon(icon, color: color, size: 17),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w800, color: kText)),
                                const Text('••••••••••', style: TextStyle(fontFamily: 'Sora', fontSize: 12, letterSpacing: 2, color: kTextMuted)),
                              ],
                            ),
                          ),
                          Container(
                            width: 30, height: 30,
                            decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(9)),
                            child: const Icon(Icons.visibility_outlined, color: kTextMuted, size: 13),
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
    );
  }
}
