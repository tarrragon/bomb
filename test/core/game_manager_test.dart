import 'package:flutter_test/flutter_test.dart';
import 'package:bomb/core/game_manager.dart';

void main() {
  late GameManager gameManager;

  setUp(() {
    gameManager = GameManager();
  });

  group('GameManager 基礎測試', () {
    test('Singleton 實例應該保持一致', () {
      final instance1 = GameManager();
      final instance2 = GameManager();
      expect(identical(instance1, instance2), true);
    });

    test('初始狀態應該正確', () {
      expect(gameManager.gameState, equals(GameState.initial));
      expect(gameManager.mineCount, equals(10));
      expect(gameManager.boardSize, equals(9));
      expect(gameManager.flaggedCount, equals(0));
      expect(gameManager.revealedCount, equals(0));
      expect(gameManager.isFirstClick, equals(true));
    });
  });

  group('GameManager 操作測試', () {
    test('設置難度應該更新遊戲設定', () {
      gameManager.setDifficulty(mineCount: 15, boardSize: 12);
      expect(gameManager.mineCount, equals(15));
      expect(gameManager.boardSize, equals(12));
      expect(gameManager.gameState, equals(GameState.initial));
    });

    test('開始遊戲應該切換狀態', () {
      gameManager.startGame();
      expect(gameManager.gameState, equals(GameState.playing));
    });

    test('遊戲結束應該設置正確狀態', () {
      gameManager.gameOver(true);
      expect(gameManager.gameState, equals(GameState.won));

      gameManager.gameOver(false);
      expect(gameManager.gameState, equals(GameState.lost));
    });
  });
}
