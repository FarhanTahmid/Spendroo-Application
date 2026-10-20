import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/entitlements/entitlements.dart';
import '../../core/entitlements/entitlements_controller.dart';
import '../../core/providers.dart';
import '../team/team_repository.dart' show initialsOf;

/// What a change was made to.
abstract final class HistoryKind {
  static const entry = 'entry';
  static const cashbook = 'cashbook';
  static const category = 'category';
  static const paymentMethod = 'payment_method';

  /// One of a book's own fields (features/fields).
  static const field = 'field';
  static const access = 'access';
  static const member = 'member';
}

/// What happened to it.
abstract final class HistoryAction {
  static const created = 'created';
  static const updated = 'updated';
  static const deleted = 'deleted';
  static const restored = 'restored';
}

/// Whoever made a change, members who have since left included.
class HistoryActor {
  const HistoryActor({required this.id, required this.email, this.name = ''});

  factory HistoryActor.fromJson(Map<String, dynamic> json) => HistoryActor(
        id: '${json['id']}',
        email: json['email'] as String? ?? '',
        name: (json['name'] as String? ?? '').trim(),
      );

  final String id;
  final String email;
  final String name;

  String get displayName => name.isEmpty ? email : name;
  String get initials => initialsOf(displayName);
}

/// One field of a change: what it was, and what it became. Links (a
/// category, a payment method) come as names.
class FieldChange {
  const FieldChange(this.field, this.before, this.after, {this.name, this.kind});

  factory FieldChange.fromJson(Map<String, dynamic> json) => FieldChange(
        json['field'] as String? ?? '',
        json['before'],
        json['after'],
        name: json['name'] as String?,
        kind: json['kind'] as String?,
      );

  /// A column of the row, or [customValue] for one of the book's own fields.
  final String field;
  final Object? before;
  final Object? after;

  /// For [customValue]: the field's name as the business wrote it, and its kind.
  final String? name;
  final String? kind;

  static const customValue = 'custom_value';
}

/// One change in a business, as the owner sees it in the edit history.
class HistoryEvent {
  const HistoryEvent({
    required this.id,
    required this.at,
    required this.kind,
    required this.action,
    required this.objectId,
    this.cashbookId,
    this.cashbookName = '',
    this.actor,
    this.subject = '',
    this.changes = const [],
    this.amountMinor,
    this.currency,
    this.entryType,
    this.role,
  });

  factory HistoryEvent.fromJson(Map<String, dynamic> json) {
    final book = json['cashbook'];
    final actor = json['actor'];
    return HistoryEvent(
      id: json['id'] as String,
      at: (DateTime.tryParse(json['at'] as String? ?? '') ?? DateTime.now()).toLocal(),
      kind: json['kind'] as String? ?? HistoryKind.entry,
      action: json['action'] as String? ?? HistoryAction.updated,
      objectId: json['object_id'] as String? ?? '',
      cashbookId: book is Map ? book['id'] as String? : null,
      cashbookName: book is Map ? book['name'] as String? ?? '' : '',
      actor: actor is Map ? HistoryActor.fromJson(actor.cast<String, dynamic>()) : null,
      subject: json['subject'] as String? ?? '',
      changes: [
        for (final change in json['changes'] as List? ?? const [])
          if (change is Map) FieldChange.fromJson(change.cast<String, dynamic>()),
      ],
      amountMinor: (json['amount_minor'] as num?)?.toInt(),
      currency: json['currency'] as String?,
      entryType: json['entry_type'] as String?,
      role: json['role'] as String?,
    );
  }

  final String id;
  final DateTime at;
  final String kind;
  final String action;
  final String objectId;
  final String? cashbookId;
  final String cashbookName;

  /// Null when nobody made it: a script, or the admin.
  final HistoryActor? actor;

  /// What it was made to: an entry's title, a cashbook's or category's name,
  /// the person given access or a role.
  final String subject;
  final List<FieldChange> changes;

  /// An entry's amount and type after this change.
  final int? amountMinor;
  final String? currency;
  final String? entryType;

  /// Access and members: the role after this change.
  final String? role;

  /// The local day it happened, for grouping.
  DateTime get day => DateTime(at.year, at.month, at.day);
}

/// What the history is narrowed to. Days are the owner's own, both ends included.
class HistoryFilter {
  const HistoryFilter({this.cashbookId, this.personId, this.entryId, this.from, this.to});

  final String? cashbookId;

  /// A user id: whose changes.
  final String? personId;

  /// One entry's story; the other filters do not apply then.
  final String? entryId;
  final DateTime? from;
  final DateTime? to;

  HistoryFilter copyWith({
    String? Function()? cashbookId,
    String? Function()? personId,
    ({DateTime from, DateTime to})? Function()? range,
  }) {
    final days = range?.call();
    return HistoryFilter(
      cashbookId: cashbookId == null ? this.cashbookId : cashbookId(),
      personId: personId == null ? this.personId : personId(),
      entryId: entryId,
      from: range == null ? from : days?.from,
      to: range == null ? to : days?.to,
    );
  }

  /// How many of the filters an owner can clear are in force.
  int get count => [cashbookId, personId, from].where((value) => value != null).length;

  bool get isNarrowed => count > 0;

  HistoryFilter cleared() => HistoryFilter(entryId: entryId);

