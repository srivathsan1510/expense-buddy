import 'package:hive/hive.dart';

class Expense {
  String id;
  String title;
  double amount;
  String category;
  DateTime date;
  String? note;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  });
}

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 0;

  @override
  Expense read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final amount = reader.readDouble();
    final category = reader.readString();
    final dateMillis = reader.readInt();
    final hasNote = reader.readBool();
    final note = hasNote ? reader.readString() : null;
    return Expense(
      id: id,
      title: title,
      amount: amount,
      category: category,
      date: DateTime.fromMillisecondsSinceEpoch(dateMillis),
      note: note,
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeDouble(obj.amount);
    writer.writeString(obj.category);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    if (obj.note != null) {
      writer.writeBool(true);
      writer.writeString(obj.note!);
    } else {
      writer.writeBool(false);
    }
  }
}
