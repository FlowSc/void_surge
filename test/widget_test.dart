import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:void_surge/app.dart';
import 'package:void_surge/core/providers/preferences_provider.dart';

void main() {
  testWidgets('App launches with home screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const VoidSurgeApp(),
      ),
    );

    expect(find.text('VOID'), findsOneWidget);
    expect(find.text('SURGE'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);
  });
}
