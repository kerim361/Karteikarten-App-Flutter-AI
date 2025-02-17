import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/flashcard.dart';

class LearnPage extends StatefulWidget {
  final String hash;
  const LearnPage({super.key, required this.hash});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  late Future<List<Flashcard>> _futureFlashcards;
  Map<String, bool> _ratings = {};

  @override
  void initState() {
    super.initState();
    _futureFlashcards = ApiService.fetchFlashcards(widget.hash);
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    final ratings = await ApiService.fetchRatings(widget.hash);
    setState(() {
      _ratings = ratings;
    });
  }

  void _showCardDetailDialog(Flashcard card) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(card.frage, style: const TextStyle(fontSize: 20)),
          content: SingleChildScrollView(
            child: Text(
              card.antwort,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Schließen"),
            ),
          ],
        );
      },
    );
  }

  Icon _buildRatingIcon(int index) {
    // Indizes in Rating-Datei = 1-based => "1", "2", ...
    final indexString = (index + 1).toString();
    final rating = _ratings[indexString] ?? false;
    return rating
        ? const Icon(Icons.check_circle, color: Colors.green)
        : const Icon(Icons.cancel, color: Colors.red);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lernen – Hash: ${widget.hash}"),
      ),
      body: Column(
        children: [
          // Legende
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 5),
                Text("= gelernt"),
                SizedBox(width: 20),
                Icon(Icons.cancel, color: Colors.red),
                SizedBox(width: 5),
                Text("= nicht gelernt"),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Flashcard>>(
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
                    return Card(
                      child: ListTile(
                        leading: _buildRatingIcon(index),
                        title: Text(card.frage),
                        onTap: () => _showCardDetailDialog(card),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
