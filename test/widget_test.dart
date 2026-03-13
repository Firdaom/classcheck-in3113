// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.



import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:classcheck_in/app.dart';
import 'package:classcheck_in/services/attendance_store.dart';

void main() {
  testWidgets('renders dashboard actions', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final store = AttendanceStore();
    await store.initialize();

    await tester.pumpWidget(ClassCheckInApp(store: store));
    await tester.pumpAndSettle();

    expect(find.text('Class Check-in'), findsOneWidget);
    expect(find.text('Check-in'), findsWidgets);
    expect(find.text('Finish class'), findsOneWidget);
  });
}
