import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'package:intl/intl.dart';

class ExpenseTile extends StatelessWidget {
  final Expense e;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  ExpenseTile({required this.e, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.yMMMd().format(e.date);
    return Card(
      margin: EdgeInsets.symmetric(vertical:6, horizontal:10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          child: Text('₹${e.amount.toInt()}'),
          backgroundColor: Colors.deepPurple.shade50,
        ),
        title: Text(e.title.toUpperCase()),
        subtitle: Text('${e.category} • $date'),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(icon: Icon(Icons.edit_outlined), onPressed: onEdit),
          IconButton(icon: Icon(Icons.delete_outline), onPressed: onDelete),
        ]),
      ),
    );
  }
}
