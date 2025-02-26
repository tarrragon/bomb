import 'package:flutter/foundation.dart';
import 'package:bomb/core/game_manager.dart';
import 'package:bomb/core/i_game_manager.dart';

/// 空遊戲管理器，實現與 GameManager 相同的接口但提供安全的默認行為
///
/// 職責：
/// * 作為 GameManager 的替代品，當真正的 GameManager 不可用時使用
/// * 提供所有 GameManager 方法的安全默認實現
/// * 避免空指針異常和已釋放對象的訪問
class NullGameManager extends ChangeNotifier implements IGameManager {
  // 單例模式
  static final NullGameManager _instance = NullGameManager._internal();

  factory NullGameManager() {
    return _instance;
  }

  NullGameManager._internal();

  // 實現 GameManager 的所有屬性，提供安全的默認值
  @override
  GameState get gameState => GameState.initial;

  @override
  int get mineCount => 10;

  @override
  int get boardSize => 9;

  @override
  int get flaggedCount => 0;

  @override
  int get revealedCount => 0;

  @override
  Duration get gameTime => Duration.zero;

  @override
  bool get isFirstClick => true;

  @override
  bool get isDisposed => false;

  // 實現 GameManager 的所有方法，提供空實現
  @override
  void resetGame() {}

  @override
  void setDifficulty({required int mineCount, required int boardSize}) {}

  @override
  void startGame() {}

  @override
  void updateFlaggedCount(int flagCount) {}

  @override
  void updateRevealedCount(int revealedCellCount) {}

  @override
  void gameOver(bool isWin) {}

  @override
  void handleFirstClick() {}

  @override
  void updateGameTime(Duration time) {}

  @override
  void initializeGame() {
    // 空實現，不做任何事情
  }
}
