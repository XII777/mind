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
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mindful/config/app_constants.dart';
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
    ).animate().scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          curve: Curves.easeOutBack,
          duration: AppConstants.defaultAnimDuration,
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

