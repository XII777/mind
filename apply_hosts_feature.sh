#!/usr/bin/env bash
set -e
# Run this from the root of your Mindful project folder (where pubspec.yaml lives)
mkdir -p "lib/core/utils"
cat > "lib/core/utils/hosts_file_utils.dart" << 'HOSTS_EOF'
/*
 *
 *  * Copyright (c) 2024 Mindful (https://github.com/akaMrNagar/Mindful)
 *  * Author : Pawan Nagar (https://github.com/akaMrNagar)
 *  *
 *  * This source code is licensed under the GPL-2.0 license license found in the
 *  * LICENSE file in the root directory of this source tree.
 *
 */

/// Utilities to fetch and parse "hosts" formatted files such as the
/// popular StevenBlack unified hosts list
/// (https://github.com/StevenBlack/hosts) into a plain list of domains
/// that Mindful's website blocker can consume.
class HostsFileUtils {
  HostsFileUtils._();

  /// Default raw URL of the StevenBlack/hosts unified hosts file
  /// (ads + malware + fakenews, no adult content).
  static const String stevenBlackHostsUrl =
      'https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts';

  /// Raw URL of the StevenBlack/hosts "porn" variant — adult content
  /// combined with the base ads/malware/fakenews lists.
  static const String stevenBlackPornUrl =
      'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn/hosts';

  /// Raw URL of the StevenBlack/hosts "porn-only" variant — adult
  /// content domains only, without the base ads/malware lists.
  static const String stevenBlackPornOnlyUrl =
      'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn-only/hosts';

  /// Parses the raw content of a hosts file and returns the set of unique,
  /// valid domains found within it.
  ///
  /// A typical hosts file line looks like:
  /// ```
  /// 0.0.0.0 ads.example.com
  /// 127.0.0.1 tracker.example.com # comment
  /// ```
  /// Lines starting with `#`, blank lines, and reserved/loopback-only
  /// entries (e.g. `0.0.0.0 0.0.0.0`, `localhost`) are ignored.
  static Set<String> parseHostsContent(String content) {
    final Set<String> domains = {};

    for (final rawLine in content.split('\n')) {
      final line = rawLine.trim();

      /// Skip empty lines and comments
      if (line.isEmpty || line.startsWith('#')) continue;

      /// Strip inline comments
      final withoutComment = line.split('#').first.trim();
      if (withoutComment.isEmpty) continue;

      /// Split on whitespace, expected format: "<ip> <host> [aliases...]"
      final parts = withoutComment.split(RegExp(r'\s+'));
      if (parts.length < 2) continue;

      /// Everything after the IP is a hostname/alias on that line
      for (final host in parts.sublist(1)) {
        final normalized = host.trim().toLowerCase();

        if (_isValidBlockableHost(normalized)) {
          domains.add(normalized);
        }
      }
    }

    return domains;
  }

  static const Set<String> _ignoredHosts = {
    'localhost',
    'localhost.localdomain',
    'local',
    'broadcasthost',
    'ip6-localhost',
    'ip6-loopback',
    'ip6-localnet',
    'ip6-mcastprefix',
    'ip6-allnodes',
    'ip6-allrouters',
    'ip6-allhosts',
    '0.0.0.0',
  };

