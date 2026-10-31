import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project/main.dart';

void main() {
  testWidgets('JobFinderApp smoke test - builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const JobFinderApp());
    await tester.pump();

    expect(find.text('JobFinder'), findsOneWidget);
    expect(find.text('Find Your Dream Job'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
  });
}
