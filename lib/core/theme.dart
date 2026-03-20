import 'package:flutter/material.dart';

// ─── Palette ────────────────────────────────────────────────────────────────
const Color kPurple = Color(0xFF7C3AED);
const Color kPurpleLight = Color(0xFF9B59F5);
const Color kBlue = Color(0xFF4F6FE8);
const Color kBlueMid = Color(0xFF3B82F6);
const Color kCyan = Color(0xFF06B6D4);
const Color kPink = Color(0xFFEC4899);
const Color kGreen = Color(0xFF10B981);
const Color kOrange = Color(0xFFF59E0B);
const Color kRed = Color(0xFFEF4444);
const Color kNavy = Color(0xFF1E2A4A);

const Color kBg = Color(0xFF0F1629);
const Color kBg2 = Color(0xFF141E35);
const Color kSurface = Color(0xFF1A2540);
const Color kSurface2 = Color(0xFF202D4A);
const Color kSurface3 = Color(0xFF263354);

const Color kText = Color(0xFFF0F4FF);
const Color kTextMuted = Color(0xFF8A9BC4);
const Color kTextDim = Color(0xFF4A5A7A);

// ─── Gradients ───────────────────────────────────────────────────────────────
const LinearGradient kGradMain = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  stops: [0.0, 0.5, 1.0],
  colors: [kPurple, kBlue, kCyan],
);

const LinearGradient kGradPink = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kPink, kPurple],
);

const LinearGradient kGradCyan = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kBlue, kCyan],
);

const LinearGradient kGradGreen = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kGreen, kCyan],
);

// ─── Border radii ────────────────────────────────────────────────────────────
const double kRadius = 20.0;
const double kRadiusSm = 12.0;
const double kRadiusXs = 8.0;

// ─── Text styles ─────────────────────────────────────────────────────────────
const TextStyle kStyleSoraH1 = TextStyle(
  fontFamily: 'Sora',
  fontSize: 28,
  fontWeight: FontWeight.w700,
  color: kText,
  letterSpacing: -0.5,
);

const TextStyle kStyleSoraH2 = TextStyle(
  fontFamily: 'Sora',
  fontSize: 22,
  fontWeight: FontWeight.w700,
  color: kText,
  letterSpacing: -0.3,
);

const TextStyle kStyleSoraH3 = TextStyle(
  fontFamily: 'Sora',
  fontSize: 18,
  fontWeight: FontWeight.w700,
  color: kText,
);

const TextStyle kStyleBody = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: kText,
);

const TextStyle kStyleBodySm = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 12,
  fontWeight: FontWeight.w600,
  color: kTextMuted,
);

const TextStyle kStyleLabel = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 12,
  fontWeight: FontWeight.w800,
  color: kTextMuted,
  letterSpacing: 1.5,
);

// ─── Theme ───────────────────────────────────────────────────────────────────
ThemeData buildAppTheme() {
  return ThemeData(
    fontFamily: 'Nunito',
    scaffoldBackgroundColor: kBg2,
    colorScheme: const ColorScheme.dark(
      primary: kPurple,
      secondary: kCyan,
      surface: kSurface,
      onPrimary: kText,
      onSurface: kText,
    ),
    textTheme: const TextTheme(
      displayLarge: kStyleSoraH1,
      displayMedium: kStyleSoraH2,
      titleLarge: kStyleSoraH3,
      bodyLarge: kStyleBody,
      bodySmall: kStyleBodySm,
      labelSmall: kStyleLabel,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
}
