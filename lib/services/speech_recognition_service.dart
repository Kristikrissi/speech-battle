import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechRecognitionResult {
  final String text;
  final bool isFinal;

  SpeechRecognitionResult({required this.text, required this.isFinal});
}

class SpeechRecognitionService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  String _selectedLocaleId = 'ru_RU';
  List<LocaleName> _availableLocales = [];

  final _resultController =
      StreamController<SpeechRecognitionResult>.broadcast();
  final _statusController = StreamController<bool>.broadcast();

  Stream<SpeechRecognitionResult> get resultStream => _resultController.stream;
  Stream<bool> get statusStream => _statusController.stream;
  bool get isInitialized => _isInitialized;
  List<LocaleName> get availableLocales => _availableLocales;
  String get currentLocale => _selectedLocaleId;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speech.initialize(
        onStatus: (status) {
          debugPrint('Speech recognition status: $status');
          _statusController.add(_speech.isListening);
        },
        onError: (error) {
          debugPrint('Speech recognition error: $error');
          _statusController.add(false);
        },
        debugLogging: kDebugMode,
      );

      if (_isInitialized) {
        _availableLocales = await _speech.locales();
        debugPrint(
            'Available locales: ${_availableLocales.map((l) => "${l.localeId} (${l.name})").join(', ')}');

        // Автоматически пытаемся найти русскую локаль
        await findAndSetRussianLocale();

        debugPrint(
            'Selected locale: $_selectedLocaleId (${_getLocaleName(_selectedLocaleId)})');
      } else {
        debugPrint('Speech recognition initialization failed');
      }

      return _isInitialized;
    } catch (e) {
      debugPrint('Error initializing speech recognition: $e');
      _isInitialized = false;
      return false;
    }
  }

  String _getLocaleName(String localeId) {
    final locale = _availableLocales.firstWhere(
      (l) => l.localeId == localeId,
      orElse: () => LocaleName(localeId, 'Unknown'),
    );
    return locale.name;
  }

  void startListening() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }

    if (_speech.isListening) {
      await stopListening(); // Останавливаем предыдущее прослушивание
      await Future.delayed(
          const Duration(milliseconds: 200)); // Небольшая задержка
    }

    try {
      debugPrint(
          'Starting listening with locale: $_selectedLocaleId (${_getLocaleName(_selectedLocaleId)})');

      // В веб-версии пробуем использовать ru-RU, если ru_RU не работает
      String localeToUse = _selectedLocaleId;
      if (kIsWeb &&
          !_availableLocales.any((l) => l.localeId == _selectedLocaleId)) {
        localeToUse = _selectedLocaleId.replaceAll('_', '-'); // ru_RU -> ru-RU
        debugPrint('Web fallback: trying locale $localeToUse');
      }

      await _speech.listen(
        onResult: (result) {
          debugPrint(
              'Recognition result: ${result.recognizedWords} (final: ${result.finalResult})');
          _resultController.add(
            SpeechRecognitionResult(
              text: result.recognizedWords,
              isFinal: result.finalResult,
            ),
          );
        },
        localeId: localeToUse,
        listenMode: ListenMode.confirmation,
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
        partialResults: true,
      );

      _statusController.add(true);
    } catch (e) {
      debugPrint('Error starting speech recognition: $e');
      _statusController.add(false);
    }
  }

  Future<void> stopListening() async {
    if (!_speech.isListening) return;

    try {
      await _speech.stop();
      _statusController.add(false);
      debugPrint('Speech recognition stopped');
    } catch (e) {
      debugPrint('Error stopping speech recognition: $e');
    }
  }

  Future<bool> checkAvailability() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      return initialized;
    }
    return _isInitialized;
  }

  Future<bool> checkMicrophoneAvailability() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return false;
    }

    // Проверка доступности микрофона
    // В SpeechToText нет прямого метода для проверки микрофона,
    // поэтому используем initialize как индикатор доступности
    return _isInitialized;
  }

  Future<List<LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return [];
    }

    if (_availableLocales.isEmpty) {
      _availableLocales = await _speech.locales();
    }

    return _availableLocales;
  }

  void setLocale(String localeId) {
    // Проверяем оба формата: ru_RU и ru-RU
    String normalizedLocaleId = localeId;
    if (!_availableLocales.any((locale) => locale.localeId == localeId)) {
      normalizedLocaleId = localeId.replaceAll('_', '-'); // ru_RU -> ru-RU
    }
    if (_availableLocales
        .any((locale) => locale.localeId == normalizedLocaleId)) {
      _selectedLocaleId = normalizedLocaleId;
      debugPrint(
          'Locale set to: $_selectedLocaleId (${_getLocaleName(_selectedLocaleId)})');
    } else {
      debugPrint('Warning: Locale $localeId not found in available locales');
    }
  }

  Future<bool> findAndSetRussianLocale() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return false;
    }

    if (_availableLocales.isEmpty) {
      _availableLocales = await _speech.locales();
      debugPrint(
          'Available locales after fetch: ${_availableLocales.map((l) => "${l.localeId} (${l.name})").join(', ')}');
    }

    for (final locale in _availableLocales) {
      if (locale.localeId == 'ru_RU' ||
          locale.localeId == 'ru-RU' ||
          locale.localeId.startsWith('ru') ||
          locale.name.toLowerCase().contains('рус') ||
          locale.name.toLowerCase().contains('rus') ||
          locale.name.toLowerCase().contains('russian')) {
        _selectedLocaleId = locale.localeId;
        debugPrint('Found Russian locale: $_selectedLocaleId (${locale.name})');
        return true;
      }
    }

    debugPrint('Russian locale not found, falling back to default');
    if (_availableLocales.isNotEmpty) {
      _selectedLocaleId = _availableLocales.first.localeId;
      debugPrint('Set default locale: $_selectedLocaleId');
    }
    return false;
  }

  Future<void> reset() async {
    await stopListening();
    // Дополнительные действия по сбросу состояния, если необходимо
    debugPrint('Speech recognition service reset');
  }

  void dispose() {
    stopListening();
    _resultController.close();
    _statusController.close();
    debugPrint('Speech recognition service disposed');
  }
}
