import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'gradient_widgets.dart';

/// Bottom navigation bar matching the Figma design.
/// Has 5 items: Accueil, Fichiers, [+FAB center], Chat, Famille
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        border: Border(
          top: BorderSide(color: Colors.white.withAlpha(12), width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _NavItem(
            index: 0,
            currentIndex: currentIndex,
            onTap: onTap,
            icon: _navIcon(Icons.home_outlined),
            activeIcon: _navIcon(Icons.home_outlined, active: true),
            label: 'Accueil',
          ),
          _NavItem(
            index: 1,
            currentIndex: currentIndex,
            onTap: onTap,
            icon: _navIcon(Icons.folder_outlined),
            activeIcon: _navIcon(Icons.folder_outlined, active: true),
            label: 'Fichiers',
          ),
          // Center FAB
          _CenterFAB(onTap: () => onTap(2)),
          _NavItem(
            index: 3,
            currentIndex: currentIndex,
            onTap: onTap,
            icon: _navIcon(Icons.chat_bubble_outline),
            activeIcon: _navIcon(Icons.chat_bubble_outline, active: true),
            label: 'Chat',
          ),
          _NavItem(
            index: 4,
            currentIndex: currentIndex,
            onTap: onTap,
            icon: _navIcon(Icons.people_outline),
            activeIcon: _navIcon(Icons.people_outline, active: true),
            label: 'Famille',
          ),
        ],
      ),
    );
  }

  Icon _navIcon(IconData data, {bool active = false}) {
    return Icon(
      data,
      color: active ? kPurpleLight : kTextMuted,
      size: 22,
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.onTap,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Widget icon;
  final Widget activeIcon;
  final String label;

  bool get isActive => currentIndex == index;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                isActive ? activeIcon : icon,
                const SizedBox(height: 3),
                isActive
                    ? GradientText(
                        label,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        gradient: kGradMain,
                      )
                    : Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: kTextMuted,
                        ),
                      ),
              ],
            ),
            if (isActive)
              Positioned(
                bottom: -6,
                child: Container(
                  width: 20,
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: kGradMain,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(3),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CenterFAB extends StatelessWidget {
  const _CenterFAB({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(bottom: 0),
              transform: Matrix4.translationValues(0, -14, 0),
              decoration: BoxDecoration(
                gradient: kGradMain,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: kPurple.withAlpha(115),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
          ),
          const Text(
            'Nouveau',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: kTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}
