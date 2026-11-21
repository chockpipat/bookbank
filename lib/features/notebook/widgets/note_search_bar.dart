import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:bookbank/features/notebook/providers/note_provider.dart';
import 'package:bookbank/core/localization/localization_provider.dart';

class NoteSearchBar extends StatefulWidget {
  const NoteSearchBar({super.key});

  @override
  State<NoteSearchBar> createState() => _NoteSearchBarState();
}

class _NoteSearchBarState extends State<NoteSearchBar> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final noteProvider = Provider.of<NoteProvider>(context);
    final loc = Provider.of<LocalizationProvider>(context);
    final categories = noteProvider.getCategories(loc);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Chips
        SizedBox(
          height: 34.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, index) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final category = categories[index];
              final categoryKey = noteProvider.getCategoryKey(category, loc);
              final isSelected = noteProvider.selectedCategory == categoryKey;

              return GestureDetector(
                onTap: () => noteProvider.setCategory(category, loc),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(50.r),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Center(
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isSelected
                            ? theme.scaffoldBackgroundColor
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
