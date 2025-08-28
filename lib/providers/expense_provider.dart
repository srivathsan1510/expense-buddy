import 'package:flutter/foundation.dart';
import '../models/expense.dart';

class ExpenseProvider with ChangeNotifier {
  final List<Expense> _expenses = [];

  List<Expense> get expenses => [..._expenses];

  void addExpense(String title, double amount, DateTime date) {
    final newExpense = Expense(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: date,
    );
    _expenses.add(newExpense);
    notifyListeners();
  }
}
