import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mock/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login screen renders organizer app', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const StudentOrganizerApp());
    await tester.pumpAndSettle();

    expect(find.text('Smart Organizer'), findsOneWidget);
    expect(find.text('LOGIN AS STUDENT'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
