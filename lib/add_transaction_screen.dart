import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
Widget build(BuildContext context) {
  final isEdit = widget.transaction != null;

  return Scaffold(
    
    appBar: AppBar(
  title: Text(
    isEdit ? "Edit Transaction" : "Add Transaction",
    style: GoogleFonts.orbitron(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    ),
  ),
  centerTitle: true,
  elevation: 0,
),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
           decoration: BoxDecoration(
  borderRadius: BorderRadius.circular(20),
  gradient: const LinearGradient(
    colors: [
      Color(0xFF1E293B),
      Color(0xFF020617),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  boxShadow: [
    BoxShadow(
      color: Color(0xFFF59E0B).withOpacity(0.15),
      blurRadius: 30,
    )
  ],
),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text("Amount",
                    style: TextStyle(color: Colors.white)),

                const SizedBox(height: 10),

                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                   fontSize: 30,
                   fontWeight: FontWeight.bold,
                 color: Color(0xFFF59E0B),
              ),
                  decoration:  InputDecoration(
                    hintText: "₹ 0.00",
                    hintStyle:TextStyle(
                      color: Colors.white.withOpacity(0.6)
                    ) ,
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text("Type",
              style: TextStyle(fontWeight: FontWeight.w600)),

          const SizedBox(height: 10),

          Row(
            children: [
              _buildTypeButton("expense"),
              const SizedBox(width: 10),
              _buildTypeButton("income"),
            ],
          ),

          const SizedBox(height: 20),

          const Text("Category",
              style: TextStyle(fontWeight: FontWeight.w600)),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child:DropdownButton<String>(
  value: selectedCategory,
  isExpanded: true,
  items: [
    
    "Food",
    "Transport",
    "Shopping",
    "Bills",
    "Entertainment",
    "Health",
    "Education",
    "General",
    "Other",
  ].map((e) => DropdownMenuItem(
    value: e,
    child: Text(e),
  )).toList(),
  onChanged: (value) {
    setState(() {
      selectedCategory = value!;
    });
  },
),
            ),
          ),

          const SizedBox(height: 20),

          const Text("Note",
              style: TextStyle(fontWeight: FontWeight.w600)),

          const SizedBox(height: 10),

          TextField(
            controller: noteController,
            decoration: InputDecoration(
              hintText: "Add a note...",
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              
              onPressed: saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF59E0B),
                padding:
                    const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                isEdit ? "Update Transaction" : "Save Transaction",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildTypeButton(String type) {
  final isSelected = selectedType == type;

  return Expanded(
    child: GestureDetector(
      onTap: () {
        setState(() {
          selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected
              ? (type == "expense"
                  ? Colors.red.withOpacity(0.8)
                  : Colors.green.withOpacity(0.8))
              : Colors.grey.withOpacity(0.1),
              
              
        ),
        child: Center(
          child: Text(
            type.toUpperCase(),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
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