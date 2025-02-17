import re
import sys
import os

def erstelle_rating_datei(eingabe_datei):
    """
    Erstellt eine Bewertungsdatei (Rating-Datei) für die Karteikarten aus einer
    korrigierten Datei (z.B. `-KK-korrigiert.txt`).

    Args:
        eingabe_datei (str): Der Name der Eingabedatei mit den Karteikarten.
    """
    if not os.path.isfile(eingabe_datei):
        print(f"❌ Fehler: Datei '{eingabe_datei}' nicht gefunden.")
        return

    # Sicherstellen, dass die Datei die Endung '-KK-korrigiert.txt' hat
    if not eingabe_datei.endswith("-KK-korrigiert.txt"):
        print("❌ Fehler: Die Eingabedatei muss die Endung '-KK-korrigiert.txt' haben.")
        return

    # Basisname für die Rating-Datei bestimmen
    rating_datei = eingabe_datei.replace("-KK-korrigiert.txt", "-KK-rating.txt")

    try:
        # Datei einlesen
        with open(eingabe_datei, "r", encoding="utf-8") as file:
            inhalt = file.readlines()

        # Karteikarten-Nummern extrahieren
        karteikarten_index = []
        for zeile in inhalt:
            match = re.match(r"Karteikarte\s*(\d+)", zeile.strip())
            if match:
                karteikarten_index.append(int(match.group(1)))

        if not karteikarten_index:
            print("❌ Fehler: Keine Karteikarten in der Datei gefunden.")
            return

        # Maximalen Index bestimmen (höchste Karteikarten-Nummer)
        max_index = max(karteikarten_index)

        # Rating-Datei mit `false`-Bewertungen schreiben
        with open(rating_datei, "w", encoding="utf-8") as file:
            for i in range(1, max_index + 1):
                file.write(f"{i}:false\n")

        print(f"✅ Datei gespeichert: {rating_datei}")

    except Exception as e:
        print(f"❌ Unerwarteter Fehler: {e}")

def main():
    if len(sys.argv) != 2:
        print("Verwendung: python rate_karteikarten.py <datei-KK-korrigiert.txt>")
        sys.exit(1)

    eingabe_datei = sys.argv[1]
    erstelle_rating_datei(eingabe_datei)

if __name__ == "__main__":
    main()
