import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryDropdown extends StatefulWidget {
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
    required this.incomeCategories,
    required this.expenseCategories,
  });

  @override
  State<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  late List<String> allCategories;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    allCategories = widget.type == 'income'
        ? widget.incomeCategories
        : widget.expenseCategories;
    selectedCategory = widget.value;
  }

  @override
  void didUpdateWidget(CategoryDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type) {
      allCategories = widget.type == 'income'
          ? widget.incomeCategories
          : widget.expenseCategories;
    }
  }

  void _showCategoryPicker(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    List<String> filteredCategories = List.from(allCategories);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 16.w,
                  right: 16.w,
                  top: 16.h,
                ),
                child: StatefulBuilder(
                  builder: (context, setState) => Column(
                    children: [
                      // 🔍 Search Field
                      TextField(
                        controller: searchController,
                        onChanged: (query) {
                          setState(() {
                            filteredCategories = allCategories
                                .where((c) => c
                                    .toLowerCase()
                                    .contains(query.toLowerCase()))
                                .toList();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: widget.translations['search'] ??
                              'Search category...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 10.h,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // 📋 Scrollable Category List with border for each item
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: filteredCategories.length,
                          itemBuilder: (context, index) {
                            final cat = filteredCategories[index];
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedCategory = cat;
                                  });
                                  widget.onChanged(cat);
                                  Navigator.pop(context);
                                },
                                borderRadius: BorderRadius.circular(12.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 12.h),
                                 decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
  color: Colors.grey.shade200.withOpacity(0.6),
  width: 0.8, // slightly thicker
    ),
            ),
          ),
                                  child: Text(
                                    widget.translations[cat] ?? cat,
                                    style: TextStyle(
                                      fontSize:
                                          widget.isTablet ? 16.sp : 14.sp,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 8.h),

                      // 🚫 Cancel Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black87,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            widget.translations['cancel'] ?? 'Cancel',
                            style: TextStyle(
                              fontSize: widget.isTablet ? 16.sp : 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: () => _showCategoryPicker(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedCategory ??
                  (widget.translations['selectCategory'] ?? 'Select Category'),
              style: textTheme.bodyMedium?.copyWith(
                fontSize: widget.isTablet ? 16.sp : 14.sp,
                color: selectedCategory == null
                    ? Colors.grey
                    : theme.textTheme.bodyMedium?.color ??
                        theme.colorScheme.onSurface,
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
