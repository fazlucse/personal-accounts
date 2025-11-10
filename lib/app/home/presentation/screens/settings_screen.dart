import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubits/profile_cubit.dart';
import '../cubits/settings_cubit.dart';
import '../widgets/category_bottom_sheet.dart';

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
    final budgetController = TextEditingController(
      text: profile.budget.toString(),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t['settings']!,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? themeData.textTheme.bodyLarge!.color
                  : Colors.black,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            t['theme']!,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark
                  ? themeData.textTheme.bodyMedium!.color
                  : Colors.black,
            ),
          ),
          DropdownButton<String>(
            value: settings.theme,
            isExpanded: true,
            onChanged: (value) {
              if (value != null) {
                context.read<SettingsCubit>().setTheme(value);
              }
            },
            items: ['light', 'dark']
                .map(
                  (th) => DropdownMenuItem(
                    value: th,
                    child: Text(
                      t[th]!,
                      style: TextStyle(
                        color: isDark
                            ? themeData.textTheme.bodyMedium!.color
                            : Colors.black,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 16.h),
          Text(
            t['currency']!,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark
                  ? themeData.textTheme.bodyMedium!.color
                  : Colors.black,
            ),
          ),
          DropdownButton<String>(
            value: profile.currency,
            isExpanded: true,
            onChanged: (value) {
              if (value != null) {
                context.read<ProfileCubit>().updateProfile(currency: value);
              }
            },
            items: [
              DropdownMenuItem(
                value: 'BDT',
                child: Text(
                  'BDT - Bangladeshi Taka',
                  style: TextStyle(
                    color: isDark
                        ? themeData.textTheme.bodyMedium!.color
                        : Colors.black,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 'USD',
                child: Text(
                  'USD - US Dollar',
                  style: TextStyle(
                    color: isDark
                        ? themeData.textTheme.bodyMedium!.color
                        : Colors.black,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 'EUR',
                child: Text(
                  'EUR - Euro',
                  style: TextStyle(
                    color: isDark
                        ? themeData.textTheme.bodyMedium!.color
                        : Colors.black,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 'GBP',
                child: Text(
                  'GBP - British Pound',
                  style: TextStyle(
                    color: isDark
                        ? themeData.textTheme.bodyMedium!.color
                        : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            t['monthlyBudget']!,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark
                  ? themeData.textTheme.bodyMedium!.color
                  : Colors.black,
            ),
          ),
          TextField(
            controller: budgetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          SizedBox(height: 16.h),
          Text(
            t['language']!,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark
                  ? themeData.textTheme.bodyMedium!.color
                  : Colors.black,
            ),
          ),
          DropdownButton<String>(
            value: settings.language,
            isExpanded: true,
            onChanged: (value) {
              if (value != null) {
                context.read<SettingsCubit>().setLanguage(value);
              }
            },
            items: [
              DropdownMenuItem(
                value: 'en',
                child: Text(
                  'English',
                  style: TextStyle(
                    color: isDark
                        ? themeData.textTheme.bodyMedium!.color
                        : Colors.black,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 'bn',
                child: Text(
                  'বাংলা',
                  style: TextStyle(
                    color: isDark
                        ? themeData.textTheme.bodyMedium!.color
                        : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              final budget = double.tryParse(budgetController.text);
              if (budget != null) {
                context.read<ProfileCubit>().updateProfile(budget: budget);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/main',
                  (route) => false,
                  arguments: {'tabIndex': 0}, // Navigate to home tab
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo[600],
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 48.h),
            ),
            child: Text(t['save']!),
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: () {
              showCategoryBottomSheet(
                context: context,
                t: t,
                isDark: isDark,
                themeData: themeData,
              );
            },
            icon: const Icon(Icons.category),
            label: Text(t['manageCategories'] ?? 'Manage Categories'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal[600],
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 48.h),
            ),
          ),
        ],
      ),
    );
  }
}
