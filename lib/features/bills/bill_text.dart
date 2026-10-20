import 'package:intl/intl.dart';

import '../../core/sync/bill_outbox.dart';
import '../../l10n/app_localizations.dart';

const megabyte = 1024 * 1024;

/// "740 KB", "3.2 MB", "10 GB", in the user's digits.
String formatBytes(int bytes, String language) {
  final format = NumberFormat.decimalPatternDigits(locale: language, decimalDigits: 1);
  String trimmed(double value) => format.format(value).replaceAll(RegExp(r'[.,]0$'), '');
  if (bytes <= 0) return '${NumberFormat.decimalPattern(language).format(0)} KB';
  // Under a megabyte the tenths say nothing
  if (bytes < 1024 * 1024) return '${NumberFormat.decimalPattern(language).format((bytes / 1024).ceil().clamp(1, 1023))} KB';
  if (bytes < 1024 * megabyte) return '${trimmed(bytes / megabyte)} MB';
  return '${trimmed(bytes / (1024 * megabyte))} GB';
}

/// A plan's allowance in megabytes, as a size: 2048 MB reads "2 GB".
String formatMegabytes(int megabytes, String language) => formatBytes(megabytes * megabyte, language);

/// Why a bill could not be attached, from the code the server (or the phone) gave.
String billErrorText(AppLocalizations l10n, String? code) => switch (code) {
      'bill_type' => l10n.billErrorType,
      'bill_unsafe' => l10n.billErrorUnsafe,
      'bill_corrupt' => l10n.billErrorCorrupt,
      'bill_too_large' => l10n.billErrorTooLarge,
      'bill_forbidden' => l10n.billErrorForbidden,
      'bill_gone' => l10n.billErrorGone,
      BillOutbox.missing => l10n.billErrorMissing,
      _ => l10n.billErrorGeneric,
    };
