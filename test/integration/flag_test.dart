import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bomb/core/game_manager.dart';
import 'package:bomb/core/game_board.dart';
import 'package:bomb/providers/game_board_state.dart';

void main() {
  group('旗子功能測試', () {
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

    test('應該能夠在格子上插旗和移除旗子', () {
      if (kDebugMode) {
        print('test: 開始測試');
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

      // 選擇一個未揭露的格子來插旗
      int flagRow = -1;
      int flagCol = -1;

      // 尋找一個未揭露的格子
      for (int i = 0; i < gameBoard.boardSize; i++) {
        for (int j = 0; j < gameBoard.boardSize; j++) {
          if (!gameBoard.board[i][j].isRevealed) {
            flagRow = i;
            flagCol = j;
            break;
          }
        }
        if (flagRow != -1) break;
      }

      if (flagRow == -1 || flagCol == -1) {
        fail('無法找到未揭露的格子來插旗');
      }

      if (kDebugMode) {
        print('test: 選擇位置 ($flagRow, $flagCol) 來插旗');
      }

      // 初始狀態應該沒有旗子
      expect(gameBoard.getFlaggedCount(), equals(0), reason: '初始狀態應該沒有旗子');

      // 插旗
      gameBoardState.handleCellFlag(flagRow, flagCol);

      // 檢查旗子數量
      expect(gameBoard.getFlaggedCount(), equals(1), reason: '插旗後應該有一個旗子');
      expect(
        gameBoard.board[flagRow][flagCol].isFlagged,
        isTrue,
        reason: '該格子應該被標記為有旗子',
      );

      // 再次點擊移除旗子
      gameBoardState.handleCellFlag(flagRow, flagCol);

      // 檢查旗子數量
      expect(gameBoard.getFlaggedCount(), equals(0), reason: '移除旗子後應該沒有旗子');
      expect(
        gameBoard.board[flagRow][flagCol].isFlagged,
        isFalse,
        reason: '該格子應該被標記為沒有旗子',
      );

      if (kDebugMode) {
        print('test: 測試結束');
      }
    });
  });
}