  static bool _isValidBlockableHost(String host) {
    if (host.isEmpty) return false;
    if (host.contains(' ')) return false;
    if (!host.contains('.')) return false;
    if (_ignoredHosts.contains(host)) return false;

    /// Reject anything that isn't a plausible domain (letters, digits,
    /// dots and hyphens only)
    return RegExp(r'^[a-z0-9.-]+$').hasMatch(host);
  }
}
HOSTS_EOF
mkdir -p "lib/providers/restrictions"
cat > "lib/providers/restrictions/wellbeing_provider.dart" << 'HOSTS_EOF'
/*
 *
 *  * Copyright (c) 2024 Mindful (https://github.com/akaMrNagar/Mindful)
 *  * Author : Pawan Nagar (https://github.com/akaMrNagar)
 *  *
 *  * This source code is licensed under the GPL-2.0 license license found in the
 *  * LICENSE file in the root directory of this source tree.
 *
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindful/core/database/app_database.dart';
import 'package:mindful/core/database/daos/unique_records_dao.dart';
import 'package:mindful/core/enums/platform_features.dart';
import 'package:mindful/core/services/drift_db_service.dart';
import 'package:mindful/core/services/method_channel_service.dart';
import 'package:mindful/core/utils/default_models_utils.dart';

/// A Riverpod state notifier provider that manages [Wellbeing] related settings.
final wellBeingProvider = StateNotifierProvider<WellBeingNotifier, Wellbeing>(
  (ref) => WellBeingNotifier(),
);

/// This class manages the state of well-being settings.
class WellBeingNotifier extends StateNotifier<Wellbeing> {
  late UniqueRecordsDao _dao;

  WellBeingNotifier() : super(defaultWellbeingModel) {
    _init();
  }

  /// Initializes the well-being settings by loading them from the database and setting up a listener to save changes.
  void _init() async {
    _dao = DriftDbService.instance.driftDb.uniqueRecordsDao;
    state = await _dao.loadWellBeingSettings();

    if (MethodChannelService.instance.isSelfRestart) {
      await MethodChannelService.instance.updateWellBeingSettings(state);
    }

    /// Listen to provider and save changes to Isar database and platform service
    addListener(
      fireImmediately: false,
      (state) {
        _dao.saveWellBeingSettings(state);
        MethodChannelService.instance.updateWellBeingSettings(state);
      },
    );
  }

  /// Adds or removes a feature to/from the blocked features list.
  void insertRemoveBlockedFeature(PlatformFeatures feature) =>
      state = state.copyWith(
        blockedFeatures: state.blockedFeatures.contains(feature)
            ? [...state.blockedFeatures.where((e) => e != feature)]
            : [...state.blockedFeatures, feature],
      );

  /// Toggles the block status for NSFW websites.
  void switchBlockNsfwSites() =>
      state = state.copyWith(blockNsfwSites: !state.blockNsfwSites);

  /// Adds or removes a website host to the blocked websites list.
  void insertRemoveBlockedSite(String websiteHost, bool shouldInsert) async =>
      state = state.copyWith(
        blockedWebsites: shouldInsert
            ? [...state.blockedWebsites, websiteHost]
            : [...state.blockedWebsites.where((e) => e != websiteHost)],
      );

  /// Adds a website host to the nsfw websites list.
  void insertNsfwSite(String websiteHost) async => state =
      state.copyWith(nsfwWebsites: [...state.nsfwWebsites, websiteHost]);

  /// Bulk-adds a set of website hosts (e.g. imported from a hosts file
  /// such as https://github.com/StevenBlack/hosts) to the blocked
  /// websites list, skipping hosts that are already present.
  ///
  /// Returns the number of newly added hosts.
  int importBlockedSites(Iterable<String> websiteHosts) {
    final existing = state.blockedWebsites.toSet();
    final toAdd = websiteHosts
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty && !existing.contains(e))
        .toSet();

    if (toAdd.isEmpty) return 0;

    state = state.copyWith(
      blockedWebsites: [...state.blockedWebsites, ...toAdd],
    );

    return toAdd.length;
  }

  /// Bulk-adds a set of website hosts (e.g. an adult-content hosts list
  /// such as the StevenBlack/hosts "porn" or "porn-only" variant) to the
  /// NSFW websites list, and switches on NSFW blocking automatically.
  ///
  /// Entries added to [Wellbeing.nsfwWebsites] are permanently locked
  /// (non-removable) by the rest of the app, since [WebsiteTile] disables
  /// removal for any host that is present in [Wellbeing.nsfwWebsites].
  ///
  /// Returns the number of newly added hosts.
  int importNsfwSites(Iterable<String> websiteHosts) {
    final existing = state.nsfwWebsites.toSet();
    final toAdd = websiteHosts
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty && !existing.contains(e))
        .toSet();

    if (toAdd.isEmpty) return 0;

    state = state.copyWith(
      nsfwWebsites: [...state.nsfwWebsites, ...toAdd],
      blockNsfwSites: true,
    );

    return toAdd.length;
  }

  /// Sets the allowed time limit for short content consumption.
  void setAllowedShortContentTime(int timeSec) =>
      state = state.copyWith(allowedShortsTimeSec: timeSec > 0 ? timeSec : -1);
}
HOSTS_EOF
mkdir -p "lib/providers/restrictions"
cat > "lib/providers/restrictions/websites_search_provider.dart" << 'HOSTS_EOF'
/*
 *
 *  * Copyright (c) 2024 Mindful (https://github.com/akaMrNagar/Mindful)
 *  * Author : Pawan Nagar (https://github.com/akaMrNagar)
 *  *
 *  * This source code is licensed under the GPL-2.0 license license found in the
 *  * LICENSE file in the root directory of this source tree.
 *
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the current (lower-cased) search query used to filter the
/// blocked/NSFW websites list on the websites blocking screen.
final websitesSearchQueryProvider = StateProvider<String>((ref) => '');
HOSTS_EOF
mkdir -p "lib/ui/screens/websites_blocking"
cat > "lib/ui/screens/websites_blocking/import_hosts_tile.dart" << 'HOSTS_EOF'
/*
 *
 *  * Copyright (c) 2024 Mindful (https://github.com/akaMrNagar/Mindful)
 *  * Author : Pawan Nagar (https://github.com/akaMrNagar)
 *  *
 *  * This source code is licensed under the GPL-2.0 license license found in the
 *  * LICENSE file in the root directory of this source tree.
 *
 */

