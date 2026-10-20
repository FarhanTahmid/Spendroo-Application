import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/entitlements/entitlements.dart';
import '../../core/entitlements/entitlements_controller.dart';
import '../../core/providers.dart';
import 'book_access.dart';

/// A staff member of the book's business, and how far they may use the book.
class StaffAccess {
  const StaffAccess({required this.userId, required this.email, this.grantId, this.access});

  factory StaffAccess.fromJson(Map<String, dynamic> json) {
    final role = json['role'] as String?;
    return StaffAccess(
      userId: json['user'] as String,
      email: json['user_email'] as String,
      grantId: json['grant_id'] as String?,
      access: role == null ? null : BookAccess.fromGrant(role),
    );
  }

  final String userId;
  final String email;
  final String? grantId;

  /// Null when they can't open the book at all.
  final BookAccess? access;
}

enum AccessOutcome { saved, offline, refused }

/// Who may use a cashbook is kept on the server and changed there, so this
/// needs a connection. The grants then reach phones by sync.
class AccessRepository {
  AccessRepository(this.ref);

  final Ref ref;

  ApiClient get _api => ref.read(apiClientProvider);

  /// Null when the server could not be reached or would not say.
  Future<List<StaffAccess>?> fetch(String bookId) async {
    try {
      final response = await _api.get('/api/v1/cashbooks/$bookId/access/');
      if (!response.ok) return null;
      return [for (final row in response.body as List) StaffAccess.fromJson((row as Map).cast<String, dynamic>())];
    } on OfflineException {
      return null;
    }
  }

  /// Gives [member] [access] to the book, changes it, or with null takes it away.
  /// Throws a PlanLimitException when the book is read-only on the owner's plan.
  Future<AccessOutcome> set(String bookId, StaffAccess member, BookAccess? access) async {
    if (access == member.access) return AccessOutcome.saved;
    final grantId = member.grantId;
    try {
      final response = switch ((grantId, access)) {
        (null, final BookAccess access) => await _api
            .post('/api/v1/cashbooks/$bookId/add_member/', {'member': member.userId, 'role': access.grantRole}),
        (final String id, null) => await _api.delete('/api/v1/cashbooks/$bookId/members/$id/'),
        (final String id, final BookAccess access) =>
          await _api.patch('/api/v1/cashbooks/$bookId/members/$id/', {'role': access.grantRole}),
        (null, null) => null,
      };
      if (response == null) return AccessOutcome.saved;
      if (response.statusCode == 402 && response.body is Map) {
        ref.read(entitlementsProvider.notifier).refresh();
        throw PlanLimitException.fromJson(response.body as Map);
      }
      if (!response.ok) return AccessOutcome.refused;
      ref.invalidate(bookAccessListProvider(bookId));
      await ref.read(syncControllerProvider.notifier).syncNow();
      return AccessOutcome.saved;
    } on OfflineException {
      return AccessOutcome.offline;
    }
  }
}

final accessRepositoryProvider = Provider<AccessRepository>(AccessRepository.new);

/// The business's staff with their access to one book, fresh from the server.
/// Null when the server could not be reached.
final bookAccessListProvider = FutureProvider.autoDispose.family<List<StaffAccess>?, String>(
  (ref, bookId) => ref.read(accessRepositoryProvider).fetch(bookId),
);
