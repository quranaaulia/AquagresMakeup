
import 'package:flutter/material.dart';
import 'transaction.dart'; // Import the Transaction model

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }
}
