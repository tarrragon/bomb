// lib/core/game_board.dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/base_cell.dart';
import '../models/mine_cell.dart';
import '../models/number_cell.dart';

class GameBoard with ChangeNotifier {
  late List<List<BaseCell>> _board;
  final int boardSize;
  final int mineCount;
  bool _isInitialized = false;

  GameBoard({required this.boardSize, required this.mineCount}) {
    _initializeBoard();
  }

  List<List<BaseCell>> get board => _board;
  bool get isInitialized => _isInitialized;

  void _initializeBoard() {
    _board = List.generate(
      boardSize,
      (row) => List.generate(
        boardSize,
        (col) => NumberCell(row: row, col: col, adjacentMines: 0),
      ),
    );
  }

  // 在第一次點擊時初始化地雷
  void initializeMines(int firstClickRow, int firstClickCol) {
    if (_isInitialized) return;

    final random = Random();
    int minesPlaced = 0;

    // 建立安全區域（以第一次點擊的位置為中心的 3x3 區域）
    List<List<bool>> safeZone = List.generate(
      boardSize,
      (row) => List.generate(
        boardSize,
        (col) =>
            (row - firstClickRow).abs() <= 1 &&
            (col - firstClickCol).abs() <= 1,
      ),
    );

    // 放置地雷
    while (minesPlaced < mineCount) {
      int row = random.nextInt(boardSize);
      int col = random.nextInt(boardSize);

      if (!safeZone[row][col] && !_board[row][col].isMine) {
        _board[row][col] = MineCell(row: row, col: col);
        minesPlaced++;
      }
    }

    // 計算周圍地雷數
    _calculateAdjacentMines();
    _isInitialized = true;
    notifyListeners();
  }

  // 計算每個格子周圍的地雷數
  void _calculateAdjacentMines() {
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (!_board[row][col].isMine) {
          int count = _countAdjacentMines(row, col);
          _board[row][col] = NumberCell(
            row: row,
            col: col,
            adjacentMines: count,
          );
        }
      }
    }
  }

  // 計算指定位置周圍的地雷數
  int _countAdjacentMines(int row, int col) {
    int count = 0;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int newRow = row + i;
        int newCol = col + j;
        if (_isValidPosition(newRow, newCol) && _board[newRow][newCol].isMine) {
          count++;
        }
      }
    }
    return count;
  }

  // 檢查位置是否有效
  bool _isValidPosition(int row, int col) {
    return row >= 0 && row < boardSize && col >= 0 && col < boardSize;
  }

  // 點擊格子
  void revealCell(int row, int col) {
    if (!_isValidPosition(row, col)) return;

    BaseCell cell = _board[row][col];
    if (cell.isRevealed || cell.isFlagged) return;

    cell.reveal();

    // 如果是空格子（周圍沒有地雷），則展開周圍的格子
    if (!cell.isMine && cell.adjacentMines == 0) {
      _revealAdjacentCells(row, col);
    }

    notifyListeners();
  }

  // 展開周圍的格子
  void _revealAdjacentCells(int row, int col) {
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int newRow = row + i;
        int newCol = col + j;

        if (_isValidPosition(newRow, newCol)) {
          BaseCell adjacentCell = _board[newRow][newCol];
          if (!adjacentCell.isRevealed && !adjacentCell.isFlagged) {
            revealCell(newRow, newCol);
          }
        }
      }
    }
  }

  // 插旗/移除旗子
  void toggleFlag(int row, int col) {
    if (!_isValidPosition(row, col)) return;

    BaseCell cell = _board[row][col];
    if (!cell.isRevealed) {
      cell.toggleFlag();
      notifyListeners();
    }
  }

  // 檢查是否獲勝
  bool checkWin() {
    int revealedCount = 0;
    int correctlyFlaggedMines = 0;

    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        BaseCell cell = _board[row][col];
        if (cell.isRevealed && !cell.isMine) {
          revealedCount++;
        }
        if (cell.isFlagged && cell.isMine) {
          correctlyFlaggedMines++;
        }
      }
    }

    return revealedCount == (boardSize * boardSize - mineCount) ||
        correctlyFlaggedMines == mineCount;
  }

  // 揭露所有地雷
  void revealAllMines() {
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (_board[row][col].isMine) {
          _board[row][col].reveal();
        }
      }
    }
    notifyListeners();
  }

  // 取得已插旗數量
  int getFlaggedCount() {
    int count = 0;
    for (var row in _board) {
      for (var cell in row) {
        if (cell.isFlagged) count++;
      }
    }
    return count;
  }

  // 取得已揭露格子數量
  int getRevealedCount() {
    int count = 0;
    for (var row in _board) {
      for (var cell in row) {
        if (cell.isRevealed && !cell.isMine) count++;
      }
    }
    return count;
  }
}