import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mindful/core/extensions/ext_build_context.dart';
import 'package:mindful/core/utils/hosts_file_utils.dart';
import 'package:mindful/providers/restrictions/wellbeing_provider.dart';
import 'package:mindful/ui/common/default_list_tile.dart';

/// One selectable source in the hosts-file import sheet.
class _HostsSource {
  const _HostsSource({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isNsfw,
    this.url,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  /// If true, imported hosts are routed to the NSFW list (auto-locked,
  /// non-removable, and switches on NSFW blocking). If false, they go
  /// to the regular blocked-websites list.
  final bool isNsfw;

  /// Remote URL to download, or null for "pick a local file".
  final String? url;
}

const List<_HostsSource> _remoteSources = [
  _HostsSource(
    title: 'Full list (ads, malware, fake news)',
    subtitle: 'StevenBlack/hosts — general blocklist',
    icon: FluentIcons.shield_20_regular,
    isNsfw: false,
    url: HostsFileUtils.stevenBlackHostsUrl,
  ),
  _HostsSource(
    title: 'Full list + adult content',
    subtitle: 'StevenBlack/hosts — "porn" variant',
    icon: FluentIcons.shield_error_20_regular,
    isNsfw: true,
    url: HostsFileUtils.stevenBlackPornUrl,
  ),
  _HostsSource(
    title: 'Adult content only',
    subtitle: 'StevenBlack/hosts — "porn-only" variant',
    icon: FluentIcons.eye_off_20_regular,
    isNsfw: true,
    url: HostsFileUtils.stevenBlackPornOnlyUrl,
  ),
];

/// A list tile which lets the user bulk-import blocked websites from a
/// "hosts" formatted file, such as the popular unified hosts lists from
/// https://github.com/StevenBlack/hosts
///
/// The user can choose between the general list, the adult-content
/// ("porn") variants, or a hosts file already saved on their device.
/// Any hosts imported from an adult-content source are routed into the
/// NSFW list, which the rest of the app treats as permanently locked
/// (non-removable) and automatically blocked.
class ImportHostsFileTile extends ConsumerStatefulWidget {
  const ImportHostsFileTile({super.key});

  @override
  ConsumerState<ImportHostsFileTile> createState() =>
      _ImportHostsFileTileState();
}

class _ImportHostsFileTileState extends ConsumerState<ImportHostsFileTile> {
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    return DefaultListTile(
      enabled: !_isImporting,
      leadingIcon: FluentIcons.document_arrow_down_20_regular,
      titleText: 'Import from hosts file',
      subtitleText: _isImporting
          ? 'Importing, please wait...'
          : 'Bulk block websites using a hosts file (e.g. StevenBlack/hosts)',
      trailing: _isImporting
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(FluentIcons.chevron_right_20_regular),
      onPressed: _isImporting ? null : () => _showSourcePicker(context),
    );
  }

  void _showSourcePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final source in _remoteSources)
              DefaultListTile(
                leadingIcon: source.icon,
                titleText: source.title,
                subtitleText: source.subtitle,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  _importFromUrl(context, source);
                },
              ),
            DefaultListTile(
              leadingIcon: FluentIcons.document_search_20_regular,
              titleText: 'Select a hosts file from device',
              subtitleText:
                  'Choose a .txt or hosts file already saved on this device',
              onPressed: () {
                Navigator.of(sheetContext).pop();
                _importFromLocalFile(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _importFromUrl(
    BuildContext context,
    _HostsSource source,
  ) async {
    setState(() => _isImporting = true);
    try {
      final response = await http
          .get(Uri.parse(source.url!))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to download hosts file (status ${response.statusCode})',
        );
      }

      _applyParsedHosts(context, response.body, isNsfw: source.isNsfw);
    } catch (e) {
      if (mounted) {
        context.showSnackAlert('Could not download hosts file: $e');
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  Future<void> _importFromLocalFile(BuildContext context) async {
    try {
      /// FileType.any keeps this working for hosts files saved with no
      /// extension at all, or with .txt/.host/.hosts extensions - all of
      /// which are plain text under the hood regardless of what the OS
      /// reports as their MIME type.
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result == null || result.files.isEmpty) return;

      final path = result.files.first.xFile.path;
      if (path.isEmpty) return;

      final file = File(path);
      if (!await file.exists()) {
        throw Exception('Selected file could not be found');
      }

      setState(() => _isImporting = true);

      final content = await file.readAsString();

      if (!mounted) return;
      final isNsfw = await _askIfAdultList(context);
      if (isNsfw == null) return; // user dismissed the prompt

      _applyParsedHosts(context, content, isNsfw: isNsfw);
    } catch (e) {
      if (mounted) {
        context.showSnackAlert('Could not read the selected file: $e');
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  /// Asks the user whether the locally picked file is an adult-content
  /// list, so it can be routed to the locked NSFW category. Returns
  /// null if the user dismissed the dialog without choosing.
  Future<bool?> _askIfAdultList(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('What kind of list is this?'),
        content: const Text(
          'If this file contains adult/NSFW website domains, it will be '
          'added to the locked NSFW category and cannot be edited later. '
          'Otherwise it will be added to your regular blocked list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Regular blocklist'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Adult / NSFW list'),
          ),
        ],
      ),
    );
  }

  void _applyParsedHosts(
    BuildContext context,
    String content, {
    required bool isNsfw,
  }) {
    final domains = HostsFileUtils.parseHostsContent(content);

    if (domains.isEmpty) {
      if (mounted) {
        context.showSnackAlert(
          'No valid host entries were found in the file',
        );
      }
      return;
    }

    final notifier = ref.read(wellBeingProvider.notifier);
    final addedCount = isNsfw
        ? notifier.importNsfwSites(domains)
        : notifier.importBlockedSites(domains);

    if (mounted) {
      context.showSnackAlert(
        addedCount > 0
            ? 'Blocked $addedCount new website${addedCount == 1 ? '' : 's'} '
                '${isNsfw ? '(locked NSFW category) ' : ''}'
                'from the imported hosts file'
            : 'All websites from the file are already blocked',
      );
    }
  }
}
HOSTS_EOF
mkdir -p "lib/ui/screens/websites_blocking"
cat > "lib/ui/screens/websites_blocking/websites_search_field.dart" << 'HOSTS_EOF'
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
import 'package:mindful/providers/restrictions/websites_search_provider.dart';
import 'package:mindful/ui/common/search_bar.dart';

/// Search field to filter the blocked/NSFW websites list shown below it
/// on the websites blocking screen. Backed by [websitesSearchQueryProvider].
class WebsitesSearchField extends ConsumerWidget {
  const WebsitesSearchField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: DefaultSearchBar(
        hintText: 'Search blocked websites',
        onSubmitted: (query) => ref
            .read(websitesSearchQueryProvider.notifier)
            .state = query.trim().toLowerCase(),
      ),
    );
  }
}
HOSTS_EOF
mkdir -p "lib/ui/screens/websites_blocking"
cat > "lib/ui/screens/websites_blocking/sliver_blocked_websites_list.dart" << 'HOSTS_EOF'
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
import 'package:mindful/core/extensions/ext_build_context.dart';
import 'package:mindful/core/extensions/ext_widget.dart';
import 'package:mindful/providers/restrictions/wellbeing_provider.dart';
import 'package:mindful/providers/restrictions/websites_search_provider.dart';
import 'package:mindful/ui/common/empty_list_indicator.dart';
import 'package:mindful/ui/common/sliver_implicitly_animated_list.dart';
import 'package:mindful/ui/screens/websites_blocking/website_tile.dart';

