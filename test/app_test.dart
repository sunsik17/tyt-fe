import 'package:flutter_test/flutter_test.dart';
import 'package:tyt/main.dart';

void main() {
  testWidgets('앱이 테마를 적용한 첫 화면을 띄운다', (tester) async {
    await tester.pumpWidget(const TytApp());

    expect(find.text('TYT'), findsOneWidget);
  });
}
