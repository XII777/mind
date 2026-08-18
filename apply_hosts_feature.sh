#!/usr/bin/env bash
set -e
echo "Applying toggleable hosts-category import feature..."
mkdir -p "lib/core/models"
cat > "lib/core/models/imported_hosts_list.dart" << 'HOSTS_EOF'
/*
 *
 *  * Copyright (c) 2024 Mindful (https://github.com/akaMrNagar/Mindful)
 *  * Author : Pawan Nagar (https://github.com/akaMrNagar)
 *  *
 *  * This source code is licensed under the GPL-2.0 license license found in the
 *  * LICENSE file in the root directory of this source tree.
 *
 */

/// A single imported hosts list "category" (e.g. "Adult content",
/// "Gambling") shown in the UI as one toggle instead of a per-domain
/// list. Toggling [enabled] blocks/unblocks every domain in [domains]
/// at once.
class ImportedHostsList {
  const ImportedHostsList({
    required this.id,
    required this.name,
    required this.sourceLabel,
    required this.domains,
    required this.enabled,
    required this.isNsfw,
  });

  /// Stable identifier, e.g. derived from the source URL or file name.
  final String id;

  /// Display name, e.g. "Adult content (porn)".
  final String name;

  /// Short description of where this list came from, e.g. the URL or
  /// "Imported from device".
  final String sourceLabel;

  /// All domains belonging to this list.
  final List<String> domains;

  /// Whether this list's domains are currently being enforced/blocked.
  final bool enabled;

  /// Whether this list belongs to the NSFW category. NSFW lists are
  /// always locked on (cannot be disabled) once imported, matching the
  /// rest of the app's "NSFW entries are permanent" behavior.
  final bool isNsfw;

  ImportedHostsList copyWith({
    String? id,
    String? name,
    String? sourceLabel,
    List<String>? domains,
    bool? enabled,
    bool? isNsfw,
  }) {
    return ImportedHostsList(
      id: id ?? this.id,
      name: name ?? this.name,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      domains: domains ?? this.domains,
      enabled: enabled ?? this.enabled,
      isNsfw: isNsfw ?? this.isNsfw,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sourceLabel': sourceLabel,
        'domains': domains,
        'enabled': enabled,
        'isNsfw': isNsfw,
      };

  factory ImportedHostsList.fromJson(Map<String, dynamic> json) {
    return ImportedHostsList(
      id: json['id'] as String,
      name: json['name'] as String,
      sourceLabel: json['sourceLabel'] as String? ?? '',
      domains: (json['domains'] as List<dynamic>).cast<String>(),
      enabled: json['enabled'] as bool? ?? true,
      isNsfw: json['isNsfw'] as bool? ?? false,
    );
  }
}
HOSTS_EOF
echo "  wrote lib/core/models/imported_hosts_list.dart"
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
/// popular StevenBlack unified hosts lists
/// (https://github.com/StevenBlack/hosts) into a plain list of domains
/// that Mindful's website blocker can consume.
class HostsFileUtils {
  HostsFileUtils._();

  static const String _base =
      'https://raw.githubusercontent.com/StevenBlack/hosts/master';

  /// Base list: ads + malware (no fakenews/gambling/porn/social).
  static const String hostsAdsMalware = '$_base/hosts';

  /// Individual "alternates" variants, each = base (ads + malware) PLUS
  /// the named category.
  static const String hostsFakenews = '$_base/alternates/fakenews/hosts';
  static const String hostsGambling = '$_base/alternates/gambling/hosts';
  static const String hostsPorn = '$_base/alternates/porn/hosts';
  static const String hostsSocial = '$_base/alternates/social/hosts';

  /// Combined variants (base + two or more categories).
  static const String hostsFakenewsGambling =
      '$_base/alternates/fakenews-gambling/hosts';
  static const String hostsFakenewsPorn =
      '$_base/alternates/fakenews-porn/hosts';
  static const String hostsFakenewsSocial =
      '$_base/alternates/fakenews-social/hosts';
  static const String hostsGamblingPorn =
      '$_base/alternates/gambling-porn/hosts';
  static const String hostsGamblingSocial =
      '$_base/alternates/gambling-social/hosts';
  static const String hostsPornSocial =
      '$_base/alternates/porn-social/hosts';
  static const String hostsFakenewsGamblingPorn =
      '$_base/alternates/fakenews-gambling-porn/hosts';
  static const String hostsFakenewsGamblingSocial =
      '$_base/alternates/fakenews-gambling-social/hosts';
  static const String hostsFakenewsPornSocial =
      '$_base/alternates/fakenews-porn-social/hosts';
  static const String hostsGamblingPornSocial =
      '$_base/alternates/gambling-porn-social/hosts';

