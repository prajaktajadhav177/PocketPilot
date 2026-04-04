import 'package:flutter/material.dart';
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
  Widget build(BuildContext context){
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 80,),
            Text("Lets get Started", 
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
            ),
            SizedBox(height: 10,),
            Text("You are just one step away!",
            style: TextStyle(
                  color: Colors.grey,
                ),
                ),
                SizedBox(height: 30,),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: "Enter Your Name",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
  
                    )
                  ),
                ),
                SizedBox(height: 30,),
        
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: ()async{
                    String name=_nameController.text.trim();
                    if(name.isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Please Enter Your Name")));
                        return;
                    }
                    final prefs=await SharedPreferences.getInstance();
                     bool success=await prefs.setString('username',name);

                     bool flagSaved=await prefs.setBool('isFirstTime', false);
                     
                     if(success && flagSaved){
                      if (!mounted) return;
                     Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>HomeScreen(
                      isDark: false, 
                      onThemeChanged: (_) {},
                     )));
                     }
                  }, child: Text("Continue")),
                )
          ],
        ),
      ),
    );
  }
}