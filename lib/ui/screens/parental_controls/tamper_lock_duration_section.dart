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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindful/core/enums/item_position.dart';
import 'package:mindful/core/extensions/ext_build_context.dart';
import 'package:mindful/providers/system/permissions_provider.dart';
import 'package:mindful/providers/system/tamper_lock_provider.dart';
import 'package:mindful/ui/common/default_list_tile.dart';
import 'package:mindful/ui/common/styled_text.dart';
import 'package:mindful/ui/dialogs/tamper_lock_duration_dialog.dart';

/// The tamper-protection lock-duration tile, grouped directly beneath
/// [AdminPermissionTile] as one connected card - same design language
/// used elsewhere in the app (e.g. Invincible mode's toggle followed
/// immediately by its time-window tile with a trailing value).
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

    final subtitle = tamperLock.isLocked
        ? 'Locked until ${tamperLock.lockEndsAt!.day}/'
            '${tamperLock.lockEndsAt!.month}/${tamperLock.lockEndsAt!.year}'
        : 'Days tamper protection stays locked once enabled';

    return DefaultListTile(
      position: ItemPosition.mid,
      titleText: 'Tamper protection lock',
      subtitleText: subtitle,
      trailing: StyledText(
        '${tamperLock.lockDurationDays} day'
        '${tamperLock.lockDurationDays == 1 ? '' : 's'}',
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      onPressed: () => _editLockDuration(context),
    );
  }
}
