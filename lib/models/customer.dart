class Customer {
  final int? id;
  final String name;

  const Customer({
    this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String,
    );
  }

  Customer copyWith({
    int? id,
    String? name,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}