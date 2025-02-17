import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/flashcard.dart';

class TestPage extends StatefulWidget {
  final String hash;
  const TestPage({super.key, required this.hash});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  late Future<List<Flashcard>> _futureFlashcards;

  int _currentIndex = 0;
  bool _showAnswer = false;
  final List<bool?> _userResults = [];

  @override
  void initState() {
    super.initState();
    _futureFlashcards = ApiService.fetchFlashcards(widget.hash);
  }

  void _onShowAnswer() {
    setState(() {
      _showAnswer = true;
    });
  }

  void _onAnswer(bool isCorrect, int totalCards) {
    _userResults.add(isCorrect);
    setState(() {
      _showAnswer = false;
      _currentIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test – Hash: ${widget.hash}"),
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
          // Sind wir über die letzte Karte hinaus -> Zusammenfassung
          if (_currentIndex >= cards.length) {
            return _buildSummaryView(cards);
          }

          // Zeige aktuelle Karte
          final card = cards[_currentIndex];
          return _buildTestView(card, cards.length);
        },
      ),
    );
  }

  Widget _buildTestView(Flashcard card, int totalCards) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            "Frage ${_currentIndex + 1} / $totalCards",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            card.frage,
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (!_showAnswer)
            ElevatedButton(
              onPressed: _onShowAnswer,
              child: const Text("Antwort zeigen"),
            )
          else
            Column(
              children: [
                Text(
                  card.antwort,
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Richtig/Falsch Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () => _onAnswer(true, totalCards),
                      label: const Text("Richtig"),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => _onAnswer(false, totalCards),
                      label: const Text("Falsch"),
                    ),
                  ],
                )
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryView(List<Flashcard> cards) {
    final total = cards.length;
    // Anzahl true in _userResults
    final correct = _userResults.where((res) => res == true).length;
    final scorePct = (correct / total) * 100;

    final note = _calculateUniNote(scorePct);

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          "Ergebnis:\n$correct von $total richtig\n"
          "(${scorePct.toStringAsFixed(1)}%)",
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          "→ Deine Note: $note",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              final userResult = _userResults[index];
              return ListTile(
                title: Text("Frage ${index + 1}: ${card.frage}"),
                subtitle: Text(
                  "Antwort: ${card.antwort}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                trailing: Icon(
                  userResult == true ? Icons.check_circle : Icons.cancel,
                  color: userResult == true ? Colors.green : Colors.red,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _calculateUniNote(double scorePct) {
    if (scorePct >= 90) return "1,0 (sehr gut)";
    if (scorePct >= 85) return "1,3 (sehr gut)";
    if (scorePct >= 80) return "1,7 (gut)";
    if (scorePct >= 76) return "2,0 (gut)";
    if (scorePct >= 72) return "2,3 (gut)";
    if (scorePct >= 67) return "2,7 (befriedigend)";
    if (scorePct >= 63) return "3,0 (befriedigend)";
    if (scorePct >= 59) return "3,3 (befriedigend)";
    if (scorePct >= 54) return "3,7 (ausreichend)";
    if (scorePct >= 50) return "4,0 (ausreichend)";
    return "5,0 (nicht ausreichend)";
  }
}
