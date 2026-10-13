import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/db/local_store.dart';
import '../../core/entitlements/entitlements.dart';
import '../../core/entitlements/entitlements_controller.dart';
import '../../core/entitlements/plan_guard.dart';
import '../../core/providers.dart';
import '../personal/ledger_repository.dart';
import 'goal_math.dart';

const goalActive = 'active';
const goalReached = 'reached';
const goalArchived = 'archived';

/// A goal with what is in it now.
class GoalView {
  GoalView(this.goal, this.savedMinor, {this.lastInOn});

  final SavingsGoal goal;

  /// The balance of the goal's account: everything put in, less what was taken out.
  final int savedMinor;

  /// The day money last went in; null before the first time.
  final DateTime? lastInOn;

  DateTime get createdOn => dayOf(DateTime.parse(goal.createdAt));
  DateTime? get targetOn => goal.targetOn == null ? null : DateTime.parse(goal.targetOn!);
  bool get isArchived => goal.status == goalArchived;

  GoalProgress progressOn(DateTime today) => GoalProgress.of(
        savedMinor: savedMinor,
        targetMinor: goal.targetMinor,
        createdOn: createdOn,
        today: today,
        targetOn: targetOn,
      );
}

/// Savings goals. Each keeps its money in an account of its own (kind
/// 'goal'): putting money in or taking it out is a transfer, so the account
/// it came from shows less to spend and nothing is counted twice.
class GoalsRepository {
  GoalsRepository(this.db, this.store, this.ledger, [this.plan]);

  final AppDatabase db;
  final LocalStore store;
  final LedgerRepository ledger;
  final PlanGuard? plan;

  static const _select = 'SELECT g.*, COALESCE(SUM(t.amount_minor), 0) AS saved, '
      'MAX(CASE WHEN t.amount_minor > 0 THEN t.occurred_on END) AS last_in FROM savings_goals g '
      'LEFT JOIN transactions t ON t.account_id = g.account_id AND t.deleted_at IS NULL ';

  GoalView _view(QueryRow row) {
    final lastIn = row.readNullable<String>('last_in');
    return GoalView(
      db.savingsGoals.map(row.data),
      row.read<int>('saved'),
      lastInOn: lastIn == null ? null : DateTime.parse(lastIn),
    );
  }

  /// Every goal of the workspace, oldest first, archived ones included.
  Stream<List<GoalView>> watchGoals(String workspaceId) => db
      .customSelect(
        '$_select WHERE g.workspace_id = ? AND g.deleted_at IS NULL GROUP BY g.id ORDER BY g.created_at',
        variables: [Variable<String>(workspaceId)],
        readsFrom: {db.savingsGoals, db.transactions},
      )
      .watch()
      .map((rows) => rows.map(_view).toList());

  Stream<GoalView?> watchGoal(String goalId) => db
      .customSelect(
        '$_select WHERE g.id = ? AND g.deleted_at IS NULL GROUP BY g.id',
        variables: [Variable<String>(goalId)],
        readsFrom: {db.savingsGoals, db.transactions},
      )
      .watchSingleOrNull()
      .map((row) => row == null ? null : _view(row));

  static const _moves = 'SELECT t.*, g.id AS goal_id, o.account_id AS other_id, a.name AS other_name '
      'FROM savings_goals g '
      'JOIN transactions t ON t.account_id = g.account_id AND t.deleted_at IS NULL '
      'LEFT JOIN transactions o ON o.transfer_group_id = t.transfer_group_id AND o.id <> t.id '
      'AND o.deleted_at IS NULL '
      'LEFT JOIN accounts a ON a.id = o.account_id ';

  GoalMove _move(QueryRow row) => GoalMove(
        id: row.read<String>('id'),
        day: DateTime.parse(row.read<String>('occurred_on')),
        amountMinor: row.read<int>('amount_minor'),
        otherAccountId: row.readNullable<String>('other_id'),
        otherAccountName: row.readNullable<String>('other_name'),
        note: row.read<String>('note'),
        source: row.read<String>('source'),
        transferGroupId: row.readNullable<String>('transfer_group_id'),
      );

