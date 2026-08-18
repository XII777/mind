#!/usr/bin/env bash
set -e
echo "Applying tamper protection time-lock feature..."
mkdir -p "lib/providers/system"
cat > "lib/providers/system/tamper_lock_provider.dart" << 'TAMPER_EOF'
/*
 *
 *  * Copyright (c) 2024 Mindful (https://github.com/akaMrNagar/Mindful)
 *  * Author : Pawan Nagar (https://github.com/akaMrNagar)
 *  *
 *  * This source code is licensed under the GPL-2.0 license license found in the
 *  * LICENSE file in the root directory of this source tree.
 *
 */

import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// Immutable snapshot of the tamper-protection lock state.
class TamperLockState {
  const TamperLockState({
    required this.lockDurationDays,
    required this.lockStartedAt,
  });

  /// How many days the lock stays active for, counted from
  /// [lockStartedAt]. A value of 0 means "no lock" (feature effectively
  /// disabled - tamper protection can be turned off any time).
  final int lockDurationDays;

  /// When the current lock period began, or null if tamper protection
  /// hasn't been enabled with a lock yet.
  final DateTime? lockStartedAt;

  /// The exact moment the current lock period ends, or null if no lock
  /// is active.
  DateTime? get lockEndsAt => lockStartedAt == null
      ? null
      : lockStartedAt!.add(Duration(days: lockDurationDays));

  /// True while the set number of days has not yet passed since the
  /// lock started. While true, tamper protection cannot be disabled.
  bool get isLocked {
    if (lockDurationDays <= 0 || lockStartedAt == null) return false;
    final endsAt = lockEndsAt!;
    return DateTime.now().isBefore(endsAt);
  }

