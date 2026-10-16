import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:netflix_fake/screens/auth_screen.dart';

void main() {
  testWidgets('shows the CineScope authentication form', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AuthScreen()));

    expect(find.text('CineScope'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
  });
}
