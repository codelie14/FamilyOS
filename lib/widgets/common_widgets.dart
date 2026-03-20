import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Rounded square member avatar with gradient background.
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({
    super.key,
    required this.initials,
    required this.gradient,
    this.size = 52,
    this.isOnline,
    this.radius = 16,
  });

  final String initials;
  final LinearGradient gradient;
  final double size;
  final bool? isOnline;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withAlpha(25),
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              fontSize: size * 0.34,
              color: Colors.white,
            ),
          ),
        ),
        if (isOnline != null)
          Positioned(
            bottom: 3,
            right: 3,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isOnline! ? kGreen : kTextDim,
                shape: BoxShape.circle,
                border: Border.all(color: kBg2, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

/// Small icon button (38×38 rounded square).
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.showDot = false,
    this.isAccent = false,
    this.size = 38,
    this.radius = 12,
  });

  final Widget icon;
  final VoidCallback? onTap;
  final bool showDot;
  final bool isAccent;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      width: size,
      height: size,
      decoration: isAccent
          ? BoxDecoration(
              gradient: kGradMain,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: [
                BoxShadow(
                  color: kPurple.withAlpha(90),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: Colors.white.withAlpha(15),
                width: 1,
              ),
            ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          icon,
          if (showDot)
            Positioned(
              top: 7,
              right: 7,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: kPink,
                  shape: BoxShape.circle,
                  border: Border.all(color: kBg2, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: container,
    );
  }
}

/// Section header with ALL-CAPS label + optional action link.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onActionTap,
    this.bottomPadding = 12,
  });

  final String title;
  final String? action;
  final VoidCallback? onActionTap;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: kTextMuted,
              letterSpacing: 1.5,
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                action!,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: kPurpleLight,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Surface card with optional border.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 14.0,
    this.color = kSurface,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: Colors.white.withAlpha(12),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
