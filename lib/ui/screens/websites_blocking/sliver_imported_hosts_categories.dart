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
