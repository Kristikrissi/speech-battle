import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/phrase_card.dart';
import '../models/player.dart';
import '../models/game_hero.dart';
import '../models/ai_opponent.dart';
import '../models/player_progress.dart';
import '../models/achievement.dart';
import '../services/speech_recognition_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameStatus { notStarted, inProgress, finished }

enum GameMode { campaign, quickBattle, weeklyTournament, training }

enum TrainingFocus { pronunciation, intonation, vocabulary, grammar }

class PlayerStats {
  int gamesPlayed;
  int gamesWon;
  int gamesLost;
  double averageAccuracy;
  int highestScore;

  PlayerStats({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.gamesLost = 0,
    this.averageAccuracy = 0.0,
    this.highestScore = 0,
  });
}

class GameSettings {
  bool soundEnabled;
  bool vibrationEnabled;
  String language;
  String recognitionLanguage;
  int difficultyLevel;

  GameSettings({
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.language = 'ru',
    this.recognitionLanguage = 'ru_RU',
    this.difficultyLevel = 1,
  });
}

class GameState extends ChangeNotifier {
  GameStatus _gameStatus = GameStatus.notStarted;
  List<PhraseCard> _cards = [];
  int _currentCardIndex = 0;
  int _currentCampaignLevelIndex = 0;
  Map<Player, int> _playerScore = {};
  Map<String, int> _opponentScore = {};
  bool _isListening = false;
  String _interimRecognizedText = '';
  String _lastRecognizedText = '';
  double _accuracyScore = 0.0;
  double _opponentAccuracy = 0.0;
  final Random _random = Random();

  GameSettings _settings = GameSettings();

  final SpeechRecognitionService _speechService = SpeechRecognitionService();

  GameMode _currentGameMode = GameMode.quickBattle;
  late GameModeManager _gameModeManager;

  List<GameHero> _availableHeroes = [];
  GameHero? _selectedHero;
  AIOpponent? _currentOpponent;

  late PlayerProgress _playerProgress;

  PlayerStats _playerStats = PlayerStats();

  final List<Achievement> _achievements = allAchievements;
  final List<String> _unlockedAchievements = [];

  GameStatus get gameStatus => _gameStatus;
  List<PhraseCard> get cards => _cards;
  int get currentCardIndex => _currentCardIndex;
  int get currentCampaignLevelIndex => _currentCampaignLevelIndex;
  Map<Player, int> get playerScore => _playerScore;
  Map<String, int> get opponentScore => _opponentScore;
  bool get isListening => _isListening;
  String get interimRecognizedText => _interimRecognizedText;
  String get lastRecognizedText => _lastRecognizedText;
  double get accuracyScore => _accuracyScore;
  double get opponentAccuracy => _opponentAccuracy;
  GameMode get currentGameMode => _currentGameMode;
  GameModeManager get gameModeManager => _gameModeManager;
  List<GameHero> get availableHeroes => _availableHeroes;
  GameHero? get selectedHero => _selectedHero;
  AIOpponent? get currentOpponent => _currentOpponent;
  PlayerProgress get playerProgress => _playerProgress;
  PlayerStats get playerStats => _playerStats;
  List<Achievement> get achievements => _achievements;
  List<String> get unlockedAchievements => _unlockedAchievements;
  GameSettings get settings => _settings;
  SpeechRecognitionService get speechService => _speechService;

