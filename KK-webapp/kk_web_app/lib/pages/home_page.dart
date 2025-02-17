import 'package:flutter/material.dart';
import 'learn_page.dart';
import 'test_page.dart';
import 'developer_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _hashController = TextEditingController();

  void _navigate() {
    final hash = _hashController.text.trim();

    if (hash.isEmpty) return;

    // Spezialfall: "Yunus-ist-cool" -> DeveloperPage
    if (hash == "Yunus-ist-cool") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DeveloperPage()),
      );
      return;
    }

    // Normale Buttons: Lernen oder Test
    // Hier könnten wir auch zwei Buttons haben, also verschieben wir evtl. die Logik in onPressed ...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Karteikarten Home"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Gib hier deinen Hash ein:"),
              TextField(
                controller: _hashController,
                decoration: const InputDecoration(
                  labelText: "Hash",
                  hintText: "z.B. f77f95fb5d7...",
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final hash = _hashController.text.trim();
                      if (hash.isNotEmpty && hash != "Yunus-ist-cool") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LearnPage(hash: hash),
                          ),
                        );
                      } else if (hash == "Yunus-ist-cool") {
                        // Entwickler-Seite
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DeveloperPage()),
                        );
                      }
                    },
                    child: const Text("Lernen"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final hash = _hashController.text.trim();
                      if (hash.isNotEmpty && hash != "Yunus-ist-cool") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TestPage(hash: hash),
                          ),
                        );
                      } else if (hash == "Yunus-ist-cool") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DeveloperPage()),
                        );
                      }
                    },
                    child: const Text("Test"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
