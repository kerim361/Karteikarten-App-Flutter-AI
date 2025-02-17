import re
import sys
import os

def korrigiere_karteikarten(eingabe_datei, ausgabe_datei=None):
    """
    Korrigiert die Nummerierung der Karteikarten in einer Textdatei und speichert das Ergebnis mit der Endung '-KK-korrigiert.txt'.

    Args:
        eingabe_datei (str): Der Name der Eingabedatei.
        ausgabe_datei (str, optional): Der Name der Ausgabedatei. Wird standardmäßig aus dem Eingabenamen generiert.
    """
    # Sicherstellen, dass die Datei die Endung '-KK.txt' hat
    if not eingabe_datei.endswith("-KK.txt"):
        print("❌ Fehler: Die Eingabedatei muss die Endung '-KK.txt' haben.")
        return

    # Dateiname anpassen, um das richtige Format für die Ausgabe zu erhalten
    if ausgabe_datei is None:
        ausgabe_datei = eingabe_datei.replace("-KK.txt", "-KK-korrigiert.txt")

    try:
        # Datei einlesen
        with open(eingabe_datei, "r", encoding="utf-8") as file:
            inhalt = file.readlines()
        
        neue_zeilen = []
        karteikarten_index = 1  # Start bei 1
        
        for zeile in inhalt:
            # Überprüfen, ob die Zeile mit "Karteikarte X" beginnt
            if re.match(r"Karteikarte\s*\d+", zeile.strip()):
                neue_zeilen.append(f"Karteikarte {karteikarten_index}\n")
                karteikarten_index += 1
            else:
                neue_zeilen.append(zeile)

        # Datei mit korrigierter Nummerierung speichern
        with open(ausgabe_datei, "w", encoding="utf-8") as file:
            file.writelines(neue_zeilen)

        print(f"✅ Datei gespeichert: {ausgabe_datei}")

    except FileNotFoundError:
        print(f"❌ Fehler: Datei '{eingabe_datei}' nicht gefunden.")
    except Exception as e:
        print(f"❌ Unerwarteter Fehler: {e}")

def main():
    if len(sys.argv) != 2:
        print("Verwendung: python korrigiere_karteikarten.py <datei-KK.txt>")
        sys.exit(1)

    eingabe_datei = sys.argv[1]
    korrigiere_karteikarten(eingabe_datei)

if __name__ == "__main__":
    main()
