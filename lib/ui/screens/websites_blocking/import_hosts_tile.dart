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

/// A list tile which lets the user bulk-import blocked websites from a
/// "hosts" formatted file, such as the popular unified hosts list from
/// https://github.com/StevenBlack/hosts
///
/// The user can either:
///  1. Fetch the latest StevenBlack/hosts list directly from GitHub, or
///  2. Select a hosts file already downloaded/saved on their device.
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
            DefaultListTile(
              leadingIcon: FluentIcons.globe_20_regular,
              titleText: 'Download StevenBlack/hosts',
              subtitleText:
                  'Fetch the latest unified hosts list from GitHub',
              onPressed: () {
                Navigator.of(sheetContext).pop();
                _importFromGithub(context);
              },
            ),
            DefaultListTile(
              leadingIcon: FluentIcons.document_search_20_regular,
              titleText: 'Select a hosts file',
              subtitleText: 'Choose a hosts file already on this device',
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

  Future<void> _importFromGithub(BuildContext context) async {
    setState(() => _isImporting = true);
    try {
      final response = await http
          .get(Uri.parse(HostsFileUtils.stevenBlackHostsUrl))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Failed to download hosts file '
            '(status ${response.statusCode})');
      }

      _applyParsedHosts(context, response.body);
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
      );

      if (result == null || result.files.isEmpty) return;

      final path = result.files.first.xFile.path;
      if (path.isEmpty) return;

      setState(() => _isImporting = true);

      final content = await File(path).readAsString();
      _applyParsedHosts(context, content);
    } catch (e) {
      if (mounted) {
        context.showSnackAlert('Could not read the selected file: $e');
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  void _applyParsedHosts(BuildContext context, String content) {
    final domains = HostsFileUtils.parseHostsContent(content);

    if (domains.isEmpty) {
      if (mounted) {
        context.showSnackAlert('No valid host entries were found in the file');
      }
      return;
    }

    final addedCount =
        ref.read(wellBeingProvider.notifier).importBlockedSites(domains);

    if (mounted) {
      context.showSnackAlert(
        addedCount > 0
            ? 'Blocked $addedCount new website${addedCount == 1 ? '' : 's'} '
                'from the imported hosts file'
            : 'All websites from the file are already blocked',
      );
    }
  }
}
