import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final int requiredValue;
  final AchievementType type;
  
  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.requiredValue,
    required this.type,
  });
}

enum AchievementType {
  gamesPlayed,
  gamesWon,
  accuracy,
  perfectPronunciation,
  useHeroPower,
  defeatBoss,
  collectCards,
  tournamentRank
}

// Список всех достижений в игре
final List<Achievement> allAchievements = [
  Achievement(
    id: 'games_played_10',
    name: 'Новичок',
    description: 'Сыграйте 10 игр',
    icon: Icons.sports_esports,
    requiredValue: 10,
    type: AchievementType.gamesPlayed,
  ),
  Achievement(
    id: 'games_played_50',
    name: 'Опытный игрок',
    description: 'Сыграйте 50 игр',
    icon: Icons.sports_esports,
    requiredValue: 50,
    type: AchievementType.gamesPlayed,
  ),
  Achievement(
    id: 'games_played_100',
    name: 'Ветеран',
    description: 'Сыграйте 100 игр',
    icon: Icons.sports_esports,
    requiredValue: 100,
    type: AchievementType.gamesPlayed,
  ),
  Achievement(
    id: 'games_won_5',
    name: 'Первые победы',
    description: 'Выиграйте 5 игр',
    icon: Icons.emoji_events,
    requiredValue: 5,
    type: AchievementType.gamesWon,
  ),
  Achievement(
    id: 'games_won_25',
    name: 'Победитель',
    description: 'Выиграйте 25 игр',
    icon: Icons.emoji_events,
    requiredValue: 25,
    type: AchievementType.gamesWon,
  ),
  Achievement(
    id: 'accuracy_80',
    name: 'Точность речи',
    description: 'Достигните точности 80% в одной игре',
    icon: Icons.speed,
    requiredValue: 80,
    type: AchievementType.accuracy,
  ),
  Achievement(
    id: 'accuracy_95',
    name: 'Мастер речи',
    description: 'Достигните точности 95% в одной игре',
    icon: Icons.speed,
    requiredValue: 95,
    type: AchievementType.accuracy,
  ),
  Achievement(
    id: 'perfect_5',
    name: 'Идеальное произношение',
    description: 'Получите 5 идеальных произношений',
    icon: Icons.record_voice_over,
    requiredValue: 5,
    type: AchievementType.perfectPronunciation,
  ),
  Achievement(
    id: 'hero_power_10',
    name: 'Сила героя',
    description: 'Используйте способность героя 10 раз',
    icon: Icons.flash_on,
    requiredValue: 10,
    type: AchievementType.useHeroPower,
  ),
  Achievement(
    id: 'boss_defeat_3',
    name: 'Победитель боссов',
    description: 'Победите 3 боссов в кампании',
    icon: Icons.security,
    requiredValue: 3,
    type: AchievementType.defeatBoss,
  ),
  Achievement(
    id: 'cards_20',
    name: 'Коллекционер',
    description: 'Соберите 20 разных карточек',
    icon: Icons.collections,
    requiredValue: 20,
    type: AchievementType.collectCards,
  ),
  Achievement(
    id: 'tournament_rank_5',
    name: 'Турнирный боец',
    description: 'Достигните 5 ранга в турнире',
    icon: Icons.leaderboard,
    requiredValue: 5,
    type: AchievementType.tournamentRank,
  ),
];