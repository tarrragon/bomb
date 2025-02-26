import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bomb/core/game_manager.dart';
import 'package:bomb/core/game_board.dart';
import 'package:bomb/providers/game_board_state.dart';

void main() {
  group('首次點擊測試', () {
    late GameManager gameManager;
    late GameBoard gameBoard;
    late GameBoardState gameBoardState;

    setUp(() {
      // 在測試開始時創建全新的遊戲狀態
      gameManager = GameManager();

      // 確保 GameManager 處於初始狀態
      expect(gameManager.isFirstClick, isTrue, reason: 'GameManager 應該處於初始狀態');
      expect(
        gameManager.gameState,
        equals(GameState.initial),
        reason: 'GameManager 應該處於初始狀態',
      );

      gameBoard = GameBoard(
        boardSize: gameManager.boardSize,
        mineCount: gameManager.mineCount,
      );

      // 確保 GameBoard 處於初始狀態
      expect(gameBoard.isInitialized, isFalse, reason: 'GameBoard 應該處於初始狀態');

      gameBoardState = GameBoardState(
        gameBoard: gameBoard,
        gameManager: gameManager,
      );

      // 確認遊戲狀態已經正確初始化
      if (kDebugMode) {
        print('setUp: 遊戲狀態初始化');
        print('setUp: gameManager.isFirstClick = ${gameManager.isFirstClick}');
        print('setUp: gameManager.gameState = ${gameManager.gameState}');
        print('setUp: gameBoard.isInitialized = ${gameBoard.isInitialized}');
        print('setUp: gameBoard.mineCount = ${gameBoard.mineCount}');
      }
    });

    test('首次點擊應該初始化遊戲', () {
      if (kDebugMode) {
        print('test: 開始測試');
      }
      if (kDebugMode) {
        print('test: gameManager.isFirstClick = ${gameManager.isFirstClick}');
        print('test: gameManager.gameState = ${gameManager.gameState}');
        print('test: gameBoard.isInitialized = ${gameBoard.isInitialized}');
      }

      // 確保遊戲狀態處於初始狀態
      expect(gameManager.isFirstClick, isTrue, reason: 'GameManager 應該處於初始狀態');
      expect(
        gameManager.gameState,
        equals(GameState.initial),
        reason: 'GameManager 應該處於初始狀態',
      );
      expect(gameBoard.isInitialized, isFalse, reason: 'GameBoard 應該處於初始狀態');

      // 選擇一個安全位置
      const int safeRow = 4;
      const int safeCol = 4;

      // 開始遊戲
      gameBoardState.startGame(safeRow, safeCol);

      // 確保遊戲已經初始化
      expect(gameBoard.isInitialized, isTrue, reason: 'GameBoard 應該已經初始化');
      expect(
        gameManager.isFirstClick,
        isFalse,
        reason: 'GameManager.isFirstClick 應該為 false',
      );
      expect(
        gameManager.gameState,
        equals(GameState.playing),
        reason: '遊戲應該在進行中',
      );

      if (kDebugMode) {
        print('test: 遊戲開始後狀態: ${gameManager.gameState}');
        print('test: 已揭露格子數量: ${gameBoard.getRevealedCount()}');
        print('test: 總格子數量: ${gameBoard.boardSize * gameBoard.boardSize}');
      }

      // 點擊一個格子
      gameBoardState.handleCellTap(safeRow, safeCol);

      // 點擊後的狀態
      if (kDebugMode) {
        print('test: 點擊後遊戲狀態: ${gameManager.gameState}');
        print('test: 點擊後已揭露格子數量: ${gameBoard.getRevealedCount()}');
      }

      // 檢查遊戲狀態
      // 注意：點擊後遊戲可能處於進行中或已獲勝狀態，取決於隨機生成的地雷分布
      expect(
        gameManager.gameState == GameState.playing ||
            gameManager.gameState == GameState.won,
        isTrue,
        reason: '點擊後遊戲應該在進行中或已獲勝',
      );

      if (kDebugMode) {
        print('test: 測試結束');
      }
    });
  });
}
