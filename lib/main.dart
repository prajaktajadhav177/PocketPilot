import 'package:flutter/material.dart';
import 'package:pocket_pilot/splash_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('transactions');
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode') ?? false;
  runApp(MyApp(initialTheme: isDark));
}


class MyApp extends StatefulWidget{
    final bool initialTheme;

  const MyApp({super.key, required this.initialTheme});


  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
bool isDark=false;

@override
void initState(){
  super.initState();
  loadTheme();
}

void loadTheme() async{
  final prefs=await SharedPreferences.getInstance();
  setState(() {
    isDark=prefs.getBool('isDarkMode') ?? false;
  });
}

void updateTheme(bool value){
  setState(() {
    isDark=value;
  });
}

  @override
 
 Widget build(BuildContext context){

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.grey[100],
    cardColor: Colors.white,
    textTheme: TextTheme(
      bodyMedium: TextStyle(
        color: Color(0xFF121212)
      )
    ),
    colorScheme: ColorScheme.light(
      primary: Colors.blue
    )),

    darkTheme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      cardColor: Color(0xFF1E1E1E),
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: Colors.white)
      ),
      colorScheme: ColorScheme.dark(
        primary: Colors.blue,
      )
    ),
    themeMode:isDark ? ThemeMode.dark : ThemeMode.light,
    home:SplashScreen(
      onThemeChanged:updateTheme,
      isDark:isDark,
    )
      
      );
   
 }
}