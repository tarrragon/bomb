import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bomb/core/game_manager.dart';
import 'package:bomb/core/game_board.dart';
import 'package:bomb/providers/game_board_state.dart';

void main() {
  group('首次點擊安全測試', () {
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

    test('首次點擊絕對不會踩到地雷', () {
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

      // 測試多個不同的位置
      final testPositions = [
        [0, 0], // 左上角
        [0, gameBoard.boardSize - 1], // 右上角
        [gameBoard.boardSize - 1, 0], // 左下角
        [gameBoard.boardSize - 1, gameBoard.boardSize - 1], // 右下角
        [gameBoard.boardSize ~/ 2, gameBoard.boardSize ~/ 2], // 中心
      ];

      for (final position in testPositions) {
        // 重置遊戲狀態
        gameBoardState.initializeGameBoard();

        // 確保遊戲狀態處於初始狀態
        expect(
          gameManager.isFirstClick,
          isTrue,
          reason: 'GameManager 應該處於初始狀態',
        );
        expect(
          gameManager.gameState,
          equals(GameState.initial),
          reason: 'GameManager 應該處於初始狀態',
        );
        expect(gameBoard.isInitialized, isFalse, reason: 'GameBoard 應該處於初始狀態');

        final row = position[0];
        final col = position[1];

        if (kDebugMode) {
          print('test: 測試位置 ($row, $col)');
        }

        // 開始遊戲
        gameBoardState.startGame(row, col);

        // 確保遊戲已經初始化
        expect(gameBoard.isInitialized, isTrue, reason: 'GameBoard 應該已經初始化');

        // 確認首次點擊的位置不是地雷
        expect(
          gameBoard.board[row][col].isMine,
          isFalse,
          reason: '首次點擊的位置不應該是地雷',
        );

        // 確認首次點擊的位置周圍也不是地雷
        for (int i = -1; i <= 1; i++) {
          for (int j = -1; j <= 1; j++) {
            final newRow = row + i;
            final newCol = col + j;
            if (newRow >= 0 &&
                newRow < gameBoard.boardSize &&
                newCol >= 0 &&
                newCol < gameBoard.boardSize) {
              expect(
                gameBoard.board[newRow][newCol].isMine,
                isFalse,
                reason: '首次點擊的位置周圍不應該有地雷',
              );
            }
          }
        }

        // 點擊該位置
        gameBoardState.handleCellTap(row, col);

        // 確認遊戲沒有結束（沒有踩到地雷）
        expect(
          gameManager.gameState != GameState.lost,
          isTrue,
          reason: '首次點擊不應該導致遊戲失敗',
        );

        if (kDebugMode) {
          print('test: 位置 ($row, $col) 測試通過');
        }
      }

      if (kDebugMode) {
        print('test: 測試結束');
      }
    });
  });
}
