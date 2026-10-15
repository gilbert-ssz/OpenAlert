import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Natural aquatic palette: dark green, teal, aqua, light green, white.
class AppColors {
  AppColors._();

  static const deepGreen = Color(0xFF0B3D2E);
  static const forest = Color(0xFF14532D);
  static const teal = Color(0xFF0F766E);
  static const aqua = Color(0xFF2EC4D6);
  static const lightGreen = Color(0xFFD7F0E1);
  static const mint = Color(0xFFF1F8F4);
  static const ink = Color(0xFF12302A);
  static const muted = Color(0xFF5D7069);

  static const good = Color(0xFF2E9E5B);
  static const caution = Color(0xFFD99A00);
  static const critical = Color(0xFFD14343);
  static const unknown = Color(0xFF7A8A86);
  static const demo = Color(0xFF7B5CC2);
}

class AppImages {
  AppImages._();

  static const welcome = 'assets/images/welcome_bg.jpg';
  static const home = 'assets/images/home_header.jpg';
  static const monitor = 'assets/images/monitor_header.jpg';
  static const fish = 'assets/images/fish_header.jpg';
  static const history = 'assets/images/history_header.jpg';
  static const settings = 'assets/images/settings_header.jpg';
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      primary: AppColors.teal,
      secondary: AppColors.aqua,
      surface: Colors.white,
    );
    final radius = BorderRadius.circular(14);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.mint,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.deepGreen,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: radius, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: Color(0xFFD5E4DC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.teal, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.lightGreen,
        height: 76,
        iconTheme: const WidgetStatePropertyAll(
            IconThemeData(size: 28, color: AppColors.deepGreen)),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 13.5,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? AppColors.deepGreen
                : AppColors.muted,
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }

  /// Soft shadow used by cards across the app.
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: AppColors.deepGreen.withValues(alpha: 0.08),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];
}
