import 'package:flutter/material.dart';

import '../models/note.dart';
import '../models/user.dart';
import '../services/database_helper.dart';
import '../utils/date_format.dart';
import 'login_screen.dart';
import 'note_edit_screen.dart';

/// Écran principal : liste des notes de l'utilisateur (S4, S5, S6, S9).
class NotesInterface extends StatefulWidget {
  const NotesInterface({super.key, required this.user});

  final User user;

  @override
  State<NotesInterface> createState() => _NotesInterfaceState();
}

class _NotesInterfaceState extends State<NotesInterface> {
  List<Note> _notes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final notes = await DatabaseHelper.instance.getNotes(widget.user.id);
      if (!mounted) return;
      setState(() {
        _notes = notes;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Impossible de charger vos notes.';
      });
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Ouvre l'éditeur : nouvelle note si [note] est nul, sinon modification.
  Future<void> _openEditor([Note? note]) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditScreen(user: widget.user, note: note),
      ),
    );
    if (saved == true) {
      await _loadNotes();
      _showMessage('Note enregistrée');
    }
  }

  Future<void> _confirmDelete(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer la note ?'),
        content: Text('La note « ${note.title} » sera supprimée définitivement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await DatabaseHelper.instance.deleteNote(note.id!, widget.user.id);
      await _loadNotes();
      _showMessage('Note supprimée');
    } catch (_) {
      _showMessage('La suppression a échoué. Veuillez réessayer.');
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: _logout,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle note'),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 8),
            Text(_error!),
            TextButton(
              onPressed: () {
                setState(() => _loading = true);
                _loadNotes();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            'Bonjour, ${widget.user.username}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: _notes.isEmpty ? _buildEmptyState() : _buildList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.note_alt_outlined, size: 64),
            const SizedBox(height: 16),
            Text('Aucune note pour le moment', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Appuyez sur + Nouvelle note pour écrire votre première note.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      // Marge en bas pour que le bouton flottant ne cache pas la dernière note.
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 88),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            isThreeLine: true,
            onTap: () => _openEditor(note),
            title: Text(
              note.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.content.isEmpty ? 'Aucun contenu' : note.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  formatNoteDate(note.updatedAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Supprimer',
              onPressed: () => _confirmDelete(note),
            ),
          ),
        );
      },
    );
  }
}
