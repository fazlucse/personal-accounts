import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  Future<Profile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('profile');
    if (jsonString != null) {
      final json = jsonDecode(jsonString);
      return Profile.fromJson(json);
    }
    return Profile(
      name: 'User Name',
      email: 'user@example.com',
      currency: 'BDT',
      phone: '',
      designation:'',
      budget: 40000,
    );
  }

  Future<void> updateProfile(Profile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(profile.toJson());
    await prefs.setString('profile', jsonString);
  }
}