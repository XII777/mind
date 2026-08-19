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
import 'package:mindful/core/models/flip_clock_theme.dart';
import 'package:mindful/providers/focus/flip_clock_theme_provider.dart';
import 'package:mindful/ui/screens/active_session/flip_clock_text.dart';

/// Opens a bottom sheet letting the user pick a color theme for the
/// focus-session flip clock, with a live preview of each option.
void showFlipClockThemePicker(BuildContext context) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => const _FlipClockThemePickerSheet(),
  );
}

class _FlipClockThemePickerSheet extends ConsumerWidget {
  const _FlipClockThemePickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(flipClockThemeProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(FluentIcons.color_20_filled),
                const SizedBox(width: 8),
                Text(
                  'Timer theme',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 16,
              children: [
                for (final theme in kFlipClockThemes)
                  _ThemeSwatch(
                    theme: theme,
                    isSelected: theme.id == selected.id,
                    onTap: () {
                      ref.read(flipClockThemeProvider.notifier).setTheme(theme);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  final FlipClockTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 92,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? scheme.primary : Colors.transparent,
            width: 2,
          ),
          color: scheme.surfaceContainerLow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IgnorePointer(
              child: FlipClockText(
                duration: const Duration(minutes: 12, seconds: 34),
                theme: theme,
                fontSize: 18,
                alwaysShowMinutes: true,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              theme.name,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
