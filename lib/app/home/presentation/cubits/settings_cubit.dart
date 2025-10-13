import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/settings_model.dart';
import '../../data/repositories/settings_repository.dart';

class SettingsCubit extends Cubit<Settings> {
  final SettingsRepository repository;

  SettingsCubit(this.repository) : super(Settings(language: 'en', theme: 'light')) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final settings = await repository.getSettings();
    emit(settings);
  }

  Future<void> setLanguage(String language) async {
    await repository.setLanguage(language);
    await loadSettings();
  }

  Future<void> setTheme(String theme) async {
    await repository.setTheme(theme);
    await loadSettings();
  }
}