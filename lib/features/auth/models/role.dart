/// Reusable Role enum matching the backend Role.java
enum Role {
  CLIENT,
  COLLECTOR,
  ADMIN,
  OPERATIONS,
  FINANCE,
  SUPPORT;

  /// Display name (can be customized later if needed)
  String get displayName => name;

  /// Convert string to Role enum safely
  static Role fromString(String? role) {
    if (role == null || role.isEmpty) return Role.CLIENT;
    return Role.values.firstWhere(
          (r) => r.name.toUpperCase() == role.toUpperCase(),
      orElse: () => Role.CLIENT,
    );
  }

  /// Get all role names as List<String> for dropdowns, etc.
  static List<String> get allRoleNames =>
      Role.values.map((r) => r.name).toList();

  /// Get all roles as List<Role>
  static List<Role> get allRoles => Role.values;

  @override
  String toString() => name;
}