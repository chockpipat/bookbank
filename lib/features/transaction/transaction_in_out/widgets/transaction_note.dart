import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import 'package:bookbank/core/localization/localization_provider.dart';
import 'package:bookbank/data/database.dart';
import 'package:bookbank/data/db_helper.dart';
import 'package:bookbank/features/transaction/transaction_in_out/manage_notes_screen.dart';

// ────────── Transaction Note Widget ──────────
class TransactionNote extends StatefulWidget {
  final ValueChanged<String>? onChanged;

  const TransactionNote({super.key, this.onChanged});

  @override
  State<TransactionNote> createState() => _TransactionNoteState();
}

// ────────── Dropdown Note Content ──────────
class _DropdownNoteContent extends StatelessWidget {
  final String dropdownNoteName;
  final VoidCallback onNoteSelected;

  const _DropdownNoteContent({
    required this.dropdownNoteName,
    required this.onNoteSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: onNoteSelected,
      style: TextButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
        alignment: Alignment.centerLeft,
      ),
      child: Text(
        dropdownNoteName,
        style: TextStyle(fontSize: 12.sp, color: theme.colorScheme.onSurface),
      ),
    );
  }
}

// ────────── Transaction Note State ──────────
class _TransactionNoteState extends State<TransactionNote> {
  bool _isDropdownNote = false;
  final TextEditingController _noteController = TextEditingController();
  final GlobalKey _fieldKey = GlobalKey();
  OverlayEntry? _dropdownEntry;

  List<QuickNote> _quickNotes = [];

  @override
  void initState() {
    super.initState();
    _noteController.addListener(_onNoteChanged);
    _loadData();
  }

  @override
  void dispose() {
    _dropdownEntry?.remove();
    _noteController.dispose();
    super.dispose();
  }

  void _onNoteChanged() {
    widget.onChanged?.call(_noteController.text);
  }

  Future<void> _loadData() async {
    try {
      final notes = await DatabaseHelper.instance.getQuickNotes();
      if (!mounted) return;
      setState(() {
        _quickNotes = notes;
      });
    } catch (_) {}
  }

  void _toggleDropdown() {
    if (_isDropdownNote) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    final renderBox =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final fieldSize = renderBox.size;

    _dropdownEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Backdrop — tap outside to close
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _closeDropdown,
              child: const SizedBox.expand(),
            ),
          ),

          // Dropdown panel
          Positioned(
            left: offset.dx,
            top: offset.dy + fieldSize.height + 8,
            width: fieldSize.width,
            child: Material(
              color: Colors.transparent,
              child: _buildDropdownPanel(context),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_dropdownEntry!);
    setState(() => _isDropdownNote = true);
  }

  void _closeDropdown() {
    _dropdownEntry?.remove();
    _dropdownEntry = null;
    if (mounted) {
      setState(() => _isDropdownNote = false);
    }
  }

  void _selectNote(String note) {
    _noteController.text = note;
    _closeDropdown();
  }

  void _openManageNotes() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManageNotesScreen()),
    ).then((_) => _loadData());
  }

  Widget _buildDropdownPanel(BuildContext context) {
    final theme = Theme.of(context);
    final locProvider = Provider.of<LocalizationProvider>(context);
    final loc = locProvider.loc;

    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.notes,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                // Manage note button
                TextButton.icon(
                  onPressed: _openManageNotes,
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface,
                    padding: EdgeInsets.zero,
                  ),
                  label: Text(
                    loc.manageNotes,
                    style: TextStyle(fontSize: 12.sp),
                  ),
                  icon: Icon(LucideIcons.edit, size: 16),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Divider(color: theme.colorScheme.outline),
            const SizedBox(height: 8),

            // Content
            Expanded(
              child: _quickNotes.isEmpty
                  ? Center(
                      child: Text(
                        loc.emptyNotes,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._quickNotes.map(
                            (note) => _DropdownNoteContent(
                              dropdownNoteName: note.note,
                              onNoteSelected: () => _selectNote(note.note),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locProvider = Provider.of<LocalizationProvider>(context);
    final loc = locProvider.loc;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.note,
          style: TextStyle(fontSize: 12.sp, color: theme.colorScheme.onSurface),
        ),
        const SizedBox(height: 8),

        // ────────── Note Input Field ──────────
        Container(
          key: _fieldKey,
          width: double.infinity,
          height: 50.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(7.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  controller: _noteController,
                  style: TextStyle(fontSize: 12.sp),
                  decoration: InputDecoration(
                    // Hint text && prefix icon
                    hintText: loc.enterQuickNote,
                    prefixIcon: Icon(
                      LucideIcons.messageCircleMore,
                      size: 18.w,
                      color: theme.colorScheme.onSurface,
                    ),

                    // Hint text style
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 12.sp,
                    ),

                    prefixIconConstraints: BoxConstraints(minWidth: 40),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),

              // Dropdown button
              IconButton(
                onPressed: _toggleDropdown,
                icon: Icon(
                  _isDropdownNote
                      ? LucideIcons.chevronUp
                      : LucideIcons.chevronDown,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
