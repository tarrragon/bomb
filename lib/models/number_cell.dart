import 'base_cell.dart';

/// 數字格子類別，繼承自 BaseCell
/// 包含顯示數字的格子和空白格子（adjacentMines = 0）
class NumberCell extends BaseCell {
  final int _adjacentMines;

  NumberCell({
    required super.row,
    required super.col,
    required int adjacentMines,
  }) : _adjacentMines = adjacentMines;

  @override
  bool get isMine => false;

  @override
  int get adjacentMines => _adjacentMines;
}
