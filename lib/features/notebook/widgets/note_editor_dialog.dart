// ────────── Packages ──────────
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bookbank/features/notebook/providers/note_provider.dart';

// ────────── Database ──────────
import 'package:bookbank/data/database.dart';

// ────────── Theme & Localization ──────────
import 'package:bookbank/core/theme/app_theme.dart';
import 'package:bookbank/core/localization/localization_provider.dart';

// ────────── Widgets ──────────
class NoteEditorDialog extends StatefulWidget {
  final NoteModel? noteToEdit;

  const NoteEditorDialog({super.key, this.noteToEdit});

  static Future<void> show(BuildContext context, {NoteModel? noteToEdit}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NoteEditorDialog(noteToEdit: noteToEdit),
    );
  }

  @override
  State<NoteEditorDialog> createState() => _NoteEditorDialogState();
}

// ────────── State ──────────
class _NoteEditorDialogState extends State<NoteEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  String? _selectedCategory;
  String? _selectedCategoryKey;
  late int _selectedColorValue;
  bool _isSaving = false;

  final List<int> _colorPalette = [
    0xFF2196F3, // Blue
    0xFF4CAF50, // Green
    0xFF9C27B0, // Purple
    0xFFFF9800, // Orange
    0xFFE91E63, // Pink
    0xFF00BCD4, // Teal
  ];

  // ────────── Category Helpers ──────────
  List<String> _categories(BuildContext context) {
    final loc = context.watch<LocalizationProvider>().loc;
    return [loc.categoryGeneral, loc.categoryFinance, loc.categoryGoals];
  }

  // ────────── Category Helpers ──────────
  String _getCategoryKey(String localizedCategory, BuildContext context) {
    final loc = context.read<LocalizationProvider>().loc;
    if (localizedCategory == loc.categoryGeneral) return 'General';
    if (localizedCategory == loc.categoryFinance) return 'Finance';
    if (localizedCategory == loc.categoryGoals) return 'Goals';
    if (localizedCategory == 'General' ||
        localizedCategory == 'Finance' ||
        localizedCategory == 'Goals') {
      return localizedCategory;
    }
    return 'General'; // fallback
  }

  // ────────── Category Helpers ──────────
  String _getLocalizedCategory(String categoryKey, BuildContext context) {
    final loc = context.read<LocalizationProvider>().loc;
    if (categoryKey == 'General') return loc.categoryGeneral;
    if (categoryKey == 'Finance') return loc.categoryFinance;
    if (categoryKey == 'Goals') return loc.categoryGoals;
    return loc.categoryGeneral; // fallback
  }

  @override
  void initState() {
    super.initState();
    final note = widget.noteToEdit;
    _titleController = TextEditingController(text: note?.title ?? '');
    _contentController = TextEditingController(text: note?.content ?? '');
    _selectedCategoryKey = note?.category;
    _selectedColorValue = note?.colorValue ?? _colorPalette[0];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // ────────── Save Note Logic ──────────
  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final loc = Provider.of<LocalizationProvider>(context, listen: false).loc;
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    final categoryKey = _getCategoryKey(_selectedCategory!, context);

    bool success = false;

    // ────────── Update Note ──────────
    if (widget.noteToEdit != null) {
      final updatedNote = widget.noteToEdit!.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: categoryKey,
        colorValue: _selectedColorValue,
        date: formattedDate,
      );
      success = await noteProvider.updateNote(updatedNote);
    } else {
      success = await noteProvider.addNote(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: categoryKey,
        colorValue: _selectedColorValue,
        date: formattedDate,
      );
    }

    // ────────── UI Updates ──────────
    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
              left: 16.w,
              right: 16.w,
            ),
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: AppColors.background, width: 3),
                ),
              ),
              padding: EdgeInsets.only(left: 8.w),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.background,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),

                  Expanded(
                    child: Text(
                      widget.noteToEdit == null
                          ? loc.addedSuccess
                          : loc.updatedSuccess,
                      style: TextStyle(
                        color: AppColors.background,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final locProvider = Provider.of<LocalizationProvider>(context);
    final loc = locProvider.loc;

    // ────────── Initialize Selected Category ──────────
    if (_selectedCategory == null && _selectedCategoryKey != null) {
      _selectedCategory = _getLocalizedCategory(_selectedCategoryKey!, context);
    }
    _selectedCategory ??= _categories(context)[0];

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ────────── Top Handle Bar ──────────
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // ────────── Title bar ──────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          widget.noteToEdit != null ? Icons.edit : Icons.add,
                          size: 24.sp,
                        ),
                        const SizedBox(width: 8),

                        Text(
                          widget.noteToEdit != null
                              ? loc.editNote
                              : loc.addNote,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // ────────── Title Input ──────────
                TextFormField(
                  controller: _titleController,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? loc.enterTitle
                      : null,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    labelText: loc.title,
                    hintText: loc.enterNoteTitle,
                    labelStyle: TextStyle(fontSize: 12.sp),
                    hintStyle: TextStyle(fontSize: 12.sp),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7.r),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7.r),
                      borderSide: BorderSide(
                        color: theme.colorScheme.onSurface,
                        width: 2,
                      ),
                    ),

                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7.r),
                      borderSide: BorderSide(
                        color: theme.colorScheme.error,
                        width: 1.5,
                      ),
                    ),

                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7.r),
                      borderSide: BorderSide(
                        color: theme.colorScheme.error,
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                // ────────── Content Input ──────────
                TextFormField(
                  controller: _contentController,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? loc.enterContent
                      : null,
                  maxLines: 4,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    labelText: loc.content,
                    hintText: loc.enterNoteContent,
                    labelStyle: TextStyle(fontSize: 12.sp),
                    hintStyle: TextStyle(fontSize: 12.sp),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    alignLabelWithHint: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7.r),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7.r),
                      borderSide: BorderSide(
                        color: theme.colorScheme.onSurface,
                        width: 2,
                      ),
                    ),

                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7.r),
                      borderSide: BorderSide(
                        color: theme.colorScheme.error,
                        width: 1.5,
                      ),
                    ),

                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7.r),
                      borderSide: BorderSide(
                        color: theme.colorScheme.error,
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // ────────── Category Selection ──────────
                Text(
                  loc.category,
                  style: TextStyle(
                    fontSize: AppSize.s.sp,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),

                // ────────── Category Chips ──────────
                Wrap(
                  spacing: 8.w,
                  children: _categories(context).map((category) {
                    final isSelected = _selectedCategory == category;
                    return ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        }
                      },
                      side: BorderSide.none,
                      checkmarkColor: theme.colorScheme.onSurface,
                      selectedColor: theme.colorScheme.onSurface.withValues(
                        alpha: 0.2,
                      ),
                      labelStyle: TextStyle(
                        fontSize: 12.sp,
                        color: theme.colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16.h),

                // ────────── Color Selection ──────────
                Text(
                  loc.noteColor,
                  style: TextStyle(
                    fontSize: AppSize.s.sp,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),

                // ────────── Color Chips ──────────
                Row(
                  children: _colorPalette.map((colorVal) {
                    final isSelected = _selectedColorValue == colorVal;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColorValue = colorVal;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 12.w),
                        width: 32.w,
                        height: 32.h,
                        decoration: BoxDecoration(
                          color: Color(colorVal),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: theme.colorScheme.onSurface,
                                  width: 1.5,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Color(colorVal).withValues(alpha: 0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12.sp,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 24.h),

                // ────────── Action Buttons ──────────
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveNote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.onSurface,
                      foregroundColor: theme.scaffoldBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.r),
                      ),
                    ),
                    child: _isSaving
                        ? SizedBox(
                            width: 24.w,
                            height: 24.h,
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            widget.noteToEdit != null
                                ? loc.saveChanges
                                : loc.createNote,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                  ),
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
