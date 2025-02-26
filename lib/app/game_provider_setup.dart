import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bomb/core/game_manager.dart';
import 'package:bomb/core/i_game_manager.dart';
import 'package:bomb/providers/game_board_state.dart';

/// 遊戲 Provider 設置
///
/// 負責：
/// * 初始化遊戲相關的 Provider
/// * 建立 Provider 之間的依賴關係
/// * 提供統一的入口點來訪問遊戲狀態
class GameProviderSetup extends StatelessWidget {
  final Widget child;

  // 使用 super 參數特性簡化構造函數
  const GameProviderSetup({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 提供 GameManager 實例
        ChangeNotifierProvider<IGameManager>(create: (_) => GameManager()),

        // 提供 GameBoardState 實例，依賴於 GameManager
        ChangeNotifierProxyProvider<IGameManager, GameBoardState>(
          create:
              (context) => GameBoardState.updateFromGameManager(
                gameManager: Provider.of<IGameManager>(context, listen: false),
              ),
          update:
              (context, gameManager, previous) =>
                  GameBoardState.updateFromGameManager(
                    gameManager: gameManager,
                    previous: previous,
                  ),
        ),
      ],
      child: child,
    );
  }
}
