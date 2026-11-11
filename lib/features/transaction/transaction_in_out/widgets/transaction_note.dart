import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import 'package:bookbank/core/localization/localization_provider.dart';

// ────────── Transaction Note Widget ──────────
class TransactionNote extends StatefulWidget {
  const TransactionNote({super.key});

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

  @override
  void dispose() {
    _dropdownEntry?.remove();
    _noteController.dispose();
    super.dispose();
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

  Widget _buildDropdownPanel(BuildContext context) {
    final theme = Theme.of(context);
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
                  'test Catatan',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                // Manage note button
                TextButton.icon(
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => const ManageNotes(),
                    //   ),
                    // );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface,
                    padding: EdgeInsets.zero,
                  ),
                  label: Text(
                    'test Kelola Catatan',
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DropdownNoteContent(
                      dropdownNoteName: 'Gaji',
                      onNoteSelected: () => _selectNote('Gaji'),
                    ),
                    _DropdownNoteContent(
                      dropdownNoteName: 'Deposit Keamanan',
                      onNoteSelected: () => _selectNote('Deposit Keamanan'),
                    ),
                    _DropdownNoteContent(
                      dropdownNoteName: 'Makanan',
                      onNoteSelected: () => _selectNote('Makanan'),
                    ),
                    _DropdownNoteContent(
                      dropdownNoteName: 'Sewa',
                      onNoteSelected: () => _selectNote('Sewa'),
                    ),
                    _DropdownNoteContent(
                      dropdownNoteName: 'Perbaikan',
                      onNoteSelected: () => _selectNote('Perbaikan'),
                    ),
                    _DropdownNoteContent(
                      dropdownNoteName: 'Belanja',
                      onNoteSelected: () => _selectNote('Belanja'),
                    ),
                    _DropdownNoteContent(
                      dropdownNoteName: 'Top Up Game',
                      onNoteSelected: () => _selectNote('Top Up Game'),
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
          'test Note',
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
                    hintText: 'Test Add Note',
                    prefixIcon: Icon(
                      LucideIcons.messageCircleMore,
                      size: 18.w,
                      color: theme.colorScheme.onSurface,
                    ),

                    // Hint text style
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
