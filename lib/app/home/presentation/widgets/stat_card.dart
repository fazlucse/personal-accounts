import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget buildStatCard({
  required String title,
  required String value,
  required Color color,
  required IconData icon,
  required ThemeData themeData,
}) {
  return Card(
    elevation: 2,
    child: Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12.sp, color: themeData.textTheme.bodySmall!.color)),
          Text(value, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: color)),
          const Spacer(),
          Align(alignment: Alignment.bottomRight, child: Icon(icon, color: color, size: 32.sp)),
        ],
      ),
    ),
  );
}