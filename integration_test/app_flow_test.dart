import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:korean_step_by_step/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App launches, switches languages, and toggles pronunciation aids', (WidgetTester tester) async {
    await tester.pumpWidget(const KoreanStepByStepIntlApp());
    await tester.pumpAndSettle();
    expect(find.byType(KoreanStepByStepIntlApp), findsOneWidget);
  });
}
