import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.volume_up),
                title: const Text('Звук'),
                subtitle: Text(
                    gameState.settings.soundEnabled ? 'Включен' : 'Выключен'),
                trailing: Switch(
                  value: gameState.settings.soundEnabled,
                  onChanged: (value) {
                    gameState.updateSoundEnabled(value);
                  },
                  activeColor: Colors.deepPurple,
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.vibration),
                title: const Text('Вибрация'),
                subtitle: Text(gameState.settings.vibrationEnabled
                    ? 'Включена'
                    : 'Выключена'),
                trailing: Switch(
                  value: gameState.settings.vibrationEnabled,
                  onChanged: (value) {
                    gameState.updateVibrationEnabled(value);
                  },
                  activeColor: Colors.deepPurple,
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Язык приложения'),
                subtitle: Text(gameState.settings.language == 'ru'
                    ? 'Русский'
                    : 'English'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showLanguageDialog(context, gameState);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.mic),
                title: const Text('Язык распознавания'),
                subtitle: Text(_getRecognitionLanguageName(
                    gameState.settings.recognitionLanguage)),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showRecognitionLanguageDialog(context, gameState);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.fitness_center),
                title: const Text('Сложность игры'),
                subtitle: Text(
                    _getDifficultyName(gameState.settings.difficultyLevel)),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showDifficultyDialog(context, gameState);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Статистика'),
                subtitle:
                    Text('Игр сыграно: ${gameState.playerStats.gamesPlayed}, '
                        'Побед: ${gameState.playerStats.gamesWon}, '
                        'Поражений: ${gameState.playerStats.gamesLost}'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings_backup_restore,
                    color: Colors.orange),
                title: const Text('Сбросить настройки'),
                subtitle:
                    const Text('Вернуть настройки к значениям по умолчанию'),
                onTap: () {
                  _showResetConfirmationDialog(context, gameState);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.restore, color: Colors.red),
                title: const Text('Сбросить прогресс'),
                subtitle: const Text('Сброс всего прогресса и достижений'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Сбросить прогресс?'),
                      content: const Text(
                        'Вы уверены, что хотите сбросить весь прогресс? Это действие нельзя отменить.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Отмена'),
                        ),
                        TextButton(
                          onPressed: () {
                            Provider.of<GameState>(context, listen: false)
                                .resetProgress();
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Прогресс сброшен'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          },
                          child: const Text('Сбросить',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('О приложении'),
                subtitle: const Text('Информация о приложении и разработчиках'),
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  String _getRecognitionLanguageName(String code) {
    switch (code) {
      case 'ru_RU':
      case 'ru-RU':
        return 'Русский (Россия)';
      case 'en_US':
        return 'English (US)';
      case 'en_GB':
        return 'English (UK)';
      default:
        return code;
    }
  }

  String _getDifficultyName(int level) {
    switch (level) {
      case 1:
        return 'Легкая';
      case 2:
        return 'Средняя';
      case 3:
        return 'Сложная';
      default:
        return 'Неизвестно';
    }
  }

  void _showLanguageDialog(BuildContext context, GameState gameState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите язык'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Русский'),
              leading: Radio<String>(
                value: 'ru',
                groupValue: gameState.settings.language,
                onChanged: (value) {
                  if (value != null) {
                    gameState.updateLanguage(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('English'),
              leading: Radio<String>(
                value: 'en',
                groupValue: gameState.settings.language,
                onChanged: (value) {
                  if (value != null) {
                    gameState.updateLanguage(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }

  void _showRecognitionLanguageDialog(
      BuildContext context, GameState gameState) {
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<List<dynamic>>(
        future: gameState.speechService.getAvailableLocales(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return AlertDialog(
              title: const Text('Ошибка'),
              content: const Text(
                  'Не удалось загрузить доступные языки распознавания.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          }

          final locales = snapshot.data!;
          bool hasRussian = locales.any((locale) =>
              locale?.localeId == 'ru_RU' ||
              locale?.localeId == 'ru-RU' ||
              locale?.localeId?.startsWith('ru') == true);

          if (kIsWeb && !hasRussian) {
            return AlertDialog(
              title: const Text('Ошибка'),
              content: const Text(
                  'Русский язык недоступен в веб-версии на вашем устройстве. Попробуйте другой браузер или используйте нативное приложение.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          }

          return AlertDialog(
            title: const Text('Язык распознавания'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: locales
                  .where((locale) =>
                      locale != null &&
                      ['ru_RU', 'ru-RU', 'en_US', 'en_GB']
                          .contains(locale.localeId))
                  .map((locale) => ListTile(
                        title: Text(_getRecognitionLanguageName(
                            locale?.localeId ?? '')),
                        leading: Radio<String>(
                          value: locale?.localeId ?? '',
                          groupValue: gameState.settings.recognitionLanguage,
                          onChanged: (value) {
                            if (value != null && value.isNotEmpty) {
                              gameState.updateRecognitionLanguage(value);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ))
                  .toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDifficultyDialog(BuildContext context, GameState gameState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Уровень сложности'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Легкая'),
              leading: Radio<int>(
                value: 1,
                groupValue: gameState.settings.difficultyLevel,
                onChanged: (value) {
                  if (value != null) {
                    gameState.updateDifficultyLevel(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Средняя'),
              leading: Radio<int>(
                value: 2,
                groupValue: gameState.settings.difficultyLevel,
                onChanged: (value) {
                  if (value != null) {
                    gameState.updateDifficultyLevel(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Сложная'),
              leading: Radio<int>(
                value: 3,
                groupValue: gameState.settings.difficultyLevel,
                onChanged: (value) {
                  if (value != null) {
                    gameState.updateDifficultyLevel(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmationDialog(BuildContext context, GameState gameState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сбросить настройки?'),
        content: const Text(
            'Все настройки будут возвращены к значениям по умолчанию. Продолжить?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              gameState.resetSettings();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Настройки сброшены'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Речевая Битва',
      applicationVersion: '1.0.0',
      applicationIcon: const FlutterLogo(size: 64),
      applicationLegalese: '© 2025 Речевая Битва',
      children: [
        const SizedBox(height: 20),
        const Text(
          'Речевая Битва - это игра для тренировки произношения и речи. '
          'Произносите фразы с правильной интонацией, сражайтесь с противниками и улучшайте свои навыки!',
        ),
        const SizedBox(height: 16),
        const Text(
          'Разработано с использованием Flutter и технологий распознавания речи.',
        ),
      ],
    );
  }
}
