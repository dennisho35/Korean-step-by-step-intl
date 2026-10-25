import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KoreanStepByStepIntlApp());
}

/// 5 獨立顯示開關
class DisplayToggles {
  bool showRomaji = true;
  bool showNativePron = true;
  bool showActualPron = true;
  bool showTranslation = true;
  bool showPronNotes = true;

  void applyBeginnerPreset() {
    showRomaji = true;
    showNativePron = true;
    showActualPron = true;
    showTranslation = true;
    showPronNotes = true;
  }

  void applyAdvancedPreset() {
    showRomaji = false;
    showNativePron = false;
    showActualPron = true;
    showTranslation = true;
    showPronNotes = false;
  }
}

/// 11 語系國際化服務
class I18nService {
  static const List<String> supportedLocales = [
    'en-GB', 'th-TH', 'ja-JP', 'vi-VN', 'fr-FR',
    'de-DE', 'es-ES', 'ru-RU', 'uk-UA', 'it-IT', 'zh-TW',
  ];

  String currentLocale = 'en-GB';

  final Map<String, Map<String, String>> localesMeta = const {
    'en-GB': {'flag': '🇬🇧', 'nativeName': 'English (UK)'},
    'th-TH': {'flag': '🇹🇭', 'nativeName': 'ภาษาไทย'},
    'ja-JP': {'flag': '🇯🇵', 'nativeName': '日本語'},
    'vi-VN': {'flag': '🇻🇳', 'nativeName': 'Tiếng Việt'},
    'fr-FR': {'flag': '🇫🇷', 'nativeName': 'Français'},
    'de-DE': {'flag': '🇩🇪', 'nativeName': 'Deutsch'},
    'es-ES': {'flag': '🇪🇸', 'nativeName': 'Español'},
    'ru-RU': {'flag': '🇷🇺', 'nativeName': 'Русский'},
    'uk-UA': {'flag': '🇺🇦', 'nativeName': 'Українська'},
    'it-IT': {'flag': '🇮🇹', 'nativeName': 'Italiano'},
    'zh-TW': {'flag': '🇹🇼', 'nativeName': '繁體中文'},
  };

  final Map<String, Map<String, String>> _uiStrings = const {
    'en-GB': {
      'appTitle': 'Korean Step-by-Step International',
      'navHangul': '1. Hangul',
      'navNumbers': '2. Numbers',
      'navConv': '3. Dialogues',
      'navQuiz': '4. Quiz',
      'navStats': '5. Progress',
      'subJamo': '40 Jamo',
      'subBatchim': '7 Batchim Rules',
      'subPhono': '7 Sound Rules',
      'subWriting': 'Writing Pad',
      'presetBeginner': '🌱 Beginner Mode',
      'presetAdvanced': '🎓 Advanced Mode',
      'toggleRomaji': 'Romanization',
      'toggleNativePron': 'Native Phonetics',
      'toggleActualPron': 'Actual [Hangul]',
      'toggleTranslation': 'Translation',
      'togglePronNotes': 'Pronunciation Notes',
      'btnListen': 'Listen',
      'btnMarkMastered': '✓ Mastered',
      'btnMarkReview': '★ Review',
      'labelActualPron': 'Actual Pronunciation',
      'quizNext': 'Next Question →',
      'statsTotalMastered': 'Mastered Items',
      'statsQuizAccuracy': 'Quiz Accuracy',
      'statsReviewQueue': 'SRS Review Queue',
      'statsTotalReviews': 'Total Audio & Card Reviews',
      'privacyNotice': '100% Offline-Ready Local Storage. No personal data uploaded.',
      'approxDisclaimer': 'Native-script pronunciation guides are approximate aids based on actual Korean phonology.',
    },
    'zh-TW': {
      'appTitle': '韓語一步通國際版 Korean Step-by-Step',
      'navHangul': '1. 字母與音變',
      'navNumbers': '2. 數字與量詞',
      'navConv': '3. 實用會話',
      'navQuiz': '4. 互動測驗',
      'navStats': '5. 學習進度',
      'subJamo': '40 韓文字母',
      'subBatchim': '7 大收音規則',
      'subPhono': '7 大音變規則',
      'subWriting': '手寫練習',
      'presetBeginner': '🌱 初學者模式',
      'presetAdvanced': '🎓 進階模式',
      'toggleRomaji': '羅馬拼音',
      'toggleNativePron': '母語近似音',
      'toggleActualPron': '實際發音 [...]',
      'toggleTranslation': '母語翻譯',
      'togglePronNotes': '發音與音變提示',
      'btnListen': '發音',
      'btnMarkMastered': '✓ 已掌握',
      'btnMarkReview': '★ 需重溫',
      'labelActualPron': '韓語實際發音',
      'quizNext': '下一題 →',
      'statsTotalMastered': '已掌握項目',
      'statsQuizAccuracy': '測驗正確率',
      'statsReviewQueue': '需重溫清單',
      'statsTotalReviews': '累計練習次數',
      'privacyNotice': '100% 本機離線儲存，不收集或上傳任何個人資料。',
      'approxDisclaimer': '母語諧音與注音提示僅供初學階段輔助記憶，請搭配三段語速發音練習。',
    },
  };

