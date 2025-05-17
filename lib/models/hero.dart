class GameHero {
  final String id;
  final String name;
  final String imageUrl;
  final List<String> uniquePhrases;
  final HeroPower power;
  final int level;
  final int experience;
  
  GameHero({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.uniquePhrases,
    required this.power,
    this.level = 1,
    this.experience = 0,
  });
}

class HeroPower {
  final String name;
  final String description;
  final PowerType type;
  final int cooldown;
  
  HeroPower({
    required this.name,
    required this.description,
    required this.type,
    required this.cooldown,
  });
}

enum PowerType {
  damageBoost,
  accuracyBoost,
  defenseBoost,
  healingBoost,
  specialAttack
}