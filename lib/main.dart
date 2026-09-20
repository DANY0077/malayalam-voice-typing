import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/models/app_state.dart';
import 'src/screens/home_screen.dart';
import 'src/services/speech_service.dart';
import 'src/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storageService = StorageService();
  await storageService.init();
  
  runApp(
    MultiProvider(
      providers [
        ChangeNotifierProvider(create: (_) => AppState(storageService)),
        Provider(create: (_) => SpeechService()),
      ],
      child: const MalayalamVoiceTypingApp(),
    ),
  );
}

class MalayalamVoiceTypingApp extends StatelessWidget {
  const MalayalamVoiceTypingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Malayalam Voice Typing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00695C),
          brightness: Brightness.light,
        ),
        fontFamily: 'NotoSansMalayalam',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00695C),
          brightness: Brightness.dark,
        ),
        fontFamily: 'NotoSansMalayalam',
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}