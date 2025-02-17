import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../services/api_service.dart';

class FlashcardsPage extends StatefulWidget {
  final String hash;

  const FlashcardsPage({super.key, required this.hash});

  @override
  State<FlashcardsPage> createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashcardsPage> {
  late Future<List<Flashcard>> _futureFlashcards;
  Map<String, bool> _ratings = {};

  @override
  void initState() {
    super.initState();
    _futureFlashcards = ApiService.fetchFlashcards(widget.hash);
    _ladeRatings();
  }

  Future<void> _ladeRatings() async {
    try {
      final ratings = await ApiService.fetchRatings(widget.hash);
      setState(() {
        _ratings = ratings;
      });
    } catch (e) {
      // Falls es keine Ratings gibt oder Fehler
      setState(() {
        _ratings = {};
      });
    }
  }

  Future<void> _updateRating(int cardIndex, bool newVal) async {
    // Wir verwenden cardIndex+1 oder cardIndex als String (je nach dem, wie du es in der rating-Datei nutzt)
    final indexString = (cardIndex + 1).toString();

    final success = await ApiService.sendRating(widget.hash, indexString, newVal);
    if (success) {
      setState(() {
        _ratings[indexString] = newVal;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Karteikarten: ${widget.hash}"),
      ),
      body: FutureBuilder<List<Flashcard>>(
        future: _futureFlashcards,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Fehler: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Keine Karteikarten gefunden."));
          }

          final cards = snapshot.data!;
          return ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              final indexString = (index + 1).toString();
              final isRatedTrue = _ratings[indexString] ?? false;

              return Card(
                child: ListTile(
                  title: Text("Frage: ${card.frage}"),
                  subtitle: Text("Antwort: ${card.antwort}"),
                  trailing: Switch(
                    value: isRatedTrue,
                    onChanged: (newVal) {
                      _updateRating(index, newVal);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
