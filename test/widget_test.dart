import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dermalogic_v3/main.dart';

void main() {
  testWidgets('App lance correctement', (WidgetTester tester) async {
    // Taille mobile pour eviter le layout desktop (nav bar overflow)
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: DermaLogicApp()),
    );
    await tester.pump();

    // Verifier que MaterialApp.router est bien cree
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
