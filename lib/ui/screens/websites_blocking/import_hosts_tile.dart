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
