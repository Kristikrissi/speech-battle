class AppSettings {
  String language;
  bool soundEnabled;
  bool vibrationEnabled;
  String recognitionLanguage;
  int difficultyLevel;
  bool darkThemeEnabled;

  AppSettings({
    this.language = 'ru',
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.recognitionLanguage = 'ru_RU',
    this.difficultyLevel = 1,
    this.darkThemeEnabled = false,
  });

  // Создание копии с измененными параметрами
  AppSettings copyWith({
    String? language,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? recognitionLanguage,
    int? difficultyLevel,
    bool? darkThemeEnabled,
  }) {
    return AppSettings(
      language: language ?? this.language,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      recognitionLanguage: recognitionLanguage ?? this.recognitionLanguage,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      darkThemeEnabled: darkThemeEnabled ?? this.darkThemeEnabled,
    );
  }

  // Преобразование в Map для сохранения
  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'recognitionLanguage': recognitionLanguage,
      'difficultyLevel': difficultyLevel,
      'darkThemeEnabled': darkThemeEnabled,
    };
  }

  // Создание из Map при загрузке
  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      language: map['language'] ?? 'ru',
      soundEnabled: map['soundEnabled'] ?? true,
      vibrationEnabled: map['vibrationEnabled'] ?? true,
      recognitionLanguage: map['recognitionLanguage'] ?? 'ru_RU',
      difficultyLevel: map['difficultyLevel'] ?? 1,
      darkThemeEnabled: map['darkThemeEnabled'] ?? false,
    );
  }
}
