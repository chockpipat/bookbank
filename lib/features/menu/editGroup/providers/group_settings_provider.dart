import 'package:flutter/foundation.dart';
import 'package:bookbank/data/database.dart';
import 'package:bookbank/data/db_helper.dart';

class GroupSettingsProvider extends ChangeNotifier {
  List<GroupSettings> _groupSettings = [];
  bool _isLoading = false;

  List<GroupSettings> get groupSettings => _groupSettings;
  bool get isLoading => _isLoading;

  GroupSettingsProvider() {
    loadGroupSettings();
  }

  Future<void> loadGroupSettings() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final settings = await DatabaseHelper.instance.getAllGroupSettings();
      _groupSettings = settings;
    } catch (e) {
      debugPrint('Error loading group settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  GroupSettings? getGroupSettings(String groupId) {
    try {
      return _groupSettings.firstWhere(
        (s) => s.groupId == groupId,
        orElse: () => GroupSettings(
          groupId: groupId,
          groupName: groupId,
          iconCodePoint: 0xe145,
          colorValue: 0xFF2196F3,
          savingsGoalEnabled: false,
          savingsGoalAmount: 0,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  /// Generate the next available group ID (Group1, Group2, ...)
  String _nextGroupId() {
    var max = 0;
    final pattern = RegExp(r'^Group(\d+)$');
    for (final s in _groupSettings) {
      final match = pattern.firstMatch(s.groupId);
      if (match != null) {
        final n = int.tryParse(match.group(1)!) ?? 0;
        if (n > max) max = n;
      }
    }
    return 'Group${max + 1}';
  }

  /// Add a new category group and refresh the list
  Future<GroupSettings?> addGroup({
    required String groupName,
    required int iconCodePoint,
    required int colorValue,
    bool savingsGoalEnabled = false,
    double savingsGoalAmount = 0,
  }) async {
    try {
      final settings = GroupSettings(
        groupId: _nextGroupId(),
        groupName: groupName,
        iconCodePoint: iconCodePoint,
        colorValue: colorValue,
        savingsGoalEnabled: savingsGoalEnabled,
        savingsGoalAmount: savingsGoalAmount,
      );
      await DatabaseHelper.instance.insertGroupSettings(settings);
      await loadGroupSettings();
      return getGroupSettings(settings.groupId);
    } catch (e) {
      debugPrint('Error adding group settings: $e');
      return null;
    }
  }

  Future<void> updateGroupSettings(GroupSettings settings) async {
    try {
      await DatabaseHelper.instance.updateGroupSettings(settings);
      await loadGroupSettings();
    } catch (e) {
      debugPrint('Error updating group settings: $e');
    }
  }

  Future<void> refresh() async {
    await loadGroupSettings();
  }
}
