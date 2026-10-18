/// What someone may do in one cashbook. Owners and admins manage every book
/// and viewers read every book; staff get what their grant to the book says.
/// The server decides the same way (CashBook.has_permission).
enum BookAccess {
  view,

  /// Adds entries but never changes one, not even their own.
  add,
  edit,

  /// Also categories, payment methods and who has access.
  manage;

  bool get canAdd => index >= add.index;
  bool get canEdit => index >= edit.index;
  bool get canManage => this == manage;

  /// The access a workspace role gives to every book, or null for staff,
  /// whose access is per book.
  static BookAccess? forRole(String role) => switch (role) {
        'owner' || 'admin' => manage,
        'staff' => null,
        _ => view,
      };

  /// A staff member's access from their grant's role; without one they can only have reached the book to look.
  static BookAccess fromGrant(String? role) => switch (role) {
        'admin' => manage,
        'editor' => edit,
        'contributor' => add,
        _ => view,
      };

  /// The grant role the server stores for this access.
  String get grantRole => switch (this) {
        view => 'viewer',
        add => 'contributor',
        edit => 'editor',
        manage => 'admin',
      };
}
