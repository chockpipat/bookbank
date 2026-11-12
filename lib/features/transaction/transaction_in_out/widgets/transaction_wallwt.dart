import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bookbank/core/localization/localization_provider.dart';

// ────────── Transaction Wallwt ──────────
class TransactionWallwt extends StatefulWidget {
  final ValueChanged<String>? onChanged;

  const TransactionWallwt({super.key, this.onChanged});

  @override
  State<TransactionWallwt> createState() => _TransactionWallwtState();
}

// ────────── Wallet Position Button ──────────
class WalletPositionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isSelected;

  const WalletPositionButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: isSelected
            ? theme.colorScheme.onSurface
            : theme.colorScheme.surface,
        foregroundColor: isSelected
            ? theme.colorScheme.surface
            : theme.colorScheme.onSurface,
        minimumSize: Size(double.infinity, 50.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.r)),
      ),
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

// ────────── Transaction Wallwt State ──────────
class _TransactionWallwtState extends State<TransactionWallwt> {
  String? _selectedWalletPosition = 'bank';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locProvider = Provider.of<LocalizationProvider>(context);
    final loc = locProvider.loc;

    // Toggle wallet position
    void toggleWalletPosition(String position) {
      setState(() {
        _selectedWalletPosition = position;
      });
      widget.onChanged?.call(position);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.moneyPosition,
          style: TextStyle(fontSize: 12.sp, color: theme.colorScheme.onSurface),
        ),
        SizedBox(height: 8.h),

        Row(
          children: [
            Expanded(
              child: WalletPositionButton(
                label: loc.bank,
                icon: LucideIcons.landmark,
                isSelected: _selectedWalletPosition == 'bank',
                onPressed: () => toggleWalletPosition('bank'),
              ),
            ),
            SizedBox(width: 12.w),

            Expanded(
              child: WalletPositionButton(
                label: loc.cash,
                icon: LucideIcons.wallet,
                isSelected: _selectedWalletPosition == 'cash',
                onPressed: () => toggleWalletPosition('cash'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
