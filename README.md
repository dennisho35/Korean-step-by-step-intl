# Korean Step-by-Step International (韓語一步通國際版)

A complete, cross-platform Korean language learning platform (Android APK & Web App for GitHub Pages) built for absolute beginners across **11 languages**:
- 🇬🇧 `en-GB` — English (UK)
- 🇹🇭 `th-TH` — ภาษาไทย (Thai)
- 🇯🇵 `ja-JP` — 日本語 (Japanese)
- 🇻🇳 `vi-VN` — Tiếng Việt (Vietnamese)
- 🇫🇷 `fr-FR` — Français (French)
- 🇩🇪 `de-DE` — Deutsch (German)
- 🇪🇸 `es-ES` — Español (Spanish)
- 🇷🇺 `ru-RU` — Русский (Russian)
- 🇺🇦 `uk-UA` — Українська (Ukrainian)
- 🇮🇹 `it-IT` — Italiano (Italian)
- 🇹🇼 `zh-TW` — 繁體中文 (Traditional Chinese)

## Key Features
1. **Top-Left Language Switcher**: Instant runtime language switching across UI, explanations, translations, and native-script pronunciation guides without losing current lesson state or saved progress.
2. **5-Layer Pronunciation Aid System & 5 Independent Toggles**:
   - Hangul original (`한국어`, `감사합니다`) — never altered by localization
   - Standard Revised Romanization (`Hangug-eo`, `gamsahamnida`)
   - Native-Script Pronunciation Guide tailored to each language (`ฮัน-กู-กอ`, `ハングゴ`, `хан-гу-го`, `хан-ґу-ґо`, etc.)
   - Actual Phonological Pronunciation (`[한구거]`, `[감사함니다]`)
   - 3-Speed Korean TTS Audio (`0.24x` Ultra-Slow, `0.35x` Beginner, `0.45x` Standard)
3. **Complete Curriculum**: 40 Hangul Jamo, 5 Plain/Tense/Aspirated Triplets, Interactive Syllable Combiner (11,172 blocks), 8 Batchim Rules, 7 Phonological Rules, Stroke Handwriting Canvas, 12 Number Categories, 19 Counters, 20 Conversations (63 dialogue lines), 26 Quizzes, and Offline-First SRS Progress Dashboard.

## Validation & Build Commands

### 1. Run 11-Locale & Phonological Validation Suite
```bash
python3 tool/validate_i18n.py
```

### 2. Run Flutter Analyze & Unit Tests
```bash
flutter pub get
flutter analyze
flutter test
```

### 3. Build Android Release APK
```bash
flutter build apk --release
```

### 4. Build Flutter Web for GitHub Pages (`https://dennisho35.github.io/Korean-Learning-web/`)
```bash
flutter build web --release --base-href "/Korean-Learning-web/"
```
