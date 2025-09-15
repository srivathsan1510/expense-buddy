import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_tile.dart';
import '../widgets/add_edit_expense.dart';
import '../models/expense.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _search = '';
  DateTime? _month;
  final _monthOptions = <DateTime?>[null];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _monthOptions.add(DateTime(now.year, now.month));
    final prev = DateTime(now.year, now.month - 1);
    _monthOptions.add(prev);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(context, listen:false).seedSample();
    });
  }

  void _openAdd([Expense? e]) {
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => AddEditExpense(existing: e));
  }

  List<PieChartSectionData> _sections(Map<String,double> data) {
    final colors = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.brown];
    final entries = data.entries.toList();
    final total = entries.fold(0.0, (s,e)=>s+e.value);
    final list = <PieChartSectionData>[];
    for (int i=0;i<entries.length;i++) {
      final val = entries[i].value;
      final percent = total==0?0:(val/total*100);
      list.add(PieChartSectionData(value: val, title: '${percent.toStringAsFixed(0)}%', color: colors[i%colors.length], radius: 50, showTitle: true));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ExpenseProvider>(context);
    final filtered = prov.search(_search, _month);
    final cat = prov.categoryTotals(_month);
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    return Scaffold(
      appBar: AppBar(title: Text('Expense Buddy'), actions: [
        IconButton(icon: Icon(Icons.download), onPressed: ()=>prov.exportCsv()),
        IconButton(icon: Icon(Icons.filter_alt), onPressed: (){
          _month = _month==null?DateTime(DateTime.now().year, DateTime.now().month):null;
          setState(()=>{});
        })
      ]),
      body: Column(children: [
        Card(margin: EdgeInsets.all(12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Padding(padding: EdgeInsets.all(14), child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Total', style: TextStyle(fontSize:14)),
            SizedBox(height:6),
            Text(currency.format(prov.totalExpense), style: TextStyle(fontSize:20, fontWeight: FontWeight.bold)),
            SizedBox(height:6),
            Text('Month: ${_month!=null?DateFormat.yMMM().format(_month!):"All"}')
          ])),
          SizedBox(width:140, height:120, child: cat.isEmpty?Center(child:Text('No data')):PieChart(PieChartData(sections: _sections(cat), centerSpaceRadius:20)))
        ]))),
        Padding(padding: EdgeInsets.symmetric(horizontal:12), child: Row(children: [
          Expanded(child: TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search title or category'), onChanged: (v){setState(()=>_search=v);})),
          SizedBox(width:10),
          DropdownButton<DateTime?>(value: _month, items: _monthOptions.map((m)=>DropdownMenuItem(value:m, child: Text(m==null?'All':DateFormat.yMMM().format(m)))).toList(), onChanged: (v){setState(()=>_month=v);})
        ])),
        Expanded(child: filtered.isEmpty?Center(child:Text('No expenses added yet!')):ListView.builder(itemCount: filtered.length, itemBuilder: (ctx,i){
          final e = filtered[i];
          return Dismissible(key: Key(e.id), background: Container(color:Colors.red), onDismissed: (_){prov.deleteExpense(e.id);}, child: ExpenseTile(e: e, onDelete: ()=>prov.deleteExpense(e.id), onEdit: ()=>_openAdd(e)));
        }))
      ]),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.add), onPressed: ()=>_openAdd()),
    );
  }
}
