import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';

class PlayerProfileScreen extends StatelessWidget {
  const PlayerProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль игрока'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          final progress = gameState.playerProgress;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Карточка с основной информацией
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Аватар игрока
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade100,
                            shape: BoxShape.circle,
                            image: const DecorationImage(
                              image:
                                  AssetImage('assets/images/player_avatar.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Имя игрока
                        const Text(
                          'Игрок 1',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Уровень и опыт
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                'Уровень ${progress.level}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Опыт: ${progress.experience}/${progress.level * 100}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Прогресс-бар опыта
                        LinearProgressIndicator(
                          value: progress.experience / (progress.level * 100),
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.deepPurple),
                        ),
                        const SizedBox(height: 16),

                        // Монеты
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              color: Colors.amber,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${progress.coins} монет',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Заголовок раздела героев
                Text(
                  'Разблокированные герои',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // Список разблокированных героев
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: gameState.availableHeroes.length,
                    itemBuilder: (context, index) {
                      final hero = gameState.availableHeroes[index];
                      final isUnlocked =
                          progress.unlockedHeroes.contains(hero.id);

                      return Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 16),
                        child: Column(
                          children: [
                            // Аватар героя
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: isUnlocked
                                    ? Colors.white
                                    : Colors.grey.shade300,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isUnlocked
                                      ? Colors.deepPurple
                                      : Colors.grey,
                                  width: 2,
                                ),
                                image: isUnlocked
                                    ? DecorationImage(
                                        image: AssetImage(hero.imageUrl),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: isUnlocked
                                  ? null
                                  : const Icon(
                                      Icons.lock,
                                      color: Colors.grey,
                                      size: 32,
                                    ),
                            ),
                            const SizedBox(height: 8),

                            // Имя героя
                            Text(
                              hero.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isUnlocked ? Colors.black : Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Заголовок раздела статистики
                Text(
                  'Статистика',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // Карточка со статистикой
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildStatRow(
                          context,
                          'Сыграно матчей',
                          '${gameState.playerStats.gamesPlayed}',
                          Icons.sports_esports,
                        ),
                        const Divider(),
                        _buildStatRow(
                          context,
                          'Побед',
                          '${gameState.playerStats.gamesWon}',
                          Icons.emoji_events,
                        ),
                        const Divider(),
                        _buildStatRow(
                          context,
                          'Поражений',
                          '${gameState.playerStats.gamesLost}',
                          Icons.sentiment_dissatisfied,
                        ),
                        const Divider(),
                        _buildStatRow(
                          context,
                          'Средняя точность',
                          '${gameState.playerStats.averageAccuracy.toStringAsFixed(1)}%',
                          Icons.speed,
                        ),
                        const Divider(),
                        _buildStatRow(
                          context,
                          'Лучший результат',
                          '${gameState.playerStats.highestScore}',
                          Icons.star,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Заголовок раздела достижений
                Text(
                  'Достижения',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // Список достижений
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: gameState.achievements.length,
                  itemBuilder: (context, index) {
                    final achievement = gameState.achievements[index];
                    final isUnlocked =
                        gameState.unlockedAchievements.contains(achievement.id);

                    return Container(
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? Colors.amber.shade100
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isUnlocked ? Colors.amber : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            achievement.icon,
                            size: 32,
                            color: isUnlocked
                                ? Colors.amber.shade800
                                : Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            achievement.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isUnlocked ? Colors.black : Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(
      BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: Colors.deepPurple,
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
