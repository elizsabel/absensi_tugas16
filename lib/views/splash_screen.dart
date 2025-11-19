import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SplashScreenLemon extends StatelessWidget {
  final bool isDark;
  final Function(bool) onThemeChanged;

  const SplashScreenLemon({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFFFF7D1),
      body: Center(
        child: Text(
          "Splash Absensi 🍋",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.brown,
          ),
        ),
      ),
    );
  }
}
