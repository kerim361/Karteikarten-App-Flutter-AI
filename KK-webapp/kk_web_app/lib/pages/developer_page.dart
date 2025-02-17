import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // Für kIsWeb
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';


class DeveloperPage extends StatefulWidget {
  const DeveloperPage({super.key});

  @override
  State<DeveloperPage> createState() => _DeveloperPageState();
}

class _DeveloperPageState extends State<DeveloperPage> {
  String? _newHash;
  String? _errorMessage;

  Future<void> _pickAndUploadPdf() async {
    // Wähle eine PDF-Datei aus
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.isEmpty) return;

    final pickedFile = result.files.first;
    final fileName = pickedFile.name;
    
    if (!fileName.toLowerCase().endsWith(".pdf")) {
      setState(() {
        _errorMessage = "Nur PDF-Dateien erlaubt";
        _newHash = null;
      });
      return;
    }

    // Auf Web darf nicht auf .path zugegriffen werden
    final filePath = kIsWeb ? null : pickedFile.path;
    final fileBytes = pickedFile.bytes;

    final uri = Uri.parse("http://127.0.0.1:5000/upload");
    final request = http.MultipartRequest("POST", uri);

    try {
      if (filePath != null) {
        // Für Desktop/Mobile, falls path verfügbar ist:
        request.files.add(await http.MultipartFile.fromPath("file", filePath));
      } else if (fileBytes != null) {
        // Auf Web: Nutze die Bytes und gib den Dateinamen mit Endung .pdf an
        request.files.add(http.MultipartFile.fromBytes(
          "file",
          fileBytes,
          filename: fileName,
        ));
      } else {
        setState(() {
          _errorMessage = "Fehler: Keine Datei oder Bytes vorhanden.";
          _newHash = null;
        });
        return;
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _newHash = data["newHash"];
          _errorMessage = null;
        });
      } else {
        setState(() {
          _newHash = null;
          _errorMessage = "Fehler beim Hochladen: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _newHash = null;
        _errorMessage = "Upload fehlgeschlagen: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Developer Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "PDF hochladen",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: _pickAndUploadPdf,
              child: const Text("Datei auswählen & hochladen"),
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            if (_newHash != null)
              Column(
                children: [
                  Text("Neuer Hash: $_newHash"),
                  const SizedBox(height: 5),
                  ElevatedButton(
  onPressed: () {
    if (_newHash != null) {
      Clipboard.setData(ClipboardData(text: _newHash!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hash wurde kopiert!"))
      );
    }
  },
  child: const Text("Hash kopieren"),
),

                ],
              ),
          ],
        ),
      ),
    );
  }
}
