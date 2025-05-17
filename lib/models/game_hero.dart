class GameHero {
  final String id;
  final String name;
  final String imageUrl;
  final List<String> uniquePhrases;
  final HeroPower power;
  int level;
  int experience;
  
  GameHero({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.uniquePhrases,
    required this.power,
    this.level = 1,
    this.experience = 0,
  });
  
  // Фабричный метод для создания из JSON
  factory GameHero.fromJson(Map<String, dynamic> json) {
    return GameHero(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      uniquePhrases: List<String>.from(json['uniquePhrases']),
      power: HeroPower.fromJson(json['power']),
      level: json['level'] ?? 1,
      experience: json['experience'] ?? 0,
    );
  }
  
  // Метод для преобразования в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'uniquePhrases': uniquePhrases,
      'power': power.toJson(),
      'level': level,
      'experience': experience,
    };
  }
}

// Типы способностей героев
enum PowerType {
  damageBoost,
  accuracyBoost,
  defenseBoost,
  healingBoost,
  specialAttack
}

// Класс для способности героя
class HeroPower {
  final String name;
  final String description;
  final PowerType type;
  final int cooldown;
  bool isReady = true;
  
  HeroPower({
    required this.name,
    required this.description,
    required this.type,
    required this.cooldown,
  });
  
  // Фабричный метод для создания из JSON
  factory HeroPower.fromJson(Map<String, dynamic> json) {
    return HeroPower(
      name: json['name'],
      description: json['description'],
      type: _getPowerTypeFromString(json['type']),
      cooldown: json['cooldown'],
    );
  }
  
  // Метод для преобразования в JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
      'cooldown': cooldown,
    };
  }
  
  // Использование способности
  void use() {
    isReady = false;
  }
  
  // Сброс кулдауна
  void resetCooldown() {
    isReady = true;
  }
  
  // Вспомогательный метод для преобразования строки в тип способности
  static PowerType _getPowerTypeFromString(String typeStr) {
    switch (typeStr) {
      case 'damageBoost':
        return PowerType.damageBoost;
      case 'accuracyBoost':
        return PowerType.accuracyBoost;
      case 'defenseBoost':
        return PowerType.defenseBoost;
      case 'healingBoost':
        return PowerType.healingBoost;
      case 'specialAttack':
        return PowerType.specialAttack;
      default:
        return PowerType.damageBoost;
    }
  }
}
