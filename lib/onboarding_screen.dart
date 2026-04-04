import 'package:flutter/material.dart';
//import 'package:pocket_pilot/home_screen.dart';
import 'package:pocket_pilot/registration_screen.dart';
//import 'package:pocket_pilot/splash_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingScreen extends StatefulWidget{

  _OnboardingScreenState createState ()=>_OnboardingScreenState();

}

class _OnboardingScreenState extends State<OnboardingScreen>{

final PageController _controller=PageController();
int currentIndex=0;

@override
void dispose(){
  _controller.dispose();
  super.dispose();
}
  @override
 Widget build(BuildContext context){
  return Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: PageView(
              controller:_controller,
              physics:const BouncingScrollPhysics(),
              onPageChanged: (index){
                setState(() {
                  currentIndex=index;
                });
              },
              children: [
                buildPage("assets/images/cal.svg","Track Your Money", "Monitor your daily expenses"),
                buildPage("assets/images/chart.svg","Smart Insights", "Understand your spending"),
                buildPage("assets/images/wallet.svg","Multi-Currency", "Manage money globally"),
              ],
            ),
          ),
      
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index)=>buildDot(index)),
          ),
          SizedBox(height: 20),
      
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity,50),
                backgroundColor: Colors.blue
              ),
              onPressed: (){
                if(currentIndex==2){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>RegistrationScreen()));
                }else{
                  _controller.nextPage(duration:const Duration(milliseconds: 300), curve: Curves.ease,);
                  }
              },
              
               child: Text(currentIndex==2 ? "Get Started" : "Next")),
          )
        ],
      ),
    )
  );

 
 }

  Widget buildPage(String image,String title, String desc){

    return Container(
        color: Color.fromARGB(255, 219, 123, 68),
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              image,
              height: 220,
            ),
            SizedBox(height: 30,),
            Text(title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white
            ),
            ),
            SizedBox(height: 30),

            Text(desc,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white70
                
            ),)

          ],
        ),
    );

  }

  Widget buildDot(int index){
      return Container(margin: EdgeInsets.symmetric(horizontal: 5),
      width: 8,
      decoration: BoxDecoration(
        color: currentIndex==index?Colors.blue:Colors.grey,
        borderRadius: BorderRadius.circular(4)
      ),
      );
  }
}