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

class _SplashScreenState extends State<SplashScreen>{

  @override

void initState(){
  super.initState();
          checkFirstTime();
  
}

void checkFirstTime() async{
  final prefs=await SharedPreferences.getInstance();
  bool isFirstTime=prefs.getBool('isFirstTime') ?? true;

  await Future.delayed(const Duration(seconds: 2));

  if(!mounted) return;
  if(isFirstTime){
    Navigator.pushReplacement(context,MaterialPageRoute(builder: (_)=>OnboardingScreen()));
  }else{
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomeScreen(
      onThemeChanged:widget.onThemeChanged,
      isDark:widget.isDark,
    )));
  }
}

  @override
 
 Widget build(BuildContext context){

    return Scaffold(

      body: Container(

        height: double.infinity,
        width: double.infinity,


        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Color.fromARGB(255, 1, 6, 33),
            Color.fromARGB(255, 3, 130, 173)
          ],
          begin:Alignment.topLeft,
          end:Alignment.bottomRight)
        ),
        child: Center(
          child: Text(
            "PocketPilot",
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28,
               
              
            ),
          ),
        ),
      ),

    );

 }
}