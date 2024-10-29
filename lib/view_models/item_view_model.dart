// lib/view_models/item_view_model.dart

import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/item.dart';

class ItemViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Item> items = [];
double get netAmount {
  return items.fold(0, (sum, item) => sum + item.price);
}

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
      price: total,
    );

    items.add(newItem);
    notifyListeners();
  }

  Future<void> saveAllItems() async {
    for (var item in items) {
      await _dbHelper.saveItems(item as List<Item>);
    }
  }
}
