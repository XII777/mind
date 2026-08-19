#!/usr/bin/env bash
set -e
echo "Applying mechanical flip clock + theme picker..."
mkdir -p "lib/core/models"
cat > "lib/core/models/flip_clock_theme.dart" << 'CLOCKV2_EOF'
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
CLOCKV2_EOF
echo "  wrote lib/core/models/flip_clock_theme.dart"
mkdir -p "lib/providers/focus"
cat > "lib/providers/focus/flip_clock_theme_provider.dart" << 'CLOCKV2_EOF'
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
CLOCKV2_EOF
echo "  wrote lib/providers/focus/flip_clock_theme_provider.dart"
mkdir -p "lib/ui/screens/active_session"
cat > "lib/ui/screens/active_session/flip_clock_text.dart" << 'CLOCKV2_EOF'
/*
 *
 *  * Copyright (c) 2024 Mindful (https://github.com/akaMrNagar/Mindful)
 *  * Author : Pawan Nagar (https://github.com/akaMrNagar)
 *  *
 *  * This source code is licensed under the GPL-2.0 license license found in the
 *  * LICENSE file in the root directory of this source tree.
 *
 */

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mindful/core/models/flip_clock_theme.dart';

/// A single split-flap "flip clock" digit card, styled after classic
/// mechanical departure-board / desk flip clocks: rounded card, a
/// visible center hinge with a small gear notch, and subtle top/bottom
/// shading for depth.
class _FlipDigitCard extends StatefulWidget {
  const _FlipDigitCard({
    required this.digit,
    required this.fontSize,
    required this.cardColor,
    required this.textColor,
  });

  final String digit;
  final double fontSize;
  final Color cardColor;
  final Color textColor;

  @override
  State<_FlipDigitCard> createState() => _FlipDigitCardState();
}

class _FlipDigitCardState extends State<_FlipDigitCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  String _oldDigit = '';
  String _newDigit = '';

  @override
  void initState() {
    super.initState();
    _oldDigit = widget.digit;
    _newDigit = widget.digit;
  }

  @override
  void didUpdateWidget(covariant _FlipDigitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.digit != widget.digit) {
      _oldDigit = oldWidget.digit;
      _newDigit = widget.digit;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _cardWidth => widget.fontSize * 0.8;
  double get _cardHeight => widget.fontSize * 0.66;
  double get _radius => widget.fontSize * 0.09;

  BorderRadius _halfRadius(bool isTop) => BorderRadius.vertical(
        top: isTop ? Radius.circular(_radius) : Radius.zero,
        bottom: isTop ? Radius.zero : Radius.circular(_radius),
      );

  Widget _half({
    required String digit,
    required bool isTop,
    double shadeOpacity = 0,
  }) {
    return ClipRect(
      child: Align(
        alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
        heightFactor: 0.5,
        child: Container(
          width: _cardWidth,
          height: _cardHeight * 2,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.cardColor,
            borderRadius: _halfRadius(isTop),
            gradient: shadeOpacity > 0
                ? LinearGradient(
                    begin: isTop ? Alignment.topCenter : Alignment.bottomCenter,
                    end: isTop ? Alignment.bottomCenter : Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: shadeOpacity),
                      Colors.transparent,
                    ],
                  )
                : null,
          ),
          child: Text(
            digit,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w700,
              height: 1,
              color: widget.textColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }

  Widget _hingeNotch() {
    final dotSize = widget.fontSize * 0.09;
    return Center(
      child: Container(
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _cardWidth,
      height: _cardHeight,
      child: Stack(
        children: [
          /// Static bottom half (slightly shaded for depth)
          Positioned.fill(
            child: _half(digit: _newDigit, isTop: false, shadeOpacity: 0.08),
          ),

          /// Static top half showing the destination digit
          Positioned.fill(
            child: _half(digit: _newDigit, isTop: true),
          ),

          /// The animated flipping panel
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value;
              final isFirstHalf = t < 0.5;
              final angle = t * pi;

              return Positioned.fill(
                child: Transform(
                  alignment: Alignment.topCenter,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0025)
                    ..rotateX(angle),
                  child: isFirstHalf
                      ? _half(digit: _oldDigit, isTop: true)
                      : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateX(pi),
                          child: _half(
                            digit: _newDigit,
                            isTop: true,
                            shadeOpacity: 0.15,
                          ),
                        ),
                ),
              );
            },
          ),

          /// Center hinge line + gear-style notch, like the reference
          /// mechanical flip clock
          Positioned(
            top: _cardHeight / 2 - 0.5,
            left: 0,
            right: 0,
            child: Container(height: 1, color: Colors.black45),
          ),
          Positioned(
            top: _cardHeight / 2,
            left: 0,
            right: 0,
            child: _hingeNotch(),
          ),
        ],
      ),
    );
  }
}

