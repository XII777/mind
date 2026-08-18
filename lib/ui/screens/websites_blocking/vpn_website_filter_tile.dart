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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindful/core/extensions/ext_build_context.dart';
import 'package:mindful/providers/restrictions/vpn_website_filter_provider.dart';
import 'package:mindful/ui/common/default_list_tile.dart';
import 'package:flutter/material.dart';

/// Toggle for the system-wide VPN DNS website filter: an alternative to
/// (and independent from) the accessibility-service based website
/// blocking, which instead filters DNS lookups against the same
/// blocklist for every app on the device via a local VPN tunnel.
class VpnWebsiteFilterTile extends ConsumerWidget {
  const VpnWebsiteFilterTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.watch(vpnWebsiteFilterProvider);

    return DefaultListTile(
      switchValue: isEnabled,
      leadingIcon: FluentIcons.wifi_lock_20_regular,
      titleText: 'VPN website filter',
      subtitleText: isEnabled
          ? 'Blocking sites system-wide via local VPN, for every app.'
          : 'Filter websites for all apps at once using a local VPN, '
              'instead of only inside browsers. Turning this on will '
              'take over from "Internet Blocker" if that\'s active, '
              'since only one VPN can run at a time.',
      onPressed: () async {
        final confirm = isEnabled ||
            await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Enable VPN website filter?'),
                content: const Text(
                  'This starts a local, on-device VPN that filters DNS '
                  'lookups against your blocklist for every app on this '
                  'device - no data leaves your device or goes through '
                  'any external server. It will take over from '
                  '"Internet Blocker" if that\'s currently running, since '
                  'Android only allows one active VPN at a time.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text('Enable'),
                  ),
                ],
              ),
            ) ??
            false;

        if (!confirm) return;
        await ref.read(vpnWebsiteFilterProvider.notifier).setEnabled(!isEnabled);
      },
    );
  }
}
