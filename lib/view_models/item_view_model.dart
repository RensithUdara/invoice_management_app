import 'package:flutter/material.dart';
import '../models/item.dart';
import '../helpers/database_helper.dart';

class ItemViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Item> items = [];
  double netAmount = 0.0;

  Future<void> loadItems() async {
    items = await _dbHelper.fetchItems();
    notifyListeners();
  }

  Future<Item?> getItemByCode(String code) async {
    return await _dbHelper.fetchItemByCode(code);
  }

  void calculateAndAddItem(String code, String name, double price, int quantity, int discount) {
    final total = (price * quantity) * (100 - discount) / 100;
    final newItem = Item(
      code: code,
      name: name,
      price: price,
      quantity: quantity,
      discount: discount,
      total: total,
    );

    items.add(newItem);
    calculateNetAmount();
    notifyListeners();
  }

  void calculateNetAmount() {
    netAmount = items.fold(0, (sum, item) => sum + (item.total ?? 0));
    notifyListeners();
  }

  Future<void> saveAllItems() async {
    for (var item in items) {
      await _dbHelper.saveItem(item);
    }
  }
}
