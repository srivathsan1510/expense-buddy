import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

class AddEditExpense extends StatefulWidget {
  final Expense? existing;
  AddEditExpense({this.existing});
  @override
  State<AddEditExpense> createState() => _AddEditExpenseState();
}

class _AddEditExpenseState extends State<AddEditExpense> {
  final _title = TextEditingController();
  final _amount = TextEditingController();
  DateTime? _date;
  String _category = 'General';
  final _note = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _title.text = widget.existing!.title;
      _amount.text = widget.existing!.amount.toString();
      _date = widget.existing!.date;
      _category = widget.existing!.category;
      _note.text = widget.existing!.note ?? '';
    } else {
      _date = DateTime.now();
    }
  }

  void _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: _date ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now());
    if (picked != null) setState(()=>_date = picked);
  }

  void _save() {
    final title = _title.text.trim();
    final amt = double.tryParse(_amount.text.trim()) ?? 0;
    if (title.isEmpty || amt <= 0 || _date == null) return;
    final provider = Provider.of<ExpenseProvider>(context, listen:false);
    if (widget.existing != null) {
      final updated = Expense(id: widget.existing!.id, title: title, amount: amt, category: _category, date: _date!, note: _note.text.trim().isEmpty?null:_note.text.trim());
      provider.updateExpense(updated);
    } else {
      final id = Uuid().v4();
      final e = Expense(id: id, title: title, amount: amt, category: _category, date: _date!, note: _note.text.trim().isEmpty?null:_note.text.trim());
      provider.addExpense(e);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), child: Container(
      padding: EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _title, decoration: InputDecoration(labelText: 'Title')),
        TextField(controller: _amount, keyboardType: TextInputType.numberWithOptions(decimal:true), decoration: InputDecoration(labelText: 'Amount')),
        Row(children: [
          Expanded(child: Text('Date: ${_date!=null?_date!.toLocal().toString().split(' ')[0]:'Choose'}')),
          TextButton(onPressed: _pickDate, child: Text('Choose Date'))
        ]),
        TextField(controller: _note, decoration: InputDecoration(labelText: 'Note (optional)')),
        SizedBox(height:10),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          ElevatedButton(onPressed: _save, child: Text(widget.existing!=null?'Update':'Add'))
        ])
      ]),
    ));
  }
}
