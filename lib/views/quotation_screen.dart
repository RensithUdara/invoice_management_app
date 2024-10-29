import 'package:flutter/material.dart';
import 'package:flutter_app/helpers/database_helper.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../view_models/item_view_model.dart';
import '../models/item.dart';

class QuotationScreen extends StatefulWidget {
  const QuotationScreen({super.key});

  @override
  QuotationScreenState createState() => QuotationScreenState();
}

class QuotationScreenState extends State<QuotationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  String? _selectedItemCode;
  late TabController _tabController;
  bool isGeneral = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ItemViewModel>(context, listen: false).loadItems();
    });
  }

  void switchRole(bool general) {
    setState(() {
      isGeneral = general;
    });
  }

  String getCurrentDate() {
    final DateTime now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(now);
  }

  void _fetchItemDetails(String code) async {
    final item = await _dbHelper.fetchItemByCode(code);
    if (item != null) {
      setState(() {
        _codeController.text = item.code;
        _priceController.text = item.price.toString();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item not found")),
      );
    }
  }

  void _addItem(ItemViewModel viewModel) {
    final code = _codeController.text;
    final name = _selectedItemCode;
    final price = double.tryParse(_priceController.text);
    final qty = int.tryParse(_qtyController.text);
    final discount = int.tryParse(_discountController.text) ?? 0;

    if (code.isEmpty || name == null || price == null || qty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    viewModel.calculateAndAddItem(code, name, price, qty, discount);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Item added successfully")),
    );

    _codeController.clear();
    _priceController.clear();
    _qtyController.clear();
    _discountController.clear();
    setState(() {
      _selectedItemCode = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ItemViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Row(
          children: [
            Icon(Icons.note, color: Colors.white),
            SizedBox(width: 8),
            Text("Quotation",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline_rounded,
                color: Colors.white, size: 30),
            onPressed: () async {
              await viewModel.saveAllItems();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Items saved successfully!")),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Office selection dropdown and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  hint: Text(
                    "Aukland Offices",
                    style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold),
                  ),
                  value: _selectedItemCode,
                  onChanged: (value) async {
                    if (value != null) {
                      final item = await viewModel.getItemByCode(value);
                      if (item != null) {
                        setState(() {
                          _selectedItemCode = item.code;
                          _codeController.text = item.code;
                          _priceController.text = item.price.toString();
                        });
                      }
                    }
                  },
                  items: viewModel.items.isNotEmpty
                      ? viewModel.items.map((item) {
                          return DropdownMenuItem<String>(
                            value: item.code,
                            child: Text(item.name),
                          );
                        }).toList()
                      : [],
                ),
                Text(
                  getCurrentDate(),
                  style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      switchRole(true);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isGeneral ? Colors.blue.shade700 : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const Center(
                        child: Text(
                          'General',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      switchRole(false);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: !isGeneral ? Colors.blue.shade700 : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const Center(
                        child: Text(
                          'Item',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Net Amount",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  Text(viewModel.netAmount.toStringAsFixed(2),
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Input fields and ADD button
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: "Item Code",
                labelStyle: TextStyle(color: Colors.grey.shade700),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onChanged: (value) {
                _fetchItemDetails(value);
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: "Reason",
                labelStyle: TextStyle(color: Colors.grey.shade700),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: "Price",
                labelStyle: TextStyle(color: Colors.grey.shade700),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qtyController,
                    decoration: InputDecoration(
                      labelText: "Qty",
                      labelStyle: TextStyle(color: Colors.grey.shade700),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _discountController,
                    decoration: InputDecoration(
                      labelText: "Discount %",
                      labelStyle: TextStyle(color: Colors.grey.shade700),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _addItem(viewModel);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    backgroundColor: Colors.blue.shade700,
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("ADD"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Data table with horizontal scrolling
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor:
                      MaterialStateProperty.all(Colors.grey.shade200),
                  columns: const [
                    DataColumn(
                        label: Text("Item",
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text("Price",
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text("Qty",
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text("Discount",
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text("Total",
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: viewModel.items.map((item) {
                    return DataRow(
                      cells: [
                        DataCell(Text(item.name)),
                        DataCell(Text(item.price.toString())),
                        DataCell(Text(_qtyController.text)),
                        DataCell(Text(_discountController.text)),
                        DataCell(Text((item.price).toStringAsFixed(2))),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
