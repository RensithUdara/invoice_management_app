class Item {
  final String code;
  final String name;
  final double price;
  final int? quantity;
  final int? discount;
  final double? total;

  Item({
    required this.code,
    required this.name,
    required this.price,
    this.quantity,
    this.discount,
    this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'price': price,
      'quantity': quantity,
      'discount': discount,
      'total': total,
    };
  }
}
