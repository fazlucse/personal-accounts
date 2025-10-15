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
      padding: EdgeInsets.all(10.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // CRITICAL: prevents expansion
            children: [
              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: themeData.textTheme.bodySmall!.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              SizedBox(height: 4.h),
              
              // Value with flexible sizing
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              // Icon at bottom right
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  icon,
                  color: color.withOpacity(0.7),
                  size: 28.sp,
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}