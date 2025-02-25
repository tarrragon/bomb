# Bomb

## 專案結構

```bash
lib/
├── app/                    # 應用程式設定
│   └── game_provider_setup.dart  # Provider 配置和依賴注入設定
│
├── core/                   # 核心遊戲邏輯
│   ├── game_manager.dart      # 遊戲狀態管理（Singleton）
│   └── game_board.dart        # 遊戲版面邏輯
│   └── constants.dart       # 常數定義
│
├── models/                 # 資料模型
│   ├── base_cell.dart        # 基礎格子類別（抽象類別）
│   ├── mine_cell.dart        # 地雷格子
│   └── number_cell.dart      # 數字格子
│
├── providers/             # 狀態管理
│   ├── game_provider.dart       # 遊戲管理器的 Provider
│   ├── game_board_provider.dart # 遊戲版面的 Provider
│   └── game_board_state.dart    # 遊戲版面狀態管理
│
├── screens/              # 畫面
│   ├── game_screen.dart      # 主遊戲畫面
│   └── settings_screen.dart  # 設定畫面
│
├── widgets/              # UI 組件
│   ├── game_board_widget.dart    # 遊戲版面組件
│   ├── game_status_widget.dart   # 遊戲狀態組件
│   └── game_timer_widget.dart    # 遊戲計時器組件
│
└── main.dart            # 應用程式入口點

```

## 目錄說明

- `app/`: 應用程式層級的設定，包含 Provider 配置等
- `core/`: 遊戲核心邏輯，處理遊戲規則和狀態
- `models/`: 資料模型定義
- `providers/`: 狀態管理相關的 Provider 實作
- `screens/`: 畫面實作
- `widgets/`: 可重用的 UI 組件
- `test/`: 對應的測試檔案