  TamperLockState copyWith({
    int? lockDurationDays,
    DateTime? lockStartedAt,
    bool clearStart = false,
  }) {
    return TamperLockState(
      lockDurationDays: lockDurationDays ?? this.lockDurationDays,
      lockStartedAt: clearStart ? null : (lockStartedAt ?? this.lockStartedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'lockDurationDays': lockDurationDays,
        'lockStartedAt': lockStartedAt?.toIso8601String(),
      };

  factory TamperLockState.fromJson(Map<String, dynamic> json) {
    return TamperLockState(
      lockDurationDays: json['lockDurationDays'] as int? ?? 0,
      lockStartedAt: json['lockStartedAt'] != null
          ? DateTime.tryParse(json['lockStartedAt'] as String)
          : null,
    );
  }

  static const initial = TamperLockState(
    lockDurationDays: 7,
    lockStartedAt: null,
  );
}

/// Manages the tamper-protection time lock: once tamper protection
/// (device admin) is enabled, it can be locked for a configurable
/// number of days during which it cannot be disabled or the app
/// uninstalled through normal means. After that window passes, it
/// unlocks automatically.
///
/// Persisted to a small JSON file (not the Drift DB) to avoid schema
/// migrations for this standalone feature.
final tamperLockProvider =
    StateNotifierProvider<TamperLockNotifier, TamperLockState>(
  (ref) => TamperLockNotifier(),
);

class TamperLockNotifier extends StateNotifier<TamperLockState> {
  bool _loaded = false;

  TamperLockNotifier() : super(TamperLockState.initial) {
    _init();
  }

  Future<File> _storageFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/tamper_lock_state.json');
  }

  Future<void> _init() async {
    try {
      final file = await _storageFile();
      if (await file.exists()) {
        final raw = await file.readAsString();
        state = TamperLockState.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      }
    } catch (_) {
      /// Corrupted/unreadable file — fall back to defaults.
      state = TamperLockState.initial;
    }
    _loaded = true;
  }

  Future<void> _persist() async {
    if (!_loaded) return;
    try {
      final file = await _storageFile();
      await file.writeAsString(jsonEncode(state.toJson()));
    } catch (_) {
      /// Best-effort persistence; ignore write failures.
    }
  }

  /// Sets how many days a newly-started lock period should last. Can
  /// only be changed while no lock is currently active, so the active
  /// countdown can't be shortened or bypassed mid-way.
  Future<bool> setLockDurationDays(int days) async {
    if (state.isLocked) return false;
    state = state.copyWith(lockDurationDays: days);
    await _persist();
    return true;
  }

  /// Starts (or restarts) the lock countdown from now, using the
  /// currently configured [TamperLockState.lockDurationDays]. Call this
  /// when tamper protection / device admin is freshly enabled.
  Future<void> startLock() async {
    if (state.lockDurationDays <= 0) return;
    state = state.copyWith(lockStartedAt: DateTime.now());
    await _persist();
  }

  /// Clears the lock entirely (e.g. after tamper protection is
  /// legitimately disabled once the window has passed).
  Future<void> clearLock() async {
    state = state.copyWith(clearStart: true);
    await _persist();
  }
}
TAMPER_EOF
echo "  wrote lib/providers/system/tamper_lock_provider.dart"
mkdir -p "lib/ui/dialogs"
cat > "lib/ui/dialogs/tamper_lock_duration_dialog.dart" << 'TAMPER_EOF'
/*
 *
 *  * Copyright (c) 2024 Mindful (https://github.com/akaMrNagar/Mindful)
 *  * Author : Pawan Nagar (https://github.com/akaMrNagar)
 *  *
 *  * This source code is licensed under the GPL-2.0 license license found in the
 *  * LICENSE file in the root directory of this source tree.
 *
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shows a dialog to pick the number of days tamper protection stays
/// locked (cannot be disabled) once enabled. Returns the picked value,
/// or null if cancelled.
Future<int?> showTamperLockDurationDialog({
  required BuildContext context,
  required int initialDays,
}) async {
  final controller = TextEditingController(text: initialDays.toString());

  return showDialog<int>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Tamper protection lock'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Once tamper protection is enabled, it cannot be disabled '
            'and the app cannot be uninstalled for this many days. '
            'Set to 0 to disable this lock.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Lock duration (days)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final days = int.tryParse(controller.text.trim()) ?? 0;
            Navigator.of(dialogContext).pop(days);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
TAMPER_EOF
echo "  wrote lib/ui/dialogs/tamper_lock_duration_dialog.dart"
mkdir -p "lib/ui/permissions"
cat > "lib/ui/permissions/admin_permission_tile.dart" << 'TAMPER_EOF'
/*
 *
 *  * Copyright (c) 2024 Mindful (https://github.com/akaMrNagar/Mindful)
 *  * Author : Pawan Nagar (https://github.com/akaMrNagar)
 *  *
 *  * This source code is licensed under the GPL-2.0 license license found in the
 *  * LICENSE file in the root directory of this source tree.
 *
 */

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindful/config/hero_tags.dart';
import 'package:mindful/core/database/adapters/time_of_day_adapter.dart';
import 'package:mindful/core/enums/item_position.dart';
import 'package:mindful/core/extensions/ext_build_context.dart';
import 'package:mindful/providers/system/parental_controls_provider.dart';
import 'package:mindful/providers/system/permissions_provider.dart';
import 'package:mindful/providers/system/tamper_lock_provider.dart';
import 'package:mindful/ui/common/default_list_tile.dart';
import 'package:mindful/ui/dialogs/confirmation_dialog.dart';
import 'package:mindful/ui/dialogs/tamper_lock_duration_dialog.dart';
import 'package:mindful/ui/permissions/accessibility_permission_card.dart';
import 'package:mindful/ui/permissions/permission_sheet.dart';
import 'package:mindful/ui/transitions/default_hero.dart';

class AdminPermissionTile extends ConsumerStatefulWidget {
  const AdminPermissionTile({super.key});

  @override
  ConsumerState<AdminPermissionTile> createState() =>
      _AdminPermissionTileState();
}

class _AdminPermissionTileState extends ConsumerState<AdminPermissionTile> {
  bool _wasAdminEnabled = false;

