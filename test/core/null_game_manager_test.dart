import 'package:flutter_test/flutter_test.dart';
import 'package:bomb/core/null_game_manager.dart';
import 'package:bomb/core/game_manager.dart';

void main() {
  group('NullGameManager 測試', () {
    late NullGameManager nullManager;

    setUp(() {
      nullManager = NullGameManager();
    });

    test('應該提供默認的屬性值', () {
      expect(nullManager.gameState, equals(GameState.initial));
      expect(nullManager.mineCount, equals(10));
      expect(nullManager.boardSize, equals(9));
      expect(nullManager.flaggedCount, equals(0));
      expect(nullManager.revealedCount, equals(0));
      expect(nullManager.gameTime, equals(Duration.zero));
      expect(nullManager.isFirstClick, isTrue);
      expect(nullManager.isDisposed, isFalse);
    });

    test('方法調用不應該拋出異常', () {
      // 測試所有方法
      expect(() => nullManager.resetGame(), returnsNormally);
      expect(
        () => nullManager.setDifficulty(mineCount: 15, boardSize: 12),
        returnsNormally,
      );
      expect(() => nullManager.startGame(), returnsNormally);
      expect(() => nullManager.updateFlaggedCount(5), returnsNormally);
      expect(() => nullManager.updateRevealedCount(20), returnsNormally);
      expect(() => nullManager.gameOver(true), returnsNormally);
      expect(() => nullManager.handleFirstClick(), returnsNormally);
      expect(
        () => nullManager.updateGameTime(Duration(seconds: 10)),
        returnsNormally,
      );
    });

    test('應該是單例', () {
      final anotherInstance = NullGameManager();
      expect(identical(nullManager, anotherInstance), isTrue);
    });
  });
}
