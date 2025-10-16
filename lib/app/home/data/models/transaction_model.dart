class Transaction {
  final int id;
  final String type;
  final String category;
  final double amount;
  final String date;
  final String? description;
  final String created_by;
  final String created_at;

  Transaction({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
     this.description,
    String? created_by = 'Unknown',
    String? created_at,
  }) : created_by = created_by ?? 'system',
        created_at = created_at ?? DateTime.now().toIso8601String();

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: json['type'],
      category: json['category'],
      amount: json['amount'].toDouble(),
      date: json['date'],
      description: json['description'],
      created_by: json['created_by'] ?? 'Unknown',
      created_at: json['created_at'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'amount': amount,
      'date': date,
      'description': description,
      'created_by': created_by,
      'created_at': created_at,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      type: map['type'],
      category: map['category'],
      amount: map['amount'],
      date: map['date'],
      description: map['description'],
      created_by: map['created_by'] ?? 'Unknown',
      created_at: map['created_at'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'amount': amount,
      'date': date,
      'description': description,
      'created_by': created_by,
      'created_at': created_at,
    };
  }
}