/// A row of [_FlipDigitCard]s rendering HH:MM:SS (or MM:SS) in a classic
/// mechanical split-flap "flip clock" style, used on the active focus
/// session screen. Colors come from [theme] - pass the special
/// "App theme" preset (default) to have it automatically blend with the
/// app's current color scheme, or a fixed preset for a distinct look.
class FlipClockText extends StatelessWidget {
  const FlipClockText({
    super.key,
    required this.duration,
    required this.theme,
    this.fontSize = 48,
    this.alwaysShowMinutes = true,
  });

  final Duration duration;
  final FlipClockTheme theme;
  final double fontSize;
  final bool alwaysShowMinutes;

  @override
  Widget build(BuildContext context) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    final segments = <String>[];
    if (hours > 0) segments.add(hours.toString().padLeft(2, '0'));
    if (alwaysShowMinutes || hours > 0) {
      segments.add(minutes.toString().padLeft(2, '0'));
    }
    segments.add(seconds.toString().padLeft(2, '0'));

    final cardColor = theme.resolveCardColor(context);
    final textColor = theme.resolveTextColor(context);

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: fontSize * 0.12,
      children: [
        for (int s = 0; s < segments.length; s++) ...[
          if (s > 0)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: fontSize * 0.02),
              child: Text(
                ':',
                style: TextStyle(
                  fontSize: fontSize * 0.7,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          for (final char in segments[s].split(''))
            _FlipDigitCard(
              digit: char,
              fontSize: fontSize,
              cardColor: cardColor,
              textColor: textColor,
            ),
        ],
      ],
    );
  }
}
CLOCKV2_EOF
echo "  wrote lib/ui/screens/active_session/flip_clock_text.dart"
mkdir -p "lib/ui/screens/active_session"
cat > "lib/ui/screens/active_session/flip_clock_theme_picker.dart" << 'CLOCKV2_EOF'
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
CLOCKV2_EOF
echo "  wrote lib/ui/screens/active_session/flip_clock_theme_picker.dart"
mkdir -p "lib/ui/screens/active_session"
cat > "lib/ui/screens/active_session/active_session_screen.dart" << 'CLOCKV2_EOF'
/*
 *
 *  * Copyright (c) 2024 Mindful (https://github.com/akaMrNagar/Mindful)
 *  * Author : Pawan Nagar (https://github.com/akaMrNagar)
 *  *
 *  * This source code is licensed under the GPL-2.0 license license found in the
 *  * LICENSE file in the root directory of this source tree.
 *
 */

import 'dart:async';
import 'dart:math';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindful/config/navigation/app_routes.dart';
import 'package:mindful/core/database/app_database.dart';
import 'package:mindful/core/enums/session_type.dart';
import 'package:mindful/core/extensions/ext_build_context.dart';
import 'package:mindful/core/extensions/ext_duration.dart';
import 'package:mindful/core/extensions/ext_num.dart';
import 'package:mindful/core/extensions/ext_widget.dart';
import 'package:mindful/config/app_constants.dart';
import 'package:mindful/config/hero_tags.dart';
import 'package:mindful/providers/focus/focus_mode_provider.dart';
import 'package:mindful/ui/common/default_fab_button.dart';
import 'package:mindful/ui/common/scaffold_shell.dart';
import 'package:mindful/ui/common/styled_text.dart';
import 'package:mindful/ui/dialogs/confirmation_dialog.dart';
import 'package:mindful/ui/dialogs/input_field_dialog.dart';
import 'package:mindful/providers/focus/flip_clock_theme_provider.dart';
import 'package:mindful/ui/screens/active_session/flip_clock_text.dart';
import 'package:mindful/ui/screens/active_session/flip_clock_theme_picker.dart';
import 'package:mindful/ui/screens/active_session/sine_wave.dart';
import 'package:mindful/ui/screens/active_session/timer_progress_clock.dart';
import 'package:mindful/ui/transitions/default_hero.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sliver_tools/sliver_tools.dart';

class ActiveSessionScreen extends ConsumerStatefulWidget {
  const ActiveSessionScreen({super.key});

