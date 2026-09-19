import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:milagres_da_fe_app/main.dart';

void main() {
  testWidgets('renderiza a tela inicial estática', (WidgetTester tester) async {
    await tester.pumpWidget(const MilagresDaFeApp());

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text(AppInfo.welcome), findsOneWidget);
    expect(find.text('Igreja Evangélica'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Novidades'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Novidades'), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('renderiza bem em tela larga', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MilagresDaFeApp());
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
