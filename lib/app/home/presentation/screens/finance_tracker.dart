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

        // Placeholder user data (replace with actual user profile data)
        final userName = 'John Doe';
        final userPhone = '+1234567890';
        final userDesignation = 'Financial Analyst';

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
              PopupMenuButton<String>(
                child: Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: CircleAvatar(
                    radius: isTablet ? 20.sp : 16.sp,
                    backgroundColor: isDark ? Colors.grey[700] : Colors.indigo[100],
                    child: Icon(
                      Icons.person,
                      size: isTablet ? 20.sp : 16.sp,
                      color: isDark ? Colors.white : Colors.indigo[600],
                    ),
                  ),
                ),
                onSelected: (value) {
                  if (value == 'logout') {
                    // Implement logout logic here, e.g., clear auth state and navigate to login
                    Navigator.pushReplacementNamed(context, '/login');
                  } else if (value == 'en' || value == 'bn') {
                    context.read<SettingsCubit>().setLanguage(value);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: isTablet ? 16.sp : 14.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          userPhone,
                          style: TextStyle(
                            fontSize: isTablet ? 14.sp : 12.sp,
                            color: isDark ? Colors.grey[300] : Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          userDesignation,
                          style: TextStyle(
                            fontSize: isTablet ? 14.sp : 12.sp,
                            color: isDark ? Colors.grey[300] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'en',
                    child: Text(
                      'English',
                      style: TextStyle(fontSize: isTablet ? 16.sp : 14.sp),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'bn',
                    child: Text(
                      'বাংলা',
                      style: TextStyle(fontSize: isTablet ? 16.sp : 14.sp),
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'logout',
                    child: Text(
                      t['logout'] ?? 'Logout',
                      style: TextStyle(
                        fontSize: isTablet ? 16.sp : 14.sp,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
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
              height: isTablet ? 70.h : 60.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
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
                  SizedBox(width: 48.w),
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