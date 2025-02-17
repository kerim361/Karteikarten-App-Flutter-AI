import os
import sys
import subprocess

# Basispfad setzen
BASE_DIR = os.path.abspath("..")  # Geht ins Hauptverzeichnis
HASHES_DIR = os.path.join(BASE_DIR, "Hashes")  # Hashes-Verzeichnis
SCRIPTS_DIR = os.path.join(BASE_DIR, "KK-Py-scrpits")  # Skriptverzeichnis

def main():
    if len(sys.argv) != 2:
        print("⚠️  Verwendung: python start.py EINGABE-HASH")
        sys.exit(1)

    eingabe_hash = sys.argv[1]
    hash_path = os.path.join(HASHES_DIR, eingabe_hash)

    if not os.path.exists(hash_path):
        print(f"❌ Fehler: Der Ordner {hash_path} existiert nicht.")
        sys.exit(1)

    pdf_datei = os.path.join(hash_path, f"{eingabe_hash}.pdf")
    txt_datei = os.path.join(hash_path, f"{eingabe_hash}.txt")
    kk_datei = os.path.join(hash_path, f"{eingabe_hash}-KK.txt")
    kk_korrigiert = os.path.join(hash_path, f"{eingabe_hash}-KK-korrigiert.txt")
    rating_datei = os.path.join(hash_path, f"{eingabe_hash}-KK-rating.txt")

    # Schritt 1: PDF zu TXT konvertieren
    if not os.path.exists(txt_datei):
        print(f"📄 Konvertiere {pdf_datei} → {txt_datei} ...")
        subprocess.run([sys.executable, os.path.join(SCRIPTS_DIR, "PDFtoTXT.py"), pdf_datei], check=True)
    else:
        print(f"✅ TXT-Datei existiert bereits: {txt_datei}")

    # Schritt 2: Karteikarten mit ChatGPT generieren
    if not os.path.exists(kk_datei):
        print(f"📝 Erstelle Karteikarten aus {txt_datei} → {kk_datei} ...")
        subprocess.run([sys.executable, os.path.join(SCRIPTS_DIR, "chatGPTAnfrage.py"), txt_datei], check=True)
    else:
        print(f"✅ Karteikarten-Datei existiert bereits: {kk_datei}")

    # Schritt 3: Karteikarten-Nummerierung korrigieren
    if not os.path.exists(kk_korrigiert):
        print(f"🔍 Korrigiere Karteikarten-Nummerierung: {kk_datei} → {kk_korrigiert} ...")
        subprocess.run([sys.executable, os.path.join(SCRIPTS_DIR, "KK-clean.py"), kk_datei], check=True)
    else:
        print(f"✅ Korrigierte Datei existiert bereits: {kk_korrigiert}")

    # Schritt 4: Rating-Datei für Karteikarten erstellen
    if not os.path.exists(rating_datei):
        print(f"⭐ Erstelle Rating-Datei für {kk_korrigiert} → {rating_datei} ...")
        subprocess.run([sys.executable, os.path.join(SCRIPTS_DIR, "build-rating.py"), kk_korrigiert], check=True)
    else:
        print(f"✅ Rating-Datei existiert bereits: {rating_datei}")

    print(f"🎉 Fertig! Korrigierte Karteikarten & Bewertung gespeichert in:\n  - {kk_korrigiert}\n  - {rating_datei}")

if __name__ == "__main__":
    main()
