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
}