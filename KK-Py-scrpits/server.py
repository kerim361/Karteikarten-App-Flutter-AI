import os
import re
import sys
import secrets  # zum Generieren eines zufälligen Hash
import threading
import time
import subprocess
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Pfad zum Hashes-Ordner (eine Ebene höher als KK-Py-scrpits)
HASHES_DIR = os.path.abspath("../Hashes")


def lade_karteikarten(hash_wert):
    dateipfad = os.path.join(HASHES_DIR, hash_wert, f"{hash_wert}-KK-korrigiert.txt")
    if not os.path.isfile(dateipfad):
        return None

    karteikarten = []
    with open(dateipfad, "r", encoding="utf-8") as file:
        inhalt = file.read().split("\n\n")
        for eintrag in inhalt:
            frage_match = re.search(r"Frage: (.+)", eintrag)
            antwort_match = re.search(r"Antwort:\n(.+)", eintrag, re.DOTALL)
            if frage_match and antwort_match:
                karteikarten.append({
                    "Frage": frage_match.group(1).strip(),
                    "Antwort": antwort_match.group(1).strip()
                })
    return karteikarten


def lade_ratings(hash_wert):
    dateipfad = os.path.join(HASHES_DIR, hash_wert, f"{hash_wert}-KK-rating.txt")
    if not os.path.isfile(dateipfad):
        return None

    ratings = {}
    with open(dateipfad, "r", encoding="utf-8") as file:
        for line in file:
            line = line.strip()
            if not line:
                continue
            teile = line.split(":")
            if len(teile) == 2:
                idx, bool_str = teile
                ratings[idx] = bool_str.lower() == "true"
    return ratings


def speichere_ratings(hash_wert, ratings):
    dateipfad = os.path.join(HASHES_DIR, hash_wert, f"{hash_wert}-KK-rating.txt")
    lines = []
    for k, v in ratings.items():
        line = f"{k}:{str(v).lower()}"
        lines.append(line)
    with open(dateipfad, "w", encoding="utf-8") as file:
        file.write("\n".join(lines))


def delayed_start(new_hash):
    """Wartet 15 Sekunden und ruft dann start.py mit dem neuen Hash auf."""
    time.sleep(15)
    start_script = os.path.join(os.path.dirname(__file__), "start.py")
    try:
        # Verwende sys.executable anstelle von "python"
        subprocess.run([sys.executablere, start_script, new_hash], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Fehler beim Ausführen von start.py: {e}")


@app.route("/karteikarten/<hash_wert>", methods=["GET"])
def get_karteikarten(hash_wert):
    karteikarten = lade_karteikarten(hash_wert)
    if karteikarten is None:
        return jsonify({"error": f"Hash '{hash_wert}' nicht gefunden"}), 404
    return jsonify(karteikarten)


@app.route("/ratings/<hash_wert>", methods=["GET"])
def get_ratings(hash_wert):
    ratings = lade_ratings(hash_wert)
    if ratings is None:
        return jsonify({})
    return jsonify(ratings)


@app.route("/ratings/<hash_wert>", methods=["POST"])
def update_rating(hash_wert):
    data = request.json
    if not data or "cardIndex" not in data or "rating" not in data:
        return jsonify({"error": "Missing 'cardIndex' or 'rating'"}), 400

    card_index = str(data["cardIndex"])
    card_rating = bool(data["rating"])

    ratings = lade_ratings(hash_wert)
    if ratings is None:
        ratings = {}

    ratings[card_index] = card_rating
    speichere_ratings(hash_wert, ratings)

    return jsonify({"success": True, "updatedRating": {card_index: card_rating}}), 200


@app.route("/upload", methods=["POST"])
def upload_file():
    """
    Erwartet ein Multipart-Formular (z.B. "file" als Schlüssel).
    Nur PDF-Dateien werden akzeptiert.
    Generiert einen neuen Hash, legt Ordner an und speichert die PDF als <hash>.pdf.
    Antwort: { "newHash": "<hash>" }
    Nach erfolgreichem Upload und Umbenennung wird 15 Sekunden später start.py mit dem neuen Hash aufgerufen.
    """
    if "file" not in request.files:
        return jsonify({"error": "No file in request"}), 400

    pdf_file = request.files["file"]
    if pdf_file.filename == "":
        return jsonify({"error": "No filename"}), 400

    # Check, ob es eine PDF ist
    if not pdf_file.filename.lower().endswith(".pdf"):
        return jsonify({"error": "Only .pdf files allowed"}), 400

    # Generiere neuen Hash (z.B. 32 Byte → 64 Hex-Zeichen)
    new_hash = secrets.token_hex(32)
    new_folder = os.path.join(HASHES_DIR, new_hash)
    os.makedirs(new_folder, exist_ok=True)

    new_filename = f"{new_hash}.pdf"
    pdf_path = os.path.join(new_folder, new_filename)
    pdf_file.save(pdf_path)

    # Starte start.py 15 Sekunden später in einem Hintergrundthread
    threading.Thread(target=delayed_start, args=(new_hash,)).start()

    return jsonify({"newHash": new_hash}), 200


if __name__ == "__main__":
    app.run(debug=True)
