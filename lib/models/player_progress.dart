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

class PlayerProgress {
  int level;
  int experience;
  int coins;
  List<String> unlockedHeroes;
  TournamentProgress tournamentProgress;
  
  PlayerProgress({
    this.level = 1,
    this.experience = 0,
    this.coins = 0,
    List<String>? unlockedHeroes,
    TournamentProgress? tournamentProgress,
  }) : 
    unlockedHeroes = unlockedHeroes ?? ['1'], // По умолчанию разблокирован первый герой
    tournamentProgress = tournamentProgress ?? TournamentProgress();
  
  // Добавление опыта с возможным повышением уровня
  void addExperience(int amount) {
    experience += amount;
    
    // Проверка на повышение уровня
    // Простая формула: для следующего уровня нужно level * 100 опыта
    while (experience >= level * 100) {
      experience -= level * 100;
      level++;
    }
  }
  
  // Добавление монет
  void addCoins(int amount) {
    coins += amount;
  }
  
  // Разблокировка нового героя
  void unlockHero(String heroId) {
    if (!unlockedHeroes.contains(heroId)) {
      unlockedHeroes.add(heroId);
    }
  }
  
  // Фабричный метод для создания из JSON
  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    return PlayerProgress(
      level: json['level'] ?? 1,
      experience: json['experience'] ?? 0,
      coins: json['coins'] ?? 0,
      unlockedHeroes: List<String>.from(json['unlockedHeroes'] ?? ['1']),
      tournamentProgress: json['tournamentProgress'] != null
          ? TournamentProgress.fromJson(json['tournamentProgress'])
          : null,
    );
  }
  
  // Метод для преобразования в JSON
  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'experience': experience,
      'coins': coins,
      'unlockedHeroes': unlockedHeroes,
      'tournamentProgress': tournamentProgress.toJson(),
    };
  }
}

// Класс для отслеживания прогресса в турнире
class TournamentProgress {
  int points;
  int currentRank;
  List<TournamentMatch> matchHistory;
  
  TournamentProgress({
    this.points = 0,
    this.currentRank = 10, // Начинаем с низшего ранга
    List<TournamentMatch>? matchHistory,
  }) : matchHistory = matchHistory ?? [];
  
  // Фабричный метод для создания из JSON
  factory TournamentProgress.fromJson(Map<String, dynamic> json) {
    return TournamentProgress(
      points: json['points'] ?? 0,
      currentRank: json['currentRank'] ?? 10,
      matchHistory: json['matchHistory'] != null
          ? (json['matchHistory'] as List).map((match) {
              return TournamentMatch(
                opponentName: match['opponentName'],
                playerScore: match['playerScore'],
                opponentScore: match['opponentScore'],
                date: DateTime.parse(match['date']),
              );
            }).toList()
          : null,
    );
  }
  
  // Метод для преобразования в JSON
  Map<String, dynamic> toJson() {
    return {
      'points': points,
      'currentRank': currentRank,
      'matchHistory': matchHistory.map((match) {
        return {
          'opponentName': match.opponentName,
          'playerScore': match.playerScore,
          'opponentScore': match.opponentScore,
          'date': match.date.toIso8601String(),
        };
      }).toList(),
    };
  }
}
