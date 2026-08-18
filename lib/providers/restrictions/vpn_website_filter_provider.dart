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