  /// The query the server takes: days become moments where the owner is.
  Map<String, String> get query => {
        if (entryId != null) 'entry': entryId!,
        if (entryId == null && cashbookId != null) 'cashbook': cashbookId!,
        if (entryId == null && personId != null) 'person': personId!,
        if (entryId == null && from != null) 'from': DateTime(from!.year, from!.month, from!.day).toUtc().toIso8601String(),
        if (entryId == null && to != null) 'to': DateTime(to!.year, to!.month, to!.day + 1).toUtc().toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      other is HistoryFilter &&
      other.cashbookId == cashbookId &&
      other.personId == personId &&
      other.entryId == entryId &&
      other.from == from &&
      other.to == to;

  @override
  int get hashCode => Object.hash(cashbookId, personId, entryId, from, to);
}

/// A page of the history; [next] is null on the last.
class HistoryChunk {
  const HistoryChunk(this.events, this.next);

  final List<HistoryEvent> events;
  final String? next;
}

/// Why a page did not come.
enum HistoryProblem {
  offline,

  /// Not the owner (any more), or not a business.
  refused,

  /// The owner's plan has no edit history.
  locked,
  failed,
}

/// The history lives only on the server, so it needs a connection. The
/// owner alone may read it, on a plan with [F.auditTrail].
class HistoryRepository {
  HistoryRepository(this.ref);

  final Ref ref;

  static const pageSize = 30;

  ApiClient get _api => ref.read(apiClientProvider);

  Future<(HistoryChunk?, HistoryProblem?)> page(String workspaceId, HistoryFilter filter, {String? cursor}) async {
    try {
      final response = await _api.get('/api/v1/workspaces/$workspaceId/history/', query: {
        ...filter.query,
        'limit': '$pageSize',
        if (cursor != null) 'cursor': cursor,
      });
      if (response.ok && response.body is Map) {
        final body = response.json;
        return (
          HistoryChunk(
            [
              for (final row in body['results'] as List? ?? const [])
                if (row is Map) HistoryEvent.fromJson(row.cast<String, dynamic>()),
            ],
            body['next'] as String?,
          ),
          null,
        );
      }
      if (response.statusCode == 402) {
        // The phone's copy of the plan was out of date
        ref.read(entitlementsProvider.notifier).refresh();
        return (null, HistoryProblem.locked);
      }
      if (response.statusCode == 400 || response.statusCode == 403 || response.statusCode == 404) {
        return (null, HistoryProblem.refused);
      }
      return (null, HistoryProblem.failed);
    } on OfflineException {
      return (null, HistoryProblem.offline);
    }
  }
}

final historyRepositoryProvider = Provider<HistoryRepository>(HistoryRepository.new);

/// The history so far for one filter. [loadMore] adds the next page.
class HistoryFeed {
  const HistoryFeed({
    this.events = const [],
    this.next,
    this.loading = true,
    this.loadingMore = false,
    this.problem,
    this.moreFailed = false,
  });

  final List<HistoryEvent> events;
  final String? next;

  /// Nothing read yet.
  final bool loading;
  final bool loadingMore;

  /// Why the first page did not come; null once it has.
  final HistoryProblem? problem;

  /// A later page did not come; the ones shown stay.
  final bool moreFailed;

  bool get hasMore => next != null;

  HistoryFeed copyWith({
    List<HistoryEvent>? events,
    String? Function()? next,
    bool? loading,
    bool? loadingMore,
    HistoryProblem? Function()? problem,
    bool? moreFailed,
  }) =>
      HistoryFeed(
        events: events ?? this.events,
        next: next == null ? this.next : next(),
        loading: loading ?? this.loading,
        loadingMore: loadingMore ?? this.loadingMore,
        problem: problem == null ? this.problem : problem(),
        moreFailed: moreFailed ?? this.moreFailed,
      );
}

typedef HistoryQuery = ({String workspaceId, HistoryFilter filter});

class HistoryFeedController extends Notifier<HistoryFeed> {
  HistoryFeedController(this.query);

  final HistoryQuery query;

  int _generation = 0;
  bool _busy = false;

  @override
  HistoryFeed build() {
    // An upgrade or downgrade changes what the server answers
    ref.watch(entitlementsProvider.select((value) => value.value?.can(F.auditTrail)));
    _generation++;
    _busy = false;
    Future.microtask(refresh);
    return const HistoryFeed();
  }

  HistoryRepository get _repo => ref.read(historyRepositoryProvider);

  /// Reads the first page again. What is shown stays until it arrives.
  Future<void> refresh() async {
    final generation = ++_generation;
    _busy = true;
    try {
      final (page, problem) = await _repo.page(query.workspaceId, query.filter);
      if (generation != _generation || !ref.mounted) return;
      state = page == null
          ? HistoryFeed(events: state.events, next: state.next, loading: false, problem: problem)
          : HistoryFeed(events: page.events, next: page.next, loading: false);
    } finally {
      if (generation == _generation) _busy = false;
    }
  }

  Future<void> loadMore() async {
    if (_busy || !state.hasMore || state.problem != null) return;
    _busy = true;
    final generation = _generation;
    state = state.copyWith(loadingMore: true, moreFailed: false);
    try {
      final (page, _) = await _repo.page(query.workspaceId, query.filter, cursor: state.next);
      if (generation != _generation || !ref.mounted) return;
      state = page == null
          ? state.copyWith(loadingMore: false, moreFailed: true)
          : state.copyWith(events: [...state.events, ...page.events], next: () => page.next, loadingMore: false);
    } finally {
      if (generation == _generation) _busy = false;
    }
  }
}

final historyFeedProvider =
    NotifierProvider.autoDispose.family<HistoryFeedController, HistoryFeed, HistoryQuery>(HistoryFeedController.new);
