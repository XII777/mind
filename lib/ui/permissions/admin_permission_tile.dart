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
