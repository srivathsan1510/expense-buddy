import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import 'package:intl/intl.dart';

class ExpenseList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final expenseData = Provider.of<ExpenseProvider>(context);
    final expenses = expenseData.expenses;

    return expenses.isEmpty
        ? Center(child: Text('No expenses added yet!'))
        : ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (ctx, i) => Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              child: ListTile(
                leading: CircleAvatar(
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: FittedBox(
                      child: Text('₹${expenses[i].amount}'),
                    ),
                  ),
                ),
                title: Text(expenses[i].title),
                subtitle:
                    Text(DateFormat.yMMMd().format(expenses[i].date)),
              ),
            ),
          );
  }
}
