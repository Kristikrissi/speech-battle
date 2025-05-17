import '../models/phrase_card.dart';
import '../models/ai_opponent.dart';

// Перечисление доступных игровых режимов
enum GameMode { campaign, quickBattle, weeklyTournament, training }

// Базовый класс для конфигурации игрового режима
abstract class GameModeConfig {
  final String name;
  final String description;

  GameModeConfig({
    required this.name,
    required this.description,
  });
}

// Конфигурация для режима кампании
class CampaignConfig extends GameModeConfig {
  final List<CampaignLevel> levels;
  final int currentLevel;

  CampaignConfig({
    required String name,
    required String description,
    required this.levels,
    this.currentLevel = 0,
  }) : super(name: name, description: description);
}

// Конфигурация для режима быстрого боя
class QuickBattleConfig extends GameModeConfig {
  final List<AIOpponent> availableOpponents;

  QuickBattleConfig({
    required String name,
    required String description,
    required this.availableOpponents,
  }) : super(name: name, description: description);
}

// Конфигурация для режима турнира
class TournamentConfig extends GameModeConfig {
  final DateTime startDate;
  final DateTime endDate;
  final List<AIOpponent> opponents;
  final Map<int, TournamentReward> rewards;

  TournamentConfig({
    required String name,
    required String description,
    required this.startDate,
    required this.endDate,
    required this.opponents,
    required this.rewards,
  }) : super(name: name, description: description);
}

// Конфигурация для режима тренировки
class TrainingConfig extends GameModeConfig {
  final TrainingFocus focus;
  final List<PhraseCard> specialCards;

  TrainingConfig({
    required String name,
    required String description,
    required this.focus,
    required this.specialCards,
  }) : super(name: name, description: description);
}

// Фокус тренировки
enum TrainingFocus { pronunciation, intonation, rhythm, speed }

// Класс для управления игровыми режимами
class GameModeManager {
  final Map<GameMode, GameModeConfig> modeConfigs;

  GameModeManager({
    required this.modeConfigs,
  });
}

// Класс для уровня кампании
class CampaignLevel {
  final int id;
  final String name;
  final String description;
  final AIOpponent boss;
  final List<PhraseCard> availableCards;
  final int rewardCoins;
  final int rewardExp;
  List<PhraseCard> cards = [];

  CampaignLevel({
    required this.id,
    required this.name,
    required this.description,
    required this.boss,
    required this.availableCards,
    required this.rewardCoins,
    required this.rewardExp,
  });

  // Фабричный метод для создания из JSON
  factory CampaignLevel.fromJson(Map<String, dynamic> json) {
    return CampaignLevel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      boss: AIOpponent.fromJson(json['boss']),
      availableCards: (json['availableCards'] as List)
          .map((card) => PhraseCard.fromJson(card))
          .toList(),
      rewardCoins: json['rewardCoins'],
      rewardExp: json['rewardExp'],
    );
  }

  // Метод для преобразования в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'boss': boss.toJson(),
      'availableCards': availableCards.map((card) => card.toJson()).toList(),
      'rewardCoins': rewardCoins,
      'rewardExp': rewardExp,
    };
  }
}

// Класс для наград в турнире
class TournamentReward {
  final int rank;
  final int coins;
  final int experience;
  final String? specialItemId;

  TournamentReward({
    required this.rank,
    required this.coins,
    required this.experience,
    this.specialItemId,
  });
}

// Класс для матча в турнире
class TournamentMatch {
  final String opponentName;
  final int playerScore;
  final int opponentScore;
  final DateTime date;

  TournamentMatch({
    required this.opponentName,
    required this.playerScore,
    required this.opponentScore,
    required this.date,
  });
}
