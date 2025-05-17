import 'package:speech_battle/models/game_modes.dart' as models;
import 'package:speech_battle/providers/game_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'campaign_screen.dart';
import 'quick_battle_screen.dart';
import 'tournament_screen.dart';
import 'training_screen.dart';

class GameModeSelectionScreen extends StatelessWidget {
  const GameModeSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбор режима игры'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Выберите режим игры',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),

                // Карточки режимов игры
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildGameModeCard(
                        context,
                        gameState,
                        models.GameMode.campaign,
                        Icons.map,
                        Colors.blue.shade100,
                        Colors.blue,
                      ),
                      _buildGameModeCard(
                        context,
                        gameState,
                        models.GameMode.quickBattle,
                        Icons.flash_on,
                        Colors.red.shade100,
                        Colors.red,
                      ),
                      _buildGameModeCard(
                        context,
                        gameState,
                        models.GameMode.weeklyTournament,
                        Icons.emoji_events,
                        Colors.amber.shade100,
                        Colors.amber.shade800,
                      ),
                      _buildGameModeCard(
                        context,
                        gameState,
                        models.GameMode.training,
                        Icons.school,
                        Colors.green.shade100,
                        Colors.green,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameModeCard(
    BuildContext context,
    GameState gameState,
    models.GameMode mode,
    IconData icon,
    Color backgroundColor,
    Color iconColor,
  ) {
    // Преобразуем models.GameMode в GameMode из providers/game_state.dart
    GameMode providerGameMode;
    switch (mode) {
      case models.GameMode.campaign:
        providerGameMode = GameMode.campaign;
        break;
      case models.GameMode.quickBattle:
        providerGameMode = GameMode.quickBattle;
        break;
      case models.GameMode.weeklyTournament:
        providerGameMode = GameMode.weeklyTournament;
        break;
      case models.GameMode.training:
        providerGameMode = GameMode.training;
        break;
      default:
        providerGameMode = GameMode.quickBattle;
    }

    final config = gameState.gameModeManager.modeConfigs[providerGameMode];

    return GestureDetector(
      onTap: () {
        gameState.selectGameMode(providerGameMode);

        // Переход на соответствующий экран
        if (mode == models.GameMode.campaign) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CampaignScreen()),
          );
        } else if (mode == models.GameMode.quickBattle) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QuickBattleScreen()),
          );
        } else if (mode == models.GameMode.weeklyTournament) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TournamentScreen()),
          );
        } else if (mode == models.GameMode.training) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TrainingScreen()),
          );
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                backgroundColor,
                Colors.white,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: iconColor,
                ),
                const SizedBox(height: 16),
                Text(
                  config?.name ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  config?.description ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
