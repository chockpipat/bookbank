// ────────── Packages & Providers ──────────
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bookbank/features/notebook/providers/note_provider.dart';

// ────────── Database ──────────
import 'package:bookbank/data/database.dart';

// ────────── Theme & localization ──────────
import 'package:bookbank/core/theme/app_theme.dart';
import 'package:bookbank/core/localization/localization_provider.dart';

// ────────── Widgets ──────────
import 'package:bookbank/features/notebook/widgets/empty_notes_view.dart';
import 'package:bookbank/features/notebook/widgets/note_card.dart';
import 'package:bookbank/features/notebook/widgets/note_editor_dialog.dart';
import 'package:bookbank/features/notebook/widgets/note_search_bar.dart';

class NoteBookScreen extends StatefulWidget {
  const NoteBookScreen({super.key});

  @override
  State<NoteBookScreen> createState() => _NoteBookScreenState();
}

class _NoteBookScreenState extends State<NoteBookScreen> {
  final Set<int> _selectedIds = {};
  bool _isMultiSelectMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NoteProvider>(context, listen: false).loadNotes();
    });
  }

  // ────────── Helper Methods ──────────
  void _showDeleteConfirmation(BuildContext context, NoteModel note) {
    final theme = Theme.of(context);
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    final loc = Provider.of<LocalizationProvider>(context, listen: false).loc;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: theme.colorScheme.onSurfaceVariant),
        ),

        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
            SizedBox(width: 8.w),
            Text(loc.confirmDelete),
          ],
        ),

        content: Text('${loc.confirmDeleteNote} "${note.title}"?'),

        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              loc.cancel,
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),

          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              if (note.id != null) {
                final success = await noteProvider.deleteNote(note.id!);
                if (success && context.mounted) {
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
                        padding: EdgeInsets.only(left: 8.w),
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: AppColors.background,
                              width: 3,
                            ),
                          ),
                        ),
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
                                loc.noteDeleted,
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
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: Text(loc.delete),
          ),
        ],
      ),
    );
  }

  // ────────── Selection Methods ──────────
  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) {
          _isMultiSelectMode = false;
        }
      } else {
        _selectedIds.add(id);
        _isMultiSelectMode = true;
      }
    });
  }

  // ────────── Clear Selection ──────────
  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
      _isMultiSelectMode = false;
    });
  }

  // ────────── Delete Selected Notes ──────────
  Future<void> _deleteSelectedNotes() async {
    if (_selectedIds.isEmpty) return;

    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final loc = Provider.of<LocalizationProvider>(context, listen: false).loc;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(loc.delete),
        content: Text('${loc.delete} ${_selectedIds.length} ${loc.notes}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.delete, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // Delete Notes
    if (confirmed == true && mounted) {
      for (final id in _selectedIds) {
        await noteProvider.deleteNote(id);
      }
      _clearSelection();
    }
  }

  // ────────── Show Note Detail Dialog ──────────
  void _showNoteDetailDialog(BuildContext context, NoteModel note) {
    final theme = Theme.of(context);
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final loc = Provider.of<LocalizationProvider>(context, listen: false).loc;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
          side: BorderSide(color: theme.colorScheme.outline),
        ),
        child: Container(
          padding: EdgeInsets.all(20.w),
          constraints: BoxConstraints(maxHeight: 500.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Tag & Color
              Row(
                children: [
                  Container(
                    width: 12.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: Color(note.colorValue),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Color(note.colorValue).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      note.category,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const Spacer(),

                  IconButton(
                    icon: Icon(
                      note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      color: note.isPinned
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      noteProvider.togglePin(note);
                      Navigator.of(context).pop();
                    },
                  ),

                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Title
              Text(
                note.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6.h),

              // Date
              Text(
                '${loc.recordedOn} : ${note.date}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Divider(height: 24),

              // Content Area
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    note.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14.sp,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showDeleteConfirmation(context, note);
                    },
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                      size: 18.sp,
                    ),
                    label: Text(
                      loc.delete,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.colorScheme.error),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      NoteEditorDialog.show(context, noteToEdit: note);
                    },
                    icon: Icon(Icons.edit, size: 18.sp),
                    label: Text(loc.edit),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ────────── Main Build Method ──────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final noteProvider = Provider.of<NoteProvider>(context);
    final locProvider = Provider.of<LocalizationProvider>(context);
    final filteredNotes = noteProvider.getFilteredNotesWithLocalization(
      locProvider,
    );

    final loc = locProvider.loc;

    return Scaffold(
      // ────────── Floating Action Button ──────────
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 120.h, right: 10.w),
        child: IconButton(
          onPressed: () => NoteEditorDialog.show(context),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.onSurface,
            foregroundColor: theme.scaffoldBackgroundColor,
            minimumSize: Size(46.w, 46.h),
          ),
          icon: Icon(Icons.add, size: 24.sp),
        ),
      ),

      // ────────── Body Content ──────────
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 115.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ────────── Title Section ──────────
                  Row(
                    children: [
                      Icon(
                        LucideIcons.notepadText,
                        color: theme.colorScheme.onSurface,
                        size: 24.sp,
                      ),
                      SizedBox(width: 16.w),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.notebook,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: AppSize.l.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            loc.notesSubtitle,
                            style: TextStyle(
                              fontSize: AppSize.xs.sp,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // ────────── Item Count ──────────
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Text(
                      '${filteredNotes.length} ${loc.items}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // ────────── Search & Category Filters or Selection Menu ──────────
              if (_isMultiSelectMode)
                Container(
                  height: 48.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.r),
                    color: theme.colorScheme.onSurface,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${_selectedIds.length} ${loc.selected}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.scaffoldBackgroundColor,
                        ),
                      ),
                      const Spacer(),

                      InkWell(
                        onTap: _clearSelection,
                        borderRadius: BorderRadius.circular(20.r),
                        child: Padding(
                          padding: EdgeInsets.all(8.w),
                          child: Icon(
                            Icons.close,
                            size: 20.sp,
                            color: theme.scaffoldBackgroundColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),

                      InkWell(
                        onTap: _deleteSelectedNotes,
                        borderRadius: BorderRadius.circular(20.r),
                        child: Padding(
                          padding: EdgeInsets.all(8.w),
                          child: Icon(
                            Icons.delete,
                            size: 20.sp,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                const NoteSearchBar(),
              SizedBox(height: 16.h),

              // ────────── Note Content List /Grid View ──────────
              Expanded(
                child: noteProvider.isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.onSurface,
                        ),
                      )
                    : filteredNotes.isEmpty
                    ? EmptyNotesView(
                        onAddNote: () => NoteEditorDialog.show(context),
                      )
                    : RefreshIndicator(
                        onRefresh: () => noteProvider.loadNotes(),
                        child: ListView.builder(
                          padding: EdgeInsets.only(bottom: 90.h),
                          itemCount: filteredNotes.length,
                          itemBuilder: (context, index) {
                            final note = filteredNotes[index];
                            return NoteCard(
                              note: note,
                              onTap: () => _showNoteDetailDialog(context, note),
                              onEdit: () => NoteEditorDialog.show(
                                context,
                                noteToEdit: note,
                              ),
                              onDelete: () =>
                                  _showDeleteConfirmation(context, note),
                              onTogglePin: () => noteProvider.togglePin(note),
                              isMultiSelectMode: _isMultiSelectMode,
                              isSelected: _selectedIds.contains(note.id ?? 0),
                              onToggleSelection: () =>
                                  _toggleSelection(note.id ?? 0),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
