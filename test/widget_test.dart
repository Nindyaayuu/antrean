import 'package:flutter_test/flutter_test.dart';
import 'package:antrean_percetakan/main.dart';

void main() {
  testWidgets('HomeScreen shows list of antrean', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Daftar Antrean'), findsOneWidget);
    expect(find.textContaining('Budi'), findsOneWidget);
    expect(find.textContaining('Sari'), findsOneWidget);
  });
}
