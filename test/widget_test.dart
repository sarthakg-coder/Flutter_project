import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project/main.dart';

void main() {
  testWidgets('JobFinderApp smoke test - builds successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const JobFinderApp());
    await tester.pump();

    // Verify that the splash screen shows JobFinder
    expect(find.text('JobFinder'), findsOneWidget);
    expect(find.text('Find Your Dream Job'), findsOneWidget);

    // Advance past the 2-second splash timer so no timers remain pending
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
  });
}
