import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_pilot/add_transaction_screen.dart';
import 'package:pocket_pilot/all_transactions_screen.dart';
import 'package:pocket_pilot/currency_helper.dart';
import  'package:pocket_pilot/insight_screen.dart';
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
  double goal=0;
  String selectedCurrency = "INR";
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
    loadGoal();
    loadCurrency();
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

  void loadGoal() async{
    final prefs=await SharedPreferences.getInstance();
    setState(() {
      goal=prefs.getDouble('goal') ?? 0;
    });
  }

  void loadCurrency() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    selectedCurrency = prefs.getString('currency') ?? "INR";
  });
}



  @override
  
  Widget build(BuildContext context){
    //final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = getCategoryData().entries.toList()
  ..sort((a, b) => b.value.compareTo(a.value));

  final limitedData = data.take(4).toList();

  final colors = [
  Color(0xFFF59E0B), 
  Colors.red,
  Colors.green,
  Colors.blue,
];
    return Scaffold(
          backgroundColor:Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   Text(
                  "${getGreeting()}, $username",
                     style: GoogleFonts.orbitron(
                      fontSize: 20,
                        fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                     ),
                ),
            
                          Spacer(),
                          
                          IconButton(onPressed: (){
                             
                            Navigator.push(context, MaterialPageRoute(builder: (_)=>InsightScreen()));
                          }, icon: Icon(Icons.bar_chart,
                          color: Theme.of(context).iconTheme.color?.withOpacity(0.8),),
                          tooltip: "Insights"),
                  
                 
                  IconButton(onPressed:() async{

                    final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => SettingsScreen(
      isDark: widget.isDark,
      onThemeChanged: widget.onThemeChanged,
    ),
  ),
);

if (result != null) {
  if (result == "reset") {
    loadTransactions(); 
  } else {
        setState(() {
      username = result;
    });
  }
}
loadCurrency();
                  }, icon: Icon(Icons.settings,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.8),),
                  tooltip: "Settings")
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
                SizedBox(height: 24,),
              Container(
  width: double.infinity,
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    
    borderRadius: BorderRadius.circular(24),
    gradient: const LinearGradient(
  colors: [
    Color(0xFF1E293B), 
    Color(0xFF0F172A),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
),
    boxShadow: [
  BoxShadow(
    color: Color(0xFFF59E0B).withOpacity(0.15),
    blurRadius: 30,
    spreadRadius: 2,
  )
],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      const Text("Available balance",
          style: TextStyle(color: Colors.white70)),

      const SizedBox(height: 6),

      Text(
  "${CurrencyHelper.getSymbol(selectedCurrency)} "
"${CurrencyHelper.fromINR(totalBalance, selectedCurrency).toStringAsFixed(0)}",
  style: const TextStyle(
    color: Color(0xFFF59E0B), // 👈 change
    fontSize: 28,
    fontWeight: FontWeight.bold,
  ),
),

      const SizedBox(height: 16),

      Divider(color: Colors.white.withOpacity(0.3)),

      const SizedBox(height: 16),

      Row(
        children: [

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                _buildMiniStat("Spent", totalSpent),
                const SizedBox(height: 14),
                _buildMiniStat("Earned", totalEarned),

              ],
            ),
          ),

          SizedBox(
            height: 120,
            width: 120,
            child: getCategoryData().isEmpty
                ? const SizedBox()
                :PieChart(
  PieChartData(
    centerSpaceRadius: 32,
    sectionsSpace: 3,
    startDegreeOffset: -90,
    sections: List.generate(limitedData.length, (i) {
      final e = limitedData[i];
      return PieChartSectionData(
        value: e.value,
        gradient: LinearGradient(
  colors: [
    colors[i % colors.length],
    colors[i % colors.length].withOpacity(0.6),
  ],
),
        title: "",
        radius: 22,
      );
    }),
  ),
)
          ),
        ],
      ),
    ],
  ),
),
            

                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: SizedBox(height: 20,),
                ),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
  "Recent Transactions",
  style: GoogleFonts.orbitron(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  ),
),
                        Spacer(),

                        IconButton(onPressed: 
                        (){
                          Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => AllTransactionsScreen()),
  );
                        }, icon: Icon(Icons.open_in_full))
                    ],
                  ),
                    SizedBox(height: 10),
            
              box.isEmpty
            ? Center(
  child: Column(
    children: [
      const SizedBox(height: 40),

      Icon(
        Icons.receipt_long,
        size: 50,
        color: Theme.of(context)
            .iconTheme
            .color
            ?.withOpacity(0.3),
      ),

      const SizedBox(height: 12),

      Text(
        "No transactions yet",
        style: TextStyle(
          color: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.color
              ?.withOpacity(0.6),
        ),
      ),
    ],
  ),
)
            :ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
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
  margin: const EdgeInsets.only(bottom: 10),
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    color: Theme.of(context).cardColor,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 8,
        offset: const Offset(0, 3),
      )
    ],
  ),
  child: Row(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: t.type == "expense"
    ? Colors.red.shade400.withOpacity(0.1)
    : Colors.green.shade400.withOpacity(0.1)
        ),
        child: Icon(
          t.type == "expense"
              ? Icons.arrow_downward
              : Icons.arrow_upward,
          color:
              t.type == "expense" ? Colors.red : Colors.green,
        ),
      ),

      const SizedBox(width: 12),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.category,
              style: const TextStyle(
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              t.note,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),

      Text(
        "${t.type == "expense" ? "-" : "+"} "
"${CurrencyHelper.getSymbol(selectedCurrency)}"
"${CurrencyHelper.fromINR(t.amount, selectedCurrency).toStringAsFixed(0)}",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: t.type == "expense"
              ? Colors.red
              : Colors.green,
        ),
      ),
    ],
  ),
),
                      
                  ),
              );
                
              },
              
            )
            
            ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        
       backgroundColor: const Color(0xFFF59E0B),
foregroundColor: Colors.black,
      elevation: 6,
      onPressed: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => AddTransactionScreen()),
  );

  loadTransactions();
},
      child: Icon(Icons.add,size: 28,),
      
      ),
    );
  }

 Widget buildStat(String title, double value, Color color) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: TextStyle(color: Colors.white70)),
      SizedBox(height: 4),
      Text(
      "${CurrencyHelper.getSymbol(selectedCurrency)} "
"${CurrencyHelper.fromINR(value, selectedCurrency).toStringAsFixed(0)}",
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

Widget _buildMiniStat(String title, double value) {
  final isExpense = title == "Spent";

  return Row(
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
color: isExpense 
  ? Colors.red.shade400 
  : Colors.green.shade400,        ),
      ),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white70)),
          Text(
            "${CurrencyHelper.getSymbol(selectedCurrency)} "
"${CurrencyHelper.fromINR(value, selectedCurrency).toStringAsFixed(0)}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      )
    ],
  );
}

}