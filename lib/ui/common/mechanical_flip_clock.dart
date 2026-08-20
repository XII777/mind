/*
 *
 *  * Copyright (c) 2024 Mindful (https://github.com/akaMrNagar/Mindful)
 *  * Author : Pawan Nagar (https://github.com/akaMrNagar)
 *  *
 *  * This source code is licensed under the GPL-2.0 license license found in the
 *  * LICENSE file in the root directory of this source tree.
 *
 */

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A 3D mechanical split-flap flip digit widget.
class MechanicalFlipDigit extends StatefulWidget {
  const MechanicalFlipDigit({
    super.key,
    required this.digit,
    this.width = 54.0,
    this.height = 84.0,
  });

  final int digit;
  final double width;
  final double height;

  @override
  State<MechanicalFlipDigit> createState() => _MechanicalFlipDigitState();
}

class _MechanicalFlipDigitState extends State<MechanicalFlipDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentDigit = 0;
  int _nextDigit = 0;

  @override
  void initState() {
    super.initState();
    _currentDigit = widget.digit;
    _nextDigit = widget.digit;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentDigit = _nextDigit;
          _controller.reset();
        });
      }
    });
  }

  @override
  void didUpdateWidget(MechanicalFlipDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.digit != widget.digit) {
      _nextDigit = widget.digit;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;

        if (value == 0.0) {
          return _buildCardPanel(
            digit: _currentDigit,
            width: widget.width,
            height: widget.height,
          );
        }

        final topFlipAngle = value <= 0.5 ? value * math.pi : math.pi / 2;
        final bottomFlipAngle = value > 0.5 ? (value - 0.5) * math.pi : 0.0;

        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            children: [
              // 1. Base top half (New digit top)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: widget.height / 2,
                child: _buildHalfCard(
                  digit: _nextDigit,
                  isTop: true,
                  width: widget.width,
                  height: widget.height,
                ),
              ),

              // 2. Base bottom half (Old digit bottom)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: widget.height / 2,
                child: _buildHalfCard(
                  digit: value > 0.5 ? _nextDigit : _currentDigit,
                  isTop: false,
                  width: widget.width,
                  height: widget.height,
                ),
              ),

              // 3. Flipping top half (Old digit top rotating down)
              if (value <= 0.5)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: widget.height / 2,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.002)
                      ..rotateX(-topFlipAngle),
                    alignment: Alignment.bottomCenter,
                    child: _buildHalfCard(
                      digit: _currentDigit,
                      isTop: true,
                      width: widget.width,
                      height: widget.height,
                    ),
                  ),
                ),

              // 4. Flipping bottom half (New digit bottom rotating into place)
              if (value > 0.5)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: widget.height / 2,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.002)
                      ..rotateX(math.pi / 2 - bottomFlipAngle),
                    alignment: Alignment.topCenter,
                    child: _buildHalfCard(
                      digit: _nextDigit,
                      isTop: false,
                      width: widget.width,
                      height: widget.height,
                    ),
                  ),
                ),

              // 5. Center horizontal divider seam
              Center(
                child: Container(
                  height: 2,
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardPanel({
    required int digit,
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C22),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '$digit',
              style: TextStyle(
                fontSize: height * 0.68,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.95),
                fontFamily: 'monospace',
              ),
            ),
          ),
          Center(
            child: Container(
              height: 2,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHalfCard({
    required int digit,
    required bool isTop,
    required double width,
    required double height,
  }) {
    return ClipRect(
      child: Container(
        width: width,
        height: height / 2,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C22),
          borderRadius: BorderRadius.vertical(
            top: isTop ? const Radius.circular(8) : Radius.zero,
            bottom: !isTop ? const Radius.circular(8) : Radius.zero,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: OverflowBox(
          maxHeight: height,
          alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
          child: SizedBox(
            height: height,
            width: width,
            child: Center(
              child: Text(
                '$digit',
                style: TextStyle(
                  fontSize: height * 0.68,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.95),
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A complete Mechanical Flip Clock row showing HH:MM:SS or MM:SS
class MechanicalFlipClock extends StatelessWidget {
  const MechanicalFlipClock({
    super.key,
    required this.duration,
    this.digitWidth = 54.0,
    this.digitHeight = 84.0,
  });

  final Duration duration;
  final double digitWidth;
  final double digitHeight;

  @override
  Widget build(BuildContext context) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    final showHours = hours > 0;

    final h1 = hours ~/ 10;
    final h2 = hours % 10;
    final m1 = minutes ~/ 10;
    final m2 = minutes % 10;
    final s1 = seconds ~/ 10;
    final s2 = seconds % 10;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showHours) ...[
          MechanicalFlipDigit(digit: h1, width: digitWidth, height: digitHeight),
          const SizedBox(width: 4),
          MechanicalFlipDigit(digit: h2, width: digitWidth, height: digitHeight),
          _buildColon(digitHeight),
        ],
        MechanicalFlipDigit(digit: m1, width: digitWidth, height: digitHeight),
        const SizedBox(width: 4),
        MechanicalFlipDigit(digit: m2, width: digitWidth, height: digitHeight),
        _buildColon(digitHeight),
        MechanicalFlipDigit(digit: s1, width: digitWidth, height: digitHeight),
        const SizedBox(width: 4),
        MechanicalFlipDigit(digit: s2, width: digitWidth, height: digitHeight),
      ],
    );
  }

  Widget _buildColon(double height) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white70,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white70,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
