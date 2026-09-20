/// Une note appartenant à un utilisateur.
class Note {
  final int? id; // null tant que la note n'est pas enregistrée
  final int userId;
  final String title;
  final String content;
  final DateTime updatedAt;

  const Note({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  /// Les clés correspondent exactement aux colonnes de la table `notes`.
  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, Object?> map) {
    return Note(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      content: map['content'] as String,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
