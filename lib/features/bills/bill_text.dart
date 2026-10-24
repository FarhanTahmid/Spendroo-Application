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

/// The words for one kind of attached file: bills on a business entry,
/// receipts on a personal expense or income. Everything else about them is the same.
class BillWording {
  const BillWording(this.l10n, {required this.receipt});

  final AppLocalizations l10n;
  final bool receipt;

  String get title => receipt ? l10n.receipts : l10n.bills;
  String get hint => receipt ? l10n.receiptsHint : l10n.billsHint;
  String get attach => receipt ? l10n.receiptAttach : l10n.billAttach;
  String get remove => receipt ? l10n.receiptRemove : l10n.billRemove;
  String get removeConfirm => receipt ? l10n.receiptRemoveConfirm : l10n.billRemoveConfirm;
  String get removed => receipt ? l10n.receiptRemoved : l10n.billRemoved;
  String get added => receipt ? l10n.receiptAdded : l10n.billAdded;
  String get openOffline => receipt ? l10n.receiptOpenOffline : l10n.billOpenOffline;
  String get gone => receipt ? l10n.receiptGone : l10n.billGone;
  String get openFailed => receipt ? l10n.receiptOpenFailed : l10n.billOpenFailed;
  String get errorGeneric => receipt ? l10n.receiptErrorGeneric : l10n.billErrorGeneric;
  String perFile(String size) => receipt ? l10n.receiptPerFile(size) : l10n.billPerFile(size);
  String count(int count) => receipt ? l10n.receiptCount(count) : l10n.billCount(count);

  /// Why a file could not be attached, from the code the server (or the phone) gave.
  String error(String? code) => switch (code) {
        'bill_type' => l10n.billErrorType,
        'bill_unsafe' => l10n.billErrorUnsafe,
        'bill_corrupt' => l10n.billErrorCorrupt,
        'bill_too_large' => l10n.billErrorTooLarge,
        'bill_forbidden' => receipt ? l10n.receiptErrorForbidden : l10n.billErrorForbidden,
        'bill_gone' => receipt ? l10n.receiptErrorGone : l10n.billErrorGone,
        'receipt_not_allowed' => l10n.receiptErrorNotAllowed,
        BillOutbox.missing => l10n.billErrorMissing,
        _ => errorGeneric,
      };
}
