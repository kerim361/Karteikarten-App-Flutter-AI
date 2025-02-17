import fitz  # PyMuPDF
import sys
import os

def pdf_to_txt(pdf_datei, txt_datei=None):
    """Konvertiert eine PDF-Datei in eine TXT-Datei."""
    
    if not os.path.isfile(pdf_datei):
        print(f"Fehler: Die Datei {pdf_datei} wurde nicht gefunden.")
        return
    
    if txt_datei is None:
        txt_datei = os.path.splitext(pdf_datei)[0] + ".txt"
    
    try:
        # PDF öffnen
        doc = fitz.open(pdf_datei)
        text = ""

        # Text aus jeder Seite extrahieren
        for seite in doc:
            text += seite.get_text("text") + "\n"

        # Text in eine Datei speichern
        with open(txt_datei, "w", encoding="utf-8") as f:
            f.write(text)

        print(f"Erfolgreich gespeichert: {txt_datei}")
    
    except Exception as e:
        print(f"Ein Fehler ist aufgetreten: {e}")

def main():
    if len(sys.argv) != 2:
        print("Verwendung: python pdf_to_txt.py datei.pdf")
        sys.exit(1)

    pdf_datei = sys.argv[1]
    pdf_to_txt(pdf_datei)

if __name__ == "__main__":
    main()
