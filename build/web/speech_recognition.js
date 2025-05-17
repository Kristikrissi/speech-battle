// Глобальная переменная для хранения объекта распознавания
let recognition = null;

// Функция инициализации распознавания речи
function initSpeechRecognition() {
  // Проверяем поддержку распознавания речи
  if ('webkitSpeechRecognition' in window) {
    recognition = new webkitSpeechRecognition();
    recognition.continuous = false;
    recognition.interimResults = true;
    recognition.lang = 'ru-RU';
    
    console.log('Распознавание речи инициализировано');
    return true;
  } else if ('SpeechRecognition' in window) {
    recognition = new SpeechRecognition();
    recognition.continuous = false;
    recognition.interimResults = true;
    recognition.lang = 'ru-RU';
    
    console.log('Распознавание речи инициализировано (стандартное API)');
    return true;
  } else {
    console.error('Распознавание речи не поддерживается в этом браузере');
    return false;
  }
}

// Функция для начала распознавания
window.startSpeechRecognition = function() {
  if (!recognition && !initSpeechRecognition()) {
    console.error('Не удалось инициализировать распознавание речи');
    return false;
  }
  
  try {
    // Настраиваем обработчики событий
    recognition.onstart = function() {
      console.log('Распознавание речи запущено');
      // Отправляем сообщение Flutter
      if (window.flutterSpeechListeningStarted) {
        window.flutterSpeechListeningStarted();
      }
    };
    
    // Обработчик результатов распознавания
    recognition.onresult = function(event) {
      let interimTranscript = '';
      let finalTranscript = '';
      
      for (let i = event.resultIndex; i < event.results.length; ++i) {
        if (event.results[i].isFinal) {
          finalTranscript += event.results[i][0].transcript;
          let confidence = event.results[i][0].confidence;
          
          console.log('Финальный результат:', finalTranscript, 'Уверенность:', confidence);
          
          // Отправляем результат в Flutter
          if (window.flutterSpeechResult) {
            window.flutterSpeechResult(finalTranscript, confidence);
          }
        } else {
          interimTranscript += event.results[i][0].transcript;
          
          console.log('Промежуточный результат:', interimTranscript);
          
          // Отправляем промежуточный результат
          if (window.flutterSpeechInterim) {
            window.flutterSpeechInterim(interimTranscript);
          }
        }
      }
    };
    
    // Обработчик ошибок
    recognition.onerror = function(event) {
      console.error('Ошибка распознавания речи:', event.error);
      if (window.flutterSpeechError) {
        window.flutterSpeechError(event.error);
      }
    };
    
    // Обработчик окончания распознавания
    recognition.onend = function() {
      console.log('Распознавание речи завершено');
      if (window.flutterSpeechEnd) {
        window.flutterSpeechEnd();
      }
    };
    
    // Запускаем распознавание
    recognition.start();
    console.log('Запрос на запуск распознавания отправлен');
    return true;
  } catch (e) {
    console.error('Ошибка при запуске распознавания речи:', e);
    return false;
  }
};

// Функция для остановки распознавания
window.stopSpeechRecognition = function() {
  if (recognition) {
    try {
      recognition.stop();
      console.log('Распознавание речи остановлено');
      return true;
    } catch (e) {
      console.error('Ошибка при остановке распознавания речи:', e);
      return false;
    }
  }
  return false;
};

// Функции для связи с Flutter
window.flutterSpeechResult = function(text, confidence) {
  console.log('Отправка результата в Flutter:', text, confidence);
  if (window.flutter_inappwebview) {
    window.flutter_inappwebview.callHandler('onSpeechResult', text, confidence);
  }
};

window.flutterSpeechInterim = function(text) {
  if (window.flutter_inappwebview) {
    window.flutter_inappwebview.callHandler('onSpeechInterim', text);
  }
};

window.flutterSpeechError = function(error) {
  if (window.flutter_inappwebview) {
    window.flutter_inappwebview.callHandler('onSpeechError', error);
  }
};

window.flutterSpeechEnd = function() {
  if (window.flutter_inappwebview) {
    window.flutter_inappwebview.callHandler('onListeningEnded');
  }
};

window.flutterSpeechListeningStarted = function() {
  if (window.flutter_inappwebview) {
    window.flutter_inappwebview.callHandler('onListeningStarted');
  }
};

// Проверяем доступность микрофона при загрузке страницы
window.addEventListener('DOMContentLoaded', function() {
  console.log('Проверка доступности микрофона...');
  
  if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
    navigator.mediaDevices.getUserMedia({ audio: true })
      .then(function(stream) {
        console.log('Микрофон доступен!');
        // Останавливаем все треки, чтобы освободить микрофон
        stream.getTracks().forEach(track => track.stop());
      })
      .catch(function(err) {
        console.error('Ошибка доступа к микрофону:', err);
      });
  } else {
    console.error('getUserMedia не поддерживается в этом браузере');
  }
  
  // Инициализируем распознавание речи
  initSpeechRecognition();
});

// Функция для проверки разрешения микрофона
window.checkMicrophonePermission = function(callback) {
  if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
    navigator.mediaDevices.getUserMedia({ audio: true })
      .then(function(stream) {
        console.log('Микрофон доступен!');
        // Останавливаем все треки, чтобы освободить микрофон
        stream.getTracks().forEach(track => track.stop());
        // Вызываем callback с положительным результатом
        if (callback) callback(true);
      })
      .catch(function(err) {
        console.error('Ошибка доступа к микрофону:', err);
        // Вызываем callback с отрицательным результатом
        if (callback) callback(false);
      });
  } else {
    console.error('getUserMedia не поддерживается в этом браузере');
    // Вызываем callback с отрицательным результатом
    if (callback) callback(false);
  }
};
