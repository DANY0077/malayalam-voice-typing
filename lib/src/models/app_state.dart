import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  final StorageService _storage;
  
  String _recognizedText = '';
  bool _isListening = false;
  bool _isProcessing = false;
  String _selectedLanguage = 'ml-IN';
  double _confidence = 0.0;
  String _lastError = '';
  List<String> _history = [];
  bool _autoPunctuate = true;
  bool _autoCapitalize = true;
  bool _vibrationFeedback = true;

  AppState(this._storage) {
    _loadSettings();
  }

  String get recognizedText => _recognizedText;
  bool get isListening => _isListening;
  bool get isProcessing => _isProcessing;
  String get selectedLanguage => _selectedLanguage;
  double get confidence => _confidence;
  String get lastError => _lastError;
  List<String> get history => _history;
  bool get autoPunctuate => _autoPunctuate;
  bool get autoCapitalize => _autoCapitalize;
  bool get vibrationFeedback => _vibrationFeedback;

  Future<void> _loadSettings() async {
    _autoPunctuate = _storage.getBool('auto_punctuate') ?? true;
    _autoCapitalize = _storage.getBool('auto_capitalize') ?? true;
    _vibrationFeedback = _storage.getBool('vibration_feedback') ?? true;
    _history = _storage.getStringList('history') ?? [];
    notifyListeners();
  }

  void setRecognizedText(String text) {
    _recognizedText = text;
    notifyListeners();
  }

  void appendRecognizedText(String text) {
    _recognizedText += text;
    notifyListeners();
  }

  void clearText() {
    _recognizedText = '';
    notifyListeners();
  }

  void setListening(bool value) {
    _isListening = value;
    if (!value) _isProcessing = false;
    notifyListeners();
  }

  void setProcessing(bool value) {
    _isProcessing = value;
    notifyListeners();
  }

  void setConfidence(double value) {
    _confidence = value;
    notifyListeners();
  }

  void setError(String error) {
    _lastError = error;
    notifyListeners();
  }

  void clearError() {
    _lastError = '';
    notifyListeners();
  }

  void setLanguage(String language) {
    _selectedLanguage = language;
    _storage.setString('selected_language', language);
    notifyListeners();
  }

  void toggleAutoPunctuate() {
    _autoPunctuate = !_autoPunctuate;
    _storage.setBool('auto_punctuate', _autoPunctuate);
    notifyListeners();
  }

  void toggleAutoCapitalize() {
    _autoCapitalize = !_autoCapitalize;
    _storage.setBool('auto_capitalize', _autoCapitalize);
    notifyListeners();
  }

  void toggleVibrationFeedback() {
    _vibrationFeedback = !_vibrationFeedback;
    _storage.setBool('vibration_feedback', _vibrationFeedback);
    notifyListeners();
  }

  void addToHistory(String text) {
    if (text.trim().isEmpty) return;
    _history.insert(0, text);
    if (_history.length > 50) _history = _history.sublist(0, 50);
    _storage.setStringList('history', _history);
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    _storage.setStringList('history', _history);
    notifyListeners();
  }

  String formatText(String text) {
    if (text.trim().isEmpty) return text;
    
    var formatted = text.trim();
    
    if (_autoCapitalize) {
      formatted = _capitalizeSentences(formatted);
    }
    
    if (_autoPunctuate) {
      formatted = _addPunctuation(formatted);
    }
    
    return formatted;
  }

  String _capitalizeSentences(String text) {
    final sentences = text.split(RegExp(r'([.!?])\s*'));
    final result = <String>[];
    for (var i = 0; i < sentences.length; i++) {
      final sentence = sentences[i].trim();
      if (sentence.isNotEmpty) {
        result.add(sentence[0].toUpperCase() + sentence.substring(1));
      }
      if (i < sentences.length - 1) {
        result.add(sentences[i].contains(RegExp(r'[.!?]')) ? '. ' : '');
      }
    }
    return result.join();
  }

  String _addPunctuation(String text) {
    var result = text;
    
    result = result.replaceAllMapped(
      RegExp(r'\b(but|and|or|because|so|however|therefore|meanwhile)\b', caseSensitive: false),
      (match) => ', ${match.group(0)}',
    );
    
    result = result.replaceAllMapped(
      RegExp(r'\s+(malayalam|english|hindi|tamil|kannada|telugu)\b', caseSensitive: false),
      (match) => '. ${match.group(0)!.trim()}',
    );

    if (!result.endsWith(RegExp(r'[.!?]'))) {
      result += '.';
    }
    
    return result;
  }
}