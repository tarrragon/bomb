import 'package:flutter_test/flutter_test.dart';
import 'package:bomb/core/game_board.dart';
import 'package:bomb/core/game_manager.dart';
import 'package:bomb/core/null_game_manager.dart';
import 'package:bomb/providers/game_board_state.dart';

void main() {
  group('GameBoardState', () {
    late GameBoard gameBoard;
    late GameManager gameManager;
    late GameBoardState state;

    setUp(() {
      gameBoard = GameBoard(boardSize: 9, mineCount: 10);
      gameManager = GameManager();
      state = GameBoardState(gameBoard: gameBoard, gameManager: gameManager);
    });

    test('構造函數應該正確初始化', () {
      expect(state.gameBoard, equals(gameBoard));
      expect(state.gameManager, equals(gameManager));
      // 使用 isA 檢查而不是 hasValidGameManager
      expect(state.gameManager, isA<GameManager>());
    });

    test('copyWith 應該正確保留未更新的值', () {
      final newGameBoard = GameBoard(boardSize: 12, mineCount: 15);
      final newState = state.copyWith(gameBoard: newGameBoard);

      expect(newState.gameBoard, equals(newGameBoard));
      expect(newState.gameManager, equals(gameManager));
    });

    test('當 GameManager 為 null 時應該使用 NullGameManager', () {
      final stateWithoutManager = GameBoardState(gameBoard: gameBoard);

      expect(stateWithoutManager.boardSize, equals(gameBoard.boardSize));
      expect(stateWithoutManager.mineCount, equals(gameBoard.mineCount));
      // 使用 isA 檢查而不是 hasValidGameManager
      expect(stateWithoutManager.gameManager, isA<NullGameManager>());
    });

    test('當 GameManager 被釋放時應該正確處理', () {
      gameManager.dispose();

      // 使用 isA 檢查而不是 hasValidGameManager
      expect(state.gameManager, isA<NullGameManager>());
      expect(state.boardSize, equals(gameBoard.boardSize));
      expect(state.mineCount, equals(gameBoard.mineCount));
    });

    test('設置新的 GameManager 時應該通知監聽者', () {
      var notified = false;
      state.addListener(() {
        notified = true;
      });

      state.gameManager = GameManager();
      expect(notified, isTrue);
    });

    test('設置相同的 GameManager 時不應該通知監聽者', () {
      var notified = false;
      state.addListener(() {
        notified = true;
      });

      state.gameManager = state.gameManager;
      expect(notified, isFalse);
    });
  });

  group('GameBoardState.updateFromGameManager 測試', () {
    late GameBoard gameBoard;
    late GameManager gameManager;
    late GameBoardState previousState;

    setUp(() {
      gameBoard = GameBoard(boardSize: 9, mineCount: 10);
      gameManager = GameManager();
      previousState = GameBoardState(
        gameBoard: gameBoard,
        gameManager: gameManager,
      );
    });

    test('當提供有效的 GameManager 時應該正確更新', () {
      final newGameManager = GameManager();
      final updatedState = GameBoardState.updateFromGameManager(
        gameManager: newGameManager,
        previous: previousState,
      );

      expect(updatedState.gameManager, equals(newGameManager));
      expect(updatedState.gameBoard, equals(gameBoard));
    });

    test('當 GameManager 為 null 時應該保持遊戲進度', () {
      final updatedState = GameBoardState.updateFromGameManager(
        gameManager: null,
        previous: previousState,
      );

      expect(updatedState.gameManager, isNull);
      expect(updatedState.gameBoard, equals(gameBoard));
    });

    test('當 GameManager 已被釋放時應該保護遊戲進度', () {
      gameManager.dispose();
      final updatedState = GameBoardState.updateFromGameManager(
        gameManager: gameManager,
        previous: previousState,
      );

      expect(updatedState.gameManager, isNull);
      expect(updatedState.gameBoard, equals(gameBoard));
    });

    test('當沒有前一個狀態時應該創建新的遊戲版面', () {
      final updatedState = GameBoardState.updateFromGameManager(
        gameManager: null,
        previous: null,
      );

      expect(updatedState.gameManager, isNull);
      expect(updatedState.gameBoard.boardSize, equals(9));
      expect(updatedState.gameBoard.mineCount, equals(10));
    });

    test('當 GameManager 狀態異常時應該保護遊戲進度', () {
      // 模擬 GameManager 狀態異常
      final invalidGameManager = GameManager()..dispose();

      final updatedState = GameBoardState.updateFromGameManager(
        gameManager: invalidGameManager,
        previous: previousState,
      );

      expect(updatedState.gameManager, isNull);
      expect(updatedState.gameBoard, equals(gameBoard));
    });
  });

  group('GameBoardState 生命週期測試', () {
    late GameBoard gameBoard;
    late GameManager gameManager;
    late GameBoardState state;

    setUp(() {
      gameBoard = GameBoard(boardSize: 9, mineCount: 10);
      gameManager = GameManager();
      state = GameBoardState(gameBoard: gameBoard, gameManager: gameManager);
    });

    test('dispose 應該清理資源', () {
      // 記錄初始狀態
      expect(state.gameManager, equals(gameManager));
      // 使用 isA 檢查而不是 hasValidGameManager
      expect(state.gameManager, isA<GameManager>());

      // 執行釋放
      state.dispose();

      // 驗證清理結果
      expect(state.gameManager, isA<NullGameManager>());
      // 確認仍然可以訪問 GameBoard
      expect(state.boardSize, equals(gameBoard.boardSize));
      expect(state.mineCount, equals(gameBoard.mineCount));
    });

    test('當 GameManager 被釋放時應該保持 GameBoard 狀態', () {
      // 記錄初始值
      final initialBoardSize = state.boardSize;
      final initialMineCount = state.mineCount;

      // 釋放 GameManager
      gameManager.dispose();

      // 驗證 GameBoard 狀態保持不變
      expect(state.boardSize, equals(initialBoardSize));
      expect(state.mineCount, equals(initialMineCount));
      // 使用 isA 檢查而不是 hasValidGameManager
      expect(state.gameManager, isA<NullGameManager>());
    });

    test('dispose 後不應該觸發 notifyListeners', () {
      var notified = false;
      state.addListener(() {
        notified = true;
      });

      state.dispose();

      // 嘗試更新狀態
      state.gameManager = GameManager();

      // 確認沒有觸發通知
      expect(notified, isFalse);
    });
  });

  group('GameBoardState 應該正確處理 GameManager 被釋放的情況', () {
    // 創建 GameManager
    final gameManager = GameManager();

    // 使用 GameManager 創建 GameBoardState
    final boardState = GameBoardState.updateFromGameManager(
      gameManager: gameManager,
    );

    // 記錄初始狀態
    final initialBoardSize = boardState.boardSize;
    final initialMineCount = boardState.mineCount;

    // 模擬 GameManager 被釋放
    boardState.onGameManagerDisposed();

    // 驗證 GameBoardState 的響應
    expect(boardState.gameManager, isA<NullGameManager>());
    expect(boardState.boardSize, equals(initialBoardSize));
    expect(boardState.mineCount, equals(initialMineCount));
  });
}
