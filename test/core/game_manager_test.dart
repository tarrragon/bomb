import 'package:flutter_test/flutter_test.dart';
import 'package:bomb/core/game_manager.dart';

void main() {
  late GameManager gameManager;

  setUp(() {
    gameManager = GameManager();
  });

  group('GameManager 初始狀態測試', () {
    test('初始化時應該有正確的預設值', () {
      expect(gameManager.gameState, equals(GameState.initial));
      expect(gameManager.mineCount, equals(10));
      expect(gameManager.boardSize, equals(9));
      expect(gameManager.flaggedCount, equals(0));
      expect(gameManager.revealedCount, equals(0));
      expect(gameManager.gameTime, equals(Duration.zero));
      expect(gameManager.isFirstClick, isTrue);
    });
  });

  group('GameManager 遊戲流程測試', () {
    test('開始遊戲時狀態應該改變', () {
      gameManager.startGame();
      expect(gameManager.gameState, equals(GameState.playing));
    });

    test('重置遊戲應該回到初始狀態', () {
      gameManager.startGame();
      gameManager.updateFlaggedCount(5);
      gameManager.resetGame();

      expect(gameManager.gameState, equals(GameState.initial));
      expect(gameManager.flaggedCount, equals(0));
      expect(gameManager.isFirstClick, isTrue);
    });

    test('設置難度時應該更新相關參數', () {
      gameManager.setDifficulty(mineCount: 15, boardSize: 12);

      expect(gameManager.mineCount, equals(15));
      expect(gameManager.boardSize, equals(12));
    });
  });

  group('GameManager 遊戲勝負判定測試', () {
    test('揭露所有非地雷格子時應該獲勝', () {
      gameManager.startGame(); // 確保遊戲狀態是 playing
      expect(gameManager.gameState, equals(GameState.playing));

      // 計算需要揭露的格子數（總格子數 - 地雷數）
      final totalCells = gameManager.boardSize * gameManager.boardSize;
      final nonMineCells = totalCells - gameManager.mineCount;

      // 檢查當前已揭露格子數
      expect(gameManager.revealedCount, equals(0));

      // 更新已揭露格子數
      gameManager.updateRevealedCount(nonMineCells);
      expect(gameManager.revealedCount, equals(nonMineCells));

      // 檢查遊戲狀態
      expect(gameManager.gameState, equals(GameState.won));
    });

    // 可以加入不同難度的測試
    test('不同難度下揭露所有非地雷格子時應該獲勝', () {
      // 設置不同的難度
      gameManager.setDifficulty(mineCount: 15, boardSize: 12);
      gameManager.startGame();

      final totalCells = gameManager.boardSize * gameManager.boardSize;
      final nonMineCells = totalCells - gameManager.mineCount;

      gameManager.updateRevealedCount(nonMineCells);
      expect(gameManager.gameState, equals(GameState.won));
    });

    test('觸碰地雷時應該遊戲結束', () {
      gameManager.startGame();
      gameManager.gameOver(false);

      expect(gameManager.gameState, equals(GameState.lost));
    });
  });
}
