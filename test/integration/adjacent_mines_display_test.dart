import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bomb/core/game_manager.dart';
import 'package:bomb/core/game_board.dart';
import 'package:bomb/providers/game_board_state.dart';
import 'package:bomb/models/number_cell.dart';

void main() {
  group('周圍地雷數量顯示測試', () {
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

    test('點擊非地雷格子應該顯示周圍地雷數量', () {
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

      // 尋找一個非地雷格子，且周圍有地雷
      int testRow = -1;
      int testCol = -1;
      int expectedMines = 0;

      // 遍歷所有格子，找到一個未揭露的非地雷格子，且周圍有地雷
      for (int i = 0; i < gameBoard.boardSize; i++) {
        for (int j = 0; j < gameBoard.boardSize; j++) {
          if (!gameBoard.board[i][j].isRevealed &&
              !gameBoard.board[i][j].isMine) {
            // 計算周圍地雷數量
            int adjacentMines = gameBoard.countAdjacentMines(i, j);
            if (adjacentMines > 0) {
              testRow = i;
              testCol = j;
              expectedMines = adjacentMines;
              break;
            }
          }
        }
        if (testRow != -1) break;
      }

      if (testRow == -1 || testCol == -1) {
        fail('無法找到合適的測試格子');
      }

      if (kDebugMode) {
        print('test: 選擇位置 ($testRow, $testCol) 進行測試，預期周圍地雷數量：$expectedMines');
      }

      // 確認格子尚未揭露
      expect(
        gameBoard.board[testRow][testCol].isRevealed,
        isFalse,
        reason: '測試前格子不應該被揭露',
      );

      // 點擊格子
      gameBoardState.handleCellTap(testRow, testCol);

      // 確認格子已經揭露
      expect(
        gameBoard.board[testRow][testCol].isRevealed,
        isTrue,
        reason: '點擊後格子應該被揭露',
      );

      // 確認格子是數字格子
      expect(
        gameBoard.board[testRow][testCol] is NumberCell,
        isTrue,
        reason: '格子應該是 NumberCell 類型',
      );

      // 確認格子顯示的周圍地雷數量正確
      final numberCell = gameBoard.board[testRow][testCol] as NumberCell;
      expect(
        numberCell.adjacentMines,
        equals(expectedMines),
        reason: '格子顯示的周圍地雷數量應該正確',
      );

      // 確認 countAdjacentMines 方法的結果與 NumberCell 中存儲的值一致
      expect(
        gameBoard.countAdjacentMines(testRow, testCol),
        equals(numberCell.adjacentMines),
        reason: 'countAdjacentMines 方法的結果應該與 NumberCell 中存儲的值一致',
      );

      if (kDebugMode) {
        print('test: 測試結束');
      }
    });
  });
}
