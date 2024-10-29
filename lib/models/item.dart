// lib/models/item.dart

class Item {
  final String code;
  final String name;
  final double price;

  Item({
    required this.code,
    required this.name,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'price': price,
    };
  }
}
