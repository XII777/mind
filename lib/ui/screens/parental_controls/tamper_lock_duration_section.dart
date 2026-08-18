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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindful/core/enums/item_position.dart';
import 'package:mindful/core/extensions/ext_build_context.dart';
import 'package:mindful/core/extensions/ext_widget.dart';
import 'package:mindful/providers/system/permissions_provider.dart';
import 'package:mindful/providers/system/tamper_lock_provider.dart';
import 'package:mindful/ui/common/content_section_header.dart';
import 'package:mindful/ui/common/default_list_tile.dart';
import 'package:mindful/ui/dialogs/tamper_lock_duration_dialog.dart';
import 'package:sliver_tools/sliver_tools.dart';

/// A dedicated section (its own header + tile) for configuring how many
/// days tamper protection stays locked once enabled, and for showing
/// the current lock status. Kept separate from the tamper protection
/// enable/disable toggle so both are easy to find and uncluttered.
class TamperLockDurationSection extends ConsumerStatefulWidget {
  const TamperLockDurationSection({super.key});

  @override
  ConsumerState<TamperLockDurationSection> createState() =>
      _TamperLockDurationSectionState();
}

class _TamperLockDurationSectionState
    extends ConsumerState<TamperLockDurationSection> {
  bool _wasAdminEnabled = false;

  Future<void> _editLockDuration(BuildContext context) async {
    final tamperLock = ref.read(tamperLockProvider);

    if (tamperLock.isLocked) {
      context.showSnackAlert(
        'Lock duration cannot be changed while a lock is currently active.',
      );
      return;
    }

    final days = await showTamperLockDurationDialog(
      context: context,
      initialDays: tamperLock.lockDurationDays,
    );

    if (days == null) return;
    final applied =
        await ref.read(tamperLockProvider.notifier).setLockDurationDays(days);

    if (!applied && context.mounted) {
      context.showSnackAlert(
        'Lock duration cannot be changed while a lock is currently active.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final haveAdminPermission =
        ref.watch(permissionProvider.select((v) => v.haveAdminPermission));
    final tamperLock = ref.watch(tamperLockProvider);

    /// Start the lock countdown the moment admin permission transitions
    /// from off -> on (i.e. the user just granted tamper protection).
    if (haveAdminPermission && !_wasAdminEnabled) {
      Future.microtask(
        () => ref.read(tamperLockProvider.notifier).startLock(),
      );
    }
    _wasAdminEnabled = haveAdminPermission;

    final statusSubtitle = !haveAdminPermission
        ? 'Enable tamper protection above first for this to take effect.'
        : tamperLock.lockDurationDays <= 0
            ? 'No lock set — tamper protection can be disabled any time.'
            : tamperLock.isLocked
                ? 'Locked until ${tamperLock.lockEndsAt!.day}/'
                    '${tamperLock.lockEndsAt!.month}/'
                    '${tamperLock.lockEndsAt!.year}. Cannot be disabled '
                    'until then.'
                : 'Not currently locked. A new ${tamperLock.lockDurationDays}-day '
                    'lock will start next time tamper protection is enabled.';

    return MultiSliver(
      children: [
        ContentSectionHeader(
          title: 'Tamper protection lock',
        ).sliver,
        DefaultListTile(
          position: ItemPosition.fit,
          leadingIcon: tamperLock.isLocked
              ? FluentIcons.lock_closed_20_filled
              : FluentIcons.calendar_edit_20_regular,
          titleText: 'Lock duration',
          subtitleText: statusSubtitle,
          trailing: Text(
            '${tamperLock.lockDurationDays} day'
            '${tamperLock.lockDurationDays == 1 ? '' : 's'}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () => _editLockDuration(context),
        ).sliver,
      ],
    );
  }
}
