import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/main.dart';
import '../../data/models/settings_model.dart';
import '../cubits/settings_cubit.dart';
import 'dashboard_screen.dart';
import 'add_transaction_screen.dart';
import 'reports_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class FinanceTracker extends StatefulWidget {
  const FinanceTracker({super.key});

  @override
  State<FinanceTracker> createState() => _FinanceTrackerState();
}

class _FinanceTrackerState extends State<FinanceTracker> {
  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, Settings>(
      builder: (context, settings) {
        final language = settings.language;
        final theme = settings.theme;
        final t = translations[language]!;
        final isDark = theme == 'dark';
        final themeData = Theme.of(context);
        final isTablet = MediaQuery.of(context).size.width > 600;

        final List<Widget> tabs = [
          DashboardScreen(t: t, isDark: isDark, themeData: themeData),
          ReportsScreen(t: t, isDark: isDark, themeData: themeData),
          ProfileScreen(t: t, isDark: isDark, themeData: themeData),
          SettingsScreen(t: t, isDark: isDark, themeData: themeData),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Text(
              t['appName']!,
              style: TextStyle(
                fontSize: isTablet ? 24.sp : 20.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.indigo[400] : Colors.indigo[600],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isDark ? Icons.wb_sunny : Icons.nights_stay,
                  size: isTablet ? 28.sp : 24.sp,
                ),
                onPressed: () {
                  context.read<SettingsCubit>().setTheme(isDark ? 'light' : 'dark');
                },
              ),
              Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: DropdownButton<String>(
                  value: language,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<SettingsCubit>().setLanguage(value);
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'en',
                      child: Text('English', style: TextStyle(fontSize: isTablet ? 16.sp : 14.sp)),
                    ),
                    DropdownMenuItem(
                      value: 'bn',
                      child: Text('বাংলা', style: TextStyle(fontSize: isTablet ? 16.sp : 14.sp)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: tabs[_activeTabIndex],
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showAddTransactionBottomSheet(
                context: context,
                translations: t,
                isDark: isDark,
                themeData: themeData,
              );
            },
            backgroundColor: Colors.indigo[600],
            foregroundColor: Colors.white,
            elevation: 6,
            shape: CircleBorder(),
            child: Icon(Icons.add, size: isTablet ? 28.sp : 24.sp),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            color: themeData.bottomAppBarTheme.color ?? (isDark ? Colors.grey[900] : Colors.white),
            elevation: 8,
            shape: CircularNotchedRectangle(),
            notchMargin: 8.w,
            surfaceTintColor: isDark ? Colors.grey[800] : Colors.white,
            child: Container(
              height: isTablet ? 70.h : 60.h, // Increased height for spacing
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Left 2 tabs
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.h), // Space below icons
                    child: IconButton(
                      icon: Icon(
                        Icons.home,
                        size: isTablet ? 28.sp : 24.sp,
                        color: _activeTabIndex == 0 ? Colors.indigo[600] : themeData.textTheme.bodySmall!.color,
                      ),
                      onPressed: () => setState(() => _activeTabIndex = 0),
                      tooltip: t['dashboard'],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: IconButton(
                      icon: Icon(
                        Icons.description,
                        size: isTablet ? 28.sp : 24.sp,
                        color: _activeTabIndex == 1 ? Colors.indigo[600] : themeData.textTheme.bodySmall!.color,
                      ),
                      onPressed: () => setState(() => _activeTabIndex = 1),
                      tooltip: t['reports'],
                    ),
                  ),
                  SizedBox(width: 48.w), // Space for FAB cradle
                  // Right 2 tabs
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: IconButton(
                      icon: Icon(
                        Icons.person,
                        size: isTablet ? 28.sp : 24.sp,
                        color: _activeTabIndex == 2 ? Colors.indigo[600] : themeData.textTheme.bodySmall!.color,
                      ),
                      onPressed: () => setState(() => _activeTabIndex = 2),
                      tooltip: t['profile'],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: IconButton(
                      icon: Icon(
                        Icons.settings,
                        size: isTablet ? 28.sp : 24.sp,
                        color: _activeTabIndex == 3 ? Colors.indigo[600] : themeData.textTheme.bodySmall!.color,
                      ),
                      onPressed: () => setState(() => _activeTabIndex = 3),
                      tooltip: t['settings'],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}