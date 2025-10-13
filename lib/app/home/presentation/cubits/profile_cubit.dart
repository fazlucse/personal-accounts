import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileCubit extends Cubit<Profile> {
  final ProfileRepository repository;

  ProfileCubit(this.repository) : super(Profile(
          name: 'User Name',
          email: 'user@example.com',
          currency: 'BDT',
          budget: 40000,
        )) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    final profile = await repository.getProfile();
    emit(profile);
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? currency,
    double? budget,
  }) async {
    final currentProfile = state;
    final updatedProfile = Profile(
      name: name ?? currentProfile.name,
      email: email ?? currentProfile.email,
      currency: currency ?? currentProfile.currency,
      budget: budget ?? currentProfile.budget,
    );
    await repository.updateProfile(updatedProfile);
    emit(updatedProfile);
  }
}