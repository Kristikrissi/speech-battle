import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../models/ai_opponent.dart';
import 'home_screen.dart';
import '../models/player.dart';

class OpponentSelectionScreen extends StatelessWidget {
  const OpponentSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбор противника'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          final quickBattleConfig =
              gameState.gameModeManager.modeConfigs[GameMode.quickBattle];
          final opponents =
              (quickBattleConfig as QuickBattleConfig).availableOpponents;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Выберите противника',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: opponents.length,
                    itemBuilder: (context, index) {
                      final opponent = opponents[index];
                      return _buildOpponentCard(context, gameState, opponent);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOpponentCard(
    BuildContext context,
    GameState gameState,
    AIOpponent opponent,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          gameState.selectOpponent(opponent);

          // Начинаем игру с выбранным противником
          final player = Player(name: 'Игрок 1');
          gameState.startGame([player]);

          // Переходим на экран игры
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          'Уровень: ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          '${opponent.level}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          'Сложность: ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        ...List.generate(5, (index) {
                          return Icon(
                            Icons.star,
                            size: 16,
                            color: index < opponent.level
                                ? Colors.amber
                                : Colors.grey.shade300,
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),

              // Иконка для перехода
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
