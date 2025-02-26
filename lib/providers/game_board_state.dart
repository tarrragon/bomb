import 'package:flutter/foundation.dart';
import 'package:bomb/core/game_board.dart';
import 'package:bomb/core/game_manager.dart';
import 'package:bomb/core/i_game_manager.dart';
import 'package:bomb/models/base_cell.dart';
import 'package:bomb/core/null_game_manager.dart';

/// 定義更新策略接口
///
/// 職責：
/// * 封裝不同情境下 GameBoardState 的更新邏輯
/// * 提供統一的接口供 updateFromGameManager 方法使用
/// * 實現策略模式，將不同的更新邏輯分離到不同的類中
///
/// 設計邏輯：
/// * 使用策略模式代替條件判斷，提高代碼的可讀性和可維護性
/// * 每個策略類只負責一種特定情境，符合單一職責原則
/// * 通過工廠方法選擇適當的策略，實現開閉原則
///
/// 運作流程：
/// 1. UpdateStrategyFactory 根據條件選擇適當的策略
/// 2. 策略的 execute 方法執行特定的更新邏輯
/// 3. 返回一個bool，表示是否需要通知監聽者
/// 4. updateFromGameManager 方法根據返回值決定後續操作
abstract class UpdateStrategy {
  // 返回一個bool，表示是否需要通知監聽者
  bool execute(IGameManager? gameManager, GameBoardState? previous);
}

/// 有前一個狀態且 GameManager 有效的更新策略
///
/// 職責：
/// * 處理已有 GameBoardState 且 GameManager 有效的情況
/// * 更新 GameBoardState 的 GameManager 引用
/// * 指示需要通知監聽者
///
/// 運作流程：
/// 1. 將有效的 GameManager 分配給前一個 GameBoardState
/// 2. 返回 true，表示需要通知監聽者
/// 3. updateFromGameManager 將調用 previous.notifyListeners()
/// 4. 返回更新後的前一個 GameBoardState
class ValidManagerWithPreviousStrategy implements UpdateStrategy {
  @override
  bool execute(IGameManager? gameManager, GameBoardState? previous) {
    previous!._gameManager = gameManager!;
    // 返回 true，表示需要通知監聽者
    return true;
  }
}

/// 有前一個狀態但 GameManager 無效的更新策略
///
/// 職責：
/// * 處理已有 GameBoardState 但 GameManager 無效的情況
/// * 將 NullGameManager 分配給 GameBoardState
/// * 保持遊戲進度不變
/// * 指示需要通知監聽者
///
/// 運作流程：
/// 1. 創建 NullGameManager 並分配給前一個 GameBoardState
/// 2. 返回 true，表示需要通知監聽者
/// 3. updateFromGameManager 將調用 previous.notifyListeners()
/// 4. 返回更新後的前一個 GameBoardState
class InvalidManagerWithPreviousStrategy implements UpdateStrategy {
  @override
  bool execute(IGameManager? gameManager, GameBoardState? previous) {
    previous!._gameManager = NullGameManager();
    // 返回 true，表示需要通知監聽者
    return true;
  }
}

/// 沒有前一個狀態的更新策略
///
/// 職責：
/// * 處理沒有前一個 GameBoardState 的情況
/// * 不進行任何操作，因為新的 GameBoardState 將在 updateFromGameManager 中創建
/// * 指示不需要通知監聽者
///
/// 運作流程：
/// 1. 不進行任何操作
/// 2. 返回 false，表示不需要通知監聽者
/// 3. updateFromGameManager 將創建一個新的 GameBoardState
/// 4. 返回新創建的 GameBoardState
class WithoutPreviousStrategy implements UpdateStrategy {
  @override
  bool execute(IGameManager? gameManager, GameBoardState? previous) {
    // 這個策略不需要通知監聽者，因為它創建了一個新的 GameBoardState
    return false;
  }
}

