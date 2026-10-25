import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:korean_step_by_step/models/curriculum_models.dart';

void main() {
  test('Curriculum i18n JSON contains all 11 locales and 5 display toggles work independently', () {
    final file = File('assets/data/curriculum_i18n.json');
    expect(file.existsSync(), isTrue);
    final data = json.decode(file.readAsStringSync()) as Map<String, dynamic>;

    expect((data['jamo'] as List).length, equals(40));
    expect((data['batchimRules'] as List).length, equals(8));
    expect((data['phonologicalRules'] as List).length, equals(7));
    expect((data['numbersCategories'] as List).length, equals(12));
    expect((data['counters'] as List).length, equals(19));
    expect((data['conversations'] as List).length, equals(20));
    expect((data['quizQuestions'] as List).length, equals(26));

    final toggles = DisplayToggles();
    toggles.applyAdvancedPreset();
    expect(toggles.showRomaji, isFalse);
    expect(toggles.showNativePron, isFalse);
    expect(toggles.showActualPron, isTrue);

    toggles.applyBeginnerPreset();
    expect(toggles.showRomaji, isTrue);
    expect(toggles.showNativePron, isTrue);
  });
}