  GameState() {
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    try {
      debugPrint('Начало инициализации игры');

      bool isInitialized = await _speechService.initialize();
      if (!isInitialized) {
        debugPrint('Не удалось инициализировать сервис распознавания речи');
      } else {
        debugPrint('Сервис распознавания речи успешно инициализирован');
        // Проверяем выбранную локаль
        debugPrint(
            'Текущая локаль распознавания: ${_speechService.currentLocale}');
      }

      // Проверяем доступность русской локали
      bool russianAvailable = await _speechService.findAndSetRussianLocale();
      if (!russianAvailable && kIsWeb) {
        debugPrint('Предупреждение: русская локаль недоступна в веб-версии');
        // Уведомляем UI через notifyListeners позже
      }

      _speechService.resultStream.listen((result) {
        if (result.isFinal) {
          _lastRecognizedText = result.text;
          _interimRecognizedText = '';
          _calculateAccuracy();
        } else {
          _interimRecognizedText = result.text;
        }
        notifyListeners();
      });

      _speechService.statusStream.listen((isListening) {
        _isListening = isListening;
        notifyListeners();
      });

      await _loadCards();
      await _loadHeroes();
      await _loadOpponents();

      _playerProgress = PlayerProgress();

      _initializeGameModes();
      await _loadGameModeData();
      await loadCampaignProgress();

      notifyListeners();
      debugPrint('Инициализация игры завершена успешно');
    } catch (e, stackTrace) {
      debugPrint('Ошибка при инициализации игры: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  Future<void> saveCampaignProgress() async {
    try {
      debugPrint('Сохранение прогресса кампании');
      final prefs = await SharedPreferences.getInstance();
      final campaignConfig =
          _gameModeManager.modeConfigs[GameMode.campaign] as CampaignConfig;
      await prefs.setInt('campaign_level', campaignConfig.currentLevel);
      debugPrint(
          'Прогресс кампании сохранен: уровень ${campaignConfig.currentLevel}');
    } catch (e) {
      debugPrint('Ошибка при сохранении прогресса кампании: $e');
    }
  }

  Future<void> loadCampaignProgress() async {
    try {
      debugPrint('Загрузка прогресса кампании');
      final prefs = await SharedPreferences.getInstance();
      final campaignConfig =
          _gameModeManager.modeConfigs[GameMode.campaign] as CampaignConfig;
      final savedLevel = prefs.getInt('campaign_level') ?? 0;
      campaignConfig.currentLevel = savedLevel;
      debugPrint(
          'Прогресс кампании загружен: уровень ${campaignConfig.currentLevel}');
    } catch (e) {
      debugPrint('Ошибка при загрузке прогресса кампании: $e');
    }
  }

  Future<void> _loadCards() async {
    try {
      debugPrint('Загрузка карточек из JSON');
      final String response =
          await rootBundle.loadString('assets/phrases.json');
      debugPrint('Файл phrases.json загружен, размер: ${response.length} байт');

      final data = await json.decode(response);
      debugPrint(
          'JSON успешно декодирован, количество элементов: ${data.length}');

      _cards =
          List<PhraseCard>.from(data.map((item) => PhraseCard.fromJson(item)));
      debugPrint('Карточки успешно созданы, количество: ${_cards.length}');
    } catch (e, stackTrace) {
      debugPrint('Ошибка при загрузке карточек: $e');
      debugPrint('Stack trace: $stackTrace');

      _cards = [
        PhraseCard(
          text: 'Привет, мир!',
          translation: 'Обычная',
          difficulty: 1,
          intonationHint: 'Радостно',
          baseDamage: 8,
        ),
        PhraseCard(
          text: 'Как дела?',
          translation: 'Обычная',
          difficulty: 1,
          intonationHint: 'Вопросительно',
          baseDamage: 8,
        ),
        PhraseCard(
          text: 'Ты готов к битве?',
          translation: 'Обычная',
          difficulty: 2,
          intonationHint: 'Уверенно',
          baseDamage: 10,
        ),
        PhraseCard(
          text: 'Сила в словах!',
          translation: 'Редкая',
          difficulty: 3,
          intonationHint: 'Энергично',
          baseDamage: 15,
        ),
      ];
      debugPrint('Созданы тестовые карточки, количество: ${_cards.length}');
    }
  }

  Future<void> _loadHeroes() async {
    try {
      debugPrint('Начинаем загрузку героев из JSON...');
      final String response = await rootBundle.loadString('assets/heroes.json');
      debugPrint('Файл heroes.json загружен, размер: ${response.length} байт');

      final data = await json.decode(response);
      debugPrint(
          'JSON успешно декодирован, количество элементов: ${data.length}');

      _availableHeroes =
          List<GameHero>.from(data.map((item) => GameHero.fromJson(item)));
      debugPrint(
          'Герои успешно созданы, количество: ${_availableHeroes.length}');

      if (_availableHeroes.isNotEmpty) {
        _selectedHero = _availableHeroes.first;
        debugPrint('Выбран герой по умолчанию: ${_selectedHero!.name}');
      }
    } catch (e, stackTrace) {
      debugPrint('Ошибка при загрузке героев: $e');
      debugPrint('Stack trace: $stackTrace');

      _availableHeroes = [
        GameHero(
          id: '1',
          name: 'Воин Слова',
          imageUrl: 'assets/images/warrior.png',
          uniquePhrases: ['Я сражаюсь словами!'],
          power: HeroPower(
            name: 'Словесный удар',
            description: 'Увеличивает урон на 30%',
            type: PowerType.damageBoost,
            cooldown: 3,
          ),
        ),
        GameHero(
          id: '2',
          name: 'Мастер Речи',
          imageUrl: 'assets/images/master.png',
          uniquePhrases: ['Слова - моё оружие!'],
          power: HeroPower(
            name: 'Точность речи',
            description: 'Повышает точность на 20%',
            type: PowerType.accuracyBoost,
            cooldown: 4,
          ),
        ),
      ];
      _selectedHero = _availableHeroes.first;
      debugPrint(
          'Созданы тестовые герои, количество: ${_availableHeroes.length}');
    }
  }

  Future<void> _loadOpponents() async {
    try {
      debugPrint('Начинаем загрузку противников из JSON...');
      final String response =
          await rootBundle.loadString('assets/opponents.json');
      debugPrint(
          'Файл opponents.json загружен, размер: ${response.length} байт');

      final data = await json.decode(response);
      debugPrint(
          'JSON успешно декодирован, количество элементов: ${data.length}');

      final opponents =
          List<AIOpponent>.from(data.map((item) => AIOpponent.fromJson(item)));
      debugPrint('Противники успешно созданы, количество: ${opponents.length}');

      if (opponents.isNotEmpty) {
        _currentOpponent = opponents.first;
        debugPrint('Выбран противник по умолчанию: ${_currentOpponent!.name}');
      }
    } catch (e, stackTrace) {
      debugPrint('Ошибка при загрузке противников: $e');
      debugPrint('Stack trace: $stackTrace');

      _currentOpponent = AIOpponent(
        name: 'Робот Рон',
        imageUrl: 'assets/images/robot.png',
        level: 1,
        difficultyMultiplier: 1.0,
        phrases: ['Бип-буп, я робот!'],
      );
      debugPrint('Создан тестовый противник: ${_currentOpponent!.name}');
    }
  }

  void _initializeGameModes() {
    try {
      debugPrint('Инициализация игровых режимов');

      final campaignConfig = CampaignConfig(
        name: 'Кампания',
        description: 'Пройдите через серию уровней, сражаясь с боссами',
        levels: [],
        currentLevel: 0,
      );

      final quickBattleConfig = QuickBattleConfig(
        name: 'Быстрый бой',
        description: 'Сразитесь с выбранным противником',
        availableOpponents: [],
      );

      final tournamentConfig = TournamentConfig(
        name: 'Еженедельный турнир',
        description: 'Соревнуйтесь с другими игроками за призы',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        opponents: [],
        rewards: {
          1: TournamentReward(rank: 1, coins: 1000, experience: 500),
          2: TournamentReward(rank: 2, coins: 500, experience: 300),
          3: TournamentReward(rank: 3, coins: 250, experience: 150),
        },
      );

      final trainingConfig = TrainingConfig(
        name: 'Тренировка',
        description: 'Улучшайте свои навыки произношения',
        focus: TrainingFocus.intonation,
        specialCards: [],
      );

      _gameModeManager = GameModeManager(
        modeConfigs: {
          GameMode.campaign: campaignConfig,
          GameMode.quickBattle: quickBattleConfig,
          GameMode.weeklyTournament: tournamentConfig,
          GameMode.training: trainingConfig,
        },
      );

      debugPrint('Игровые режимы успешно инициализированы');
    } catch (e) {
      debugPrint('Ошибка при инициализации игровых режимов: $e');
    }
  }

  Future<void> _loadGameModeData() async {
    debugPrint('Загрузка данных для игровых режимов');

    if (_cards.isEmpty) {
      await _loadCards();
    }

    try {
      debugPrint('Загрузка уровней кампании');
      final String response =
          await rootBundle.loadString('assets/campaign_levels.json');
      debugPrint(
          'Файл campaign_levels.json загружен, размер: ${response.length} байт');

      final data = await json.decode(response);
      debugPrint(
          'JSON успешно декодирован, количество элементов: ${data.length}');

      final campaignConfig =
          _gameModeManager.modeConfigs[GameMode.campaign] as CampaignConfig;

      campaignConfig.levels.clear();

      final levels = List<CampaignLevel>.from(
          data.map((item) => CampaignLevel.fromJson(item)));
      debugPrint(
          'Уровни кампании успешно созданы, количество: ${levels.length}');

      for (var level in levels) {
        if (level.availableCards.isEmpty) {
          List<PhraseCard> levelCards = List.from(_cards);
          levelCards.shuffle();
          if (levelCards.length > 12) {
            levelCards = levelCards.take(12).toList();
          }
          level.availableCards = levelCards;
          debugPrint(
              'Добавлены карточки для уровня ${level.name}, количество: ${level.availableCards.length}');
        }
      }

      campaignConfig.levels.addAll(levels);
      debugPrint(
          'Уровни добавлены в конфигурацию кампании, всего: ${campaignConfig.levels.length}');
    } catch (e) {
      debugPrint('Ошибка при загрузке уровней кампании: $e');

      final campaignConfig =
          _gameModeManager.modeConfigs[GameMode.campaign] as CampaignConfig;

      campaignConfig.levels.clear();

      List<PhraseCard> level1Cards = List.from(_cards);
      level1Cards.shuffle();
      level1Cards = level1Cards.take(8).toList();

      List<PhraseCard> level2Cards = List.from(_cards);
      level2Cards.shuffle();
      level2Cards = level2Cards.take(10).toList();

      final defaultBoss = AIOpponent(
        name: 'Тестовый Босс',
        imageUrl: 'assets/images/boss.png',
        level: 1,
        difficultyMultiplier: 1.0,
        phrases: ['Я тестовый босс!'],
      );

      campaignConfig.levels.addAll([
        CampaignLevel(
          id: 1,
          name: 'Начало пути',
          description: 'Первые шаги в мире слов',
          rewardCoins: 100,
          rewardExp: 50,
          boss: _currentOpponent ?? defaultBoss,
          availableCards: _cards.take(5).toList(),
        ),
        CampaignLevel(
          id: 2,
          name: 'Испытание речи',
          description: 'Проверьте свои навыки произношения',
          rewardCoins: 200,
          rewardExp: 100,
          boss: _currentOpponent ?? defaultBoss,
          availableCards: _cards.take(8).toList(),
        ),
      ]);

      debugPrint(
          'Созданы тестовые уровни кампании, количество: ${campaignConfig.levels.length}');
    }

    try {
      debugPrint('Загрузка противников для быстрого боя');
      final String response =
          await rootBundle.loadString('assets/opponents.json');
      debugPrint(
          'Файл opponents.json загружен, размер: ${response.length} байт');

      final data = await json.decode(response);
      debugPrint(
          'JSON успешно декодирован, количество элементов: ${data.length}');

      final opponents =
          List<AIOpponent>.from(data.map((item) => AIOpponent.fromJson(item)));
      debugPrint('Противники успешно созданы, количество: ${opponents.length}');

      final quickBattleConfig = _gameModeManager
          .modeConfigs[GameMode.quickBattle] as QuickBattleConfig;
      quickBattleConfig.availableOpponents.addAll(opponents);
    } catch (e) {
      debugPrint('Ошибка при загрузке противников для быстрого боя: $e');

      final quickBattleConfig = _gameModeManager
          .modeConfigs[GameMode.quickBattle] as QuickBattleConfig;

      quickBattleConfig.availableOpponents.addAll([
        AIOpponent(
          name: 'Робот Рон',
          imageUrl: 'assets/images/robot.png',
          level: 1,
          difficultyMultiplier: 1.0,
          phrases: ['Бип-буп, я робот!'],
        ),
        AIOpponent(
          name: 'Мастер Слов',
          imageUrl: 'assets/images/master.png',
          level: 2,
          difficultyMultiplier: 1.2,
          phrases: ['Слова - моё оружие!'],
        ),
      ]);

      debugPrint(
          'Созданы тестовые противники для быстрого боя, количество: ${quickBattleConfig.availableOpponents.length}');
    }

    try {
      debugPrint('Загрузка карточек для тренировки');
      final String response =
          await rootBundle.loadString('assets/training_cards.json');
      debugPrint(
          'Файл training_cards.json загружен, размер: ${response.length} байт');

      final data = await json.decode(response);
      debugPrint(
          'JSON успешно декодирован, количество элементов: ${data.length}');

      final trainingCards =
          List<PhraseCard>.from(data.map((item) => PhraseCard.fromJson(item)));
      debugPrint(
          'Карточки для тренировки успешно созданы, количество: ${trainingCards.length}');

      final trainingConfig =
          _gameModeManager.modeConfigs[GameMode.training] as TrainingConfig;
      trainingConfig.specialCards.addAll(trainingCards);
    } catch (e) {
      debugPrint('Ошибка при загрузке карточек для тренировки: $e');

      final trainingConfig =
          _gameModeManager.modeConfigs[GameMode.training] as TrainingConfig;

      trainingConfig.specialCards.addAll(_cards);
      debugPrint(
          'Для тренировки используются обычные карточки, количество: ${trainingConfig.specialCards.length}');
    }

    notifyListeners();
    debugPrint('Загрузка данных для игровых режимов завершена');
  }

  void selectCampaignLevel(int levelIndex) {
    debugPrint('Выбран уровень кампании: $levelIndex');

    final campaignConfig =
        _gameModeManager.modeConfigs[GameMode.campaign] as CampaignConfig;
    if (levelIndex >= 0 && levelIndex < campaignConfig.levels.length) {
      _currentCampaignLevelIndex = levelIndex;

      _currentGameMode = GameMode.campaign;

      final level = campaignConfig.levels[levelIndex];
      if (level.availableCards.isNotEmpty) {
        debugPrint(
            'Найдены карточки для уровня: ${level.availableCards.length}');
        _cards = List<PhraseCard>.from(level.availableCards);
        _cards.shuffle();
        if (_cards.length > 12) {
          _cards = _cards.take(12).toList();
        }
        debugPrint(
            'Загружены карточки для уровня, количество: ${_cards.length}');
      } else {
        debugPrint(
            'Карточки для уровня не найдены, загружаем все доступные карточки');
        _loadCards().then((_) {
          _cards.shuffle();
          if (_cards.length > 12) {
            _cards = _cards.take(12).toList();
          }
          notifyListeners();
        });

        debugPrint(
            'Для уровня используются стандартные карточки: ${_cards.length}');
      }

      _currentOpponent = level.boss;
      debugPrint('Установлен босс уровня: ${_currentOpponent?.name}');

      notifyListeners();
    } else {
      debugPrint('Ошибка: неверный индекс уровня кампании: $levelIndex');
    }
  }

  void startGame(List<Player> players) async {
    debugPrint('Начало игры');

    // Проверяем доступность русской локали перед началом
    bool russianAvailable = await _speechService.findAndSetRussianLocale();
    if (!russianAvailable && kIsWeb) {
      debugPrint('Русская локаль недоступна, уведомляем UI');
      // UI должен обработать это через Consumer<GameState>
    }

    _gameStatus = GameStatus.inProgress;
    _currentCardIndex = 0;
    _playerScore = {for (var player in players) player: 0};
    _opponentScore = {'opponent': 0};
    _lastRecognizedText = '';
    _interimRecognizedText = '';
    _accuracyScore = 0.0;
    _opponentAccuracy = 0.0;

    _cards.shuffle();
    if (_cards.length > 12) {
      _cards = _cards.take(12).toList();
    }
    debugPrint('Карточки перемешаны, количество: ${_cards.length}');

    // Автоматически запускаем прослушивание для первой карточки
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!_isListening && _gameStatus == GameStatus.inProgress) {
        setListening(true);
      }
    });

