import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clipboard/clipboard.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vibration/vibration.dart';
import '../models/app_state.dart';
import '../services/speech_service_interface.dart';
import '../widgets/language_selector.dart';
import '../widgets/text_display.dart';
import '../widgets/control_buttons.dart';
import '../widgets/history_panel.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late SpeechServiceInterface _speechService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeSpeech();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _speechService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _speechService.cancelListening();
    }
  }

  Future<void> _initializeSpeech() async {
    _speechService = context.read<SpeechServiceInterface>();
    final initialized = await _speechService.initialize();
    if (mounted) {
      setState(() => _isInitialized = initialized);
    }
  }

  void _onListenPressed() {
    final appState = context.read<AppState>();
    if (appState.isListening) {
      _speechService.stopListening();
    } else {
      _speechService.startListening(
        localeId: appState.selectedLanguage,
        onResult: (text) {
          appState.setRecognizedText(text);
        },
      );
    }
  }

  void _onClearPressed() {
    context.read<AppState>().clearText();
  }

  void _onCopyPressed() {
    final text = context.read<AppState>().recognizedText;
    if (text.isNotEmpty) {
      FlutterClipboard.copy(text);
      _showSnackBar('Copied to clipboard');
      if (context.read<AppState>().vibrationFeedback) {
        Vibration.vibrate(duration: 30);
      }
    }
  }

  void _onSharePressed() {
    final text = context.read<AppState>().recognizedText;
    if (text.isNotEmpty) {
      Share.share(text, subject: 'Malayalam Voice Typing');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Malayalam Voice Typing'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: _isInitialized
          ? Column(
              children: [
                const LanguageSelector(),
                Expanded(
                  child: TextDisplay(),
                ),
                ControlButtons(onListenPressed: _onListenPressed),
                const HistoryPanel(),
              ],
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing speech recognition...'),
                ],
              ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'copy',
            mini: true,
            onPressed: _onCopyPressed,
            tooltip: 'Copy to clipboard',
            child: const Icon(Icons.copy),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'share',
            mini: true,
            onPressed: _onSharePressed,
            tooltip: 'Share text',
            child: const Icon(Icons.share),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'clear',
            mini: true,
            onPressed: _onClearPressed,
            tooltip: 'Clear text',
            child: const Icon(Icons.clear),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => _SettingsPanel(scrollController: scrollController),
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  final ScrollController scrollController;

  const _SettingsPanel({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
          const Divider(),
          SwitchListTile(
            title: const Text('Auto Punctuation'),
            subtitle: const Text('Automatically add periods, commas'),
            value: appState.autoPunctuate,
            onChanged: (_) => appState.toggleAutoPunctuate(),
          ),
          SwitchListTile(
            title: const Text('Auto Capitalization'),
            subtitle: const Text('Capitalize first letter of sentences'),
            value: appState.autoCapitalize,
            onChanged: (_) => appState.toggleAutoCapitalize(),
          ),
          SwitchListTile(
            title: const Text('Vibration Feedback'),
            subtitle: const Text('Vibrate on start/stop recording'),
            value: appState.vibrationFeedback,
            onChanged: (_) => appState.toggleVibrationFeedback(),
          ),
          const Divider(),
          ListTile(
            title: const Text('Clear History'),
            leading: const Icon(Icons.delete_sweep),
            onTap: () {
              appState.clearHistory();
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('About'),
            leading: const Icon(Icons.info),
            onTap: () => _showAbout(context),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Malayalam Voice Typing',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.mic, size: 48),
      children: [
        const Text('AI-powered voice typing for Malayalam'),
        const Text('Turns natural speech into clean, properly punctuated text.'),
      ],
    );
  }
}