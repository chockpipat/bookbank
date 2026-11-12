import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import 'package:bookbank/core/localization/localization_provider.dart';
import 'package:bookbank/data/database.dart';
import 'package:bookbank/data/db_helper.dart';

// ────────── Manage Quick Notes Screen ──────────
class ManageNotesScreen extends StatefulWidget {
  const ManageNotesScreen({super.key});

  @override
  State<ManageNotesScreen> createState() => _ManageNotesScreenState();
}

class _ManageNotesScreenState extends State<ManageNotesScreen> {
  List<QuickNote> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final notes = await DatabaseHelper.instance.getQuickNotes();
      if (!mounted) return;
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addNote() async {
    final loc = context.read<LocalizationProvider>().loc;
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        title: Text(loc.addNote),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: loc.enterQuickNote,
          ),
          onSubmitted: (_) => Navigator.pop(dialogContext, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(loc.save),
          ),
        ],
      ),
    );

    final text = controller.text.trim();
    controller.dispose();
    if (confirmed == true && text.isNotEmpty) {
      await DatabaseHelper.instance.insertQuickNote(text);
      await _loadNotes();
    }
  }

  Future<void> _deleteNote(int id) async {
    await DatabaseHelper.instance.deleteQuickNote(id);
    await _loadNotes();
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    setState(() {
      final item = _notes.removeAt(oldIndex);
      _notes.insert(newIndex, item);
    });
    await DatabaseHelper.instance.updateQuickNotesOrder(_notes);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.watch<LocalizationProvider>().loc;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(LucideIcons.chevronLeft, size: 28.sp),
        ),
        title: Text(
          loc.manageNotes,
          style: TextStyle(fontSize: 14.sp),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
          ? Center(
              child: Text(
                loc.emptyNotes,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          : ReorderableListView.builder(
              padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 100.h),
              itemCount: _notes.length,
              onReorderItem: _onReorder,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Container(
                  key: ValueKey(note.id),
                  margin: EdgeInsets.only(bottom: 8.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: ListTile(
                    leading: Icon(
                      LucideIcons.gripVertical,
                      size: 20.sp,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    title: Text(
                      note.note,
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    trailing: IconButton(
                      onPressed: () => _deleteNote(note.id!),
                      icon: Icon(
                        LucideIcons.trash2,
                        size: 18.sp,
                        color: Colors.red,
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        backgroundColor: theme.colorScheme.onSurface,
        foregroundColor: theme.colorScheme.surface,
        child: Icon(LucideIcons.plus, size: 24.sp),
      ),
    );
  }
}