    notifyListeners();
    debugPrint('Игра начата');
  }

  void resetGame() {
    debugPrint('Сброс игры');

    // Останавливаем прослушивание, если оно активно
    if (_isListening) {
      _speechService.stopListening();
      _isListening = false;
    }

    _gameStatus = GameStatus.notStarted;
    _currentCardIndex = 0;
    _playerScore = {};
    _opponentScore = {};
    _lastRecognizedText = '';
    _interimRecognizedText = '';
    _accuracyScore = 0.0;
    _opponentAccuracy = 0.0;
    notifyListeners();
    debugPrint('Игра сброшена');
  }

  void exitGame() {
    debugPrint('Выход из игры');

    if (_isListening) {
      _speechService.stopListening();
      _isListening = false;
    }

    resetGame();
    saveCampaignProgress();

    debugPrint('Выход из игры выполнен');
  }

  void _simulateOpponentTurn() {
    if (_currentOpponent == null ||
        _cards.isEmpty ||
        _currentCardIndex >= _cards.length) {
      debugPrint(
          'Невозможно симулировать ход противника: противник не выбран или нет карточек');
      return;
    }

    debugPrint('Симуляция хода противника: ${_currentOpponent!.name}');

    final currentCard = _cards[_currentCardIndex];

    double baseAccuracy =
        70.0 + (_currentOpponent!.level * 5.0) - (currentCard.difficulty * 3.0);

    double randomFactor = _random.nextDouble() * 20.0 - 10.0;

    double finalAccuracy =
        (baseAccuracy + randomFactor) * _currentOpponent!.difficultyMultiplier;

    _opponentAccuracy = finalAccuracy.clamp(0.0, 100.0);

    if (_opponentAccuracy >= 70.0) {
      int baseScore = currentCard.baseDamage;
      double accuracyMultiplier = _opponentAccuracy / 100.0;
      int scoreToAdd = (baseScore *
              accuracyMultiplier *
              _currentOpponent!.difficultyMultiplier)
          .round();

      _opponentScore['opponent'] =
          (_opponentScore['opponent'] ?? 0) + scoreToAdd;
    }

    debugPrint(
        'Противник ${_currentOpponent!.name} сказал фразу с точностью ${_opponentAccuracy.toStringAsFixed(1)}%');
    debugPrint('Счет противника: ${_opponentScore['opponent']}');

    notifyListeners();
  }

  void nextCard() {
    debugPrint('Переход к следующей карточке');

    // Сначала останавливаем прослушивание, если оно активно
    if (_isListening) {
      _speechService.stopListening();
      _isListening = false; // Явно обновляем состояние
    }

    if (_currentCardIndex < _cards.length - 1) {
      _currentCardIndex++;
      _lastRecognizedText = '';
      _interimRecognizedText = ''; // Добавлено для сброса промежуточного текста
      _accuracyScore = 0.0;
      _opponentAccuracy = 0.0;

      // Небольшая задержка перед новым запуском прослушивания
      Future.delayed(const Duration(milliseconds: 500), () {
        // Автоматически запускаем прослушивание для новой карточки
        if (!_isListening && _gameStatus == GameStatus.inProgress) {
          setListening(true);
        }
      });

      debugPrint(
          'Переход к карточке ${_currentCardIndex + 1}/${_cards.length}');
    } else {
      debugPrint('Достигнут конец колоды карточек, игра завершена');
      _gameStatus = GameStatus.finished;

      _playerStats.gamesPlayed++;
      debugPrint(
          'Обновлена статистика: игр сыграно = ${_playerStats.gamesPlayed}');

      final playerScoreValue = _playerScore.values.first;
      final opponentScoreValue = _opponentScore['opponent'] ?? 0;
      final isWinner = playerScoreValue > opponentScoreValue;

      debugPrint(
          'Счет игрока: $playerScoreValue, счет противника: $opponentScoreValue');
      debugPrint('Результат: ${isWinner ? "победа" : "поражение"}');

      if (isWinner) {
        _playerStats.gamesWon++;
        debugPrint('Игрок победил! Побед = ${_playerStats.gamesWon}');

        _playerProgress.addCoins(100);
        _playerProgress.addExperience(50);
        debugPrint('Добавлена награда: 100 монет, 50 опыта');

        if (_currentGameMode == GameMode.campaign) {
          final campaignConfig =
              _gameModeManager.modeConfigs[GameMode.campaign] as CampaignConfig;

          if (_currentCampaignLevelIndex == campaignConfig.currentLevel &&
              _currentCampaignLevelIndex < campaignConfig.levels.length - 1) {
            campaignConfig.currentLevel = campaignConfig.currentLevel + 1;
            debugPrint(
                'Разблокирован следующий уровень кампании: ${campaignConfig.currentLevel}');

            final level = campaignConfig.levels[_currentCampaignLevelIndex];
            _playerProgress.addCoins(level.rewardCoins);
            _playerProgress.addExperience(level.rewardExp);
            debugPrint(
                'Добавлена награда за уровень: ${level.rewardCoins} монет, ${level.rewardExp} опыта');

            saveCampaignProgress();
          }
        }
      } else {
        _playerStats.gamesLost++;
        debugPrint('Игрок проиграл. Поражений = ${_playerStats.gamesLost}');

        _playerProgress.addCoins(20);
        _playerProgress.addExperience(10);
        debugPrint('Добавлена утешительная награда: 20 монет, 10 опыта');
      }

      _checkAchievements();
    }

    notifyListeners();
  }

  void setListening(bool isListening) async {
    debugPrint('Установка состояния прослушивания: $isListening');

    if (isListening) {
      // Проверяем, инициализирован ли сервис
      bool isInitialized = await _speechService.initialize();
      if (!isInitialized) {
        debugPrint('Не удалось инициализировать сервис распознавания речи');
        return; // Прерываем запуск, если не удалось инициализировать
      }

      bool russianAvailable = await _speechService.findAndSetRussianLocale();
      if (!russianAvailable && kIsWeb) {
        debugPrint('Русская локаль недоступна перед началом прослушивания');
        notifyListeners(); // UI должен показать предупреждение
      }

      // Сбрасываем состояние перед новым запуском
      _lastRecognizedText = '';
      _interimRecognizedText = '';

      // Запускаем прослушивание с небольшой задержкой
      await Future.delayed(const Duration(milliseconds: 100));
      await _speechService
          .stopListening(); // На всякий случай останавливаем предыдущее прослушивание
      await Future.delayed(const Duration(milliseconds: 100));
      _speechService.startListening();
      debugPrint('Прослушивание запущено');
    } else {
      _speechService.stopListening();
      debugPrint('Прослушивание остановлено');
    }
  }

  void _calculateAccuracy() {
    if (_lastRecognizedText.isEmpty) {
      _accuracyScore = 0.0;
      debugPrint('Пустой текст распознавания, точность = 0.0%');
      return;
    }

    debugPrint('Расчет точности произношения');
    debugPrint('Распознанный текст: $_lastRecognizedText');

    final currentCard = _cards[_currentCardIndex];
    final targetText = currentCard.text.toLowerCase();
    final recognizedText = _lastRecognizedText.toLowerCase();

    debugPrint('Целевой текст: $targetText');

    final targetWords = targetText.split(RegExp(r'\s+'));
    final recognizedWords = recognizedText.split(RegExp(r'\s+'));

    int matchingWords = 0;
    int totalWords = targetWords.length;

    List<String> unusedRecognizedWords = List.from(recognizedWords);

    for (String targetWord in targetWords) {
      double bestMatchScore = 0.0;
      int bestMatchIndex = -1;

      for (int i = 0; i < unusedRecognizedWords.length; i++) {
        String recognizedWord = unusedRecognizedWords[i];
        if (recognizedWord.isEmpty) continue;

        double similarity =
            _calculateWordSimilarity(targetWord, recognizedWord);

        if (similarity > bestMatchScore && similarity > 0.6) {
          bestMatchScore = similarity;
          bestMatchIndex = i;
        }
      }

      if (bestMatchIndex != -1) {
        matchingWords += bestMatchScore.round();
        unusedRecognizedWords[bestMatchIndex] = '';
      }
    }

    double wordOrderScore = 0.0;
    if (matchingWords > 0) {
      int correctOrderCount = 0;

      Map<String, List<int>> recognizedWordIndices = {};
      for (int i = 0; i < recognizedWords.length; i++) {
        String word = recognizedWords[i].toLowerCase();
        if (!recognizedWordIndices.containsKey(word)) {
          recognizedWordIndices[word] = [];
        }
        recognizedWordIndices[word]!.add(i);
      }

      int lastFoundIndex = -1;
      for (String targetWord in targetWords) {
        if (recognizedWordIndices.containsKey(targetWord)) {
          int? foundIndex;
          for (int index in recognizedWordIndices[targetWord]!) {
            if (index > lastFoundIndex) {
              foundIndex = index;
              break;
            }
          }

          if (foundIndex != null) {
            correctOrderCount++;
            lastFoundIndex = foundIndex;
            recognizedWordIndices[targetWord]!.remove(foundIndex);
          }
        }
      }

      wordOrderScore = correctOrderCount / totalWords;
    }

    double lengthScore = 1.0 -
        (targetWords.length - recognizedWords.length).abs() /
            max(targetWords.length, 1);
    if (lengthScore < 0) lengthScore = 0;

    double characterScore = 0.0;
    if (targetText.length <= 20) {
      int distance = _levenshteinDistance(targetText, recognizedText);
      characterScore = 1.0 - (distance / max(targetText.length, 1));
      if (characterScore < 0) characterScore = 0;
    } else {
      characterScore = 0.7;
    }

    double wordAccuracy = matchingWords / max(totalWords, 1);

    const double wordWeight = 0.5;
    const double orderWeight = 0.2;
    const double lengthWeight = 0.1;
    const double charWeight = 0.2;

    double finalAccuracy = (wordAccuracy * wordWeight) +
        (wordOrderScore * orderWeight) +
        (lengthScore * lengthWeight) +
        (characterScore * charWeight);

    _accuracyScore = (finalAccuracy * 100).clamp(0.0, 100.0);

    debugPrint(
        'Точность по словам: ${(wordAccuracy * 100).toStringAsFixed(1)}%');
    debugPrint(
        'Точность по порядку: ${(wordOrderScore * 100).toStringAsFixed(1)}%');
    debugPrint('Точность по длине: ${(lengthScore * 100).toStringAsFixed(1)}%');
    debugPrint(
        'Точность по символам: ${(characterScore * 100).toStringAsFixed(1)}%');
    debugPrint('Итоговая точность: ${_accuracyScore.toStringAsFixed(1)}%');

    if (_accuracyScore >= 70) {
      final baseScore = currentCard.baseDamage;
      final accuracyMultiplier = _accuracyScore / 100;
      final scoreToAdd = (baseScore * accuracyMultiplier).round();

      final player = _playerScore.keys.first;
      _playerScore[player] = (_playerScore[player] ?? 0) + scoreToAdd;
      debugPrint(
          'Добавлено очков: $scoreToAdd, всего: ${_playerScore[player]}');
    } else {
      debugPrint('Точность ниже 70%, очки не добавлены');
    }

    if (_accuracyScore > _playerStats.averageAccuracy) {
      _playerStats.averageAccuracy = _accuracyScore;
      debugPrint(
          'Обновлена средняя точность: ${_playerStats.averageAccuracy.toStringAsFixed(1)}%');
    }

    if (_playerScore.values.first > _playerStats.highestScore) {
      _playerStats.highestScore = _playerScore.values.first;
      debugPrint('Обновлен лучший результат: ${_playerStats.highestScore}');
    }

    _simulateOpponentTurn();

    notifyListeners();
  }

  double _calculateWordSimilarity(String word1, String word2) {
    if (word1 == word2) return 1.0;
    if (word1.isEmpty || word2.isEmpty) return 0.0;

    int distance = _levenshteinDistance(word1, word2);
    int maxLength = max(word1.length, word2.length);

    return 1.0 - (distance / maxLength);
  }

  int _levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> v0 = List<int>.filled(s2.length + 1, 0);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i <= s2.length; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < s2.length; j++) {
        int cost = (s1[i] == s2[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }

      for (int j = 0; j <= s2.length; j++) {
        v0[j] = v1[j];
      }
    }

    return v1[s2.length];
  }

  void selectHero(GameHero hero) {
    debugPrint('Выбран герой: ${hero.name}');
    _selectedHero = hero;
    if (_cards.isEmpty) {
      _loadCards();
    }

    notifyListeners();
  }

  void selectOpponent(AIOpponent opponent) {
    debugPrint('Выбран противник: ${opponent.name}');
    _currentOpponent = opponent;
    notifyListeners();
  }

  void selectGameMode(GameMode mode) {
    debugPrint('Выбран игровой режим: $mode');
    _currentGameMode = mode;

    if (mode == GameMode.quickBattle) {
      _loadCards();
      debugPrint('Для быстрого боя загружены все карточки');
    }

    notifyListeners();
  }

  void _checkAchievements() {
    debugPrint('Проверка достижений');

    for (final achievement in _achievements) {
      if (_unlockedAchievements.contains(achievement.id)) {
        continue;
      }

      bool isUnlocked = false;

      switch (achievement.type) {
        case AchievementType.gamesPlayed:
          isUnlocked = _playerStats.gamesPlayed >= achievement.requiredValue;
          break;
        case AchievementType.gamesWon:
          isUnlocked = _playerStats.gamesWon >= achievement.requiredValue;
          break;
        case AchievementType.accuracy:
          isUnlocked =
              _playerStats.averageAccuracy >= achievement.requiredValue;
          break;
        default:
          break;
      }

      if (isUnlocked) {
        _unlockedAchievements.add(achievement.id);
        debugPrint('Разблокировано достижение: ${achievement.name}');

        _playerProgress.addCoins(50);
        _playerProgress.addExperience(25);
        debugPrint('Добавлена награда за достижение: 50 монет, 25 опыта');
      }
    }
  }

  void updateSoundEnabled(bool value) {
    _settings.soundEnabled = value;
    notifyListeners();
  }

  void updateVibrationEnabled(bool value) {
    _settings.vibrationEnabled = value;
    notifyListeners();
  }

  void updateLanguage(String value) {
    _settings.language = value;
    notifyListeners();
  }

  void updateRecognitionLanguage(String value) {
    _settings.recognitionLanguage = value;
    _speechService.setLocale(value);
    debugPrint('Обновлен язык распознавания: $value');
    notifyListeners();
  }

  void updateDifficultyLevel(int value) {
    _settings.difficultyLevel = value;
    notifyListeners();
  }

  void resetSettings() {
    _settings = GameSettings();
    _speechService.setLocale(_settings.recognitionLanguage);
    notifyListeners();
  }

  void resetProgress() {
    _playerProgress = PlayerProgress();
    _playerStats = PlayerStats();
    _unlockedAchievements.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('Освобождение ресурсов GameState');
    _speechService.dispose();
    super.dispose();
  }
}

