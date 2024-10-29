import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/item.dart';

class ItemViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Item> items = []; 
  List<Item> addedItems = []; 

  double get netAmount {
    return addedItems.fold(0.00, (sum, item) => sum + item.price);
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

    addedItems.add(newItem);
    notifyListeners();
  }

  Future<void> saveAllItems() async {
    for (var item in addedItems) {
      await _dbHelper.saveItems([item]); 
    }
  }
}
