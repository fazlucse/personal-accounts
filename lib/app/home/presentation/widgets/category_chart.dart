// lib/app/home/presentation/widgets/category_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/profile_model.dart';

Widget buildCategoryChart(
  Map<String, double> data,
  double total,
  Color baseColor,
  Profile profile,
  Map<String, String> t,
  String title,
) {
  if (data.isEmpty || total <= 0) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 20.h),
            Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey[400]),
            SizedBox(height: 8.h),
            Text(t['no_data'] ?? 'No data', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  final colors = [
    baseColor,
    baseColor.withOpacity(0.8),
    baseColor.withOpacity(0.6),
    baseColor.withOpacity(0.4),
    baseColor.withOpacity(0.2),
  ];

  return Card(
    elevation: 2,
    child: Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: data.entries.map((e) {
                  final percentage = (e.value / total) * 100;
                  final label = t[e.key] ?? e.key;
                  return PieChartSectionData(
                    color: colors[data.keys.toList().indexOf(e.key) % colors.length],
                    value: e.value,
                    title: '$label\n${percentage.toStringAsFixed(1)}%',
                    radius: 50.r,
                    titleStyle: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.white),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 30.r,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}