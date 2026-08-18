#!/usr/bin/env bash
set -e
echo "Applying flip-clock style + fullscreen orientation support..."
mkdir -p "lib/ui/screens/active_session"
cat > "lib/ui/screens/active_session/flip_clock_text.dart" << 'FLIP_EOF'
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

/// A single split-flap "flip clock" digit card, mimicking the classic
/// mechanical departure-board flip animation: the old digit's top half
/// rotates down through the hinge to reveal the new digit.
class _FlipDigitCard extends StatefulWidget {
  const _FlipDigitCard({
    required this.digit,
    required this.fontSize,
  });

  final String digit;
  final double fontSize;

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

  Widget _half({
    required String digit,
    required bool isTop,
    required Color background,
    required Color foreground,
  }) {
    final cardWidth = widget.fontSize * 0.78;
    final cardHeight = widget.fontSize * 0.62;

    return ClipRect(
      child: Align(
        alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
        heightFactor: 0.5,
        child: Container(
          width: cardWidth,
          height: cardHeight * 2,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            digit,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.bold,
              height: 1,
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = widget.fontSize * 0.78;
    final cardHeight = widget.fontSize * 0.62;
    final scheme = Theme.of(context).colorScheme;
    final cardColor = scheme.surfaceContainerHigh;
    final textColor = scheme.onSurface;

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Stack(
        children: [
          /// Static bottom half already showing the destination digit
          Positioned.fill(
            child: _half(
              digit: _newDigit,
              isTop: false,
              background: cardColor,
              foreground: textColor,
            ),
          ),

          /// Static top half showing the destination digit (revealed as
          /// the flipping panel rotates away)
          Positioned.fill(
            child: _half(
              digit: _newDigit,
              isTop: true,
              background: cardColor,
              foreground: textColor,
            ),
          ),

          /// The animated flipping panel: starts as the old digit's top
          /// half at rotationX 0, rotates down through 90° (edge-on) to
          /// 180°, at which point it shows the new digit mirrored back
          /// to readable via a second rotation.
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
                      ? _half(
                          digit: _oldDigit,
                          isTop: true,
                          background: cardColor,
                          foreground: textColor,
                        )
                      : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateX(pi),
                          child: _half(
                            digit: _newDigit,
                            isTop: true,
                            background: cardColor,
                            foreground: textColor,
                          ),
                        ),
                ),
              );
            },
          ),

          /// Center hinge line for the classic split-flap look
          Positioned(
            top: cardHeight / 2 - 0.5,
            left: 0,
            right: 0,
            child: Container(height: 1, color: Colors.black26),
          ),
        ],
      ),
    );
  }
}

/// A row of [_FlipDigitCard]s rendering HH:MM:SS (or MM:SS) in a classic
/// mechanical split-flap "flip clock" style, used on the active focus
/// session screen.
class FlipClockText extends StatelessWidget {
  const FlipClockText({
    super.key,
    required this.duration,
    this.fontSize = 48,
    this.alwaysShowMinutes = true,
  });

  final Duration duration;
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
                ),
              ),
            ),
          for (final char in segments[s].split(''))
            _FlipDigitCard(digit: char, fontSize: fontSize),
        ],
      ],
    );
  }
}
FLIP_EOF
echo "  wrote lib/ui/screens/active_session/flip_clock_text.dart"
mkdir -p "lib/ui/screens/active_session"
cat > "lib/ui/screens/active_session/active_session_screen.dart" << 'FLIP_EOF'
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
import 'package:flutter/services.dart';
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
import 'package:mindful/ui/screens/active_session/flip_clock_text.dart';
import 'package:mindful/ui/common/scaffold_shell.dart';
import 'package:mindful/ui/common/styled_text.dart';
import 'package:mindful/ui/dialogs/confirmation_dialog.dart';
import 'package:mindful/ui/dialogs/input_field_dialog.dart';
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
  bool _isFullscreen = false;

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

  @override
  void dispose() {
    /// Always restore normal system UI when leaving this screen, even
    /// if fullscreen was left on.
    if (_isFullscreen) _setSystemUiFullscreen(false);
    super.dispose();
  }

  void _setSystemUiFullscreen(bool enabled) {
    if (enabled) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top],
      );
    }
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    _setSystemUiFullscreen(_isFullscreen);
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
              /// Fullscreen toggle
              IconButton.filledTonal(
                icon: Icon(
                  _isFullscreen
                      ? FluentIcons.full_screen_minimize_20_filled
                      : FluentIcons.full_screen_maximize_20_filled,
                ),
                onPressed: _toggleFullscreen,
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
            sliverBody: _buildBody(
              context,
              progress: progress,
              totalDuration: totalDuration,
              quoteIndex: quoteIndex,
              quotes: quotes,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the session body, switching between a vertically-stacked
  /// layout (portrait) and a side-by-side layout (landscape) so the
  /// screen makes good use of space in both orientations, including
  /// while fullscreen.
  Widget _buildBody(
    BuildContext context, {
    required double progress,
    required Duration totalDuration,
    required int quoteIndex,
    required List<String> quotes,
  }) {
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    final quoteWidget = SliverAnimatedPaintExtent(
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
    );

    if (!isLandscape) {
      /// Portrait: original vertically-stacked scroll view
      return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          24.vSliverBox,
          TimerProgressClock(progress: progress).sliver,
          20.vSliverBox,
          FlipClockText(duration: totalDuration).sliver,
          40.vSliverBox,
          quoteWidget,
          64.vSliverBox,
          SineWave(
            sinColor: Theme.of(context).colorScheme.primaryContainer,
            cosColor: Theme.of(context).colorScheme.primary,
          ).sliver,
        ],
      );
    }

    /// Landscape: clock on the left, timer + quote on the right, side
    /// by side, so the content isn't cramped vertically. Waves are
    /// dropped in landscape to keep everything visible without
    /// scrolling on shorter screens.
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              TimerProgressClock(
                progress: progress,
                dimension: 150,
              ),
              24.hBox,
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FlipClockText(duration: totalDuration, fontSize: 36),
                    20.vBox,
                    Skeleton.leaf(
                      child: StyledText(
                        _isCompleted
                            ? context.locale.active_session_quote_five(
                                totalDuration.toTimeFull(
                                  context,
                                  replaceCommaWithAnd: true,
                                ),
                              )
                            : quotes[max(quoteIndex, 0)],
                        fontSize: 13,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
FLIP_EOF
echo "  wrote lib/ui/screens/active_session/active_session_screen.dart"
echo ""
echo "Done. Git status:"
git status --short
