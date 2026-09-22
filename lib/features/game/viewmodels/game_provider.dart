import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/audio/audio_haptic_service.dart';
import '../../../core/storage/hive_storage_service.dart';
import '../../../engine/generator/grid_generator.dart';
import '../../../engine/models/direction_vector.dart';
import '../../../engine/models/grid_coordinate.dart';
import '../../../engine/models/level_configuration.dart';
import '../../../engine/models/puzzle_board.dart';
import '../../../engine/models/word_placement.dart';
import '../../../engine/solver/hint_solver.dart';
import '../../../engine/solver/word_validator.dart';

/// Game lifecycle status.
enum GameStatus {
  initial,
  playing,
  paused,
  completed,
}

/// Provider managing the gameplay lifecycle, board state, score, timer, hints,
/// gesture selection, and communication with the Word Search Engine.
class GameProvider extends ChangeNotifier {
  final int levelNumber;
  final String category;
  final bool isDaily;

  final HiveStorageService _storage;
  final AudioHapticService _audio;

  late PuzzleBoard _board;
  final List<GridCoordinate> _selectedCells = [];
  GridCoordinate? _dragStartCoordinate;
  GridCoordinate? _highlightedHintCoordinate;

  GameStatus _status = GameStatus.playing;
  bool _isWobblingError = false;
  bool _isSuccessAnimation = false;
  WordPlacement? _lastDiscoveredWord;

  int _score = 0;
  int _elapsedSeconds = 0;
  Timer? _gameTimer;
  bool _isDisposed = false;

  GameProvider({
    required this.levelNumber,
    required this.category,
    this.isDaily = false,
    LevelConfiguration? customConfig,
    List<String>? targetWords,
    HiveStorageService? storage,
    AudioHapticService? audio,
  })  : _storage = storage ?? HiveStorageService(),
        _audio = audio ?? AudioHapticService() {
    _initGame(customConfig: customConfig, customWords: targetWords);
  }

  // -------------------------------------------------------------
  // Public Getters
  // -------------------------------------------------------------

  /// The current level number.
  int get currentLevel => levelNumber;

  /// The puzzle board model containing dimensions, matrix, and word placements.
  PuzzleBoard get board => _board;

  /// The character matrix representing the grid.
  List<List<String>> get matrix => _board.matrix;

  /// Number of rows in the grid.
  int get rows => _board.rows;

  /// Number of columns in the grid.
  int get cols => _board.cols;

  /// List of all target word placements on the board.
  List<WordPlacement> get placements => _board.placements;

  /// List of all target word strings.
  List<String> get targetWords => _board.placements.map((p) => p.word).toList();

  /// List of target words that have been successfully found.
  List<String> get foundWords =>
      _board.placements.where((p) => p.isFound).map((p) => p.word).toList();

  /// Total number of target words.
  int get totalWords => _board.totalWords;

  /// Number of words found so far.
  int get foundWordsCount => _board.foundWordsCount;

  /// Progress ratio from 0.0 to 1.0.
  double get progressFraction =>
      totalWords == 0 ? 0.0 : foundWordsCount / totalWords;

  /// Currently selected coordinates during user drag.
  List<GridCoordinate> get selectedCells =>
      List.unmodifiable(_selectedCells);

  /// Backwards-compatible alias for [selectedCells].
  List<GridCoordinate> get selectedCoordinates => selectedCells;

  /// Current game player score.
  int get score => _score;

  /// Seconds elapsed since level started.
  int get elapsedSeconds => _elapsedSeconds;

