// lib/core/game_board.dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/base_cell.dart';
import '../models/number_cell.dart';
import '../models/mine_cell.dart';

class GameBoard with ChangeNotifier {
  late List<List<BaseCell>> _board;
  final int boardSize;
  final int mineCount;
  bool _isInitialized = false;

  GameBoard({required this.boardSize, required this.mineCount}) {
    // 確保地雷數量合理
    if (mineCount <= 0 || mineCount >= boardSize * boardSize) {
      throw ArgumentError('地雷數量必須大於 0 且小於格子總數');
    }

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

  /// 初始化地雷
  ///
  /// 職責：
  /// * 在遊戲板上隨機放置地雷
  /// * 確保首次點擊的位置及其周圍不會有地雷
  /// * 計算每個非地雷格子周圍的地雷數量
  ///
  /// 參數：
  /// * [safeRow] - 安全區域的行索引
  /// * [safeCol] - 安全區域的列索引
  void initializeMines(int safeRow, int safeCol) {
    if (isInitialized) {
      if (kDebugMode) {
        print('遊戲板已經初始化，忽略操作');
      }
      return;
    }

    if (kDebugMode) {
      print('初始化地雷，安全區域：($safeRow, $safeCol)，地雷數量：$mineCount');
    }

    // 初始化遊戲板
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        board[i][j] = NumberCell(row: i, col: j, adjacentMines: 0);
      }
    }

    // 隨機放置地雷
    int placedMines = 0;
    final random = Random();

    // 定義安全區域（首次點擊的位置及其周圍）
    final safeZone = <List<int>>[];
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        final newRow = safeRow + i;
        final newCol = safeCol + j;
        if (newRow >= 0 &&
            newRow < boardSize &&
            newCol >= 0 &&
            newCol < boardSize) {
          safeZone.add([newRow, newCol]);
        }
      }
    }

    while (placedMines < mineCount) {
      final row = random.nextInt(boardSize);
      final col = random.nextInt(boardSize);

      // 檢查是否在安全區域內
      bool isSafe = false;
      for (final pos in safeZone) {
        if (pos[0] == row && pos[1] == col) {
          isSafe = true;
          break;
        }
      }

      // 如果在安全區域內或已經是地雷，則跳過
      if (isSafe || board[row][col].isMine) {
        continue;
      }

      // 放置地雷
      board[row][col] = MineCell(row: row, col: col);
      placedMines++;

      if (kDebugMode) {
        print('放置地雷 $placedMines：($row, $col)');
      }
    }

    // 打印地雷位置
    if (kDebugMode) {
      print('地雷位置:');
      for (int i = 0; i < boardSize; i++) {
        for (int j = 0; j < boardSize; j++) {
          if (board[i][j].isMine) {
            print('($i, $j)');
          }
        }
      }
      int actualMineCount = 0;
      for (int i = 0; i < boardSize; i++) {
        for (int j = 0; j < boardSize; j++) {
          if (board[i][j].isMine) {
            actualMineCount++;
          }
        }
      }
      print('實際地雷數量：$actualMineCount');
    }

    // 計算每個非地雷格子周圍的地雷數量
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (!board[i][j].isMine) {
          final adjacentMines = countAdjacentMines(i, j);
          board[i][j] = NumberCell(
            row: i,
            col: j,
            adjacentMines: adjacentMines,
          );
        }
      }
    }

    _isInitialized = true;
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
    // 如果遊戲還沒有初始化，不可能獲勝
    if (!_isInitialized) return false;

    int revealedCount = 0;
    int nonMineCount = boardSize * boardSize - mineCount;

    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        BaseCell cell = _board[row][col];
        if (cell.isRevealed && !cell.isMine) {
          revealedCount++;
        }
      }
    }

    if (kDebugMode) {
      print('已揭露非地雷格子數量：$revealedCount，總非地雷格子數量：$nonMineCount');
    }

    return revealedCount == nonMineCount;
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

  /// 計算指定位置周圍的地雷數
  ///
  /// 職責：
  /// * 計算指定位置周圍8個方向的地雷數量
  /// * 用於初始化數字格子的顯示值
  ///
  /// 設計考量：
  /// * 雖然在遊戲初始化時已經計算並存儲了每個格子周圍的地雷數量，
  ///   但保留此方法有：
  ///   1. 用於測試和驗證 NumberCell 中存儲的 adjacentMines 值是否正確
  ///   2. 便於調試和開發過程中檢查地雷分布
  ///   3. 為未來可能的功能擴展（如遊戲中途重新計算、提示功能等）做準備
  /// 參數：
  /// * [row] - 行索引
  /// * [col] - 列索引
  ///
  /// 返回：
  /// * 周圍地雷的數量
  int countAdjacentMines(int row, int col) {
    int count = 0;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int newRow = row + i;
        int newCol = col + j;
        if (_isValidPosition(newRow, newCol) && board[newRow][newCol].isMine) {
          count++;
        }
      }
    }
    return count;
  }

  // 添加一個方法來重置遊戲板的狀態
  void reset() {
    _isInitialized = false;
    _initializeBoard();
  }
}
