import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';
import '../../widgets/gradient_widgets.dart';
import '../../widgets/common_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _sent = false;
  bool _isLoading = false;
  final _emailController = TextEditingController();

  Future<void> _sendReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) setState(() { _sent = true; _isLoading = false; });
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${e.message}')));
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg2,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [kBlue.withAlpha(51), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.chevron_left, color: kTextMuted, size: 24),
                        Text(
                          'Retour',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: kTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppIconButton(
                        icon: const Icon(Icons.lock_outline, color: kPurpleLight, size: 26),
                        size: 56,
                        radius: 18,
                      ),
                      const SizedBox(height: 16),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: kText,
                          ),
                          children: [
                            TextSpan(text: 'Mot de passe\n'),
                            TextSpan(
                              text: 'oublié ?',
                              style: TextStyle(color: kCyan),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Entrez votre adresse email et nous vous enverrons un lien de réinitialisation.",
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: kTextMuted,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
                    child: Column(
                      children: [
                        // Email field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ADRESSE EMAIL',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: kTextMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: kText,
                              ),
                              decoration: InputDecoration(
                                hintText: 'famille@email.com',
                                hintStyle: const TextStyle(color: kTextDim),
                                prefixIcon: const Icon(Icons.mail_outline, color: kTextDim, size: 17),
                                filled: true,
                                fillColor: kSurface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(13),
                                  borderSide: BorderSide(color: Colors.white.withAlpha(15), width: 1.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(13),
                                  borderSide: BorderSide(color: Colors.white.withAlpha(15), width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(13),
                                  borderSide: const BorderSide(color: kPurple, width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator(color: kPurple))
                            : GradientButton(
                                label: 'Envoyer le lien',
                                onTap: _sendReset,
                              ),
                        // Success message
                        if (_sent) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: kSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: kGreen.withAlpha(51),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: kGreen.withAlpha(38),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.check_circle_outline, color: kGreen, size: 18),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Email envoyé !',
                                          style: TextStyle(
                                            fontFamily: 'Nunito',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: kText,
                                          )),
                                      SizedBox(height: 2),
                                      Text(
                                        'Vérifiez votre boîte mail. Le lien expire dans 15 minutes.',
                                        style: TextStyle(
                                          fontFamily: 'Nunito',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: kTextMuted,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 13,
                                  color: kTextMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                                children: [
                                  TextSpan(text: 'Vous vous souvenez ? '),
                                  TextSpan(
                                    text: 'Se connecter',
                                    style: TextStyle(
                                      color: kPurpleLight,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
