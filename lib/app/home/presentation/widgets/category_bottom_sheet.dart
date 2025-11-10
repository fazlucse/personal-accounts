// lib/app/settings/presentation/widgets/category_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import '../../data/repositories/category_repository.dart';
import '../cubits/category_cubit.dart';

final getIt = GetIt.instance;

void showCategoryBottomSheet({
  required BuildContext context,
  required Map<String, String> t,
  required bool isDark,
  required ThemeData themeData,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
    ),
    backgroundColor: themeData.scaffoldBackgroundColor,
    builder: (_) => _CategoryManager(
      t: t,
      isDark: isDark,
      themeData: themeData,
    ),
  );
}

class _CategoryManager extends StatefulWidget {
  final Map<String, String> t;
  final bool isDark;
  final ThemeData themeData;

  const _CategoryManager({
    required this.t,
    required this.isDark,
    required this.themeData,
  });

  @override
  State<_CategoryManager> createState() => _CategoryManagerState();
}

class _CategoryManagerState extends State<_CategoryManager>
    with SingleTickerProviderStateMixin {
  final _newCategoryController = TextEditingController();
  String _selectedType = 'expense';

  late final CategoryCubit _cubit;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<CategoryCubit>();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0); // Expense first
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    final name = _newCategoryController.text.trim();
    if (name.isEmpty) return;

    final repo = getIt<CategoryRepository>();
    await repo.insert(_selectedType, name);
    _newCategoryController.clear();
    await _cubit.loadCategories();
  }

  Future<void> _confirmDelete(String type, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.themeData.colorScheme.surface,
        title: Text(
          widget.t['deleteCategory'] ?? 'Delete Category',
          style: TextStyle(color: widget.themeData.colorScheme.onSurface),
        ),
        content: Text(
          widget.t['deleteConfirm']?.replaceAll('{name}', name) ??
              'Are you sure you want to delete "$name"?',
          style: TextStyle(color: widget.themeData.colorScheme.onSurface.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(widget.t['cancel'] ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(widget.t['delete'] ?? 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = getIt<CategoryRepository>();
      await repo.delete(type, name);
      await _cubit.loadCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = widget.themeData.colorScheme;
    final textColor = colorScheme.onSurface;
    final backgroundColor = colorScheme.surface;
    final cardColor = colorScheme.surfaceVariant;
    final dividerColor = colorScheme.outline.withOpacity(0.2);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          color: backgroundColor,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar: Title + Close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Drag handle
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: textColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  // Close button
                  IconButton(
                    icon: Icon(Icons.close, color: textColor, size: 24.sp),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Title + Description
              Text(
                widget.t['manageCategories'] ?? 'Manage Categories',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                widget.t['manageDesc'] ?? 'Add, edit, or remove income and expense categories.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: textColor.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 20.h),

              // Add new category
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: dividerColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newCategoryController,
                        style: TextStyle(color: textColor, fontSize: 15.sp),
                        decoration: InputDecoration(
                          hintText: widget.t['newCategory'] ?? 'Enter category name',
                          hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    DropdownButton<String>(
                      value: _selectedType,
                      dropdownColor: cardColor,
                      style: TextStyle(color: textColor, fontSize: 14.sp),
                      underline: const SizedBox(),
                      icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
                      items: [
                        DropdownMenuItem(
                          value: 'expense',
                          child: Text(widget.t['expense'] ?? 'Expense'),
                        ),
                        DropdownMenuItem(
                          value: 'income',
                          child: Text(widget.t['income'] ?? 'Income'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _selectedType = v!),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton.icon(
                      onPressed: _addCategory,
                      icon: Icon(Icons.add, size: 18.sp),
                      label: Text(widget.t['add'] ?? 'Add', style: TextStyle(fontSize: 13.sp)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // TabBar + List
              Expanded(
                child: BlocBuilder<CategoryCubit, CategoryState>(
                  bloc: _cubit,
                  builder: (context, state) {
                    if (state.status == CategoryStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Column(
                      children: [
                        // TabBar
                        Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                            border: Border(bottom: BorderSide(color: dividerColor)),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            labelColor: colorScheme.primary,
                            unselectedLabelColor: textColor.withOpacity(0.6),
                            indicatorColor: colorScheme.primary,
                            indicatorWeight: 3,
                            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                            tabs: [
                              Tab(text: widget.t['expense'] ?? 'Expense'),
                              Tab(text: widget.t['income'] ?? 'Income'),
                            ],
                          ),
                        ),

                        // TabBarView
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12.r)),
                            ),
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildCategoryList(state.expense, 'expense', textColor, colorScheme),
                                _buildCategoryList(state.income, 'income', textColor, colorScheme),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryList(
    List<String> items,
    String type,
    Color textColor,
    ColorScheme colorScheme,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Text(
            widget.t['noCategories'] ?? 'No $type categories',
            style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 15.sp),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
      itemCount: items.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: colorScheme.outline.withOpacity(0.1)),
      itemBuilder: (context, i) {
        final cat = items[i];
        return Dismissible(
          key: ValueKey('$type-$cat'),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20.w),
            child: const Icon(Icons.delete, color: Colors.white, size: 24),
          ),
          confirmDismiss: (_) async {
            await _confirmDelete(type, cat);
            return false; // Dismiss handled by alert
          },
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            title: Text(
              cat,
              style: TextStyle(color: textColor, fontSize: 16.sp),
            ),
            trailing: Icon(Icons.swipe_left, color: textColor.withOpacity(0.5), size: 20.sp),
          ),
        );
      },
    );
  }
}