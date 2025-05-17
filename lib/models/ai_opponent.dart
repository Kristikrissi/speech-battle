class AIOpponent {
  final String name;
  final String imageUrl;
  final int level;
  final double difficultyMultiplier;
  final List<String> phrases;
  
  AIOpponent({
    required this.name,
    required this.imageUrl,
    required this.level,
    required this.difficultyMultiplier,
    required this.phrases,
  });
  
  // Получение случайной фразы
  String getRandomPhrase() {
    if (phrases.isEmpty) {
      return "...";
    }
    phrases.shuffle();
    return phrases.first;
  }
  
  // Расчет урона от противника
  int calculateDamage(int baseDamage) {
    return (baseDamage * difficultyMultiplier).round();
  }
  
  // Фабричный метод для создания из JSON
  factory AIOpponent.fromJson(Map<String, dynamic> json) {
    return AIOpponent(
      name: json['name'],
      imageUrl: json['imageUrl'],
      level: json['level'],
      difficultyMultiplier: json['difficultyMultiplier'].toDouble(),
      phrases: List<String>.from(json['phrases']),
    );
  }
  
  // Метод для преобразования в JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'level': level,
      'difficultyMultiplier': difficultyMultiplier,
      'phrases': phrases,
    };
  }
}
