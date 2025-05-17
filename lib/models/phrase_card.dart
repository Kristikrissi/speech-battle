enum CardRarity { common, rare, epic, legendary }

class PhraseCard {
  final String text;
  final String translation;
  final int difficulty;
  final String? intonationHint;
  final CardRarity rarity;
  final int baseDamage;

  PhraseCard({
    required this.text,
    required this.translation,
    required this.difficulty,
    this.intonationHint,
    this.rarity = CardRarity.common,
    this.baseDamage = 10,
  });

  // Фабричный метод для создания из JSON
  factory PhraseCard.fromJson(Map<String, dynamic> json) {
    // Определение редкости карточки
    CardRarity rarity;
    switch (json['category']?.toLowerCase() ?? 'обычная') {
      case 'редкая':
        rarity = CardRarity.rare;
        break;
      case 'эпическая':
        rarity = CardRarity.epic;
        break;
      case 'легендарная':
        rarity = CardRarity.legendary;
        break;
      default:
        rarity = CardRarity.common;
    }

    return PhraseCard(
      text: json['text'] ?? '',
      translation: json['category'] ?? 'Обычная',
      difficulty: json['difficulty'] ?? (rarity.index + 1) * 2,
      intonationHint: json['intonationHint'],
      rarity: rarity,
      baseDamage: json['baseDamage'] ??
          10, // Используем значение по умолчанию, если baseDamage отсутствует
    );
  }

  // Метод для преобразования в JSON
  Map<String, dynamic> toJson() {
    String category;
    switch (rarity) {
      case CardRarity.common:
        category = 'Обычная';
        break;
      case CardRarity.rare:
        category = 'Редкая';
        break;
      case CardRarity.epic:
        category = 'Эпическая';
        break;
      case CardRarity.legendary:
        category = 'Легендарная';
        break;
    }

    return {
      'text': text,
      'category': category,
      'difficulty': difficulty,
      'intonationHint': intonationHint,
      'baseDamage': baseDamage,
    };
  }

  // Расчет урона с учетом редкости
  int calculateDamage(double accuracyPercent) {
    double rarityMultiplier = 1.0;

    switch (rarity) {
      case CardRarity.common:
        rarityMultiplier = 1.0;
        break;
      case CardRarity.rare:
        rarityMultiplier = 1.5;
        break;
      case CardRarity.epic:
        rarityMultiplier = 2.0;
        break;
      case CardRarity.legendary:
        rarityMultiplier = 3.0;
        break;
    }

    return (baseDamage * rarityMultiplier * (accuracyPercent / 100)).round();
  }
}
