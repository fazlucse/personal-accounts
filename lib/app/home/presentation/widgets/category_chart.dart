import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/profile_model.dart';

Widget buildCategoryChart(
  Map<String, double> data,
  double total,
  Color color,
  Profile profile,
  Map<String, String> t,
  String title,
) {
  return Card(
    elevation: 2,
    child: Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: SizedBox(
              height: 200.h,
              child: PieChart(
                PieChartData(
                  sections: data.entries.map((e) {
                    final percentage = total > 0 ? (e.value / total) * 100 : 0;
                    return PieChartSectionData(
                      color: color,
                      value: e.value,
                      title: '${t[e.key]} (${percentage.toStringAsFixed(1)}%)',
                      radius: 50.r,
                      titleStyle: TextStyle(fontSize: 10.sp, color: Colors.white),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}