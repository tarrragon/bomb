import 'base_cell.dart';

/// 地雷格子類別，繼承自 BaseCell
class MineCell extends BaseCell {
  MineCell({required super.row, required super.col});

  @override
  bool get isMine => true;

  @override
  int get adjacentMines => -1; // 地雷格子沒有周圍地雷數

  @override
  void reveal() {
    // 保留原有的行為
    super.reveal();
  }
}