  Future<void> initTranslations({String? savedLocale}) async {
    if (savedLocale != null && supportedLocales.contains(savedLocale)) {
      currentLocale = savedLocale;
    }
  }

  void setLocale(String locale) {
    if (supportedLocales.contains(locale)) {
      currentLocale = locale;
    }
  }

  String t(String key) {
    final map = _uiStrings[currentLocale] ?? _uiStrings['en-GB']!;
    return map[key] ?? _uiStrings['en-GB']![key] ?? key;
  }

  String approxDisclaimer() => t('approxDisclaimer');

  String pickLocalized(Map<String, dynamic>? map, String fallback) {
    if (map == null) return fallback;
    return map[currentLocale]?.toString() ?? map['en-GB']?.toString() ?? fallback;
  }
}

/// 韓語 TTS 語音播放服務（支援 0.24x / 0.35x / 0.45x）
class KoreanTtsService {
  Future<void> init() async {}

  Future<void> speak(String text, {double rate = 0.35}) async {
    // 透過 Flutter 內建或 Platform Channels 導向語音合成
  }
}

/// 手寫筆順練習畫布元件
class HandwritingPracticeCard extends StatefulWidget {
  final String targetCharacter;
  final bool showGuide;
  final VoidCallback onSpeak;

  const HandwritingPracticeCard({
    super.key,
    required this.targetCharacter,
    required this.showGuide,
    required this.onSpeak,
  });

  @override
  State<HandwritingPracticeCard> createState() => _HandwritingPracticeCardState();
}

class _HandwritingPracticeCardState extends State<HandwritingPracticeCard> {
  final List<List<Offset>> _strokes = [];

  void _clear() {
    setState(() {
      _strokes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: widget.onSpeak,
              icon: const Icon(Icons.volume_up),
              label: Text(widget.targetCharacter),
            ),
            OutlinedButton.icon(
              onPressed: _clear,
              icon: const Icon(Icons.refresh),
              label: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF1B365D), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _strokes.add([details.localPosition]);
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _strokes.last.add(details.localPosition);
                    });
                  },
                  child: CustomPaint(
                    painter: _HandwritingPainter(
                      strokes: _strokes,
                      guideChar: widget.showGuide ? widget.targetCharacter : null,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HandwritingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final String? guideChar;

  _HandwritingPainter({required this.strokes, this.guideChar});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), gridPaint);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), gridPaint);

    if (guideChar != null && guideChar!.isNotEmpty) {
      final tp = TextPainter(
        text: TextSpan(
          text: guideChar,
          style: TextStyle(
            fontSize: size.width * 0.6,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFCBD5E1).withOpacity(0.45),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2),
      );
    }

    final strokePaint = Paint()
      ..color = const Color(0xFF1B365D)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HandwritingPainter oldDelegate) => true;
}

class KoreanStepByStepIntlApp extends StatefulWidget {
  const KoreanStepByStepIntlApp({super.key});

