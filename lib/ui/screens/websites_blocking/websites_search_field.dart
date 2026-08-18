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
