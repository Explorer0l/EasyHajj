class AppUser {
  const AppUser({
    required this.id,
    required this.isAnonymous,
    this.displayName,
    this.email,
    this.photoUrl,
  });

  final String id;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final bool isAnonymous;
}

