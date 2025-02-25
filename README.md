# bomb

## 專案結構

```bash
lib/
├── core/                 # 核心邏輯層
│   ├── game_manager.dart    # 遊戲狀態管理（Singleton）
│   ├── game_board.dart      # 遊戲版面邏輯
│   ├── game_difficulty.dart # 遊戲難度設定
│   └── constants.dart       # 常數定義
│
├── models/               # 資料模型
│   ├── base_cell.dart      # 基礎格子類別（抽象類別）
│   ├── mine_cell.dart      # 地雷格子
│   └── number_cell.dart    # 數字格子
│
├── providers/           # 狀態管理
│   ├── game_board_state.dart   # 遊戲版面狀態
│   ├── game_board_provider.dart # 遊戲版面 Provider
│   └── game_providers.dart     # Provider 整合
│
├── screens/            # 畫面
│   ├── game_screen.dart    # 主遊戲畫面
│   └── settings_screen.dart # 設定畫面
│
├── widgets/            # UI 組件
│   ├── animated_cell_widget.dart # 動畫格子組件
│   ├── game_board_widget.dart    # 遊戲版面組件
│   ├── game_status_widget.dart   # 遊戲狀態組件
│   └── game_timer_widget.dart    # 遊戲計時器組件
│
└── main.dart          # 應用程式入口點
```
