import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_pilot/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_pilot/home_screen.dart';


class SplashScreen extends StatefulWidget{

  final Function(bool) onThemeChanged;
  final bool isDark;

  const SplashScreen({
    super.key,
    required this.onThemeChanged,
    required this.isDark,
  });
  
  @override
  _SplashScreenState createState()=>_SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> scaleAnim;
  late Animation<double> opacityAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2),
    );

    scaleAnim = Tween(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    opacityAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    checkFirstTime();
  }

  void checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (isFirstTime) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OnboardingScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            onThemeChanged: widget.onThemeChanged,
            isDark: widget.isDark,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E3A8A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: opacityAnim,
          child: ScaleTransition(
            scale: scaleAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // 🔥 GLOW EFFECT
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFF59E0B).withOpacity(0.25),
                        blurRadius: 40,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.06),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      size: 45,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔥 APP NAME
                Text(
                  "PocketPilot",
                 style: GoogleFonts.orbitron(
  fontSize: 26,
  fontWeight: FontWeight.w700,
  letterSpacing: 0.3,
  color: Colors.white,
),
                ),

                const SizedBox(height: 10),

                Text(
                  "Track • Analyze • Grow",
                  style: TextStyle(
                  color: Color(0xFFF59E0B).withOpacity(0.8),                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 32),

                // 🔥 LOADER
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),

                const SizedBox(height: 40),

                // 🔥 BOTTOM BRAND TOUCH
                Text(
                  "Powered by PocketPilot",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}