import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:bomb/app/game_provider_setup.dart';
import 'package:bomb/core/i_game_manager.dart';
import 'package:bomb/providers/game_board_state.dart';

void main() {
  group('GameProviderSetup 初始化測試', () {
    testWidgets('應該正確初始化 Provider', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameProviderSetup(
            child: Builder(
              builder: (context) {
                final gameManager = Provider.of<IGameManager>(context);
                final gameBoardState = Provider.of<GameBoardState>(context);

                return Column(
                  children: [
                    Text(
                      'Size: ${gameManager.boardSize}, Mines: ${gameManager.mineCount}',
                    ),
                    Text('Game State: ${gameManager.gameState}'),
                    Text('Board Size: ${gameBoardState.boardSize}'),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // 驗證 Provider 是否正確初始化
      expect(find.text('Size: 9, Mines: 10'), findsOneWidget);
      expect(find.text('Game State: GameState.initial'), findsOneWidget);
      expect(find.text('Board Size: 9'), findsOneWidget);
    });
  });
}
