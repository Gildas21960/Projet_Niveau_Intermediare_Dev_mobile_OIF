import '../models/user.dart';
import 'database_helper.dart';
import 'password_hasher.dart';

/// Erreur d'authentification avec un message lisible par l'utilisateur.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Inscription et connexion, appuyées sur la table `users`.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  Future<User> register(String username, String password) async {
    final db = await DatabaseHelper.instance.database;
    final name = username.trim();

    final existing = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      throw const AuthException("Ce nom d'utilisateur est déjà utilisé.");
    }

    final id = await db.insert('users', {
      'username': name,
      'password': PasswordHasher.hash(password),
    });
    return User(id: id, username: name);
  }

  Future<User> login(String username, String password) async {
    final db = await DatabaseHelper.instance.database;

    final rows = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username.trim()],
      limit: 1,
    );
    // Même message que le mot de passe soit faux ou le compte inconnu :
    // on ne révèle pas quels noms d'utilisateur existent.
    if (rows.isEmpty ||
        !PasswordHasher.verify(password, rows.first['password'] as String)) {
      throw const AuthException(
        "Nom d'utilisateur ou mot de passe incorrect.",
      );
    }
    return User.fromMap(rows.first);
  }
}