  void _toggleTamperProtection(
    BuildContext context,
    WidgetRef ref,
    bool isAdminEnabled,
    TimeOfDayAdapter uninstallWindowTime,
  ) async {
    /// Ask accessibility permission if not allowed
    if (!ref.read(permissionProvider).haveAccessibilityPermission) {
      const AccessibilityPermissionCard()
          .showAccessibilityPermissionSheet(context, ref);
      return;
    }

    if (isAdminEnabled) {
      /// User wants to Disable — blocked entirely while the tamper lock
      /// window is still active, regardless of the daily uninstall
      /// window, since the lock is meant to override it.
      final tamperLock = ref.read(tamperLockProvider);
      if (tamperLock.isLocked) {
        final endsAt = tamperLock.lockEndsAt!;
        context.showSnackAlert(
          'Tamper protection is locked until '
          '${endsAt.day}/${endsAt.month}/${endsAt.year} and cannot be '
          'disabled until then.',
        );
        return;
      }

      if (ref
          .read(parentalControlsProvider.notifier)
          .isBetweenUninstallWindow) {
        ref.read(permissionProvider.notifier).disableAdminPermission();
        await ref.read(tamperLockProvider.notifier).clearLock();
      } else {
        context.showSnackAlert(
          context.locale.permission_admin_snack_alert,
        );
      }
    } else {
      /// Confirm
      final isConfirm = await showConfirmationDialog(
        context: context,
        heroTag: HeroTags.tamperProtectionTileTag,
        icon: FluentIcons.shield_keyhole_20_filled,
        title: context.locale.tamper_protection_tile_title,
        info: context.locale.tamper_protection_confirmation_dialog_info,
        positiveLabel: context.locale.permission_button_grant_permission,
      );

      await Future.delayed(400.ms);
      if (!isConfirm || !context.mounted) return;

      /// User wants to Enable
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => PermissionSheet(
          icon: FluentIcons.shield_keyhole_20_filled,
          title: context.locale.permission_admin_title,
          description: context.locale.permission_admin_info,
          onTapGrantPermission: () {
            Navigator.of(sheetContext).maybePop();
            ref.read(permissionProvider.notifier).askAdminPermission();
          },
        ),
      );
    }
  }

  Future<void> _editLockDuration(BuildContext context) async {
    final tamperLock = ref.read(tamperLockProvider);

    if (tamperLock.isLocked) {
      context.showSnackAlert(
        'Lock duration cannot be changed while a lock is active.',
      );
      return;
    }

    final days = await showTamperLockDurationDialog(
      context: context,
      initialDays: tamperLock.lockDurationDays,
    );

    if (days == null) return;
    await ref.read(tamperLockProvider.notifier).setLockDurationDays(days);
  }

  @override
  Widget build(BuildContext context) {
    final haveAdminPermission =
        ref.watch(permissionProvider.select((v) => v.haveAdminPermission));
    final haveAccessibilityPermission = ref
        .watch(permissionProvider.select((v) => v.haveAccessibilityPermission));

    final uninstallWindowTime = ref
        .watch(parentalControlsProvider.select((v) => v.uninstallWindowTime));

    final tamperLock = ref.watch(tamperLockProvider);

    /// Start the lock countdown the moment admin permission transitions
    /// from off -> on (i.e. the user just granted it).
    if (haveAdminPermission && !_wasAdminEnabled) {
      Future.microtask(
        () => ref.read(tamperLockProvider.notifier).startLock(),
      );
    }
    _wasAdminEnabled = haveAdminPermission;

    final subtitle = tamperLock.isLocked
        ? 'Locked until ${tamperLock.lockEndsAt!.day}/'
            '${tamperLock.lockEndsAt!.month}/${tamperLock.lockEndsAt!.year} '
            '• Tap the days badge to change duration'
        : context.locale.tamper_protection_tile_subtitle;

    return DefaultHero(
      tag: HeroTags.tamperProtectionTileTag,
      child: DefaultListTile(
        position: ItemPosition.mid,
        switchValue: haveAdminPermission && haveAccessibilityPermission,
        leadingIcon: FluentIcons.shield_keyhole_20_regular,
        titleText: context.locale.tamper_protection_tile_title,
        subtitleText: subtitle,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _editLockDuration(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tamperLock.isLocked
                          ? FluentIcons.lock_closed_20_filled
                          : FluentIcons.calendar_edit_20_regular,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text('${tamperLock.lockDurationDays}d'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
            Switch(
              value: haveAdminPermission && haveAccessibilityPermission,
              onChanged: (_) => _toggleTamperProtection(
                context,
                ref,
                haveAdminPermission,
                uninstallWindowTime,
              ),
            ),
          ],
        ),
        onPressed: () => _toggleTamperProtection(
          context,
          ref,
          haveAdminPermission,
          uninstallWindowTime,
        ),
      ),
    );
  }
}
TAMPER_EOF
echo "  wrote lib/ui/permissions/admin_permission_tile.dart"
echo ""
echo "Done. Git status:"
git status --short