abstract class GameModeConfig {
  String get name;
  String get description;
}

class CampaignConfig implements GameModeConfig {
  @override
  final String name;
  @override
  final String description;
  final List<CampaignLevel> levels;
  int currentLevel;

  CampaignConfig({
    required this.name,
    required this.description,
    required this.levels,
    this.currentLevel = 0,
  });
}

class CampaignLevel {
  final int id;
  final String name;
  final String description;
  final int rewardCoins;
  final int rewardExp;
  final AIOpponent boss;
  List<PhraseCard> availableCards;

  CampaignLevel({
    required this.id,
    required this.name,
    required this.description,
    required this.rewardCoins,
    required this.rewardExp,
    required this.boss,
    required this.availableCards,
  });

  factory CampaignLevel.fromJson(Map<String, dynamic> json) {
    final bossJson = json['boss'] as Map<String, dynamic>? ?? {};
    final boss = AIOpponent(
      name: bossJson['name'] ?? 'Неизвестный босс',
      imageUrl: bossJson['imageUrl'] ?? 'assets/images/boss.png',
      level: bossJson['level'] ?? 1,
      difficultyMultiplier: bossJson['difficultyMultiplier'] ?? 1.0,
      phrases: List<String>.from(bossJson['phrases'] ?? []),
    );

    final cardsJson = json['availableCards'] as List<dynamic>? ?? [];
    final availableCards = cardsJson
        .map(
            (cardJson) => PhraseCard.fromJson(cardJson as Map<String, dynamic>))
        .toList();

    return CampaignLevel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Неизвестный уровень',
      description: json['description'] ?? '',
      rewardCoins: json['rewardCoins'] ?? 0,
      rewardExp: json['rewardExp'] ?? 0,
      boss: boss,
      availableCards: availableCards,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'rewardCoins': rewardCoins,
      'rewardExp': rewardExp,
      'boss': {
        'name': boss.name,
        'imageUrl': boss.imageUrl,
        'level': boss.level,
        'difficultyMultiplier': boss.difficultyMultiplier,
        'phrases': boss.phrases,
      },
      'availableCards': availableCards.map((card) => card.toJson()).toList(),
    };
  }
}

class GameModeManager {
  final Map<GameMode, GameModeConfig> modeConfigs;

  GameModeManager({
    required this.modeConfigs,
  });
}

class QuickBattleConfig implements GameModeConfig {
  @override
  final String name;
  @override
  final String description;
  final List<AIOpponent> availableOpponents;

  QuickBattleConfig({
    required this.name,
    required this.description,
    required this.availableOpponents,
  });
}

class TournamentConfig implements GameModeConfig {
  @override
  final String name;
  @override
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final List<AIOpponent> opponents;
  final Map<int, TournamentReward> rewards;

  TournamentConfig({
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.opponents,
    required this.rewards,
  });
}

class TournamentReward {
  final int rank;
  final int coins;
  final int experience;

  TournamentReward({
    required this.rank,
    required this.coins,
    required this.experience,
  });
}

class TrainingConfig implements GameModeConfig {
  @override
  final String name;
  @override
  final String description;
  final TrainingFocus focus;
  List<PhraseCard> specialCards;

  TrainingConfig({
    required this.name,
    required this.description,
    required this.focus,
    required this.specialCards,
  });
}
