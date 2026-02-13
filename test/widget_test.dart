import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:void_surge/app.dart';

void main() {
  testWidgets('App launches with home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: VoidSurgeApp()),
    );

    expect(find.text('VOID'), findsOneWidget);
    expect(find.text('SURGE'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);
  });
}