  /// Money in and out of the goal, newest first, each with the account on the other side.
  Stream<List<GoalMove>> watchMoves(String goalId) => db
      .customSelect(
        '$_moves WHERE g.id = ? ORDER BY t.occurred_on DESC, t.created_at DESC',
        variables: [Variable<String>(goalId)],
        readsFrom: {db.savingsGoals, db.transactions, db.accounts},
      )
      .watch()
      .map((rows) => rows.map(_move).toList());

  /// Every goal's moves in the workspace at once, by goal id, for the list and its insights.
  Stream<Map<String, List<GoalMove>>> watchAllMoves(String workspaceId) => db
      .customSelect(
        '$_moves WHERE g.workspace_id = ? AND g.deleted_at IS NULL ORDER BY t.occurred_on DESC, t.created_at DESC',
        variables: [Variable<String>(workspaceId)],
        readsFrom: {db.savingsGoals, db.transactions, db.accounts},
      )
      .watch()
      .map((rows) {
    final byGoal = <String, List<GoalMove>>{};
    for (final row in rows) {
      byGoal.putIfAbsent(row.read<String>('goal_id'), () => []).add(_move(row));
    }
    return byGoal;
  });

  /// Goals some recurring rule puts money into, by goal id.
  Stream<Set<String>> watchAutoSaved(String workspaceId) => db
      .customSelect(
        'SELECT DISTINCT g.id AS goal_id FROM savings_goals g JOIN recurring_rules r ON r.to_account_id = g.account_id '
        "AND r.deleted_at IS NULL AND r.is_paused = 0 AND r.kind = 'transfer' WHERE g.workspace_id = ?",
        variables: [Variable<String>(workspaceId)],
        readsFrom: {db.savingsGoals, db.recurringRules},
      )
      .watch()
      .map((rows) => {for (final row in rows) row.read<String>('goal_id')});

  /// Days with income in the last [days], for "your best saving day is payday".
  Future<List<DateTime>> incomeDays(String workspaceId, {int days = 120}) async {
    final since = isoDate(DateTime.now().subtract(Duration(days: days)));
    final rows = await db
        .customSelect(
          "SELECT DISTINCT occurred_on FROM transactions WHERE workspace_id = ? AND kind = 'income' "
          'AND deleted_at IS NULL AND occurred_on >= ?',
          variables: [Variable<String>(workspaceId), Variable<String>(since)],
          readsFrom: {db.transactions},
        )
        .get();
    return [for (final row in rows) DateTime.parse(row.read<String>('occurred_on'))];
  }

  /// The account a goal keeps its money in.
  Future<Account> accountOf(SavingsGoal goal) =>
      (db.select(db.accounts)..where((a) => a.id.equals(goal.accountId))).getSingle();

  /// Makes the goal and its account together; the account goes to the server first.
  Future<String> createGoal(
    String workspaceId, {
    required String name,
    required int targetMinor,
    required String currency,
    String? targetOn,
    String icon = '',
    String? color,
  }) async {
    await plan?.roomFor(F.savingsGoals, workspaceId);
    return db.transaction(() async {
      final accountId = await store.create('accounts', workspaceId, {
        'name': name,
        'kind': goalAccountKind,
        'currency': currency,
        'opening_balance_minor': 0,
        'is_archived': false,
      });
      return store.create(
        'savings_goals',
        workspaceId,
        {
          'account_id': accountId,
          'name': name,
          'target_minor': targetMinor,
          'target_on': targetOn,
          'icon': icon,
          'color': color,
          'status': goalActive,
        },
        localOnly: {'currency': currency, 'milestones_hit': 0},
      );
    });
  }

