import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/i18n_service.dart';
import 'models/curriculum_models.dart';
import 'services/tts_service.dart';
import 'widgets/handwriting_canvas.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KoreanStepByStepIntlApp());
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

  // Combiner state
  int _combInit = 0;
  int _combMed = 0;
  int _combFin = 0;

  // Writing state
  String _writeChar = '한';
  bool _showWriteGuide = true;

  // Progress state
  Map<String, String> _itemStatus = {};
  Map<String, int> _reviewCounts = {};
  int _quizCorrect = 0;
  int _quizTotal = 0;
  List<String> _wrongQuizIds = [];

  // Quiz state
  int _quizIndex = 0;
  int? _selectedOption;
  bool _quizSubmitted = false;
  bool _weakOnlyMode = false;

  @override
  void initState() {
    super.initState();
    _initPlatform();
  }

  Future<void> _initPlatform() async {
    _prefs = await SharedPreferences.getInstance();
    final savedLang = _prefs?.getString('ksbs_lang');
    await _i18n.loadTranslations(savedLocale: savedLang);
    await _tts.init();

    final rawJson = await rootBundle.loadString('assets/data/curriculum_i18n.json');
    final decoded = json.decode(rawJson) as Map<String, dynamic>;

    // Load saved progress & toggles
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
              // Mandatory Top-Left Language Selector
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
                      final meta = _i18n.localesMeta[code] as Map<String, dynamic>?;
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
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('assets/images/app_logo.png', width: 34, height: 34, fit: BoxFit.cover),
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
            // 5 Independent Display Toggles + Presets Bar
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
                    final i18nMap = (j['i18n'] as Map<String, dynamic>?);
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
                  _selectedOption = i;
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
              _selectedOption = null;
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
