// lib/app/cubits/tab_navigation_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class TabNavigationState {
  final int activeTabIndex;
  
  TabNavigationState({required this.activeTabIndex});
  
  TabNavigationState copyWith({int? activeTabIndex}) {
    return TabNavigationState(
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
    );
  }
}

class TabNavigationCubit extends Cubit<TabNavigationState> {
  TabNavigationCubit() : super(TabNavigationState(activeTabIndex: 0));

  void setActiveTabIndex(int index) {
    emit(state.copyWith(activeTabIndex: index));
  }

  void resetToHome() {
    emit(state.copyWith(activeTabIndex: 0));
  }
}