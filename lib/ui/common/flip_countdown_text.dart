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
import 'package:mindful/ui/common/mechanical_flip_clock.dart';

class FlipCountdownText extends StatelessWidget {
  const FlipCountdownText({
    super.key,
    required this.duration,
    this.alwaysShowMinutes = true,
  });

  final Duration duration;
  final bool alwaysShowMinutes;

  @override
  Widget build(BuildContext context) {
    return MechanicalFlipClock(
      duration: duration,
    );
  }
}
