import 'package:flutter/material.dart';
import 'package:pocket_pilot/registration_screen.dart';
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
  buildPage(
    image: "assets/images/cal.svg",
    title: "Track Your Money",
    desc: "Log every expense in seconds and always know where your money is going.",
    gradient: [Color(0xFF0F172A), Color(0xFF1E293B)],
  ),
  buildPage(
    image: "assets/images/chart.svg",
    title: "Smart Insights",
    desc: "Get clear insights into your spending and make better financial choices.",
    gradient: [Color(0xFF0F172A), Color(0xFF1E293B)],
  ),
  buildPage(
    image: "assets/images/spending.svg",
    title: "Control Your Spending",
    desc: "Stay on top of your expenses and build better financial habits every day.",
    gradient: [Color(0xFF0F172A), Color(0xFF1E293B)],
  ),
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
  minimumSize: const Size(double.infinity, 55),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16), // was 14
  ),
  backgroundColor: Color(0xFFF59E0B),
  elevation: 6,
  shadowColor: Color(0xFFF59E0B).withOpacity(0.4),
),
  onPressed: () {
    if (currentIndex == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => RegistrationScreen()),
      );
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  },
  child: Text(
    currentIndex == 2 ? "Get Started" : "Next",
    style: TextStyle(
  color: Colors.black,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.5,
),
  ),
),
          )
        ],
      ),
    )
  );

 
 }

 Widget buildPage({
  required String image,
  required String title,
  required String desc,
  required List<Color> gradient,
}) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: gradient,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        Container(
           decoration: BoxDecoration(
    boxShadow: [
      BoxShadow(
       color: Color(0xFFF59E0B).withOpacity(0.25),
        blurRadius: 40,
        spreadRadius: 10,
      )
    ],
  ),
          child: SvgPicture.asset(
            image,
            height: 220,
           
          ),
        ),

        const SizedBox(height: 40),

        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 16),

        Text(
          desc,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
}

  Widget buildDot(int index) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    margin: const EdgeInsets.symmetric(horizontal: 5),
    height: 8,
    width: currentIndex == index ? 20 : 8,
    decoration: BoxDecoration(
      color: currentIndex == index
          ? Color(0xFFF59E0B)
          : Colors.white.withOpacity(0.4),
      borderRadius: BorderRadius.circular(10),
    ),
  );
}
}