import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import 'package:intl/intl.dart';
import 'dart:html' as html;

class ExpenseProvider extends ChangeNotifier {
  static const String boxName = 'expensesBox';
  late Box<Expense> _box;
  List<Expense> _items = [];

  ExpenseProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = Hive.box<Expense>(boxName);
    _items = _box.values.toList().cast<Expense>();
    notifyListeners();
  }

  List<Expense> get items => _items..sort((a,b)=>b.date.compareTo(a.date));

  Future<void> addExpense(Expense e) async {
    await _box.put(e.id, e);
    _items = _box.values.toList().cast<Expense>();
    notifyListeners();
  }

  Future<void> updateExpense(Expense e) async {
    await _box.put(e.id, e);
    _items = _box.values.toList().cast<Expense>();
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    await _box.delete(id);
    _items = _box.values.toList().cast<Expense>();
    notifyListeners();
  }

  double get totalExpense => _items.where((e)=>true).fold(0.0,(s,e)=>s + e.amount);

  Map<String,double> categoryTotals([DateTime? month]) {
    final Map<String,double> m = {};
    final list = month == null ? _items : _items.where((e)=>e.date.year==month.year && e.date.month==month.month).toList();
    for (var e in list) {
      m[e.category] = (m[e.category] ?? 0) + e.amount;
    }
    return m;
  }

  List<Expense> search(String q, [DateTime? month]) {
    final list = month == null ? _items : _items.where((e)=>e.date.year==month.year && e.date.month==month.month).toList();
    if (q.trim().isEmpty) return list;
    final low = q.toLowerCase();
    return list.where((e)=>e.title.toLowerCase().contains(low) || e.category.toLowerCase().contains(low)).toList();
  }

  Future<void> seedSample() async {
    if (_items.isNotEmpty) return;
    final u = Uuid();
    final now = DateTime.now();
    final sample = [
      Expense(id: u.v4(), title: 'Groceries', amount: 500, category: 'Groceries', date: now),
      Expense(id: u.v4(), title: 'Bus Ticket', amount: 40, category: 'Transport', date: now.subtract(Duration(days:2))),
      Expense(id: u.v4(), title: 'Coffee', amount: 120, category: 'Food', date: now.subtract(Duration(days:1))),
    ];
    for (var e in sample) {
      await _box.put(e.id, e);
    }
    _items = _box.values.toList().cast<Expense>();
    notifyListeners();
  }

  String _toCsvString() {
    final buffer = StringBuffer();
    buffer.writeln('id,title,amount,category,date,note');
    final fmt = DateFormat('yyyy-MM-dd');
    for (var e in _items) {
      final line = [
        e.id,
        e.title.replaceAll(',', ' '),
        e.amount.toStringAsFixed(2),
        e.category,
        fmt.format(e.date),
        e.note ?? ''
      ].join(',');
      buffer.writeln(line);
    }
    return buffer.toString();
  }

  void exportCsv() {
    final csv = _toCsvString();
    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'expenses.csv')
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
