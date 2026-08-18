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
