import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubits/profile_cubit.dart';
import '../cubits/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  final Map<String, String> t;
  final bool isDark;
  final ThemeData themeData;

  const SettingsScreen({
    super.key,
    required this.t,
    required this.isDark,
    required this.themeData,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final profile = context.watch<ProfileCubit>().state;
    final budgetController = TextEditingController(text: profile.budget.toString());

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t['settings']!,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: themeData.textTheme.bodyLarge!.color),
          ),
          SizedBox(height: 16.h),
          Text(t['theme']!, style: TextStyle(fontSize: 14.sp, color: themeData.textTheme.bodyMedium!.color)),
          DropdownButton<String>(
            value: settings.theme,
            isExpanded: true,
            onChanged: (value) {
              if (value != null) {
                context.read<SettingsCubit>().setTheme(value);
              }
            },
            items: ['light', 'dark'].map((th) => DropdownMenuItem(value: th, child: Text(t[th]!))).toList(),
          ),
          SizedBox(height: 16.h),
          Text(t['currency']!, style: TextStyle(fontSize: 14.sp, color: themeData.textTheme.bodyMedium!.color)),
          DropdownButton<String>(
            value: profile.currency,
            isExpanded: true,
            onChanged: (value) {
              if (value != null) {
                context.read<ProfileCubit>().updateProfile(currency: value);
              }
            },
            items: [
              const DropdownMenuItem(value: 'BDT', child: Text('BDT - Bangladeshi Taka')),
              const DropdownMenuItem(value: 'USD', child: Text('USD - US Dollar')),
              const DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro')),
              const DropdownMenuItem(value: 'GBP', child: Text('GBP - British Pound')),
            ],
          ),
          SizedBox(height: 16.h),
          Text(t['monthlyBudget']!, style: TextStyle(fontSize: 14.sp, color: themeData.textTheme.bodyMedium!.color)),
          TextField(
            controller: budgetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          SizedBox(height: 16.h),
          Text(t['language']!, style: TextStyle(fontSize: 14.sp, color: themeData.textTheme.bodyMedium!.color)),
          DropdownButton<String>(
            value: settings.language,
            isExpanded: true,
            onChanged: (value) {
              if (value != null) {
                context.read<SettingsCubit>().setLanguage(value);
              }
            },
            items: [
              const DropdownMenuItem(value: 'en', child: Text('English')),
              const DropdownMenuItem(value: 'bn', child: Text('বাংলা')),
            ],
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              final budget = double.tryParse(budgetController.text);
              if (budget != null) {
                context.read<ProfileCubit>().updateProfile(budget: budget);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo[600],
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 48.h),
            ),
            child: Text(t['save']!),
          ),
        ],
      ),
    );
  }
}