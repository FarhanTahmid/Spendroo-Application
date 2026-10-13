import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'database.steps.dart';

part 'database.g.dart';

// Column names match the server's sync rows one to one (bookName -> book_name),
// so the sync engine can copy rows in without per-table code. Timestamps and
// dates stay as the ISO text the server sends.

/// Columns every synced row carries.
mixin SyncColumns on Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text()();
  IntColumn get version => integer().withDefault(const Constant(0))();
  IntColumn get serverSeq => integer().withDefault(const Constant(0))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get deletedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// From the REST API, not the change log.
class Workspaces extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get kind => text()();
  TextColumn get defaultCurrency => text()();
  BoolColumn get isDemo => boolean().withDefault(const Constant(false))();
  TextColumn get role => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Cashbooks extends Table with SyncColumns {
  TextColumn get bookName => text()();
  TextColumn get description => text().nullable()();
  TextColumn get currency => text()();
}

class EntryCategories extends Table with SyncColumns {
  TextColumn get cashbookId => text()();
  TextColumn get categoryName => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  /// '#RRGGBB' the user chose; null leaves the colour to the app (categoryFill).
  TextColumn get color => text().nullable()();
}

class PaymentMethods extends Table with SyncColumns {
  TextColumn get cashbookId => text()();
  TextColumn get paymentMethodName => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
}

@TableIndex(name: 'entries_book_date', columns: {#cashbookId, #entryDate})
class Entries extends Table with SyncColumns {
  TextColumn get cashbookId => text()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get paymentMethodId => text().nullable()();
  TextColumn get entryType => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text()();
  TextColumn get title => text().nullable()();
  TextColumn get remarks => text().nullable()();
  TextColumn get entryDate => text()();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  TextColumn get createdById => text().nullable()();
}

class CashbookMembers extends Table with SyncColumns {
  TextColumn get cashbookId => text()();
  TextColumn get memberId => text()();
  TextColumn get role => text()();
}

class Accounts extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get kind => text()();
  TextColumn get currency => text()();
  IntColumn get openingBalanceMinor => integer().withDefault(const Constant(0))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}

class Categories extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get kind => text()();

  /// One of the categories every account starts with. Set by the server only;
  /// the plan's limit on categories counts the others.
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  /// '#RRGGBB' the user chose; null leaves the colour to the app (categoryFill).
  TextColumn get color => text().nullable()();
}

