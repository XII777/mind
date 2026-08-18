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
