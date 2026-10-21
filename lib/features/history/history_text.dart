import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../../core/ui.dart';
import '../cashbook/access_page.dart' show accessLabel;
import '../cashbook/book_access.dart';
import '../fields/field_text.dart';
import '../team/team_roles.dart';
import 'history_repository.dart';

/// Who made [event]: "You", their name, or the app itself when nobody did.
String actorName(BuildContext context, HistoryEvent event, String? me) {
  final actor = event.actor;
  if (actor == null) return context.l10n.historyNobody;
  return actor.id == me ? context.l10n.you : actor.displayName;
}

/// What happened, without who: "Edited an entry", "Gave Rahim access".
String historySentence(BuildContext context, HistoryEvent event) {
  final l10n = context.l10n;
  final name = event.subject.isEmpty ? l10n.historySomeone : event.subject;
  return switch ((event.kind, event.action)) {
    (HistoryKind.entry, HistoryAction.created) => l10n.historyEntryCreated,
    (HistoryKind.entry, HistoryAction.deleted) => l10n.historyEntryDeleted,
    (HistoryKind.entry, HistoryAction.restored) => l10n.historyEntryRestored,
    (HistoryKind.entry, _) => l10n.historyEntryUpdated,
    (HistoryKind.cashbook, HistoryAction.created) => l10n.historyCashbookCreated,
    (HistoryKind.cashbook, HistoryAction.deleted) => l10n.historyCashbookDeleted,
    (HistoryKind.cashbook, HistoryAction.restored) => l10n.historyCashbookRestored,
    (HistoryKind.cashbook, _) => l10n.historyCashbookUpdated,
    (HistoryKind.category, HistoryAction.created) => l10n.historyCategoryCreated,
    (HistoryKind.category, HistoryAction.deleted) => l10n.historyCategoryDeleted,
    (HistoryKind.category, HistoryAction.restored) => l10n.historyCategoryRestored,
    (HistoryKind.category, _) => l10n.historyCategoryUpdated,
    (HistoryKind.paymentMethod, HistoryAction.created) => l10n.historyMethodCreated,
    (HistoryKind.paymentMethod, HistoryAction.deleted) => l10n.historyMethodDeleted,
    (HistoryKind.paymentMethod, HistoryAction.restored) => l10n.historyMethodRestored,
    (HistoryKind.paymentMethod, _) => l10n.historyMethodUpdated,
    (HistoryKind.field, HistoryAction.created) => l10n.historyFieldCreated,
    (HistoryKind.field, HistoryAction.deleted) => l10n.historyFieldDeleted,
    (HistoryKind.field, HistoryAction.restored) => l10n.historyFieldRestored,
    (HistoryKind.field, _) => l10n.historyFieldUpdated,
    (HistoryKind.access, HistoryAction.created || HistoryAction.restored) => l10n.historyAccessGiven(name),
    (HistoryKind.access, HistoryAction.deleted) => l10n.historyAccessTaken(name),
    (HistoryKind.access, _) => l10n.historyAccessChanged(name),
    (HistoryKind.member, HistoryAction.created || HistoryAction.restored) => l10n.historyMemberJoined(name),
    (HistoryKind.member, HistoryAction.deleted) => l10n.historyMemberLeft(name),
    (HistoryKind.member, _) => l10n.historyMemberRole(name),
    _ => l10n.historyChanged,
  };
}

/// The thing itself, under the sentence: an entry's title, a book's name, or
/// the access or role a person has after the change (the sentence names them).
String? historySubject(BuildContext context, HistoryEvent event) {
  if (event.kind == HistoryKind.access || event.kind == HistoryKind.member) {
    // The access or role they were left with; nothing once it is gone
    final role = event.role;
    if (role == null || event.action == HistoryAction.deleted) return null;
    return event.kind == HistoryKind.access ? accessLabel(context, BookAccess.fromGrant(role)) : roleLabel(context, role);
  }
  if (event.subject.isNotEmpty) return event.subject;
  if (event.kind == HistoryKind.entry) {
    return event.entryType == 'cash_in' ? context.l10n.cashIn : context.l10n.cashOut;
  }
  return null;
}

