/*
 *
 *  * Copyright (c) 2024 Mindful (https://github.com/akaMrNagar/Mindful)
 *  * Author : Pawan Nagar (https://github.com/akaMrNagar)
 *  *
 *  * This source code is licensed under the GPL-2.0 license license found in the
 *  * LICENSE file in the root directory of this source tree.
 *
 */

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindful/providers/system/mindful_settings_provider.dart';

/// Floating Glass Navigation Bar supporting default Frosted Glass and optional Liquid Glass material.
class FloatingGlassNavBar extends ConsumerStatefulWidget {
  const FloatingGlassNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<FloatingGlassDestination> destinations;

  @override
  ConsumerState<FloatingGlassNavBar> createState() => _FloatingGlassNavBarState();
}

class FloatingGlassDestination {
  final Widget icon;
  final Widget selectedIcon;
  final String label;

  const FloatingGlassDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class _FloatingGlassNavBarState extends ConsumerState<FloatingGlassNavBar> {
  int? _pressedIndex;

  @override
  Widget build(BuildContext context) {
    // Read user setting for Liquid Glass (Default: false -> Frosted Glass)
    final useLiquidGlass = ref.watch(
      mindfulSettingsProvider.select((v) => v.useLiquidGlass),
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(useLiquidGlass ? 0.35 : 0.15),
              blurRadius: useLiquidGlass ? 24 : 16,
              offset: const Offset(0, 8),
              spreadRadius: useLiquidGlass ? 2 : 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: useLiquidGlass ? 25 : 15,
              sigmaY: useLiquidGlass ? 25 : 15,
            ),
            child: CustomPaint(
              painter: _GlassBorderPainter(
                isLiquid: useLiquidGlass,
                isDark: isDark,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  color: useLiquidGlass
                      ? (isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.white.withOpacity(0.35))
                      : (isDark
                          ? Theme.of(context).colorScheme.surfaceContainerHigh.withOpacity(0.75)
                          : Colors.white.withOpacity(0.65)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(widget.destinations.length, (index) {
                    final isSelected = index == widget.selectedIndex;
                    final dest = widget.destinations[index];
                    final isPressed = _pressedIndex == index;

                    return GestureDetector(
                      onTapDown: (_) => setState(() => _pressedIndex = index),
                      onTapUp: (_) => setState(() => _pressedIndex = null),
                      onTapCancel: () => setState(() => _pressedIndex = null),
                      onTap: () => widget.onDestinationSelected(index),
                      child: AnimatedScale(
                        scale: isPressed ? 0.92 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOutCubic,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: isSelected
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: useLiquidGlass
                                      ? (isDark
                                          ? Colors.white.withOpacity(0.20)
                                          : Colors.white.withOpacity(0.60))
                                      : Theme.of(context).colorScheme.primaryContainer,
                                  boxShadow: useLiquidGlass
                                      ? [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, -1),
                                          ),
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 6,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                  border: useLiquidGlass
                                      ? Border.all(
                                          color: Colors.white.withOpacity(0.4),
                                          width: 1.2,
                                        )
                                      : null,
                                )
                              : null,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              isSelected ? dest.selectedIcon : dest.icon,
                              if (isSelected) ...[
                                const SizedBox(width: 8),
                                Text(
                                  dest.label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: useLiquidGlass
                                        ? Theme.of(context).colorScheme.onSurface
                                        : Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter rendering rim lighting, specular highlight, and lens refraction edge for Liquid Glass.
class _GlassBorderPainter extends CustomPainter {
  final bool isLiquid;
  final bool isDark;

  _GlassBorderPainter({required this.isLiquid, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    val rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(32));

    if (!isLiquid) {
      // Default Frosted Glass: Simple subtle rim border
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = isDark
            ? Colors.white.withOpacity(0.12)
            : Colors.black.withOpacity(0.08);
      canvas.drawRRect(rrect, borderPaint);
      return;
    }

    // Liquid Glass: Layered rim lighting & specular highlight
    final upperHighlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.75),
          Colors.white.withOpacity(0.20),
          Colors.black.withOpacity(0.15),
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(rect);

    canvas.drawRRect(rrect, upperHighlightPaint);

    // Inner refractive lens bevel
    final innerBevelRRect = RRect.fromRectAndRadius(
      rect.deflate(2.0),
      const Radius.circular(30),
    );
    final innerBevelPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withOpacity(0.25);

    canvas.drawRRect(innerBevelRRect, innerBevelPaint);
  }

  @override
  bool shouldRepaint(covariant _GlassBorderPainter oldDelegate) {
    return oldDelegate.isLiquid != isLiquid || oldDelegate.isDark != isDark;
  }
}
