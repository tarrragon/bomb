import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:bomb/core/game_board.dart';
import 'package:bomb/core/game_manager.dart';
import 'package:bomb/core/i_game_manager.dart';
import 'package:bomb/providers/game_board_state.dart';

void main() {
  group('GameManager 更新測試', () {
    testWidgets('GameManager 更新時應該正確更新難度', (tester) async {
      // 創建一個新的 GameManager 實例，避免使用單例
      final gameManager = GameManager.createForTesting();

      // 構建一個簡單的 Widget 樹，只使用 GameManager
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<IGameManager>.value(
            value: gameManager,
            child: Builder(
              builder: (context) {
                final manager = Provider.of<IGameManager>(context);

                return Column(
                  children: [
                    Text(
                      'Size: ${manager.boardSize}, Mines: ${manager.mineCount}',
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // 更新 GameManager
                        (manager as GameManager).setDifficulty(
                          mineCount: 15,
                          boardSize: 12,
                        );
                      },
                      child: Text('Change Difficulty'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // 驗證初始狀態
      expect(find.text('Size: 9, Mines: 10'), findsOneWidget);

      // 點擊按鈕更改難度
      await tester.tap(find.text('Change Difficulty'));
      await tester.pump();

      // 驗證更新後的狀態
      expect(find.text('Size: 12, Mines: 15'), findsOneWidget);
    });
  });

  group('GameBoardState 響應測試', () {
    testWidgets('GameBoardState 應該正確響應 GameManager 的更新', (tester) async {
      // 創建一個新的 GameManager 實例，避免使用單例
      final gameManager = GameManager.createForTesting();

      // 創建一個 GameBoard 實例
      final gameBoard = GameBoard(
        boardSize: gameManager.boardSize,
        mineCount: gameManager.mineCount,
      );

      // 構建一個簡單的 Widget 樹，使用 GameManager 和 GameBoardState
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<IGameManager>.value(value: gameManager),
              ChangeNotifierProxyProvider<IGameManager, GameBoardState>(
                create:
                    (_) => GameBoardState(
                      gameBoard: gameBoard,
                      gameManager: gameManager,
                    ),
                update:
                    (_, manager, previous) =>
                        GameBoardState.updateFromGameManager(
                          gameManager: manager,
                          previous: previous,
                        ),
              ),
            ],
            child: Builder(
              builder: (context) {
                final boardState = Provider.of<GameBoardState>(context);

                return Column(
                  children: [Text('Board Size: ${boardState.boardSize}')],
                );
              },
            ),
          ),
        ),
      );

      // 驗證初始狀態
      expect(find.text('Board Size: 9'), findsOneWidget);

      // 更新 GameManager
      gameManager.setDifficulty(mineCount: 15, boardSize: 12);
      await tester.pump();

      // 驗證 GameBoardState 是否正確響應
      expect(find.text('Board Size: 12'), findsOneWidget);
    });
  });
}
