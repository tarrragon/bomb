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
│   ├── i_game_manager.dart    # 遊戲管理器介面，定義遊戲管理的抽象行為
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

test/
  ├── app/
  │   └── game_provider_setup_init_test.dart  # 測試 Provider 初始化
  │   └── game_provider_update_test.dart      # 測試 Provider 狀態更新
  ├── core/                                 # 核心邏輯測試
  │   ├── game_board_test.dart              # 測試遊戲棋盤核心功能
  │   ├── game_manager_test.dart            # 測試遊戲管理器狀態轉換
  │   └── null_game_manager_test.dart       # 測試空遊戲管理器
  ├── integration/                          # 整合測試
  │   ├── adjacent_mines_display_test.dart  # 測試數字格子顯示周圍地雷數量
  │   ├── auto_expand_test.dart             # 測試空格子自動展開周圍格子
  │   ├── first_click_test.dart             # 測試首次點擊初始化遊戲
  │   ├── flag_test.dart                    # 測試插旗和移除旗子功能
  │   ├── flag_protection_test.dart         # 測試插旗後格子不能被點開
  │   ├── game_over_test.dart               # 測試遊戲結束狀態
  │   ├── game_win_test.dart                # 測試遊戲獲勝狀態
  │   ├── mine_click_test.dart              # 測試點擊地雷導致遊戲結束
  │   ├── reset_game_test.dart              # 測試重置遊戲功能
  │   └── safe_first_click_test.dart        # 測試首次點擊一定安全
  │
  ├── models/                         # 模型測試
  │   └── cell_test.dart              # 測試格子模型的基本功能
  │
  ├── unit/                           # 單元測試
  │   ├── game_board_test.dart        # 測試遊戲棋盤核心邏輯
  │   └── game_manager_test.dart      # 測試遊戲狀態管理
  │
  └── widget/                         # 元件測試
      ├── cell_widget_test.dart       # 測試格子元件
      ├── game_board_widget_test.dart # 測試遊戲棋盤元件
      └── game_controls_test.dart     # 測試遊戲控制元件

```

## 目錄說明

- `app/`: 應用程式層級的設定，包含 Provider 配置等
- `core/`: 遊戲核心邏輯，處理遊戲規則和狀態
- `models/`: 資料模型定義
- `providers/`: 狀態管理相關的 Provider 實作
- `screens/`: 畫面實作
- `widgets/`: 可重用的 UI 組件
- `test/`: 對應的測試檔案

## 主要功能模組說明

### 核心邏輯層 (Core)

- `GameBoard`: 管理遊戲棋盤，負責地雷放置、格子狀態更新、計算周圍地雷數量、揭露格子等核心遊戲邏輯
- `GameManager`: 管理遊戲狀態，處理遊戲開始、進行中、獲勝、失敗等狀態轉換
- `IGameManager`: 定義遊戲管理器的介面，確保不同實現遵循相同的行為規範
- `NullGameManager`: 提供空實現，用於測試和預設狀態

### 資料模型層 (Models)

- `BaseCell`: 定義格子的基本屬性和行為，如位置、是否揭露、是否插旗等
- `MineCell`: 代表含有地雷的格子，繼承自BaseCell
- `NumberCell`: 代表顯示周圍地雷數量的格子，繼承自BaseCell

### 狀態管理層 (Providers)

- `GameBoardState`: 連接UI和核心邏輯，提供遊戲狀態更新和UI響應

### 使用者介面層 (UI)

- `GameScreen`: 遊戲主畫面，整合所有遊戲元件
- `CellWidget`: 顯示單個格子的元件，根據格子狀態顯示不同樣式
- `GameBoardWidget`: 顯示整個遊戲棋盤的元件
- `GameControls`: 提供遊戲控制功能，如重新開始遊戲
- `GameStatusBar`: 顯示遊戲狀態，如剩餘地雷數和計時器
