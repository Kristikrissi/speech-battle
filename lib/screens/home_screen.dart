import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../widgets/card_widget.dart';
import '../models/player.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        return WillPopScope(
          onWillPop: () async {
            // Если игра в процессе, показываем диалог подтверждения
            if (gameState.gameStatus == GameStatus.inProgress) {
              _showExitConfirmationDialog(context, gameState);
              return false; // Предотвращаем автоматический выход
            }
            return true; // Разрешаем выход, если игра не в процессе
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Речевая битва'),
              backgroundColor: Colors.deepPurple,
            ),
            drawer: _buildDrawer(context),
            body: gameState.gameStatus == GameStatus.notStarted
                ? _buildStartScreen(context, gameState)
                : gameState.gameStatus == GameStatus.inProgress
                    ? _buildGameScreen(context, gameState)
                    : _buildResultScreen(context, gameState),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Речевая Битва',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Главная'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Профиль'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.campaign),
            title: const Text('Кампания'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/campaign');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Настройки'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
    );
  }

  // Метод для проверки доступа к микрофону
  void _showMicrophoneInfo(BuildContext context) {
    if (kIsWeb) {
      // Для веб-версии просто показываем информационное сообщение
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Информация о микрофоне'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.mic,
                color: Colors.blue,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'Для работы приложения необходим доступ к микрофону. '
                'Пожалуйста, разрешите доступ к микрофону, когда браузер запросит разрешение.',
              ),
              SizedBox(height: 8),
              Text(
                'Примечание: В некоторых браузерах распознавание речи работает только через HTTPS.',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Понятно'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildStartScreen(BuildContext context, GameState gameState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Добро пожаловать в Речевую Битву!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Text(
            'Тренируйте свою речь, произнося фразы с правильной интонацией',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Кнопка быстрой игры
          ElevatedButton(
            onPressed: () {
              // Показываем информацию о микрофоне перед началом игры
              if (kIsWeb) {
                _showMicrophoneInfo(context);
              }

              // Создаем тестового игрока
              final player = Player(name: 'Игрок 1');
              gameState.startGame([player]);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Быстрая игра',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Кнопка выбора героя
          OutlinedButton(
            onPressed: () {
              // Показываем информацию о микрофоне перед переходом
              if (kIsWeb) {
                _showMicrophoneInfo(context);
              }
              Navigator.pushNamed(context, '/hero_selection');
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.deepPurple),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Выбрать героя',
              style: TextStyle(
                fontSize: 18,
                color: Colors.deepPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen(BuildContext context, GameState gameState) {
    if (gameState.cards.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentCard = gameState.cards[gameState.currentCardIndex];

    return Column(
      children: [
        // Информация о противнике и счете
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Информация о противнике
              if (gameState.currentOpponent != null) ...[
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          AssetImage(gameState.currentOpponent!.imageUrl),
                      onBackgroundImageError: (_, __) =>
                          const Icon(Icons.person),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Противник: ${gameState.currentOpponent!.name}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Счет: ${gameState.opponentScore['opponent'] ?? 0}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Информация о прогрессе и счете игрока
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Карточка: ${gameState.currentCardIndex + 1}/${gameState.cards.length}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Ваш счет: ${gameState.playerScore.values.first}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Карточка с фразой
        Expanded(
          child: CardWidget(
            card: currentCard,
            onSpeak: () {
              gameState.setListening(!gameState.isListening);
            },
          ),
        ),

        // Результаты распознавания
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.grey[200],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Статус: ${gameState.isListening ? "Слушаю..." : "Ожидание"}',
                style: TextStyle(
                  color: gameState.isListening ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (gameState.interimRecognizedText.isNotEmpty &&
                  gameState.isListening)
                Text(
                  'Распознано: ${gameState.interimRecognizedText}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              if (gameState.lastRecognizedText.isNotEmpty)
                Text(
                  'Вы сказали: ${gameState.lastRecognizedText}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              if (gameState.accuracyScore > 0)
                Text(
                  'Ваша точность: ${gameState.accuracyScore.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: gameState.accuracyScore > 70
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (gameState.opponentAccuracy > 0 &&
                  gameState.currentOpponent != null)
                Text(
                  'Точность противника: ${gameState.opponentAccuracy.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: gameState.opponentAccuracy > 70
                        ? Colors.red
                        : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),

        // Кнопки управления
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Кнопка выхода
              OutlinedButton.icon(
                onPressed: () {
                  _showExitConfirmationDialog(context, gameState);
                },
                icon: const Icon(Icons.exit_to_app, color: Colors.red),
                label: const Text(
                  'Выйти',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              // Кнопка "Далее"
              ElevatedButton(
                onPressed: gameState.lastRecognizedText.isNotEmpty
                    ? gameState.nextCard
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Далее',
                    style: TextStyle(
                      color: Colors.white,
                    )),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultScreen(BuildContext context, GameState gameState) {
    final playerScore = gameState.playerScore.values.first;
    final opponentScore = gameState.opponentScore['opponent'] ?? 0;
    final isWinner = playerScore > opponentScore;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isWinner ? 'Победа!' : 'Поражение',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isWinner ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 20),

          // Информация о противнике
          if (gameState.currentOpponent != null) ...[
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(gameState.currentOpponent!.imageUrl),
              onBackgroundImageError: (_, __) => const Icon(Icons.person),
            ),
            const SizedBox(height: 10),
            Text(
              'Противник: ${gameState.currentOpponent!.name}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Счет противника: $opponentScore',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
          ],

          Text(
            'Ваш счет: $playerScore',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),

          Text(
            'Заработано монет: ${gameState.playerProgress.coins}',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          Text(
            'Опыт: ${gameState.playerProgress.experience}',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 40),

          ElevatedButton(
            onPressed: () {
              // Создаем тестового игрока и начинаем новую игру
              final player = Player(name: 'Игрок 1');
              gameState.startGame([player]);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Играть снова'),
          ),

          const SizedBox(height: 20),

          // Кнопка возврата на главный экран
          OutlinedButton(
            onPressed: () {
              // Сбрасываем состояние игры и возвращаемся на главный экран
              gameState.resetGame();
              Navigator.pushReplacementNamed(context, '/');
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.deepPurple),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'На главную',
              style: TextStyle(
                fontSize: 18,
                color: Colors.deepPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Диалог подтверждения выхода из игры
  void _showExitConfirmationDialog(BuildContext context, GameState gameState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выйти из игры?'),
        content: const Text(
          'Вы уверены, что хотите выйти из игры? Ваш прогресс в текущей игре будет потерян.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Закрываем диалог
            },
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Закрываем диалог
              gameState.exitGame(); // Прерываем игру
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
