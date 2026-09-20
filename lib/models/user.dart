/// Utilisateur connecté (le mot de passe haché n'est jamais gardé en mémoire).
class User {
  final int id;
  final String username;

  const User({required this.id, required this.username});

  factory User.fromMap(Map<String, Object?> map) {
    return User(
      id: map['id'] as int,
      username: map['username'] as String,
    );
  }
}
