/*
 *
 *  * Copyright (c) 2024 Mindful (https://github.com/akaMrNagar/Mindful)
 *  * Author : Pawan Nagar (https://github.com/akaMrNagar)
 *  *
 *  * This source code is licensed under the GPL-2.0 license license found in the
 *  * LICENSE file in the root directory of this source tree.
 *
 */

/// A single imported hosts list "category" (e.g. "Adult content",
/// "Gambling") shown in the UI as one toggle instead of a per-domain
/// list. Toggling [enabled] blocks/unblocks every domain in [domains]
/// at once.
class ImportedHostsList {
  const ImportedHostsList({
    required this.id,
    required this.name,
    required this.sourceLabel,
    required this.domains,
    required this.enabled,
    required this.isNsfw,
  });

  /// Stable identifier, e.g. derived from the source URL or file name.
  final String id;

  /// Display name, e.g. "Adult content (porn)".
  final String name;

  /// Short description of where this list came from, e.g. the URL or
  /// "Imported from device".
  final String sourceLabel;

  /// All domains belonging to this list.
  final List<String> domains;

  /// Whether this list's domains are currently being enforced/blocked.
  final bool enabled;

  /// Whether this list belongs to the NSFW category. NSFW lists are
  /// always locked on (cannot be disabled) once imported, matching the
  /// rest of the app's "NSFW entries are permanent" behavior.
  final bool isNsfw;

  ImportedHostsList copyWith({
    String? id,
    String? name,
    String? sourceLabel,
    List<String>? domains,
    bool? enabled,
    bool? isNsfw,
  }) {
    return ImportedHostsList(
      id: id ?? this.id,
      name: name ?? this.name,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      domains: domains ?? this.domains,
      enabled: enabled ?? this.enabled,
      isNsfw: isNsfw ?? this.isNsfw,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sourceLabel': sourceLabel,
        'domains': domains,
        'enabled': enabled,
        'isNsfw': isNsfw,
      };

  factory ImportedHostsList.fromJson(Map<String, dynamic> json) {
    return ImportedHostsList(
      id: json['id'] as String,
      name: json['name'] as String,
      sourceLabel: json['sourceLabel'] as String? ?? '',
      domains: (json['domains'] as List<dynamic>).cast<String>(),
      enabled: json['enabled'] as bool? ?? true,
      isNsfw: json['isNsfw'] as bool? ?? false,
    );
  }
}
