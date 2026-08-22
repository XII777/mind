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
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindful/config/app_constants.dart';
import 'package:mindful/config/navigation/app_routes.dart';
import 'package:mindful/core/enums/default_home_tab.dart';
import 'package:mindful/core/enums/item_position.dart';
import 'package:mindful/core/extensions/ext_build_context.dart';
import 'package:mindful/core/extensions/ext_list.dart';
import 'package:mindful/core/extensions/ext_num.dart';
import 'package:mindful/providers/usage/todays_apps_usage_provider.dart';
import 'package:mindful/ui/common/content_section_header.dart';
import 'package:mindful/ui/common/default_expandable_list_tile.dart';
import 'package:mindful/ui/common/default_list_tile.dart';
import 'package:mindful/ui/common/sliver_active_session_alert.dart';
import 'package:mindful/ui/common/default_refresh_indicator.dart';
import 'package:mindful/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:mindful/ui/controllers/tab_controller_provider.dart';
import 'package:mindful/ui/screens/home/dashboard/glance_cards/focus_daily_glance.dart';
import 'package:mindful/ui/screens/home/dashboard/glance_cards/screen_time_glance.dart';
import 'package:mindful/ui/screens/home/dashboard/glance_cards_grid.dart';
import 'package:mindful/ui/screens/home/dashboard/sliver_tips_and_tricks.dart';
import 'package:mindful/ui/transitions/default_effects.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sliver_tools/sliver_tools.dart';

class TabDashboard extends ConsumerWidget {
  const TabDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUsageLoading =
        ref.watch(todaysAppsUsageProvider.select((v) => v.isLoading));

    final scheme = Theme.of(context).colorScheme;

    return DefaultRefreshIndicator(
      onRefresh: () async => ref
          .read(todaysAppsUsageProvider.notifier)
          .refreshTodaysUsage(resetState: true),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          /// Active session alert (preserved exactly)
          const SliverActiveSessionAlert(),

          MultiSliver(
            children: [
              8.vBox,

              // ── Stats Row ─────────────────────────────────
              Skeletonizer.zone(
                enabled: isUsageLoading,
                enableSwitchAnimation: true,
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      const Expanded(child: ScreenTimeGlance()),
                      4.hBox,
                      const Expanded(child: FocusDailyGlance()),
                    ],
                  ),
                ),
              ),

              // ── Glance expandable ─────────────────────────
              DefaultExpandableListTile(
                position: ItemPosition.mid,
                titleText: context.locale.glance_tile_title,
                subtitleText: context.locale.glance_tile_subtitle,
                content: Skeletonizer.zone(
                  enabled: isUsageLoading,
                  enableSwitchAnimation: true,
                  child: const GlanceCardsGrid(),
                ),
              ),

              // ── Parental Controls — accented card ─────────
              _ParentalControlsCard(),

              // ── Restrictions section ──────────────────────
              ..._restrictions(context, scheme),

