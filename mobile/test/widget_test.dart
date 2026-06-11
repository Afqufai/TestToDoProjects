import 'package:flutter_test/flutter_test.dart';
import 'package:workspace_tracker/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WorkspaceTrackerApp());

    // Verify that the CircularProgressIndicator or Login string is there initially.
    expect(find.text('Loading...'), findsOneWidget);
  });
}
