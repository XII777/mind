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
