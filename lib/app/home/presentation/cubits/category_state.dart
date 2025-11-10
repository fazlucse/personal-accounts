// lib/presentation/cubits/category_state.dart
part of 'category_cubit.dart';

enum CategoryStatus { initial, loading, loaded, error }

class CategoryState extends Equatable {
  final CategoryStatus status;
  final List<String> income;
  final List<String> expense;
  final String? error;

  const CategoryState({
    this.status = CategoryStatus.initial,
    this.income = const [],
    this.expense = const [],
    this.error,
  });

  CategoryState copyWith({
    CategoryStatus? status,
    List<String>? income,
    List<String>? expense,
    String? error,
  }) {
    return CategoryState(
      status: status ?? this.status,
      income: income ?? this.income,
      expense: expense ?? this.expense,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, income, expense, error];
}