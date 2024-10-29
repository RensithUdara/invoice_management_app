import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_models/item_view_model.dart';
import 'views/quotation_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ItemViewModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quotation App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: QuotationScreen(),
    );
  }
}
