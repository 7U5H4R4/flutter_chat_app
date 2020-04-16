
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterchatapp/main.dart';
import 'package:flutterchatapp/pages/conversation_page_list.dart';

void main() {
  testWidgets('Main UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    expect(find.byType(ConversationPageList),findsOneWidget);
  });
}
