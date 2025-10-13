import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubits/profile_cubit.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, String> t;
  final bool isDark;
  final ThemeData themeData;

  const ProfileScreen({
    super.key,
    required this.t,
    required this.isDark,
    required this.themeData,
  });

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileCubit>().state;
    final nameController = TextEditingController(text: profile.name);
    final emailController = TextEditingController(text: profile.email);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t['profile']!,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: themeData.textTheme.bodyLarge!.color),
          ),
          SizedBox(height: 16.h),
          Text(t['name']!, style: TextStyle(fontSize: 14.sp, color: themeData.textTheme.bodyMedium!.color)),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          SizedBox(height: 16.h),
          Text(t['email']!, style: TextStyle(fontSize: 14.sp, color: themeData.textTheme.bodyMedium!.color)),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              context.read<ProfileCubit>().updateProfile(
                    name: nameController.text,
                    email: emailController.text,
                  );
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