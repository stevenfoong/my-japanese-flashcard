"""Generate the app's sound clips with a running VOICEVOX engine.

Used by .github/workflows/generate-audio.yml, which starts the engine as a
Docker service. To run it yourself:

    docker run --rm -p 127.0.0.1:50021:50021 voicevox/voicevox_engine:cpu-latest
    python3 tools/generate_audio.py

Writes:
  assets/audio/kana/<sound>.mp3   one clip per kana sound (hiragana and katakana share it)
  assets/audio/words/<hash>.mp3   one clip per example word
  assets/audio/index.json         text -> clip file, read by the app

Only missing clips are generated, unless the voice or settings change.
Needs ffmpeg on the PATH.
"""
import hashlib
import json
import os
import subprocess
import sys
import tempfile
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DECKS = ROOT / "assets" / "decks"
OUT = ROOT / "assets" / "audio"
ENGINE = os.environ.get("VOICEVOX_URL", "http://127.0.0.1:50021")
VOICE = os.environ.get("VOICE_NAME", "No.7")
STYLE = os.environ.get("VOICE_STYLE", "ノーマル")

# Bump to regenerate every clip after changing the settings below.
SETTINGS = {"rev": 1, "kana_speed": 0.85, "word_speed": 0.95, "pre": 0.08, "post": 0.2}


def call(method, path, params=None, body=None):
    url = ENGINE + path
    if params:
        url += "?" + urllib.parse.urlencode(params)
    data = None
    headers = {}
    if body is not None:
        data = json.dumps(body).encode("utf-8")
        headers["Content-Type"] = "application/json"
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    with urllib.request.urlopen(req, timeout=120) as r:
        return r.read()


def find_style_id():
    speakers = json.loads(call("GET", "/speakers"))
    for sp in speakers:
        if sp["name"] == VOICE:
            for st in sp["styles"]:
                if st["name"] == STYLE:
                    return st["id"]
            styles = ", ".join(s["name"] for s in sp["styles"])
            sys.exit(f"::error::Voice {VOICE} has no style {STYLE}. Styles: {styles}")
    names = ", ".join(sp["name"] for sp in speakers)
    sys.exit(f"::error::Voice {VOICE} not found. Voices: {names}")


def to_kata(s):
    return "".join(chr(ord(c) + 0x60) if "ぁ" <= c <= "ゖ" else c for c in s)


def query_for_kana(kana, sid):
    """Read a single kana exactly as written.

    Normal text mode treats lone は/へ/を as grammar particles (wa/e/o), so the
    kana is sent in VOICEVOX's phonetic notation instead (katakana plus an
    accent mark), then placed into a normal audio query.
    """
    kata = to_kata(kana)
    base = json.loads(call("POST", "/audio_query", {"text": kata, "speaker": sid}))
    for notation in (kata + "'", kata):
        try:
            phrases = json.loads(call("POST", "/accent_phrases",
                                      {"text": notation, "speaker": sid, "is_kana": "true"}))
            base["accent_phrases"] = phrases
            return base
        except Exception:
            continue
    print(f"::warning::{kana}: phonetic notation failed, using normal reading")
    return base


def synth(query, sid, speed, dest):
    query["speedScale"] = speed
    query["prePhonemeLength"] = SETTINGS["pre"]
    query["postPhonemeLength"] = SETTINGS["post"]
    query["outputStereo"] = False
    wav = call("POST", "/synthesis", {"speaker": sid}, query)
    dest.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(suffix=".wav") as tmp:
        tmp.write(wav)
        tmp.flush()
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", tmp.name,
                        "-ac", "1", "-b:a", "48k", str(dest)], check=True)


def main():
    version = call("GET", "/version").decode().strip('"')
    sid = find_style_id()
    voice = f"VOICEVOX:{VOICE}"
    signature = {"voice": voice, "style": STYLE, **SETTINGS}
    print(f"Engine {version}, {voice} ({STYLE}) = style id {sid}")

    index_file = OUT / "index.json"
    old = json.loads(index_file.read_text(encoding="utf-8")) if index_file.exists() else {}
    fresh = old.get("signature") != signature

    kana_jobs = {}   # file -> kana
    word_jobs = {}   # file -> word
    clips = {}
    for deck in ("hiragana", "katakana"):
        data = json.loads((DECKS / f"{deck}.json").read_text(encoding="utf-8"))
        for card in data["cards"]:
            sound = card["id"].split("-", 1)[1]
            rel = f"kana/{sound}.mp3"
            clips[card["front"]] = rel
            kana_jobs.setdefault(rel, card["front"])
            for ex in card.get("examples", []):
                word = ex["word"]
                rel = f"words/w{hashlib.sha1(word.encode()).hexdigest()[:10]}.mp3"
                clips[word] = rel
                word_jobs.setdefault(rel, word)

    made = 0
    for rel, kana in kana_jobs.items():
        dest = OUT / rel
        if fresh or not dest.exists():
            synth(query_for_kana(kana, sid), sid, SETTINGS["kana_speed"], dest)
            made += 1
    for rel, word in word_jobs.items():
        dest = OUT / rel
        if fresh or not dest.exists():
            q = json.loads(call("POST", "/audio_query", {"text": word, "speaker": sid}))
            synth(q, sid, SETTINGS["word_speed"], dest)
            made += 1

    # Remove clips no longer used by any card.
    used = set(clips.values())
    for sub in ("kana", "words"):
        for f in (OUT / sub).glob("*.mp3"):
            if f"{sub}/{f.name}" not in used:
                f.unlink()

    index = {"voice": voice, "style": STYLE, "engine": version,
             "signature": signature, "clips": dict(sorted(clips.items()))}
    index_file.write_text(json.dumps(index, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    size = sum(f.stat().st_size for f in OUT.rglob("*.mp3"))
    print(f"Generated {made} clips; {len(used)} in use, {size / 1048576:.1f} MB total")


if __name__ == "__main__":
    main()
