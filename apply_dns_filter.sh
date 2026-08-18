#!/usr/bin/env bash
set -e
echo "Applying: separate tamper-lock section, README credit, VPN website filter..."
mkdir -p "."
cat > "README.md" << 'BIGFEAT_EOF'

> [!NOTE]
> **This is a modified fork of [Mindful](https://github.com/akaMrNagar/Mindful).**
> All credit for the original app, its design, and architecture goes to
> its creator, **Pawan Nagar** ([@akaMrNagar](https://github.com/akaMrNagar)) — see the
> [original repository here](https://github.com/akaMrNagar/Mindful).
> This fork adds and customizes features on top of that original work
> and is not affiliated with or endorsed by the original author. Please
> support the original project by starring it and, if you're looking
> for the official app, downloading it from the
> [Play Store](https://play.google.com/store/apps/details?id=com.mindful.android)
> or [original GitHub releases](https://github.com/akamrnagar/mindful/releases/latest).

<div align="center">
    <a href="https://bemindful.vercel.app/"><img alt="Icon" src="docs/assets/mindful.png" width="144px" /></a>
    <h1> <b>Mindful</b></h1>
    <a href="https://play.google.com/store/apps/details?id=com.mindful.android"><img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" height="96" /></a>
    <a href="https://github.com/akamrnagar/mindful/releases/latest"><img src="docs/assets/github_badge.png" height="96" /></a>
</div>



**Mindful** is a free and open-source app designed to help you regain control over your digital habits, improve your focus, and boost productivity. Whether you're battling social media addiction, struggling to stay focused, or simply looking for a way to better manage your screen time, Mindful is here to assist.


[![API](https://img.shields.io/badge/API-🤖-black)](docs/API.md)
[![Contribute](https://img.shields.io/badge/Build_&_Contribute-🛠️-black)](docs/CONTRIBUTING.md)
[![Verify](https://img.shields.io/badge/Verify-🔐-black)](docs/VERIFICATION.md) 
[![Privacy](https://img.shields.io/badge/Privacy_Policy-📃-black)](https://bemindful.vercel.app/privacy) 
[![Faqs](https://img.shields.io/badge/FAQs-🙋-black)](docs/FAQS.md) 
[![Featured](https://img.shields.io/badge/Featured-🎉-black)](docs/FEATURED.md) 
[![GitHub](https://img.shields.io/github/downloads/akamrnagar/mindful/total?label=Downloads&logo=github&cacheSeconds=3600)](https://github.com/akamrnagar/mindful/releases/latest)
[![Google Play](https://img.shields.io/endpoint?color=40bb12&label=Downloads&logo=google-play&url=https%3A%2F%2Fplay.cuzi.workers.dev%2Fplay%3Fi%3Dcom.mindful.android%26l%3Ddownloads%26m%3D%24totalinstalls)](https://play.google.com/store/apps/details?id=com.mindful.android)
[![Telegram](https://img.shields.io/badge/Telegram-2CA5E0?logo=telegram&logoColor=white)](https://t.me/fossmindful)
[![Instagram](https://img.shields.io/badge/Instagram-e7336f?logo=instagram&logoColor=white)](https://instagram.com/lasthopedevelopers)

---

| <img src="docs/assets/screenshots/screenshot_1.png"> | <img src="docs/assets/screenshots/screenshot_2.png"> | <img src="docs/assets/screenshots/screenshot_3.png"> | <img src="docs/assets/screenshots/screenshot_4.png"> |
| ---------------------------------------------------- | ---------------------------------------------------- | ---------------------------------------------------- | ---------------------------------------------------- |
| <img src="docs/assets/screenshots/screenshot_5.png"> | <img src="docs/assets/screenshots/screenshot_6.png"> | <img src="docs/assets/screenshots/screenshot_7.png"> | <img src="docs/assets/screenshots/screenshot_8.png"> |

# 💪 Features

- ### 1. Focus Mode
    Stay on track with session types like Study, Work, or Creative. Use countdown or stopwatch modes, and review your session timeline to track progress and stay consistent.

- ### 2. Screen Time Limits
    Set daily usage limits for apps — especially for addictive short content like Reels or Shorts. Group similar apps, add shared limits, and enable Invincible Mode to lock restrictions after they're hit.

- ### 3. Detailed Usage Insights
    Check weekly screen time, app usage, and data consumption. Mindful helps you understand your habits so you can take control of your time.

- ### 4. App & Internet Blocking
    Block distracting apps or cut off internet access with one tap. Filter adult content and create a focused, safe environment for work or study.

- ### 5. Notification Management
    Batch notifications, schedule delivery, or mute apps during focus time. Keep interruptions low and your attention high.

- ### 6. Bedtime Mode
    Wind down with paused apps and DND during sleep hours. Wake up to a clean slate — apps resume automatically when the day begins.

- ### 7. Parental Controls
    Set healthy digital habits for children with tamper-proof restrictions, invincible mode, and optional biometric lock.

- ### 8. Privacy-First & Open Source
    No ads. No tracking. Mindful works completely offline, keeping your data on your device and it's fully open-source, forever.

> [!IMPORTANT]
> ## Why _internet_ permission in manifest?
> 
> Android restricts apps from creating and protecting Local VPN tunnels without network permission. The Local VPN allows Mindful to block internet access for selected apps. This is why you see the network permission in Mindful's manifest. However, rest assured that Mindful does not collect or transmit any user data. You can verify this by checking the network usage in the app or in your device settings. 



# Donate 

Mindful is a Free and Open Source Software (FOSS) that took months of dedicated, restless work to develop. If you find this app helpful, please consider making a donation to support our efforts and ensure continued development. Your generosity will help us keep improving and maintaining Mindful for everyone.

_Note: Drop your socials along with your donation to get recognized as a supporter._

<a href="https://buymeacoffee.com/akamrnagar"><img src="docs/assets/donation/bmc_qr.png" height="184" ></a>
&emsp;
<a href="https://github.com/akaMrNagar/Mindful?tab=readme-ov-file#donate"><img src="docs/assets/donation/upi_qr.png" height="184" ></a>

[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-🖤-ffdd00)](https://www.buymeacoffee.com/akamrnagar)
[![UPI](https://img.shields.io/badge/akamrnagar@upi-🖤-f47820)]()
[![Sponsor Me on GitHub](https://img.shields.io/badge/Sponsor%20Me%20on%20GitHub-🖤-db61a2)](https://github.com/sponsors/akamrnagar)


# Feedback and Support

Your feedback is invaluable to us! If you have suggestions, encounter issues, or simply want to share your thoughts, please reach out to us through the following channels : 

* **[GitHub (bug)](https://github.com/akaMrNagar/Mindful/issues/new?&template=bug_report.md)**
* **[GitHub (enhancement)](https://github.com/akaMrNagar/Mindful/issues/new?&template=feature_request.md)**
* **[GitHub (vulnerability)](https://github.com/akaMrNagar/Mindful/security/advisories/new)**
* **[Write to us via email](mailto:help.lasthopedevs@gmail.com)**

---
# Translation & Localization

![Translate](https://img.shields.io/badge/Translate-Crowdin-4cc71e?logo=crowdin)
[![Localized](https://badges.crowdin.net/mindful/localized.svg)](https://crowdin.com/project/mindful)

A huge thank you to our amazing localization contributors in making Mindful accessible to the world.


[*@michelangelodepascale02*](https://crowdin.com/profile/michelangelodepascale02), 
[*@mysticxz*](https://crowdin.com/profile/mysticxz), 
[*@wreckingbang*](https://crowdin.com/profile/wreckingbang), 
[*@eric*.nevard](https://crowdin.com/profile/eric.nevard), 
[*@deltridev*](https://crowdin.com/profile/deltridev), 
[*@luxdev01*](https://crowdin.com/profile/luxdev01), 
[*@na7m*](https://crowdin.com/profile/na7m), 
[*@riikun*](https://crowdin.com/profile/riikun), 
[*@kareemkimo*](https://crowdin.com/profile/kareemkimo), 
[*@uito*](https://crowdin.com/profile/uito), 
[*@netobloom*](https://crowdin.com/profile/netobloom), 
[*@marcmaderhome123*](https://crowdin.com/profile/marcmaderhome123), 
[*@alpereneryilmaz03*](https://crowdin.com/profile/alpereneryilmaz03), 
[*@keremk*](https://crowdin.com/profile/keremk), 
[*@nolhanproduction*](https://crowdin.com/profile/nolhanproduction), 
[*@lefetrtp*](https://crowdin.com/profile/lefetrtp), 
[*@ceceayo*](https://crowdin.com/profile/ceceayo), 
[*@jihuayu*](https://crowdin.com/profile/jihuayu), 
[*@ngocanh*.tve](https://crowdin.com/profile/ngocanh.tve), 
[*@vinaooooo*](https://crowdin.com/profile/vinaooooo), 
[*@nlhm*](https://crowdin.com/profile/nlhm), 
[*@nevena2ooo*](https://crowdin.com/profile/nevena2ooo), 
[*@nerisal*](https://crowdin.com/profile/nerisal), 
[*@andriik*](https://crowdin.com/profile/andriik), 
[*@mateuszam*](https://crowdin.com/profile/mateuszam), 
[*@jrodenas*](https://crowdin.com/profile/jrodenas), 
[*@andre*.fernandes.it](https://crowdin.com/profile/andre.fernandes.it), 
[*@fireflurry*](https://crowdin.com/profile/fireflurry),
[*@youquan0914*](https://crowdin.com/profile/youquan0914), 
[*@e_cllf*](https://crowdin.com/profile/e_cllf).
[*@cypherzane*](https://crowdin.com/profile/cypherzane).
[*@none_baiano*](https://crowdin.com/profile/none_baiano).
BIGFEAT_EOF
echo "  wrote README.md"
mkdir -p "lib/ui/permissions"
cat > "lib/ui/permissions/admin_permission_tile.dart" << 'BIGFEAT_EOF'
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
import 'package:mindful/core/enums/item_position.dart';
import 'package:mindful/core/extensions/ext_build_context.dart';
import 'package:mindful/providers/system/parental_controls_provider.dart';
import 'package:mindful/providers/system/permissions_provider.dart';
import 'package:mindful/providers/system/tamper_lock_provider.dart';
import 'package:mindful/ui/common/default_list_tile.dart';
import 'package:mindful/ui/dialogs/confirmation_dialog.dart';
import 'package:mindful/ui/permissions/accessibility_permission_card.dart';
import 'package:mindful/ui/permissions/permission_sheet.dart';
import 'package:mindful/ui/transitions/default_hero.dart';

/// Simple tamper-protection (device admin) enable/disable toggle. The
/// lock-duration setting lives in its own section - see
/// [TamperLockDurationSection] - to keep this row uncluttered.
class AdminPermissionTile extends ConsumerWidget {
  const AdminPermissionTile({super.key});

  void _toggleTamperProtection(
    BuildContext context,
    WidgetRef ref,
    bool isAdminEnabled,
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
          'disabled until then. See "Tamper protection lock" below.',
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final haveAdminPermission =
        ref.watch(permissionProvider.select((v) => v.haveAdminPermission));
    final haveAccessibilityPermission = ref
        .watch(permissionProvider.select((v) => v.haveAccessibilityPermission));

    return DefaultHero(
      tag: HeroTags.tamperProtectionTileTag,
      child: DefaultListTile(
        position: ItemPosition.mid,
        switchValue: haveAdminPermission && haveAccessibilityPermission,
        leadingIcon: FluentIcons.shield_keyhole_20_regular,
        titleText: context.locale.tamper_protection_tile_title,
        subtitleText: context.locale.tamper_protection_tile_subtitle,
        onPressed: () => _toggleTamperProtection(
          context,
          ref,
          haveAdminPermission,
        ),
      ),
    );
  }
}
BIGFEAT_EOF
echo "  wrote lib/ui/permissions/admin_permission_tile.dart"
mkdir -p "lib/ui/screens/parental_controls"
cat > "lib/ui/screens/parental_controls/tamper_lock_duration_section.dart" << 'BIGFEAT_EOF'
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
BIGFEAT_EOF
echo "  wrote lib/ui/screens/parental_controls/tamper_lock_duration_section.dart"
mkdir -p "lib/ui/screens/parental_controls"
cat > "lib/ui/screens/parental_controls/parental_controls_screen.dart" << 'BIGFEAT_EOF'
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
import 'package:mindful/config/hero_tags.dart';
import 'package:mindful/core/enums/item_position.dart';
import 'package:mindful/core/extensions/ext_build_context.dart';
import 'package:mindful/core/extensions/ext_widget.dart';
import 'package:mindful/core/services/auth_service.dart';
import 'package:mindful/providers/system/parental_controls_provider.dart';
import 'package:mindful/providers/system/permissions_provider.dart';
import 'package:mindful/ui/common/content_section_header.dart';
import 'package:mindful/ui/common/default_list_tile.dart';
import 'package:mindful/ui/common/scaffold_shell.dart';
import 'package:mindful/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:mindful/ui/common/styled_text.dart';
import 'package:mindful/ui/dialogs/time_picker_dialog.dart';
import 'package:mindful/ui/permissions/admin_permission_tile.dart';
import 'package:mindful/ui/screens/parental_controls/invincible_mode_settings.dart';
import 'package:mindful/ui/screens/parental_controls/tamper_lock_duration_section.dart';
import 'package:mindful/ui/transitions/default_hero.dart';

class ParentalControlsScreen extends ConsumerWidget {
  const ParentalControlsScreen({super.key});

  void _toggleProtectedAccess(
    BuildContext context,
    WidgetRef ref,
    bool isAccessProtected,
  ) async {
    try {
      if (!isAccessProtected) {
        final isAuthenticated = await AuthService.instance.authenticate();

        /// Return if not mounted
        if (!context.mounted) return;

        /// If no locks available
        if (isAuthenticated == null) {
          context.showSnackAlert(
            context.locale.protected_access_no_lock_snack_alert,
            icon: FluentIcons.fingerprint_20_filled,
          );
          return;
        }

        /// If aborted the auth
        if (!isAuthenticated) {
          context.showSnackAlert(
            context.locale.protected_access_failed_lock_snack_alert,
            icon: FluentIcons.fingerprint_20_filled,
          );

          return;
        }
      }

      ref.read(parentalControlsProvider.notifier).switchProtectedAccess();
    } catch (e) {
      debugPrint("Failed to authenticate: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentalControls = ref.watch(parentalControlsProvider);
    final isAdminEnabled =
        ref.watch(permissionProvider.select((v) => v.haveAdminPermission));

    return ScaffoldShell(
      items: [
        NavbarItem(
          icon: FluentIcons.shield_keyhole_20_regular,
          filledIcon: FluentIcons.shield_keyhole_20_filled,
          titleText: context.locale.parental_controls_tab_title,
          sliverBody: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              /// Invincible mode
              const InvincibleModeSettings(),

              /// Parental controls
              ContentSectionHeader(
                title: context.locale.parental_controls_tab_title,
              ).sliver,

              /// Protected access
              DefaultListTile(
                position: ItemPosition.top,
                switchValue: parentalControls.protectedAccess,
                leadingIcon: FluentIcons.fingerprint_20_regular,
                titleText: context.locale.protected_access_tile_title,
                subtitleText: context.locale.protected_access_tile_subtitle,
                onPressed: () => _toggleProtectedAccess(
                  context,
                  ref,
                  parentalControls.protectedAccess,
                ),
              ).sliver,

              /// Tamper protection
              const AdminPermissionTile().sliver,

              /// Uninstall window
              DefaultHero(
                tag: HeroTags.uninstallWindowTileTag,
                child: DefaultListTile(
                  position: ItemPosition.bottom,
                  titleText: context.locale.uninstall_window_tile_title,
                  subtitleText: context.locale.uninstall_window_tile_subtitle,
                  trailing: StyledText(
                    parentalControls.uninstallWindowTime.format(context),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  onPressed: () async {
                    /// Check if between the specified window
                    if (isAdminEnabled &&
                        !ref
                            .read(parentalControlsProvider.notifier)
                            .isBetweenUninstallWindow) {
                      context.showSnackAlert(
                        context.locale.permission_admin_snack_alert,
                      );
                      return;
                    }

                    final pickedTime = await showCustomTimePickerDialog(
                      context: context,
                      heroTag: HeroTags.uninstallWindowTileTag,
                      initialTime: parentalControls.uninstallWindowTime,
                      info: context.locale.uninstall_window_tile_title,
                    );

                    if (pickedTime != null && context.mounted) {
                      ref
                          .read(parentalControlsProvider.notifier)
                          .changeUninstallWindowTime(pickedTime);
                    }
                  },
                ),
              ).sliver,

              /// Tamper protection lock duration - separate section
              const TamperLockDurationSection(),

              const SliverTabsBottomPadding(),
            ],
          ),
        )
      ],
    );
  }
}
BIGFEAT_EOF
echo "  wrote lib/ui/screens/parental_controls/parental_controls_screen.dart"
mkdir -p "lib/core/services"
cat > "lib/core/services/method_channel_service.dart" << 'BIGFEAT_EOF'
/*
 *
 *  * Copyright (c) 2024 Mindful (https://github.com/akaMrNagar/Mindful)
 *  * Author : Pawan Nagar (https://github.com/akaMrNagar)
 *  *
 *  * This source code is licensed under the GPL-2.0 license license found in the
 *  * LICENSE file in the root directory of this source tree.
 *
 */

import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mindful/core/database/app_database.dart';
import 'package:mindful/models/usage_model.dart';
import 'package:mindful/models/app_info.dart';
import 'package:mindful/models/device_info_model.dart';

/// This class handles the Flutter method channel and is responsible for invoking native Android Java code.
///
/// It provides methods for communication between the Flutter and native Android parts of the application.
class MethodChannelService {
  /// Singleton instance of the MethodChannelService.
  static final MethodChannelService instance = MethodChannelService._();

  /// Private constructor for enforcing the singleton pattern.
  MethodChannelService._();

  /// The method channel object used for communication.
  final MethodChannel _methodChannel = const MethodChannel(
    'com.peace.mind.methodchannel.fg',
  );

  /// Flag indicating if the app is restarted by itself (after importing database).
  bool get isSelfRestart => _isSelfRestart;
  bool _isSelfRestart = false;

  /// [DeviceInfoModel] containing information about this device on which app is running
  DeviceInfoModel get deviceInfo => _deviceInfo;
  late DeviceInfoModel _deviceInfo;

  /// Initializes the method channel by setting a handler for incoming method calls from the native side.
  Future<void> init() async {
    _methodChannel.setMethodCallHandler(
      (call) async {
        if (call.method == "updateSelfStartStatus") {
          _isSelfRestart = call.arguments as bool? ?? false;
        }
      },
    );

    /// Load information about the device
    _deviceInfo = await MethodChannelService.instance.getDeviceInfo();
  }

  // ===========================================================================================
  // ==================================== SETUP ================================================
  // ===========================================================================================

  /// Update locale on the native side
  Future<bool> updateLocale({required String languageCode}) async =>
      await _methodChannel.invokeMethod('updateLocale', languageCode);

  /// Update excluded apps for widget purpose
  Future<bool> updateExcludedApps(List<String> excludedApps) async =>
      await _methodChannel.invokeMethod(
        'updateExcludedApps',
        jsonEncode(excludedApps),
      );

  /// Gets the map of device info and create and returns [DeviceInfoModel] .
  Future<DeviceInfoModel> getDeviceInfo() async => DeviceInfoModel.fromMap(
      await _methodChannel.invokeMapMethod('getDeviceInfo') ?? {});

  /// Gets the launch counts of apps mapped to their package name.
  Future<Map<String, int>> getAppsLaunchCount() async =>
      await _methodChannel.invokeMapMethod<String, int>('getAppsLaunchCount') ??
      {};

  /// Gets the total short screen time for the device in milliseconds.
  ///
  /// This method retrieves the total screen time spent on short-form video apps
  /// and converts it to seconds before returning the value.
  Future<int> getShortsScreenTimeSec() async {
    int time = await _methodChannel.invokeMethod('getShortsScreenTimeMs');
    return time ~/ 1000;
  }

  /// Gets all the stored native crash logs and clears them afterward.
  Future<List<CrashLogsTableCompanion>> getNativeCrashLogs() async {
    List<CrashLogsTableCompanion> crashLogs = [];

    try {
      String jsonString =
          await _methodChannel.invokeMethod('getNativeCrashLogs');

      List<dynamic> logMapsList = jsonDecode(jsonString);

      for (var item in logMapsList) {
        if (item is Map) {
          final logMap = Map<String, dynamic>.from(item);
          final log = CrashLogsTableCompanion(
            appVersion: Value(logMap['appVersion'] as String),
            timeStamp: Value(
              DateTime.fromMillisecondsSinceEpoch(logMap['timeStamp'] as int),
            ),
            error: Value((logMap['error'] as String).trim()),
            stackTrace: Value((logMap['stackTrace'] as String).trim()),
          );

          crashLogs.add(log);
        }
      }
    } catch (e) {
      debugPrint("MethodChannelService.getNativeCrashLogs() Error: $e");
    }

    return crashLogs;
  }

  /// Clears all the crash logs on the native side.
  Future<bool> clearNativeCrashLogs() async =>
      await _methodChannel.invokeMethod('clearNativeCrashLogs');

  /// Retrieves a list of all launchable apps installed on the user's device.
  Future<List<AppInfo>> fetchDeviceAppsInfo() async {
    try {
      List<Map> result =
          await _methodChannel.invokeListMethod<Map>('getDeviceAppsInfo') ?? [];
      return result.map((e) => AppInfo.fromMap(e)).toList();
    } catch (e) {
      debugPrint("MethodChannelService.fetchDeviceAppsInfo() Error: $e");
    }
    return [];
  }

  /// Loads Map of [String] package name and the respective [UsageModel] for the given interval
  ///
  /// The result map contains one [UsageModel] per app
  Future<Map<String, UsageModel>> fetchAppsUsageForInterval({
    required DateTime start,
    required DateTime end,
  }) async {
    Map<String, UsageModel> usagesMap = {};
    try {
      List<Map> results = await _methodChannel
              .invokeListMethod<Map>('getAppsUsageForInterval', {
            "startDateTime": start.millisecondsSinceEpoch,
            "endDateTime": end.millisecondsSinceEpoch,
          }) ??
          [];

      for (var map in results) {
        usagesMap[map["packageName"] as String] = UsageModel.fromMap(map);
      }
    } catch (e) {
      debugPrint("MethodChannelService.fetchAppsUsageForInterval() Error: $e");
    }
    return usagesMap;
  }

  // ===========================================================================================
  // ==================================== SERVICES =============================================
  // ===========================================================================================

  /// Safe method to update app restrictions list in the TRACKER service.
  ///
  /// This method push the updated list to the service if it is already running
  /// otherwise only start service if list is not empty
  Future<void> updateAppRestrictions(
    List<AppRestriction> appRestrictions,
  ) async =>
      _methodChannel.invokeMethod(
        'updateAppRestrictions',
        jsonEncode(appRestrictions),
      );

  /// Safe method to update restriction groups list in the TRACKER service.
  ///
  /// This method push the updated list to the service if it is already running
  /// otherwise only start service if list is not empty
  Future<void> updateRestrictionsGroups(
    List<RestrictionGroup> restrictionGroups,
  ) async =>
      _methodChannel.invokeMethod(
        'updateRestrictionsGroups',
        jsonEncode(restrictionGroups),
      );

  /// Safe method to update internet blocked apps in the VPN service.
  ///
  /// This method push the updated list to the service if it is already running
  /// otherwise only start service if list is not empty
  Future<void> updateInternetBlockedApps(List<String> blockedApps) async =>
      _methodChannel.invokeMethod(
        'updateInternetBlockedApps',
        jsonEncode(blockedApps),
      );

  /// Enables/disables the system-wide VPN DNS website filter and/or
  /// updates its blocklist. When [enabled] is true and [domains] is
  /// non-empty, this takes over the VPN tunnel from the per-app
  /// "Internet Blocker" (the two are mutually exclusive - only one VPN
  /// tunnel can be active at a time on Android). When disabled, control
  /// reverts to whatever the per-app blocker is currently configured to.
  Future<void> updateDnsWebsiteFilter({
    required bool enabled,
    required List<String> domains,
  }) async =>
      _methodChannel.invokeMethod('updateDnsWebsiteFilter', {
        'enabled': enabled,
        'domains': jsonEncode(domains),
      });

  /// Safe method to update settings in Notification Listener service if provided.
  /// Also Updates the notification batching schedule if provided.
  ///
  /// This method push the updated settings to the service if it is already running
  /// otherwise try to bind to service if needed
  Future<void> updateNotificationSettings(
    NotificationSettings settings,
  ) async =>
      _methodChannel.invokeMethod(
        'updateNotificationSettings',
        jsonEncode(settings),
      );

  /// Updates the well-being settings for the foreground service.
  ///
  /// This method takes a [Wellbeing] object and sends it to the native side
  Future<void> updateWellBeingSettings(Wellbeing wellBeingSettings) async =>
      _methodChannel.invokeMethod(
        'updateWellBeingSettings',
        jsonEncode(
          {
            "allowedShortsTimeSec": wellBeingSettings.allowedShortsTimeSec,
            "blockNsfwSites": wellBeingSettings.blockNsfwSites,
            "blockedFeatures":
                wellBeingSettings.blockedFeatures.map((e) => e.name).toList(),
            "blockedWebsites": wellBeingSettings.blockedWebsites,
            "nsfwWebsites": wellBeingSettings.nsfwWebsites,
          },
        ),
      );

  /// Updates the bedtime schedule.
  ///
  /// This method takes a [BedtimeSchedule] object and sends it to the native side
  Future<bool> updateBedtimeSchedule(BedtimeSchedule bedtimeSettings) async =>
      await _methodChannel.invokeMethod(
        'updateBedtimeSchedule',
        jsonEncode(bedtimeSettings),
      );

  /// Uses an emergency pass and pause the tracking service.
  ///
  /// This method sends a request to the native side to use an emergency pass.
  Future<bool> activeEmergencyPause() async =>
      await _methodChannel.invokeMethod('activeEmergencyPause');

  /// Start new focus session or only updates the list of distracting apps if already running.
  ///
  /// This method sends a request to the native side to start focus session.
  Future<void> updateFocusSession({
    required FocusSession session,
    required FocusProfile profile,
  }) async =>
      await _methodChannel.invokeMethod(
        'updateFocusSession',
        jsonEncode({
          'startTimeMsEpoch': session.startDateTime.millisecondsSinceEpoch,
          'durationSeconds': session.durationSecs,
          'toggleDnd': profile.shouldStartDnd,
          'distractingApps': profile.distractingApps,
        }),
      );

  /// Giveup or Finish running focus session with success or failure.
  ///
  /// This method sends a request to the native side to stop already running focus session.
  Future<bool> giveUpOrFinishFocusSession({
    required bool isTheSessionSuccessful,
  }) async =>
      await _methodChannel.invokeMethod(
        'giveUpOrFinishFocusSession',
        isTheSessionSuccessful,
      );

  // ===========================================================================================
  // ==================================== PERMISSIONS ==========================================
  // ===========================================================================================
  /// Checks if the admin permission is granted and optionally asks for it.
  ///
  /// Returns `true` if the permission is granted Otherwise, returns `false`.
  Future<bool> getAndAskAdminPermission(
          {bool askPermissionToo = false}) async =>
      await _methodChannel.invokeMethod(
        'getAndAskAdminPermission',
        askPermissionToo,
      );

  /// Checks if the accessibility permission is granted and optionally asks for it.
  ///
  /// This method returns `true` if the permission is granted Otherwise, it returns `false`.
  Future<bool> getAndAskAccessibilityPermission(
          {bool askPermissionToo = false}) async =>
      await _methodChannel.invokeMethod(
        'getAndAskAccessibilityPermission',
        askPermissionToo,
      );

  /// Checks if the usage access permission is granted and optionally asks for it.
  ///
  /// Returns `true` if the permission is granted Otherwise, returns `false`.
  Future<bool> getAndAskUsageAccessPermission(
          {bool askPermissionToo = false}) async =>
      await _methodChannel.invokeMethod(
        'getAndAskUsageAccessPermission',
        askPermissionToo,
      );

  /// Checks if the display overlay permission is granted and optionally asks for it.
  ///
  /// Returns `true` if the permission is granted Otherwise, returns `false`.
  Future<bool> getAndAskDisplayOverlayPermission(
          {bool askPermissionToo = false}) async =>
      await _methodChannel.invokeMethod(
        'getAndAskDisplayOverlayPermission',
        askPermissionToo,
      );

  /// Checks if the set exact alarm permission is granted and optionally asks for it.
  ///
  /// Returns `true` if the permission is granted Otherwise, returns `false`.
  Future<bool> getAndAskExactAlarmPermission(
          {bool askPermissionToo = false}) async =>
      await _methodChannel.invokeMethod(
        'getAndAskExactAlarmPermission',
        askPermissionToo,
      );

  /// Checks if the VPN permission is granted and optionally asks for it.
  ///
  /// This method returns `true` if the permission is granted Otherwise, it returns `false`.
  Future<bool> getAndAskVpnPermission({bool askPermissionToo = false}) async =>
      await _methodChannel.invokeMethod(
        'getAndAskVpnPermission',
        askPermissionToo,
      );

  /// Checks if the ignore battery optimization permission is granted and optionally asks for it.
  ///
  /// Returns `true` if the permission is granted Otherwise, returns `false`.
  Future<bool> getAndAskIgnoreBatteryOptimizationPermission(
          {bool askPermissionToo = false}) async =>
      await _methodChannel.invokeMethod(
        'getAndAskIgnoreBatteryOptimizationPermission',
        askPermissionToo,
      );

  /// Checks if the notification permission is granted and optionally asks for it.
  ///
  /// This method returns `true` if the permission is granted Otherwise, it returns `false`.
  Future<bool> getAndAskNotificationPermission(
          {bool askPermissionToo = false}) async =>
      await _methodChannel.invokeMethod(
        'getAndAskNotificationPermission',
        askPermissionToo,
      );

  /// Checks if the Do Not Disturb (DND) permission is granted and optionally asks for it.
  ///
  /// Returns `true` if the permission is granted Otherwise, returns `false`.
  Future<bool> getAndAskDndPermission({bool askPermissionToo = false}) async =>
      await _methodChannel.invokeMethod(
        'getAndAskDndPermission',
        askPermissionToo,
      );

  /// Checks if the Notification Access permission is granted and optionally asks for it.
  ///
  /// Returns `true` if the permission is granted Otherwise, returns `false`.
  Future<bool> getAndAskNotificationAccessPermission(
          {bool askPermissionToo = false}) async =>
      await _methodChannel.invokeMethod(
        'getAndAskNotificationAccessPermission',
        askPermissionToo,
      );

  /// Disable device Admin if active.
  Future<bool> disableDeviceAdmin() async =>
      await _methodChannel.invokeMethod('disableDeviceAdmin');

  // ===========================================================================================
  // ============================== EXTERNAL ACTIVITIES ========================================
  // ===========================================================================================

  /// Opens the device's Do Not Disturb (DND) settings.
  Future<bool> openDeviceDndSettings() async =>
      await _methodChannel.invokeMethod('openDeviceDndSettings');

  /// Opens the device specific settings to whitelist mindful.
  Future<bool> openAutoStartSettings() async =>
      await _methodChannel.invokeMethod('openAutoStartSettings');

  /// Opens an app with the specified package name.
  Future<bool> openAppWithPackage(String appPackage) async =>
      await _methodChannel.invokeMethod('openAppWithPackage', appPackage);

  /// Opens an app with notification thread.
  Future<bool> openAppWithNotificationThread(Notification notification) async =>
      await _methodChannel.invokeMethod(
        'openAppWithNotificationThread',
        jsonEncode(notification),
      );

  /// Opens the app settings for the specified app package.
  Future<bool> openAppSettingsForPackage(String appPackage) async =>
      await _methodChannel.invokeMethod(
        'openAppSettingsForPackage',
        appPackage,
      );

  // ===========================================================================================
  // ==================================== UTILS ================================================
  // ===========================================================================================

  /// Pop animates and close the app
  Future<bool> restartApp() async =>
      await _methodChannel.invokeMethod('restartApp');

  /// Parses the host name from a given URL string.
  ///
  /// This method sends the URL to the native side and retrieves the parsed host name.
  Future<String> parseHostFromUrl(String url) async =>
      await _methodChannel.invokeMethod('parseHostFromUrl', url);

  /// Launches a specified URL in the user's preferred web browser.
  ///
  /// This method takes the URL string and sends it to the native side for launching in the browser.
  Future<bool> launchUrl(String siteUrl) async =>
      await _methodChannel.invokeMethod('launchUrl', siteUrl);

  /// Prompts the user to add Quick Focus Tile to the status bar
  Future<bool> promptForQuickTile() async =>
      await _methodChannel.invokeMethod('promptForQuickTile');
}
BIGFEAT_EOF
echo "  wrote lib/core/services/method_channel_service.dart"
mkdir -p "lib/providers/restrictions"
cat > "lib/providers/restrictions/vpn_website_filter_provider.dart" << 'BIGFEAT_EOF'
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
import 'package:mindful/core/services/method_channel_service.dart';
import 'package:mindful/providers/restrictions/imported_hosts_lists_provider.dart';
import 'package:mindful/providers/restrictions/wellbeing_provider.dart';
import 'package:path_provider/path_provider.dart';

/// Whether the system-wide VPN DNS website filter is turned on. This is
/// a separate, simpler alternative/complement to the existing
/// accessibility-service based website blocking: instead of watching
/// browser tabs, it filters DNS lookups against the same blocklist
/// (manually-added sites + enabled imported hosts-list categories) for
/// every app on the device while the VPN tunnel is active.
///
/// NOTE: this is mutually exclusive with the per-app "Internet Blocker"
/// VPN feature, since Android only allows one active VPN tunnel at a
/// time. Enabling this takes over the tunnel from that feature.
final vpnWebsiteFilterProvider =
    StateNotifierProvider<VpnWebsiteFilterNotifier, bool>(
  (ref) => VpnWebsiteFilterNotifier(ref),
);

class VpnWebsiteFilterNotifier extends StateNotifier<bool> {
  final Ref _ref;
  bool _loaded = false;

  VpnWebsiteFilterNotifier(this._ref) : super(false) {
    _init();
  }

  Future<File> _storageFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/vpn_website_filter_enabled.json');
  }

  Future<void> _init() async {
    try {
      final file = await _storageFile();
      if (await file.exists()) {
        final raw = await file.readAsString();
        state = (jsonDecode(raw) as Map<String, dynamic>)['enabled'] == true;
      }
    } catch (_) {
      state = false;
    }
    _loaded = true;

    /// Keep the native filter's domain list in sync whenever the
    /// underlying blocklists change, so toggling categories/sites while
    /// the VPN filter is on takes effect immediately.
    _ref.listen(wellBeingProvider, (_, __) => _pushToNative());
    _ref.listen(importedHostsListsProvider, (_, __) => _pushToNative());

    await _pushToNative();
  }

  Future<void> _persist() async {
    if (!_loaded) return;
    try {
      final file = await _storageFile();
      await file.writeAsString(jsonEncode({'enabled': state}));
    } catch (_) {
      /// Best-effort persistence; ignore write failures.
    }
  }

  Set<String> _collectAllBlockedDomains() {
    final wellbeing = _ref.read(wellBeingProvider);
    final categories = _ref.read(importedHostsListsProvider);

    final domains = <String>{
      ...wellbeing.blockedWebsites,
      ...wellbeing.nsfwWebsites,
    };

    for (final category in categories) {
      if (category.enabled) domains.addAll(category.domains);
    }

    return domains;
  }

  Future<void> _pushToNative() async {
    final domains = state ? _collectAllBlockedDomains() : <String>{};
    await MethodChannelService.instance.updateDnsWebsiteFilter(
      enabled: state,
      domains: domains.toList(),
    );
  }

  /// Toggles the VPN website filter on/off.
  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await _persist();
    await _pushToNative();
  }
}
BIGFEAT_EOF
echo "  wrote lib/providers/restrictions/vpn_website_filter_provider.dart"
mkdir -p "lib/ui/screens/websites_blocking"
cat > "lib/ui/screens/websites_blocking/vpn_website_filter_tile.dart" << 'BIGFEAT_EOF'
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
BIGFEAT_EOF
echo "  wrote lib/ui/screens/websites_blocking/vpn_website_filter_tile.dart"
mkdir -p "lib/ui/screens/websites_blocking"
cat > "lib/ui/screens/websites_blocking/websites_blocking_screen.dart" << 'BIGFEAT_EOF'
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
import 'package:mindful/config/hero_tags.dart';
import 'package:mindful/core/extensions/ext_build_context.dart';
import 'package:mindful/core/extensions/ext_widget.dart';
import 'package:mindful/providers/restrictions/wellbeing_provider.dart';
import 'package:mindful/providers/system/permissions_provider.dart';
import 'package:mindful/ui/common/content_section_header.dart';
import 'package:mindful/ui/common/default_list_tile.dart';
import 'package:mindful/ui/common/scaffold_shell.dart';
import 'package:mindful/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:mindful/ui/common/styled_text.dart';
import 'package:mindful/ui/dialogs/confirmation_dialog.dart';
import 'package:mindful/ui/permissions/accessibility_permission_card.dart';
import 'package:mindful/ui/screens/websites_blocking/add_websites_fab.dart';
import 'package:mindful/ui/screens/websites_blocking/import_hosts_tile.dart';
import 'package:mindful/ui/screens/websites_blocking/sliver_blocked_websites_list.dart';
import 'package:mindful/ui/screens/websites_blocking/sliver_imported_hosts_categories.dart';
import 'package:mindful/ui/screens/websites_blocking/vpn_website_filter_tile.dart';
import 'package:mindful/ui/screens/websites_blocking/websites_search_field.dart';
import 'package:mindful/ui/transitions/default_hero.dart';

class WebsitesBlockingScreen extends ConsumerWidget {
  const WebsitesBlockingScreen({super.key});

  void _turnNsfwBlockerOn(BuildContext context, WidgetRef ref) async {
    final isConfirm = await showConfirmationDialog(
      context: context,
      icon: FluentIcons.video_prohibited_20_filled,
      heroTag: HeroTags.blockNsfwTileTag,
      title: context.locale.adult_content_heading,
      info: context.locale.block_nsfw_dialog_info,
      positiveLabel: context.locale.block_nsfw_dialog_button_block_anyway,
    );

    if (isConfirm) {
      ref.read(wellBeingProvider.notifier).switchBlockNsfwSites();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockNsfwSites =
        ref.watch(wellBeingProvider.select((v) => v.blockNsfwSites));

    final haveAccessibilityPermission = ref.watch(
      permissionProvider.select((v) => v.haveAccessibilityPermission),
    );

    return ScaffoldShell(items: [
      NavbarItem(
        icon: FluentIcons.arrow_flow_diagonal_up_right_12_filled,
        filledIcon: FluentIcons.arrow_flow_diagonal_up_right_12_filled,
        fab: const AddWebsitesFAB(),
        titleText: context.locale.websites_blocking_tab_title,
        sliverBody: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            /// Information about websites blocking
            StyledText(context.locale.websites_blocking_tab_info).sliver,

            /// Adult content header
            ContentSectionHeader(title: context.locale.adult_content_heading)
                .sliver,

            const AccessibilityPermissionCard(),

            /// Block NSFW websites
            DefaultHero(
              tag: HeroTags.blockNsfwTileTag,
              child: DefaultListTile(
                enabled: haveAccessibilityPermission && !blockNsfwSites,
                leadingIcon: FluentIcons.video_prohibited_20_regular,
                titleText: context.locale.block_nsfw_title,
                subtitleText: context.locale.block_nsfw_subtitle,
                switchValue: blockNsfwSites,
                onPressed: () => _turnNsfwBlockerOn(context, ref),
              ),
            ).sliver,

            /// Blocked websites header
            ContentSectionHeader(title: context.locale.blocked_websites_heading)
                .sliver,

            /// Import blocked websites from a hosts file (e.g. StevenBlack/hosts)
            if (haveAccessibilityPermission)
              const ImportHostsFileTile().sliver,

            /// System-wide VPN DNS website filter toggle - does not
            /// require accessibility permission, works independently
            const VpnWebsiteFilterTile().sliver,

            /// Search field - searches manual sites plus domains inside
            /// any currently enabled imported category
            const WebsitesSearchField().sliver,

            /// One toggle tile per imported hosts-list category
            /// (e.g. Ads, Porn, Gambling) instead of every domain
            const SliverImportedHostsCategories(),

            /// Manually added individual websites
            const SliverBlockedWebsitesList(),

            const SliverTabsBottomPadding(),
          ],
        ),
      )
    ]);
  }
}
BIGFEAT_EOF
echo "  wrote lib/ui/screens/websites_blocking/websites_blocking_screen.dart"
mkdir -p "android/app/src/main/java/com/peace/mind/services/vpn"
cat > "android/app/src/main/java/com/peace/mind/services/vpn/DnsFilterEngine.kt" << 'BIGFEAT_EOF'
/*
 *
 *  *
 *  *  * Copyright (c) 2024 Mindful (https://github.com/akaMrNagar/Mindful)
 *  *  * Author : Pawan Nagar (https://github.com/akaMrNagar)
 *  *  *
 *  *  * This source code is licensed under the GPL-2.0 license license found in the
 *  *  * LICENSE file in the root directory of this source tree.
 *  *
 *
 */
package com.peace.mind.services.vpn

import android.net.VpnService
import android.os.ParcelFileDescriptor
import android.util.Log
import java.io.FileInputStream
import java.io.FileOutputStream
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress
import java.nio.ByteBuffer
import java.util.concurrent.atomic.AtomicBoolean

/**
 * A minimal, safety-scoped DNS filtering engine used by [MindfulVpnService]
 * when "VPN website filter" is enabled.
 *
 * Design notes (important - read before modifying):
 * - This engine ONLY intercepts DNS (UDP port 53) traffic. It does NOT do
 *   general IP packet forwarding. The VPN [android.net.VpnService.Builder]
 *   is configured to route just a single virtual DNS-server address
 *   through the tunnel (see [VIRTUAL_DNS_ADDRESS]), while all other
 *   traffic (actual web/app content) bypasses the VPN entirely and goes
 *   directly over the device's normal network connection.
 * - This drastically limits the "blast radius" of any bug here: at worst,
 *   DNS resolution for a single query might fail (apps handle that
 *   gracefully as a normal DNS error), rather than risking the device's
 *   overall internet connectivity like a full packet-forwarding VPN would.
 * - Because this filters at the DNS level system-wide (there is no
 *   reliable, safe way to attribute a raw IP packet to a specific app
 *   without significant additional OS-level plumbing), this filter
 *   applies to ALL apps on the device while active, not just specific
 *   ones. It is intentionally a separate, simpler feature from the
 *   existing per-app "Internet Blocker" (which fully cuts off internet
 *   for specific apps) - the two are mutually exclusive since Android
 *   only allows one active VPN tunnel at a time.
 */
class DnsFilterEngine(
    private val vpnService: VpnService,
    private val upstreamDnsHost: String = "1.1.1.1",
) {
    companion object {
        private const val TAG = "Mindful.DnsFilterEngine"
        const val VIRTUAL_DNS_ADDRESS = "10.111.222.1"
        private const val DNS_PORT = 53
        private const val UPSTREAM_TIMEOUT_MS = 4000
        private const val MAX_PACKET_SIZE = 32767
    }

    @Volatile
    var blockedDomains: Set<String> = emptySet()

    private val isRunning = AtomicBoolean(false)
    private var readerThread: Thread? = null

    /** Starts the DNS-filter read loop against the given VPN tunnel fd. */
    fun start(vpnInterface: ParcelFileDescriptor) {
        if (isRunning.getAndSet(true)) return

        val thread = Thread({
            runReadLoop(vpnInterface)
        }, TAG)
        readerThread = thread
        thread.start()
    }

    fun stop() {
        isRunning.set(false)
        readerThread?.interrupt()
        readerThread = null
    }

    private fun isDomainBlocked(domain: String): Boolean {
        val lower = domain.lowercase().trimEnd('.')
        if (blockedDomains.contains(lower)) return true

        /// Also match subdomains of a blocked domain, e.g. blocking
        /// "example.com" should also block "m.example.com".
        var idx = lower.indexOf('.')
        while (idx != -1) {
            val parent = lower.substring(idx + 1)
            if (blockedDomains.contains(parent)) return true
            idx = lower.indexOf('.', idx + 1)
        }
        return false
    }

    private fun runReadLoop(vpnInterface: ParcelFileDescriptor) {
        val input = FileInputStream(vpnInterface.fileDescriptor)
        val output = FileOutputStream(vpnInterface.fileDescriptor)
        val buffer = ByteArray(MAX_PACKET_SIZE)

        Log.d(TAG, "runReadLoop: DNS filter engine started")

        while (isRunning.get() && !Thread.currentThread().isInterrupted) {
            try {
                val length = input.read(buffer)
                if (length <= 0) continue

                val packet = ByteBuffer.wrap(buffer, 0, length)
                handleIpPacket(packet, length, output)
            } catch (e: Exception) {
                if (isRunning.get()) {
                    Log.w(TAG, "runReadLoop: error processing packet", e)
                }
                /// Keep looping - a single malformed/unexpected packet
                /// should never take down the whole filter.
            }
        }

        Log.d(TAG, "runReadLoop: DNS filter engine stopped")
    }

    /** Parses a raw IPv4 packet and, if it's a UDP/53 DNS query destined
     * for our virtual DNS address, handles it; otherwise the packet is
     * ignored (nothing else should reach this tunnel given the narrow
     * route we configure). */
    private fun handleIpPacket(packet: ByteBuffer, length: Int, output: FileOutputStream) {
        if (length < 20) return // shorter than a minimal IPv4 header

        val versionAndIhl = packet.get(0).toInt() and 0xFF
        val version = versionAndIhl shr 4
        if (version != 4) return // only IPv4 supported by this minimal engine

        val ihl = (versionAndIhl and 0x0F) * 4
        if (ihl < 20 || length < ihl + 8) return

        val protocol = packet.get(9).toInt() and 0xFF
        if (protocol != 17) return // not UDP

        val udpStart = ihl
        val srcPort = ((packet.get(udpStart).toInt() and 0xFF) shl 8) or
                (packet.get(udpStart + 1).toInt() and 0xFF)
        val dstPort = ((packet.get(udpStart + 2).toInt() and 0xFF) shl 8) or
                (packet.get(udpStart + 3).toInt() and 0xFF)

        if (dstPort != DNS_PORT) return

        val udpLength = ((packet.get(udpStart + 4).toInt() and 0xFF) shl 8) or
                (packet.get(udpStart + 5).toInt() and 0xFF)
        val dnsStart = udpStart + 8
        val dnsLength = udpLength - 8
        if (dnsLength <= 0 || dnsStart + dnsLength > length) return

        val dnsQuery = ByteArray(dnsLength)
        packet.position(dnsStart)
        packet.get(dnsQuery)

        val queriedDomain = parseDnsQuestionName(dnsQuery) ?: return

        /// Extract source IP (the tun-side address of whoever sent this
        /// query) so we can address our response back to them.
        val srcIpBytes = ByteArray(4)
        packet.position(12)
        packet.get(srcIpBytes)
        val srcIp = InetAddress.getByAddress(srcIpBytes)

        if (isDomainBlocked(queriedDomain)) {
            val response = buildBlockedDnsResponse(dnsQuery)
            writeUdpResponsePacket(
                output, srcIp, srcPort, response,
            )
        } else {
            forwardToUpstream(dnsQuery) { response ->
                if (response != null) {
                    writeUdpResponsePacket(output, srcIp, srcPort, response)
                }
            }
        }
    }

    /** Minimal DNS question-name parser: reads the QNAME of the first
     * question in a DNS query message (labels prefixed by length byte,
     * terminated by a zero-length label). Returns null if the message is
     * too short/malformed to safely parse. */
    private fun parseDnsQuestionName(dns: ByteArray): String? {
        if (dns.size < 12) return null // DNS header is 12 bytes
        val qdCount = ((dns[4].toInt() and 0xFF) shl 8) or (dns[5].toInt() and 0xFF)
        if (qdCount < 1) return null

        val sb = StringBuilder()
        var pos = 12
        while (pos < dns.size) {
            val labelLen = dns[pos].toInt() and 0xFF
            if (labelLen == 0) break
            pos += 1
            if (pos + labelLen > dns.size) return null
            if (sb.isNotEmpty()) sb.append('.')
            sb.append(String(dns, pos, labelLen, Charsets.US_ASCII))
            pos += labelLen
        }
        return if (sb.isEmpty()) null else sb.toString()
    }

    /** Builds a synthetic NXDOMAIN DNS response for a blocked query,
     * preserving the original transaction ID and question section so
     * the requesting app accepts it as a valid (if empty) answer. */
    private fun buildBlockedDnsResponse(query: ByteArray): ByteArray {
        val response = query.copyOf()

        /// Flags: QR=1 (response), Opcode from query, RD copied, RA=0,
        /// RCODE=3 (NXDOMAIN)
        response[2] = (0x81).toByte() // QR=1, Opcode=0, AA=0, TC=0, RD=1
        response[3] = (0x83).toByte() // RA=0, Z=0, RCODE=3 (NXDOMAIN)

        /// Zero out answer/authority/additional counts - we return no
        /// records, just an authoritative "not found".
        response[6] = 0; response[7] = 0
        response[8] = 0; response[9] = 0
        response[10] = 0; response[11] = 0

        return response
    }

    /** Forwards an allowed DNS query to a real upstream resolver over a
     * VPN-protected UDP socket (so the forwarding socket itself doesn't
     * get routed back into our own tunnel), then invokes [onResult] with
     * the raw response bytes, or null on failure/timeout. */
    private fun forwardToUpstream(query: ByteArray, onResult: (ByteArray?) -> Unit) {
        var socket: DatagramSocket? = null
        try {
            socket = DatagramSocket()
            vpnService.protect(socket)
            socket.soTimeout = UPSTREAM_TIMEOUT_MS

            val upstreamAddr = InetAddress.getByName(upstreamDnsHost)
            val outPacket = DatagramPacket(query, query.size, upstreamAddr, DNS_PORT)
            socket.send(outPacket)

            val responseBuffer = ByteArray(MAX_PACKET_SIZE)
            val inPacket = DatagramPacket(responseBuffer, responseBuffer.size)
            socket.receive(inPacket)

            onResult(inPacket.data.copyOf(inPacket.length))
        } catch (e: Exception) {
            Log.w(TAG, "forwardToUpstream: failed to resolve via upstream", e)
            onResult(null)
        } finally {
            socket?.close()
        }
    }

    /** Wraps a raw DNS response into an IPv4/UDP packet addressed back to
     * the original querying app (via the tun interface's virtual address
     * space) and writes it to the tun fd. */
    private fun writeUdpResponsePacket(
        output: FileOutputStream,
        destIp: InetAddress,
        destPort: Int,
        dnsPayload: ByteArray,
    ) {
        try {
            val udpLength = 8 + dnsPayload.size
            val totalLength = 20 + udpLength
            val packet = ByteBuffer.allocate(totalLength)

            /// --- IPv4 header ---
            packet.put(0x45.toByte()) // version=4, IHL=5 (20 bytes, no options)
            packet.put(0x00.toByte()) // DSCP/ECN
            packet.putShort(totalLength.toShort())
            packet.putShort(0) // identification
            packet.putShort(0x4000.toShort()) // flags=DF, fragment offset=0
            packet.put(64.toByte()) // TTL
            packet.put(17.toByte()) // protocol = UDP
            packet.putShort(0) // checksum placeholder, filled below

            val srcIpBytes = InetAddress.getByName(VIRTUAL_DNS_ADDRESS).address
            packet.put(srcIpBytes)
            packet.put(destIp.address)

            /// --- UDP header ---
            packet.putShort(DNS_PORT.toShort())
            packet.putShort(destPort.toShort())
            packet.putShort(udpLength.toShort())
            packet.putShort(0) // UDP checksum - 0 is valid (optional over IPv4)

            /// --- DNS payload ---
            packet.put(dnsPayload)

            /// Fill in IPv4 header checksum (bytes 10-11)
            val ipChecksum = computeIpChecksum(packet.array(), 0, 20)
            packet.putShort(10, ipChecksum.toShort())

            output.write(packet.array(), 0, totalLength)
        } catch (e: Exception) {
            Log.w(TAG, "writeUdpResponsePacket: failed to write response", e)
        }
    }

    private fun computeIpChecksum(data: ByteArray, offset: Int, length: Int): Int {
        var sum = 0
        var i = offset
        while (i < offset + length) {
            val word = ((data[i].toInt() and 0xFF) shl 8) or
                    (if (i + 1 < offset + length) (data[i + 1].toInt() and 0xFF) else 0)
            sum += word
            i += 2
        }
        while (sum shr 16 != 0) {
            sum = (sum and 0xFFFF) + (sum shr 16)
        }
        return sum.inv() and 0xFFFF
    }
}
BIGFEAT_EOF
echo "  wrote android/app/src/main/java/com/peace/mind/services/vpn/DnsFilterEngine.kt"
mkdir -p "android/app/src/main/java/com/peace/mind/services/vpn"
cat > "android/app/src/main/java/com/peace/mind/services/vpn/MindfulVpnService.kt" << 'BIGFEAT_EOF'
/*
 *
 *  *
 *  *  * Copyright (c) 2024 Mindful (https://github.com/akaMrNagar/Mindful)
 *  *  * Author : Pawan Nagar (https://github.com/akaMrNagar)
 *  *  *
 *  *  * This source code is licensed under the GPL-2.0 license license found in the
 *  *  * LICENSE file in the root directory of this source tree.
 *  *
 *
 */
package com.peace.mind.services.vpn

import android.content.Intent
import android.content.pm.PackageManager
import android.net.VpnService
import android.os.IBinder
import android.os.ParcelFileDescriptor
import android.util.Log
import com.peace.mind.AppConstants
import com.peace.mind.R
import com.peace.mind.generics.ServiceBinder
import com.peace.mind.helpers.device.NotificationHelper
import com.peace.mind.helpers.storage.SharedPrefsHelper
import java.io.IOException
import java.net.InetSocketAddress
import java.net.SocketAddress
import java.net.SocketException
import java.nio.channels.DatagramChannel
import java.util.concurrent.atomic.AtomicReference


/**
 * A VPN service with two independent, mutually-exclusive modes:
 *
 * 1. **Internet Blocker** (default, unchanged from earlier versions):
 *    fully blocks internet access for a specific set of apps by routing
 *    only their traffic into a tunnel that never forwards anything.
 *
 * 2. **VPN website filter**: filters DNS (website) lookups system-wide
 *    against a domain blocklist, via [DnsFilterEngine]. See that class
 *    for the safety rationale behind why this only touches DNS traffic.
 *
 * Because Android only allows a single active [VpnService] tunnel at a
 * time, only one of these two modes can be active at once. If the DNS
 * website filter is enabled, it takes priority over the per-app
 * internet blocker while both are configured.
 */
class MindfulVpnService : VpnService() {
    companion object {
        private const val TAG = "Mindful.VpnService"
    }

    private val mBinder = ServiceBinder(this@MindfulVpnService)
    private val mAtomicVpnThread = AtomicReference<Thread?>(null)
    private var mBlockedApps: Set<String> = HashSet(0)
    private var mBlockedDomains: Set<String> = HashSet(0)
    private var mDnsFilterEnabled: Boolean = false
    private var mVpnInterface: ParcelFileDescriptor? = null
    private var mIsServiceRunning = false
    private var mDnsFilterEngine: DnsFilterEngine? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {

        if (intent?.action == ServiceBinder.ACTION_START_MINDFUL_SERVICE) {
            startFgService()
            return START_STICKY
        }

        stopAndDisposeService()
        return START_NOT_STICKY
    }


    private fun startFgService() {
        if (mIsServiceRunning) return
        try {
            startForeground(
                AppConstants.VPN_SERVICE_NOTIFICATION_ID,
                NotificationHelper.buildFgServiceNotification(
                    this,
                    getString(R.string.internet_blocker_running_notification_info)
                )
            )
            mIsServiceRunning = true
            Log.d(TAG, "startFgService: VPN service started successfully")
        } catch (e: Exception) {
            Log.e(TAG, "startFgService: Failed to start VPN service", e)
            SharedPrefsHelper.insertCrashLogToPrefs(this, e)
            stopAndDisposeService()
        }
    }

    /**
     * Restarts the VPN connection by disconnecting and then reconnecting the VPN.
     */
    private fun reconnectVpn() {
        disconnectVpn()
        connectVpn()
        Log.d(TAG, "reconnectVpn: VPN reconnected successfully")
    }

    /**
     * Establishes a VPN connection based on the active mode (DNS website
     * filter takes priority if enabled, otherwise per-app internet
     * blocking). If neither has anything configured, the service stops.
     */
    private fun connectVpn() {
        if (!mDnsFilterEnabled && mBlockedApps.isEmpty()) {
            Log.w(TAG, "connectVpn: Nothing to do (no blocked apps, DNS filter off), Exiting")
            stopAndDisposeService()
            return
        }

        val newThread = Thread(vpnThread, TAG)
        setVpnThread(newThread)
        newThread.start()
    }

    /**
     * Disconnects the VPN connection if established.
     */
    private fun disconnectVpn() {
        try {
            mDnsFilterEngine?.stop()
            mDnsFilterEngine = null

            if (mVpnInterface != null) {
                mVpnInterface!!.close()
                mVpnInterface = null
                setVpnThread(null)
                Log.d(TAG, "disconnectVpn: VPN disconnected successfully")
            }
        } catch (e: IOException) {
            Log.e(TAG, "disconnectVpn: Failed to disconnect VPN", e)
        }
    }

    /**
     * Stops the foreground service and disconnects the VPN.
     */
    private fun stopAndDisposeService() {
        disconnectVpn()
        stopSelf()
    }

    /**
     * Returns a Runnable that configures and establishes the VPN connection
     * for whichever mode is currently active.
     */
    private val vpnThread: Runnable
        get() = Runnable {
            if (mDnsFilterEnabled) {
                connectDnsFilterVpn()
            } else {
                connectAppBlockerVpn()
            }
        }

    /**
     * Mode 1: per-app internet blocker (original behavior, unchanged).
     * Routes only the blocked apps' traffic into a tunnel that never
     * forwards any packets, effectively cutting off their internet.
     */
    private fun connectAppBlockerVpn() {
        try {
            DatagramChannel.open().use { tunnel ->
                check(this@MindfulVpnService.protect(tunnel.socket())) { "Cannot protect the vpn socket tunnel" }
                val serverAddress: SocketAddress = InetSocketAddress("localhost", 0)
                tunnel.connect(serverAddress)
                tunnel.configureBlocking(false)

                val builder = this@MindfulVpnService.Builder()
                builder.addAddress("192.168.0.0", 24)
                builder.addRoute("0.0.0.0", 0)

                // Add blocked app's packages
                for (packageName in mBlockedApps) {
                    try {
                        builder.addAllowedApplication(packageName)
                    } catch (e: PackageManager.NameNotFoundException) {
                        Log.w(TAG, "connectAppBlockerVpn: Cannot find app with package $packageName")
                    }
                }
                synchronized(this@MindfulVpnService) {
                    mVpnInterface = builder.establish()
                    Log.d(TAG, "connectAppBlockerVpn: VPN connected successfully")
                }
            }
        } catch (e: SocketException) {
            Log.e(TAG, "connectAppBlockerVpn: Cannot use socket for VPN", e)
            SharedPrefsHelper.insertCrashLogToPrefs(this@MindfulVpnService, e)
            stopAndDisposeService()
        } catch (e: IOException) {
            Log.e(TAG, "connectAppBlockerVpn: VPN connection failed, exiting", e)
            SharedPrefsHelper.insertCrashLogToPrefs(this@MindfulVpnService, e)
            stopAndDisposeService()
        } catch (e: IllegalArgumentException) {
            Log.e(TAG, "connectAppBlockerVpn: VPN connection failed, exiting", e)
            SharedPrefsHelper.insertCrashLogToPrefs(this@MindfulVpnService, e)
            stopAndDisposeService()
        } catch (e: Exception) {
            Log.e(TAG, "connectAppBlockerVpn: Something went wrong", e)
            SharedPrefsHelper.insertCrashLogToPrefs(this@MindfulVpnService, e)
            stopAndDisposeService()
        }
    }

    /**
     * Mode 2: system-wide DNS website filter. Routes ONLY a single
     * virtual DNS-server address through the tunnel (see
     * [DnsFilterEngine.VIRTUAL_DNS_ADDRESS]) - all other traffic bypasses
     * the VPN entirely. See [DnsFilterEngine] for full rationale.
     */
    private fun connectDnsFilterVpn() {
        try {
            val builder = this@MindfulVpnService.Builder()
            builder.addAddress(DnsFilterEngine.VIRTUAL_DNS_ADDRESS, 32)
            builder.addDnsServer(DnsFilterEngine.VIRTUAL_DNS_ADDRESS)
            builder.addRoute(DnsFilterEngine.VIRTUAL_DNS_ADDRESS, 32)

            synchronized(this@MindfulVpnService) {
                val vpnInterface = builder.establish()
                if (vpnInterface == null) {
                    Log.e(TAG, "connectDnsFilterVpn: Failed to establish VPN interface")
                    stopAndDisposeService()
                    return
                }

                mVpnInterface = vpnInterface
                val engine = DnsFilterEngine(this@MindfulVpnService)
                engine.blockedDomains = mBlockedDomains
                mDnsFilterEngine = engine
                engine.start(vpnInterface)

                Log.d(TAG, "connectDnsFilterVpn: DNS website filter VPN connected successfully")
            }
        } catch (e: IOException) {
            Log.e(TAG, "connectDnsFilterVpn: VPN connection failed, exiting", e)
            SharedPrefsHelper.insertCrashLogToPrefs(this@MindfulVpnService, e)
            stopAndDisposeService()
        } catch (e: IllegalArgumentException) {
            Log.e(TAG, "connectDnsFilterVpn: VPN connection failed, exiting", e)
            SharedPrefsHelper.insertCrashLogToPrefs(this@MindfulVpnService, e)
            stopAndDisposeService()
        } catch (e: Exception) {
            Log.e(TAG, "connectDnsFilterVpn: Something went wrong", e)
            SharedPrefsHelper.insertCrashLogToPrefs(this@MindfulVpnService, e)
            stopAndDisposeService()
        }
    }

    /**
     * Sets the current VPN thread, interrupting the previous thread if necessary.
     *
     * @param thread The new thread to be set.
     */
    private fun setVpnThread(thread: Thread?) {
        val oldThread = mAtomicVpnThread.getAndSet(thread)
        oldThread?.interrupt()
    }

    /**
     * Updates the list of blocked apps and restarts the VPN service if needed.
     * Has no effect while the DNS website filter mode is active - the two
     * modes are mutually exclusive since only one VPN tunnel can run at once.
     */
    fun updateBlockedApps(blockedApps: Set<String>) {
        mBlockedApps = blockedApps
        Log.d(TAG, "updateBlockedApps: Internet blocked apps updated successfully")
        if (mDnsFilterEnabled) return
        if (mBlockedApps.isEmpty()) stopAndDisposeService()
        else reconnectVpn()
    }

    /**
     * Enables or disables the system-wide DNS website filter and/or
     * updates its domain blocklist. When enabling with a non-empty
     * domain set, this takes over the VPN tunnel from the per-app
     * internet blocker (if that was active). When disabling, control
     * reverts to whatever the per-app blocker's current configuration is.
     */
    fun updateDnsWebsiteFilter(enabled: Boolean, blockedDomains: Set<String>) {
        mBlockedDomains = blockedDomains
        mDnsFilterEnabled = enabled && blockedDomains.isNotEmpty()

        Log.d(TAG, "updateDnsWebsiteFilter: enabled=$mDnsFilterEnabled, domains=${blockedDomains.size}")

        if (mDnsFilterEnabled) {
            reconnectVpn()
        } else {
            /// Fall back to app-blocker mode (or stop entirely if that
            /// has nothing configured either).
            if (mBlockedApps.isEmpty()) {
                stopAndDisposeService()
            } else {
                reconnectVpn()
            }
        }

        /// If already running in DNS filter mode, push the updated
        /// domain set to the live engine without a full reconnect.
        mDnsFilterEngine?.blockedDomains = mBlockedDomains
    }

    override fun onDestroy() {
        disconnectVpn()
        stopForeground(STOP_FOREGROUND_REMOVE)
        Log.d(TAG, "onDestroy: VPN service destroyed successfully")
        super.onDestroy()
    }

    override fun onBind(intent: Intent): IBinder? {
        return if (intent.action == ServiceBinder.ACTION_BIND_TO_MINDFUL) mBinder else null
    }
}
BIGFEAT_EOF
echo "  wrote android/app/src/main/java/com/peace/mind/services/vpn/MindfulVpnService.kt"
mkdir -p "android/app/src/main/java/com/peace/mind"
cat > "android/app/src/main/java/com/peace/mind/FgMethodCallHandler.kt" << 'BIGFEAT_EOF'
package com.peace.mind

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.net.VpnService
import androidx.activity.result.ActivityResultLauncher
import com.peace.mind.enums.DndWakeLock
import com.peace.mind.generics.SafeServiceConnection
import com.peace.mind.generics.ServiceBinder
import com.peace.mind.helpers.AlarmTasksSchedulingHelper.cancelBedtimeRoutineTasks
import com.peace.mind.helpers.AlarmTasksSchedulingHelper.cancelNotificationBatchTask
import com.peace.mind.helpers.AlarmTasksSchedulingHelper.scheduleBedtimeRoutineTasks
import com.peace.mind.helpers.AlarmTasksSchedulingHelper.scheduleNotificationBatchTask
import com.peace.mind.helpers.device.DeviceAppsHelper.getDeviceAppInfos
import com.peace.mind.helpers.device.NewActivitiesLaunchHelper
import com.peace.mind.helpers.device.NotificationHelper
import com.peace.mind.helpers.device.PermissionsHelper
import com.peace.mind.helpers.storage.SharedPrefsHelper
import com.peace.mind.helpers.usages.AppsUsageHelper.getAppsUsageForInterval
import com.peace.mind.models.AppRestriction
import com.peace.mind.models.BedtimeSchedule
import com.peace.mind.models.FocusSession
import com.peace.mind.models.Notification
import com.peace.mind.models.NotificationSettings
import com.peace.mind.models.RestrictionGroup
import com.peace.mind.services.notification.MindfulNotificationListenerService
import com.peace.mind.services.timer.EmergencyPauseService
import com.peace.mind.services.timer.FocusSessionService
import com.peace.mind.services.tracking.MindfulTrackerService
import com.peace.mind.services.vpn.MindfulVpnService
import com.peace.mind.utils.AppUtils
import com.peace.mind.utils.JsonUtils
import com.peace.mind.utils.Utils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.util.Locale

class FgMethodCallHandler(
    private val context: Context,
    private val activity: Activity? = null,
    private val vpnPermLauncher: ActivityResultLauncher<Intent>? = null,
) : MethodCallHandler {

    private val focusServiceConn =
        SafeServiceConnection(
            context = context,
            serviceClass = FocusSessionService::class.java
        )

    private val trackerServiceConn =
        SafeServiceConnection(
            context = context,
            serviceClass = MindfulTrackerService::class.java
        )

    private val vpnServiceConn =
        SafeServiceConnection(
            context = context,
            serviceClass = MindfulVpnService::class.java
        )

    private val notificationServiceConn =
        SafeServiceConnection(
            context = context,
            serviceClass = MindfulNotificationListenerService::class.java
        )


    init {
        // Bind to Services if they are already running
        trackerServiceConn.bindService()
        vpnServiceConn.bindService()
        notificationServiceConn.bindService()
        focusServiceConn.bindService()
    }


    fun dispose() {
        // Unbind all services
        trackerServiceConn.unBindService()
        vpnServiceConn.unBindService()
        notificationServiceConn.unBindService()
        focusServiceConn.unBindService()
    }

    private fun updateLocale(languageCode: String) {
        if (languageCode.isNotEmpty()) {
            val newLocale = Locale(languageCode)
            Locale.setDefault(newLocale)
            val config = Configuration()
            config.setLocale(newLocale)
            context.resources.updateConfiguration(config, context.resources.displayMetrics)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            // ==============================================================================================================
            // ====================================== SYSTEM =================================================================
            // ==============================================================================================================

            "updateLocale" -> {
                updateLocale(call.arguments() ?: "en")
                result.success(true)
            }

            "updateExcludedApps" -> {
                SharedPrefsHelper.getSetExcludedApps(context, call.arguments() ?: "")
                result.success(true)
            }

            "getDeviceInfo" -> {
                result.success(AppUtils.getDeviceInfoMap(context))
            }

            "getDeviceAppsInfo" -> {
                getDeviceAppInfos(
                    context = context,
                    onSuccess = { data -> result.success(data) }
                )
            }

            "getAppsUsageForInterval" -> {
                getAppsUsageForInterval(
                    context = context,
                    startMsEpoch = call.argument("startDateTime"),
                    endMsEpoch = call.argument("endDateTime"),
                    onSuccess = { data -> result.success(data) }
                )
            }

            "getAppsLaunchCount" -> {
                result.success(
                    trackerServiceConn.service?.getRestrictionManager?.getAppsLaunchCount
                        ?: mapOf<String, Int>()
                )
            }

            "getShortsScreenTimeMs" -> {
                result.success(SharedPrefsHelper.getSetShortsScreenTimeMs(context, null))
            }

            "getNativeCrashLogs" -> {
                result.success(SharedPrefsHelper.getCrashLogsArrayJsonString(context))
            }

            "clearNativeCrashLogs" -> {
                SharedPrefsHelper.clearCrashLogs(context)
                result.success(true)
            }

            // ==============================================================================================================
            // ====================================== SERVICES =================================================================
            // ==============================================================================================================

            "updateAppRestrictions" -> {
                val appRestrictions = JsonUtils.parseAppRestrictionsMap(
                    call.arguments() ?: ""
                )
                updateTrackerServiceRestrictions(appRestrictions, null)
                result.success(true)
            }

            "updateRestrictionsGroups" -> {
                val restrictionGroups = JsonUtils.parseRestrictionGroupsMap(
                    call.arguments() ?: ""
                )
                updateTrackerServiceRestrictions(null, restrictionGroups)
                result.success(true)
            }

            "updateInternetBlockedApps" -> {
                val blockedApps =
                    JsonUtils.parseStringSet(call.arguments() ?: "")
                if (vpnServiceConn.isActive) {
                    vpnServiceConn.service?.updateBlockedApps(blockedApps)
                } else if (blockedApps.isNotEmpty() && getAndAskVpnPermission(false)) {
                    vpnServiceConn.setOnConnectedCallback { service ->
                        service.updateBlockedApps(
                            blockedApps
                        )
                    }
                    vpnServiceConn.startAndBind()
                }
                result.success(true)
            }

            "updateDnsWebsiteFilter" -> {
                val args = call.arguments<Map<String, Any?>>() ?: emptyMap()
                val enabled = args["enabled"] as? Boolean ?: false
                val domainsJson = args["domains"] as? String ?: "[]"
                val blockedDomains = JsonUtils.parseStringSet(domainsJson)

                if (vpnServiceConn.isActive) {
                    vpnServiceConn.service?.updateDnsWebsiteFilter(enabled, blockedDomains)
                } else if (enabled && blockedDomains.isNotEmpty() && getAndAskVpnPermission(false)) {
                    vpnServiceConn.setOnConnectedCallback { service ->
                        service.updateDnsWebsiteFilter(enabled, blockedDomains)
                    }
                    vpnServiceConn.startAndBind()
                }
                result.success(true)
            }

            "updateWellBeingSettings" -> {
                // NOTE: Only updating shared prefs because accessibility service have onSharedPrefsChange listener registered which will eventually reload needed data
                SharedPrefsHelper.getSetWellBeingSettings(
                    context,
                    call.arguments() ?: ""
                )
                result.success(true)
            }

            "updateBedtimeSchedule" -> {
                val jsonBedtimeSettings = call.arguments() ?: ""
                val bedtimeSettings = BedtimeSchedule.fromJson(jsonBedtimeSettings)
                if (bedtimeSettings.isScheduleOn) {
                    scheduleBedtimeRoutineTasks(context, jsonBedtimeSettings)
                } else {
                    cancelBedtimeRoutineTasks(context)
                    if (bedtimeSettings.shouldStartDnd) {
                        NotificationHelper.toggleDnd(context, DndWakeLock.BEDTIME_MODE, false)
                    }
                }
                result.success(true)
            }

            "activeEmergencyPause" -> {
                if (!Utils.isServiceRunning(context, EmergencyPauseService::class.java)
                    && Utils.isServiceRunning(context, MindfulTrackerService::class.java)
                ) {
                    context.startService(
                        Intent(context, EmergencyPauseService::class.java).setAction(
                            ServiceBinder.ACTION_START_MINDFUL_SERVICE
                        )
                    )
                    result.success(true)
                } else {
                    result.success(false)
                }
            }

            "updateFocusSession" -> {
                val focusSession = FocusSession.fromJson(call.arguments() ?: "")
                if (focusServiceConn.isActive) {
                    focusServiceConn.service?.updateFocusSession(focusSession)
                } else {
                    focusServiceConn.setOnConnectedCallback { service: FocusSessionService ->
                        service.startFocusSession(
                            focusSession
                        )
                    }
                    focusServiceConn.startAndBind()
                }
                result.success(true)
            }

            "giveUpOrFinishFocusSession" -> {
                if (focusServiceConn.isActive) {
                    focusServiceConn.service?.giveUpOrStopFocusSession(call.arguments() ?: false)
                    focusServiceConn.unBindService()
                }
                result.success(true)
            }

            "updateNotificationSettings" -> {
                val settingsJson = call.arguments() ?: ""
                val settings = NotificationSettings.fromJson(settingsJson)

                /// Update service
                if (notificationServiceConn.isActive) {
                    notificationServiceConn.service?.updateNotificationSettings(settings)
                } else if (settings.batchedApps.isNotEmpty() || settings.storeNonBatchedToo) {
                    notificationServiceConn.setOnConnectedCallback { service: MindfulNotificationListenerService ->
                        service.updateNotificationSettings(settings)
                    }
                    notificationServiceConn.bindService()
                }

                /// Schedule batches
                if (settings.schedules.isNotEmpty()) {
                    scheduleNotificationBatchTask(context, settingsJson)
                } else {
                    cancelNotificationBatchTask(context)
                }

                result.success(true)
            }

            // ==============================================================================================================
            // ===================================== PERMISSIONS ============================================================
            // ==============================================================================================================

            "getAndAskAccessibilityPermission" -> {
                result.success(
                    PermissionsHelper.getAndAskAccessibilityPermission(
                        context,
                        call.arguments() ?: false
                    )
                )
            }

            "getAndAskAdminPermission" -> {
                result.success(
                    PermissionsHelper.getAndAskAdminPermission(
                        context,
                        call.arguments() ?: false
                    )
                )
            }

            "getAndAskUsageAccessPermission" -> {
                result.success(
                    PermissionsHelper.getAndAskUsageAccessPermission(
                        context,
                        call.arguments() ?: false
                    )
                )
            }

            "getAndAskIgnoreBatteryOptimizationPermission" -> {
                result.success(
                    PermissionsHelper.getAndAskIgnoreBatteryOptimizationPermission(
                        context,
                        call.arguments() ?: false
                    )
                )
            }

            "getAndAskDisplayOverlayPermission" -> {
                result.success(
                    PermissionsHelper.getAndAskDisplayOverlayPermission(
                        context,
                        call.arguments() ?: false
                    )
                )
            }

            "getAndAskExactAlarmPermission" -> {
                result.success(
                    PermissionsHelper.getAndAskExactAlarmPermission(
                        context,
                        call.arguments() ?: false
                    )
                )
            }

            "getAndAskNotificationPermission" -> {
                result.success(
                    activity?.let {
                        return@let PermissionsHelper.getAndAskNotificationPermission(
                            it,
                            call.arguments() ?: false
                        )
                    } ?: false
                )
            }

            "getAndAskDndPermission" -> {
                result.success(
                    PermissionsHelper.getAndAskDndPermission(
                        context,
                        call.arguments() ?: false
                    )
                )
            }

            "getAndAskNotificationAccessPermission" -> {
                result.success(
                    PermissionsHelper.getAndAskNotificationAccessPermission(
                        context,
                        call.arguments() ?: false
                    )
                )
            }

            "getAndAskVpnPermission" -> {
                result.success(getAndAskVpnPermission(call.arguments() ?: false))
            }

            // ==============================================================================================================
            // ====================================== UTILS =================================================================
            // ==============================================================================================================

            "disableDeviceAdmin" -> {
                NewActivitiesLaunchHelper.disableDeviceAdmin(context)
                result.success(true)
            }

            "promptForQuickTile" -> {
                NewActivitiesLaunchHelper.promptForQuickFocusTile(context, result)
            }

            "openAppWithPackage" -> {
                NewActivitiesLaunchHelper.openAppWithPackage(
                    context,
                    call.arguments() ?: ""
                )
                result.success(true)
            }

            "openAppWithNotificationThread" -> {
                val notification = Notification.fromJson(call.arguments() ?: "")
                NewActivitiesLaunchHelper.openAppWithNotificationThread(
                    context = context,
                    notification = notification,
                    pendingIntent = notificationServiceConn.service?.getPendingIntentForKey(
                        notification.key
                    ),
                )
                result.success(true)
            }

            "openAppSettingsForPackage" -> {
                NewActivitiesLaunchHelper.openSettingsForPackage(
                    context,
                    call.arguments() ?: ""
                )
                result.success(true)
            }

            "openDeviceDndSettings" -> {
                NewActivitiesLaunchHelper.openDeviceDndSettings(context)
                result.success(true)
            }

            "openAutoStartSettings" -> {
                result.success(NewActivitiesLaunchHelper.openAutoStartSettings(context))
            }

            "restartApp" -> {
                activity?.let {
                    NewActivitiesLaunchHelper.restartMindful(it)
                }
                result.success(true)
            }

            "launchUrl" -> {
                NewActivitiesLaunchHelper.launchUrl(context, call.arguments() ?: "")
                result.success(true)
            }

            "parseHostFromUrl" -> {
                result.success(Utils.parseHostNameFromUrl(call.arguments() ?: "") ?: "")
            }

            else -> result.notImplemented()
        }
    }


    /**
     * Updates app and group restrictions in the tracker service.
     * If the service is connected, sends updates directly; otherwise,
     * sets a callback to update once the connection is established and starts the service.
     *
     * @param appRestrictions   a map of app package names to their respective restrictions,
     * or null if only group restrictions are being updated.
     * @param restrictionGroups a map of restriction group IDs to their respective restrictions,
     * or null if only app-specific restrictions are being updated.
     */
    private fun updateTrackerServiceRestrictions(
        appRestrictions: HashMap<String, AppRestriction>?,
        restrictionGroups: HashMap<Int, RestrictionGroup>?,
    ) {
        if (trackerServiceConn.isActive) {
            trackerServiceConn.service?.getRestrictionManager?.updateRestrictions(
                appRestrictions,
                restrictionGroups
            )
        } else if (appRestrictions?.isNotEmpty() == true || restrictionGroups?.isNotEmpty() == true) {
            trackerServiceConn.setOnConnectedCallback { service ->
                service.getRestrictionManager.updateRestrictions(
                    appRestrictions,
                    restrictionGroups
                )
            }
            trackerServiceConn.startAndBind()
        }
    }

    /**
     * Checks if the Create VPN permission is granted and optionally asks for it if not granted.
     *
     * @param askPermissionToo Whether to prompt the user to enable Create VPN permission if not granted.
     * @return True if Create VPN permission is granted, false otherwise.
     */
    private fun getAndAskVpnPermission(askPermissionToo: Boolean): Boolean {
        val intent = VpnService.prepare(context)
        if (askPermissionToo && intent != null) {
            vpnPermLauncher?.launch(intent)
        }
        return intent == null
    }

}BIGFEAT_EOF
echo "  wrote android/app/src/main/java/com/peace/mind/FgMethodCallHandler.kt"
echo ""
echo "Done. Git status:"
git status --short
