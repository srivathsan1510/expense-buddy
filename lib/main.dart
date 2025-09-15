import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/expense.dart';
import 'providers/expense_provider.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ExpenseAdapter());
  await Hive.openBox<Expense>(ExpenseProvider.boxName);
  runApp(ChangeNotifierProvider(create: (_) => ExpenseProvider(), child: MaterialApp(debugShowCheckedModeBanner: false, title: 'Expense Buddy', theme: ThemeData(primarySwatch: Colors.deepPurple), home: HomeScreen())));
}
