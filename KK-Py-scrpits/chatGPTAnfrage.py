import os
import sys
import time
from openai import OpenAI

# API-Schlüssel sicher aus Umgebungsvariablen laden
api_key = os.environ.get("OPENAI_API_KEY")
if not api_key:
    raise ValueError("Der API-Schlüssel ist nicht gesetzt. Bitte füge ihn als Umgebungsvariable 'OPENAI_API_KEY' hinzu.")

# OpenAI-Client initialisieren
client = OpenAI(
    api_key=api_key
)

def split_text(text, max_length=50000):
    """Teilt den Text in größere Abschnitte auf, die jeweils max_length Zeichen lang sind."""
    return [text[i:i+max_length] for i in range(0, len(text), max_length)]

def stelle_anfrage_und_speichere(folien_dateiname):
    try:
        # Absoluten Pfad berechnen
        folien_dateiname = os.path.abspath(folien_dateiname)

        # Überprüfen, ob die Datei existiert
        if not os.path.isfile(folien_dateiname):
            raise FileNotFoundError(f"Die Datei wurde nicht gefunden.\nGesucht unter: {folien_dateiname}")
        
        gpt_prompt_path = os.path.abspath("gptPrompt.txt")

        if not os.path.isfile(gpt_prompt_path):
            raise FileNotFoundError(f"Die Datei gptPrompt.txt wurde nicht gefunden.\nGesucht unter: {gpt_prompt_path}")
        
        # Text aus gptPrompt.txt lesen
        with open(gpt_prompt_path, "r", encoding="utf-8") as prompt_file:
            gpt_prompt = prompt_file.read()
        
        # Text aus der gegebenen Folien-Datei lesen
        with open(folien_dateiname, "r", encoding="utf-8") as folien_file:
            folien_text = folien_file.read()
        
        if not folien_text.strip():
            raise ValueError(f"Die Datei {folien_dateiname} ist leer. Bitte verwende eine Datei mit Inhalt.")
        
        # Text in größere Abschnitte aufteilen
        text_chunks = split_text(folien_text, max_length=40000)
        
        # Datei speichern mit -KK Suffix
        ausgabe_dateiname = f"{os.path.splitext(folien_dateiname)[0]}-KK.txt"
        
        with open(ausgabe_dateiname, "w", encoding="utf-8") as file:
            for i, chunk in enumerate(text_chunks):
                chunk_prompt = gpt_prompt.replace("mindestens 30 und höchstens 100", 
                                                  f"mindestens {30 // len(text_chunks)} und höchstens {100 // len(text_chunks)}")
                anforderung = f"{chunk_prompt}\n{chunk}"
                
                # Anfrage an das Chat-Modell
                response = client.chat.completions.create(
                    messages=[{"role": "user", "content": anforderung}],
                    model="o1-mini"
                )
                
                # Antwort extrahieren und speichern
                antwort = response.choices[0].message.content
                file.write(antwort + "\n")
                print(f"Abschnitt {i+1} / {len(text_chunks)} wurde verarbeitet und gespeichert.")

        print(f"Die Antwort wurde in der Datei '{ausgabe_dateiname}' gespeichert.")

    except FileNotFoundError as fnf_error:
        print(f"Fehler: {fnf_error}")
    except ValueError as val_error:
        print(f"Fehler: {val_error}")
    except Exception as e:
        print(f"Ein unerwarteter Fehler ist aufgetreten: {e}")


def main():
    if len(sys.argv) != 2:
        print("Verwendung: python chatGPTAnfrage.py folientext.txt")
        sys.exit(1)
    
    folien_dateiname = sys.argv[1]
    stelle_anfrage_und_speichere(folien_dateiname)

if __name__ == "__main__":
    main()

