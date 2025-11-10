// models/category_model.dart
class Category {
  final int? id;
  final String type;
  final String name;

  Category({this.id, required this.type, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'created_by': 'user',
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      type: map['type'],
      name: map['name'],
    );
  }
}