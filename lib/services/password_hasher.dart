import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Hachage des mots de passe : SHA-256 avec un sel aléatoire par utilisateur.
/// Le résultat est stocké sous la forme `sel$empreinte` dans la colonne
/// `password` : le mot de passe en clair n'est jamais enregistré.
class PasswordHasher {
  PasswordHasher._();

  static String hash(String password) {
    final random = Random.secure();
    final salt = base64Url.encode(
      List<int>.generate(16, (_) => random.nextInt(256)),
    );
    return '$salt\$${_digest(salt, password)}';
  }

  static bool verify(String password, String stored) {
    final parts = stored.split('\$');
    if (parts.length != 2) return false;
    return _digest(parts[0], password) == parts[1];
  }

  static String _digest(String salt, String password) {
    return sha256.convert(utf8.encode('$salt$password')).toString();
  }
}
