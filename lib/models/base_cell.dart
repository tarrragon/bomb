import 'package:flutter/foundation.dart';

/// 格子的基礎抽象類別，定義了所有格子共有的屬性和行為
abstract class BaseCell with ChangeNotifier {
  final int row;
  final int col;
  bool _isRevealed = false;
  bool _isFlagged = false;
  bool _isMine = false;
  int _adjacentMines = 0;

  BaseCell({
    required this.row,
    required this.col,
    bool isMine = false,
    int adjacentMines = 0,
  }) : _isMine = isMine,
       _adjacentMines = adjacentMines;

  /// 判斷格子是否已被揭露
  bool get isRevealed => _isRevealed;

  /// 判斷格子是否已被標記旗子
  bool get isFlagged => _isFlagged;

  /// 判斷是否為地雷
  bool get isMine => _isMine;

  /// 獲取周圍地雷數
  int get adjacentMines => _adjacentMines;

  /// 設置是否為地雷，並在必要時通知監聽者
  set isMine(bool value) {
    if (_isMine != value) {
      _isMine = value;
      notifyListeners();
    }
  }

  /// 設置周圍地雷數，並在必要時通知監聽者
  set adjacentMines(int value) {
    if (_adjacentMines != value) {
      _adjacentMines = value;
      notifyListeners();
    }
  }

  /// 揭露格子的抽象方法，由子類實現不同的揭露行為
  void reveal() {
    if (!_isFlagged) {
      _isRevealed = true;
      notifyListeners();
    }
  }

  /// 切換旗子標記狀態
  void toggleFlag() {
    if (!_isRevealed) {
      _isFlagged = !_isFlagged;
      notifyListeners();
    }
  }

  @override
  String toString() => 'Cell($row, $col)';
}
