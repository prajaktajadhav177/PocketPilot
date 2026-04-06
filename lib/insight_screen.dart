import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart' show Hive;
import 'package:pocket_pilot/currency_helper.dart';
import 'package:pocket_pilot/models/transaction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class InsightScreen extends StatefulWidget{

@override
  _InsightScreenState createState()=> _InsightScreenState();
}

class _InsightScreenState extends State<InsightScreen>{

  final box=Hive.box('transactions');
  List<TransactionModel> transactions=[];
  int touchedIndex = -1;

  String selectedCurrency = "INR";

  @override
  void initState(){
    super.initState();
    loadData();
    loadCurrency();
  }

  void loadData(){
    
      transactions=box.values
    .map((e)=>TransactionModel.fromMap(Map<String,dynamic>.from(e))).toList();
  
  }

  void loadCurrency() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    selectedCurrency = prefs.getString('currency') ?? "INR";
  });
}

  double get totalIncome=>transactions
  .where((t)=>t.type=="income")
  .fold(0,(sum,t)=>sum+t.amount);

  double get totalExpense=>transactions
  .where((t)=>t.type=="expense")
  .fold(0,(sum,t)=>sum+t.amount);

  Map<String,double> get categoryTotals{
    Map<String,double> data={};
    for(var t in transactions){
      if(t.type=="expense"){
        data[t.category]=(data[t.category]??0)+t.amount;
      }
    }
    return data;
  }

  String get topCategory{
    if(categoryTotals.isEmpty) return "No data";

    var sorted = categoryTotals.entries.toList()
    ..sort((a,b)=>b.value.compareTo(a.value));
    return sorted.first.key;
  }

Map<String, double> getCategoryData() {
  Map<String, double> data = {};

  for (var t in transactions) {
    if (t.type == "expense") {
      data[t.category] = (data[t.category] ?? 0) + t.amount;
    }
  }
  return data;
}



@override

Widget build(BuildContext context) {
  //final isDark = Theme.of(context).brightness == Brightness.dark;

  final data = getCategoryData().entries.toList()
  ..sort((a, b) => b.value.compareTo(a.value));

final colors = [
  Color(0xFFF59E0B),
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.purple,
];

  return Scaffold(
    appBar: AppBar(
  title: Text(
    "Insights",
    style: GoogleFonts.orbitron(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    ),
  ),
  centerTitle: true,
  elevation: 0,
),
    body: transactions.isEmpty
        ?  Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.bar_chart,
          size: 50,
          color: Colors.grey.withOpacity(0.4)),
      SizedBox(height: 10),
      Text(
        "No insights yet",
        style: TextStyle(
          color: Colors.grey.withOpacity(0.6),
        ),
      ),
    ],
  ),
)
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                   gradient: LinearGradient(colors: [
                    Color(0xFF1E293B),   
                     Color(0xFF0F172A),
                   ]),
                    boxShadow: [
                    BoxShadow(
                     color: Color(0xFFF59E0B).withOpacity(0.1),
                     blurRadius: 20,
                     spreadRadius: 1,
                   )
                ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text("Total Overview",
                          style: TextStyle(color: Colors.white70)),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _bigStat("Income", totalIncome, Colors.greenAccent),
                          _bigStat("Expense", totalExpense, Colors.redAccent),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF59E0B).withOpacity(0.15)
                        ),
                        child: const Icon(Icons.insights,
                            color: Color(0xFFF59E0B)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "You spent the most on $topCategory this month ",
                          style: const TextStyle(
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
  height: 200,
  child: data.isEmpty
      ? const Center(child: Text("No data"))
      : PieChart(
  PieChartData(
    centerSpaceRadius: 40,
    sectionsSpace: 4,
    startDegreeOffset: -90,

    pieTouchData: PieTouchData(
  touchCallback: (event, response) {
    setState(() {
      if (!event.isInterestedForInteractions ||
          response == null ||
          response.touchedSection == null) {
        touchedIndex = -1;
        return;
      }

      touchedIndex =
          response.touchedSection?.touchedSectionIndex ?? -1;
    });
  },
),

    sections: List.generate(data.length, (i) {
      final e = data[i];
      final isTouched = i == touchedIndex;

      final percent =
          ((e.value / totalExpense) * 100).toStringAsFixed(0);

      return PieChartSectionData(
        value: e.value,
        radius: isTouched ? 70 : 60, // 👈 pop effect
        title: isTouched
            ? "${e.key}\n$percent%"
            : "",

        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),

        gradient: LinearGradient(
          colors: [
            colors[i % colors.length],
            colors[i % colors.length].withOpacity(0.6),
          ],
        ),
      );
    }),
  ),
)
        
),


                const SizedBox(height: 20),

                Text(
  "Category Breakdown",
  style: GoogleFonts.orbitron(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  ),
),

                const SizedBox(height: 12),

                ...categoryTotals.entries.map((e) {
                  final percent =
                      (e.value / totalExpense * 100).toStringAsFixed(1);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Row(
                      children: [

                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFF59E0B).withOpacity(0.1)                          ),
                          child: const Icon(
                            Icons.category,
                              size: 18),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(e.key,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),

                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                 value: e.value / totalExpense,
                                  minHeight: 6,
                                  backgroundColor: Colors.grey.withOpacity(0.2),
                                  valueColor: AlwaysStoppedAnimation(
                                   Color(0xFFF59E0B), // 👈 IMPORTANT
                                   ),
                                  ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
  "${CurrencyHelper.getSymbol(selectedCurrency)} "
  "${CurrencyHelper.fromINR(e.value, selectedCurrency).toStringAsFixed(0)}"),

                            Text("$percent%",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500)),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
  );
}
Widget buildCard(String title,double amount,Color color){
  return Container(
    width: MediaQuery.of(context).size.width*0.4,
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      
      children: [
        Text(
        title,
  style: const TextStyle(
    color: Colors.white70,
    fontSize: 12,
  ),),
        SizedBox(height: 5,),
        Text(  "${CurrencyHelper.getSymbol(selectedCurrency)} "
  "${CurrencyHelper.fromINR(amount, selectedCurrency).toStringAsFixed(0)}", 
        style: TextStyle(
    color: color,
    fontSize: 20, // bigger
    fontWeight: FontWeight.bold,
  ),)
      ],
    ),
  );
}

Widget _bigStat(String title, double value, Color color) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title,
          style: const TextStyle(color: Colors.white70)),
      const SizedBox(height: 6),
      Text(
        "${CurrencyHelper.getSymbol(selectedCurrency)} "
"${CurrencyHelper.fromINR(value, selectedCurrency).toStringAsFixed(0)}",
        style: TextStyle(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
}