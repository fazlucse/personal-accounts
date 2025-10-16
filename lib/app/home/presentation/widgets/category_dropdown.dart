import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryDropdown extends StatelessWidget {
  final String? value;
  final bool isExpanded;
  final bool isTablet;
  final String type;
  final Map<String, String> translations;
  final Function(String?) onChanged;
  final List<String> incomeCategories;
  final List<String> expenseCategories;

  const CategoryDropdown({
    super.key,
    required this.value,
    this.isExpanded = true,
    required this.isTablet,
    required this.type,
    required this.translations,
    required this.onChanged,
    required this.incomeCategories ,
    required this.expenseCategories
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return DropdownButton<String>(
      value: value,
      isExpanded: isExpanded,
      dropdownColor: theme.cardColor, // Use theme's cardColor for dropdown background
      style: textTheme.bodyMedium?.copyWith(
        fontSize: isTablet ? 16.sp : 14.sp,
        color: theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface,
      ),
      onChanged: onChanged,
      items: (type == 'income' ? incomeCategories : expenseCategories)
          .map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(
                  translations[cat] ?? cat,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: isTablet ? 16.sp : 14.sp,
                    color: theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface,
                  ),
                ),
              ))
          .toList(),
    );
  }
}