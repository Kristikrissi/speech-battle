// Функция для инициализации распознавания речи
function initSpeechRecognition() {
  if (!('webkitSpeechRecognition' in window)) {
    alert('Ваш браузер не поддерживает распознавание речи. Попробуйте Chrome.');
    return null;
  }
  
  const recognition = new webkitSpeechRecognition();
  recognition.continuous = false;
  recognition.interimResults = true;
  recognition.lang = 'ru-RU';
  
  return recognition;
}

// Глобальная переменная для хранения объекта распознавания
let recognition = null;

// Функция для начала распознавания
function startListening() {
  if (!recognition) {
    recognition = initSpeechRecognition();
  }
  
  if (recognition) {
    recognition.start();
    window.flutter_inappwebview.callHandler('onListeningStarted');
  }
}

// Функция для остановки распознавания
function stopListening() {
  if (recognition) {
    recognition.stop();
  }
}

// Обработчики событий распознавания
function setupRecognitionHandlers() {
  if (!recognition) return;
  
  recognition.onresult = function(event) {
    let interimTranscript = '';
    let finalTranscript = '';
    
    for (let i = event.resultIndex; i < event.results.length; ++i) {
      if (event.results[i].isFinal) {
        finalTranscript += event.results[i][0].transcript;
        // Получаем уверенность распознавания (от 0 до 1)
        const confidence = event.results[i][0].confidence;
        
        // Отправляем результат в Flutter
        window.flutter_inappwebview.callHandler(
          'onSpeechResult', 
          finalTranscript, 
          confidence
        );
      } else {
        interimTranscript += event.results[i][0].transcript;
        // Отправляем промежуточный результат
        window.flutter_inappwebview.callHandler(
          'onSpeechInterim', 
          interimTranscript
        );
      }
    }
  };
  
  recognition.onerror = function(event) {
    window.flutter_inappwebview.callHandler('onSpeechError', event.error);
  };
  
  recognition.onend = function() {
    window.flutter_inappwebview.callHandler('onListeningEnded');
  };
}

// Инициализация при загрузке страницы
window.addEventListener('load', function() {
  recognition = initSpeechRecognition();
  if (recognition) {
    setupRecognitionHandlers();
  }
});

// Функция для анализа произнесенной фразы
function analyzeSpeech(spokenText, originalText, confidence) {
  // Простой алгоритм для оценки схожести текстов
  const similarity = calculateSimilarity(spokenText.toLowerCase(), originalText.toLowerCase());
  
  // Оценка на основе уверенности распознавания и схожести текстов
  const accuracyScore = Math.round(confidence * 50) + Math.round(similarity * 50);
  
  return {
    accuracy: accuracyScore,
    similarity: similarity,
    confidence: confidence
  };
}

// Функция для расчета схожести текстов (алгоритм Левенштейна)
function calculateSimilarity(a, b) {
  if (a.length === 0) return 0;
  if (b.length === 0) return 0;
  
  const matrix = [];
  
  // Инициализация матрицы
  for (let i = 0; i <= b.length; i++) {
    matrix[i] = [i];
  }
  
  for (let i = 0; i <= a.length; i++) {
    matrix[0][i] = i;
  }
  
  // Заполнение матрицы
  for (let i = 1; i <= b.length; i++) {
    for (let j = 1; j <= a.length; j++) {
      if (b.charAt(i-1) === a.charAt(j-1)) {
        matrix[i][j] = matrix[i-1][j-1];
      } else {
        matrix[i][j] = Math.min(
          matrix[i-1][j-1] + 1, // замена
          matrix[i][j-1] + 1,   // вставка
          matrix[i-1][j] + 1    // удаление
        );
      }
    }
  }
  
  // Расчет схожести (от 0 до 1)
  const maxLength = Math.max(a.length, b.length);
  const distance = matrix[b.length][a.length];
  return 1 - (distance / maxLength);
}
