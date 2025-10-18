import 'dart:ffi';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

class TransactionCubit extends Cubit<List<Transaction>> {
  final TransactionRepository repository;

  TransactionCubit(this.repository) : super([]) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final transactions = await repository.getTransactions();
    emit(transactions);
  }

  Future<void> addTransaction(Transaction transaction) async {
    await repository.addTransaction(transaction);
    await loadTransactions();
  }
  Future<void> deleteTransaction(Transaction transaction) async {
    await repository.deleteTransaction(transaction.id.toString()); // Call repository
    final updatedList = state.where((t) => t.id != transaction.id).toList();
    emit(updatedList);
  }
}