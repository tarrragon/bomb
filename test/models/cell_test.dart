import 'package:flutter_test/flutter_test.dart';
import 'package:bomb/models/mine_cell.dart';
import 'package:bomb/models/number_cell.dart';

void main() {
  group('格子模型測試', () {
    test('MineCell 應該正確初始化', () {
      final cell = MineCell(row: 1, col: 2);

      expect(cell.isMine, isTrue);
      expect(cell.isRevealed, isFalse);
      expect(cell.isFlagged, isFalse);
      expect(cell.row, equals(1));
      expect(cell.col, equals(2));
    });

    test('NumberCell 應該正確處理周圍地雷數', () {
      final cell = NumberCell(row: 0, col: 0, adjacentMines: 3);

      expect(cell.isMine, isFalse);
      expect(cell.adjacentMines, equals(3));
    });

    test('格子的標記狀態應該正確切換', () {
      final cell = NumberCell(row: 0, col: 0, adjacentMines: 3);

      cell.toggleFlag();
      expect(cell.isFlagged, isTrue);

      cell.toggleFlag();
      expect(cell.isFlagged, isFalse);
    });
  });
}
