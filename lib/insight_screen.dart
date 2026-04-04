import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart' show Hive;
import 'package:pocket_pilot/models/transaction_model.dart';


class InsightScreen extends StatefulWidget{

@override
  _InsightScreenState createState()=> _InsightScreenState();
}

class _InsightScreenState extends State<InsightScreen>{

  final box=Hive.box('transactions');
  List<TransactionModel> transactions=[];

  @override
  void initState(){
    super.initState();
    loadData();
  }

  void loadData(){
    
      transactions=box.values
    .map((e)=>TransactionModel.fromMap(Map<String,dynamic>.from(e))).toList();
  
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

@override
Widget build(BuildContext context){
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child:transactions.isEmpty
      ? Center(
        child: Text("No data To Analyze"),
      )
      :Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildCard("Income",totalIncome,Colors.green),
                buildCard("Expense",totalExpense,Colors.red)
              ],
            ),
            SizedBox(height: 20,),
            Text("Top Spending Category",
            style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8,),
            Text(topCategory),
            SizedBox(height: 10,),
            Expanded(child: ListView(
              children: categoryTotals.entries.map((e){
                return Column(
                  children: [
                    ListTile(
                      title: Text(e.key),
                      trailing: Text("₹ ${e.value.toStringAsFixed(0)}"),
                    ),
                    Divider()
                  ],
                );
              }).toList()
              
            ))
          ],
        ),
      )
  );

   
}
Widget buildCard(String title,double amount,Color color){
  return Container(
    width: MediaQuery.of(context).size.width*0.4,
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      
      children: [
        Text(title),
        SizedBox(height: 5,),
        Text("₹ ${amount.toStringAsFixed(0)}", 
        style: TextStyle(fontWeight: FontWeight.bold),),
      ],
    ),
  );
}
}