/// 更新策略工廠
///
/// 職責：
/// * 根據條件選擇適當的更新策略
/// * 封裝策略選擇的邏輯
/// * 提供統一的接口供 updateFromGameManager 方法使用
///
/// 設計邏輯：
/// * 使用工廠模式創建策略對象
/// * 根據 GameManager 的有效性和是否有前一個狀態來選擇策略
/// * 將策略選擇的邏輯與策略實現分離
///
/// 運作流程：
/// 1. 接收 isValidManager 和 hasPrevious 參數
/// 2. 根據這些參數選擇適當的策略
/// 3. 返回選擇的策略實例
class UpdateStrategyFactory {
  static UpdateStrategy getStrategy(bool isValidManager, bool hasPrevious) {
    if (hasPrevious) {
      return isValidManager
          ? ValidManagerWithPreviousStrategy()
          : InvalidManagerWithPreviousStrategy();
    } else {
      return WithoutPreviousStrategy();
    }
  }
}

/// 遊戲版面狀態管理器
///
/// 負責：
/// * 協調 GameBoard 和 GameManager 之間的互動
/// * 處理遊戲版面的狀態更新
/// * 管理格子的點擊和標記行為
///
/// 設計考量：
/// * 將遊戲邏輯與狀態管理分離：
///   - GameBoard 專注於遊戲版面的核心邏輯
///   - GameManager 負責整體遊戲狀態
///   - 本類別負責協調兩者的互動
///
/// * 確保遊戲狀態的一致性：
///   - 統一管理遊戲進行中的各種狀態變化
///   - 確保玩家操作後的狀態更新正確
///   - 避免遊戲狀態產生衝突
///
/// * 提供介面給遊戲畫面使用：
///   - 封裝遊戲邏輯
///   - 提供API 給畫面元件
class GameBoardState extends ChangeNotifier {
  GameBoard gameBoard;
  IGameManager _gameManager;

  GameBoardState({required this.gameBoard, IGameManager? gameManager})
    : _gameManager = gameManager ?? NullGameManager();

  // 提供對 GameManager 的訪問
  IGameManager get gameManager => _gameManager;

  // 更新 GameManager
  set gameManager(IGameManager? value) {
    final newManager = value ?? NullGameManager();
    if (newManager != _gameManager) {
      _gameManager = newManager;
      notifyListeners();
    }
  }

  // 直接使用 GameManager 的屬性，不需要檢查
  int get boardSize => _gameManager.boardSize;
  int get mineCount => _gameManager.mineCount;

  /// 創建一個新的 GameBoardState 實例，同時保留未指定參數的現有值
  ///
  /// 使用場景：
  /// * 在 ChangeNotifierProxyProvider 的 update 方法中
  /// * 當需要更新 GameManager 但保留現有 GameBoard 狀態時
  ///
  /// 參數：
  /// * [gameBoard] - 新的遊戲版面，如果為 null 則保留現有版面
  /// * [gameManager] - 新的遊戲管理器，如果為 null 則保留現有管理器
  GameBoardState copyWith({GameBoard? gameBoard, IGameManager? gameManager}) {
    return GameBoardState(
      gameBoard: gameBoard ?? this.gameBoard,
      gameManager: gameManager ?? this.gameManager,
    );
  }

