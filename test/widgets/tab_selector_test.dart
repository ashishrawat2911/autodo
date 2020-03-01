import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autodo/widgets/widgets.dart';
import 'package:autodo/models/models.dart';

void main() {
  group('TabSelector', () {
    testWidgets('should render properly', (WidgetTester tester) async {
      final Key todosTabKey = Key('todosTab');
      final Key refuelingsTabKey = Key('refuelingsTab');
      final Key statsTabKey = Key('statsTab');
      final Key repeatsTabKey = Key('repeatsTab');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(),
            bottomNavigationBar: TabSelector(
              onTabSelected: (_) => null,
              activeTab: AppTab.todos,
              todosTabKey: todosTabKey,
              refuelingsTabKey: refuelingsTabKey,
              statsTabKey: statsTabKey,
              repeatsTabKey: repeatsTabKey,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(todosTabKey), findsOneWidget);
      expect(find.byKey(refuelingsTabKey), findsOneWidget);
      expect(find.byKey(statsTabKey), findsOneWidget);
      expect(find.byKey(repeatsTabKey), findsOneWidget);
    });

    testWidgets('should call onTabSelected with correct index when tab tapped',
        (WidgetTester tester) async {
      AppTab selectedTab;
      final Key todosTabKey = Key('todosTab');
      final Key refuelingsTabKey = Key('refuelingsTab');
      final Key statsTabKey = Key('statsTab');
      final Key repeatsTabKey = Key('repeatsTab');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(),
            bottomNavigationBar: TabSelector(
              onTabSelected: (appTab) {
                selectedTab = appTab;
              },
              activeTab: AppTab.todos,
              todosTabKey: todosTabKey,
              refuelingsTabKey: refuelingsTabKey,
              statsTabKey: statsTabKey,
              repeatsTabKey: repeatsTabKey,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final Finder todoTabFinder = find.byKey(todosTabKey);
      final Finder refuelingTabFinder = find.byKey(refuelingsTabKey);
      final Finder statsTabFinder = find.byKey(statsTabKey);
      final Finder repeatTabFinder = find.byKey(repeatsTabKey);
      expect(todoTabFinder, findsOneWidget);
      expect(statsTabFinder, findsOneWidget);
      await tester.tap(todoTabFinder);
      expect(selectedTab, AppTab.todos);
      await tester.tap(refuelingTabFinder);
      expect(selectedTab, AppTab.refuelings);
      await tester.tap(statsTabFinder);
      expect(selectedTab, AppTab.stats);
      await tester.tap(repeatTabFinder);
      expect(selectedTab, AppTab.repeats);
    });
  });
}
