class Expense {
  final String id;
  final String type;
  final double amount;
  final DateTime date;
  final String notes;
  final String cropName;

  Expense({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.notes,
    required this.cropName,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String,
      cropName: json['cropName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
      'cropName': cropName,
    };
  }
} 