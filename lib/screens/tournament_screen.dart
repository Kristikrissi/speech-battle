import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';

class TournamentScreen extends StatelessWidget {
  const TournamentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Еженедельный турнир'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emoji_events,
                  size: 80,
                  color: Colors.amber,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Еженедельный турнир',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Соревнуйтесь с другими игроками за призы',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Текущий ранг: 10',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Очки: 0',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // Логика начала турнирного матча
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Начать матч'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}