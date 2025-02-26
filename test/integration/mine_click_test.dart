import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bomb/core/game_manager.dart';
import 'package:bomb/core/game_board.dart';
import 'package:bomb/providers/game_board_state.dart';
import 'package:bomb/models/mine_cell.dart';

void main() {
  group('點擊地雷測試', () {
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

    test('點擊地雷應該結束遊戲', () {
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

      // 選擇一個安全位置進行首次點擊
      const int safeRow = 0;
      const int safeCol = 0;

      // 開始遊戲（首次點擊）
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

      // 指定一個地雷位置（與首次點擊位置不同）
      const int mineRow = 5;
      const int mineCol = 5;

      // 確保該位置不是已經揭露的
      if (gameBoard.board[mineRow][mineCol].isRevealed) {
        if (kDebugMode) {
          print('test: 指定的地雷位置 ($mineRow, $mineCol) 已經被揭露，選擇另一個位置');
        }

        // 尋找一個未揭露的位置
        bool found = false;
        for (int i = 0; i < gameBoard.boardSize && !found; i++) {
          for (int j = 0; j < gameBoard.boardSize && !found; j++) {
            if (!gameBoard.board[i][j].isRevealed) {
              // 找到一個未揭露的位置
              gameBoard.board[i][j] = MineCell(row: i, col: j);
              if (kDebugMode) {
                print('test: 在位置 ($i, $j) 放置地雷');
              }
              found = true;
              break;
            }
          }
        }

        if (!found) {
          fail('無法找到未揭露的位置來放置地雷');
        }
      } else {
        // 在指定位置放置地雷
        gameBoard.board[mineRow][mineCol] = MineCell(
          row: mineRow,
          col: mineCol,
        );
        if (kDebugMode) {
          print('test: 在位置 ($mineRow, $mineCol) 放置地雷');
        }
      }

      // 確認該位置確實是地雷
      expect(
        gameBoard.board[mineRow][mineCol].isMine,
        isTrue,
        reason: '指定的位置應該是地雷',
      );

      // 點擊地雷前的狀態
      if (kDebugMode) {
        print('test: 點擊地雷前遊戲狀態: ${gameManager.gameState}');
      }

      // 點擊地雷
      gameBoardState.handleCellTap(mineRow, mineCol);

      // 點擊地雷後的狀態
      if (kDebugMode) {
        print('test: 點擊地雷後遊戲狀態: ${gameManager.gameState}');
      }
      if (kDebugMode) {
        print('test: 點擊地雷後已揭露格子數量: ${gameBoard.getRevealedCount()}');
      }

      // 檢查遊戲狀態
      expect(
        gameManager.gameState,
        equals(GameState.lost),
        reason: '點擊地雷後遊戲狀態應為 GameState.lost',
      );

      if (kDebugMode) {
        print('test: 測試結束');
      }
    });
  });
}
