import 'package:flutter/material.dart';
import 'package:bomb/core/game_board.dart';
import 'package:bomb/core/game_manager.dart';
import 'package:bomb/models/base_cell.dart';

/// 遊戲版面狀態管理器
///
/// 負責：
/// * 協調 GameBoard 和 GameManager 之間的互動
/// * 處理遊戲版面的狀態更新
/// * 管理格子的點擊和標記行為
///
/// 設計考量：
/// * 將遊戲邏輯與狀態管理分離：
///   - GameBoard 專注於遊戲版面的核心邏輯
///   - GameManager 負責整體遊戲狀態
///   - 本類別負責協調兩者的互動
///
/// * 確保遊戲狀態的一致性：
///   - 統一管理遊戲進行中的各種狀態變化
///   - 確保玩家操作後的狀態更新正確
///   - 避免遊戲狀態產生衝突
///
/// * 提供介面給遊戲畫面使用：
///   - 封裝遊戲邏輯
///   - 提供API 給畫面元件
class GameBoardState extends ChangeNotifier {
  final GameBoard _gameBoard;
  final GameManager _gameManager;

  GameBoardState({
    required GameBoard gameBoard,
    required GameManager gameManager,
  }) : _gameBoard = gameBoard,
       _gameManager = gameManager;

  /// 處理格子點擊事件
  ///
  /// 流程：
  /// 1. 檢查遊戲是否可以繼續
  /// 2. 處理首次點擊特殊邏輯
  /// 3. 揭露格子並更新狀態
  /// 4. 檢查勝負條件
  void handleCellTap(int row, int col) {
    if (_gameManager.gameState == GameState.lost ||
        _gameManager.gameState == GameState.won) {
      return;
    }

    // 處理第一次點擊
    if (_gameManager.isFirstClick) {
      _gameManager.handleFirstClick();
      _gameBoard.initializeMines(row, col);
    }

    // 揭露格子
    _gameBoard.revealCell(row, col);

    // 更新遊戲狀態
    if (_gameBoard.board[row][col].isMine) {
      _gameBoard.revealAllMines();
      _gameManager.gameOver(false);
    } else {
      _gameManager.updateRevealedCount(_gameBoard.getRevealedCount());

      // 檢查是否獲勝
      if (_gameBoard.checkWin()) {
        _gameManager.gameOver(true);
      }
    }
  }

  /// 處理格子標記事件
  ///
  /// 功能：
  /// * 切換格子的標記狀態
  /// * 更新已標記的格子計數
  void handleCellFlag(int row, int col) {
    if (_gameManager.gameState == GameState.lost ||
        _gameManager.gameState == GameState.won) {
      return;
    }

    _gameBoard.toggleFlag(row, col);
    _gameManager.updateFlaggedCount(_gameBoard.getFlaggedCount());
  }

  /// 重置遊戲版面
  ///
  /// 執行：
  /// 1. 建立新的遊戲版面
  /// 2. 更新現有版面狀態
  /// 3. 重置遊戲管理器
  void resetBoard() {
    final newBoard = GameBoard(
      boardSize: _gameManager.boardSize,
      mineCount: _gameManager.mineCount,
    );

    // 更新遊戲板狀態
    _gameBoard.board.clear();
    _gameBoard.board.addAll(newBoard.board);

    // 重置遊戲狀態
    _gameManager.resetGame();
    notifyListeners();
  }

  // 取得特定位置的格子
  BaseCell getCell(int row, int col) => _gameBoard.board[row][col];

  // 檢查遊戲是否已初始化
  bool get isInitialized => _gameBoard.isInitialized;

  // 取得版面大小
  int get boardSize => _gameBoard.boardSize;

  // 取得地雷數量
  int get mineCount => _gameBoard.mineCount;

  // 取得已標記的旗子數量
  int get flaggedCount => _gameBoard.getFlaggedCount();

  // 取得已揭露的格子數量
  int get revealedCount => _gameBoard.getRevealedCount();

  // 取得遊戲版面
  GameBoard getGameBoard() => _gameBoard;
}
