import 'dart:async';
import 'package:flutter/material.dart';
import 'loginpage.dart';

class SplashCuteYellow extends StatefulWidget {
  const SplashCuteYellow({super.key});

  @override
  State<SplashCuteYellow> createState() => _SplashCuteYellowState();
}

class _SplashCuteYellowState extends State<SplashCuteYellow>
    with TickerProviderStateMixin {
  late AnimationController lemonCtrl;
  late AnimationController sparkleCtrl;
  late AnimationController dotCtrl;

  late Animation<double> lemonBounce;
  late Animation<double> sparkleFade;
  late Animation<int> dotAnim;

  @override
  void initState() {
    super.initState();

    // 🍋 Bounce Animation
    lemonCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    lemonBounce = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(parent: lemonCtrl, curve: Curves.easeInOut));

    // ✨ Sparkle Animation
    sparkleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    sparkleFade = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(CurvedAnimation(parent: sparkleCtrl, curve: Curves.easeInOut));

    // 🍊 Dot Loading Animation
    dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    dotAnim = StepTween(begin: 0, end: 2).animate(dotCtrl);

    // Auto Navigate
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginCustGlow()),
      );
    });
  }

  @override
  void dispose() {
    lemonCtrl.dispose();
    sparkleCtrl.dispose();
    dotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF7DA), Color(0xFFFFE88C), Color(0xFFFFC74C)],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ✨ Sparkle Left
            Positioned(
              top: 130,
              left: 50,
              child: FadeTransition(
                opacity: sparkleFade,
                child: Icon(
                  Icons.star,
                  size: 26,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),

            // ✨ Sparkle Right
            Positioned(
              top: 200,
              right: 40,
              child: FadeTransition(
                opacity: sparkleFade,
                child: Icon(
                  Icons.star,
                  size: 22,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),

            // 🍋 LEMON BOUNCING
            AnimatedBuilder(
              animation: lemonCtrl,
              builder: (_, child) {
                return Transform.translate(
                  offset: Offset(0, lemonBounce.value),
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  // shape: BoxShape.circle,
                  // color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.yellow.shade700.withOpacity(0.35),
                      blurRadius: 35,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: Image.asset(
                  "assets/images/tracklizz.png",
                  height: 200,
                  width: 200,
                ),
              ),
            ),

            // TITLE & TEXT
            Positioned(
              bottom: 260,
              child: Column(
                children: [
                  Text(
                    "Stay On Time • Stay on Track",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.brown.shade700,
                      // shadows: const [
                      //   Shadow(color: Colors.white, blurRadius: 6),
                      // ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Created by Elizsabel",
                    style: TextStyle(fontSize: 10, color: Colors.black),
                  ),
                ],
              ),
            ),

            // 🍊 LOADING DOT CUTE
            Positioned(
              bottom: 200,
              child: AnimatedBuilder(
                animation: dotCtrl,
                builder: (_, __) {
                  int active = dotAnim.value;

                  return Row(
                    children: List.generate(3, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: index == active
                                ? Colors.orange.shade700
                                : Colors.orange.shade200,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
