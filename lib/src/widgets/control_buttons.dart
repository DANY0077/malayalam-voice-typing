import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

class ControlButtons extends StatelessWidget {
  final VoidCallback onListenPressed;

  const ControlButtons({super.key, required this.onListenPressed});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ActionButton(
              icon: appState.isListening ? Icons.stop : Icons.mic,
              label: appState.isListening ? 'Stop' : 'Start',
              color: appState.isListening
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
              onPressed: onListenPressed,
              isLarge: true,
            ),
            const SizedBox(width: 16),
            _ActionButton(
              icon: Icons.delete,
              label: 'Clear',
              color: Theme.of(context).colorScheme.outline,
              onPressed: appState.recognizedText.isNotEmpty
                  ? () => appState.clearText()
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final bool isLarge;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: isLarge ? 28 : 20),
      label: Text(
        label,
        style: TextStyle(fontSize: isLarge ? 18 : 14, fontWeight: FontWeight.w600),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        padding: EdgeInsets.symmetric(
          horizontal: isLarge ? 32 : 24,
          vertical: isLarge ? 16 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isLarge ? 16 : 12),
        ),
      ),
    );
  }
}