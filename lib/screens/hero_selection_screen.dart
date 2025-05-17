import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';

class HeroSelectionScreen extends StatelessWidget {
  const HeroSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбор героя'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          if (gameState.availableHeroes.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: gameState.availableHeroes.length,
            itemBuilder: (context, index) {
              final hero = gameState.availableHeroes[index];
              final isSelected = gameState.selectedHero?.id == hero.id;

              return Card(
                elevation: isSelected ? 8 : 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isSelected ? Colors.deepPurple : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    gameState.selectHero(hero);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Аватар героя
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage(hero.imageUrl),
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
                                hero.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Уровень: ${hero.level}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Сила: ${hero.power.name}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                hero.power.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
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
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            // Переход к экрану выбора оппонента или начала игры
            Navigator.pushNamed(context, '/opponent_selection');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Далее',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
