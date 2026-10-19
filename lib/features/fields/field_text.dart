import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/money.dart';
import '../../core/ui.dart';
import 'field_repository.dart';

String kindLabel(BuildContext context, String kind) {
  final l10n = context.l10n;
  return switch (kind) {
    FieldKind.number => l10n.fieldKindNumber,
    FieldKind.date => l10n.fieldKindDate,
    FieldKind.choice => l10n.fieldKindChoice,
    _ => l10n.fieldKindText,
  };
}

String kindHint(BuildContext context, String kind) {
  final l10n = context.l10n;
  return switch (kind) {
    FieldKind.number => l10n.fieldKindNumberHint,
    FieldKind.date => l10n.fieldKindDateHint,
    FieldKind.choice => l10n.fieldKindChoiceHint,
    _ => l10n.fieldKindTextHint,
  };
}

IconData kindIcon(String kind) => switch (kind) {
      FieldKind.number => Icons.tag_rounded,
      FieldKind.date => Icons.event_outlined,
      FieldKind.choice => Icons.checklist_rounded,
      _ => Icons.short_text_rounded,
    };

/// Each kind its own colour, so a list of fields reads at a glance.
Color kindTint(BuildContext context, String kind) => switch (kind) {
      FieldKind.number => const Color(0xFF2F80ED),
      FieldKind.date => const Color(0xFFE07A1F),
      FieldKind.choice => const Color(0xFF8E5BD8),
      _ => const Color(0xFF12A594),
    };

/// A value as people read it: dates in words, numbers grouped, Bangla digits
/// in Bangla. A value that no longer parses is shown as it was kept.
String fieldDisplay(BuildContext context, String kind, String value) {
  final bangla = context.languageCode.startsWith('bn');
  switch (kind) {
    case FieldKind.date when DateTime.tryParse(value) != null:
      return formatDate(context, value);
    case FieldKind.number:
      final match = RegExp(r'^(-?)(\d+)(?:\.(\d+))?$').firstMatch(value);
      if (match == null) return value;
      final whole = NumberFormat.decimalPattern(bangla ? 'bn' : 'en_US').format(int.parse(match[2]!));
      final fraction = match[3] == null ? '' : '.${bangla ? Money.toBengaliDigits(match[3]!) : match[3]}';
      return '${match[1]}$whole$fraction';
    default:
      return value;
  }
}
