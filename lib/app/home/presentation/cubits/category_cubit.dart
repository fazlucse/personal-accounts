// lib/presentation/cubits/category_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/category_repository.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _repo;

  CategoryCubit(this._repo) : super(const CategoryState());

  Future<void> loadCategories() async {
    emit(state.copyWith(status: CategoryStatus.loading));
    try {
      final income = await _repo.getByType('income');
      final expense = await _repo.getByType('expense');
      emit(state.copyWith(
        status: CategoryStatus.loaded,
        income: income,
        expense: expense,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CategoryStatus.error,
        error: e.toString(),
      ));
    }
  }
}