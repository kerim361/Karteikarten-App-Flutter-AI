Intelligente Karteikarten-App für Vorlesungen 📚✨

Diese Flutter-App bietet eine elegante Lösung für das effiziente Lernen und Wiederholen von Vorlesungsinhalten. Mit einem nahtlosen Frontend und einem leistungsstarken Python-Backend ermöglicht die Anwendung das Hochladen von Vorlesungsunterlagen auf einer intuitiven Web-Oberfläche.

🚀 Wie funktioniert es?

Vorlesung hochladen – Lade deine Vorlesungsfolien oder Notizen einfach auf die Webseite hoch.
Automatische Umwandlung – Die App verarbeitet den Inhalt und generiert daraus ein interaktives Karteikarten-Deck.
Hash-ID für dein Deck – Jedes erstellte Deck erhält eine eindeutige Hash-ID, die gespeichert wird, damit du jederzeit darauf zugreifen und weiterlernen kannst.
Lernen & Wiederholen – Nutze die Karteikarten, um dein Wissen spielerisch zu festigen und effizient zu wiederholen.
Diese App kombiniert Automatisierung mit einer modernen, benutzerfreundlichen Oberfläche und sorgt dafür, dass du dein Studium produktiver gestalten kannst. 🎯📖

Was hältst du davon? Soll ich noch etwas anpassen? 😊


Tutorial: Karteikarten-Flutter-App – Automatische Erstellung von Lernkarten aus Vorlesungen 🎓📚

Überblick

Diese App ermöglicht es, Vorlesungsfolien hochzuladen, die dann automatisch in ein Karteikarten-Deck umgewandelt werden. Jedes Deck erhält eine eindeutige Hash-ID, mit der du später weiterlernen kannst.

Voraussetzungen

🔹 Python 3 installiert
🔹 Flutter installiert (Flutter-Installation)
🔹 GitHub-Repository (optional für Versionierung)

Schritt 1: Server starten

Bevor die Web-App funktioniert, muss der Backend-Server gestartet werden. Öffne ein Terminal und navigiere in das KK-Py-scripts Verzeichnis:

cd KK-Py-scrpits
python3 server.py
Nach dem Start läuft der Backend-Server und verarbeitet hochgeladene Vorlesungen.

Schritt 2: Flutter-Webapp starten

Öffne ein zweites Terminal, navigiere in das Flutter-Webapp-Verzeichnis und starte die App:

cd KK-webapp/kk_web_app
flutter run
Die App sollte nun im Browser oder auf einem Emulator erscheinen.

Schritt 3: Vorlesungsfolien hochladen

Öffne die Web-App im Browser.
Schreibe im Suchfeld:
Yunus-ist-cool
Dies bringt dich ins Developer-Menü.
Lade deine Vorlesungsfolien hoch (z. B. als PDF).
Warte ca. 10 Minuten, bis die KI die Inhalte verarbeitet und die Karteikarten generiert.
Schritt 4: Hash-ID speichern & Karteikarten lernen

Nach der Verarbeitung wird eine Hash-ID generiert.

Hash kopieren:
Der Hash ist im Developer-Menü sichtbar.
Speichere ihn, um später darauf zugreifen zu können.
Karteikarten abrufen:
Suche in der App nach deiner Hash-ID.
Deine generierten Karteikarten erscheinen und können zum Lernen genutzt werden!
Zusätzliche Funktionen & Tipps

✅ Rating-System für Karteikarten:

Die Datei 8117b1affa339cbd0fac95970dcff3eac9537ceefdfcc88013f23ae552fc410d-KK-rating.txt speichert Bewertungen der Karten.
✅ Bearbeitete Karteikarten:

8117b1affa339cbd0fac95970dcff3eac9537ceefdfcc88013f23ae552fc410d-KK-korrigiert.txt enthält Korrekturen.
✅ Datenstruktur:

Jedes erstellte Deck befindet sich in Hashes/ mit den zugehörigen Dateien.
✅ Erweiterung:

Falls du das Frontend oder Backend erweitern möchtest, findest du die Hauptlogik in KK-webapp/lib/ und die Python-Skripte in KK-Py-scrpits/.
🎯 Fazit
Diese App nimmt dir das mühsame Erstellen von Lernkarten ab und ermöglicht effizientes Wiederholen. 🚀 Falls du Fragen hast oder Features hinzufügen möchtest, schau dir den Code an und passe ihn nach deinen Bedürfnissen an!

Viel Erfolg beim Lernen! 🎓🔥

