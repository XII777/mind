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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindful/core/models/flip_clock_theme.dart';
import 'package:path_provider/path_provider.dart';

/// Stores which [FlipClockTheme] the user picked for the focus session
/// timer, persisted locally (not in the main Drift DB, to avoid a
/// schema migration for this small standalone preference).
final flipClockThemeProvider =
    StateNotifierProvider<FlipClockThemeNotifier, FlipClockTheme>(
  (ref) => FlipClockThemeNotifier(),
);

class FlipClockThemeNotifier extends StateNotifier<FlipClockTheme> {
  bool _loaded = false;

  FlipClockThemeNotifier() : super(kFlipClockThemes.first) {
    _init();
  }

  Future<File> _storageFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/flip_clock_theme.json');
  }

  Future<void> _init() async {
    try {
      final file = await _storageFile();
      if (await file.exists()) {
        final raw = await file.readAsString();
        final id = (jsonDecode(raw) as Map<String, dynamic>)['themeId'] as String?;
        if (id != null) state = flipClockThemeById(id);
      }
    } catch (_) {
      state = kFlipClockThemes.first;
    }
    _loaded = true;
  }

  Future<void> setTheme(FlipClockTheme theme) async {
    state = theme;
    if (!_loaded) return;
    try {
      final file = await _storageFile();
      await file.writeAsString(jsonEncode({'themeId': theme.id}));
    } catch (_) {
      /// Best-effort persistence; ignore write failures.
    }
  }
}