/// An entry's amount as it stands after the change.
String? historyAmount(BuildContext context, HistoryEvent event) {
  final amount = event.amountMinor;
  if (event.kind != HistoryKind.entry || amount == null) return null;
  return Money.format(amount, event.currency ?? 'BDT', locale: context.languageCode);
}

String fieldLabel(BuildContext context, HistoryEvent event, FieldChange change) {
  final l10n = context.l10n;
  return switch (change.field) {
    // The business's own name for it, as written
    FieldChange.customValue => change.name ?? l10n.fieldsTitle,
    'amount_minor' => l10n.historyFieldAmount,
    'entry_type' => l10n.historyFieldType,
    'entry_date' => l10n.historyFieldDate,
    'title' => l10n.historyFieldTitle,
    'remarks' => l10n.historyFieldNote,
    'merchant' => l10n.party,
    'tags' => l10n.tags,
    'category' => l10n.historyFieldCategory,
    'payment_method' => l10n.historyFieldMethod,
    'book_name' || 'category_name' || 'payment_method_name' || 'name' => l10n.historyFieldName,
    'options' => l10n.fieldOptions,
    'required' => l10n.fieldRequired,
    'show_in_list' => l10n.fieldShowInList,
    'description' => l10n.historyFieldDescription,
    'currency' => l10n.historyFieldCurrency,
    'color' => l10n.historyFieldColour,
    'role' => event.kind == HistoryKind.access ? l10n.historyFieldAccess : l10n.historyFieldRole,
    _ => change.field,
  };
}

/// A field's value in words; null when it was empty.
String? fieldValue(BuildContext context, HistoryEvent event, FieldChange change, Object? value) {
  if (value == null || value == '') return null;
  final l10n = context.l10n;
  return switch (change.field) {
    FieldChange.customValue when value is String => fieldDisplay(context, change.kind ?? '', value),
    // The server sends tags by name; none left reads as empty
    'options' || 'tags' when value is List => value.isEmpty ? null : value.join(', '),
    'required' || 'show_in_list' when value is bool => value ? l10n.yes : l10n.no,
    'amount_minor' when value is num =>
      Money.format(value.toInt(), event.currency ?? 'BDT', locale: context.languageCode),
    'entry_type' => value == 'cash_in' ? l10n.cashIn : l10n.cashOut,
    'entry_date' when value is String && DateTime.tryParse(value) != null => formatDate(context, value),
    'role' when event.kind == HistoryKind.access => accessLabel(context, BookAccess.fromGrant('$value')),
    'role' => roleLabel(context, '$value'),
    _ => '$value',
  };
}

/// A colour field holds a hex code; it is shown as a swatch as well.
Color? fieldSwatch(String field, Object? value) {
  if (field != 'color' || value is! String || !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(value)) return null;
  return Color(int.parse('FF${value.substring(1)}', radix: 16));
}

/// The fields a change touched, named: "Amount, Category".
String changedFields(BuildContext context, HistoryEvent event) =>
    event.changes.map((change) => fieldLabel(context, event, change)).toSet().join(', ');

/// "3:45 PM" in the user's own clock.
String historyTime(BuildContext context, DateTime at) =>
    MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(at), alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context));

/// "Today", "Yesterday", or the date, over a day's changes.
String historyDay(BuildContext context, DateTime day) {
  final iso = '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
  return friendlyDate(context, iso);
}

/// The colour and mark of what happened.
(IconData, Color) actionLook(BuildContext context, String action) {
  final colors = context.colors;
  return switch (action) {
    HistoryAction.created => (Icons.add_rounded, colors.moneyIn),
    HistoryAction.deleted => (Icons.delete_outline_rounded, colors.moneyOut),
    HistoryAction.restored => (Icons.restore_rounded, colors.mint),
    _ => (Icons.edit_rounded, Theme.of(context).colorScheme.primary),
  };
}

/// What kind of thing the change was made to.
IconData kindIcon(String kind) => switch (kind) {
      HistoryKind.entry => Icons.receipt_long_outlined,
      HistoryKind.cashbook => Icons.menu_book_outlined,
      HistoryKind.category => Icons.sell_outlined,
      HistoryKind.paymentMethod => Icons.account_balance_wallet_outlined,
      HistoryKind.field => Icons.dashboard_customize_outlined,
      HistoryKind.access => Icons.key_outlined,
      _ => Icons.group_outlined,
    };
