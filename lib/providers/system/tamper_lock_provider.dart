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
import 'package:path_provider/path_provider.dart';

/// Immutable snapshot of the tamper-protection lock state.
class TamperLockState {
  const TamperLockState({
    required this.lockDurationDays,
    required this.lockStartedAt,
  });

  /// How many days the lock stays active for, counted from
  /// [lockStartedAt]. A value of 0 means "no lock" (feature effectively
  /// disabled - tamper protection can be turned off any time).
  final int lockDurationDays;

  /// When the current lock period began, or null if tamper protection
  /// hasn't been enabled with a lock yet.
  final DateTime? lockStartedAt;

  /// The exact moment the current lock period ends, or null if no lock
  /// is active.
  DateTime? get lockEndsAt => lockStartedAt == null
      ? null
      : lockStartedAt!.add(Duration(days: lockDurationDays));

  /// True while the set number of days has not yet passed since the
  /// lock started. While true, tamper protection cannot be disabled.
  bool get isLocked {
    if (lockDurationDays <= 0 || lockStartedAt == null) return false;
    final endsAt = lockEndsAt!;
    return DateTime.now().isBefore(endsAt);
  }

  TamperLockState copyWith({
    int? lockDurationDays,
    DateTime? lockStartedAt,
    bool clearStart = false,
  }) {
    return TamperLockState(
      lockDurationDays: lockDurationDays ?? this.lockDurationDays,
      lockStartedAt: clearStart ? null : (lockStartedAt ?? this.lockStartedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'lockDurationDays': lockDurationDays,
        'lockStartedAt': lockStartedAt?.toIso8601String(),
      };

  factory TamperLockState.fromJson(Map<String, dynamic> json) {
    return TamperLockState(
      lockDurationDays: json['lockDurationDays'] as int? ?? 0,
      lockStartedAt: json['lockStartedAt'] != null
          ? DateTime.tryParse(json['lockStartedAt'] as String)
          : null,
    );
  }

  static const initial = TamperLockState(
    lockDurationDays: 7,
    lockStartedAt: null,
  );
}

/// Manages the tamper-protection time lock: once tamper protection
/// (device admin) is enabled, it can be locked for a configurable
/// number of days during which it cannot be disabled or the app
/// uninstalled through normal means. After that window passes, it
/// unlocks automatically.
///
/// Persisted to a small JSON file (not the Drift DB) to avoid schema
/// migrations for this standalone feature.
final tamperLockProvider =
    StateNotifierProvider<TamperLockNotifier, TamperLockState>(
  (ref) => TamperLockNotifier(),
);

class TamperLockNotifier extends StateNotifier<TamperLockState> {
  bool _loaded = false;

  TamperLockNotifier() : super(TamperLockState.initial) {
    _init();
  }

  Future<File> _storageFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/tamper_lock_state.json');
  }

  Future<void> _init() async {
    try {
      final file = await _storageFile();
      if (await file.exists()) {
        final raw = await file.readAsString();
        state = TamperLockState.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      }
    } catch (_) {
      /// Corrupted/unreadable file — fall back to defaults.
      state = TamperLockState.initial;
    }
    _loaded = true;
  }

  Future<void> _persist() async {
    if (!_loaded) return;
    try {
      final file = await _storageFile();
      await file.writeAsString(jsonEncode(state.toJson()));
    } catch (_) {
      /// Best-effort persistence; ignore write failures.
    }
  }

  /// Sets how many days a newly-started lock period should last. Can
  /// only be changed while no lock is currently active, so the active
  /// countdown can't be shortened or bypassed mid-way.
  Future<bool> setLockDurationDays(int days) async {
    if (state.isLocked) return false;
    state = state.copyWith(lockDurationDays: days);
    await _persist();
    return true;
  }

  /// Starts (or restarts) the lock countdown from now, using the
  /// currently configured [TamperLockState.lockDurationDays]. Call this
  /// when tamper protection / device admin is freshly enabled.
  Future<void> startLock() async {
    if (state.lockDurationDays <= 0) return;
    state = state.copyWith(lockStartedAt: DateTime.now());
    await _persist();
  }

  /// Clears the lock entirely (e.g. after tamper protection is
  /// legitimately disabled once the window has passed).
  Future<void> clearLock() async {
    state = state.copyWith(clearStart: true);
    await _persist();
  }
}
