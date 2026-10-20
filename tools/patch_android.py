"""Adjust the Android files that `flutter create` generates during the CI build.

- App name shown on the phone
- Lets the app find the phone's text-to-speech engine (needed on Android 11+)
- Signs release builds with the shared key from the KANA_KEYSTORE file, so
  every APK installs as an update over the previous one
- Stops the release-build code shrinker from removing plugin code that is
  only called from native code (it broke saving progress)
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

# Flutter's Gradle plugin picks up android/app/proguard-rules.pro automatically.
rules = Path("android/app/proguard-rules.pro")
keep = """# Plugin code reached through JNI must survive shrinking.
-keep class io.flutter.plugins.** { *; }
-keep class com.tundralabs.fluttertts.** { *; }
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}
"""
existing = rules.read_text(encoding="utf-8") if rules.exists() else ""
if "io.flutter.plugins" not in existing:
    rules.write_text(existing + ("\n" if existing else "") + keep, encoding="utf-8")
print(rules.read_text(encoding="utf-8"))

# Turn release-build shrinking off entirely; the keep rules alone did not stop
# the shared_preferences plugin from breaking. Flutter's Gradle plugin reads
# the "shrink" property.
props = Path("android/gradle.properties")
ptext = props.read_text(encoding="utf-8") if props.exists() else ""
if "shrink=" not in ptext:
    props.write_text(ptext.rstrip("\n") + "\nshrink=false\n", encoding="utf-8")
print(props.read_text(encoding="utf-8"))

# Sign with the shared key. Gradle otherwise falls back to a fresh debug key
# on every CI run, and Android refuses to update an app signed differently.
gradle = Path("android/app/build.gradle.kts")
g = gradle.read_text(encoding="utf-8")
if 'create("shared")' not in g:
    shared = """    signingConfigs {
        create("shared") {
            storeFile = file(System.getenv("KANA_KEYSTORE") ?: error("KANA_KEYSTORE is not set"))
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
    }

    buildTypes {"""
    assert "    buildTypes {" in g, "buildTypes block not found in build.gradle.kts"
    g = g.replace("    buildTypes {", shared, 1)
    assert 'signingConfigs.getByName("debug")' in g, "release signing line not found"
    g = g.replace('signingConfigs.getByName("debug")', 'signingConfigs.getByName("shared")')
    gradle.write_text(g, encoding="utf-8")
print(g)
