import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';
import '../../widgets/gradient_widgets.dart';
import '../../services/auth_service.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _isLoading = false;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  Future<void> _handleAuth(bool isLogin) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (isLogin) {
        await _authService.signInWithEmailAndPassword(email, password);
      } else {
        await _authService.createUserWithEmailAndPassword(email, password);
      }
      // Success is handled by StreamBuilder in main.dart
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.message}')),
      );
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur inattendue est survenue')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _emailController.text = 'admin@familyos.app';
    _passwordController.text = 'password123';
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg2,
      body: Stack(
        children: [
          // Mesh background orbs
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [kPurple.withAlpha(64), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [kCyan.withAlpha(51), Colors.transparent],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                children: [
                  // Hero logo
                  _buildHero(),
                  const SizedBox(height: 8),
                  // Tab switcher
                  _buildTabs(),
                  const SizedBox(height: 28),
                  // Form
                  if (_isLogin) _buildLoginForm() else _buildRegisterForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _floatAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatAnimation.value),
              child: child,
            );
          },
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: kGradMain,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: kPurple.withAlpha(115),
                  blurRadius: 48,
                  offset: const Offset(0, 16),
                ),
                BoxShadow(
                  color: kPurple.withAlpha(25),
                  blurRadius: 0,
                  spreadRadius: 12,
                ),
              ],
            ),
            child: Image.asset('assets/images/logo.png', width: 52, height: 52),
          ),
        ),
        const SizedBox(height: 20),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: kText,
            ),
            children: [
              TextSpan(text: 'Family'),
              TextSpan(
                text: 'OS',
                style: TextStyle(color: kCyan),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Votre espace famille sécurisé',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: kTextMuted,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(12), width: 1),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _TabButton(
            label: 'Connexion',
            isActive: _isLogin,
            onTap: () => setState(() => _isLogin = true),
          ),
          _TabButton(
            label: 'Inscription',
            isActive: !_isLogin,
            onTap: () => setState(() => _isLogin = false),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormField(
          label: 'Adresse email',
          icon: Icons.mail_outline,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          placeholder: 'famille@email.com',
        ),
        const SizedBox(height: 16),
        _PasswordField(
          controller: _passwordController,
          obscure: _obscurePassword,
          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
            ),
            child: const Text(
              'Mot de passe oublié ?',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: kPurpleLight,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _isLoading
            ? const Center(child: CircularProgressIndicator(color: kPurple))
            : GradientButton(
                label: 'Se connecter',
                onTap: () => _handleAuth(true),
              ),
        const SizedBox(height: 20),
        _buildDivider(),
        const SizedBox(height: 20),
        _buildSocialRow(),
        const SizedBox(height: 24),
        Center(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kTextMuted,
              ),
              children: [
                const TextSpan(text: "Pas encore de compte ? "),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => setState(() => _isLogin = false),
                    child: const Text(
                      "S'inscrire",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: kPurpleLight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormField(
          label: 'Nom de famille',
          icon: Icons.people_outline,
          placeholder: 'Famille Dubois',
        ),
        const SizedBox(height: 16),
        _FormField(
          label: 'Adresse email',
          icon: Icons.mail_outline,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          placeholder: 'famille@email.com',
        ),
        const SizedBox(height: 16),
        _PasswordField(
          controller: _passwordController,
          obscure: _obscurePassword,
          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
          label: 'Créer un mot de passe',
        ),
        const SizedBox(height: 24),
        _isLoading
            ? const Center(child: CircularProgressIndicator(color: kPurple))
            : GradientButton(
                label: "Créer mon espace famille",
                onTap: () => _handleAuth(false),
              ),
        const SizedBox(height: 24),
        Center(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kTextMuted,
              ),
              children: [
                const TextSpan(text: "Déjà un compte ? "),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => setState(() => _isLogin = true),
                    child: const Text(
                      "Se connecter",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: kPurpleLight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: Colors.white.withAlpha(18)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ou continuer avec',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              color: kTextDim,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Container(height: 1, color: Colors.white.withAlpha(18)),
        ),
      ],
    );
  }

  Widget _buildSocialRow() {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            label: 'Google',
            icon: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: const Text(
                'G',
                style: TextStyle(
                  color: Color(0xFF4285F4),
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SocialButton(
            label: 'Apple',
            icon: const Icon(Icons.apple, color: kText, size: 18),
          ),
        ),
      ],
    );
  }
}

// ─── Sub-components ──────────────────────────────────────────────────────────

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: isActive
              ? BoxDecoration(
                  gradient: kGradMain,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: kPurple.withAlpha(90),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                )
              : BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isActive ? Colors.white : kTextMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.icon,
    this.controller,
    this.keyboardType,
    this.placeholder = '',
  });

  final String label;
  final IconData icon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: kTextMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: kText,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: kTextDim),
            prefixIcon: Icon(icon, color: kTextDim, size: 17),
            filled: true,
            fillColor: kSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(
                color: Colors.white.withAlpha(15),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(
                color: Colors.white.withAlpha(15),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: kPurple, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
    this.label = 'Mot de passe',
  });

  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: kTextMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: kText,
          ),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: const TextStyle(color: kTextDim),
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: kTextDim,
              size: 17,
            ),
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: kTextDim,
                size: 17,
              ),
            ),
            filled: true,
            fillColor: kSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(
                color: Colors.white.withAlpha(15),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(
                color: Colors.white.withAlpha(15),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: kPurple, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.icon});
  final String label;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withAlpha(15), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: kTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}
