import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/flashcard.dart';

class ApiService {
  // Passe das an deine Lokal-Adresse oder (später) an deinen Server im Internet an.
  static const String baseUrl = 'http://127.0.0.1:5000';

  /// Hole alle Karteikarten zu einem bestimmten Hash.
  static Future<List<Flashcard>> fetchFlashcards(String hash) async {
    final url = Uri.parse('$baseUrl/karteikarten/$hash');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      // data ist eine Liste von Karten-Objekten: [{"Frage":..., "Antwort":...}, ...]
      return data.map((jsonCard) => Flashcard.fromJson(jsonCard)).toList();
    } else {
      // Fehlerbehandlung
      throw Exception('Fehler beim Laden der Karteikarten (Hash: $hash)');
    }
  }

  /// Hole das Rating für alle Karten eines Hash (Dictionary).
  /// Beispiel: { "1": true, "2": false, ... }
  static Future<Map<String, bool>> fetchRatings(String hash) async {
    final url = Uri.parse('$baseUrl/ratings/$hash');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      // data könnte z.B. { "1": true, "2": false } sein
      // Konvertieren in Map<String, bool>
      return data.map((key, value) => MapEntry(key, value as bool));
    } else {
      // Keine Ratings vorhanden -> leeres Map
      return {};
    }
  }

  /// Sende ein Rating für eine bestimmte Karte (mit Index) an den Server.
  static Future<bool> sendRating(String hash, String cardIndex, bool rating) async {
    final url = Uri.parse('$baseUrl/ratings/$hash');
    final body = json.encode({
      "cardIndex": cardIndex,
      "rating": rating,
    });
    final headers = {"Content-Type": "application/json"};

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // Erfolg
      return true;
    } else {
      // Fehler
      return false;
    }
  }
}
