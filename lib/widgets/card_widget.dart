import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/phrase_card.dart';

class CardWidget extends StatelessWidget {
  final PhraseCard card;
  final VoidCallback onSpeak;

  const CardWidget({
    Key? key,
    required this.card,
    required this.onSpeak,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Определяем цвет карточки в зависимости от категории
    Color cardColor;
    switch (card.translation.toLowerCase()) {
      case 'обычная':
        cardColor = Colors.blue.shade100;
        break;
      case 'редкая':
        cardColor = Colors.purple.shade100;
        break;
      case 'эпическая':
        cardColor = Colors.amber.shade100;
        break;
      case 'легендарная':
        cardColor = Colors.orange.shade100;
        break;
      default:
        cardColor = Colors.blue.shade100;
    }

    return Card(
      elevation: 8,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: _getCategoryColor(card.translation),
          width: 2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cardColor,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Категория карточки
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getCategoryColor(card.translation),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  card.translation,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Основной текст фразы
              Text(
                card.text,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Подсказка по интонации
              if (card.intonationHint != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Интонация: ${card.intonationHint}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              // Индикатор сложности
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Сложность: ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  ...List.generate(5, (index) {
                    return Icon(
                      Icons.star,
                      size: 20,
                      color: index < (card.difficulty / 5).ceil()
                          ? Colors.amber
                          : Colors.grey.shade300,
                    );
                  }),
                ],
              ),
              const SizedBox(height: 30),
              
              // Кнопка для произнесения
              ElevatedButton.icon(
                onPressed: onSpeak,
                icon: const Icon(Icons.mic, size: 24),
                label: const Text(
                  'Произнести',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              
              // Информация о микрофоне для веб-версии
              if (kIsWeb) ...[
                const SizedBox(height: 10),
                const Text(
                  'Примечание: Если микрофон не работает, убедитесь, что вы открыли приложение через HTTPS и разрешили доступ к микрофону в настройках браузера.',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'обычная':
        return Colors.blue;
      case 'редкая':
        return Colors.purple;
      case 'эпическая':
        return Colors.amber.shade800;
      case 'легендарная':
        return Colors.orange.shade800;
      default:
        return Colors.blue;
    }
  }
}
