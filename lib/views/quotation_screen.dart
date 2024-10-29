import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../view_models/item_view_model.dart';
import 'item_list_screen.dart';

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
  String? _selectedItem;
  String? _selectedItemCode;
  bool isGeneral = true;

  final List<Map<String, dynamic>> _addedItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ItemViewModel>(context, listen: false).loadItems();
    });
  }

  void switchRole(bool general) {
    setState(() {
      isGeneral = general;
    });

    if (!general) {
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ItemListScreen(),
          ),
        ).then((_) {
          setState(() {
            isGeneral = true;
          });
        });
      });
    }
  }

  String getCurrentDate() {
    final DateTime now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(now);
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

    final total = (price * qty) * (100 - discount) / 100;
    _addedItems.add({
      'name': name,
      'price': price,
      'qty': qty,
      'discount': discount,
      'total': total,
    });

    viewModel.calculateAndAddItem(code, name, price, qty, discount);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Item added successfully")),
    );

    _codeController.clear();
    _priceController.clear();
    _qtyController.clear();
    _discountController.clear();
    _reasonController.clear();
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
        title: Row(
          children: [
            const Icon(Icons.note, color: Colors.white),
            const SizedBox(width: 8),
            Text("Quotation",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                  value: _selectedItem,
                  onChanged: (value) {
                    setState(() {
                      _selectedItem = value;
                    });
                  },
                  items: ["Aukland Offices", "Sri Lanka Office", "USA Office"]
                      .map((location) {
                    return DropdownMenuItem<String>(
                      value: location,
                      child: Text(location),
                    );
                  }).toList(),
                ),
                Text(
                  getCurrentDate(),
                  style: TextStyle(
                      color: Colors.blue.shade700, fontWeight: FontWeight.bold),
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
                            bottomLeft: Radius.circular(10)),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const Center(
                        child: Text(
                          'General',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
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
                            bottomRight: Radius.circular(10)),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const Center(
                        child: Text(
                          'Item',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
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
            DropdownButton<String>(
              hint: Text("Select Item Code",
                  style: TextStyle(color: Colors.grey.shade700)),
              value: _selectedItemCode,
              onChanged: (String? newValue) async {
                setState(() {
                  _selectedItemCode = newValue;
                });

                if (newValue != null) {
                  final item = await viewModel.getItemByCode(newValue);
                  if (item != null) {
                    setState(() {
                      _codeController.text = item.code;
                      _priceController.text = item.price.toStringAsFixed(2);
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Item not found")),
                    );
                  }
                }
              },
              items: viewModel.items.map((item) {
                return DropdownMenuItem<String>(
                  value: item.code,
                  child: Text(item.code),
                );
              }).toList(),
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
                  child: const Text("ADD" ,style: TextStyle(color: Colors.white,)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor:
                        MaterialStateProperty.all(Colors.blue.shade200),
                    dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        return states.contains(MaterialState.selected)
                            ? Colors.blue.shade50
                            : Colors.grey.shade50;
                      },
                    ),
                    headingTextStyle: TextStyle(
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 0.8,
                    ),
                    dataTextStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    columnSpacing: 30,
                    horizontalMargin: 16,
                    dividerThickness: 2.0,
                    columns: const [
                      DataColumn(label: Text("Item")),
                      DataColumn(label: Text("Price")),
                      DataColumn(label: Text("Qty")),
                      DataColumn(label: Text("Discount")),
                      DataColumn(label: Text("Total")),
                    ],
                    rows: _addedItems.map((item) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(item['name'],
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                          DataCell(
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(item['price'].toStringAsFixed(2),
                                  style: const TextStyle(fontSize: 13)),
                            ),
                          ),
                          DataCell(
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(item['qty'].toString(),
                                  style: const TextStyle(fontSize: 13)),
                            ),
                          ),
                          DataCell(
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text("${item['discount']}%",
                                  style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontSize: 13)),
                            ),
                          ),
                          DataCell(
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(item['total'].toStringAsFixed(2),
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
