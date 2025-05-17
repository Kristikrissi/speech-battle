import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../models/player.dart';

class CampaignScreen extends StatelessWidget {
  const CampaignScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Одиночная кампания'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          // Получаем конфигурацию кампании
          final campaignConfig = gameState
              .gameModeManager.modeConfigs[GameMode.campaign] as CampaignConfig;

          return Column(
            children: [
              // Заголовок кампании
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Уровни кампании',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),

              // Список уровней
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: campaignConfig.levels.length,
                  itemBuilder: (context, index) {
                    final level = campaignConfig.levels[index];
                    final isUnlocked = index <= campaignConfig.currentLevel;
                    final isCompleted = index < campaignConfig.currentLevel;

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: isUnlocked
                            ? () => _startLevel(context, gameState, index)
                            : null,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Номер уровня
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isUnlocked
                                      ? Colors.deepPurple
                                      : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${level.id}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Информация об уровне
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      level.name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isUnlocked
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      level.description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isUnlocked
                                            ? Colors.black54
                                            : Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.emoji_events,
                                          size: 16,
                                          color: isUnlocked
                                              ? Colors.amber
                                              : Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Награда: ${level.rewardCoins} монет, ${level.rewardExp} опыта',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isUnlocked
                                                ? Colors.black54
                                                : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Индикатор статуса
                              if (isCompleted)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 24,
                                )
                              else if (isUnlocked)
                                const Icon(
                                  Icons.play_circle_filled,
                                  color: Colors.deepPurple,
                                  size: 24,
                                )
                              else
                                const Icon(
                                  Icons.lock,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _startLevel(BuildContext context, GameState gameState, int levelIndex) {
    // Выбираем уровень
    gameState.selectCampaignLevel(levelIndex);

    // Создаем тестового игрока
    final player = Player(name: 'Игрок 1');

    // Запускаем игру
    gameState.startGame([player]);

    // Переходим на экран игры
    Navigator.pushNamed(context, '/');
  }
}
