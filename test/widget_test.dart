import 'package:flutter_test/flutter_test.dart';
import 'package:malayalam_voice_typing/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MalayalamVoiceTypingApp());
    await tester.pumpAndSettle();
    
    expect(find.text('Malayalam Voice Typing'), findsOneWidget);
  });
}