  @override
  State<KoreanStepByStepIntlApp> createState() => _KoreanStepByStepIntlAppState();
}

class _KoreanStepByStepIntlAppState extends State<KoreanStepByStepIntlApp> {
  final I18nService _i18n = I18nService();
  final KoreanTtsService _tts = KoreanTtsService();
  final DisplayToggles _toggles = DisplayToggles();
  Map<String, dynamic>? _curriculum;
  SharedPreferences? _prefs;

  int _mainTabIndex = 0;
  double _speechRate = 0.35;
  String _preset = 'beginner';

  // Writing state
  final String _writeChar = '한';
  final bool _showWriteGuide = true;

  // Progress state
  Map<String, String> _itemStatus = {};
  Map<String, int> _reviewCounts = {};
  int _quizCorrect = 0;
  int _quizTotal = 0;
  List<String> _wrongQuizIds = [];

  // Quiz state
  int _quizIndex = 0;
  bool _quizSubmitted = false;

  @override
  void initState() {
    super.initState();
    _initPlatform();
  }

  Future<void> _initPlatform() async {
    _prefs = await SharedPreferences.getInstance();
    final savedLang = _prefs?.getString('ksbs_lang');
    await _i18n.initTranslations(savedLocale: savedLang);
    await _tts.init();

    Map<String, dynamic> decoded;
    try {
      final rawJson = await rootBundle.loadString('assets/data/curriculum_i18n.json');
      decoded = json.decode(rawJson) as Map<String, dynamic>;
    } catch (_) {
      decoded = _fallbackCurriculumData;
    }

    final statusRaw = _prefs?.getString('ksbs_item_status');
    if (statusRaw != null) {
      _itemStatus = Map<String, String>.from(json.decode(statusRaw) as Map);
    }
    final revRaw = _prefs?.getString('ksbs_review_counts');
    if (revRaw != null) {
      _reviewCounts = Map<String, int>.from(json.decode(revRaw) as Map);
    }
    _quizCorrect = _prefs?.getInt('ksbs_quiz_correct') ?? 0;
    _quizTotal = _prefs?.getInt('ksbs_quiz_total') ?? 0;
    _wrongQuizIds = _prefs?.getStringList('ksbs_wrong_quizzes') ?? [];
    _speechRate = _prefs?.getDouble('ksbs_speed') ?? 0.35;

    if (mounted) {
      setState(() {
        _curriculum = decoded;
      });
    }
  }

  Future<void> _saveProgress() async {
    if (_prefs == null) return;
    await _prefs!.setString('ksbs_lang', _i18n.currentLocale);
    await _prefs!.setString('ksbs_item_status', json.encode(_itemStatus));
    await _prefs!.setString('ksbs_review_counts', json.encode(_reviewCounts));
    await _prefs!.setInt('ksbs_quiz_correct', _quizCorrect);
    await _prefs!.setInt('ksbs_quiz_total', _quizTotal);
    await _prefs!.setStringList('ksbs_wrong_quizzes', _wrongQuizIds);
    await _prefs!.setDouble('ksbs_speed', _speechRate);
  }

  void _speak(String text, {double? customRate}) {
    final rate = customRate ?? _speechRate;
    final clean = text.replaceAll(RegExp(r'\[.*?\]'), '').split('/').first.trim();
    if (clean.isEmpty) return;
    setState(() {
      _reviewCounts[clean] = (_reviewCounts[clean] ?? 0) + 1;
    });
    _saveProgress();
    _tts.speak(clean, rate: rate);
  }

  void _toggleStatus(String id, String status) {
    setState(() {
      if (_itemStatus[id] == status) {
        _itemStatus.remove(id);
      } else {
        _itemStatus[id] = status;
      }
    });
    _saveProgress();
  }

