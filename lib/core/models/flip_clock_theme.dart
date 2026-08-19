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

/// A color preset for the flip-clock timer shown during a focus
/// session. [cardColor] and [textColor] are null for the special
/// "App theme" preset, which instead derives its colors live from the
/// current Material color scheme so it always blends with the rest of
/// the app's UI (including light/dark mode).
class FlipClockTheme {
  const FlipClockTheme({
    required this.id,
    required this.name,
    this.cardColor,
    this.textColor,
  });

  final String id;
  final String name;
  final Color? cardColor;
  final Color? textColor;

  /// Whether this preset dynamically follows the app's own color scheme
  /// rather than using fixed colors.
  bool get isDynamic => cardColor == null;

  Color resolveCardColor(BuildContext context) =>
      cardColor ?? Theme.of(context).colorScheme.surfaceContainerHigh;

  Color resolveTextColor(BuildContext context) =>
      textColor ?? Theme.of(context).colorScheme.onSurface;
}

/// Preset flip-clock color themes the user can choose from, styled
/// after classic split-flap desk clocks and colorful clock widgets.
const List<FlipClockTheme> kFlipClockThemes = [
  FlipClockTheme(id: 'app_theme', name: 'App theme'),
  FlipClockTheme(
    id: 'classic',
    name: 'Classic',
    cardColor: Color(0xFF1C1C1E),
    textColor: Colors.white,
  ),
  FlipClockTheme(
    id: 'coral',
    name: 'Coral',
    cardColor: Color(0xFFE8735C),
    textColor: Colors.white,
  ),
  FlipClockTheme(
    id: 'navy',
    name: 'Navy',
    cardColor: Color(0xFF1B2A4A),
    textColor: Color(0xFFEAEAEA),
  ),
  FlipClockTheme(
    id: 'forest',
    name: 'Forest',
    cardColor: Color(0xFF2F4A3C),
    textColor: Colors.white,
  ),
  FlipClockTheme(
    id: 'sunset',
    name: 'Sunset',
    cardColor: Color(0xFFC9483C),
    textColor: Colors.white,
  ),
  FlipClockTheme(
    id: 'ocean',
    name: 'Ocean',
    cardColor: Color(0xFF2A6F77),
    textColor: Colors.white,
  ),
  FlipClockTheme(
    id: 'cream',
    name: 'Cream',
    cardColor: Color(0xFFF4E9DA),
    textColor: Color(0xFF3A2E24),
  ),
];

FlipClockTheme flipClockThemeById(String id) => kFlipClockThemes.firstWhere(
      (t) => t.id == id,
      orElse: () => kFlipClockThemes.first,
    );
