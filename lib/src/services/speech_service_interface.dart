import 'package:flutter/foundation.dart';
import 'speech_service.dart';
import 'web_speech_service.dart';
import '../models/app_state.dart';

abstract class SpeechServiceInterface {
  Future<bool> initialize();
  Future<void> startListening({required String localeId, Function(String)? onResult});
  void stopListening();
  void cancelListening();
  void setLanguage(String language);
  void dispose();
  bool get isListening;
  bool get isAvailable;
}

class SpeechServiceFactory {
  static SpeechServiceInterface create(AppState appState) {
    if (kIsWeb) {
      return WebSpeechService(appState);
    } else {
      return SpeechService(appState);
    }
  }
}