  /// Sends only what changed. The account keeps the goal's name, so a transfer reads the same anywhere.
  Future<void> updateGoal(
    SavingsGoal original, {
    required String name,
    required int targetMinor,
    required String? targetOn,
    required String icon,
    required String? color,
  }) async {
    plan?.writable(F.savingsGoals, original.id);
    await db.transaction(() async {
      await store.update('savings_goals', original.id, {
        if (name != original.name) 'name': name,
        if (targetMinor != original.targetMinor) 'target_minor': targetMinor,
        if (targetOn != original.targetOn) 'target_on': targetOn,
        if (icon != original.icon) 'icon': icon,
        if (color != original.color) 'color': color,
      });
      if (name != original.name) await store.update('accounts', original.accountId, {'name': name});
    });
  }

  /// Archived goals do not count toward the plan's limit; bringing one back needs room like a new one.
  Future<void> setArchived(SavingsGoal goal, bool archived) async {
    if (!archived) await plan?.roomFor(F.savingsGoals, goal.workspaceId);
    // The server works out again whether a goal brought back is reached
    await store.update('savings_goals', goal.id, {'status': archived ? goalArchived : goalActive});
  }

  /// Puts money aside: a transfer from [from] into the goal.
  Future<void> contribute(SavingsGoal goal, Account from, {
    required int amountMinor,
    required String occurredOn,
    String note = '',
  }) async {
    // A goal a downgrade locked takes nothing more; taking money out always works
    plan?.writable(F.savingsGoals, goal.id);
    await ledger.addTransfer(from, await accountOf(goal), amountMinor: amountMinor, occurredOn: occurredOn, note: note);
  }

  /// Takes money out of the goal into [to], where it can be spent.
  Future<void> withdraw(SavingsGoal goal, Account to, {
    required int amountMinor,
    required String occurredOn,
    String note = '',
  }) async {
    await ledger.addTransfer(await accountOf(goal), to, amountMinor: amountMinor, occurredOn: occurredOn, note: note);
  }

  /// Only an empty goal can go: money in it is taken out first, so none is lost from sight.
  Future<void> deleteGoal(GoalView view) async {
    if (view.savedMinor != 0) throw StateError('A goal with money in it cannot be deleted.');
    await db.transaction(() async {
      await store.remove('savings_goals', view.goal.id);
      await store.remove('accounts', view.goal.accountId);
    });
  }
}

/// The kind of account a goal's money sits in; never one to spend from.
const goalAccountKind = 'goal';

final goalsRepositoryProvider = Provider<GoalsRepository>(
  (ref) => GoalsRepository(
    ref.watch(databaseProvider),
    ref.watch(localStoreProvider),
    ref.watch(ledgerRepositoryProvider),
    ref.watch(planGuardProvider),
  ),
);

final goalsProvider = StreamProvider.family<List<GoalView>, String>(
  (ref, workspaceId) => ref.watch(goalsRepositoryProvider).watchGoals(workspaceId),
);

final goalProvider = StreamProvider.family<GoalView?, String>(
  (ref, goalId) => ref.watch(goalsRepositoryProvider).watchGoal(goalId),
);

final goalMovesProvider = StreamProvider.family<List<GoalMove>, String>(
  (ref, goalId) => ref.watch(goalsRepositoryProvider).watchMoves(goalId),
);

final allGoalMovesProvider = StreamProvider.family<Map<String, List<GoalMove>>, String>(
  (ref, workspaceId) => ref.watch(goalsRepositoryProvider).watchAllMoves(workspaceId),
);

final autoSavedGoalsProvider = StreamProvider.family<Set<String>, String>(
  (ref, workspaceId) => ref.watch(goalsRepositoryProvider).watchAutoSaved(workspaceId),
);

final incomeDaysProvider = FutureProvider.autoDispose.family<List<DateTime>, String>(
  (ref, workspaceId) => ref.watch(goalsRepositoryProvider).incomeDays(workspaceId),
);
