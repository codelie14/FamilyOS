import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ChatConversationScreen extends StatelessWidget {
  const ChatConversationScreen({
    super.key,
    required this.name,
    required this.initial,
    required this.gradient,
  });

  final String name;
  final String initial;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg2,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('09:41', style: TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w700, color: kText)),
                  Icon(Icons.battery_full, size: 14, color: kText),
                ],
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: Colors.white.withAlpha(15), width: 1),
                    ),
                    child: const Icon(Icons.chevron_left, color: kTextMuted, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  alignment: Alignment.center,
                  child: Text(initial, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontFamily: 'Nunito', fontSize: 15, fontWeight: FontWeight.w800, color: kText)),
                      const Text('4 membres en ligne', style: TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w600, color: kGreen)),
                    ],
                  ),
                ),
                _hBtn(Icons.call_outlined),
                const SizedBox(width: 6),
                _hBtn(Icons.more_horiz),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                _dateLabel("Aujourd'hui · 09:30"),
                _themBubble(
                  gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kPink, kPurple]),
                  initial: 'M',
                  text: "Bonjour tout le monde ! 👋 J'ai ajouté de nouvelles photos des vacances dans la galerie 📸",
                  time: '09:31',
                ),
                const SizedBox(height: 12),
                // Photo bubble (them)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kPink, kPurple]),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      alignment: Alignment.center,
                      child: const Text('M', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 11, color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 160,
                      decoration: BoxDecoration(
                        color: kSurface2,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withAlpha(12), width: 1),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [kPurple.withAlpha(76), kCyan.withAlpha(76)],
                              ),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                            ),
                            child: const Center(child: Icon(Icons.photo_library_outlined, color: Colors.white38, size: 32)),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('12 photos · Vacances 2025',
                                style: TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w600, color: kTextMuted)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _meBubble(text: 'Super ! Merci Marie, elles sont magnifiques 🌟', time: '09:33'),
                const SizedBox(height: 12),
                // File bubble (me)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kSurface2,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withAlpha(12), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: kPurple.withAlpha(38),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.insert_drive_file_outlined, color: kPurpleLight, size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Planning_été.pdf', style: TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w800, color: kText)),
                              Text('2.4 MB · PDF', style: TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w600, color: kTextMuted)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _themBubble(
                  gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kCyan, kBlue]),
                  initial: 'L',
                  text: 'On se retrouve à 18h pour le dîner ? 🍽️',
                  time: '09:38',
                ),
                const SizedBox(height: 12),
                _meBubble(text: 'Oui, parfait ! J\'apporte le dessert 🎂', time: '09:39'),
                const SizedBox(height: 12),
                // Typing indicator
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kPink, kPurple]),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      alignment: Alignment.center,
                      child: const Text('M', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 11, color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: kSurface2,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                          bottomLeft: Radius.circular(4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _dot(),
                          const SizedBox(width: 5),
                          _dot(),
                          const SizedBox(width: 5),
                          _dot(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            decoration: BoxDecoration(
              color: kSurface,
              border: Border(top: BorderSide(color: Colors.white.withAlpha(12), width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: kSurface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withAlpha(15), width: 1),
                  ),
                  child: const Icon(Icons.attach_file, color: kTextMuted, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: kSurface2,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withAlpha(15), width: 1),
                    ),
                    child: const Text('Message…', style: TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w600, color: kTextDim)),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: kGradMain,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: kPurple.withAlpha(90), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hBtn(IconData icon) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withAlpha(15), width: 1),
      ),
      child: Icon(icon, color: kTextMuted, size: 16),
    );
  }

  Widget _dateLabel(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(text,
            style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w800, color: kTextDim, letterSpacing: 1)),
      ),
    );
  }

  Widget _themBubble({required LinearGradient gradient, required String initial, required String text, required String time}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(9)),
          alignment: Alignment.center,
          child: Text(initial, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 11, color: Colors.white)),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kSurface2,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w600, color: kText, height: 1.5)),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w600, color: kTextDim)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _meBubble({required String text, required String time}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(width: 40),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              gradient: kGradMain,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white, height: 1.5)),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white54)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dot() {
    return Container(width: 7, height: 7, decoration: BoxDecoration(color: kTextMuted, shape: BoxShape.circle));
  }
}
