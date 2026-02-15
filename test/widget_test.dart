import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dermalogic_v3/main.dart';

void main() {
  testWidgets('App lance correctement', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: DermaLogicApp()),
    );

    expect(find.text('DermaLogic v3\nMigration Flutter en cours...'), findsOneWidget);
  });
}
