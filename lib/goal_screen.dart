import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalScreen extends StatefulWidget{

  @override
  _GoalScreenState createState()=> _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen>{

  final TextEditingController goalController=TextEditingController();

  double goal=0;

  @override 
  void initState(){
    super.initState();
    loadGoal();
  }

  void loadGoal() async{
    final prefs=await SharedPreferences.getInstance();
    setState(() {
      goal=prefs.getDouble('goal') ?? 0;
      goalController.text=goal==0 ? "" :goal.toString();

    });
  }
  void saveGoal(){
    final value=double.tryParse(goalController.text);
    if(value==null){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter valid goal")));
      return;
    }
  }

  Widget build(BuildContext context){
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(

          children: [
            TextField(
                controller: goalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter Your Saving goal",
                  border: OutlineInputBorder()
                ),
            ),
            SizedBox(height: 15,),
            ElevatedButton(onPressed: 
            saveGoal, child: Text("Save Goal"))
          ],
        ),
      ),
    );
  }
}