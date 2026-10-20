"""Turn the word lists in content/*.csv into app decks in assets/decks/.

Edit the CSV files (on GitHub or locally), then run:
    python3 tools/build_word_decks.py

CSV columns: front, kana, romaji, meaning, note
  front   what is written on the menu or sign (kanji, kana or both)
  kana    how it is read; the voice clip is made from this
  romaji  long vowels written twice (koohii, gyuudon)

content/menu-photos.csv also has a "photo" column: a crop in assets/photos/.
Every photo is its own card, even when the word is already in another deck,
so the same word can be practised in different handwriting.

Card ids come from the romaji (or the photo file name), and progress is saved against the id,
so fixing a romaji typo resets progress for that one card.
"""
import csv
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DECKS = {
    # csv file           deck name          title             id prefix  card style
    "katakana-words.csv": ("katakana_words", "Katakana words", "kw", "cafe"),
    "food-menu.csv": ("food_menu", "Food menu", "food", "menu"),
    "menu-photos.csv": ("menu_photos", "Real menus", "photo", "menu"),
}


def slug(text):
    return re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")


def build(csv_name, deck, title, prefix, style):
    rows = list(csv.DictReader((ROOT / "content" / csv_name).open(encoding="utf-8")))
    cards, seen = [], set()
    for n, r in enumerate(rows, start=2):
        if None in r:
            sys.exit(f"{csv_name} line {n}: too many commas; wrap the note in double quotes")
        r = {k: (v or "").strip() for k, v in r.items()}
        if not (r["front"] and r["kana"] and r["romaji"] and r["meaning"]):
            sys.exit(f"{csv_name} line {n}: front, kana, romaji and meaning are required")
        photo = r.get("photo", "")
        if photo and not (ROOT / "assets" / "photos" / photo).exists():
            sys.exit(f"{csv_name} line {n}: assets/photos/{photo} not found")
        # Photo cards are named after their image, so one word can have many.
        cid = f"{prefix}-{Path(photo).stem}" if photo else f"{prefix}-{slug(r['romaji'])}"
        if cid in seen:
            sys.exit(f"{csv_name} line {n}: duplicate card id {cid}")
        seen.add(cid)
        cards.append({
            "id": cid, "front": r["front"], "kana": r["kana"], "romaji": r["romaji"],
            "meaning": r["meaning"], "note": r["note"], "group": "word",
            **({"photo": f"photos/{photo}"} if photo else {}),
        })
    data = {"deck": deck, "title": title, "style": style, "version": 1, "cards": cards}
    (ROOT / "assets" / "decks" / f"{deck}.json").write_text(
        json.dumps(data, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    print(f"{deck}: {len(cards)} cards")


if __name__ == "__main__":
    for csv_name, args in DECKS.items():
        build(csv_name, *args)