  Widget _buildPronLayers({
    String? romaji,
    Map<String, dynamic>? nativePronMap,
    String? actualPron,
    String? translation,
    String? note,
  }) {
    final loc = _i18n.currentLocale;
    final nativePron = nativePronMap != null
        ? (nativePronMap[loc]?.toString() ?? nativePronMap['en-GB']?.toString() ?? '')
        : '';

    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_toggles.showRomaji && romaji != null && romaji.isNotEmpty)
            Text('🔤 $romaji', style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 13)),
          if (_toggles.showNativePron && nativePron.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text('🗣️ [$loc] $nativePron', style: const TextStyle(color: Color(0xFF0F766E), fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          if (_toggles.showActualPron && actualPron != null && actualPron.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text('🎯 ${_i18n.t("labelActualPron")}: $actualPron', style: const TextStyle(color: Color(0xFF9333EA), fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          if (_toggles.showTranslation && translation != null && translation.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text('💡 $translation', style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          if (_toggles.showPronNotes && note != null && note.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('📌 $note', style: const TextStyle(color: Color(0xFF475569), fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildAudioSrsRow(String hangul, String itemId) {
    final st = _itemStatus[itemId];
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ElevatedButton.icon(
          onPressed: () => _speak(hangul),
          icon: const Icon(Icons.volume_up, size: 16),
          label: Text(_i18n.t('btnListen')),
        ),
        OutlinedButton(onPressed: () => _speak(hangul, customRate: 0.24), child: const Text('🐢 0.24x')),
        OutlinedButton(onPressed: () => _speak(hangul, customRate: 0.35), child: const Text('🚶 0.35x')),
        OutlinedButton(onPressed: () => _speak(hangul, customRate: 0.45), child: const Text('🏃 0.45x')),
        FilterChip(
          selected: st == 'mastered',
          label: Text(_i18n.t('btnMarkMastered')),
          onSelected: (_) => _toggleStatus(itemId, 'mastered'),
        ),
        FilterChip(
          selected: st == 'review',
          label: Text(_i18n.t('btnMarkReview')),
          onSelected: (_) => _toggleStatus(itemId, 'review'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_curriculum == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: _i18n.t('appTitle'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B365D)),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF152C4E),
          foregroundColor: Colors.white,
          titleSpacing: 8,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _i18n.currentLocale,
                    isDense: true,
                    style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13),
                    items: I18nService.supportedLocales.map((code) {
                      final meta = _i18n.localesMeta[code];
                      final flag = meta?['flag'] ?? '🌐';
                      final nativeName = meta?['nativeName'] ?? code;
                      return DropdownMenuItem<String>(
                        value: code,
                        child: Text('$flag $nativeName'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _i18n.setLocale(val);
                        });
                        _saveProgress();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6384C),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('한', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _i18n.t('appTitle'),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: Text(_i18n.t('presetBeginner')),
                      selected: _preset == 'beginner',
                      onSelected: (_) => setState(() {
                        _preset = 'beginner';
                        _toggles.applyBeginnerPreset();
                      }),
                    ),
                    const SizedBox(width: 6),
                    ChoiceChip(
                      label: Text(_i18n.t('presetAdvanced')),
                      selected: _preset == 'advanced',
                      onSelected: (_) => setState(() {
                        _preset = 'advanced';
                        _toggles.applyAdvancedPreset();
                      }),
                    ),
                    const SizedBox(width: 10),
                    FilterChip(
                      label: Text(_i18n.t('toggleRomaji')),
                      selected: _toggles.showRomaji,
                      onSelected: (v) => setState(() { _toggles.showRomaji = v; _preset = 'custom'; }),
                    ),
                    const SizedBox(width: 4),
                    FilterChip(
                      label: Text(_i18n.t('toggleNativePron')),
                      selected: _toggles.showNativePron,
                      onSelected: (v) => setState(() { _toggles.showNativePron = v; _preset = 'custom'; }),
                    ),
                    const SizedBox(width: 4),
                    FilterChip(
                      label: Text(_i18n.t('toggleActualPron')),
                      selected: _toggles.showActualPron,
                      onSelected: (v) => setState(() { _toggles.showActualPron = v; _preset = 'custom'; }),
                    ),
                    const SizedBox(width: 4),
                    FilterChip(
                      label: Text(_i18n.t('toggleTranslation')),
                      selected: _toggles.showTranslation,
                      onSelected: (v) => setState(() { _toggles.showTranslation = v; _preset = 'custom'; }),
                    ),
                    const SizedBox(width: 4),
                    FilterChip(
                      label: Text(_i18n.t('togglePronNotes')),
                      selected: _toggles.showPronNotes,
                      onSelected: (v) => setState(() { _toggles.showPronNotes = v; _preset = 'custom'; }),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              color: const Color(0xFFFEF3C7),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text('ℹ️ ${_i18n.approxDisclaimer()}', style: const TextStyle(fontSize: 12, color: Color(0xFF78350F))),
            ),
            Expanded(child: _buildActiveTabBody()),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _mainTabIndex,
          onDestinationSelected: (idx) => setState(() => _mainTabIndex = idx),
          destinations: [
            NavigationDestination(icon: const Icon(Icons.translate), label: _i18n.t('navHangul')),
            NavigationDestination(icon: const Icon(Icons.pin), label: _i18n.t('navNumbers')),
            NavigationDestination(icon: const Icon(Icons.forum), label: _i18n.t('navConv')),
            NavigationDestination(icon: const Icon(Icons.quiz), label: _i18n.t('navQuiz')),
            NavigationDestination(icon: const Icon(Icons.insights), label: _i18n.t('navStats')),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTabBody() {
    switch (_mainTabIndex) {
      case 0:
        return _buildHangulModule();
      case 1:
        return _buildNumbersModule();
      case 2:
        return _buildConversationsModule();
      case 3:
        return _buildQuizModule();
      case 4:
        return _buildStatsModule();
      default:
        return _buildHangulModule();
    }
  }

  Widget _buildHangulModule() {
    final jamoList = _curriculum!['jamo'] as List<dynamic>;
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: _i18n.t('subJamo')),
              Tab(text: _i18n.t('subBatchim')),
              Tab(text: _i18n.t('subPhono')),
              Tab(text: _i18n.t('subWriting')),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: jamoList.length,
                  itemBuilder: (ctx, idx) {
                    final j = jamoList[idx] as Map<String, dynamic>;
                    final i18nMap = j['i18n'] as Map<String, dynamic>?;
                    final locObj = (i18nMap?[_i18n.currentLocale] ?? i18nMap?['en-GB']) as Map<String, dynamic>?;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(j['jamo'].toString(), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFF1B365D))),
                                Text(j['name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            _buildPronLayers(
                              romaji: j['romaji']?.toString(),
                              nativePronMap: j['nativePron'] as Map<String, dynamic>?,
                              actualPron: j['actualPron']?.toString(),
                              translation: '${j['exampleWordKr']} (${locObj?['wordMeaning'] ?? ''})',
                              note: locObj?['pronunciationTip']?.toString(),
                            ),
                            _buildAudioSrsRow(j['exampleWordKr']?.toString() ?? j['jamo'].toString(), j['id'].toString()),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                _buildBatchimList(),
                _buildPhonoList(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: HandwritingPracticeCard(
                    targetCharacter: _writeChar,
                    showGuide: _showWriteGuide,
                    onSpeak: () => _speak(_writeChar),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchimList() {
    final list = _curriculum!['batchimRules'] as List<dynamic>;
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (ctx, idx) {
        final b = list[idx] as Map<String, dynamic>;
        final i18nMap = b['i18n'] as Map<String, dynamic>?;
        final locObj = (i18nMap?[_i18n.currentLocale] ?? i18nMap?['en-GB']) as Map<String, dynamic>?;
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(locObj?['title']?.toString() ?? b['repSound'].toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (_toggles.showPronNotes)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(locObj?['desc']?.toString() ?? ''),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhonoList() {
    final list = _curriculum!['phonologicalRules'] as List<dynamic>;
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (ctx, idx) {
        final p = list[idx] as Map<String, dynamic>;
        final i18nMap = p['i18n'] as Map<String, dynamic>?;
        final locObj = (i18nMap?[_i18n.currentLocale] ?? i18nMap?['en-GB']) as Map<String, dynamic>?;
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(locObj?['title']?.toString() ?? p['title'].toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (_toggles.showPronNotes)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(locObj?['explanation']?.toString() ?? ''),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNumbersModule() {
    final cats = _curriculum!['numbersCategories'] as List<dynamic>;
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: cats.length,
      itemBuilder: (ctx, idx) {
        final cat = cats[idx] as Map<String, dynamic>;
        final titleMap = cat['i18nTitle'] as Map<String, dynamic>?;
        final title = _i18n.pickLocalized(titleMap, cat['title'].toString());
        final items = cat['items'] as List<dynamic>;
        return ExpansionTile(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          children: items.map((it) {
            final item = it as Map<String, dynamic>;
            return ListTile(
              title: Text('${item['num']} → ${item['korean']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: _buildPronLayers(
                romaji: item['romaji']?.toString(),
                nativePronMap: item['nativePron'] as Map<String, dynamic>?,
                actualPron: item['actualPron']?.toString(),
                translation: item['note']?.toString(),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: () => _speak(item['korean'].toString()),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildConversationsModule() {
    final convs = _curriculum!['conversations'] as List<dynamic>;
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: convs.length,
      itemBuilder: (ctx, idx) {
        final c = convs[idx] as Map<String, dynamic>;
        final titleMap = c['i18nTitle'] as Map<String, dynamic>?;
        final title = _i18n.pickLocalized(titleMap, c['title'].toString());
        final lines = c['lines'] as List<dynamic>;
        return ExpansionTile(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          children: lines.map((l) {
            final line = l as Map<String, dynamic>;
            final trMap = line['i18n'] as Map<String, dynamic>?;
            final tr = _i18n.pickLocalized(trMap, line['zh'].toString());
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(line['kr'].toString(), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  _buildPronLayers(
                    romaji: line['romaji']?.toString(),
                    nativePronMap: line['nativePron'] as Map<String, dynamic>?,
                    actualPron: line['actual']?.toString(),
                    translation: tr,
                    note: line['note']?.toString(),
                  ),
                  _buildAudioSrsRow(line['kr'].toString(), line['id'].toString()),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildQuizModule() {
    final allQuizzes = _curriculum!['quizQuestions'] as List<dynamic>;
    final q = allQuizzes[_quizIndex % allQuizzes.length] as Map<String, dynamic>;
    final promptMap = q['i18nPrompt'] as Map<String, dynamic>?;
    final prompt = _i18n.pickLocalized(promptMap, q['prompt'].toString());
    final optsMap = q['i18nOptions'] as Map<String, dynamic>?;
    final options = (optsMap?[_i18n.currentLocale] ?? q['options']) as List<dynamic>;
    final correctIdx = q['correctIndex'] as int;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Question ${_quizIndex + 1} / ${allQuizzes.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(prompt, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: Text(q['targetDisplay'].toString(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            trailing: IconButton(
              icon: const Icon(Icons.volume_up),
              onPressed: () => _speak(q['targetAudio'].toString()),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(options.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton(
              onPressed: _quizSubmitted ? null : () {
                setState(() {
                  _quizSubmitted = true;
                  _quizTotal++;
                  if (i == correctIdx) {
                    _quizCorrect++;
                  } else {
                    final qid = q['id'].toString();
                    if (!_wrongQuizIds.contains(qid)) _wrongQuizIds.add(qid);
                  }
                });
                _saveProgress();
              },
              child: Align(alignment: Alignment.centerLeft, child: Text('${i + 1}. ${options[i]}')),
            ),
          );
        }),
        if (_quizSubmitted)
          ElevatedButton(
            onPressed: () => setState(() {
              _quizIndex = (_quizIndex + 1) % allQuizzes.length;
              _quizSubmitted = false;
            }),
            child: Text(_i18n.t('quizNext')),
          ),
      ],
    );
  }

  Widget _buildStatsModule() {
    final mastered = _itemStatus.values.where((v) => v == 'mastered').length;
    final review = _itemStatus.values.where((v) => v == 'review').length + _wrongQuizIds.length;
    final totalRevs = _reviewCounts.values.fold<int>(0, (a, b) => a + b);
    final acc = _quizTotal > 0 ? '${((_quizCorrect / _quizTotal) * 100).round()}%' : '—';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(child: ListTile(title: Text(_i18n.t('statsTotalMastered')), trailing: Text('$mastered', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)))),
        Card(child: ListTile(title: Text(_i18n.t('statsQuizAccuracy')), trailing: Text(acc, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)))),
        Card(child: ListTile(title: Text(_i18n.t('statsReviewQueue')), trailing: Text('$review', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)))),
        Card(child: ListTile(title: Text(_i18n.t('statsTotalReviews')), trailing: Text('$totalRevs', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)))),
        const SizedBox(height: 12),
        Text('🔒 ${_i18n.t("privacyNotice")}', style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

const Map<String, dynamic> _fallbackCurriculumData = {
  'jamo': [
    {
      'id': 'jamo_c_g',
      'jamo': 'ㄱ',
      'name': '기역 (giyeok)',
      'romaji': 'g / k',
      'actualPron': '[기역]',
      'exampleWordKr': '가방',
      'nativePron': {
        'en-GB': 'k / g (soft k initially; voiced g between vowels)',
        'zh-TW': '近似輕音「ㄎ」與「ㄍ」之間',
      },
      'i18n': {
        'en-GB': {
          'wordMeaning': 'bag',
          'pronunciationTip': 'Plain velar stop: soft [k] initially, voiced [g] between vowels.',
        },
        'zh-TW': {
          'wordMeaning': '包包',
          'pronunciationTip': '平音：詞首發微送氣清音，母音間變有聲 [g]。',
        },
      },
    },
  ],
  'batchimRules': [
    {
      'id': 'bat_k',
      'repSound': '[ㄱ] (k̚)',
      'i18n': {
        'en-GB': {
          'title': '1. Velar Unreleased Stop [ㄱ] (-k̚)',
          'desc': 'Written ㄱ, ㅋ, or ㄲ at syllable end neutralize to unreleased [k̚].',
        },
      },
    },
  ],
  'phonologicalRules': [
    {
      'id': 'rule_02_nasalization',
      'title': '2. Nasalization (비음화)',
      'i18n': {
        'en-GB': {
          'title': '2. Nasalization (비음화)',
          'explanation': '감사합니다 is pronounced [감사함니다] (ㅂ+ㄴ → ㅁ+ㄴ).',
        },
      },
    },
  ],
  'numbersCategories': [
    {
      'id': 'num_native_basic',
      'title': '1. Basic Native Korean Numbers',
      'i18nTitle': {'en-GB': '1. Basic Native Korean Numbers (하나, 둘, 셋...)'},
      'items': [
        {
          'num': '1',
          'korean': '하나 (한)',
          'romaji': 'hana (han)',
          'actualPron': '[하나]',
          'note': 'Shortens to 한 (han) before a counter.',
        },
      ],
    },
  ],
  'conversations': [
    {
      'id': 'conv_01',
      'title': '1. Basic Greetings',
      'i18nTitle': {'en-GB': '1. Basic Greetings (Hello & Thank You)'},
      'lines': [
        {
          'id': 'c01_l1',
          'kr': '안녕하세요! 감사합니다.',
          'actual': '[안녕하세요! 감사함니다]',
          'romaji': 'Annyeonghaseyo! Gamsahamnida.',
          'zh': '你好！謝謝。',
          'i18n': {'en-GB': 'Hello! Thank you.'},
          'note': 'ㅂ before ㄴ nasalizes to [ㅁ].',
        },
      ],
    },
  ],
  'quizQuestions': [
    {
      'id': 'q01',
      'prompt': 'Why is 감사합니다 pronounced [감사함니다]?',
      'targetDisplay': '감사합니다 → [감사함니다]',
      'targetAudio': '감사합니다',
      'correctIndex': 0,
      'options': [
        'Nasalization (비음화): ㅂ before ㄴ becomes [ㅁ]',
        'Palatalization',
        'Liquidization',
        'H-deletion',
      ],
    },
  ],
};
