
class TransactionModel {
  final double amount;
  final String type;
  final String category;
  final String note;
  final String date;
  TransactionModel({
    required this.amount,
    required this.type,
    required this.category,
    required this.note,
    required this.date
  });

  Map<String, dynamic> toMap(){
    return{
      'amount':amount,
      'type':type,
      'category':category,
      'note':note,
      'date':date,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map){
    return TransactionModel(
      amount: map['amount'],
     type: map['type'],
      category: map['category'],
       note: map['note'],
        date: map['date']);
  }
}