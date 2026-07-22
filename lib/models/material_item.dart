class MaterialItem {
  final int? id;
  final String name;
  final String articleNumber;
  final String unit;
  final String category;

  const MaterialItem({
    this.id,
    required this.name,
    required this.articleNumber,
    required this.unit,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'articleNumber': articleNumber,
      'unit': unit,
      'category': category,
    };
  }

  factory MaterialItem.fromMap(Map<String, dynamic> map) {
    return MaterialItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      articleNumber: map['articleNumber'] as String,
      unit: map['unit'] as String,
      category: map['category'] as String,
    );
  }

  MaterialItem copyWith({
    int? id,
    String? name,
    String? articleNumber,
    String? unit,
    String? category,
  }) {
    return MaterialItem(
      id: id ?? this.id,
      name: name ?? this.name,
      articleNumber: articleNumber ?? this.articleNumber,
      unit: unit ?? this.unit,
      category: category ?? this.category,
    );
  }
}
