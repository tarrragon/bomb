import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:bomb/core/game_manager.dart';
import 'package:bomb/providers/game_provider.dart';

void main() {
  testWidgets('GameProvider 應該正確提供 GameManager 實例', (
    WidgetTester tester,
  ) async {
    late GameManager providedManager;

    await tester.pumpWidget(
      GameProvider(
        child: Builder(
          builder: (context) {
            providedManager = context.read<GameManager>();
            return const SizedBox();
          },
        ),
      ),
    );

    expect(providedManager, isNotNull);
    expect(providedManager, isA<GameManager>());
  });
}
