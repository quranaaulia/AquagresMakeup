
import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'package:provider/provider.dart';
import 'transaction/transaction_provider.dart'; // Import the TransactionProvider

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()), // Provide TransactionProvider
      ],
      child: MaterialApp(
        title: 'Makeup Store',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomePage(),
      ),
    );
  }
}
