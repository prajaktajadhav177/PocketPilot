import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pocket_pilot/models/transaction_model.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() =>
      _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  final box = Hive.box('transactions');

  String typeFilter = "all";
  String categoryFilter = "all";

  // 🔥 FIXED CATEGORY LIST (IMPORTANT)
  final List<String> allCategories = [
    "all",
    "Food",
    "Transport",
    "Shopping",
    "Bills",
    "Entertainment",
    "Health",
    "Education",
    "Other",
  ];

  List<TransactionModel> get transactions =>
      box.values
          .map((e) =>
              TransactionModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();

  List<TransactionModel> get filtered {
    return transactions.where((t) {
      if (typeFilter != "all" && t.type != typeFilter) return false;
      if (categoryFilter != "all" && t.category != categoryFilter)
        return false;
      return true;
    }).toList();
  }

  // 🎯 COLORS
  final primary = const Color(0xFF2563EB);
  final incomeColor = const Color(0xFF16A34A);
  final expenseColor = const Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Transactions"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [

          // 🔥 PREMIUM FILTER CARD
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // 🔷 TYPE FILTER (SEGMENT STYLE)
                const Text(
                  "Transaction Type",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    buildTypeButton("all"),
                    buildTypeButton("income"),
                    buildTypeButton("expense"),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔽 CATEGORY DROPDOWN
                const Text(
                  "Category",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: categoryFilter,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                      ),
                      items: allCategories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(
                            category.toUpperCase(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w500),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          categoryFilter = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🔥 LIST
          Expanded(
            child: filtered.isEmpty
                ? buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 10),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final t = filtered[index];
                      return buildTransactionCard(t);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // 🔥 TYPE BUTTON (PREMIUM SEGMENT)
  Widget buildTypeButton(String value) {
    final isSelected = typeFilter == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => typeFilter = value),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? primary : Colors.grey.withOpacity(0.1),
          ),
          child: Center(
            child: Text(
              value.toUpperCase(),
              style: TextStyle(
                color:
                    isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 TRANSACTION CARD (UPGRADED)
  Widget buildTransactionCard(TransactionModel t) {
    final isExpense = t.type == "expense";

    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [

          // ICON
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isExpense
                  ? expenseColor.withOpacity(0.1)
                  : incomeColor.withOpacity(0.1),
            ),
            child: Icon(
              isExpense
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              color: isExpense ? expenseColor : incomeColor,
            ),
          ),

          const SizedBox(width: 12),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.category,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
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

          // AMOUNT
          Text(
            "${isExpense ? "-" : "+"} ₹${t.amount}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isExpense ? expenseColor : incomeColor,
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 EMPTY STATE (UPGRADED)
  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 70,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 14),
          Text(
            "No transactions found",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}