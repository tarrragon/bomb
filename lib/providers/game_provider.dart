import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/game_manager.dart';

/// 遊戲狀態提供者，負責將 GameManager 注入到 Widget 樹中
class GameProvider extends ChangeNotifierProvider<GameManager> {
  GameProvider({super.key, required Widget child})
    : super(create: (_) => GameManager(), child: child);
}