class SliverBlockedWebsitesList extends ConsumerWidget {
  const SliverBlockedWebsitesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedWebsites = ref.watch(wellBeingProvider.select(
      (v) => v.blockedWebsites,
    ));
    final nsfwWebsites = ref.watch(wellBeingProvider.select(
      (v) => v.nsfwWebsites,
    ));
    final searchQuery = ref.watch(websitesSearchQueryProvider);

    final allWebsites = {...nsfwWebsites.reversed, ...blockedWebsites.reversed};

    final filteredWebsites = searchQuery.isEmpty
        ? allWebsites.toList()
        : allWebsites.where((host) => host.contains(searchQuery)).toList();

    return filteredWebsites.isNotEmpty
        ? SliverImplicitlyAnimatedList(
            itemExtent: 64,
            items: filteredWebsites,
            keyBuilder: (item) => item,
            itemBuilder: (context, i, item, position) => WebsiteTile(
              websitehost: item,
              isRemovable: !nsfwWebsites.contains(item),
              position: position,
            ),
          )
        : EmptyListIndicator(
            info: searchQuery.isEmpty
                ? context.locale.blocked_websites_empty_list_hint
                : 'No websites match "$searchQuery"',
          ).sliver;
  }
}
HOSTS_EOF
mkdir -p "lib/ui/screens/websites_blocking"
cat > "lib/ui/screens/websites_blocking/websites_blocking_screen.dart" << 'HOSTS_EOF'
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

            /// Search field to filter blocked/nsfw websites list
            const WebsitesSearchField().sliver,

            /// Distracting websites list
            const SliverBlockedWebsitesList(),

            const SliverTabsBottomPadding(),
          ],
        ),
      )
    ]);
  }
}
HOSTS_EOF
echo "All files written."
