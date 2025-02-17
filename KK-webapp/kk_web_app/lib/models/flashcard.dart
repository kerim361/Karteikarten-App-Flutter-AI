class Flashcard {
  final String frage;
  final String antwort;
  bool rating; // z.B. ob Karteikarte als "gewusst" markiert ist

  Flashcard({
    required this.frage,
    required this.antwort,
    this.rating = false,
  });

  // Hilfsfunktion zum Erstellen aus JSON
  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      frage: json['Frage'] ?? '',
      antwort: json['Antwort'] ?? '',
    );
  }
}
