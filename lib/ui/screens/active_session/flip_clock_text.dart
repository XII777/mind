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
