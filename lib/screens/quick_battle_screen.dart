import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../models/player.dart';

class QuickBattleScreen extends StatelessWidget {
  const QuickBattleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Быстрый бой'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          // Получаем конфигурацию быстрого боя
          final quickBattleConfig = gameState.gameModeManager
              .modeConfigs[GameMode.quickBattle] as QuickBattleConfig;

          return Column(
            children: [
              // Заголовок
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Выберите противника',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),

              // Информация о выбранном герое
              if (gameState.selectedHero != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Аватар героя
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage(
                                    gameState.selectedHero!.imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Информация о герое
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ваш герой: ${gameState.selectedHero!.name}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Сила: ${gameState.selectedHero!.power.name}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Кнопка смены героя
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/hero_selection');
                            },
                            child: const Text('Сменить'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Список противников
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: quickBattleConfig.availableOpponents.length,
                  itemBuilder: (context, index) {
                    final opponent =
                        quickBattleConfig.availableOpponents[index];
                    final isSelected =
                        gameState.currentOpponent?.name == opponent.name;

                    return Card(
                      elevation: isSelected ? 8 : 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.deepPurple
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          gameState.selectOpponent(opponent);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Аватар противника
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage(opponent.imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Информация о противнике
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      opponent.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Уровень: ${opponent.level}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Text(
                                          'Сложность: ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        ...List.generate(5, (i) {
                                          return Icon(
                                            Icons.star,
                                            size: 16,
                                            color: i < opponent.level
                                                ? Colors.amber
                                                : Colors.grey.shade300,
                                          );
                                        }),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Индикатор выбора
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.deepPurple,
                                  size: 32,
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
      bottomNavigationBar: Consumer<GameState>(
        builder: (context, gameState, child) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: gameState.currentOpponent != null
                  ? () => _startQuickBattle(context, gameState)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Начать бой',
                style: TextStyle(fontSize: 18),
              ),
            ),
          );
        },
      ),
    );
  }

  void _startQuickBattle(BuildContext context, GameState gameState) {
    // Создаем тестового игрока
    final player = Player(name: 'Игрок 1');

    // Запускаем игру
    gameState.startGame([player]);

    // Переходим на экран игры
    Navigator.pushNamed(context, '/');
  }
}