  /// Everything: base + fakenews + gambling + porn + social.
  static const String hostsEverything =
      '$_base/alternates/fakenews-gambling-porn-social/hosts';

  /// Kept for backwards compatibility with earlier versions of this file.
  static const String stevenBlackHostsUrl = hostsAdsMalware;
  static const String stevenBlackPornUrl = hostsPorn;
  static const String stevenBlackPornOnlyUrl = hostsPorn;

  /// Parses the raw content of a hosts file and returns the set of unique,
  /// valid domains found within it.
  ///
  /// Handles both standard hosts-file syntax:
  /// ```
  /// 0.0.0.0 ads.example.com
  /// 127.0.0.1 tracker.example.com # comment
  /// ```
  /// and plain domain-per-line lists (no leading IP), which some
  /// blocklists / exports use:
  /// ```
  /// ads.example.com
  /// tracker.example.com
  /// ```
  /// Lines starting with `#`, blank lines, and reserved/loopback-only
  /// entries (e.g. `0.0.0.0 0.0.0.0`, `localhost`) are ignored. Handles
  /// UTF-8 BOM and both `\n` and `\r\n` line endings.
  static Set<String> parseHostsContent(String content) {
    final Set<String> domains = {};

    /// Strip a UTF-8 byte-order-mark if present (common when files are
    /// saved/downloaded on Windows) and normalize CRLF to LF.
    final normalized = content
        .replaceFirst('\uFEFF', '')
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');

    for (final rawLine in normalized.split('\n')) {
      final line = rawLine.trim();

      /// Skip empty lines and comments
      if (line.isEmpty || line.startsWith('#') || line.startsWith('!')) {
        continue;
      }

      /// Strip inline comments
      final withoutComment = line.split('#').first.trim();
      if (withoutComment.isEmpty) continue;

      /// Split on whitespace. Two supported shapes:
      /// 1. "<ip> <host> [aliases...]" (standard hosts file)
      /// 2. "<host>" (plain domain list, one per line)
      final parts = withoutComment.split(RegExp(r'\s+'));

      if (parts.length == 1) {
        /// Plain domain-only line
        final normalizedHost = parts.first.trim().toLowerCase();
        if (_isValidBlockableHost(normalizedHost)) {
          domains.add(normalizedHost);
        }
        continue;
      }

      /// First token looks like an IP (has dots/colons and no letters
      /// other than hex in the ipv6 case) -> treat as "<ip> <hosts...>"
      /// Otherwise, be lenient and just treat every token as a host,
      /// since some lists prefix with junk we don't recognize.
      final looksLikeIp = RegExp(r'^[0-9a-fA-F:.]+$').hasMatch(parts.first);
      final hostTokens = looksLikeIp ? parts.sublist(1) : parts;

      for (final host in hostTokens) {
        final normalizedHost = host.trim().toLowerCase();
        if (_isValidBlockableHost(normalizedHost)) {
          domains.add(normalizedHost);
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
echo "  wrote lib/core/utils/hosts_file_utils.dart"
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
echo "  wrote lib/providers/restrictions/wellbeing_provider.dart"
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
echo "  wrote lib/providers/restrictions/websites_search_provider.dart"
mkdir -p "lib/providers/restrictions"
cat > "lib/providers/restrictions/imported_hosts_lists_provider.dart" << 'HOSTS_EOF'
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
import 'package:mindful/core/models/imported_hosts_list.dart';
import 'package:mindful/core/services/method_channel_service.dart';
import 'package:mindful/providers/restrictions/wellbeing_provider.dart';
import 'package:path_provider/path_provider.dart';

/// Manages imported hosts-list "categories" (e.g. Ads, Porn, Gambling)
/// shown in the UI as a single toggle each instead of a per-domain list.
///
/// This intentionally does NOT store the (potentially huge) domain
/// lists inside the Drift database used by [wellBeingProvider] - it
/// keeps its own lightweight JSON file so the main settings DB stays
/// small and fast. Whenever a category is imported or toggled, this
/// provider recomputes the full enforcement set (manually-added sites
/// from [wellBeingProvider] plus domains from every *enabled* category)
/// and pushes that combined set straight to the native blocking
/// service, without persisting the expanded set back into the Drift DB.
final importedHostsListsProvider = StateNotifierProvider<
    ImportedHostsListsNotifier, List<ImportedHostsList>>(
  (ref) => ImportedHostsListsNotifier(ref),
);

class ImportedHostsListsNotifier
    extends StateNotifier<List<ImportedHostsList>> {
  final Ref _ref;
  bool _loaded = false;

  ImportedHostsListsNotifier(this._ref) : super(const []) {
    _init();
  }

  Future<File> _storageFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/imported_hosts_lists.json');
  }

  Future<void> _init() async {
    try {
      final file = await _storageFile();
      if (await file.exists()) {
        final raw = await file.readAsString();
        final decoded = jsonDecode(raw) as List<dynamic>;
        state = decoded
            .map((e) => ImportedHostsList.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      /// Corrupted or unreadable file — start fresh rather than crash.
      state = const [];
    }

    _loaded = true;

    /// Keep native enforcement in sync whenever the underlying manual
    /// blocklist (from wellBeingProvider) changes too, since the
    /// effective set is manual ∪ enabled-category domains.
    _ref.listen(wellBeingProvider, (_, __) => _pushCombinedStateToNative());

    await _persistAndSync();
  }

  Future<void> _persist() async {
    if (!_loaded) return;
    try {
      final file = await _storageFile();
      final encoded = jsonEncode(state.map((e) => e.toJson()).toList());
      await file.writeAsString(encoded);
    } catch (_) {
      /// Best-effort persistence; ignore write failures (e.g. low storage).
    }
  }

  Future<void> _persistAndSync() async {
    await _persist();
    await _pushCombinedStateToNative();
  }

  /// Sends the manually-added sites (from [wellBeingProvider]) combined
  /// with every enabled category's domains to the native blocking
  /// service, without writing the expanded set back to the Drift DB.
  Future<void> _pushCombinedStateToNative() async {
    final wellbeing = _ref.read(wellBeingProvider);

    final enabledNonNsfwDomains = state
        .where((l) => l.enabled && !l.isNsfw)
        .expand((l) => l.domains);
    final enabledNsfwDomains =
        state.where((l) => l.enabled && l.isNsfw).expand((l) => l.domains);

    final combinedBlocked = {
      ...wellbeing.blockedWebsites,
      ...enabledNonNsfwDomains,
    }.toList();

    final combinedNsfw = {
      ...wellbeing.nsfwWebsites,
      ...enabledNsfwDomains,
    }.toList();

    final combinedState = wellbeing.copyWith(
      blockedWebsites: combinedBlocked,
      nsfwWebsites: combinedNsfw,
      /// If any NSFW category is enabled, force NSFW blocking on too.
      blockNsfwSites: wellbeing.blockNsfwSites || combinedNsfw.isNotEmpty,
    );

    await MethodChannelService.instance.updateWellBeingSettings(combinedState);
  }

  /// Imports (or re-imports/updates) a category list. If a category
  /// with the same [id] already exists, its domains and metadata are
  /// refreshed while preserving its current enabled state.
  ///
  /// Returns the number of domains in the (new or refreshed) list.
  Future<int> addOrUpdateList({
    required String id,
    required String name,
    required String sourceLabel,
    required Set<String> domains,
    required bool isNsfw,
  }) async {
    final existingIndex = state.indexWhere((l) => l.id == id);

    final newEntry = ImportedHostsList(
      id: id,
      name: name,
      sourceLabel: sourceLabel,
      domains: domains.toList(),
      enabled: existingIndex == -1 ? true : state[existingIndex].enabled,
      isNsfw: isNsfw,
    );

    if (existingIndex == -1) {
      state = [...state, newEntry];
    } else {
      state = [
        for (final l in state) l.id == id ? newEntry : l,
      ];
    }

    await _persistAndSync();
    return domains.length;
  }

  /// Toggles a category on/off. NSFW categories are locked and cannot
  /// be disabled once imported.
  Future<void> toggleList(String id) async {
    ImportedHostsList? target;
    for (final l in state) {
      if (l.id == id) {
        target = l;
        break;
      }
    }
    if (target == null || target.isNsfw) return; // locked or not found

    state = [
      for (final l in state) l.id == id ? l.copyWith(enabled: !l.enabled) : l,
    ];

    await _persistAndSync();
  }

  /// Removes a non-NSFW category entirely. NSFW categories are locked
  /// and cannot be removed once imported.
  Future<void> removeList(String id) async {
    ImportedHostsList? target;
    for (final l in state) {
      if (l.id == id) {
        target = l;
        break;
      }
    }
    if (target == null || target.isNsfw) return;

    state = state.where((l) => l.id != id).toList();
    await _persistAndSync();
  }
}
HOSTS_EOF
echo "  wrote lib/providers/restrictions/imported_hosts_lists_provider.dart"
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

import 'dart:convert';
import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mindful/core/extensions/ext_build_context.dart';
import 'package:mindful/core/utils/hosts_file_utils.dart';
import 'package:mindful/providers/restrictions/imported_hosts_lists_provider.dart';
import 'package:mindful/ui/common/default_list_tile.dart';

/// One selectable preset source in the hosts-file import sheet.
class _HostsSource {
  const _HostsSource({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isNsfw,
    required this.url,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isNsfw;
  final String url;
}

final List<_HostsSource> _remoteSources = [
  _HostsSource(
    id: 'stevenblack_ads_malware',
    title: 'Ads + Malware (base list)',
    subtitle: 'StevenBlack/hosts — default',
    icon: FluentIcons.shield_20_regular,
    isNsfw: false,
    url: HostsFileUtils.hostsAdsMalware,
  ),
  _HostsSource(
    id: 'stevenblack_fakenews',
    title: 'Fake news',
    subtitle: 'Base list + fake news sites',
    icon: FluentIcons.news_20_regular,
    isNsfw: false,
    url: HostsFileUtils.hostsFakenews,
  ),
  _HostsSource(
    id: 'stevenblack_gambling',
    title: 'Gambling',
    subtitle: 'Base list + gambling sites',
    icon: FluentIcons.money_20_regular,
    isNsfw: false,
    url: HostsFileUtils.hostsGambling,
  ),
  _HostsSource(
    id: 'stevenblack_social',
    title: 'Social media',
    subtitle: 'Base list + social media sites',
    icon: FluentIcons.people_20_regular,
    isNsfw: false,
    url: HostsFileUtils.hostsSocial,
  ),
  _HostsSource(
    id: 'stevenblack_porn',
    title: 'Adult content (porn)',
    subtitle: 'Base list + adult sites — locked NSFW category',
    icon: FluentIcons.eye_off_20_regular,
    isNsfw: true,
    url: HostsFileUtils.hostsPorn,
  ),
  _HostsSource(
    id: 'stevenblack_gambling_porn',
    title: 'Gambling + Adult content',
    subtitle: 'Base list + gambling + porn — locked NSFW category',
    icon: FluentIcons.shield_error_20_regular,
    isNsfw: true,
    url: HostsFileUtils.hostsGamblingPorn,
  ),
  _HostsSource(
    id: 'stevenblack_fakenews_gambling_porn',
    title: 'Fake news + Gambling + Adult',
    subtitle: 'Base list + fakenews + gambling + porn — locked NSFW category',
    icon: FluentIcons.shield_error_20_regular,
    isNsfw: true,
    url: HostsFileUtils.hostsFakenewsGamblingPorn,
  ),
  _HostsSource(
    id: 'stevenblack_everything',
    title: 'Everything',
    subtitle:
        'Base + fake news + gambling + porn + social — locked NSFW category',
    icon: FluentIcons.shield_lock_20_regular,
    isNsfw: true,
    url: HostsFileUtils.hostsEverything,
  ),
];

/// A list tile which lets the user bulk-import a hosts-file category
/// (e.g. from https://github.com/StevenBlack/hosts) as a single
/// toggleable entry, rather than dumping every domain into the visible
/// websites list. The user can choose a preset variant, enter a custom
/// URL, or pick a hosts file already saved on their device.
///
/// Adult-content sources are routed to the locked NSFW category, which
/// cannot be disabled or removed once imported.
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
      titleText: 'Import a hosts-file category',
      subtitleText: _isImporting
          ? 'Importing, please wait...'
          : 'Add a toggleable blocklist category (e.g. StevenBlack/hosts)',
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
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (context, scrollController) => SafeArea(
          child: ListView(
            controller: scrollController,
            children: [
              for (final source in _remoteSources)
                DefaultListTile(
                  leadingIcon: source.icon,
                  titleText: source.title,
                  subtitleText: source.subtitle,
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    _importFromUrl(
                      context,
                      id: source.id,
                      name: source.title,
                      url: source.url,
                      isNsfw: source.isNsfw,
                    );
                  },
                ),
              DefaultListTile(
                leadingIcon: FluentIcons.link_20_regular,
                titleText: 'Add from a custom URL',
                subtitleText: 'Enter any hosts-file link to import',
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  _promptCustomUrl(context);
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _promptCustomUrl(BuildContext context) async {
    final urlController = TextEditingController();
    final nameController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Import from URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Category name',
                hintText: 'e.g. My custom list',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              autofocus: true,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Hosts file URL',
                hintText: 'https://example.com/hosts.txt',
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
            onPressed: () => Navigator.of(dialogContext).pop({
              'url': urlController.text.trim(),
              'name': nameController.text.trim(),
            }),
            child: const Text('Next'),
          ),
        ],
      ),
    );

    if (result == null) return;
    final url = result['url'] ?? '';
    final name = (result['name'] ?? '').isEmpty
        ? 'Custom list'
        : result['name']!;

    if (!(url.startsWith('http://') || url.startsWith('https://'))) {
      if (mounted) {
        context.showSnackAlert('Please enter a valid http(s) URL');
      }
      return;
    }

    if (!mounted) return;
    final isNsfw = await _askIfAdultList(context);
    if (isNsfw == null) return;

    if (!mounted) return;
    await _importFromUrl(
      context,
      id: 'custom_${url.hashCode}',
      name: name,
      url: url,
      isNsfw: isNsfw,
    );
  }

  Future<void> _importFromUrl(
    BuildContext context, {
    required String id,
    required String name,
    required String url,
    required bool isNsfw,
  }) async {
    setState(() => _isImporting = true);
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to download hosts file (status ${response.statusCode})',
        );
      }

      await _applyParsedHosts(
        context,
        response.body,
        id: id,
        name: name,
        sourceLabel: url,
        isNsfw: isNsfw,
      );
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
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final pickedFile = result.files.first;

      String content;
      if (pickedFile.bytes != null) {
        content = utf8.decode(pickedFile.bytes!, allowMalformed: true);
      } else {
        final path = pickedFile.xFile.path;
        if (path.isEmpty) {
          throw Exception('Selected file has no readable path');
        }
        final file = File(path);
        if (!await file.exists()) {
          throw Exception('Selected file could not be found');
        }
        final bytes = await file.readAsBytes();
        content = utf8.decode(bytes, allowMalformed: true);
      }

      if (!mounted) return;
      final isNsfw = await _askIfAdultList(context);
      if (isNsfw == null) return;

      setState(() => _isImporting = true);
      await _applyParsedHosts(
        context,
        content,
        id: 'local_${pickedFile.name.hashCode}',
        name: pickedFile.name,
        sourceLabel: 'Imported from device',
        isNsfw: isNsfw,
      );
    } catch (e) {
      if (mounted) {
        context.showSnackAlert('Could not read the selected file: $e');
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  Future<bool?> _askIfAdultList(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('What kind of list is this?'),
        content: const Text(
          'If this file contains adult/NSFW website domains, it will be '
          'added to the locked NSFW category and cannot be disabled or '
          'removed later. Otherwise it will be added as a regular '
          'toggleable category.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Regular category'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Adult / NSFW list'),
          ),
        ],
      ),
    );
  }

  Future<void> _applyParsedHosts(
    BuildContext context,
    String content, {
    required String id,
    required String name,
    required String sourceLabel,
    required bool isNsfw,
  }) async {
    final domains = HostsFileUtils.parseHostsContent(content);

    if (domains.isEmpty) {
      if (mounted) {
        context.showSnackAlert(
          'No valid host entries were found in the file '
          '(${content.length} characters read)',
        );
      }
      return;
    }

    final count = await ref.read(importedHostsListsProvider.notifier).addOrUpdateList(
          id: id,
          name: name,
          sourceLabel: sourceLabel,
          domains: domains,
          isNsfw: isNsfw,
        );

    if (mounted) {
      context.showSnackAlert(
        'Added "$name" with $count website${count == 1 ? '' : 's'} '
        '${isNsfw ? '(locked NSFW category)' : ''}',
      );
    }
  }
}
HOSTS_EOF
echo "  wrote lib/ui/screens/websites_blocking/import_hosts_tile.dart"
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
echo "  wrote lib/ui/screens/websites_blocking/websites_search_field.dart"
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
echo "  wrote lib/ui/screens/websites_blocking/sliver_blocked_websites_list.dart"
mkdir -p "lib/ui/screens/websites_blocking"
cat > "lib/ui/screens/websites_blocking/sliver_imported_hosts_categories.dart" << 'HOSTS_EOF'
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
import 'package:mindful/providers/restrictions/imported_hosts_lists_provider.dart';
import 'package:mindful/providers/restrictions/websites_search_provider.dart';
import 'package:mindful/ui/common/default_list_tile.dart';

/// Shows one toggle tile per imported hosts-list category (e.g. Ads,
/// Porn, Gambling) instead of every individual domain. NSFW categories
/// show a lock icon and cannot be toggled off or removed.
///
/// When a search query is active, categories are filtered to those
/// whose name matches, OR - for currently enabled categories - whose
/// domain list contains a match, in which case up to a few matching
/// domains are shown in the subtitle so the user can confirm a
/// specific site is covered.
class SliverImportedHostsCategories extends ConsumerWidget {
  const SliverImportedHostsCategories({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(importedHostsListsProvider);
    final searchQuery = ref.watch(websitesSearchQueryProvider);

    if (categories.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox());
    }

    final List<Widget> tiles = [];

    for (final category in categories) {
      String subtitle = '${category.domains.length} websites'
          '${category.isNsfw ? ' • Locked NSFW category' : ''}';
      bool matches = searchQuery.isEmpty;

      if (searchQuery.isNotEmpty) {
        final nameMatches = category.name.toLowerCase().contains(searchQuery);

        if (nameMatches) {
          matches = true;
        } else if (category.enabled) {
          /// Only search inside domains of currently enabled categories,
          /// per requirement that search covers what's actively blocked.
          final allMatchingDomains =
              category.domains.where((d) => d.contains(searchQuery)).toList();

          if (allMatchingDomains.isNotEmpty) {
            matches = true;
            final shown = allMatchingDomains.take(4).toList();
            final moreCount = allMatchingDomains.length - shown.length;
            subtitle = 'Matches: ${shown.join(', ')}'
                '${moreCount > 0 ? ' +$moreCount more' : ''}';
          }
        }
      }

      if (!matches) continue;

      tiles.add(
        DefaultListTile(
          leadingIcon: category.isNsfw
              ? FluentIcons.lock_closed_20_filled
              : FluentIcons.list_20_regular,
          titleText: category.name,
          subtitleText: subtitle,
          trailing: category.isNsfw
              ? const Icon(FluentIcons.lock_closed_20_filled, size: 18)
              : Switch(
                  value: category.enabled,
                  onChanged: (_) => ref
                      .read(importedHostsListsProvider.notifier)
                      .toggleList(category.id),
                ),
          onPressed: category.isNsfw
              ? null
              : () => ref
                  .read(importedHostsListsProvider.notifier)
                  .toggleList(category.id),
        ),
      );
    }

    if (tiles.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox());
    }

    return SliverList(delegate: SliverChildListDelegate(tiles));
  }
}
HOSTS_EOF
echo "  wrote lib/ui/screens/websites_blocking/sliver_imported_hosts_categories.dart"
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
import 'package:mindful/ui/screens/websites_blocking/sliver_imported_hosts_categories.dart';
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
HOSTS_EOF
echo "  wrote lib/ui/screens/websites_blocking/websites_blocking_screen.dart"
echo ""
echo "Done. Git status (you should see these files as modified/new):"
git status --short
