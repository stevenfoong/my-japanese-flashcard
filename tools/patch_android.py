"""Adjust the Android files that `flutter create` generates during the CI build.

- App name shown on the phone
- Lets the app find the phone's text-to-speech engine (needed on Android 11+)
"""
import re
from pathlib import Path

APP_NAME = "Kana Cards"

manifest = Path("android/app/src/main/AndroidManifest.xml")
text = manifest.read_text(encoding="utf-8")

tts = ('<intent>\n            <action android:name="android.intent.action.TTS_SERVICE" />\n'
       '        </intent>')
if "TTS_SERVICE" not in text:
    if "<queries>" in text:
        text = text.replace("<queries>", "<queries>\n        " + tts, 1)
    else:
        text = text.replace("</manifest>", "    <queries>\n        " + tts + "\n    </queries>\n</manifest>", 1)

text = re.sub(r'android:label="[^"]*"', f'android:label="{APP_NAME}"', text, count=1)
manifest.write_text(text, encoding="utf-8")
print(text)
