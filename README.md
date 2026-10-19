# Kana Cards

An Android flip-card app for reading Japanese as a traveller: hiragana, katakana, and later kanji, menus, station and shop signs.

## Install the latest build

1. On your Android phone, open the **Releases** page of this repo and pick **Latest build**.
2. Download `kana-cards.apk` and open it. Allow installs from your browser when Android asks.
3. Use `kana-cards-older-phones.apk` only if the first file will not install.

Every push to `main` builds a new APK automatically (see the Actions tab).

## Project layout

| Path | What it is |
| --- | --- |
| `lib/` | The app (Flutter) |
| `assets/decks/*.json` | Card content, one file per deck |
| `tools/build_kana_decks.py` | Generates the hiragana and katakana decks |
| `.github/workflows/build.yml` | Builds the APK and publishes it to the release |

The `android/` folder is generated during the build by `flutter create`, then adjusted by `tools/patch_android.py`.

## Editing cards

Kana decks are generated: edit the tables in `tools/build_kana_decks.py`, then run `python3 tools/build_kana_decks.py`.
Card `id`s are permanent because progress is saved against them, so never rename one.

## Signing

Android only installs an update over an existing app when both are signed with the same key.
Store a test keystore as the repo secret `TEST_KEYSTORE_B64` (base64 of the file, alias `androiddebugkey`, passwords `android`).
Without it, each build gets a one-off key and the old app must be uninstalled first.
