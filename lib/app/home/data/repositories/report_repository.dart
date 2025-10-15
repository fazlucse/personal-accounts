import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction_model.dart';

class ReportRepository {
  Future<void> downloadReport(List<Transaction> transactions) async {
    final List<List<dynamic>> csvData = [
      ['Type', 'Category', 'Amount', 'Date', 'Description', 'Created By', 'Created At'],
      ...transactions.map((t) => [
        t.type,
        t.category,
        t.amount,
        t.date,
        t.description,
        t.created_by,
        t.created_at,
      ]),
    ];

    final csvString = const ListToCsvConverter().convert(csvData);
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/finance-report.csv';
    final file = File(filePath);
    await file.writeAsString(csvString);

    await Share.shareXFiles([XFile(filePath)], text: 'Finance Report');
  }
}