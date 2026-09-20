import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import '../models/app_state.dart';

class WebSpeechService {
  final AppState _appState;
  web.SpeechRecognition? _recognition;
  bool _isListening = false;
  StreamController<String>? _resultController;

  WebSpeechService(this._appState);

  bool get isSupported {
    return web.window.SpeechRecognition != null || 
           web.window.webkitSpeechRecognition != null;
  }

  Future<bool> initialize() async {
    if (!isSupported) {
      _appState.setError('Speech recognition not supported in this browser. Use Chrome/Edge/Safari.');
      return false;
    }

    try {
      final recognitionConstructor = web.window.SpeechRecognition ?? web.window.webkitSpeechRecognition!;
      _recognition = recognitionConstructor.dartify() as web.SpeechRecognition;
      
      _recognition!.lang = _appState.selectedLanguage;
      _recognition!.continuous = true;
      _recognition!.interimResults = true;
      _recognition!.maxAlternatives = 1;

      _recognition!.onresult = _onResult.toJS;
      _recognition!.onerror = _onError.toJS;
      _recognition!.onend = _onEnd.toJS;
      _recognition!.onstart = _onStart.toJS;

      return true;
    } catch (e) {
      _appState.setError('Failed to initialize speech: $e');
      return false;
    }
  }

  void _onResult(web.SpeechRecognitionEvent event) {
    var finalTranscript = '';
    var interimTranscript = '';

    for (var i = event.resultIndex; i < event.results.length; i++) {
      final result = event.results.item(i);
      final transcript = result.item(0).transcript;
      
      if (result.isFinal) {
        finalTranscript += transcript;
      } else {
        interimTranscript += transcript;
      }
    }

    var displayText = _appState.recognizedText;
    if (finalTranscript.isNotEmpty) {
      var formatted = _appState.formatText(finalTranscript);
      _appState.setRecognizedText(formatted);
      _appState.addToHistory(formatted);
    } else if (interimTranscript.isNotEmpty) {
      _appState.setRecognizedText(displayText + interimTranscript);
    }

    _appState.setConfidence(event.results.item(event.resultIndex).item(0).confidence.toDouble());
  }

  void _onError(web.SpeechRecognitionErrorEvent event) {
    String message;
    switch (event.error) {
      case 'no-speech':
        message = 'No speech detected. Try again.';
        break;
      case 'audio-capture':
        message = 'Microphone not accessible. Check permissions.';
        break;
      case 'not-allowed':
        message = 'Microphone permission denied. Enable in browser settings.';
        break;
      case 'network':
        message = 'Network error. Check connection.';
        break;
      default:
        message = 'Speech error: ${event.error}';
    }
    _appState.setError(message);
    _isListening = false;
    _appState.setListening(false);
  }

  void _onEnd(web.Event event) {
    if (_isListening) {
      // Auto-restart for continuous listening
      try {
        _recognition!.start();
      } catch (e) {
        _isListening = false;
        _appState.setListening(false);
      }
    } else {
      _appState.setListening(false);
    }
  }

  void _onStart(web.Event event) {
    _appState.clearError();
    _appState.setConfidence(0.0);
  }

  Future<void> startListening() async {
    if (_recognition == null) {
      await initialize();
    }
    if (_recognition == null) return;

    _isListening = true;
    _appState.setListening(true);
    
    try {
      _recognition!.lang = _appState.selectedLanguage;
      _recognition!.start();
    } catch (e) {
      _isListening = false;
      _appState.setListening(false);
      _appState.setError('Failed to start: $e');
    }
  }

  void stopListening() {
    _isListening = false;
    _recognition?.stop();
    _appState.setListening(false);
  }

  void cancelListening() {
    _isListening = false;
    _recognition?.abort();
    _appState.setListening(false);
  }

  void setLanguage(String language) {
    _recognition?.lang = language;
  }

  void dispose() {
    _recognition?.abort();
    _recognition = null;
  }
}