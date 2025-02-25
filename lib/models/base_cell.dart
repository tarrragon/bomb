import 'package:flutter/foundation.dart';

/// 格子的基礎抽象類別，定義了所有格子共有的屬性和行為
abstract class BaseCell with ChangeNotifier {
  final int row;
  final int col;
  bool _isRevealed = false;
  bool _isFlagged = false;

  BaseCell({required this.row, required this.col});

  /// 判斷格子是否已被揭露
  bool get isRevealed => _isRevealed;

  /// 判斷格子是否已被標記旗子
  bool get isFlagged => _isFlagged;

  /// 揭露格子的抽象方法，由子類實現不同的揭露行為
  void reveal() {
    if (!_isFlagged) {
      _isRevealed = true;
      notifyListeners();
    }
  }

  /// 判斷是否為地雷，由子類實現
  bool get isMine;

  /// 獲取周圍地雷數，由子類實現
  int get adjacentMines;

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
