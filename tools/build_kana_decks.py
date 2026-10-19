"""Generate assets/decks/hiragana.json and assets/decks/katakana.json.

Edit the tables below, then run:  python3 tools/build_kana_decks.py

Card ids are permanent (progress is stored against them), so never rename
an existing key in KANA.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "decks"

# (hiragana, id key, romaji shown, group)
KANA = []
for row in [
    ("あ a", "い i", "う u", "え e", "お o"),
    ("か ka", "き ki", "く ku", "け ke", "こ ko"),
    ("さ sa", "し shi", "す su", "せ se", "そ so"),
    ("た ta", "ち chi", "つ tsu", "て te", "と to"),
    ("な na", "に ni", "ぬ nu", "ね ne", "の no"),
    ("は ha", "ひ hi", "ふ fu", "へ he", "ほ ho"),
    ("ま ma", "み mi", "む mu", "め me", "も mo"),
    ("や ya", "ゆ yu", "よ yo"),
    ("ら ra", "り ri", "る ru", "れ re", "ろ ro"),
    ("わ wa",),
]:
    for cell in row:
        k, r = cell.split()
        KANA.append((k, r, r, "basic"))
KANA.append(("を", "wo", "o", "basic"))
KANA.append(("ん", "n", "n", "basic"))

_d =("が ga ぎ gi ぐ gu げ ge ご go ざ za じ ji ず zu ぜ ze ぞ zo "
      "だ da ぢ di づ du で de ど do ば ba び bi ぶ bu べ be ぼ bo "
      "ぱ pa ぴ pi ぷ pu ぺ pe ぽ po").split()
SHOWN = {"di": "ji", "du": "zu"}
for i in range(0, len(_d), 2):
    k, key = _d[i], _d[i + 1]
    KANA.append((k, key, SHOWN.get(key, key), "dakuten"))

_c = ("きゃ kya きゅ kyu きょ kyo しゃ sha しゅ shu しょ sho ちゃ cha ちゅ chu ちょ cho "
      "にゃ nya にゅ nyu にょ nyo ひゃ hya ひゅ hyu ひょ hyo みゃ mya みゅ myu みょ myo "
      "りゃ rya りゅ ryu りょ ryo ぎゃ gya ぎゅ gyu ぎょ gyo じゃ ja じゅ ju じょ jo "
      "びゃ bya びゅ byu びょ byo ぴゃ pya ぴゅ pyu ぴょ pyo").split()
for i in range(0, len(_c), 2):
    KANA.append((_c[i], _c[i + 1], _c[i + 1], "combo"))

# Example words: (word, romaji, meaning). The card's kana must appear in the word.
HIRA_EX = {
    "あ": [("あさ", "asa", "morning"), ("あめ", "ame", "rain")],
    "い": [("いぬ", "inu", "dog"), ("いえ", "ie", "house")],
    "う": [("うみ", "umi", "sea"), ("うえ", "ue", "up, above")],
    "え": [("えき", "eki", "station"), ("えいが", "eiga", "movie")],
    "お": [("おちゃ", "ocha", "tea"), ("おかね", "okane", "money")],
    "か": [("かさ", "kasa", "umbrella"), ("さかな", "sakana", "fish")],
    "き": [("きっぷ", "kippu", "ticket"), ("きた", "kita", "north")],
    "く": [("くすり", "kusuri", "medicine"), ("くるま", "kuruma", "car")],
    "け": [("いけ", "ike", "pond"), ("さけ", "sake", "rice wine; salmon")],
    "こ": [("ここ", "koko", "here"), ("こめ", "kome", "rice (uncooked)")],
    "さ": [("さかな", "sakana", "fish"), ("さくら", "sakura", "cherry blossom")],
    "し": [("しお", "shio", "salt"), ("すし", "sushi", "sushi")],
    "す": [("すし", "sushi", "sushi"), ("すいか", "suika", "watermelon")],
    "せ": [("せき", "seki", "seat"), ("みせ", "mise", "shop")],
    "そ": [("そば", "soba", "buckwheat noodles"), ("みそ", "miso", "miso")],
    "た": [("たまご", "tamago", "egg"), ("きた", "kita", "north")],
    "ち": [("ちず", "chizu", "map"), ("くち", "kuchi", "mouth")],
    "つ": [("なつ", "natsu", "summer"), ("つくえ", "tsukue", "desk")],
    "て": [("て", "te", "hand"), ("てがみ", "tegami", "letter")],
    "と": [("とり", "tori", "bird; chicken"), ("ひと", "hito", "person")],
    "な": [("なまえ", "namae", "name"), ("さかな", "sakana", "fish")],
    "に": [("にく", "niku", "meat"), ("にし", "nishi", "west")],
    "ぬ": [("いぬ", "inu", "dog"), ("ぬの", "nuno", "cloth")],
    "ね": [("ねこ", "neko", "cat"), ("おかね", "okane", "money"), ("ふね", "fune", "ship")],
    "の": [("のみもの", "nomimono", "drink"), ("きのこ", "kinoko", "mushroom")],
    "は": [("はし", "hashi", "chopsticks"), ("はな", "hana", "flower")],
    "ひ": [("ひと", "hito", "person"), ("ひがし", "higashi", "east")],
    "ふ": [("ふね", "fune", "ship"), ("ふゆ", "fuyu", "winter")],
    "へ": [("へや", "heya", "room"), ("へび", "hebi", "snake")],
    "ほ": [("ほん", "hon", "book"), ("ほし", "hoshi", "star")],
    "ま": [("まち", "machi", "town"), ("まど", "mado", "window")],
    "み": [("みず", "mizu", "water"), ("みせ", "mise", "shop")],
    "む": [("むし", "mushi", "insect"), ("むら", "mura", "village")],
    "め": [("あめ", "ame", "rain"), ("めがね", "megane", "glasses")],
    "も": [("もも", "momo", "peach"), ("もの", "mono", "thing")],
    "や": [("やま", "yama", "mountain"), ("やさい", "yasai", "vegetables")],
    "ゆ": [("ゆ", "yu", "hot water (onsen sign)"), ("ゆき", "yuki", "snow")],
    "よ": [("よる", "yoru", "night"), ("よこ", "yoko", "side")],
    "ら": [("さくら", "sakura", "cherry blossom"), ("らいねん", "rainen", "next year")],
    "り": [("りんご", "ringo", "apple"), ("とり", "tori", "bird; chicken")],
    "る": [("くるま", "kuruma", "car"), ("よる", "yoru", "night")],
    "れ": [("これ", "kore", "this"), ("れいぞうこ", "reizouko", "fridge")],
    "ろ": [("しろ", "shiro", "white; castle"), ("ろく", "roku", "six")],
    "わ": [("わさび", "wasabi", "wasabi"), ("わたし", "watashi", "I, me")],
    "を": [("みずをください", "mizu o kudasai", "Water, please")],
    "ん": [("ほん", "hon", "book"), ("みかん", "mikan", "mandarin orange")],
    "が": [("がっこう", "gakkou", "school"), ("ながい", "nagai", "long")],
    "ぎ": [("ぎんこう", "ginkou", "bank"), ("かぎ", "kagi", "key")],
    "ぐ": [("かぐ", "kagu", "furniture")],
    "げ": [("げんき", "genki", "healthy, fine"), ("かげ", "kage", "shadow")],
    "ご": [("ごはん", "gohan", "rice; meal"), ("たまご", "tamago", "egg")],
    "ざ": [("ざぶとん", "zabuton", "floor cushion"), ("ひざ", "hiza", "knee")],
    "じ": [("じかん", "jikan", "time"), ("かじ", "kaji", "fire")],
    "ず": [("みず", "mizu", "water"), ("ちず", "chizu", "map")],
    "ぜ": [("ぜんぶ", "zenbu", "all"), ("かぜ", "kaze", "wind; a cold")],
    "ぞ": [("ぞう", "zou", "elephant"), ("れいぞうこ", "reizouko", "fridge")],
    "だ": [("だいがく", "daigaku", "university"), ("からだ", "karada", "body")],
    "ぢ": [("はなぢ", "hanaji", "nosebleed")],
    "づ": [("つづく", "tsuzuku", "to continue")],
    "で": [("でぐち", "deguchi", "exit"), ("でんしゃ", "densha", "train")],
    "ど": [("どこ", "doko", "where"), ("まど", "mado", "window")],
    "ば": [("そば", "soba", "buckwheat noodles"), ("ばんごう", "bangou", "number")],
    "び": [("えび", "ebi", "shrimp"), ("びょういん", "byouin", "hospital")],
    "ぶ": [("ぶどう", "budou", "grapes"), ("ぶたにく", "butaniku", "pork")],
    "べ": [("べんとう", "bentou", "boxed lunch"), ("たべもの", "tabemono", "food")],
    "ぼ": [("ぼうし", "boushi", "hat"), ("ごぼう", "gobou", "burdock root")],
    "ぱ": [("かんぱい", "kanpai", "Cheers!"), ("いっぱい", "ippai", "full")],
    "ぴ": [("えんぴつ", "enpitsu", "pencil"), ("ぴかぴか", "pikapika", "shiny")],
    "ぷ": [("てんぷら", "tenpura", "tempura"), ("きっぷ", "kippu", "ticket")],
    "ぺ": [("ぺこぺこ", "pekopeko", "starving")],
    "ぽ": [("さんぽ", "sanpo", "a walk"), ("しっぽ", "shippo", "tail")],
    "きゃ": [("きゃく", "kyaku", "customer")],
    "きゅ": [("きゅうり", "kyuuri", "cucumber")],
    "きょ": [("きょう", "kyou", "today")],
    "しゃ": [("でんしゃ", "densha", "train"), ("しゃしん", "shashin", "photo")],
    "しゅ": [("しゅっぱつ", "shuppatsu", "departure")],
    "しょ": [("しょうゆ", "shouyu", "soy sauce")],
    "ちゃ": [("おちゃ", "ocha", "tea")],
    "ちゅ": [("ちゅうもん", "chuumon", "order (at a restaurant)")],
    "ちょ": [("ちょっと", "chotto", "a little")],
    "にゃ": [("こんにゃく", "konnyaku", "konjac jelly")],
    "にゅ": [("ぎゅうにゅう", "gyuunyuu", "milk")],
    "ひゃ": [("ひゃく", "hyaku", "hundred")],
    "ひょ": [("ひょう", "hyou", "table, chart")],
    "みゃ": [("みゃく", "myaku", "pulse")],
    "みょ": [("みょうじ", "myouji", "surname")],
    "りゃ": [("りゃくご", "ryakugo", "abbreviation")],
    "りゅ": [("りゅうがく", "ryuugaku", "study abroad")],
    "りょ": [("りょこう", "ryokou", "travel"), ("りょかん", "ryokan", "Japanese inn")],
    "ぎゃ": [("ぎゃく", "gyaku", "opposite")],
    "ぎゅ": [("ぎゅうどん", "gyuudon", "beef rice bowl"), ("ぎゅうにく", "gyuuniku", "beef")],
    "ぎょ": [("ぎょうざ", "gyouza", "dumplings")],
    "じゃ": [("じゃあね", "jaa ne", "See you!")],
    "じゅ": [("じゅうしょ", "juusho", "address")],
    "じょ": [("じょうしゃけん", "joushaken", "boarding ticket")],
    "びゃ": [("さんびゃく", "sanbyaku", "three hundred")],
    "びょ": [("びょういん", "byouin", "hospital")],
    "ぴゃ": [("はっぴゃく", "happyaku", "eight hundred")],
    "ぴょ": [("はっぴょう", "happyou", "announcement")],
}

KATA_EX = {
    "ア": [("アイス", "aisu", "ice cream"), ("アメリカ", "amerika", "America")],
    "イ": [("イギリス", "igirisu", "the UK"), ("インターネット", "intaanetto", "internet")],
    "ウ": [("ウイスキー", "uisukii", "whisky")],
    "エ": [("エレベーター", "erebeetaa", "elevator"), ("エアコン", "eakon", "air conditioner")],
    "オ": [("オレンジ", "orenji", "orange")],
    "カ": [("カメラ", "kamera", "camera"), ("カード", "kaado", "card")],
    "キ": [("ケーキ", "keeki", "cake"), ("キロ", "kiro", "kilo")],
    "ク": [("タクシー", "takushii", "taxi"), ("クーポン", "kuupon", "coupon")],
    "ケ": [("ケーキ", "keeki", "cake"), ("チケット", "chiketto", "ticket")],
    "コ": [("コーヒー", "koohii", "coffee"), ("コンビニ", "konbini", "convenience store")],
    "サ": [("サラダ", "sarada", "salad"), ("サイズ", "saizu", "size")],
    "シ": [("タクシー", "takushii", "taxi"), ("シャツ", "shatsu", "shirt")],
    "ス": [("バス", "basu", "bus"), ("スープ", "suupu", "soup")],
    "セ": [("セット", "setto", "set meal"), ("セール", "seeru", "sale")],
    "ソ": [("ソース", "soosu", "sauce"), ("ソフトクリーム", "sofuto kuriimu", "soft-serve ice cream")],
    "タ": [("タクシー", "takushii", "taxi"), ("タオル", "taoru", "towel")],
    "チ": [("チーズ", "chiizu", "cheese"), ("チケット", "chiketto", "ticket")],
    "ツ": [("ツアー", "tsuaa", "tour"), ("シャツ", "shatsu", "shirt")],
    "テ": [("ホテル", "hoteru", "hotel"), ("テーブル", "teeburu", "table")],
    "ト": [("トイレ", "toire", "toilet"), ("トマト", "tomato", "tomato")],
    "ナ": [("バナナ", "banana", "banana"), ("ナイフ", "naifu", "knife")],
    "ニ": [("メニュー", "menyuu", "menu"), ("テニス", "tenisu", "tennis")],
    "ヌ": [("ヌードル", "nuudoru", "noodles")],
    "ネ": [("ネット", "netto", "internet"), ("ネクタイ", "nekutai", "necktie")],
    "ノ": [("ノート", "nooto", "notebook"), ("ピアノ", "piano", "piano")],
    "ハ": [("ハンバーガー", "hanbaagaa", "hamburger"), ("ハム", "hamu", "ham")],
    "ヒ": [("コーヒー", "koohii", "coffee"), ("ヒーター", "hiitaa", "heater")],
    "フ": [("ナイフ", "naifu", "knife"), ("フォーク", "fooku", "fork")],
    "ヘ": [("ヘルメット", "herumetto", "helmet")],
    "ホ": [("ホテル", "hoteru", "hotel"), ("ホーム", "hoomu", "train platform")],
    "マ": [("トマト", "tomato", "tomato"), ("マップ", "mappu", "map")],
    "ミ": [("ミルク", "miruku", "milk")],
    "ム": [("ハム", "hamu", "ham"), ("ゲーム", "geemu", "game")],
    "メ": [("メニュー", "menyuu", "menu"), ("ラーメン", "raamen", "ramen")],
    "モ": [("レモン", "remon", "lemon"), ("モール", "mooru", "shopping mall")],
    "ヤ": [("ダイヤ", "daiya", "train timetable"), ("タイヤ", "taiya", "tyre")],
    "ユ": [("ユニフォーム", "yunifoomu", "uniform")],
    "ヨ": [("ヨーグルト", "yooguruto", "yogurt")],
    "ラ": [("ラーメン", "raamen", "ramen"), ("カラオケ", "karaoke", "karaoke")],
    "リ": [("リモコン", "rimokon", "remote control")],
    "ル": [("ビール", "biiru", "beer"), ("ホテル", "hoteru", "hotel")],
    "レ": [("トイレ", "toire", "toilet"), ("レストラン", "resutoran", "restaurant")],
    "ロ": [("ロッカー", "rokkaa", "locker")],
    "ワ": [("ワイン", "wain", "wine"), ("ワイファイ", "waifai", "Wi-Fi")],
    "ン": [("パン", "pan", "bread"), ("ワイン", "wain", "wine")],
    "ガ": [("ガイド", "gaido", "guide"), ("ガム", "gamu", "chewing gum")],
    "ギ": [("ギター", "gitaa", "guitar")],
    "グ": [("グラス", "gurasu", "glass")],
    "ゲ": [("ゲーム", "geemu", "game")],
    "ゴ": [("ゴミ", "gomi", "rubbish, trash")],
    "ザ": [("ピザ", "piza", "pizza")],
    "ジ": [("レジ", "reji", "cash register"), ("ジュース", "juusu", "juice")],
    "ズ": [("チーズ", "chiizu", "cheese"), ("サイズ", "saizu", "size")],
    "ゼ": [("ゼロ", "zero", "zero")],
    "ゾ": [("ゾーン", "zoon", "zone")],
    "ダ": [("サラダ", "sarada", "salad"), ("ダイヤ", "daiya", "train timetable")],
    "デ": [("デパート", "depaato", "department store")],
    "ド": [("ドア", "doa", "door"), ("ドリンク", "dorinku", "drink")],
    "バ": [("バス", "basu", "bus"), ("バナナ", "banana", "banana")],
    "ビ": [("ビール", "biiru", "beer")],
    "ブ": [("テーブル", "teeburu", "table")],
    "ベ": [("ベッド", "beddo", "bed")],
    "ボ": [("ボタン", "botan", "button")],
    "パ": [("パン", "pan", "bread"), ("パスポート", "pasupooto", "passport")],
    "ピ": [("ピザ", "piza", "pizza")],
    "プ": [("スープ", "suupu", "soup")],
    "ペ": [("ペン", "pen", "pen")],
    "ポ": [("ポテト", "poteto", "fries, potato"), ("パスポート", "pasupooto", "passport")],
    "キャ": [("キャンセル", "kyanseru", "cancel")],
    "キュ": [("バーベキュー", "baabekyuu", "barbecue")],
    "シャ": [("シャワー", "shawaa", "shower"), ("シャツ", "shatsu", "shirt")],
    "シュ": [("シュークリーム", "shuukuriimu", "cream puff")],
    "ショ": [("ショッピング", "shoppingu", "shopping")],
    "チャ": [("チャージ", "chaaji", "top up (IC card)")],
    "チュ": [("チューハイ", "chuuhai", "shochu highball")],
    "チョ": [("チョコレート", "chokoreeto", "chocolate")],
    "ニュ": [("メニュー", "menyuu", "menu"), ("ニュース", "nyuusu", "news")],
    "ミュ": [("ミュージアム", "myuujiamu", "museum")],
    "リュ": [("リュック", "ryukku", "backpack")],
    "ギャ": [("ギャラリー", "gyararii", "gallery")],
    "ジャ": [("ジャケット", "jaketto", "jacket"), ("ジャム", "jamu", "jam")],
    "ジュ": [("ジュース", "juusu", "juice")],
    "ジョ": [("ジョギング", "jogingu", "jogging")],
    "ビュ": [("ビュッフェ", "byuffe", "buffet")],
}

HIRA_ALIKE = {
    "あ": "おめ", "い": "りこ", "う": "らつ", "え": "ん", "お": "あむ", "か": "や",
    "き": "さま", "く": "へ", "け": "はほ", "こ": "いに", "さ": "ちき", "し": "つも",
    "す": "むお", "た": "なに", "ち": "さら", "つ": "しう", "て": "そ", "な": "た",
    "に": "こた", "ぬ": "めの", "ね": "れわ", "の": "めぬ", "は": "ほけ", "へ": "く",
    "ほ": "はま", "ま": "もほ", "む": "すお", "め": "ぬあ", "も": "しま", "や": "か",
    "ら": "うち", "り": "い", "る": "ろ", "れ": "ねわ", "ろ": "る", "わ": "れね",
}
KATA_ALIKE = {
    "ア": "マ", "ウ": "ワフ", "エ": "工", "カ": "力", "ク": "ケタ", "ケ": "ク", "コ": "ユロ",
    "サ": "セ", "シ": "ツ", "ス": "ヌ", "セ": "サ", "ソ": "ンリ", "タ": "ク", "チ": "テ",
    "ツ": "シ", "テ": "チ", "ニ": "二", "ヌ": "スメ", "ハ": "八", "フ": "ワウ", "ヘ": "へ",
    "マ": "ア", "メ": "ヌ", "ユ": "コヨ", "ヨ": "ユ", "リ": "ソり", "ル": "レ", "レ": "ル",
    "ロ": "コ口", "ワ": "ウフ", "ン": "ソ",
}
KATA_NOTE = {
    "ヲ": "Rarely used in katakana",
    "ヂ": "Rarely used; ジ is the usual spelling",
    "ヅ": "Rarely used; ズ is the usual spelling",
    "エ": "工 is the kanji for craft",
    "カ": "力 is the kanji for power",
    "ニ": "二 is the kanji for two",
    "ハ": "八 is the kanji for eight",
    "ロ": "口 is the kanji for mouth",
    "ヘ": "Same shape as hiragana へ",
}
HIRA_NOTE = {
    "を": "Sounds like お. Used as a grammar particle",
    "ぢ": "Rare; sounds the same as じ",
    "づ": "Rare; sounds the same as ず",
}


def to_kata(s):
    return "".join(chr(ord(c) + 0x60) if "ぁ" <= c <= "ゖ" else c for c in s)


def examples(table, kana):
    out = []
    for word, romaji, meaning in table.get(kana, []):
        assert kana in word, f"{kana} not in example {word}"
        out.append({"word": word, "romaji": romaji, "meaning": meaning})
    return out


def build():
    OUT.mkdir(parents=True, exist_ok=True)
    hira, kata = [], []
    for k, key, shown, group in KANA:
        kk = to_kata(k)
        hira.append({
            "id": f"hira-{key}", "front": k, "romaji": shown, "group": group,
            "partner": kk, "look_alike": list(HIRA_ALIKE.get(k, "")),
            "note": HIRA_NOTE.get(k, ""), "audio": None,
            "examples": examples(HIRA_EX, k),
        })
        kata.append({
            "id": f"kata-{key}", "front": kk, "romaji": shown, "group": group,
            "partner": k, "look_alike": list(KATA_ALIKE.get(kk, "")),
            "note": KATA_NOTE.get(kk, ""), "audio": None,
            "examples": examples(KATA_EX, kk),
        })
    for name, title, cards in (("hiragana", "Hiragana", hira), ("katakana", "Katakana", kata)):
        ids = [c["id"] for c in cards]
        assert len(ids) == len(set(ids)) == 104, (name, len(ids))
        data = {"deck": name, "title": title, "version": 1, "cards": cards}
        (OUT / f"{name}.json").write_text(json.dumps(data, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
        print(name, len(cards), "cards")


if __name__ == "__main__":
    build()
