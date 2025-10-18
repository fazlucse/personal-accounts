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
    final phoneController = TextEditingController(text: profile.phone ?? '');
    final designationController = TextEditingController(
      text: profile.designation ?? '',
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t['profile']!,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: themeData.textTheme.bodyLarge!.color,
            ),
          ),
          SizedBox(height: 16.h),
          // Photo Section
          Center(
            child: GestureDetector(
              onTap: () {
                // Placeholder for photo selection logic (e.g., using image_picker)
                // For now, just a print statement
                print('Photo selection tapped');
              },
              child: CircleAvatar(
                radius: 50.r,
                backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                backgroundImage:
                    profile.photoUrl != null && profile.photoUrl!.isNotEmpty
                    ? NetworkImage(profile.photoUrl!)
                    : null,
                child: profile.photoUrl == null || profile.photoUrl!.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 50.sp,
                        color: themeData.textTheme.bodyMedium!.color,
                      )
                    : null,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Name Field
          Text(
            t['name']!,
            style: TextStyle(
              fontSize: 14.sp,
              color: themeData.textTheme.bodyMedium!.color,
            ),
          ),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          SizedBox(height: 16.h),
          // Email Field
          Text(
            t['email']!,
            style: TextStyle(
              fontSize: 14.sp,
              color: themeData.textTheme.bodyMedium!.color,
            ),
          ),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          SizedBox(height: 16.h),
          // Phone Field
          Text(
            t['phone'] ?? 'Phone', // Fallback if 'phone' is not in translations
            style: TextStyle(
              fontSize: 14.sp,
              color: themeData.textTheme.bodyMedium!.color,
            ),
          ),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          SizedBox(height: 16.h),
          // Designation Field
          Text(
            t['designation'] ??
                'Designation', // Fallback if 'designation' is not in translations
            style: TextStyle(
              fontSize: 14.sp,
              color: themeData.textTheme.bodyMedium!.color,
            ),
          ),
          TextField(
            controller: designationController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              context.read<ProfileCubit>().updateProfile(
                name: nameController.text,
                email: emailController.text,
                phone: phoneController.text,
                designation: designationController.text,
                photoUrl: profile
                    .photoUrl, // Retain existing photoUrl (update logic needed for photo)
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile Update successfully')),
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