  /// 處理格子點擊
  ///
  /// 職責：
  /// 1. 檢查遊戲狀態
  /// 2. 處理首次點擊
  /// 3. 揭露格子
  /// 4. 檢查勝負條件
  void handleCellTap(int row, int col) {
    if (kDebugMode) {
      print('handleCellTap: 點擊格子 ($row, $col)');
    }
    if (kDebugMode) {
      print('handleCellTap: 當前遊戲狀態 ${_gameManager.gameState}');
    }

    // 如果遊戲已經結束，忽略點擊
    if (_gameManager.gameState == GameState.lost ||
        _gameManager.gameState == GameState.won) {
      if (kDebugMode) {
        print('handleCellTap: 遊戲已結束，忽略點擊');
      }
      return;
    }

    // 如果遊戲尚未開始，則開始遊戲
    if (_gameManager.gameState == GameState.initial) {
      startGame(row, col);
    }

    // 揭露格子
    if (kDebugMode) {
      print('handleCellTap: 揭露格子');
    }
    gameBoard.revealCell(row, col);
    if (kDebugMode) {
      print('handleCellTap: 格子是否為地雷 ${gameBoard.board[row][col].isMine}');
    }

    // 更新遊戲狀態
    if (gameBoard.board[row][col].isMine) {
      if (kDebugMode) {
        print('handleCellTap: 點擊到地雷，遊戲結束');
      }
      gameBoard.revealAllMines();
      _gameManager.gameOver(false); // 設置為失敗
      if (kDebugMode) {
        print('handleCellTap: 設置遊戲狀態為 ${_gameManager.gameState}');
      }
      return; // 直接返回，不再更新已揭露的格子數量
    }

    // 更新已揭露的格子數量
    if (kDebugMode) {
      print('handleCellTap: 更新已揭露格子數量');
    }
    _gameManager.updateRevealedCount(gameBoard.getRevealedCount());
    if (kDebugMode) {
      print('handleCellTap: 已揭露格子數量 ${gameBoard.getRevealedCount()}');
    }

    // 檢查是否獲勝
    if (kDebugMode) {
      print('handleCellTap: 檢查是否獲勝');
    }
    if (gameBoard.checkWin()) {
      if (kDebugMode) {
        print('handleCellTap: 遊戲獲勝');
      }
      _gameManager.gameOver(true); // 設置為勝利
      if (kDebugMode) {
        print('handleCellTap: 設置遊戲狀態為 ${_gameManager.gameState}');
      }
    }
  }

  /// 處理格子右鍵點擊（插旗或移除旗子）
  ///
  /// 職責：
  /// * 切換格子的旗子狀態
  /// * 更新旗子計數
  void handleCellFlag(int row, int col) {
    if (kDebugMode) {
      print('handleCellFlag: 切換格子 ($row, $col) 的旗子狀態');
    }

    // 如果遊戲已經結束，不做任何操作
    if (_gameManager.gameState == GameState.won ||
        _gameManager.gameState == GameState.lost) {
      if (kDebugMode) {
        print('handleCellFlag: 遊戲已經結束，忽略操作');
      }
      return;
    }

    // 如果格子已經揭露，不做任何操作
    if (gameBoard.board[row][col].isRevealed) {
      if (kDebugMode) {
        print('handleCellFlag: 格子已經揭露，忽略操作');
      }
      return;
    }

    // 切換旗子狀態
    gameBoard.toggleFlag(row, col);

    // 更新旗子計數
    _gameManager.updateFlaggedCount(gameBoard.getFlaggedCount());

    // 通知監聽器
    notifyListeners();
  }

  /// 重置遊戲版面
  ///
  /// 執行：
  /// 1. 建立新的遊戲版面
  /// 2. 更新現有版面狀態
  /// 3. 重置遊戲管理器
  void resetBoard() {
    final newBoard = GameBoard(
      boardSize: _gameManager.boardSize,
      mineCount: _gameManager.mineCount,
    );

    // 更新遊戲板狀態
    gameBoard.board.clear();
    gameBoard.board.addAll(newBoard.board);

    // 重置遊戲狀態
    _gameManager.resetGame();
    notifyListeners();
  }

  // 取得特定位置的格子
  BaseCell getCell(int row, int col) => gameBoard.board[row][col];

  // 檢查遊戲是否已初始化
  bool get isInitialized => gameBoard.isInitialized;

  // 取得已標記的旗子數量
  int get flaggedCount => gameBoard.getFlaggedCount();

  // 取得已揭露的格子數量
  int get revealedCount => gameBoard.getRevealedCount();

  // 取得遊戲版面
  GameBoard getGameBoard() => gameBoard;

