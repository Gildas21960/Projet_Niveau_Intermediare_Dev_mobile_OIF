/// Formate la date d'une note : « Aujourd'hui, 09:12 », « Hier, 21:40 »,
/// puis « 18 sept., 16:05 ».
String formatNoteDate(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  final time = '${two(date.hour)}:${two(date.minute)}';

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  final diff = today.difference(day).inDays;

  if (diff == 0) return "Aujourd'hui, $time";
  if (diff == 1) return 'Hier, $time';

  const mois = [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ];
  return '${date.day} ${mois[date.month - 1]}, $time';
}
