import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pocket_pilot/models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget{
  final TransactionModel? transaction;
  final int? index;
  const AddTransactionScreen({this.transaction,this.index});

@override
  _AddTransactionScreenState createState()=>_AddTransactionScreenState();
}



class _AddTransactionScreenState extends State<AddTransactionScreen>{

  final TextEditingController amountController=TextEditingController();
  final TextEditingController noteController=TextEditingController();

  String selectedType="expense";
  String selectedCategory="General";

@override
void initState(){
  super.initState();
  if(widget.transaction!=null){
    amountController.text=widget.transaction!.amount.toString();
    noteController.text=widget.transaction!.note;
    selectedType=widget.transaction!.type;
    selectedCategory=widget.transaction!.category;
  }
}

@override
void dispose() {
  amountController.dispose();
  noteController.dispose();
  super.dispose();
}
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller:amountController,
                keyboardType:TextInputType.number,
                decoration:InputDecoration(
                  hintText:"Enter Amount",
                )
              ),
              SizedBox(height: 15,),
              Row(
                children: [
                  ChoiceChip(label: Text("Expense"),
                  selected:selectedType=="expense",
                  onSelected:(_){
                    setState(() {
                      selectedType="expense";
                    });
                  }
                  ),
                  SizedBox(width: 10,),
                  ChoiceChip(label:Text("Income"),
                  selected:selectedType=="income",
                  onSelected: (_){
                    setState(() {
                      selectedType="income";
                    });
                  },),
                ]
              ),
                  SizedBox(height: 15,),
        
                  DropdownButtonFormField(
                    value:selectedCategory,
                    items:["Food", "Travel", "Shopping", "General"]
                    .map((e)=>DropdownMenuItem(
                            value:e,
                            child:Text(e),
                    ))
                    .toList(),
                    onChanged: (value){
                      setState(() {
                        selectedCategory=value.toString();
                      });
                    },
                  ),
                  SizedBox(height: 15,),
                  TextField(
                    controller:noteController,
                    decoration: InputDecoration(
                      hintText: "Enter note",
                    ),
                  ),
                  SizedBox(height: 20,),
        
                  ElevatedButton(onPressed: saveTransaction, child: Text(widget.transaction != null ? "Update" : "Save"),
                  )
              ],
              
            
          ),
        ),
      ),
    );
  }

void saveTransaction() async{
  final amount=double.tryParse(amountController.text);

  if(amount==null){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter Valid Amount")));
    return;
  }
  final transaction=TransactionModel(
    amount: amount, 
  type: selectedType, 
  category: selectedCategory, 
  note: noteController.text,
   date: DateTime.now().toString()
   );

   final box=Hive.box('transactions');
   if(widget.transaction!=null){
    await box.putAt(widget.index!,transaction.toMap());
   }else{
    await box.add(transaction.toMap());
   }
   Navigator.pop(context);
}

}