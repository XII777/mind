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
import 'package:flutter/services.dart';

/// Shows a dialog to pick the number of days tamper protection stays
/// locked (cannot be disabled) once enabled. Returns the picked value,
/// or null if cancelled.
Future<int?> showTamperLockDurationDialog({
  required BuildContext context,
  required int initialDays,
}) async {
  final controller = TextEditingController(text: initialDays.toString());

  return showDialog<int>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Tamper protection lock'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Once tamper protection is enabled, it cannot be disabled '
            'and the app cannot be uninstalled for this many days. '
            'Set to 0 to disable this lock.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Lock duration (days)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final days = int.tryParse(controller.text.trim()) ?? 0;
            Navigator.of(dialogContext).pop(days);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