  @override
  ConsumerState<ActiveSessionScreen> createState() =>
      _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends ConsumerState<ActiveSessionScreen> {
  static const int _secondsInHour = 3600;
  bool _isCompleted = false;
  bool _isPoppingTriggered = false;

  @override
  void initState() {
    super.initState();

    /// Add a callback when the session will is completed successfully
    ref.read(focusModeProvider.notifier).setSessionSuccessCallback(
      () {
        if (!mounted) return;
        setState(() => _isCompleted = true);
        _launchConfetti();
      },
    );
  }

  /// This callback will be after a frame is rendered only when
  /// the active session provider is initialized and loaded successfully
  void _postFrameCallback(bool haveActiveSession) {
    if (haveActiveSession || _isCompleted || _isPoppingTriggered) return;
    _isPoppingTriggered = true;

    /// maybe first frame is rendering so call it after completion
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        context.showSnackAlert(
          context.locale.active_session_none_warning,
        );

        /// Let the snackbar appear then go back
        await Future.delayed(1.seconds);
        if (!mounted) return;

        /// Either go back if navigator can pop or go to home screen
        context.popOrPushReplace(AppRoutes.homePath);
      },
    );
  }

  List<String> _getQuotes(BuildContext context) => [
        context.locale.active_session_quote_one,
        context.locale.active_session_quote_two,
        context.locale.active_session_quote_three,
        context.locale.active_session_quote_four,
      ];

  double _getProgress(
    FocusSession? activeSession,
    bool isFinite,
    int elapsedSec,
  ) {
    /// Check if active session is null {may be loading}
    if (activeSession == null) return 0;

    if (isFinite) {
      return _isCompleted
          ? 100
          : 100 - ((elapsedSec / (activeSession.durationSecs)) * 100);
    } else {
      return ((elapsedSec % _secondsInHour) / _secondsInHour) * 100;
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Active session and Elapsed time in seconds
    final activeSession =
        ref.watch(focusModeProvider.select((v) => v.activeSession));

    final elapsedSeconds =
        ref.watch(focusModeProvider.select((v) => v.elapsedTimeSec));

    final sessionDurationSec = activeSession.value?.durationSecs ?? 0;

    /// Is the session finite means it does have any finite duration
    final isFinite = sessionDurationSec > 0;
    final progress =
        _getProgress(activeSession.value, isFinite, elapsedSeconds);

    final totalDuration = (isFinite
            ? _isCompleted
                ? sessionDurationSec
                : sessionDurationSec - elapsedSeconds
            : elapsedSeconds)
        .seconds;

    final quoteIndex = (progress / 25).floor() - 1;
    final quotes = _getQuotes(context);

    /// Add post frame callback after loading
    if (activeSession.hasValue) {
      _postFrameCallback(activeSession.value != null);
    }

    final enforceSession = ref
        .watch(focusModeProvider.select((v) => v.focusProfile.enforceSession));

    return Skeletonizer.zone(
      enabled: !activeSession.hasValue,
      ignorePointers: false,
      enableSwitchAnimation: true,
      child: ScaffoldShell(
        items: [
          NavbarItem(
            icon: FluentIcons.brain_circuit_20_regular,
            filledIcon: FluentIcons.brain_circuit_20_filled,
            actions: [
              /// Timer theme picker
              IconButton.filledTonal(
                icon: const Icon(FluentIcons.color_20_filled),
                onPressed: () => showFlipClockThemePicker(context),
              ),
              8.hBox,

              /// Goal or reflection
              _isCompleted || !activeSession.hasValue
                  ? 0.vBox
                  : DefaultHero(
                      tag: HeroTags.sessionReflectionTag(-1),
                      child: IconButton.filledTonal(
                        icon: const Icon(FluentIcons.clipboard_task_20_filled),
                        onPressed: _askAboutFocusReflection,
                      ),
                    ),
            ],
            titleBuilder: (percentage) =>
                _buildTitle(activeSession.value, percentage),
            fab: _isCompleted ||
                    !activeSession.hasValue ||
                    (enforceSession && isFinite)
                ? const SizedBox.shrink()
                : DefaultFabButton(
                    heroTag: HeroTags.giveUpOrFinishFocusSessionTag,
                    label: isFinite
                        ? context.locale.active_session_giveup_dialog_title
                        : context.locale.active_session_finish_dialog_title,
                    icon: isFinite
                        ? FluentIcons.emoji_sad_20_filled
                        : FluentIcons.emoji_surprise_20_filled,
                    onPressed: () => _giveUpOrFinishActiveSession(isFinite),
                  ),
            sliverBody: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                24.vSliverBox,

                /// Clock painter
                TimerProgressClock(
                  progress: progress.toDouble(),
                ).sliver,
                20.vSliverBox,

                /// Countdown timer
                FlipClockText(
                  duration: totalDuration,
                  theme: ref.watch(flipClockThemeProvider),
                ).sliver,
                40.vSliverBox,

                /// Motivation quote
                SliverAnimatedPaintExtent(
                  duration: AppConstants.defaultAnimDuration,
                  child: Skeleton.leaf(
                    child: StyledText(
                      _isCompleted
                          ? context.locale.active_session_quote_five(
                              totalDuration.toTimeFull(
                                context,
                                replaceCommaWithAnd: true,
                              ),
                            )
                          : quotes[max(quoteIndex, 0)],
                      fontSize: 14,
                      textAlign: TextAlign.center,
                    ),
                  ).centered.sliver,
                ),

                64.vSliverBox,

                /// Waves
                SineWave(
                  sinColor: Theme.of(context).colorScheme.primaryContainer,
                  cosColor: Theme.of(context).colorScheme.primary,
                ).sliver,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(FocusSession? session, double percentage) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Opacity(
          opacity: percentage,
          child: Icon(
            sessionTypeIcons[session?.type] ??
                FluentIcons.target_arrow_20_regular,
            size: 24 * percentage,
          ),
        ),
        2.vBox,
        AppBarTitle(
          titleText: sessionTypeLabels(context)[session?.type] ??
              context.locale.active_session_tab_title,
        )
      ],
    );
  }

  void _giveUpOrFinishActiveSession(bool isFinite) async {
    final confirm = await showConfirmationDialog(
      context: context,
      heroTag: HeroTags.giveUpOrFinishFocusSessionTag,
      title: isFinite
          ? context.locale.active_session_giveup_dialog_title
          : context.locale.active_session_finish_dialog_title,
      info: isFinite
          ? context.locale.active_session_giveup_dialog_info
          : context.locale.active_session_finish_dialog_info,
      icon: isFinite
          ? FluentIcons.emoji_sad_20_filled
          : FluentIcons.emoji_surprise_20_filled,
      positiveLabel: isFinite
          ? context.locale.active_session_giveup_dialog_title
          : context.locale.active_session_finish_dialog_title,
      negativeLabel: context.locale.active_session_dialog_button_keep_pushing,
    );

    if (!confirm) return;

    _isPoppingTriggered = true;
    await ref.read(focusModeProvider.notifier).giveUpOrFinishFocusSession(
          isTheSessionSuccessful: !isFinite,
          isFiniteSession: isFinite,
        );

    if (isFinite) {
      await Future.delayed(1.seconds);

      /// Show alert and go back
      if (!mounted) return;
      context.showSnackAlert(context.locale.active_session_giveup_snack_alert);
      Navigator.of(context).maybePop();
    } else {
      _launchConfetti();
    }
  }

  void _launchConfetti() {
    if (!mounted) return;

    final colors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.onSecondaryContainer,
    ];

    Confetti.launch(
      context,
      options: ConfettiOptions(
        particleCount: 100,
        scalar: 1.5,
        angle: 60,
        spread: 55,
        startVelocity: 60,
        gravity: 0.5,
        x: 0,
        y: 1,
        colors: colors,
      ),
      onFinished: (overlay) => overlay.remove(),
    );

    Confetti.launch(
      context,
      options: ConfettiOptions(
        particleCount: 100,
        scalar: 1.5,
        angle: 120,
        spread: 55,
        startVelocity: 60,
        gravity: 0.5,
        x: 1,
        y: 1,
        colors: colors,
      ),
      onFinished: (overlay) => overlay.remove(),
    );
  }

  void _askAboutFocusReflection() async {
    final reflection = await showFocusReflectionDialog(
      context: context,
      heroTag: HeroTags.sessionReflectionTag(-1),
      initialText: ref.read(focusModeProvider
              .select((v) => v.activeSession.value?.reflection)) ??
          "",
    );

    if (reflection == null) return;
    ref
        .read(focusModeProvider.notifier)
        .updateActiveSessionReflection(reflection);
  }
}
CLOCKV2_EOF
echo "  wrote lib/ui/screens/active_session/active_session_screen.dart"
echo ""
echo "Done. Git status:"
git status --short
