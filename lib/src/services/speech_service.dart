import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';
import 'app_state.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  final AppState _appState;
  StreamSubscription? _subscription;
  Timer? _silenceTimer;
  bool _isInitialized = false;

  SpeechService(this._appState);

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    final micPermission = await Permission.microphone.request();
    if (!micPermission.isGranted) {
      _appState.setError('Microphone permission required');
      return false;
    }

    final speechPermission = await Permission.speech.request();
    if (!speechPermission.isGranted) {
      _appState.setError('Speech recognition permission required');
      return false;
    }

    try {
      _isInitialized = await _speech.initialize(
        onError: _onError,
        onStatus: _onStatus,
        debugLogging: kDebugMode,
      );
      
      if (!_isInitialized) {
        _appState.setError('Failed to initialize speech recognition');
      }
      
      return _isInitialized;
    } catch (e) {
      _appState.setError('Speech initialization error: $e');
      return false;
    }
  }

  void _onError(error) {
    _appState.setError('Speech error: ${error.errorMsg}');
    _appState.setListening(false);
    _stopSilenceTimer();
  }

  void _onStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      _appState.setListening(false);
      _stopSilenceTimer();
    }
  }

  Future<void> startListening({
    required String localeId,
    Function(String)? onResult,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isInitialized) return;

    _appState.clearError();
    _appState.setListening(true);
    _appState.setConfidence(0.0);

    if (_appState.vibrationFeedback) {
      await Vibration.vibrate(duration: 50);
    }

    _speech.listen(
      onResult: (result) {
        _appState.setConfidence(result.confidence);
        
        if (result.finalResult) {
          var text = result.recognizedWords;
          text = _appState.formatText(text);
          
          if (onResult != null) {
            onResult(text);
          } else {
            _appState.setRecognizedText(text);
          }
          
          _appState.addToHistory(text);
        } else {
          _appState.setRecognizedText(result.recognizedWords);
        }
        
        _resetSilenceTimer();
      },
      localeId: localeId,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
  }

  void stopListening() {
    _speech.stop();
    _stopSilenceTimer();
    _appState.setListening(false);
  }

  void cancelListening() {
    _speech.cancel();
    _stopSilenceTimer();
    _appState.setListening(false);
    _appState.setProcessing(false);
  }

  void _resetSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(seconds: 5), () {
      if (_appState.isListening && !_appState.isProcessing) {
        _appState.setProcessing(true);
      }
    });
  }

  void _stopSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = null;
  }

  Future<List<LocaleName>> getAvailableLanguages() async {
    return await _speech.locales();
  }

  bool get isListening => _speech.isListening;
  bool get isAvailable => _isInitialized;

  void dispose() {
    _subscription?.cancel();
    _stopSilenceTimer();
    _speech.cancel();
  }
}