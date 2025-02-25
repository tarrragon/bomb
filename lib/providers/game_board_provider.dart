import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/game_board.dart';
import '../core/game_manager.dart';

class GameBoardProvider extends ChangeNotifierProvider<GameBoard> {
  GameBoardProvider({super.key, required Widget child})
    : super(
        create: (context) {
          // 取得 GameManager 實例
          final gameManager = Provider.of<GameManager>(context, listen: false);

          // 建立 GameBoard 實例
          return GameBoard(
            boardSize: gameManager.boardSize,
            mineCount: gameManager.mineCount,
          );
        },
        child: child,
      );
}

// lib/providers/game_board_state.dart
