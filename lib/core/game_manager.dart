import 'package:flutter/material.dart';

enum GameState {
  initial, // 遊戲初始狀態
  playing, // 遊戲進行中
  won, // 遊戲勝利
  lost, // 遊戲失敗
}

/// 遊戲管理器類別，負責管理整個遊戲的核心邏輯和狀態。
///
/// 主要功能：
/// * 管理遊戲狀態（初始、進行中、勝利、失敗）
/// * 追蹤遊戲數據（地雷數量、旗子數量、已揭露格子）
/// * 控制遊戲流程（開始、重置、結束）
/// * 提供遊戲時間追蹤
///

class GameManager with ChangeNotifier {
  // 確保manager只有單一實例
  static final GameManager _instance = GameManager._internal();

  factory GameManager() {
    return _instance;
  }

  GameManager._internal();

  // 遊戲狀態
  GameState _gameState = GameState.initial;
  int _mineCount = 10; // 預設地雷數
  int _boardSize = 9; // 預設板面大小
  int _flaggedCount = 0;
  int _revealedCount = 0;
  Duration _gameTime = Duration.zero;
  bool _isFirstClick = true;

  // Getters
  GameState get gameState => _gameState;
  int get mineCount => _mineCount;
  int get boardSize => _boardSize;
  int get flaggedCount => _flaggedCount;
  int get revealedCount => _revealedCount;
  Duration get gameTime => _gameTime;
  bool get isFirstClick => _isFirstClick;

  // 重置遊戲
  void resetGame() {
    _gameState = GameState.initial;
    _flaggedCount = 0;
    _revealedCount = 0;
    _gameTime = Duration.zero;
    _isFirstClick = true;
    notifyListeners();
  }

  // 設置遊戲難度
  void setDifficulty({required int mineCount, required int boardSize}) {
    _mineCount = mineCount;
    _boardSize = boardSize;
    resetGame();
  }

  // 開始遊戲
  void startGame() {
    if (_gameState == GameState.initial) {
      _gameState = GameState.playing;
      notifyListeners();
    }
  }

  /// 更新已插旗的格子數量
  /// @param flagCount 目前場上插旗的總數
  void updateFlaggedCount(int flagCount) {
    _flaggedCount = flagCount;
    notifyListeners();
  }

  /// 更新已揭露的格子數量
  /// @param revealedCellCount 目前已揭露的格子總數
  void updateRevealedCount(int revealedCellCount) {
    _revealedCount = revealedCellCount;
    // 檢查是否獲勝（當已揭露格子數量 >= 非地雷格子總數時）
    if (_gameState == GameState.playing &&
        _revealedCount >= (_boardSize * _boardSize - _mineCount)) {
      _gameState = GameState.won;
    }
    notifyListeners();
  }

  // 遊戲結束
  void gameOver(bool isWin) {
    _gameState = isWin ? GameState.won : GameState.lost;
    notifyListeners();
  }

  /// 處理遊戲首次點擊的控制邏輯
  /// 
  /// 負責：
  /// * 控制遊戲的初始啟動時機
  /// * 確保遊戲只會在第一次點擊後開始
  /// * 防止遊戲在準備完成前被執行
  /// 
  /// 設計考量：
  /// * 避免在遊戲開始前就產生地雷，防止第一下就踩到地雷
  /// * 作為遊戲狀態的轉換點：從 [GameState.initial] 到 [GameState.playing]
  /// 
  /// 功能流程：
  /// 1. 檢查是否為首次點擊
  /// 2. 設置首次點擊標記為 false
  /// 3. 觸發遊戲開始
  /// 
  /// 使用時機：
  /// * 當玩家第一次點擊遊戲格子時呼叫
  /// * 在重置遊戲後的第一次點擊時呼叫
  void handleFirstClick() {
    if (_isFirstClick) {
      _isFirstClick = false;
      startGame();
    }
  }

  // 更新遊戲時間
  void updateGameTime(Duration time) {
    _gameTime = time;
    notifyListeners();
  }
}
