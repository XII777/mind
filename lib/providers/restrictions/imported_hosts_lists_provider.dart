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