// The account screen reads an account newest first, a page at a time: the index
// holds the whole sort order, so a page is a range scan with nothing to sort
@TableIndex(name: 'transactions_account_feed', columns: {#accountId, #occurredOn, #createdAt, #id})
// Finds the other leg of a transfer
@TableIndex(name: 'transactions_transfer_group', columns: {#transferGroupId})
class Transactions extends Table with SyncColumns {
  TextColumn get accountId => text()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get kind => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text()();
  TextColumn get transferGroupId => text().nullable()();
  TextColumn get occurredOn => text()();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get source => text().withDefault(const Constant('manual'))();

  /// Filed under several categories at once: a JSON list of parts that add up
  /// to the amount (features/personal/allocations.dart). '[]' when not split.
  TextColumn get splits => text().withDefault(const Constant('[]'))();

  /// The occurrence of a recurring rule this transaction settles.
  TextColumn get occurrenceId => text().nullable()();
}

/// No month: the limit for every month. A month (yyyy-MM-01): that month only.
class Budgets extends Table with SyncColumns {
  TextColumn get categoryId => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text()();
  TextColumn get month => text().nullable()();
}

/// Local changes waiting to be pushed, oldest first.
/// Something that comes round again: a transaction to record, or a plain
/// reminder ([kind] 'reminder'). The server works out when each is due.
class RecurringRules extends Table with SyncColumns {
  TextColumn get kind => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get accountId => text().nullable()();
  TextColumn get toAccountId => text().nullable()();
  TextColumn get categoryId => text().nullable()();

  /// What the user typed, always positive; null for a reminder with no amount.
  IntColumn get amountMinor => integer().nullable()();
  TextColumn get currency => text().withDefault(const Constant(''))();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get splits => text().withDefault(const Constant('[]'))();

  /// once, daily, weekly, monthly or yearly, every [interval] of them.
  TextColumn get freq => text()();
  IntColumn get interval => integer().withDefault(const Constant(1))();

  /// Days of the week it falls on, Monday as bit 0.
  IntColumn get weekdayMask => integer().withDefault(const Constant(0))();

  /// 1-31, or -1 for the last day; a month too short uses its last day.
  IntColumn get monthDay => integer().nullable()();

  /// With [weekdayMask]: the first (1) to fourth (4) or last (-1) such day of the month.
  IntColumn get setPos => integer().nullable()();

  /// The day weeks start on when counting every [interval] weeks, Monday as 0.
  IntColumn get weekStart => integer().withDefault(const Constant(5))();
  TextColumn get startOn => text()();
  TextColumn get endOn => text().nullable()();
  IntColumn get maxCount => integer().nullable()();

  /// auto: the server records it. confirm: the user is asked first.
  TextColumn get mode => text().withDefault(const Constant('confirm'))();
  IntColumn get remindDaysBefore => integer().withDefault(const Constant(0))();

  /// HH:mm:ss in the user's own time; null uses their usual reminder time.
  TextColumn get remindAt => text().nullable()();
  BoolColumn get isPaused => boolean().withDefault(const Constant(false))();

  /// Set by the server.
  TextColumn get nextDueOn => text().nullable()();
  IntColumn get doneCount => integer().withDefault(const Constant(0))();
}

/// One date a rule falls on. Made by the server; the app only moves [status].
@TableIndex(name: 'recurring_occurrences_due', columns: {#workspaceId, #status, #dueOn})
class RecurringOccurrences extends Table with SyncColumns {
  TextColumn get ruleId => text()();
  TextColumn get dueOn => text()();

  /// upcoming, due, done or skipped.
  TextColumn get status => text()();
  TextColumn get snoozedUntil => text().nullable()();
}

/// What the reminders screen lists. Made by the server; the app only marks them read.
class InboxItems extends Table with SyncColumns {
  TextColumn get type => text()();

  /// JSON object the wording is filled from.
  TextColumn get params => text().withDefault(const Constant('{}'))();
  TextColumn get subjectTable => text().withDefault(const Constant(''))();
  TextColumn get subjectId => text().nullable()();
  TextColumn get dedupeKey => text().withDefault(const Constant(''))();
  TextColumn get readAt => text().nullable()();
  TextColumn get resolvedAt => text().nullable()();
}

class Outbox extends Table {
  IntColumn get seq => integer().autoIncrement()();
  TextColumn get mutationId => text()();
  TextColumn get workspaceId => text()();
  TextColumn get tableName_ => text().named('table_name')();
  TextColumn get op => text()();
  TextColumn get rowId => text()();

  /// JSON object of the columns this change set
  TextColumn get data => text()();
}

/// How far each workspace has been pulled.
class SyncCursors extends Table {
  TextColumn get workspaceId => text()();
  IntColumn get since => integer()();

  @override
  Set<Column> get primaryKey => {workspaceId};
}

/// Changes the server refused, shown to the user as "not synced".
class SyncFailures extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tableName_ => text().named('table_name')();
  TextColumn get rowId => text()();
  TextColumn get code => text()();
  TextColumn get detail => text()();
  TextColumn get createdAt => text()();
}

/// Set once the individual-or-business question is answered for the signed-in account.
const onboardedSettingKey = 'onboarded';

/// The onboarding answer ('personal' or 'business') until the server has it.
const onboardingUnsentKey = 'onboarding_unsent';

/// Server address chosen in Settings (test builds only); unset means AppConfig.apiUrl.
const serverUrlSettingKey = 'server_url';

/// The signed-in user's profile as JSON, so it shows offline.
const profileSettingKey = 'profile';

/// What the server last said the user's plan gives, as JSON, so it shows offline.
const entitlementsSettingKey = 'entitlements';

/// The server's marker for "plans or this user's plan changed", from the last sync.
const billingStampSettingKey = 'billing_stamp';

/// Offers closed on the home screen, as comma-separated slugs.
const offersDismissedSettingKey = 'offers_dismissed';

/// The locks the "choose what to keep" screen was last opened for, so it opens by itself once.
const keepPromptedSettingKey = 'keep_prompted';

/// Small per-device settings: language, theme, selected workspace.
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [
  Workspaces, Cashbooks, EntryCategories, PaymentMethods, Entries, CashbookMembers,
  Accounts, Categories, Transactions, Budgets, RecurringRules, RecurringOccurrences, InboxItems,
  Outbox, SyncCursors, SyncFailures, Settings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'spendroo'));

  // Every change: bump this, run `dart run drift_dev make-migrations`, add the
  // step below. The generated tests in test/drift/ check each step.
  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: stepByStep(
          from1To2: (m, schema) async {
            await m.addColumn(schema.budgets, schema.budgets.month);
          },
          from2To3: (m, schema) async {
            await m.addColumn(schema.categories, schema.categories.isDefault);
            // Rows already on the phone were pulled without the marker: pull them again
            await customStatement('DELETE FROM sync_cursors');
          },
          from3To4: (m, schema) async {
            await m.addColumn(schema.categories, schema.categories.color);
            await m.addColumn(schema.entryCategories, schema.entryCategories.color);
            // A colour chosen on another device may have been pulled without its column: pull again
            await customStatement('DELETE FROM sync_cursors');
          },
          from4To5: (m, schema) async {
            // transactions_account_feed starts with the same two columns
            await customStatement('DROP INDEX IF EXISTS transactions_account_date');
            await m.createIndex(schema.transactionsAccountFeed);
            await m.createIndex(schema.transactionsTransferGroup);
          },
          from5To6: (m, schema) async {
            await m.addColumn(schema.transactions, schema.transactions.splits);
            await m.addColumn(schema.transactions, schema.transactions.occurrenceId);
            await m.createTable(schema.recurringRules);
            await m.createTable(schema.recurringOccurrences);
            await m.createIndex(schema.recurringOccurrencesDue);
            await m.createTable(schema.inboxItems);
            // A split made on another device may have been pulled without its column: pull again
            await customStatement('DELETE FROM sync_cursors');
          },
        ),
      );

  /// Synced tables in the order rows must be applied: parents before children.
  static const syncedTables = [
    'cashbooks', 'entry_categories', 'payment_methods', 'entries', 'cashbook_members',
    'accounts', 'categories', 'recurring_rules', 'recurring_occurrences', 'transactions', 'budgets',
    'inbox_items',
  ];

  TableInfo<Table, dynamic> tableByName(String name) => allTables.firstWhere((t) => t.actualTableName == name);

  /// Signing out or switching account: nothing of the previous user stays on the device.
  Future<void> wipe() => transaction(() async {
        for (final table in allTables) {
          if (table.actualTableName != 'settings') await delete(table).go();
        }
      });

  Future<String?> getSetting(String key) async =>
      (await (select(settings)..where((s) => s.key.equals(key))).getSingleOrNull())?.value;

  Future<void> setSetting(String key, String? value) async {
    if (value == null) {
      await (delete(settings)..where((s) => s.key.equals(key))).go();
    } else {
      await into(settings).insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));
    }
  }
}
