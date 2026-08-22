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
import 'package:mindful/core/extensions/ext_num.dart';
import 'package:mindful/providers/apps/apps_info_provider.dart';
import 'package:mindful/providers/restrictions/apps_restrictions_provider.dart';
import 'package:mindful/providers/system/permissions_provider.dart';
import 'package:mindful/ui/common/default_list_tile.dart';
import 'package:mindful/ui/common/scaffold_shell.dart';
import 'package:mindful/ui/common/sliver_distracting_apps_list.dart';
import 'package:mindful/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:mindful/ui/common/styled_text.dart';
import 'package:mindful/ui/permissions/permission_sheet.dart';
import 'package:sliver_tools/sliver_tools.dart';

class InternetBlockedAppsScreen extends ConsumerStatefulWidget {
  const InternetBlockedAppsScreen({super.key});

  @override
  ConsumerState<InternetBlockedAppsScreen> createState() =>
      _InternetBlockedAppsScreenState();
}

class _InternetBlockedAppsScreenState
    extends ConsumerState<InternetBlockedAppsScreen> {
  @override
  Widget build(BuildContext context) {
    final haveVpnPermission =
        ref.watch(permissionProvider.select((v) => v.haveVpnPermission));

    final blockedPackages = ref.watch(
      appsRestrictionsProvider.select(
        (v) => v.values
            .where((e) => !e.canAccessInternet)
            .map((e) => e.appPackage)
            .toList(),
      ),
    );

    return ScaffoldShell(
      items: [
        NavbarItem(
          icon: FluentIcons.globe_prohibited_20_regular,
          filledIcon: FluentIcons.globe_prohibited_20_filled,
          titleText: 'Internet blocked apps',
          sliverBody: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              MultiSliver(
                children: [
                  /// Info text
                  StyledText(
                    'Block internet access for specific apps. Apps in this group cannot access the internet, even in the background.',
                  ),

                  16.vBox,

                  /// VPN permission warning if not granted
                  if (!haveVpnPermission)
                    DefaultListTile(
                      position: ItemPosition.none,
                      leadingIcon: FluentIcons.warning_20_filled,
                      titleText: 'VPN permission required',
                      subtitleText:
                          'Grant VPN permission to block internet access.',
                      accent: Theme.of(context).colorScheme.error,
                      trailing: const Icon(FluentIcons.chevron_right_20_regular),
                      onPressed: () => _showVpnPermissionSheet(context),
                    ),

                  if (!haveVpnPermission) 16.vBox,

                  /// Blocked apps count card
                  _BlockedCountCard(blockedCount: blockedPackages.length),

                  24.vBox,
                ],
              ),

              /// App list (add/remove)
              SliverDistractingAppsList(
                isInsideModalSheet: false,
                distractingApps: blockedPackages,
                onSelectionChanged: (package, isSelected) {
                  if (!haveVpnPermission) {
                    _showVpnPermissionSheet(context);
                    return;
                  }
                  ref
                      .read(appsRestrictionsProvider.notifier)
                      .switchInternetAccess(package, !isSelected);

                  final appName =
                      ref.read(appsInfoProvider).value?[package]?.name ??
                          package;

                  context.showSnackAlert(
                    isSelected
                        ? '$appName internet access blocked'
                        : '$appName internet access restored',
                    icon: isSelected
                        ? FluentIcons.globe_prohibited_20_filled
                        : FluentIcons.globe_20_filled,
                  );
                },
              ),

              const SliverTabsBottomPadding(),
            ],
          ),
        )
      ],
    );
  }

  void _showVpnPermissionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => PermissionSheet(
        icon: FluentIcons.channel_share_20_filled,
        title: 'VPN Permission',
        description:
            'Mindful uses a local VPN to block internet access for selected apps. Your data never leaves your device.',
        onTapGrantPermission: () {
          Navigator.of(sheetContext).maybePop();
          ref.read(permissionProvider.notifier).askVpnPermission();
        },
      ),
    );
  }
}

/// Small summary card showing blocked app count
class _BlockedCountCard extends StatelessWidget {
  const _BlockedCountCard({required this.blockedCount});
  final int blockedCount;

  @override
  Widget build(BuildContext context) {
    return DefaultListTile(
      position: ItemPosition.none,
      leadingIcon: blockedCount > 0
          ? FluentIcons.globe_prohibited_20_filled
          : FluentIcons.globe_20_regular,
      accent: blockedCount > 0 ? Theme.of(context).colorScheme.error : null,
      titleText: blockedCount > 0
          ? '$blockedCount ${blockedCount == 1 ? 'app' : 'apps'} blocked'
          : 'No apps blocked',
      subtitleText: blockedCount > 0
          ? 'These apps cannot access the internet.'
          : 'Select apps below to block their internet access.',
    );
  }
}