  /// Formatted elapsed time in MM:SS format.
  String get formattedTime {
    final m = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Coordinate highlighted by the hint system, if active.
  GridCoordinate? get highlightedHintCoordinate => _highlightedHintCoordinate;

  /// Current status of the game lifecycle.
  GameStatus get gameStatus => _status;

  /// Whether the level has been solved completely.
  bool get isCompleted => _status == GameStatus.completed;

  /// Backwards-compatible alias for [isCompleted].
  bool get isLevelCompleted => isCompleted;

  /// Whether the invalid-selection wobble animation is currently triggered.
  bool get isWobblingError => _isWobblingError;

  /// Whether the word discovery celebration animation is active.
  bool get isSuccessAnimation => _isSuccessAnimation;

  /// The most recently discovered word placement, if any.
  WordPlacement? get lastDiscoveredWord => _lastDiscoveredWord;

  // -------------------------------------------------------------
  // Initialization & Timer
  // -------------------------------------------------------------

  void _initGame({
    LevelConfiguration? customConfig,
    List<String>? customWords,
  }) {
    if (customConfig != null) {
      _board = GridGenerator.generate(
        customConfig,
        words: customWords,
        seed: levelNumber * 100,
      );
      _elapsedSeconds = 0;
      _score = 0;
      _status = GameStatus.playing;
      _startTimer();
      return;
    }

    // Check active saved game from Hive storage
    final saved = _storage.getActiveGame();
    if (saved != null &&
        (saved['levelNumber'] as num?)?.toInt() == levelNumber &&
        saved['board'] != null) {
      _board = PuzzleBoard.fromMap(saved['board'] as Map);
      _elapsedSeconds = (saved['elapsedSeconds'] as num?)?.toInt() ?? 0;
      _score = (saved['score'] as num?)?.toInt() ?? 0;
      _status = _board.isComplete ? GameStatus.completed : GameStatus.playing;
    } else {
      // Generate new board via the engine
      final config = isDaily
          ? LevelConfiguration.daily(seed: 20240921, themeTitle: category)
          : LevelConfiguration.forLevel(levelNumber);

      _board = GridGenerator.generate(
        config,
        words: customWords,
        seed: levelNumber * 100,
      );
      _elapsedSeconds = 0;
      _score = 0;
      _status = GameStatus.playing;
    }

    if (!isCompleted) {
      _startTimer();
    }
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_status == GameStatus.playing) {
        _elapsedSeconds++;
        notifyListeners();
      }
    });
  }

  void pauseGame() {
    if (_status == GameStatus.playing) {
      _status = GameStatus.paused;
      _gameTimer?.cancel();
      notifyListeners();
    }
  }

  void resumeGame() {
    if (_status == GameStatus.paused) {
      _status = GameStatus.playing;
      _startTimer();
      notifyListeners();
    }
  }

  // -------------------------------------------------------------
  // Touch Gesture & Word Selection Interaction
  // -------------------------------------------------------------

  /// Invoked when the user touches the first letter on the board.
  void onPanStart(GridCoordinate coord) {
    if (isCompleted || _isWobblingError) return;

    _dragStartCoordinate = coord;
    _selectedCells.clear();
    _selectedCells.add(coord);
    _audio.playDragTick();
    notifyListeners();
  }

  /// Invoked while the user drags across the board.
  void onPanUpdate(GridCoordinate currentCoord) {
    if (isCompleted || _isWobblingError || _dragStartCoordinate == null) return;

    // Ask Game Engine to calculate straight ray
    final ray = DirectionVector.getRayBetween(
      _dragStartCoordinate!,
      currentCoord,
    );

    if (ray != null) {
      if (ray.length != _selectedCells.length ||
          ray.last != _selectedCells.last) {
        _selectedCells.clear();
        _selectedCells.addAll(ray);
        _audio.playDragTick();
        notifyListeners();
      }
    }
  }

  /// Invoked when the user gesture ends, triggering validation.
  void onPanEnd() {
    if (isCompleted || _isWobblingError || _selectedCells.isEmpty) {
      _clearSelection();
      return;
    }

    final start = _dragStartCoordinate ?? _selectedCells.first;
    final end = _selectedCells.last;

    // Ask the Game Engine to validate the selection
    final result = WordValidator.validateSelection(
      board: _board,
      start: start,
      end: end,
    );

    if (result.isSuccessfulMatch) {
      _handleCorrectWord(result.matchedPlacement!);
    } else {
      _handleIncorrectWord();
    }
  }

  void _handleCorrectWord(WordPlacement matched) {
    // 1. Mark word as found
    final updatedPlacements = _board.placements.map((p) {
      if (p.word == matched.word) {
        return p.copyWith(isFound: true);
      }
      return p;
    }).toList();

    _board = PuzzleBoard(
      rows: _board.rows,
      cols: _board.cols,
      matrix: _board.matrix,
      placements: updatedPlacements,
    );

    // 2. Update progress and score
    final wordScore = matched.word.length * 50;
    _score += wordScore;

    // 3. Trigger success animations and haptic feedback
    _lastDiscoveredWord = matched;
    _isSuccessAnimation = true;
    _audio.playWordFound();

    _selectedCells.clear();
    _dragStartCoordinate = null;
    _highlightedHintCoordinate = null;

    // Auto-save snapshot
    _persistSnapshot();

    // Check completion condition
    if (_board.isComplete) {
      _handleVictory();
    } else {
      notifyListeners();

      // Reset success pulse flag after a short delay
      Future.delayed(const Duration(milliseconds: 300), () {
        _isSuccessAnimation = false;
        notifyListeners();
      });
    }
  }

  void _handleIncorrectWord() {
    _isWobblingError = true;
    _audio.playInvalidWord();
    notifyListeners();

    // Clear selection after triggering wobble animation
    Future.delayed(const Duration(milliseconds: 250), () {
      _isWobblingError = false;
      _clearSelection();
    });
  }

  void _clearSelection() {
    _selectedCells.clear();
    _dragStartCoordinate = null;
    notifyListeners();
  }

  void _handleVictory() {
    _status = GameStatus.completed;
    _gameTimer?.cancel();
    _audio.playLevelComplete();

    // Calculate stars and bonus
    int stars = 3;
    if (_elapsedSeconds > 180) stars = 2;
    if (_elapsedSeconds > 300) stars = 1;

    final bonusScore = 500 + (_board.totalWords * 50) + (stars * 100);
    _score += bonusScore;

    // Save completion record in Hive storage
    _storage.saveLevelProgress(levelNumber, stars, _score);
    _storage.updateCoins(25);
    _storage.clearActiveGame();

    notifyListeners();
  }

  // -------------------------------------------------------------
  // Hints & Utilities
  // -------------------------------------------------------------

  /// Consumes coins to reveal a letter hint from [HintSolver].
  bool useLetterHint() {
    final profile = _storage.getPlayerProfile();
    final coins = (profile['coins'] as num?)?.toInt() ?? 0;
    const cost = 20;

    if (coins < cost) return false;

    final hint = HintSolver.getLetterHint(_board);
    if (hint != null) {
      _storage.updateCoins(-cost);
      _highlightedHintCoordinate = hint.highlightedCoordinate;
      _audio.playDragTick();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Triggers a board visual shuffle effect.
  void shuffleBoardVisuals() {
    _audio.playDragTick();
    notifyListeners();
  }

  void _persistSnapshot() {
    if (!isCompleted) {
      _storage.debouncedSaveActiveGame({
        'levelNumber': levelNumber,
        'category': category,
        'board': _board.toMap(),
        'elapsedSeconds': _elapsedSeconds,
        'score': _score,
        'isDaily': isDaily,
      });
    }
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _gameTimer?.cancel();
    _storage.cancelDebouncedSave();
    if (!isCompleted) {
      _storage.saveActiveGame({
        'levelNumber': levelNumber,
        'category': category,
        'board': _board.toMap(),
        'elapsedSeconds': _elapsedSeconds,
        'score': _score,
        'isDaily': isDaily,
      });
    }
    super.dispose();
  }
}
