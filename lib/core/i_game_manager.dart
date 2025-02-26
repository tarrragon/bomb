import 'package:flutter/foundation.dart';
import 'package:bomb/core/game_manager.dart';

/// 遊戲管理器接口
///
/// 定義遊戲管理器應該提供的所有方法和屬性
abstract class IGameManager extends ChangeNotifier {
  // 屬性
  GameState get gameState;
  int get mineCount;
  int get boardSize;
  int get flaggedCount;
  int get revealedCount;
  Duration get gameTime;
  bool get isFirstClick;
  bool get isDisposed;

  // 方法
  void resetGame();
  void setDifficulty({required int mineCount, required int boardSize});
  void startGame();
  void updateFlaggedCount(int flagCount);
  void updateRevealedCount(int revealedCellCount);
  void gameOver(bool isWin);
  void handleFirstClick();
  void updateGameTime(Duration time);
  void initializeGame();
}
