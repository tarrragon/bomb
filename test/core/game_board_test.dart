import 'package:flutter_test/flutter_test.dart';
import 'package:bomb/core/game_board.dart';

void main() {
  late GameBoard gameBoard;
  const int testBoardSize = 9;
  const int testMineCount = 10;

  setUp(() {
    gameBoard = GameBoard(boardSize: testBoardSize, mineCount: testMineCount);
  });

  group('GameBoard 初始化測試', () {
    test('應該建立正確大小的版面', () {
      expect(gameBoard.board.length, equals(testBoardSize));
      expect(gameBoard.board[0].length, equals(testBoardSize));
    });

    test('初始版面不應該有地雷', () {
      int mineCount = 0;
      for (var row in gameBoard.board) {
        for (var cell in row) {
          if (cell.isMine) mineCount++;
        }
      }
      expect(mineCount, equals(0));
    });
  });

  group('GameBoard 操作測試', () {
    test('初始化地雷應該放置正確數量', () {
      gameBoard.initializeMines(4, 4);

      int mineCount = 0;
      for (var row in gameBoard.board) {
        for (var cell in row) {
          if (cell.isMine) mineCount++;
        }
      }
      expect(mineCount, equals(testMineCount));
    });

    test('首次點擊區域應該安全', () {
      const firstClickRow = 4;
      const firstClickCol = 4;
      gameBoard.initializeMines(firstClickRow, firstClickCol);

      // 檢查首次點擊周圍 3x3 區域
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          int row = firstClickRow + i;
          int col = firstClickCol + j;
          if (row >= 0 &&
              row < testBoardSize &&
              col >= 0 &&
              col < testBoardSize) {
            expect(gameBoard.board[row][col].isMine, isFalse);
          }
        }
      }
    });

    test('標記功能應該正確運作', () {
      const testRow = 0;
      const testCol = 0;

      expect(gameBoard.board[testRow][testCol].isFlagged, isFalse);

      gameBoard.toggleFlag(testRow, testCol);
      expect(gameBoard.board[testRow][testCol].isFlagged, isTrue);

      gameBoard.toggleFlag(testRow, testCol);
      expect(gameBoard.board[testRow][testCol].isFlagged, isFalse);
    });

    test('檢查獲勝條件', () {
      final gameBoard = GameBoard(boardSize: 9, mineCount: 10);
      gameBoard.initializeMines(4, 4); // 初始化地雷，安全區域在 (4, 4)

      // 揭露所有非地雷格子
      for (int i = 0; i < gameBoard.boardSize; i++) {
        for (int j = 0; j < gameBoard.boardSize; j++) {
          if (!gameBoard.board[i][j].isMine) {
            gameBoard.revealCell(i, j);
          }
        }
      }

      // 檢查是否獲勝
      expect(gameBoard.checkWin(), isTrue);

      // 重置遊戲板
      final newGameBoard = GameBoard(boardSize: 9, mineCount: 10);
      newGameBoard.initializeMines(4, 4);

      // 只揭露部分非地雷格子
      for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 5; j++) {
          if (!newGameBoard.board[i][j].isMine) {
            newGameBoard.revealCell(i, j);
          }
        }
      }

      // 檢查是否獲勝（應該為 false）
      expect(newGameBoard.checkWin(), isFalse);
    });

    test('點擊地雷應該揭露該格子', () {
      final gameBoard = GameBoard(boardSize: 9, mineCount: 10);
      gameBoard.initializeMines(4, 4); // 初始化地雷，安全區域在 (4, 4)

      // 尋找地雷
      int mineRow = -1;
      int mineCol = -1;
      for (int i = 0; i < gameBoard.boardSize; i++) {
        for (int j = 0; j < gameBoard.boardSize; j++) {
          if (gameBoard.board[i][j].isMine) {
            mineRow = i;
            mineCol = j;
            break;
          }
        }
        if (mineRow != -1) break;
      }

      // 確保找到了地雷
      expect(mineRow, greaterThanOrEqualTo(0));
      expect(mineCol, greaterThanOrEqualTo(0));

      // 點擊地雷
      gameBoard.revealCell(mineRow, mineCol);

      // 檢查地雷是否被揭露
      expect(gameBoard.board[mineRow][mineCol].isRevealed, isTrue);
    });

    test('揭露所有地雷應該揭露所有地雷格子', () {
      final gameBoard = GameBoard(boardSize: 9, mineCount: 10);
      gameBoard.initializeMines(4, 4); // 初始化地雷，安全區域在 (4, 4)

      // 揭露所有地雷
      gameBoard.revealAllMines();

      // 檢查所有地雷是否都被揭露
      for (int i = 0; i < gameBoard.boardSize; i++) {
        for (int j = 0; j < gameBoard.boardSize; j++) {
          if (gameBoard.board[i][j].isMine) {
            expect(gameBoard.board[i][j].isRevealed, isTrue);
          }
        }
      }
    });
  });
}
