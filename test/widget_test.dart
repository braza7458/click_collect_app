import 'package:flutter_test/flutter_test.dart';

import 'package:click_collect_app/main.dart';

void main() {
  testWidgets('Home screen shows the restaurant name and a menu item', (WidgetTester tester) async {
    await tester.pumpWidget(const ClickCollectApp());

    expect(find.text('Les Poulets de Mamie'), findsOneWidget);
    expect(find.text('Le Poulet Rôti'), findsOneWidget);
  });
}
