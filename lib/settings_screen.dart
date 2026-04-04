import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget{

  final bool isDark;
  final Function(bool) onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.isDark,
    required this.onThemeChanged

  });

  @override
  _SettingsScreenState createState()=> _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>{

late bool isDarkMode;

@override
void initState(){
  super.initState();
  isDarkMode=widget.isDark;
}

void toggleTheme(bool value) async{
  setState(() {
    isDarkMode=value;
  });
  final prefs=await SharedPreferences.getInstance();
  await prefs.setBool('isDarkMode', value);
  widget.onThemeChanged(value);
   }

  @override
  Widget build(BuildContext context){

      return Scaffold(
            body: ListTile(
              title: Text("Dark mode"),
              trailing: Switch(value: isDarkMode, onChanged:toggleTheme,
            ),
            )
      );
  } 
}