import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pocket_pilot/add_transaction_screen.dart';
import 'package:pocket_pilot/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:pocket_pilot/models/transaction_model.dart';
class HomeScreen extends StatefulWidget{

  final bool isDark;
  final Function(bool) onThemeChanged;

  const HomeScreen({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
  });



  _HomeScreenState createState()=> _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen>{

  
  
  final box=Hive.box('transactions');

  String username= "";
  String getGreeting(){
    final hour=DateTime.now().hour;
    if(hour<12) return "Good Morning";
    if(hour<17) return "Good Afternoon";
    return "Good Evening";
  }

  List<TransactionModel> transactions=[];

  double get totalBalance{
    double balance=0;
    for(var t in transactions){
        if(t.type=="expense"){
          balance-=t.amount;
        }
        else {
          balance +=t.amount;
          }
    }
    return balance;
  }

  double get totalSpent{
    return transactions
      .where((t)=>t.type=="expense")
      .fold(0,(sum,t)=>sum+t.amount);
  }

  double get totalEarned{
    return transactions
      .where((t)=>t.type=="income")
      .fold(0,(sum,t)=>sum+t.amount);
  }

    Map<String,double> getCategoryData(){
    Map<String,double> data={};

    for(var t in transactions){
      if(t.type=="expense"){
        data[t.category]=(data[t.category] ?? 0)+t.amount;
      }
    }
    return data;
  }

  @override
  void initState(){
    super.initState();
    loadUser();
    loadTransactions();
  }

  
  void loadUser() async{
    final prefs=await SharedPreferences.getInstance();
    setState(() {
      username=prefs.getString('username') ?? "User";
    });
  }

  void loadTransactions(){

    setState(() {
      transactions=box.values
      .map((e)=>TransactionModel.fromMap(Map<String,dynamic>.from(e)))
      .toList();
    });
  }


  @override
  
  Widget build(BuildContext context){
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
          backgroundColor:Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                 Text("${getGreeting()}, $username",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),),
                
                Spacer(),
                IconButton(onPressed:(){
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>SettingsScreen(isDark: widget.isDark, onThemeChanged: widget.onThemeChanged)));
                }, icon: Icon(Icons.settings,
                color:Theme.of(context).iconTheme.color))
              ],

              
            ),
             SizedBox(height: 4),

    Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "Welcome back",
        style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6)),
      ),
    ),
    SizedBox(height: 20,),
    Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDark
          ? [
        Color(0xFF0F2027),
        Color(0xFF203A43),
        Color(0xFF2C5364),      
          ]
          :[
            Color(0xFF2196F3),
  Color(0xFF64B5F6),],
          begin: Alignment.topLeft,
          end:Alignment.bottomRight),
          boxShadow: [
            BoxShadow(
              color: isDark 
              ? Colors.black.withOpacity(0.2)
              : Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset:Offset(0,5)
            )
          ]
      ),
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Total Balance",
          style: TextStyle(
            color: Colors.white
          ),),
          SizedBox(height: 5,),
          Text(
        "₹ ${totalBalance.toStringAsFixed(0)}",
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),

      SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildStat("Spent", "₹ ${totalSpent.toStringAsFixed(0)}"),
          buildStat("Earned", "₹ ${totalEarned.toStringAsFixed(0)}"),
        ],
      ),

      
        ],
      ),
    ),

    SizedBox(height: 20,),
    Text("Spending Breakdown",
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold
    ),),
    SizedBox(height: 10,),
    Container(height: 200,
    child: PieChart(
      PieChartData(
        sections: getCategoryData().entries.map((e){
          return PieChartSectionData(
            value: e.value,
            title: e.key
          );
        }).toList(),
      )
    ),),
  
    SizedBox(height: 20,),
      Text("Recent Transactions",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
        SizedBox(height: 10),

          Expanded(child: box.isEmpty
          ? Center(child: Text("No transactions yet",
          textAlign: TextAlign.center,
    style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6)),))
          :ListView.builder(
            itemCount: box.length,
            itemBuilder: (context,index){
              final map=Map<String,dynamic>.from(box.getAt(index));
              final t=TransactionModel.fromMap(map);
             
            return GestureDetector(
              onTap: () async{
                await Navigator.push(context,
                MaterialPageRoute(builder: (_)=>AddTransactionScreen(
                  transaction: t,
                  index: index,
                )));
                loadTransactions();
              },
              child: Dismissible(
                key:ValueKey(t.date),
                onDismissed: (_){
                  final deletedItem=box.getAt(index);
                  box.deleteAt(index);
                  loadTransactions(); 
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Transaction Deleted"),
                  action: SnackBarAction(label: "Undo", onPressed:(){
                    box.add(deletedItem);
                    loadTransactions();
                  }),));
                },
                background: Container(
                  alignment: Alignment.centerRight,
                    margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: Icon(Icons.delete,color: Colors.white,),
                  
                ),
                direction: DismissDirection.endToStart,
                  child: Container(
                        margin: EdgeInsets.only(bottom:10),
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Theme.of(context).cardColor
                        ),
                        child: Row(children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context).brightness==Brightness.dark
                            ? Colors.grey[800]
                            :Colors.grey[200],
                            child: Icon(t.type=="expense" 
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                            color: t.type=="expense"
                            ? Colors.red
                            :Colors.green,
                            ),
                          ),
                          SizedBox(width:10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.category,
                                      overflow: TextOverflow.ellipsis,),
                              Text(t.note,
                                      overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                      fontSize: 12, color:Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6)
                                )
                              )
                            ],
                          ),
                          Spacer(),
                          Text("${t.type=="expense" ? "-" : "+"} ₹${t.amount}",
                           style: TextStyle(
                                color: t.type == "expense"
                                    ? Colors.red
                                    : Colors.green,
                              ),)
                        ],),
                    ),
                ),
            );
              
            },
          ))

          ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 6,
      onPressed: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => AddTransactionScreen()),
  );

  loadTransactions();
},
      child: Icon(Icons.add,size: 28,),),
    );
  }

  Widget buildStat(String title,String value){
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,style: TextStyle(color: Colors.white70),),
          SizedBox(height: 5,),
          Text(value,
          style: TextStyle(
              color: Colors.white,
          fontWeight: FontWeight.bold
          )
          ),
          
        ],
    );
  }

}