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
