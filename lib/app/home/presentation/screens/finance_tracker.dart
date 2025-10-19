import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/app/home/data/models/profile_model.dart';
import 'package:test_app/main.dart';
import '../../data/models/settings_model.dart';
import '../cubits/settings_cubit.dart';
import '../cubits/tab_navigation_cubit.dart'; // Import the new cubit
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
  String? userName;
  String? userEmail;
  String? userPhone;
  String? userDesignation;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('profile');
    if (jsonString != null) {
      try {
        final profileJson = jsonDecode(jsonString);
        final profile = Profile.fromJson(profileJson);
        setState(() {
          userName = profile.name ?? 'Guest';
          userEmail = profile.email ?? 'No Email';
          userPhone = profile.phone ?? 'No Phone';
        });
      } catch (e) {
        // Handle JSON decoding errors
        setState(() {
          userName = 'Guest';
          userEmail = 'No Email';
          userPhone = 'No Phone';
        });
      }
    } else {
      // No profile data found
      setState(() {
        userName = 'Guest';
        userEmail = 'No Email';
        userPhone = 'No Phone';
      });
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty || name == 'Guest') return 'G';
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0].toUpperCase()}${parts[1][0].toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TabNavigationCubit>(
          create: (_) => TabNavigationCubit(),
        ),
      ],
      child: BlocBuilder<SettingsCubit, Settings>(
        builder: (context, settings) {
          final language = settings.language;
          final theme = settings.theme;
          final t = translations[language]!;
          final isDark = theme == 'dark';
          final themeData = Theme.of(context);
          final isTablet = MediaQuery.of(context).size.width > 600;

          return BlocBuilder<TabNavigationCubit, TabNavigationState>(
            builder: (context, tabState) {
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
                    // Theme toggle button
                    IconButton(
                      icon: Icon(
                        isDark ? Icons.wb_sunny : Icons.nights_stay,
                        size: isTablet ? 28.sp : 24.sp,
                      ),
                      onPressed: () {
                        context.read<SettingsCubit>().setTheme(
                              isDark ? 'light' : 'dark',
                            );
                      },
                    ),
                    // PopupMenuButton with user info and logout/language in one line
                    PopupMenuButton<String>(
                      child: Padding(
                        padding: EdgeInsets.only(right: 16.w),
                        child: CircleAvatar(
                          radius: isTablet ? 20.sp : 16.sp,
                          backgroundColor: isDark
                              ? Colors.grey[700]
                              : Colors.indigo[100],
                          child: Icon(
                            Icons.person,
                            size: isTablet ? 20.sp : 16.sp,
                            color: isDark ? Colors.white : Colors.indigo[600],
                          ),
                        ),
                      ),
                      onSelected: (value) {
                        if (value == 'logout') {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          enabled: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: CircleAvatar(
                                  radius: 50.sp,
                                  backgroundColor: isDark
                                      ? Colors.grey[700]
                                      : Colors.indigo[100],
                                  child: Text(
                                    _getInitials(userName ?? 'Guest'),
                                    style: TextStyle(
                                      fontSize: 32.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.indigo[600],
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  userName!,
                                  style: TextStyle(
                                    fontSize: isTablet ? 16.sp : 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Center(
                                child: Text(
                                  userPhone!,
                                  style: TextStyle(
                                    fontSize: isTablet ? 14.sp : 12.sp,
                                    color: isDark
                                        ? Colors.grey[300]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              if (userDesignation != null &&
                                  userDesignation != 'No Designation')
                                Text(
                                  userDesignation!,
                                  style: TextStyle(
                                    fontSize: isTablet ? 14.sp : 12.sp,
                                    color: isDark
                                        ? Colors.grey[300]
                                        : Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                t['logout'] ?? 'Logout',
                                style: TextStyle(
                                  fontSize: isTablet ? 16.sp : 14.sp,
                                  color: Colors.red,
                                ),
                              ),
                              Tooltip(
                                message: 'Toggle Language (EN/BN)',
                                child: StatefulBuilder(
                                  builder: (context, setState) {
                                    return Switch(
                                      value: context.select<SettingsCubit, bool>(
                                        (cubit) => cubit.state.language == 'en',
                                      ),
                                      onChanged: (value) {
                                        context.read<SettingsCubit>().setLanguage(
                                              value ? 'en' : 'bn',
                                            );
                                        setState(() {});
                                      },
                                      activeColor: isDark
                                          ? Colors.indigo[400]
                                          : Colors.indigo[600],
                                      activeTrackColor: isDark
                                          ? Colors.indigo[800]
                                          : Colors.indigo[300],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                body: tabs[tabState.activeTabIndex],
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
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                bottomNavigationBar: BottomAppBar(
                  color: themeData.bottomAppBarTheme.color ??
                      (isDark ? Colors.grey[900] : Colors.white),
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
                              color: tabState.activeTabIndex == 0
                                  ? Colors.indigo[600]
                                  : themeData.textTheme.bodySmall!.color,
                            ),
                            onPressed: () => context
                                .read<TabNavigationCubit>()
                                .setActiveTabIndex(0),
                            tooltip: t['dashboard'],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: IconButton(
                            icon: Icon(
                              Icons.description,
                              size: isTablet ? 28.sp : 24.sp,
                              color: tabState.activeTabIndex == 1
                                  ? Colors.indigo[600]
                                  : themeData.textTheme.bodySmall!.color,
                            ),
                            onPressed: () => context
                                .read<TabNavigationCubit>()
                                .setActiveTabIndex(1),
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
                              color: tabState.activeTabIndex == 2
                                  ? Colors.indigo[600]
                                  : themeData.textTheme.bodySmall!.color,
                            ),
                            onPressed: () => context
                                .read<TabNavigationCubit>()
                                .setActiveTabIndex(2),
                            tooltip: t['profile'],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: IconButton(
                            icon: Icon(
                              Icons.settings,
                              size: isTablet ? 28.sp : 24.sp,
                              color: tabState.activeTabIndex == 3
                                  ? Colors.indigo[600]
                                  : themeData.textTheme.bodySmall!.color,
                            ),
                            onPressed: () => context
                                .read<TabNavigationCubit>()
                                .setActiveTabIndex(3),
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
        },
      ),
    );
  }
}