              // ── Productivity section ──────────────────────
              ..._productivity(context, scheme),
            ].animateListOnce(
              ref: ref,
              uniqueKey: "home.dashboard",
              delay: 100.ms,
              effects: DefaultEffects.transitionIn,
              interval: 100.ms,
            ),
          ),

          const SliverTipsAndTricks(),
          const SliverTabsBottomPadding(),
        ],
      ),
    );
  }

  // ─── RESTRICTIONS ────────────────────────────────────────────
  static List<Widget> _restrictions(
      BuildContext context, ColorScheme scheme) {
    return [
      _SectionHeader(title: context.locale.restrictions_heading),

      // All five restriction tiles grouped into one card
      _RestrictTile(
        position: ItemPosition.top,
        icon: FluentIcons.app_title_20_regular,
        iconBg: const Color(0xFF1C3A2E),
        title: context.locale.apps_blocking_tile_title,
        subtitle: context.locale.apps_blocking_tile_subtitle,
        showChevron: false,
        onTap: () => TabControllerProvider.maybeOf(context)
            ?.animateToTab(DefaultHomeTab.statistics.index),
      ),
      _RestrictTile(
        position: ItemPosition.mid,
        icon: FluentIcons.app_recent_20_regular,
        iconBg: const Color(0xFF1A2F3E),
        title: context.locale.grouped_apps_blocking_tile_title,
        subtitle: context.locale.grouped_apps_blocking_tile_subtitle,
        onTap: () => Navigator.of(context)
            .pushNamed(AppRoutes.restrictionGroupsPath),
      ),
      _RestrictTile(
        position: ItemPosition.mid,
        icon: FluentIcons.globe_prohibited_20_regular,
        iconBg: const Color(0xFF2A1A3E),
        title: 'Internet blocking',
        subtitle: 'Block internet access for groups of apps.',
        onTap: () => Navigator.of(context)
            .pushNamed(AppRoutes.internetBlockingPath),
      ),
      _RestrictTile(
        position: ItemPosition.mid,
        icon: FluentIcons.resize_video_20_regular,
        iconBg: const Color(0xFF3E1A2A),
        title: context.locale.shorts_blocking_tab_title,
        subtitle: context.locale.shorts_blocking_tile_subtitle,
        onTap: () => Navigator.of(context)
            .pushNamed(AppRoutes.shortsBlockingPath),
      ),
      _RestrictTile(
        position: ItemPosition.bottom,
        icon: FluentIcons.earth_20_regular,
        iconBg: const Color(0xFF2E2A1A),
        title: context.locale.websites_blocking_tab_title,
        subtitle: context.locale.websites_blocking_tile_subtitle,
        onTap: () => Navigator.of(context)
            .pushNamed(AppRoutes.websitesBlockingPath),
      ),
    ];
  }

  // ─── PRODUCTIVITY ─────────────────────────────────────────────
  static List<Widget> _productivity(
      BuildContext context, ColorScheme scheme) {
    return [
      _SectionHeader(title: 'Productivity'),
      _RestrictTile(
        position: ItemPosition.top,
        icon: FluentIcons.drink_coffee_20_regular,
        iconBg: const Color(0xFF1C3A2E),
        title: 'Habits',
        subtitle: 'Build better habits and track them.',
        onTap: () => context.showSnackAlert(
          'Coming soon...',
          icon: FluentIcons.info_20_filled,
        ),
      ),
      _RestrictTile(
        position: ItemPosition.mid,
        icon: FluentIcons.reading_list_20_regular,
        iconBg: const Color(0xFF1A2F3E),
        title: 'Tasks and todos',
        subtitle: 'Plan your future with tasks and todos.',
        onTap: () => context.showSnackAlert(
          'Coming soon...',
          icon: FluentIcons.info_20_filled,
        ),
      ),
      _RestrictTile(
        position: ItemPosition.bottom,
        icon: FluentIcons.note_20_regular,
        iconBg: const Color(0xFF2A1A3E),
        title: 'Notes and lists',
        subtitle: 'Capture thoughts, checklists, or ideas.',
        onTap: () => context.showSnackAlert(
          'Coming soon...',
          icon: FluentIcons.info_20_filled,
        ),
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────
// PARENTAL CONTROLS CARD
// ─────────────────────────────────────────────────────────────────

class _ParentalControlsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final green = scheme.primary;

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
        color: scheme.secondaryContainer,
        border: Border.all(
          color: green.withValues(alpha: 0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: green.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
          onTap: () => Navigator.of(context)
              .pushNamed(AppRoutes.parentalControlsPath),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon in a glowing circle
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: green.withValues(alpha: 0.18),
                  ),
                  child: Icon(
                    FluentIcons.shield_keyhole_20_filled,
                    color: green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.locale.parental_controls_tab_title,
                        style: TextStyle(
                          color: scheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.locale.parental_controls_tile_subtitle,
                        style: TextStyle(
                          color: scheme.onSecondaryContainer
                              .withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: green.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Manage',
                        style: TextStyle(
                          color: green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        FluentIcons.chevron_right_20_regular,
                        color: green,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().scale(
          begin: const Offset(0.97, 0.97),
          end: const Offset(1, 1),
          curve: Curves.easeOutBack,
          duration: AppConstants.defaultAnimDuration,
        );
  }
}

// ─────────────────────────────────────────────────────────────────
// SECTION HEADER  (matches existing ContentSectionHeader style but
//                  with the green accent the reference uses)
// ─────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return ContentSectionHeader(title: title);
  }
}

// ─────────────────────────────────────────────────────────────────
// RESTRICTION TILE  — icon in a coloured pill, chevron, animations
// ─────────────────────────────────────────────────────────────────

class _RestrictTile extends StatelessWidget {
  const _RestrictTile({
    required this.position,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showChevron = true,
  });

  final ItemPosition position;
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DefaultListTile(
      position: position,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: scheme.primary),
      ),
      titleText: title,
      subtitleText: subtitle,
      trailing: showChevron
          ? const Icon(FluentIcons.chevron_right_20_regular)
          : null,
      onPressed: onTap,
    ).animate().scale(
          begin: const Offset(0.96, 0.96),
          end: const Offset(1, 1),
          curve: Curves.easeOutBack,
          duration: AppConstants.defaultAnimDuration,
        );
  }
}

