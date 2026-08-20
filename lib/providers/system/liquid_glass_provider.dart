import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// StateNotifier to manage Liquid Glass toggle state persistently in memory
final liquidGlassSettingProvider =
    StateNotifierProvider<LiquidGlassSettingNotifier, bool>(
  (ref) => LiquidGlassSettingNotifier(),
);

class LiquidGlassSettingNotifier extends StateNotifier<bool> {
  LiquidGlassSettingNotifier() : super(false);

  void toggle() => state = !state;
}
