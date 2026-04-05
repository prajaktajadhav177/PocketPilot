import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_pilot/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationScreen extends StatefulWidget{

  _RegistrationScreenState createState()=>_RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>{

final TextEditingController _nameController =TextEditingController();

@override
void dispose(){
  _nameController.dispose();
  super.dispose();
}
 @override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Scaffold(
    body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              const Spacer(),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
                boxShadow: [
    BoxShadow(
      color: Color(0xFFF59E0B).withOpacity(0.25),
      blurRadius: 30,
      spreadRadius: 6,
    )
  ],
),
                child: const Icon(Icons.account_balance_wallet,
                    size: 40, color: Colors.white),
              ),

              const SizedBox(height: 20),

               RichText(
  textAlign: TextAlign.center,
  text: TextSpan(
    style: GoogleFonts.orbitron(   
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
    ),
    children: [
      const TextSpan(
        text: "Welcome to ",
        style: TextStyle(color: Colors.white),
      ),
      const TextSpan(
        text: "PocketPilot",
        style: TextStyle(
          color: Color(0xFFF59E0B),
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
),
              const SizedBox(height: 8),

              Text(
                "Let’s set things up for you",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.white,
                ),
                child: Column(
                  children: [

                    TextField(
                      controller: _nameController,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFFF59E0B),
                            width: 1.5
                          )
                        ),
                      prefixIcon: const Icon(Icons.person),
                      hintText: "Enter your name",
                      filled: true,
                      fillColor: isDark
                      ? Colors.white.withOpacity(0.05)
                     : Colors.grey.shade100,
                      border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                     borderSide: BorderSide.none,
  ),
),
                    ),

                    const SizedBox(height: 16),

                   TextField(
  keyboardType: TextInputType.number,
  decoration: InputDecoration(
    focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFFF59E0B),
                            width: 1.5
                          )
                        ),
    prefixIcon: const Icon(Icons.flag),
    hintText: "Monthly spending goal (optional)",
    filled: true,
    fillColor: isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.grey.shade100,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
  ),
),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.black,
                    elevation: 6,
                    shadowColor: Color(0xFFF59E0B).withOpacity(0.4),
                  ),
                  onPressed: () async {
                    String name = _nameController.text.trim();

                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Please enter your name")),
                      );
                      return;
                    }

                    final prefs =
                        await SharedPreferences.getInstance();

                    await prefs.setString('username', name);
                    await prefs.setBool('isFirstTime', false);

                    if (!mounted) return;

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomeScreen(
                          isDark: false,
                          onThemeChanged: (_) {},
                        ),
                      ),
                    );
                  },
                  child: AnimatedSwitcher(
  duration: const Duration(milliseconds: 200),
  child: Text(
    "Get Started",
    key: const ValueKey("start"),
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  ),
),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    ),
  );
}
}