  /// 處理 GameManager 被釋放的情況
  ///
  /// 職責：
  /// * 清理對 GameManager 的引用
  /// * 保持遊戲板狀態不變
  /// * 更新 hasValidGameManager 標誌
  ///
  /// 設計考量：
  /// * 提供明確的機制來處理依賴對象被釋放
  /// * 確保狀態一致性
  /// * 避免在 GameManager 被釋放後訪問它
  void onGameManagerDisposed() {
    if (_gameManager != NullGameManager()) {
      _gameManager = NullGameManager();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // 清理 GameManager 引用
    onGameManagerDisposed();
    super.dispose();
  }

  /// 檢查 GameManager 是否有效
  bool isValidGameManager(IGameManager? manager) {
    if (manager == null) return false;
    try {
      // 嘗試訪問一個屬性或調用一個方法
      manager.gameState;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 從 GameManager 更新狀態
  ///
  /// 職責：
  /// * 根據 GameManager 的狀態更新 GameBoardState
  /// * 處理 GameManager 為 null 或已釋放的情況
  /// * 保持遊戲進度
  ///
  /// 參數：
  /// * [gameManager] - 新的或更新後的 GameManager 實例，可能為 null
  /// * [previous] - 先前存在的 GameBoardState 實例，代表當前的遊戲狀態
  ///   - 在 Provider 框架中，這通常是由 ChangeNotifierProxyProvider 提供的
  ///   - 如果不為 null，方法會嘗試更新這個實例而不是創建新的
  ///   - 這樣可以保持遊戲進度和狀態的連續性
  ///   - 如果為 null，方法會創建一個全新的 GameBoardState 實例
  ///

  factory GameBoardState.updateFromGameManager({
    required IGameManager? gameManager,
    GameBoardState? previous,
  }) {
    // 如果 gameManager 為 null 或已被釋放，使用 NullGameManager
    if (gameManager == null || gameManager.isDisposed) {
      return previous?.copyWith(gameManager: NullGameManager()) ??
          GameBoardState(
            gameBoard: GameBoard(boardSize: 9, mineCount: 10),
            gameManager: NullGameManager(),
          );
    }

    // 如果是第一次創建或需要更新 GameBoard
    if (previous == null ||
        previous.boardSize != gameManager.boardSize ||
        previous.mineCount != gameManager.mineCount) {
      return GameBoardState(
        gameBoard: GameBoard(
          boardSize: gameManager.boardSize,
          mineCount: gameManager.mineCount,
        ),
        gameManager: gameManager,
      );
    }

    // 如果只需要更新 GameManager
    return previous.copyWith(gameManager: gameManager);
  }

  /// 初始化遊戲板
  ///
  /// 職責：
  /// * 重置遊戲板狀態
  /// * 初始化地雷
  /// * 更新遊戲狀態
  void initializeGameBoard() {
    // 重置遊戲板
    gameBoard.reset();

    // 重置遊戲管理器
    _gameManager.initializeGame();

    if (kDebugMode) {
      print('initializeGameBoard: 遊戲板已重置');
    }
  }

  /// 開始遊戲
  ///
  /// 職責：
  /// * 將遊戲狀態從初始狀態轉換為進行中狀態
  /// * 初始化地雷（如果尚未初始化）
  /// * 更新遊戲狀態
  void startGame(int safeRow, int safeCol) {
    if (_gameManager.gameState != GameState.initial) {
      if (kDebugMode) {
        print('startGame: 遊戲已經開始，忽略操作');
      }
      return;
    }

    if (kDebugMode) {
      print('startGame: 開始遊戲，安全區域：($safeRow, $safeCol)');
    }

    // 初始化地雷
    gameBoard.initializeMines(safeRow, safeCol);

    // 更新遊戲狀態
    _gameManager.handleFirstClick();

    if (kDebugMode) {
      print('startGame: 遊戲已開始，狀態：${_gameManager.gameState}');
    }
  }
}
