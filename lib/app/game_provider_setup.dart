import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/game_manager.dart';
import '../core/game_board.dart';
import '../providers/game_board_state.dart';

/// 設置 Provider 結構
class GameProviderSetup extends StatelessWidget {
  final Widget child;

  const GameProviderSetup({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameManager()),
        ChangeNotifierProxyProvider<GameManager, GameBoardState>(
          create:
              (context) => GameBoardState(
                gameBoard: GameBoard(
                  boardSize: context.read<GameManager>().boardSize,
                  mineCount: context.read<GameManager>().mineCount,
                ),
                gameManager: context.read<GameManager>(),
              ),
          update:
              (context, gameManager, previous) => GameBoardState(
                gameBoard:
                    previous?.getGameBoard() ??
                    GameBoard(
                      boardSize: gameManager.boardSize,
                      mineCount: gameManager.mineCount,
                    ),
                gameManager: gameManager,
              ),
        ),
      ],
      child: child,
    );
  }
}
